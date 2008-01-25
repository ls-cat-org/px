#! /usr/bin/python

import sys, os, select, pg, time, traceback

#
# Program States
#
#                          +----------------+
#                          |                |
#    MD2 Lock -------------+                +-----------
#
#
#                      +------+
#                      |      |
#    MAR Lock ---------+      +-------------------------
#
#
#              MD2   MAR
#               0     0  Not ready (Mar reading or dead, MD2 waiting, preparing, or dead)
#               0     1  MAR ready for commands
#               1     1  MD2 ready for exposure
#               1     0  MAR Integrating
#              repeat
#
#
#                +------- Dezinger Status
#                |+------ Write    Status
#                ||+----- Correct  Status
#                |||+---- Read     Status
#                ||||+--- Aquire   Status
#                |||||+-- State
#                ||||||
zingMask     = 0x300000
readMask     = 0x000300
aquireMask   = 0x000030
aquiringMask = 0x000020
busyMask     = 0x000008

class PxMarError( Exception):
    value = None

    def __init__( self, value):
        self.value = value

    def __str__( self):
        return repr( self.value)


class PxMarServer:
    """
    Class for communicating with the marccd program
    """

    db = None           # database connection
    dbfd = None         # file descriptor for database connection
    dblock = None       # database connection for table locking semaphores
    dblockfd = None     # file descriptor for locking database connection
    fdin  = None        # our input file descriptor as passed by environment variable FD_IN
    fdout = None        # our output file descriptor as passed by environment variable FD_OUT
    fdoutFlags = None   # flags for polling fdout: used to toggle POLLOUT
    p     = None        # poll object for reading or errors
    fan   = {}          # array of service routines
    queue = []          # message queue to send to marccd
    msg   = None        # message read from marccd
    status = 0          # status response from marccd
    haveLock = False    # indicates we have the "ready to aquire" semaphore
    lo = ""             # left over input from processing reads from marccd
    waitForStatus=True  # flag indicating we should block output until we've received a status update
    skey = None         # key of from shots table with record we want
    fn = None           # filename from "collect" meta command
    collectingFlag=False # indicates we are integrating and should only look for aborts
    outputBlocked=True  # indicates we have blocked the output to the marccd program
    needReadout = False # next command must be readout or else we need to send an abort instead
    flushStatus = True  # flush status buff so we do not get old status

    def close( self):
        if self.dbfd != None and self.p != None:
            try:
                self.p.unregister( self.dbfd)
            except:
                pass
            self.dbfd = None
        if self.db != None and self.db.status == 1:
            if self.db.transaction() >0:
                try:
                    self.db.query( "rollback")
                except:
                    pass
            try:
                self.db.close()
            except:
                pass
            self.db = None
            self.dbfd = None

        if self.dblockfd != None and self.p != None:
            try:
                self.p.unregister( self.dblockfd)
            except:
                pass
            self.dblockfd = None
        if self.dblock != None and self.dblock.status == 1:
            if self.dblock.transaction() >0:
                try:
                    self.dblock.query( "rollback")
                except:
                    pass
            try:
                self.dblock.close()
            except:
                pass
            self.dblock = None
            self.dblockfd = None

    def open( self):
        self.db       = pg.connect(dbname='ls',user='lsuser', host='contrabass.ls-cat.org')
        self.dbfd     = self.db.fileno()
        self.p.register( self.dbfd, select.POLLIN | select.POLLPRI | select.POLLERR | select.POLLHUP | select.POLLNVAL)

        self.dblock   = pg.connect(dbname='ls',user='lsuser', host='contrabass.ls-cat.org')
        self.dblockfd = self.dblock.fileno()
        self.p.register( self.dblockfd, select.POLLIN | select.POLLPRI | select.POLLERR | select.POLLHUP | select.POLLNVAL)

    def reset( self):
        succeeded = False
        while not succeeded:
            try:
                self.close()
                self.open()
                succeeded = True
            except:
                pass
        self.haveLock       = False
        self.collectingFlag = False
        self.outputBlocked  = True
        self.needReadout    = False
        self.flushStatus    = True

        raise PxMarError( 'Reset Complete')

    def query( self, qs):
        rtn = None
        # ignore null queries since we can't tell these from connection errors
        if qs == '':
            return rtn
        if self.db.status == 0:
            self.reset()
        try:
            rtn = self.db.query( qs)
        except:
            print >> sys.stderr, sys.exc_info()[0]
            print >> sys.stderr, '-'*60
            traceback.print_exc(file=sys.stderr)
            print >> sys.stderr, '-'*60

            self.reset()
        return rtn
            
        return self.db.query( qs)

    def waitdist( self):
        print >> sys.stderr, "Enter waitdist"
        qr = self.query( "select px.isthere( 'distance') as isthere" )
        r = qr.dictresult()[0]
        if r["isthere"] != 't':
            loopFlag = 1
            while loopFlag==1:
                time.sleep( 0.21)
                qr = self.query( "select px.isthere( 'distance') as isthere")
                r = qr.dictresult()[0]
                if r["isthere"] == 't':
                    loopFlag=0
        print >> sys.stderr, "Leave waitdist"

    def movedist( self, value):
        print "movedist to %s" % (value)
        qr = self.query( "select px.isthere( 'distance', %s) as isthere" % (value))
        r = qr.dictresult()[0]
        if r["isthere"] != 't':
            self.query( "select px.rt_set_dist(%s)" % (value))
            self.waitdist()

    def checkdir( self, token):
        qr = self.query( "select dskey, dsdir from px.datasets where dspid='"+token+"'")
        r = qr.dictresult()[0]
        theDir = r["dsdir"]
        theKey = r["dskey"]
        theDirState = None
        print "Checking Directory '%s'" % (theDir)
        #
        # Try to create directory
        try:
            os.makedirs( theDir)
            #
            # No error means the directory was valid and we just created it
            theDirState = 'Valid'
        except OSError, (errno, strerror):
            if errno == 17:
                #
                # The only problem is that it alread exists: not really a problem
                theDirState = 'Valid'
            else:
                #
                # Probably the directory path includes something we do not have permissions for
                print "Error creating directory: %s" % (strerror)
                theDirState = 'Invalid'

        self.query( "update px.datasets set dsdirs='%s' where dskey=%d" % (theDirState, theKey))

    def serviceIn( self, event):
        #
        # An error on reading the input stream is probably because the marccd program has terminated
        # We'll just close the database connections and power out
        #
        if event == select.POLLERR:
            self.close()
            sys.exit( 1)

        #
        # Normally this is what we do: service the input from marccd
        #
        if event == select.POLLIN:
            #
            # Read message from detector (add left over characters to the beginning
            self.msg = self.lo + os.read( self.fdin, 4096)
            ml = self.msg.split('\n')

            #
            # If the last item did not terminate with a newline, add it to the left over stuff
            if self.msg[-1] != '\n':
                self.lo = ml[-1]
                ml.pop()
            else:
                self.lo = ""

            #
            # kill off blank entries and excess idles
            for i in range( len(ml) - 1, 0, -1):
                if len(ml[i].strip()) == 0:
                    ml.pop(i)
            #
            # perhaps deposit string into the database
            #self.query( "begin")
            #for s in ml:
            #    self.query( "INSERT INTO px._mar (mrawresponse,mc) VALUES ('%s',inet_client_addr())" % (s))
            #self.query( "commit")

            if not self.flushStatus:
                #
                # use only the last message to set the status
                if len( ml[-1]):
                    self.setStatus( ml[-1])
            else:
                if self.lo == "":
                    self.flushStatus = False

    def serviceOut( self, event):
        #
        # An error on writing the output stream is probably because the marccd program has terminated
        # We'll just close the database connections and power out
        #
        if event == select.POLLERR:
            self.close()
            sys.exit( 1)

        if event == select.POLLOUT:
            #
            # Don't do anything if last command was "start" or we are waiting for status
            if not self.waitForStatus and not (self.collectingFlag and self.haveLock):
                #
                # Get command to send to detector
                cmd = self.nextCmd()
                if cmd != None:
                    print >> sys.stderr, "In serviceOut with cmd=%s" % (cmd)
                    #
                    # Force status read before outputing anynthing else
                    self.waitForStatus = True
                    self.blockOutput()

                    #
                    # if the next command should be a readout but isn't, abort instead
                    #if self.needReadout and (cmd.find("readout") != 0):
                    #    print >> sys.stderr, "Needed readout, got %s, changing to abort" % (cmd)
                    #    print >> sys.stderr, "cmd.find('readout') is %d" % (cmd.find("readout"))
                    #    self.queue=[]
                    #    cmd = "abort"

                    #
                    # regardless, this should be false now
                    self.needReadout = False

                    #
                    # see if we have the "meta command" collect
                    # save the file name and morph into a "start"
                    if cmd.find( "collect") == 0:
                        #
                        # save the file name and queue up the readout command
                        self.key = cmd.split(",")[1]

                        #
                        # get all the information we'll need to write the header and so forth
                        #
                        qs = "select * from px.marheader( %s)" % self.key
                        qr = self.query( qs)
                        r  = qr.dictresult()[0]

                        print >> sys.stderr, "Header Info:", r

                        #
                        # Try to create directory
                        try:
                            os.makedirs( r["dsdir"])
                        except OSError, (errno, strerror):
                            if errno != 17:
                                print "Error creating directory: %s" % (strerror)
                        
                        #
                        # Wait for the detector movement
                        # Currently the detector is moved by the MD2 code.  Change this to movedist(r["sdist"]) if the detector control moves here
                        self.waitdist()

                        self.queue.insert( 0, "readout,0,%s/%s" % (r["dsdir"],r["sfn"]))
                        hs = "header,detector_distance=%s,beam_x=2048,beam_y=2048,exposure_time=%s,start_phi=%s,rotation_axis=%s,rotation_range=%s,source_wavelength=%s\n" % (
                            r["sdist"], r["sexpt"],r["sstart"],r["saxis"],r["swidth"],r["thelambda"]
                            )
                        print >> sys.stderr, hs
                        self.queue.insert( 0, hs)

                        cmd = "start"
                        self.collectingFlag = True
                        self.flushStatus    = True
                        print >> sys.stderr, "found collect, changing to start, adding %s" % (self.queue[0])

                    #
                    # finally, write the command to marccd
                    os.write( self.fdout, cmd + "\n")

    def abort( self):
        self.queue=[]

    def pushCmd( self, cmd):
        if cmd.find('checkdir')==0:
            cl = cmd.split(',')
            if len(cl) > 0:
                self.checkdir( cl[1])
        else:
            #
            # clear command queue if abort is called for
            if cmd == "abort":
                self.abort()
            #
            # Save command in queue
            self.queue.append( cmd)
            print >> sys.stderr, "queued %s" % (cmd)

    def nextCmd( self):
        rtn = None
        if len(self.queue) > 0:
            rtn = self.queue.pop(0)
            print >> sys.stderr, "dequeued %s" % (rtn)
        return rtn

    def setStatus( self, msg):
        rsp = msg.split( ",")
        try:
            self.status = int(rsp[rsp.index("is_state")+1])
        except:
            pass
        else:
            self.waitForStatus = True
            if self.status & busyMask == 0:
                #
                # wait no longer for status
                self.waitForStatus = False

                # if reading or nothing to send, block output to marccd
                #
                if not self.outputBlocked and (((self.status & (readMask | zingMask)) != 0) or len( self.queue) == 0):
                    self.blockOutput()

                # if not reading and not aquiring and something to send, allow it
                if self.outputBlocked and ((self.status & (zingMask | readMask)) == 0) and len( self.queue) > 0:
                    self.enableOutput()

                # if not acquiring, grab the marlock
                if not self.haveLock and (self.status & (aquireMask | readMask)) == 0:
                    print >> sys.stderr, "grabbing marlock"
                    try:
                        self.dblock.query( "begin")
                        self.dblock.query( "select px.lock_detector()")
                    except:
                        self.haveLock = False
                    else:
                        self.haveLock = True

                # if aquiring has started, signal MD2 we are integrating
                if self.haveLock and ((self.status & aquiringMask) != 0):
                    print >> sys.stderr, "giving up marlock"
                    self.dblock.query( "commit")    # give up mar lock
                    self.haveLock      = False      # reset flags
                        
                    #
                    # this is the exposure, command blocks until md2 is done (or dead)
                    # assume the readout command is already queued up
                    print >> sys.stderr, "trying to get md2lock..."
                    self.dblock.query( "select px.lock_diffractometer()")

                    #
                    # allow sending the next command in the queue (should be the readout)
                    self.enableOutput()

                    #
                    # Signal we are done collecting
                    self.collectingFlag = False
                    self.needReadout    = True

    def blockOutput( self):
        print >> sys.stderr, "blocking output"
        self.p.register( self.fdout, ~select.POLLOUT & self.fdoutFlags)
        self.outputBlocked = True


    def enableOutput( self):
        print >> sys.stderr, "enabling output"
        self.p.register( self.fdout, select.POLLOUT | self.fdoutFlags)
        self.outputBlocked = False

    def dbServiceIn( self, event):
        #
        # see if there is a new command
        #
        while self.db.getnotify() != None:
            pass

        flag = True
        while flag:
            if self.collectingFlag:
                qr = self.query( "SELECT px.popqueue('abort') as cmd")
            else:
                qr = self.query( "SELECT px.popqueue() as cmd")
            r = qr.dictresult()[0]
            cmd = r['cmd']
            if len(cmd) == 0:
                flag=False
            else:
                #
                # queue it
                self.pushCmd( cmd)

    def dbLockServiceIn( self, event):
        while self.dblock.getnotify() != None:
            pass

    def __init__( self):
        self.fdin = int(os.getenv( "IN_FD"))
        self.fdout = int(os.getenv("OUT_FD"))
            
        #
        # return from select when fdout has a problem 
        self.fdoutFlags = select.POLLERR | select.POLLHUP | select.POLLNVAL
        self.outputBlocked = True

        self.p = select.poll()
        self.p.register( self.fdin, select.POLLIN | select.POLLPRI | select.POLLERR | select.POLLHUP | select.POLLNVAL)
        self.p.register( self.fdout, self.fdoutFlags)
        
        self.open()

        self.fan = {
            self.fdin      : self.serviceIn,
            self.fdout     : self.serviceOut,
            self.dbfd      : self.dbServiceIn,
            self.dblockfd  : self.dbLockServiceIn
            }

    def run( self):
        runFlag = True

        self.flushStatus = True
        self.ltime = time.time()

        #
        # initialize detector
        self.query( "select px.marinit()")

        while runFlag:
            #
            # check to see if any socket needs service
            for (fd,event) in self.p.poll( 500):
                #
                # call socket's service routine for the given event
                self.fan[fd](event)

            #
            # See if it's time do do "stuff"
            if self.ltime + 2.0 < time.time():
                #
                # see if there is a new command
                #
                # ignore all but the abort command when collecting data
                #
                if self.collectingFlag:
                    qr = self.query( "SELECT px.popqueue('abort') as cmd")
                else:
                    qr = self.query( "SELECT px.popqueue() as cmd")
                r = qr.dictresult()[0]
                cmd = r['cmd']
                if len(cmd) > 0:
                    #
                    # queue it
                    self.pushCmd( cmd)
                    #
                    # set the time
                    self.ltime = time.time()

#
# Default usage
#
if __name__ == '__main__':
    z = PxMarServer()
    while( True):
        try:
            z.run()
        except PxMarError:
            pass
