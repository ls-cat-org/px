#! /usr/bin/python
#
# Automatically run marccd as the right user in the right directory
#

import pg               # Postgresql Database
import time             # Log message timestamps and sleep function
import select           # poll for database notifies
import os               # setuid
import pwd              # get UID from username
import subprocess       # how we run marccd
import tempfile         # Xauthority magic cookie

class AutoDetector:
    db  = None          # Database connection
    currentUser = None  # user currently logged into MD2
    p   = None          # poll object
    pw  = None          # password file entry for current user
    myuid     = None    # Our uid
    myhome    = None    # Our home directory
    mydisplay = None    # Our display

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

        self.myuid = int(os.environ["SUDO_UID"])
        self.myhome = os.environ["HOME"]

        #self.myhome = pwd.getpwuid( self.myuid)[5]    # could possibly use the HOME environment variable here

        self.mydisplay = os.environ["DISPLAY"]   # grab the display name to use

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
            # Steal the xauthority file contents from the current user
            #
            oxaf = open( "%s/.Xauthority" % (self.myhome), "r")
            xa  = oxaf.read()
            oxaf.close()

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
            # Write the xauthority file contents to a new, temporary location
            #
            (xafFd,xafName) = tempfile.mkstemp()
            os.write( xafFd, xa)
            os.close( xafFd)

            #
            # Save stdout and stderr
            #
            cstdout = tempfile.mkstemp( suffix="stdout", prefix="marccd", dir="/tmp")[0]
            cstderr = tempfile.mkstemp( suffix="stderr", prefix="marccd", dir="/tmp")[0]

            #
            # run the marccd program
            #
            marccd = subprocess.Popen( "cd %s; env DISPLAY='%s' XAUTHORITY='/tmp/%s' /usr/local/bin/marccd" % (self.pw[5], self.mydisplay, xafName),
                                       shell=True, stdout=cstdout, stderr=cstderr, stdin=None, bufsize=-1)
                    
            print os.waitpid( marccd.pid, 0)
            #os.unlink( xafName)
            os.close( cstdout)
            os.close( cstderr)
            print "Tata for now!"
            os._exit(0)


    def run( self):
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


if __name__ == "__main__":
    ad = AutoDetector()
    ad.run()
    

