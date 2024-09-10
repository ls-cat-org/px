#! /usr/bin/python
#
# Restores hard links from /pf/esafs-bu/... to /pf/esafs/... after restoring the former from tape
#
import pg               # postgresql database support
import os               # mkdir, stat
import stat             # stat defines/function
import sys              # exit, stderr
import ldap             # make sure we have correct user info
import traceback        # for messy looking but useful error handling

class restoreHardlinksError( Exception):
    errstr = None

    def __init__( self, errstr):
        self.errstr = errstr
        print >> sys.stderr, errstr
        # print >> sys.stderr, sys.exc_info()[0]
        # print >> sys.stderr, '-'*60
        # traceback.print_exc(file=sys.stderr)
        # print >> sys.stderr, '-'*60

    def __str__( self):
        return repr( self.errstr)


class restoreHardlinks:
    """
    Restores the hardlinks from the /pf/esafs-bu directory to the /pf/esafs directory for a given esaf and, perhaps, given subdirectory.
    """
    
    db = None   # database connection
    l  = None   # ldap connection
    uid = None  # our user's UID
    gid = None  # our user's GID
    hd  = None  # our user's home directory
    bd  = None  # our user's backup directory

    def __init__( self):
        self.db = pg.connect(dbname='ls',user='lsuser', host='postgres.ls-cat.net')
        self.l  = ldap.initialize( "ldap://ldap.ls-cat.net")

    def setUser( self, esaf):
        # get the ldap response tuple list of ls-cat.org enties with uid, uidNumber, gidNumber, and homeDirectory all defined
        lrtl = self.l.search_s( "dc=ls-cat,dc=org", ldap.SCOPE_SUBTREE, "(cn=%d)" % esaf, ["homeDirectory","uidNumber","gidNumber","buDirectory","uid"], 0)

        if len(lrtl) != 1:
            raise restoreHardlinksError( "User information not found")

        self.gid = int(lrtl[0][1]["gidNumber"][0])
        self.uid = int(lrtl[0][1]["uidNumber"][0])
        self.hd  = str(lrtl[0][1]["homeDirectory"][0])
        self.bd  = str(lrtl[0][1]["buDirectory"][0])

        myuid = os.getuid()
        mygid = os.getgid()

        if myuid == 0:
            #
            # we are super user, life is good, fat, and easy
            #
            os.setgid( self.gid)
            os.setuid( self.uid)
        else:
            # we are not super user, who are we?
            #
            if myuid == self.uid:
                #
                # next best thing, we are the correct user
                #
                if mygid != self.gid:
                    #
                    # We are the right user, let's get the group right
                    #
                    os.setgid( self.gid)
            else:
                #
                # We are not the right user
                #
                #raise restoreHardlinksError( "Please try again as 'root' or as '%s'" % (str(lrtl[0][1]["uid"][0])))

                # Perhaps we are in the right group
                #
                gs = os.getgroups()
                idx = None
                try:
                    idx = gs.index( self.gid)
                except ValueError:
                    raise restoreHardlinksError( "Cannot change to gid %d" % (self.gid))

                #
                # Go ahead and try with the correct GID
                #
                if idx != None:
                    os.setregid( self.gid, self.gid)



        #
        # Now that we have that out of the way, cd to the home directory
        #
        os.chdir( self.hd)

    def maybeMakeDirs( self, relpath):
        #
        # make a list of directories to create
        #
        dirsa = relpath.split("/")

        #
        # The last entry is the file name, get rid of it
        #
        dirsa.pop(-1)

        #
        # Refuse to work with an absolute path
        #
        if len(dirsa[0]) == 0:
            print >>sys.stderr, "Only paths relative to the home directory are supported: '%s'" % (relpath)
            sys.exit( -1)

        #
        # Make the directories, if needed in order
        #
        theDir = ""
        for d in dirsa:
            theDir += d + "/"
            goAheadMakeMyDirectory = False
            si = None
            try:
                si = os.stat( theDir)
            except OSError, (errno, strerr):
                if errno == 2:
                    #
                    # Not found.  OK, that is what we want
                    #
                    goAheadMakeMyDirectory = True
                else:
                    raise
            if goAheadMakeMyDirectory:
                #
                # The directory was not found, make it
                #
                try:
                    os.mkdir( theDir)
                except OSError, (errno, strerr):
                    if errno == 13:
                        print >>sys.stderr, "Permission denied trying to create directory '%s'" % (theDir)
                        sys.exit(-1)
                    raise
            else:
                #
                # Stat found something.  Let's make sure it's a directory before we
                # get all hot and heavy.
                #
                if si == None or not stat.S_ISDIR( si.st_mode):
                    print >>sys.stderr, "It looks like '%s' is not a directory.  I don't know how to deal with this turn of events" % (theDir)
                    sys.exit(-1)
                


    def run( self, esaf, subdir=None):
        #
        # setup working directory, uid, and gid
        #
        self.setUser( esaf)
        
        #
        # Get list of affected files
        #
        if subdir == None:
            qs = "select spath, sbupath from px.shots left join px.datasets on dspid=sdspid where dsesaf=%d order by spath" % (esaf)
        else:
            qs = "select spath, sbupath from px.shots left join px.datasets on dspid=sdspid where dsesaf=%d and spath like '%s/%%' order by spath" % (esaf, subdir)

        qr = self.db.query( qs)
        for r in qr.dictresult():
            spath   = r["spath"]
            sbupath = r["sbupath"]

            #
            # Make sure we have something to link to
            #
            si = None
            try:
                si = os.stat( sbupath)
            except OSError, (errno, strerr):
                if errno != 2:
                    # something weird is wrong
                    raise restoreHardlinksError( strerr)
                si = None

            if si == None or not stat.S_ISREG( si.st_mode):
                #
                # don't do anything if this isn't a regular file
                #
                continue

            #
            # Make the parent directories, if needed
            #
            self.maybeMakeDirs( spath)

            #
            # see if something with that name already exists
            #
            noFile = False
            try:
                si = os.stat( spath)
            except OSError, (errno, strerr):
                if errno == 2:
                    #
                    # this is what we want, no file found
                    #
                    noFile = True
                else:
                    # probably not good
                    raise


            if noFile:
                #
                # This is what we want:
                #  hard link to a regular file using a path whose parent directories exists but itself does not exist
                #
                os.link( sbupath, spath)



if __name__ == "__main__":
    rh = restoreHardlinks()
    rh.run( 72497, "d/2010_0731")
    
