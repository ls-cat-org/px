#! /usr/bin/python

import sys, os, select, pg, time, traceback, datetime

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
#
#
# Errors, warnings, and messages generated here are in the 10000 to 20000 range
#
#

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
    flushStatus = True  # flush status buff so we do not get old status
    hlList      = []    # dictionary of hardlinks to make

    def hlPush( self, d, f, expt, shotKey):
        #
        #
        # Don't add something already in the list
        for hl in self.hlList:
            od = hl[0]
            of = hl[1]
            if od == d and of == f:
                # print >> sys.stderr, "already have dir=%s and file=%s in link queue, ignoring" %(d, f)
                return

        self.hlList.append( (d, f, datetime.datetime.now() + datetime.timedelta( 0, expt), shotKey))

    def hlPop( self):
        cpy = list(self.hlList)
        for hl in cpy:
            d,f,t,shotKey = hl
            
            #
            # Watchout, hardwired timeout
            # delete entry without action if it is over 100 seconds overdue
            #
            if (datetime.datetime.now() - t) > datetime.timedelta(0, 100):
                tmp = datetime.datetime.now() - t
                qs = "select px.pusherror( 10001, 'Waited %d seconds for file %s, gave up.')" % (tmp.days*24*3600 +tmp.seconds, f);
                self.db.query( qs);
                print >> sys.stderr,"------POPING-------------",datetime.datetime.now(),t,tmp
                self.hlList.pop( self.hlList.index(hl))
            else:
                try:
                    os.stat( d+"/"+f)
                except:
                    # the file does not yet exist
                    # print >> sys.stderr, "%s/%s does not yet exist" % (d,f)
                    return

                # print >> sys.stderr, "====== Found it:  %s/%s" % (d,f)
                #
                # find the backup home directory
                qs = "select esaf.e2BUDir(dsesaf) as bp from px.datasets left join px.shots on dspid=sdspid where skey='%s'" % (shotKey)
                qr = self.query( qs)
                rd = qr.dictresult()
                if len( rd) == 0:
                    # print >> sys.stderr, "Shot no longer exists, abandoning it"
                    return
                r = qr.dictresult()[0]
                bp = r["bp"]
                if len(bp) > 0:
                    #
                    # create the path components if needed
                    #
                    if d[0] == '/':
                        bud = bp+"/"+d[1:]
                    else:
                        bud = bp+"/"+d
                            
                    bfn = bud+'/'+f

                    try:
                        # print >> sys.stderr, "making directory %s" % ( bud)
                        os.makedirs( bud)
                    except OSError, (errno, strerr):
                        if errno != 17:
                            qs = "select px.pusherror( 10002, 'Error: %d  %s   Directory: %s')" % (errno, strerr, bud)
                            self.db.query( qs);
                            print >> sys.stderr, "Failed to make backup directory %s" % (bud)
                            self.hlList.pop( self.hlList.index(hl))
                            return


                    #
                    # see if the link already exists
                    # If so, alter the file name and try again
                    i = 0
                    found = True
                    while found:
                        # assume we found it
                        found = True

                        # add a "_ddd" if the link already exists
                        # this prevents someone from overwriting their own data
                        if i==0:
                            bfn = bud+'/'+f
                        else:
                            bfn = "%s/%s_%03d" % (bud, f, i)
                        try:
                            os.stat( bfn)
                        except:
                            found=False
                        i = i+1

                    # print >> sys.stderr, "making hard link %s to file %s\n" % ( bfn, d+'/'+f)
                    try:
                        os.link( d+'/'+f, bfn)
                    except:
                        qs = "select px.pusherror( 10003, 'Hard Link %s,  file %s')" % (bfn, d+'/'+f)
                        self.db.query( qs);
                        print >> sys.stderr, "Failed to make hard link %s to file %s\n" % ( bfn, d+'/'+f)
                    
                    self.hlList.pop( self.hlList.index(hl))

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

    def open( self):
        self.db       = pg.connect(dbname='ls',user='lsuser', host='contrabass.ls-cat.org')
        self.dbfd     = self.db.fileno()
        self.p.register( self.dbfd, select.POLLIN | select.POLLPRI | select.POLLERR | select.POLLHUP | select.POLLNVAL)

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
            rtn = self.db.query( qs)

        return rtn
            
    def waitdist( self):
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

    def movedist( self, value):
        qr = self.query( "select px.isthere( 'distance', %s) as isthere" % (value))
        r = qr.dictresult()[0]
        if r["isthere"] != 't':
            self.query( "select px.rt_set_dist(%s)" % (value))
            self.waitdist()

    def checkdir( self, token):
        qr = self.query( "select dskey, dsdir from px.datasets where dspid='"+token+"'")
        rd = qr.dictresult()
        if len(rd) == 0:
            return
        r = qr.dictresult()[0]
        theDir = r["dsdir"]
        theKey = r["dskey"]
        theDirState = None
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
                qs = "select px.pusherror( 10004, 'Directory: %s, errno: %d, message: %s' % (theDir, errno, strerror)"
                self.db.query( qs);
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
                    #
                    # Force status read before outputing anynthing else
                    self.waitForStatus = True
                    self.blockOutput()


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

                        if r["dsdir"] != None and r["sfn"] != None:
                            try:
                                os.makedirs( r["dsdir"])
                            except OSError, (errno, strerror):
                                if errno != 17:
                                    qs = "select px.pusherror( 10004, 'Directory: %s, errno: %d, message: %s' % (theDir, errno, strerror)"
                                    self.db.query( qs);
                                    print "Error creating directory: %s" % (strerror)

                            #
                            # Wait for the detector movement
                            # Currently the detector is moved by the MD2 code.  Change this to movedist(r["sdist"]) if the detector control moves here
                            self.waitdist()
                            self.queue.insert( 0, "readout,0,%s/%s" % (r["dsdir"],r["sfn"]))
                            hs = "header,detector_distance=%s,beam_x=2048,beam_y=2048,exposure_time=%s,start_phi=%s,file_comments=kappa=%s omega=%s rotation_axis is really omega,rotation_axis=%s,rotation_range=%s,source_wavelength=%s\n" % (
                                r["sdist"], r["sexpt"],r["sstart"],r["skappa"],r["sstart"], "phi",r["swidth"],r["thelambda"]
                                )
                            print >> sys.stderr, hs
                            self.queue.insert( 0, hs)

                            self.hlPush( r["dsdir"], r["sfn"], int(r["sexpt"])+1, self.key)

                        else:
                            # the shot was not found: send the data to the bit bucket but go through the motions of collecting
                            r["dsdir"] = "/dev"
                            r["sfn"]   = "null"
                            self.queue.insert( 0, "readout,0,%s/%s" % (r["dsdir"],r["sfn"]))
                            qs = "select px.pusherror( 10005, '')"
                            self.db.query( qs);
                            print >> sys.stderr, "Request for a non-existant frame: data sent to /dev/null"


                        cmd = "start"
                        self.collectingFlag = True
                        self.flushStatus    = True
                        # print >> sys.stderr, "found collect, changing to start, adding %s" % (self.queue[0])

                        
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
            # print >> sys.stderr, "queued %s" % (cmd)

    def nextCmd( self):
        rtn = None
        if len(self.queue) > 0:
            rtn = self.queue.pop(0)
            # print >> sys.stderr, "dequeued %s" % (rtn)
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
                    print >> sys.stderr, "Your wish is my command.  Waiting patiently for your instructions."
                    self.db.query( "select px.lock_detector()")
                    self.haveLock = True

                # if aquiring has started, signal MD2 we are integrating
                if self.haveLock and ((self.status & aquiringMask) != 0):
                    print >> sys.stderr, "Integrating..."
                    self.db.query( "select px.unlock_detector()")  # give up mar lock
                    self.haveLock      = False      # reset flags
                        
                    #
                    # this is the exposure, command blocks until md2 is done (or dead)
                    # assume the readout command is already queued up
                    print >> sys.stderr, "Waiting for exposure to end..."
                    self.db.query( "select px.lock_diffractometer()")

                    # eventually we'll get the lock, give it up immediately
                    self.db.query( "select px.unlock_diffractometer()")

                    #
                    # allow sending the next command in the queue (should be the readout)
                    self.enableOutput()

                    #
                    # Signal we are done collecting
                    self.collectingFlag = False

    def blockOutput( self):
        self.p.register( self.fdout, ~select.POLLOUT & self.fdoutFlags)
        self.outputBlocked = True


    def enableOutput( self):
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
            # Hardwired time = bad
            #
            if self.ltime + 2.0 < time.time():
                #
                # see if we need to make a hard link
                self.hlPop()

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
