#! /usr/bin/python
#
# Copyright 2010, 2012, 2015, 2016, 2017 by Northwestern University
#
# Automatically run marccd as the right user in the right directory
#

import os               # process management (fork, uid/gid, kill, etc)
import pwd              # get UID from username
import redis            # our no-sql database
import signal           # send/receive signals to/from child processes
import socket           # get our hostname
import subprocess       # how we run marccd
import sys              # for it's normal exit routing
import tempfile         # stderr and stdout create for now
import time             # Log message timestamps and sleep function

class AutoDetector:
    """
    Start up marccd in it own x window using Xvnc or Xnest.  This program keeps an eye on who is logged
    into the station to collect data and restarts marccd in the correct directory as the correct user
    accordingly.
    """

    # This is the historical host alias for the marCCD computer running this script.
    #   For station F, that is "vanilla.ls-cat.org".
    #   For station G, this is "vinegar.ls-cat.org".
    #
    # This alias is used as a redis key, e.g. 'config.vinegar.ls-cat.org'.
    hostAlias = None

    redisHost = None    # Hostname of the IOC redis server
    rClient   = None    # Connection to the IOC's redis
    rSub      = None    # Subscriber handle to IOC's redis
    childShouldKillProcess = False # Used for job control

    currentEsafUser = None  # user currently logged into MD2
    db            = None         # Database connection
    p             = None         # poll object
    pw            = None         # password file entry for current user
    myuid         = None         # Our uid
    Xvnc          = None         # Our Xvnc home for the marccd display
    forkedPID     = None         # Our forked process

    #
    # Redis hashes/keys/values
    #
    config    = None    # config.(vanilla|vinegar).ls-cat.org
    head      = None    # stns.(3|4)
    masterName = None   # stns.(3|4).master
    esafKey   = None    # stns.(3|4).esaf
    esaf      = None    # rclient.hget(self.esafKey, 'VALUE')
    lastEsaf  = None    # Previous value of esaf

    def getCurrentEsaf(self):
        esaf = None
        stmp = self.rClient.hget(self.esaf_key, 'VALUE')
        try:
            esaf = int(stmp)
        except:
            pass

        if esaf == None:
            return

        self.esaf = esaf
        if self.esaf > 0:
            self.currentEsafUser = 'e%d' % (self.esaf)


    def messageHandler(self, msg):
        if msg['data']==self.esaf_key:
            print msg
            self.getCurrentEsaf()


    def __init__( self):
        # Hardcoded alias mappings.
        whichRedis = {
            'vidalia.ls-cat.org' : 'ioc-d.ls-cat.net',
            'venison.ls-cat.org' : 'ioc-e.ls-cat.net',
            'vanilla.ls-cat.org' : 'ioc-f.ls-cat.net',
            'vinegar.ls-cat.org' : 'ioc-g.ls-cat.net'
        }
        self.hostAlias = os.getenv('LS_MARCCD_HOST_ALIAS', socket.gethostname().replace('.net', '.org'))
        self.redisHost = os.getenv('LS_IOC_REDIS_HOST', whichRedis[self.hostAlias])
        self.rClient = redis.StrictRedis(self.redisHost)

        configKey = 'config.%s' % (self.hostAlias)
        self.config = self.rClient.hgetall(configKey)
        if not self.config.has_key('HEAD'):
            print 'Incomplete config params in redis @%s, %s; missing "HEAD" subkey' % (self.redisHost, configKey)
            sys.exit(-1)

        self.head = self.config['HEAD']
        self.masterName = self.head+'.master'
        self.esaf_key   = self.head+'.esaf'

        self.rSub = self.rClient.pubsub(ignore_subscribe_messages=True)
        self.rSub.subscribe( **{ 'REDIS_PG_CONNECTOR': self.messageHandler} )

        self.forkedPID = None
        self.esaf      = None
        self.lastEsaf  = None
        self.childShouldKillProcess = False
        self.getCurrentEsaf();

    def spawnedSignalHandler(self, signum, stack_frame):
        print 'spawnedSignalHandler', signum
        if signum == signal.SIGHUP:
            self.childShouldKillProcess = True

    def spawn(self):
        #
        # Learn about this new user
        #
        self.pw = pwd.getpwnam( self.currentEsafUser)

        print 'spawning new detector process for %s' % (self.currentEsafUser), self.pw

        self.childShouldKillProcess = False
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
                raise
                os._exit(-1)

            signal.signal(signal.SIGHUP, self.spawnedSignalHandler)
            
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
            marccd = subprocess.Popen( "/usr/local/bin/startMarccd", env=marccdEnv,
                                       shell=True, stdout=cstdout, stderr=cstderr, stdin=None, bufsize=-1,
                                       cwd=self.pw[5])
            #
            # Wait for process to end
            #
            while True:
                time.sleep(1)
                waitpidResult = os.waitpid(marccd.pid, os.WNOHANG)
                if waitpidResult[0] != 0:
                    os.close( cstdout)
                    os.close( cstderr)
                    print "Tata for now!"
                    os._exit(0)

                if self.childShouldKillProcess:
                    print 'Trying to terminate marccd process'
                    marccd.terminate()
                    time.sleep(4)
                    try:
                        print 'trying to kill  marccd process'
                        marccd.kill()
                    except:
                        print 'that didn\'t work, perhaps it was already dead'
                        pass
                    self.childShouldKillProcess = False
                    os._exit(0)

        #
        # Still in parent
        #
        self.forkedPID = pid

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

                    
    def startXvnc( self):
        """
        Fork off an Xvnc process to handle the marccd display.  To keep things simple, we'll let anyone display whatever they like in this window.
        """
        pid = os.fork()
        if pid == 0:
            #
            # we are in the child
            #
            ourName = socket.gethostname()

            self.Xvnc = subprocess.Popen( [ "/usr/bin/Xvnc", "-geometry", "1600x1200", "-desktop", ourName+" Detector", "-AlwaysShared", "-SecurityTypes", "None", "-depth", "24", ":2" ],
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
        # TODO: make this a non-default command line option since most
        # of the time this is not what we want to happen.
        #
        self.killX()
        
        # Get the server running
        #
        self.startXvnc()
        
        #
        # Wait around for log in information to change
        #
        running = True
        while running:
            #
            # Our lazy event loop
            #
            time.sleep( 0.1)

            msg = self.rSub.get_message()
            if msg:
                self.messageHandler(msg)

            #
            # Perhaps Collect zoombie
            #
            newlist = []
            if self.forkedPID:
                try:
                    os.waitpid(self.forkedPID, os.WNOHANG)
                except OSError:
                    #
                    # Killed a zombie!
                    #
                    self.forkedPID = None

            #
            # Perhaps start new detector process
            #
            if self.lastEsaf != self.esaf and self.esaf > 0:
                self.lastEsaf = self.esaf
                if self.forkedPID:
                    print 'Sending sighup to child process'
                    os.kill(self.forkedPID, signal.SIGHUP)
                    time.sleep(6)
                    try:
                        print 'Sending sigkill to child process'
                        os.kill(self.forkedPID, signal.SIGKILL)
                    except:
                        print 'Sigkill raised exception, perhaps child quit already'
                        pass

                    os.waitpid(self.forkedPID, 0)       # Cleanup the zombie
                    self.forkedPID = None
                    #
                    # remove old log file
                    #
                    # TODO: put logs in /var/log/pxMarServer and rotate instead of delete
                    #
                    try:
                        os.remove("/tmp/pxMarServer.log")
                    except:
                        pass

                self.spawn()

            #
            # Somewhere down here should be some code to stop this program
            #


if __name__ == "__main__":
    ad = AutoDetector()
    ad.run()
    

