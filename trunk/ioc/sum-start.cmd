epicsEnvSet("ARCH","linux-x86_64")
epicsEnvSet("IOC","mytestioc")
dbLoadRecords("sumdb","INST=hereiam")
iocInit
