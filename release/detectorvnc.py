#! /usr/local/bin/python
#
# detectorvnc.py
#
# Automatically start marccd in vnc (display :1.0) when someone logs into
# collect data.
#
# (C) 2011 by Keith Brister
# All rights reserved
#

import pg               # postgresql support
import sys              #
import os               #
import subprocess       #
import select           # for poll support
import pwd              # to find our home directory
import time             # sleep
import signal           #

class DetectorVNCError( Exception):
    value = None

    def __init__( self, value):
        self.value = value
        print >> sys.stderr, sys.exc_info()[0]
        print >> sys.stderr, '-'*60
        traceback.print_exc(file=sys.stderr)
        print >> sys.stderr, '-'*60

    def __str__( self):
        return repr( self.value)



class _Q:
    
    db = None   # our database connection

    def open( self):
        self.db = pg.connect( dbname="ls", host="contrabass.ls-cat.org", user="lsuser" )

    def close( self):
        self.db.close()

    def __init__( self):
        self.open()

    def reset( self):
        self.db.reset()

    def query( self, qs):
        if qs == '':
            return rtn
        if self.db.status == 0:
            self.reset()
        try:
            # ping the server
            qr = self.db.query(qs)
        except:
            print "Failed query: %s" % (qs)
            if self.db.status == 1:
                print >> sys.stderr, sys.exc_info()[0]
                print >> sys.stderr, '-'*60
                traceback.print_exc(file=sys.stderr)
                print >> sys.stderr, '-'*60
                return None
            # reset the connection, should
            # put in logic here to deal with transactions
            # as transactions are rolled back
            #
            self.db.reset()
            if self.db.status != 1:
                # Bad status even after a reset, bail
                raise DetectorVNCError( 'Database Connection Lost')

            qr = self.db.query( qs)

        return qr

    def dictresult( self, qr):
        return qr.dictresult()

    def e( self, s):
        return pg.escape_string( s)

    def fileno( self):
        return self.db.fileno()

    def getnotify( self):
        return self.db.getnotify()


