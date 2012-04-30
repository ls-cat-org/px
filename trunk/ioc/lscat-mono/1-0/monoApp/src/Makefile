TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================
#USR_CFLAGS += -O0
#USR_CXXFLAGS += -O0

#=============================
# build an ioc application

PROD_IOC = mono

DBD += mono.dbd
# mono.dbd will be made up from these files:
mono_DBD += base.dbd
#include definitions for any other support applications needed
#mono_DBD += xxx.dbd
mono_DBD += add_modules.dbd

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
mono_SRCS += mono_registerRecordDeviceDriver.cpp
mono_SRCS_DEFAULT += monoMain.cpp
mono_SRCS_vxWorks += -nil-

#The following adds support from base/src/vxWorks
mono_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

#add a definition for each support application used by this application
#mono_LIBS += xxx
ifdef ASYN
    mono_LIBS += asyn
endif

ifdef AUTOSAVE
    mono_LIBS += autosave
endif


#NOTES:
#      1)It is not possible to build MySNC both as a component of mono
#        and standalone. You must choose only one.
#      2)To build MySNC SNCSEQ must be defined in <top>/configure/RELEASE

ifneq ($(SNCSEQ),)
#The following builds MySNC as a component of mono
#mono_SRCS += MySNC.stt
#mono_LIBS += seq pv
mono_SRCS += change_en.st
mono_SRCS += fdbk_server.st
mono_SRCS += vfminout.st
mono_LIBS += seq pv
endif

mono_LIBS += $(EPICS_BASE_IOC_LIBS)

#The following builds MySNC as a standalone application
#PROD_HOST += MySNC
#MySNC_SNCFLAGS += +m
#MySNC_SRCS += MySNC.stt
#MySNC_LIBS += seq pv
#MySNC_LIBS += $(EPICS_BASE_HOST_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE
