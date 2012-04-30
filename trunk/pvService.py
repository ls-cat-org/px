#! /usr/bin/python

import EpicsCA
import pg
import mmap
import select
import sys
import traceback
import os
import time
import signal

class PVServiceError( Exception):
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
                raise PVServiceError( 'Database Connection Lost')

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


class PvService:
    mmfn = "/mnt/pvs/pvService"


    def intHandler( self, signum, frame):
        print >> sys.stderr, "Caught signal, exiting"
        self.okToRun = False

    def __init__( self):
        self.mms  = None
        self.running = False
        self.q = None
        self.pid = None
        self.pvList = {}
        self.putOnlyList = {}
        self.okToRun = True

        print >> sys.stderr, "Initialization...\n"

        self.q = _Q()

        #
        # Simple pid mechanism: only one process is allowed to run.
        # Older processes are told to quit.
        #
        qr = self.q.query( "select epics.iniCAMonitor() as pid")
        self.pid = int(qr.dictresult()[0]["pid"])

        #
        # get names and the index into the shared file
        #
        qr = self.q.query( "select index, name from epics.getpvnames( %d) order by index" % (self.pid))
        maxIndex = 0
        for r in qr.dictresult():
            print r["index"], r["name"]
            self.pvList[r["name"]] = { "index" : int(r["index"]), "pv" : EpicsCA.PV( r["name"])}
            if int( r["index"]) > maxIndex:
                maxIndex = int( r["index"])

        #
        # Initialize the file
        #
        tmpF = open( self.mmfn, "w")
        for i in range( maxIndex+1):
            for j in range( 256):
                tmpF.write( "\0")
        tmpF.close()
        #
        # We have to be sure that postgresql can read this.
        # Probably these permissions are not strict enough
        #
        os.chmod( self.mmfn, 0666)

        #
        # now we'll open the file with the correct mode
        # and use the mmap module to treat the file like a string
        #
        self.mmf = open( self.mmfn, "a+")
        self.mms = mmap.mmap( self.mmf.fileno(), (maxIndex+1)*256)
        
        #
        # Initialize the values
        #
        for p in self.pvList.keys():
            try:
                tmp = str(self.pvList[p]["pv"].get())
            except:
                print >> sys.stderr, "Failed to get %s" % (self.pvList[p]["pv"].pvname)
                tmp = str("505.505")

            if tmp == None or len(tmp) == 0:
                print >> sys.stderr, "Failed to get %s" % (self.pvList[p]["pv"].pvname)
                tmp = str("505.505")  # SOS in leet

            #
            # Write the value onto the disk
            #
            i = 256 * self.pvList[p]["index"]
            self.mms.seek( i)
            self.mms.write( tmp)
            self.mms.write( "\0")
            
        self.mms.flush()

        #
        # Setup callback to monitor the variables
        #
        for p in self.pvList.keys():
            self.pvList[p]["pv"].add_callback( callback=self.updateCB)

    def updateCB( self, pv=None, **kw):
        if not self.running:
            return
        indx = self.pvList[pv.pvname]["index"]
        i = 256*indx
        tmp  = str( pv.get())
        if tmp == None or len(tmp) == 0:
            tmp = str("505.505")   # SOS in leet

        qs = "select pg_advisory_lock( 14852, %d) as tal" % (indx)
        self.q.query( qs)
        self.mms.seek( i)
        self.mms.write( tmp)
        self.mms.write( "\0")
        self.mms.flush()
        self.q.query( "select pg_advisory_unlock( 14852, %d)" % (indx))

    def run( self):
        print >> sys.stderr, "Running\n"

        # Set up to capture ^C and exit "gracefully"
        #
        signal.signal( signal.SIGINT, self.intHandler)

        self.running = True

        tryAgain = False
        while self.okToRun:
            EpicsCA.pend_event( t=0.05)
            if tryAgain or self.q.getnotify() != None:
                qr = self.q.query( "select cappv, capval from epics.caputpop()")
                foundOne = False
                for r in qr.dictresult():
                    foundOne = True
                    nam = r["cappv"]
                    val = r["capval"]
                    print "moving ",nam," to ",val
                    if self.pvList.has_key( nam):
                        self.pvList[nam]["pv"].put( val)
                    else:
                        if not self.putOnlyList.has_key( nam):
                            self.putOnlyList["nam"] = EpicsCA.PV( nam)
                        self.putOnlyList["nam"].put( val)
                    #
                    # pause to keep commands from bumping into one another
                    #
                tryAgain = not foundOne
        #
        # Remove callbacks
        #
        for p in self.pvList.keys():
            self.pvList[p]["pv"].clear_callbacks()

if __name__ == "__main__":
    z = PvService()
    z.run()