class DetectorVNC:
    
    def killprocess( self, signum=None, sframe=None):
        #
        # In CHILD
        #
        if self.screen != None:
            self.screen.terminate()
            self.vnc.terminate()

            time.sleep( 2)      # wait for the excitement to die down

            self.screen.poll()
            if self.screen.returncode == None:
                self.screen.kill()

            self.vnc.poll()
            if self.vnc.returncode == None:
                self.vnc.kill()

    def __init__(self):
        self._q = _Q()
        self._q.query( "select px.detectorvncinit()");
        self.pid    = None      # child that runs as the esaf user
        self.vnc    = None      # Popen object of the vnc process IN CHILD
        self.screen = None      # Popen object of the screen process IN CHILD
        
    def stop_vnc( self):
        #
        # In PARENT
        #
        if self.pid != None:
            #
            # ask the child process to move out
            #
            os.kill( self.pid, signal.SIGABRT)
            i=0
            while i<10:
                xc = os.waitpid( self.pid, os.WNOHANG)
                if xc != (0,0):
                    break
                time.sleep(1)

            if i>=10:
                os.kill( self.pid, signal.SIGKILL)
                os.waitpid( self.pid, 0)

        self.pid = None
        pid2 = os.fork()
        if pid2 != 0:
            #
            # In Parent
            #
            os.waitpid( pid2, 0)
            return
        #
        # In Child
        #
        uid = self.esaf * 100
        os.setgid( uid)
        os.setuid( uid)
        hd = pwd.getpwuid( uid).pw_dir
        os.chdir( hd)

        print >> sys.stderr, "stopping VNC"
        vnc = subprocess.Popen( ["/usr/bin/vncserver",
                                 "-kill",
                                 ":1"
                                 ],
                                env={"HOME" : hd, "PATH" : "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"},
                                stdin=None, stdout=None, stderr=None,
                                close_fds=True, shell=False, cwd=hd
                                )
        vnc.wait()
        os._exit(0)

    def start_vnc( self):
        xstartup = """#!/bin/sh
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
vncconfig -iconic &
gnome-wm &
gnome-panel &
"""

        self.stop_vnc()

        self.pid = os.fork()
        if self.pid != 0:
            #
            # In Parent
            #
            return

        #
        # In Child
        #
        uid = self.esaf * 100
        os.setgid( uid)
        os.setuid( uid)
        hd = pwd.getpwuid( uid).pw_dir
        os.chdir( hd)
        signal.signal( signal.SIGABRT, self.killprocess);

        #
        # Create VNC directory (if needed) and force our xstartup script
        #
        try:
            st = os.stat( "%s/.vnc" % (hd))
        except OSError as e:
            if e.errno == 2:
                os.mkdir( "%s/.vnc" % (hd), 0770)

        f = open( "%s/.vnc/xstartup" % (hd), "w")
        f.write(xstartup)
        f.close()

        #
        # Make our own VNC Password
        # This is not secure, but only local users can access vnc
        # so one should restrict logins from /etc/ssh/sshd_config
        # to keep the server accessable only to staff
        #
        vnc_env={"HOME" : hd, "PATH" : "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"}
        vncpwp = subprocess.Popen( ["/usr/bin/vncpasswd"],
                                   env = vnc_env, shell=False, cwd=hd, close_fds=True,
                                   stdin=subprocess.PIPE, stdout=None, stderr=None
                                   )
                                   
        vncpwp.stdin.write("curolonge\n")
        vncpwp.stdin.write("curolonge\n")
        vncpwp.wait()

        #
        # now to start our vncserver
        #
        print >> sys.stderr, "starting VNC"
        self.vnc = subprocess.Popen( ["/usr/bin/vncserver",
                                      ":1",
                                      "-name", "ESAF %d" % (self.esaf),
                                      "-depth", "24",
                                      "-cc", "4",
                                      "-geometry", "1920x1200",
                                      "-SecurityTypes", "None",
                                      "-AlwaysShared",
                                      "-localhost"
                                      ],
                                     env = vnc_env,
                                     stdin=None, stdout=None, stderr=None,
                                     close_fds=True, shell=False, cwd=hd
                                     )

        time.sleep(5)
        print >> sys.stderr, "starting screen"
        self.screen = subprocess.Popen( ["/usr/bin/screen",
                                         "-d", "-m",
                                         "-s", "/bin/bash",
                                         "-t", "ESAF %d marccd" % (self.esaf),
                                         "/usr/local/bin/marccd"
                                         ],
                                        stdin=None, stdout=None, stderr=None,
                                        env={"DISPLAY":"localhost:1.0", "HOME" : hd, "PATH" : "/usr/local/bin:/usr/bin:/bin/:/usr/sbin:/sbin"},
                                        shell=False, cwd=hd, close_fds=True
                                        )
        
        print >> sys.stderr, "waiting for screen to finish"
        self.screen.wait()
        print >> sys.stderr, "waiting for vnc to finish"
        self.vnc.wait()
        print >> sys.stderr, "Finished"
        os._exit( 0)
        
    def get_esaf( self):
        rtn = None
        qr = self._q.query( "select px.currentesaf() as esaf");
        if qr != None and qr.ntuples() == 1:
            tmp = qr.dictresult()[0]["esaf"]
            if tmp != None:
                rtn = int(tmp)
        return rtn



    def run(self):
        self.esaf = None
        self.pid  = None

        self.esaf = self.get_esaf()
        if self.esaf != None:
            print >>sys.stderr, "Initializing with ESAF: %d" % (self.esaf)
            self.start_vnc()

        p = select.poll()
        p.register( self._q, select.POLLIN)

        running = True
        while running:
            p.poll()

            while self._q.getnotify() != None:
                # eat the notifies
                pass
            next_esaf = self.get_esaf()
            if next_esaf == None or next_esaf != self.esaf:
                if self.esaf != None:
                    print >>sys.stderr, "Stopping ESAF: %d" % (self.esaf)
                    self.stop_vnc()
                    
                self.esaf = next_esaf

                if self.esaf != None:
                    print >>sys.stderr, "Starting ESAF: %d" % (self.esaf)
                    self.start_vnc()

if __name__ == "__main__":
    dvnc = DetectorVNC()
    dvnc.run()
    
