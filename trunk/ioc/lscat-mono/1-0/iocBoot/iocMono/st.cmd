#!../../bin/linux-x86/mono

## You may have to change mono to something else
## everywhere it appears in this file

< envPaths

###### putenv ("EPICS_CA_ADDR_LIST=10.1.17.4 10.1.17.2 10.1.17.17")
####   epicsEnvSet(EPICS_CA_ADDR_LIST,"10.1.17.1 10.1.17.2 10.1.17.17")

  cd ${TOP}

### Register all support components
  dbLoadDatabase("dbd/mono.dbd",0,0)
  mono_registerRecordDeviceDriver(pdbbase)

  cd ${TOP}/iocBoot/${IOC}

### Load record instances
 dbLoadRecords("../../monoApp/Db/change_en.db","P=21linux:")
 dbLoadRecords("../../monoApp/Db/fdbk_server.db","P=21linux:")
 dbLoadRecords("../../monoApp/Db/vfminout.db","P=21linux:")

### save_restore setup
  < save_restore.cmd

  iocInit()
  epicsThreadSleep(1)

###  create_monitor_set("auto_positions.req", 5, "P=21linux:")
  create_monitor_set("auto_settings.req", 15, "P=21linux:")


### Start sequence program
seq change_en, "coioc=21linux, scnm=21:D1:scan3, detnm=21:D1:scaler1"
seq fdbk_server, "coioc=21linux, calcrec=21:D1:2:userCalc, detnm=21:D1:scaler1"
seq vfminout, "coioc=21linux"

############################################################
