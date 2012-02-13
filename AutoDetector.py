#! /usr/local/bin/python
#
# Automatically run marccd as the right user in the right directory
#

import pg               # Postgresql Database
import time             # Log message timestamps and sleep function
import select           # poll for database notifies
import os               # setuid
import pwd              # get UID from username
import subprocess       # how we run marccd
import tempfile         # stderr and stdout create for now
import signal           # defines signal names to kill off X process(es)

class AutoDetector:
    """
    Start up marccd in it own x window using Xvnc or Xnest.  This program keeps an eye on who is logged
    into the station to collect data and restarts marccd in the correct directory as the correct user
    accordingly.
    """
    
    db  = None          # Database connection
    currentUser = None  # user currently logged into MD2
    p   = None          # poll object
    pw  = None          # password file entry for current user
    myuid     = None    # Our uid
    Xnest     = None    # Our Xnest home for marccd
    Xvnc      = None    # Our Xvnc home for the marccd display

    def __init__( self):
        #
        # Make connection to the database
        #
        self.db       = pg.connect(dbname='ls',user='lsuser', host='contrabass.ls-cat.org')

        #
        # Set up the poll object
        #
        self.p = select.poll()
        self.p.register( self.db, select.POLLIN)
        print os.environ

    def dbService( self, event=None):
        #
        # The database sent us something asynchronously
        #
        # First, eat up the notifies
        #
        while self.db.getnotify() != None:
            pass

        #
        # See who is logged into the diffractometer
        #
        qs = "select px.whoami() as wai"
        qr = self.db.query(qs)
        if qr.ntuples() == 1:
            newUser = qr.dictresult()[0]["wai"]
            if self.currentUser == None or newUser != self.currentUser:
                #
                # Time for a changing of the guard
                #
                self.currentUser = newUser
                if self.currentUser != None:
                    self.spawn()


    def spawn( self):
        #
        # Learn about this new user
        #
        self.pw = pwd.getpwnam( self.currentUser)

        #
        # time to fork in preparation of changing the effective user and spawning the marccd process
        #
        pid = os.fork()
        if pid == 0:
            #
            # we are in the child
            #

            #
            # Switch identities
            #
            try:
                os.setregid( self.pw[3], self.pw[3])
                os.setreuid( self.pw[2], self.pw[2])
            except OSError:
                print "Well, that didn't work out.  UID or GID is bad.  Very bad."
                os._exit(-1)


            #
            # Save stdout and stderr
            #
            cstdout = tempfile.mkstemp( suffix="stdout", prefix="marccd", dir="/tmp")[0]
            cstderr = tempfile.mkstemp( suffix="stderr", prefix="marccd", dir="/tmp")[0]

            #
            # Set up the marccd environment: not much should be needed
            #
            marccdEnv = {
                "DISPLAY" : ":2"
                }

            #
            # run the marccd program
            #
            marccd = subprocess.Popen( "/usr/local/bin/marccd", env=marccdEnv,
                                       shell=True, stdout=cstdout, stderr=cstderr, stdin=None, bufsize=-1,
                                       cwd=self.pw[5])
                    
            print os.waitpid( marccd.pid, 0)
            os.close( cstdout)
            os.close( cstderr)
            print "Tata for now!"
            os._exit(0)


    def killX( self):
        """
        Find a X process for screen :2 and kill it dead.
        """
        
        pid = None
        cs = "ps -elf | grep /bin/X | grep '/usr/bin' | grep ':2$' | gawk '{print $4}'"
        pids = subprocess.Popen( cs, shell=True, stdout=subprocess.PIPE).communicate()[0].strip()
        if len(pids) > 0:
            pid = int(pids)

        if pid != None and pid > 1:
            itsDead = False
            try:
                os.kill( pid, signal.SIGQUIT)
                time.sleep( 1)
            except OSError, (errno, strerr):
                if errno != 3:
                    raise
                itsDead = True

            if not itsDead:
                try:
                    os.kill( pid, signal.SIGKILL)
                    time.sleep( 1)
                except OSError, (errno, strerr):
                    if errno != 3:
                        raise
                    itsDead = True

                    
    def startXnest( self):
        """
        Fork off an Xnest process to handle the marccd display.
        """
        pid = os.fork()
        if pid == 0:
            #
            # Child's play
            #
            self.Xnest = subprocess.Popen( [ "/usr/bin/Xnest", "-geometry", "1600x1200", "-class", "TrueColor", "-depth", "24", "-name", "LS-CAT Detector", ":2" ],
                                           shell=False, stdin=None, stdout=None, stderr=None, close_fds=True)
            #
            # Wait for the process to finish (We are killing zombies!)
            #
            os.waitpid( pid, 0)
            os._exit( 0)

    def startXvnc( self):
        """
        Fork off an Xvnc process to handle the marccd display.  To keep things simple, we'll let anyone display whatever they like in this window.
        """
        pid = os.fork()
        if pid == 0:
            #
            # we are in the child
            #
            self.Xvnc = subprocess.Popen( [ "/usr/bin/Xvnc", "-geometry", "1600x1200", "-desktop", "LS-CAT Detector", "-AlwaysShared", "-SecurityTypes", "None", "-depth", "24", "-localhost", ":2" ],
                                          shell=False, stdin=None, stdout=None, stderr=None, close_fds=True)

            #
            # Wait for the process to finish (if only to reduce the number of zombies)
            #
            os.waitpid( self.Xvnc.pid, 0)
            os._exit( 0)

        #
        # Pause for a moment while the server starts up
        #
        time.sleep( 2)

    def run( self):
        """
        Start up the vnc server, marccd for the first time, then loop on changes to the logged in user.
        TODO: should periodically see if marccd is still running and start it up again if it is not.
        """

        #
        # Clean up old servers, hopefully
        #
        self.killX()
        
        # Get the server running
        #
        # self.startXnest()
        self.startXvnc()
        
        #
        # Tell the database to let us know when a login event occurs
        #
        self.db.query( "select px.autologininit()")

        #
        # Call up the db service routine to get
        # the ball rolling.  Should end up with
        # new marccd process running
        #
        self.dbService()

        #
        # Wait around for log in information to change
        #
        running = True
        while running:
            for (fd, event) in self.p.poll():
                self.dbService( event=event)

            #
            # Somewhere down here should be some code to stop this program
            #


if __name__ == "__main__":
    ad = AutoDetector()
    ad.run()
    

