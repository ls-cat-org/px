### save_restore setup
# status-PV prefix
  save_restoreSet_status_prefix("21linux:")
### Debug-output level
 save_restoreSet_Debug(0)

### Ok to save/restore save sets with missing values (no CA connection to PV)?
  save_restoreSet_IncompleteSetsOk(1)
### Save dated backup files?
  save_restoreSet_DatedBackupFiles(0)

### Number of sequenced backup files to write
  save_restoreSet_NumSeqFiles(3)
### Time interval between sequenced backups
  save_restoreSet_SeqPeriodInSeconds(15)

### specify where save files should be
  set_savefile_path(${TOP}/iocBoot/${IOC}/, "autosave")

### specify what save files should be restored.  Note these files must be
### in the directory specified in set_savefile_path(), or, if that function
### has not been called, from the directory current when iocInit is invoked
  set_pass0_restoreFile("auto_positions.sav")
  set_pass0_restoreFile("auto_settings.sav")
  set_pass1_restoreFile("auto_settings.sav")

### specify directories in which to to search for included request files
###  set_requestfile_path(${TOP}/iocBoot/${IOC}/, "")
###  set_requestfile_path(${TOP}/iocBoot/${IOC}/, "autosave")
  set_requestfile_path(${TOP}/iocBoot/${IOC}/, "dbSave")

  dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=21linux:")
