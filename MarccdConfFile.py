#! /usr/bin/python
#
# MarccdConfFile.py
#
# Version 11030802
#

# This file contains the class MarccdConfFile that parses
# marccd.conf files.
#
# As a module this class provides access to the values of the
# parameters set as a tuple (files,vars).  See "parse" documentation.
#
# As a standalone program:
#
# Argument         Returns
# None             sorted version of the marccd.conf (includes replaced by included parameters)
#
# detector_info    manufacturer, model name, and serial number of the detector
#
# files            list of files used, symlinks resolved into real paths
#
# some_parameter   that parameter value
#

#
# All comments in the original marccd.conf files are removed.
#

#
# (C) 2011 by Keith Brister, Northwestern University
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#


import os.path          # grab directory names to support relative paths in include statements
import re               # use re to parse the line so we can search for whitespace
import sys              # stderr and argv
import shlex            # parse the line respecting quotes

class MarccdConfFile:
    """
    Parse the marccd config file with includes:
    MarccdConfFile()    => start at /home/marccd/configuration/marccd.conf
    MarccdConfFile(fn)  => start at named file
    """

    def __init__( self, fn="/home/marccd/configuration/marccd.conf"):
        self._fn = fn                           # our file name

        self._dir = os.path.dirname( fn)        # we need this to process include statements

        self._vars = {}                         # dictionary of values set in file
        self._files = []                        # list of files opened: files that do not exists are ignored and not included in this list

    def parse( self):
        """
        Return a tuple (files,vars) where
          files is a list of files parsed and
          vars  is a dictionary of key-value pairs

          multivalued items in vars are returned as a list, single valued items are returned as a string.
        """

        if os.path.exists( self._fn):

            if os.path.islink( self._fn):
                tmp = os.readlink( self._fn)
                if os.path.isabs( tmp):
                    realfilename = tmp
                else:
                    realfilename = os.path.join(os.path.dirname(self._fn), tmp)
            else:
                realfilename = self._fn
                    
            self._files.append( realfilename)
            
            f = open( realfilename, "r")

            running = True
            while( running):
                sraw = f.readline()

                if sraw == "":
                    #
                    # end of file
                    #
                    running = False
                    break

                s = sraw.strip()        # kill garbage fore and aft
                
                if len(s)==0 or s[0] == "#":
                    #
                    # this is a comment line, ignore
                    #
                    continue

                #
                # split the line nicely respecting quotes
                #
                sa = shlex.split( s)

                #
                # Remake the array ignoring comments
                #
                sa2 = []
                for li in sa:
                    if li[0] == "#":
                        break
                    sa2.append(li)

                if len(sa2) == 0:
                    #
                    # Nothing left, odd.
                    #
                    continue
                #
                # process include first
                #
                if sa2[0].lower() == "include":
                    if len( sa2) < 2:
                        #
                        # need a file name
                        #
                        continue

                    newPath = "%s/%s" % (self._dir, sa[1])

                    child = MarccdConfFile( newPath)
                    rslt  = child.parse()
                    self._vars.update(rslt[1])
                    self._files += rslt[0]

                else:
                    if len(sa2) == 1:
                        #
                        # empty string for entries with no values
                        #
                        self._vars[sa2[0]] = ""
                    elif len(sa2) == 2:
                        #
                        # string entry for single value
                        #
                        self._vars[sa2[0]] = sa2[1]
                    else:
                        #
                        # List entry for items that look like arrays
                        #
                        self._vars[sa2[0]] = []
                        for li in sa2[1:]:
                            self._vars[sa2[0]].append( li)
                            


            f.close()

        return (self._files, self._vars)

    def __str__( self):
        """
        Produce sorted version of config file without includes.
        """
        rtn = ""
        ks = self._vars.keys()
        ks.sort()
        for k in ks:
            rtn += k
            v = self._vars[k]
            if issubclass( list, type(v)):
                if len(v) > 1:
                    for i in range( len(v)):
                        rtn += " " + str(v[i])
            else:
                rtn += " %s" % (str(self._vars[k]))

            rtn += "\n"

        return rtn




if __name__ == "__main__":
    marccdConfFile = MarccdConfFile()
    (files,vars) = marccdConfFile.parse()

    if len(sys.argv) == 1:
        #
        # Print out the parsed and sorted config file
        # suitable for using as a single config file (no includes)
        #
        print marccdConfFile

    elif sys.argv[1] == "-h" or sys.argv[1] == "--help":
        print ""
        print "Usage:"
        print "%s                   => full config parameters, sorted." % (sys.argv[0])
        print "%s files             => list of files used in marccd.conf" % (sys.argv[0])
        print "%s detector_info     => detector make, model, and serial number" % (sys.argv[0])
        print "%s <parameter name>  => value of the requested parameter" % (sys.argv[0])
        print ""

    elif sys.argv[1] == "detector_info":
        #
        # Print out the detector information usable as a comment in an image file
        #
        if vars.has_key("detector_serial_number"):
            detector_serial_number = "%03d" % (int(vars["detector_serial_number"]))
        else:
            print >>sys.stderr, "Warning: detector serial number not found."
            detector_serial_number = "unknown"

        if vars.has_key("detector_model_name"):
            detector_model_name = vars["detector_model_name"]
        else:
            print >>sys.stderr, "Warning: detector model name not found."
            detector_model_name = "unknown detector model"

        print "Rayonix %s s/n %s" % ( detector_model_name, detector_serial_number)

    elif sys.argv[1] == "files":
        for i in range(len(files)):
            print files[i]

    else:
        #
        # print out the requested parameter, if any
        #
        k = sys.argv[1]
        if not vars.has_key( k):
            print >>sys.stderr, "Error: parameter %s not found" % (k)
            sys.exit(1)

        v = vars[k]
        rtn = "%s" % (k)

        if issubclass( list, type(v)):
            for i in range( len(v)):
                rtn += " %s" % (str(v[i]))
        else:
            rtn += " %s" % (str( v))

        print rtn
        
