#! /usr/bin/python

import os, sys, select, signal, time

class testCcd:
    lastState = None
    state     = 0
    argList   = []
    fd_out    = None
    fd_in     = None
    logfile   = None

    def sendout( self, s):
        os.write( self.fd_out, s+"\n")

    def getSize( self):
        self.sendout( "is_size,4096,4096")

    def getSizeBkg( self):
        self.sendout( "is_size_bkg,4096,4096")

    def getBin( self):
        self.sendout( "is_bin,1,1")

    def getFrameshift( self):
        self.sendout( "is_frameshift,0")

    def getMode( self):
        self.sendout( "is_mode,1")

    def readout( self):
        # readMask     = 0x000300
        self.state = self.state & ~0x000020
        self.state = self.state | 0x000200
        self.getState()
        time.sleep(1.2)
        self.state = self.state & ~0x000200
        self.getState()

    def start( self):
        # aquireMask   = 0x000030
        # aquiringMask = 0x000020
        self.state = self.state | 0x000020
        self.getState()

    def dezinger( self):
        # zingMask     = 0x300000
        self.state = self.state | 0x200000
        self.getState()
        self.state = self.state & ~0x200000
        self.getState()


    def correct( self):
        pass

    def header( self):
        self.logfile.write( "\n")
        self.logfile.flush()
        for h in self.argList:
            self.logfile.write( h+"\n")
            self.logfile.flush()

    def getState( self):
        if self.lastState != self.state:
            self.logfile.write( "is_state,%d\n" % (self.state))
            self.logfile.flush()
        self.lastState = self.state
        self.sendout( "is_state,%d" % (self.state))

    def endAutomation( self):
        os.kill( theChild, signal.SIGINT)
        time.sleep(1)
        os.exit(0)

    def setThumbnail1( self):
        pass

    def setThumbnail2( self):
        pass




    def __init__( self):
        self.initArray = [
            self.getState,
            self.getMode,
            self.getSize,
            self.getBin,
            self.getFrameshift
            ]


        self.commands = {
            "get_size":        self.getSize,
            "get_size_bkg":    self.getSizeBkg,
            "get_bin":         self.getBin,
            "get_frameshift":  self.getFrameshift,
            "get_mode":        self.getMode,
            "readout":         self.readout,
            "start":           self.start,
            "dezinger":        self.dezinger,
            "correct":         self.correct,
            "header":          self.header,
            "get_state":       self.getState,
            "end_automation":  self.endAutomation,
            "set_thumbnail1":  self.setThumbnail1,
            "set_thumbnail2":  self.setThumbnail2
            }

        self.logfile = open( "testCcd.log", "w")

    def run( self):

        (self.fd_in,       self.fd_out_child) = os.pipe()
        (self.fd_in_child, self.fd_out)       = os.pipe()

        os.putenv( "OUT_FD", "%d" %(self.fd_out_child))
        os.putenv( "IN_FD",  "%d" %(self.fd_in_child))


        theChild=os.fork()
        if theChild == 0:
            os.execl( "pxMarServer.py", "pxMarServer.py")
            os._exit(1)

        os.close( self.fd_out_child)
        os.close( self.fd_in_child)


        for z in self.initArray:
            z()


        p = select.poll()

        p.register( self.fd_out, select.POLLOUT | select.POLLERR | select.POLLHUP | select.POLLNVAL)
        p.register( self.fd_in,  select.POLLIN  | select.POLLPRI | select.POLLERR | select.POLLHUP | select.POLLNVAL)


        leftOver=""
        while True:
            for (fd,event) in p.poll():
                if fd == self.fd_out:
                    self.getState()
                if fd == self.fd_in:

                    msg = leftOver + os.read( self.fd_in, 8192)
                    self.logfile.write( "msg: %s\n" % (msg))
                    self.logfile.flush()
                    ml = msg.split('\n')
                    if len(msg) > 0 and msg[-1] != '\n':
                        leftOver = ml.pop()

                    for m in ml:
                        if len( m):
                            self.logfile.write( "marccd received: %s\n" % (m))
                            self.logfile.flush()
                            if m.find(",") > 0:
                                (cmd,args) = m.split(",",1)
                                self.argList = args.split(",")
                                self.logfile.write( "argList Length: %s\n" % (len(self.argList)))
                                self.logfile.flush()
                            else:
                                cmd = m;
                                self.argList = None
                                
                            self.commands[cmd]()
                    
#
# Default usage
#
if __name__ == '__main__':
    z = testCcd()
    z.run()
