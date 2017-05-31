#! /usr/bin/python
#
# pxMarServer.py
#
# remote mode server to support Mar/Rayonix detectors as LS-CAT
# (C) 2008-2017 by Keith Brister
# All rights reserved.
#

import sys              # stderr and exit
import os               # stat, link, unlink, etc
import select           # we use pool to watch for action on the file descriptors
import pg               # our database module
import time             # error message time stamps
import traceback        # where we were when things went wrong
import datetime         # now...
import subprocess       # run lfs to set the striping and pool for lustre
import signal           # catch term signal to drop locks on exit
import socket           # needed for get hostname for the correct redis configuration
import redis            # new database model

EXIT_NOW = False

def pxMarSignalHandler( signum, frame):
    global EXIT_NOW

    EXIT_NOW = True


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
#    For each of dezinger, write, correct, read, and aquire:
#        1: Queued
#        2: Executing
#        4: Error
#        8: Reserved
#
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
readMask     = 0x000700
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


class _R:
    r       = None      # our connection
    rdy     = False     # true when it looks like our connection is ok and redis is configured
    head    = None      # the start of all our keys in the redis database
    robopub = None      # our pen name
    ourKVs  = {}        # a list of our KV pairs

    def getconfig( self):
        hn = socket.gethostname()
        try:
            self.head = self.r.hget( 'config.%s' % (hn), 'HEAD')
            if self.head == None or self.head == '':
                print >> sys.stderr, 'Redis is not configured for this host "%s"' % (hn)
                self.rdy = False
                self.head = None
                return

            self.robopub = self.r.hget( 'config.%s' % (hn), 'ROBOPUB')

        except redis.exceptions.ConnectionError:
            print >> sys.stderr, 'Redis connection error.  Is it running?'
            self.rdy = False
            self.head = None
            return


    def __init__( self):
        whichRedis = {
            'vidalia.ls-cat.org' : 'mung-2.ls-cat.org',
            'venison.ls-cat.org' : 'orange-2.ls-cat.org',
            'vanilla.ls-cat.org' : 'kiwi-2.ls-cat.org',
            'vinegar.ls-cat.org' : 'mango-2.ls-cat.org'
        }
                       
        
        self.r = redis.Redis( whichRedis[socket.gethostname()]);
        self.getconfig()

    def set( self, k, v):
        if self.ourKVs.has_key( k) and self.ourKVs[k] == v:
            return

        try:
            if self.r.ping():
                if self.head == None:
                    self.getconfig()
                if self.head == None:
                    return
                
                bigk = "%s.%s" % (self.head, k)

                self.r.hmset( bigk, {'KEY': bigk, 'VALUE':v})

                if self.robopub:
                    self.r.publish( self.robopub, bigk)

                self.ourKVs[k] = v
        except:
            print >> sys.stderr, "Redis error setting key '%s' to value '%s'" % (k, v)


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
    xsize = None        # size of image
    ysize = None
    xbin  = None        # current binning
    ybin  = None
    updatedDetectorInfo = False # flag to indicate that we've updated the detectorinfo table

    def hlPush( self, d, f, expt, shotKey):
        #
        #
        # Don't add something already in the list
        for hl in self.hlList:
            od = hl[0]
            of = hl[1]
            if od == d and of == f:
                print >> sys.stderr, time.asctime(), "already have dir=%s and file=%s in link queue, ignoring" %(d, f)
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
                #
                # If the file hasn't been written by now it probably never will be: don't sit around like some kind of sap.
                #
                tmp = datetime.datetime.now() - t
                qs = "select px.pusherror( 10001, 'Waited %d seconds for file %s, gave up.')" % (tmp.days*24*3600 +tmp.seconds, f);
                self.query( qs);
                print >> sys.stderr, time.asctime(), "------POPING-------------",datetime.datetime.now(),t,tmp
                self.hlList.pop( self.hlList.index(hl))
            else:
                #
                # Look for the file
                #
                statinfo = None
                try:
                    statinfo = os.stat( d+"/"+f)
                except:
                    # the file does not yet exist
                    # print >> sys.stderr, time.asctime(), "%s/%s does not yet exist" % (d,f)
                    return

                #
                # Got it
                print >> sys.stderr, time.asctime(), "====== Found it:  %s/%s" % (d,f)
                #
                qs = "select px.shots_set_path( %d, '%s')" % (int(shotKey), d+"/"+f)
                self.query( qs)

                # find the backup home directory
                qs = "select esaf.e2BUDir(px.shots_get_esaf(%d)) as bp" % (int(shotKey))
                qr = self.query( qs)
                rd = qr.dictresult()
                if len( rd) == 0:
                    print >> sys.stderr, time.asctime(), "Shot no longer exists, abandoning it"
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
                        print >> sys.stderr, time.asctime(), "making directory %s" % ( bud)
                        os.makedirs( bud, 0770)
                    except OSError, (errno, strerr):
                        if errno != 17:
                            qs = "select px.pusherror( 10002, 'Error: %d  %s   Directory: %s')" % (errno, strerr, bud)
                            self.query( qs);
                            print >> sys.stderr, time.asctime(), "Failed to make backup directory %s" % (bud)
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

                    print >> sys.stderr, time.asctime(), "making hard link %s to file %s\n" % ( bfn, d+'/'+f)
                    try:
                        os.link( d+'/'+f, bfn)
                    except:
                        qs = "select px.shots_set_state( %d, '%s')" % (int(shotKey), 'Error')
                        self.query( qs)
                        qs = "select px.pusherror( 10003, 'Hard Link %s,  file %s')" % (bfn, d+'/'+f)
                        self.query( qs);
                        print >> sys.stderr, time.asctime(), "Failed to make hard link %s to file %s\n" % ( bfn, d+'/'+f)
                        self.redis.set( 'detector.state', '{ "skey": %d, "sstate": "Error", "msg": "Failed to make hard link %s to file %s", "sdspid": "%s"}' % (int(shotKey), bfd, d+'/'+f), self.sdspid);

                    else:
                        qs = "select px.shots_set_bupath( %d, '%s')" % (int(shotKey), bfn)
                        self.query( qs);
                        qs = "select px.shots_set_state( %d, '%s')" % (int(shotKey), 'Done')
                        self.query( qs)
                        qs = "select px.shots_set_stats( '%s', '%s', px.getstation(), NULL, NULL)" % (bfn, self.sdspid)
                        self.query( qs)
                        self.redis.set( 'detector.state', '{ "skey": %d, "sstate": "Done", "msg": "", "dir": "%s", "fn": "%s", "bdir": "%s", "bfn": "%s", "sdspid": "%s"}' % (int(shotKey), d, f, bud, bfn, self.sdspid));
                    
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

    def es( self, s):
        """
        mimic the pg connection escape_string which is oddly missing in RHEL5
        """
        return s.replace("'","''")

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
            print >> sys.stderr, time.asctime(), sys.exc_info()[0]
            print >> sys.stderr, '-'*60
            traceback.print_exc(file=sys.stderr)
            print >> sys.stderr, '-'*60

            self.reset()
            rtn = self.db.query( qs)

        return rtn
            
    def waitdist( self, theDist):
        # Move the motor and wait for it to stop at the correct place
        #
        # Here the distance is not specified or is boggus
        print >> sys.stderr, time.asctime(), theDist
        if self.skey != None:
            self.query( "select px.shots_set_state( %d, '%s')" % (int(self.skey), 'Moving'))
            self.redis.set( 'detector.state', '{ "skey": %d, "sstate": "Moving", "msg": "", "sdspid": "%s"}' % (int(self.skey), self.sdspid));

        if theDist == None:
            qr = self.query( "select px.isthere( 'distance') as isthere" )
            r = qr.dictresult()[0]
            if r["isthere"] != 't':
                loopFlag = True
                dewarWarningGiven = False
                startLoopTime = datetime.datetime.now()
                while loopFlag:
                    time.sleep( 0.21)
                    qr = self.query( "select px.isthere( 'distance') as isthere")
                    r = qr.dictresult()[0]
                    if r["isthere"] == 't':
                        loopFlag = False
        else:
            #
            # Here we have a defined and perhaps resonable distance
            #
            qs = "select px.isthere( 'distance', %s) as isthere" % (theDist)
            qr = self.query( qs)
            r = qr.dictresult()[0]

            if r["isthere"] == None:
                # something bad happened, abort.
                self.query( "select px.shots_set_state( %d, '%s')" % (int(self.skey), 'Error'))
                self.query( "select px.pauserequest()");
                self.redis.set( 'detector.state', '{ "skey": %d, "sstate": "Error", "msg": "Detector move request failed", "sdspid": "%s"}' % (int(self.skey), self.sdspid));
                return False
                
            if r["isthere"] == 'f':
                loopFlag = True
                dewarWarningGiven = False
                startLoopTime = datetime.datetime.now()
                while loopFlag:
                    time.sleep( 0.21)
                    qr = self.query( qs)
                    r = qr.dictresult()[0]

                    if r["isthere"] == None:
                        # something bad happened, abort.
                        self.query( "select px.shots_set_state( %d, '%s')" % (int(self.skey), 'Error'))
                        self.query( "select px.pauserequest()");
                        self.redis.set( 'detector.state', '{ "skey": %d, "sstate": "Error", "msg": "Detector move request failed.", "sdspid": "%s"}' % (int(self.skey), self.sdspid));
                        return False

                    if r["isthere"] == 't':
                        loopFlag = False
        if self.skey != None:
            self.query( "select px.shots_set_state( %d, '%s')" % (int(self.skey), 'Exposing'))
            self.query( "select px.shots_set_energy( %d)" % (int(self.skey)))
            self.redis.set( 'detector.state', '{ "skey": %d, "sstate": "Exposing", "msg": "", "sdspid": "%s"}' % (int(self.skey), self.sdspid));
        return True;
            

    def checkdir( self, token):
        qr = self.query( "select dsdir from px.getdataset('%s')" % (str(token)))
        rd = qr.dictresult()
        if len(rd) == 0:
            return
        r = qr.dictresult()[0]
        theDir = r["dsdir"]
        theDirState = None
        #
        # Try to create directory
        try:
            os.makedirs( theDir, 0770)
            #
            # No error means the directory was valid and we just created it
            theDirState = 'Valid'
            self.redis.set( 'detector.checkdir', '{ "dir": "%s", "valid": true}' % (theDir));
        except OSError, (errno, strerror):
            if errno == 17:
                #
                # The only problem is that it alread exists: not really a problem
                theDirState = 'Valid'
            else:
                #
                # Probably the directory path includes something we do not have permissions for
                qs = "select px.pusherror( 10004, 'Directory: %s, errno: %d, message: %s')" % (self.es(theDir), errno, self.es(strerror))
                self.query( qs);
                print >> sys.stderr, time.asctime(), "Error creating directory: %s" % (strerror)
                theDirState = 'Invalid'
                self.redis.set( 'detector.checkdir', '{ "dir": "%s", "valid": false}' % (theDir));

        self.query( "select px.ds_set_dirs( '%s', '%s')" % (token, theDirState))
        #
        # Set the lustre options for the new directory
        #
        try:
            p = subprocess.Popen( ["/usr/bin/lfs", "setstripe", "-s", "4M", "-c", "1", "-i", "-1", "-p", self.lustrePool, theDir], close_fds=True, shell=False)
            p.wait()
            if p.returncode != 0:
                print( "lfs returned %d" % (p.returncode))
        except OSError, (errno, strerror):
            if errno != 2:
                raise


    def serviceIn( self, event):

        global EXIT_NOW

        #
        # An error on reading the input stream is probably because the marccd program has terminated
        #
        if event == select.POLLERR:
            EXIT_NOW = True
            return

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
                #
                # Maybe other messages besides status: try to parse them
                self.parseMar(ml)
            else:
                if self.lo == "":
                    self.flushStatus = False

    def serviceOut( self, event):

        global EXIT_NOW
        #
        # An error on writing the output stream is probably because the marccd program has terminated
        # We'll just close the database connections and power out
        #
        if event == select.POLLERR:
            EXIT_NOW=True
            return

        if event == select.POLLOUT:
            #
            # Don't do anything if last command was "start" or we are waiting for status
            if not self.waitForStatus and not (self.collectingFlag and self.haveLock):
                #
                # Get command to send to detector
                cmd = self.nextCmd()
                if cmd != None:
                    #
                    # Force status read before outputting anynthing else
                    self.waitForStatus = True
                    self.blockOutput()


                    #
                    # see if we have the "meta command" collect
                    # save the file name and morph into a "start"
                    if cmd.find( "collect") == 0:
                        #
                        # save the file name and queue up the readout command
                        self.skey = cmd.split(",")[1]
                        

                        #
                        # get most of the information we'll need to write the header and so forth
                        #
                        qs = "select * from px.marheader( %d)" % (int(self.skey))
                        qr = self.query( qs)
                        r  = qr.dictresult()[0]


                        if r["dsdir"] != None and r["sfn"] != None and len(r["sfn"])>0:
                            self.sdspid = r["sdspid"]
                            self.redis.set( 'detector.path', '{ "directory": "%s", "filename": "%s"}' % (r["dsdir"], r["sfn"]));
                            try:
                                os.makedirs( r["dsdir"], 0770)
                            except OSError, (errno, strerror):
                                if errno != 17:
                                    qs = "select px.pusherror( 10004, 'Directory: %s, errno: %d, message: %s')" % (self.es(r["dsdir"]), int(errno), self.es(strerror))
                                    self.query( qs);
                                    print >> sys.stderr, time.asctime(), "Error creating directory: %s" % (strerror)

                            #
                            # set the kv pair for the directory and file name
                            #
                            self.query( "select px.kvset(px.getstation(), 'directory', '%s')" % r["dsdir"])
                            self.query( "select px.kvset(px.getstation(), 'filename', '%s')"  % r["sfn"])

                            #
                            # Delete the file first so that the hard link to the old file remains
                            # otherwise marccd will simply replace the contents of the old file and the hardlink
                            # will be to the new file, not the old one
                            #
                            try:
                                os.unlink( "%s/%s" % (r["dsdir"],r["sfn"]))
                            except OSError, (errno, strerror):
                                # Don't complain if the file does not exist
                                if errno != 2:
                                    print >> sys.stderr, time.asctime(), "Error deleting old file: %s" % (strerror)

                        else:
                            # the shot was not found: send the data to the bit bucket but go through the motions of collecting
                            r["dsdir"] = "/dev"
                            r["sfn"]   = "null"
                            self.queue.insert( 0, "readout,0,%s/%s" % (r["dsdir"],r["sfn"]))
                            qs = "select px.pusherror( 10005, '')"
                            self.query( qs);
                            print >> sys.stderr, time.asctime(), "Could not determine either the filename or the directory: data sent to /dev/null instead"


                        #
                        # Wait for the detector movement
                        # Regardless of who started the detector, we try to move it if it is stopped and not in the right place
                        #
                        if not self.waitdist(r["sdist"]):
                            print >> sys.stderr, "Failed to move detector into position."
                            self.query( "select px.dropDetectorOn()")
                            #
                            # Possibly this wait is too long.
                            # It should be long enough so that the diffractometer notices and aborts the exposure
                            #
                            print >>sys.stderr, " Wait for MD2 to realize what's happened"
                            for i in range(10):
                                print >> sys.stderr, ".",
                                sys.stderr.flush()
                                time.sleep( 0.2)
                            print >>sys.stderr, " Done"
                            self.query( "select px.setDetectorOn()")
                            return


                        if self.xsize!=None and self.xbin!=None and self.ysize!=None and self.ybin!=None:
                            #
                            # get the beam center information
                            #
                            qs2 = "select px.rt_get_bcx() as bcx, px.rt_get_bcy() as bcy, px.rt_get_dist() as dist"
                            qr2 = self.query( qs2)
                            r2 = qr2.dictresult()[0]
                            beam_x = self.xsize/2.0 - float( r2["bcx"])/(self.xpixsize * self.xbin)
                            beam_y = self.ysize/2.0 - float( r2["bcy"])/(self.ypixsize * self.ybin)
                            dist = r2["dist"]
                            print >> sys.stderr, time.asctime(), "beam_x: ", beam_x, "beam_y: ", beam_y, "distance: ", dist
                        else:
                            beam_x = 2048
                            beam_y = 2048
                            qs2 = "select px.rt_get_dist() as dist"
                            qr2 = self.query( qs2)
                            r2 = qr2.dictresult()[0]
                            dist = r2["dist"]
                            
                        self.redis.set( 'detector.beam_x', beam_x);
                        self.redis.set( 'detector.beam_y', beam_y);
        
                        self.queue.insert( 0, "readout,0,%s/%s" % (r["dsdir"],r["sfn"]))
                        hs = "header,detector_distance=%s,beam_x=%.3f,beam_y=%.3f,exposure_time=%s,start_phi=%s,file_comments=detector='%s' LS_CAT_Beamline='%s' kappa=%s omega=%s,rotation_axis=%s,rotation_range=%s,source_wavelength=%s\n" % (
                            dist, beam_x, beam_y,r["sexpt"],r["sstart"],self.detector_info, self.beamline, r["skappa"],r["sstart"], "phi",r["swidth"],r["thelambda"]
                            )
                        print >> sys.stderr, time.asctime(), hs
                        self.queue.insert( 0, hs)
                        
                        self.hlPush( r["dsdir"], r["sfn"], int(r["sexpt"])+1, self.skey)
                        
                        
                        cmd = "start"
                        self.collectingFlag = True
                        self.flushStatus    = True
                        print >> sys.stderr, time.asctime(), "found collect, changing to start, adding %s" % (self.queue[0])

                        
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
            print >> sys.stderr, time.asctime(), "queued %s" % (cmd)

    def nextCmd( self):
        rtn = None
        if len(self.queue) > 0:
            rtn = self.queue.pop(0)
            print >> sys.stderr, time.asctime(), "dequeued %s" % (rtn)
        return rtn

    def parseMar( self, ml):
        #
        # really dumb parser, probably nothing better will ever be needed
        # Note that "is_state" is already parsed and we may ignore it
        for msg in ml:
            if msg.find("is_size")==0:
                rsp = msg.split(",")
                self.xsize=int(rsp[1])
                self.ysize=int(rsp[2])
                self.updatedDetectorInfo = False
                print >>sys.stderr, time.asctime(), "SIZE: ", self.xsize,self.ysize

            if msg.find("is_bin")==0:
                rsp = msg.split(",")
                self.xbin=int(rsp[1])
                self.ybin=int(rsp[2])
                self.updatedDetectorInfo = False
                print >>sys.stderr, time.asctime(), "BIN: ",self.xbin,self.ybin

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
                    print >> sys.stderr, time.asctime(), "Your wish is my command.  Waiting patiently for your instructions."
                    self.query( "select px.lock_detector()")
                    self.haveLock = True

                # if aquiring has started, signal MD2 we are integrating
                if self.haveLock and ((self.status & aquiringMask) != 0):
                    print >> sys.stderr, time.asctime(), "Integrating..."
                    self.query( "select px.unlock_detector()")  # give up mar lock
                    self.haveLock      = False      # reset flags
                        
                    #
                    # this is the exposure, command blocks until md2 is done (or dead)
                    # assume the readout command is already queued up
                    print >> sys.stderr, time.asctime(), "Waiting for exposure to end..."
                    self.query( "select px.lock_diffractometer()")
                    print >> sys.stderr, time.asctime(), "Exposure ended"

                    # eventually we'll get the lock, give it up immediately
                    self.query( "select px.unlock_diffractometer()")
                    print >> sys.stderr, time.asctime(), "Diffractometer unlocked"

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
        """
        Grab needed parameters from the environment and set up polling file descriptors
        to communicate with marccd and the database.
        """

        #
        # Use redis to communicate state info to UI
        #
        self.redis = _R()


        #
        # we use the environment to get our filedescriptors from marccd
        #
        self.fdin = int(os.getenv( "IN_FD"))
        self.fdout = int(os.getenv("OUT_FD"))
            
        # Fix our umask
        os.umask( 0007);

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

        #
        # There are a small number of things that are oddly missing from the marccd protocol
        # that we need to know none the less.
        #
        self.detector_info = str(os.getenv("LS_CAT_DETECTOR_INFO", "unknown"))

        self.xpixsize = float(os.getenv("LS_CAT_CCD_PIXELSIZE", "73.242"))/1000.0          # the config file uses microns, we need millimeters
        self.ypixsize = self.xpixsize

        qs = "select coalesce(px.getstationname(),'21-ID') as sn, coalesce(px.getlustrepool(),'pffs.slow_pool') as lp"
        qr = self.query(qs)
        r = qr.dictresult()[0]
        self.beamline   = r["sn"]
        self.lustrePool = r["lp"]
        self.sdspid = "noShotInformation"


    def run( self):
        global EXIT_NOW

        runFlag = True

        self.flushStatus = True
        self.ltime = time.time()

        #
        # initialize detector
        self.query( "select px.marinit()")

        self.redis.set( 'detector.running', True);

        while not EXIT_NOW:

            if not self.updatedDetectorInfo and self.ybin != None and self.xsize != None and self.ysize != None:
                #
                # Assume that with xsize, ysize, and ybin defined that we have everything we need
                # to update the detectorinfo table.
                #
                # The detector information and pixel size are read from the environment at start up.  The other numbers
                # await the detector's response to px.marinit().
                #
                qs = "select px.setdetectorinfo( '%s', %f, %f, %d, %d, %d)" % (self.detector_info, self.xpixsize, self.ypixsize, self.xsize, self.ysize, self.ybin)
                self.query( qs)
                self.updatedDetectorInfo = True

                self.redis.set( "detector.info", '{ "info": "%s",  "xpixsize": %f, "ypixsize": %f, "xsize": %d, "ysize": %d, "bin": %d}' % (self.detector_info,self.xpixsize, self.ypixsize, self.xsize, self.ysize, self.ybin));
                
            #
            # check to see if any socket needs service
            try:
                for (fd,event) in self.p.poll( 500):
                    #
                    # call socket's service routine for the given event
                    self.fan[fd](event)
                
            except select.error, (errno, strerror):
                if errno == 4:
                    print >>sys.stderr, "pxMarServer.py poll: ", strerror
                else:
                    raise


            if EXIT_NOW:
                break;

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


        print >> sys.stderr, time.asctime(), "pxMarServer.py: cleaning up"
        self.query( "select px.dropDetectorOn()")
        self.db.close()
        print >> sys.stderr, time.asctime(), "pxMarServer.py: Exiting now."
        self.redis.set( 'detector.running', False);

#
# Default usage
#
if __name__ == '__main__':
    signal.signal( signal.SIGTERM, pxMarSignalHandler)
    signal.signal( signal.SIGABRT, pxMarSignalHandler)
    signal.signal( signal.SIGHUP, pxMarSignalHandler)
    signal.signal( signal.SIGINT, pxMarSignalHandler)
    signal.signal( signal.SIGPIPE, pxMarSignalHandler)
    z = PxMarServer()
    while not EXIT_NOW:
        try:
            z.run()
        except PxMarError:
            pass
