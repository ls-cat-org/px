# 1 "../change_en.st"
# 1 "<built-in>"
# 1 "<command line>"
# 1 "../change_en.st"
program change_en("coioc=21linux, scnm=21:D1:scan3, detnm=21:D1:scaler1")

option +r;

%%#include <string.h>
%%#include <math.h>
%%#include <tsDefs.h>
# 1 "../change_en.h" 1
# 27 "../change_en.h"
%%TS_STAMP tmc;

char time_str[80];

int status;
int msgI;
int i;
int j;
int line;
double deltaEn;
double finishEn;
double maxTheta;
double maxCnts;
double cnts;
double step;
double tmpdb;

double startEn;
double startEnID;
double startHrmID;
double startChi;
double startPi;
double startTh;
double startLnHFM;
double startLnVFM;

int startBtn; assign startBtn to "{coioc}:mono:Start"; monitor startBtn; evflag start_f; sync startBtn start_f;
int abortBtn; assign abortBtn to "{coioc}:mono:Abort"; monitor abortBtn; evflag abort_f; sync abortBtn abort_f;
int cleanBtn; assign cleanBtn to "{coioc}:mono:Clean"; monitor cleanBtn; evflag clean_f; sync cleanBtn clean_f;
int undoBtn; assign undoBtn to "{coioc}:mono:Undo"; monitor undoBtn; evflag undo_f; sync undoBtn undo_f;


int abortCentr; assign abortCentr to "{coioc}:mono:AbortCentr"; monitor abortCentr;
int centrWrkng; assign centrWrkng to "{coioc}:mono:CentrWrkng"; monitor centrWrkng;
int tbMiSwBtn; assign tbMiSwBtn to "{coioc}:mono:TBMIsw"; monitor tbMiSwBtn;
int imgHCentr; assign imgHCentr to "{coioc}:mono:ImgHCentr"; monitor imgHCentr;
int imgVCentr; assign imgVCentr to "{coioc}:mono:ImgVCentr"; monitor imgVCentr;


int chEnWrkng; assign chEnWrkng to "{coioc}:mono:ChEnWrkng"; monitor chEnWrkng;
int thWrkng; assign thWrkng to "{coioc}:mono:ThWrkng"; monitor thWrkng;
int idEnaBtn; assign idEnaBtn to "{coioc}:mono:IDena"; monitor idEnaBtn;
int chiEnaBtn; assign chiEnaBtn to "{coioc}:mono:CHIena"; monitor chiEnaBtn;
int vfmEnaBtn; assign vfmEnaBtn to "{coioc}:mono:VFMena"; monitor vfmEnaBtn;
int hfmEnaBtn; assign hfmEnaBtn to "{coioc}:mono:HFMena"; monitor hfmEnaBtn;
int piEnaBtn; assign piEnaBtn to "{coioc}:mono:PIena"; monitor piEnaBtn;
int thEnaBtn; assign thEnaBtn to "{coioc}:mono:THena"; monitor thEnaBtn;

double newEn; assign newEn to "{coioc}:mono:RqsEn"; monitor newEn;
double hrmSwEn; assign hrmSwEn to "{coioc}:mono:HrmSwEn"; monitor hrmSwEn;
double idOff1; assign idOff1 to "{coioc}:mono:IDoff1"; monitor idOff1;
double idOff2; assign idOff2 to "{coioc}:mono:IDoff2"; monitor idOff2;
double chiSca; assign chiSca to "{coioc}:mono:ChiSca"; monitor chiSca;
double chiOff; assign chiOff to "{coioc}:mono:ChiOff"; monitor chiOff;
double vfmPd; assign vfmPd to "{coioc}:mono:VFMPd"; monitor vfmPd;
double vfmGl; assign vfmGl to "{coioc}:mono:VFMGl"; monitor vfmGl;
double vfmPt; assign vfmPt to "{coioc}:mono:VFMPt"; monitor vfmPt;
double hfmPd; assign hfmPd to "{coioc}:mono:HFMPd"; monitor hfmPd;
double hfmGl; assign hfmGl to "{coioc}:mono:HFMGl"; monitor hfmGl;
double hfmPt; assign hfmPt to "{coioc}:mono:HFMPt"; monitor hfmPt;
double scWdth; assign scWdth to "{coioc}:mono:ScWdth"; monitor scWdth;
double scStep; assign scStep to "{coioc}:mono:ScStep"; monitor scStep;
double thStep; assign thStep to "{coioc}:mono:ThStep"; monitor thStep;

double detCnts; assign detCnts to "{detnm}_calc5.VAL"; monitor detCnts;
int detMode; assign detMode to "{detnm}.CONT"; monitor detMode;

string piScanNm; assign piScanNm to "{scnm}.NAME"; monitor piScanNm;
int piScanBusy; assign piScanBusy to "{scnm}.BUSY"; monitor piScanBusy;
int piScanStart; assign piScanStart to "{scnm}.EXSC";
int piScanAbort; assign piScanAbort to "21:D1:AbortScans.PROC";
int piScanCmnd; assign piScanCmnd to "{scnm}.CMND";
int piScanLinr; assign piScanLinr to "{scnm}.P1SM";
int piScanAbslt; assign piScanAbslt to "{scnm}.P1AR";
int piScanPeakP; assign piScanPeakP to "{scnm}.PASM";
double piScanCntr; assign piScanCntr to "{scnm}.P1CP";
double piScanWdth; assign piScanWdth to "{scnm}.P1WD";
double piScanStep; assign piScanStep to "{scnm}.P1SI";
string piScanDet; assign piScanDet to "{scnm}.D01PV";
float piScanPosStl; assign piScanPosStl to "{scnm}.PDLY";
float piScanDetStl; assign piScanDetStl to "{scnm}.DDLY";
float piScanUpdt; assign piScanUpdt to "{scnm}.ATIME";
string piScanPosRd; assign piScanPosRd to "{scnm}.R1PV";
string piScanPosDr; assign piScanPosDr to "{scnm}.P1PV";
string piScanDtTrg; assign piScanDtTrg to "{scnm}.T1PV";
string piScanAfter; assign piScanAfter to "{scnm}.ASPV";




double actEn; assign actEn to "21:C1:MO:E:ActPos"; monitor actEn;
double rqsPosEn; assign rqsPosEn to "21:C1:MO:E:RqsPos"; monitor rqsPosEn;
long EnAbort; assign EnAbort to "21:C1:MO:En:Abort"; monitor EnAbort;
long EnKill; assign EnKill to "21:C1:MO:En:Kill"; monitor EnKill;

long EnRunPrg; assign EnRunPrg to "21:C1:MO:En:RunPrg"; monitor EnRunPrg;


double actEnID; assign actEnID to "ID21us:Energy.VAL"; monitor actEnID;
double rqsEnID; assign rqsEnID to "ID21us:EnergySet.VAL"; monitor rqsEnID;
double rqsHrmID; assign rqsHrmID to "ID21us:HarmonicValue"; monitor rqsHrmID;
int IDStart; assign IDStart to "ID21us:Start.VAL"; monitor IDStart;
int IDStop; assign IDStop to "ID21us:Stop.VAL"; monitor IDStop;
int IDStatus; assign IDStatus to "ID21us:Busy.VAL"; monitor IDStatus;


double actChi; assign actChi to "21:C1:MO:R2:ActPos"; monitor actChi;
double rqsPosChi; assign rqsPosChi to "21:C1:MO:R2:RqsPos"; monitor rqsPosChi;
long ChiAbort; assign ChiAbort to "21:C1:MO:Tn:Abort"; monitor ChiAbort;
long ChiKill; assign ChiKill to "21:C1:MO:Tn:Kill"; monitor ChiKill;

long ChiRunPrg; assign ChiRunPrg to "21:C1:MO:Tn:RunPrg"; monitor ChiRunPrg;


double actPitch; assign actPitch to "21:C1:MO:P2:ActPos"; monitor actPitch;
double rqsPitch; assign rqsPitch to "21:C1:MO:P2:RqsPos"; monitor rqsPitch;



double curTheta; assign curTheta to "c3ioc:rmm01:ana01:ao01.VAL"; monitor curTheta;


double actLnVFM; assign actLnVFM to "21:D1:KB:VL:ActPos"; monitor actLnVFM;
double rqsLnVFM; assign rqsLnVFM to "21:D1:KB:VL:RqsPos"; monitor rqsLnVFM;
long VFMAbort; assign VFMAbort to "21:D1:KB:Vx:Abort"; monitor VFMAbort;
long VFMKill; assign VFMKill to "21:D1:KB:Vx:Kill"; monitor VFMKill;
long VFMRunPrg; assign VFMRunPrg to "21:D1:KB:Vx:RunPrg"; monitor VFMRunPrg;

double actLnHFM; assign actLnHFM to "21:D1:KB:HL:ActPos"; monitor actLnHFM;
double rqsLnHFM; assign rqsLnHFM to "21:D1:KB:HL:RqsPos"; monitor rqsLnHFM;
long HFMAbort; assign HFMAbort to "21:D1:KB:Hy:Abort"; monitor HFMAbort;
long HFMKill; assign HFMKill to "21:D1:KB:Hy:Kill"; monitor HFMKill;
long HFMRunPrg; assign HFMRunPrg to "21:D1:KB:Hy:RunPrg"; monitor HFMRunPrg;

string msgQ;
string msg[10]; assign msg[0] to "{coioc}:mono:Msg9";
        assign msg[1] to "{coioc}:mono:Msg8";
                      assign msg[2] to "{coioc}:mono:Msg7";
                      assign msg[3] to "{coioc}:mono:Msg6";
                      assign msg[4] to "{coioc}:mono:Msg5";
                      assign msg[5] to "{coioc}:mono:Msg4";
                      assign msg[6] to "{coioc}:mono:Msg3";
                      assign msg[7] to "{coioc}:mono:Msg2";
                      assign msg[8] to "{coioc}:mono:Msg1";
                      assign msg[9] to "{coioc}:mono:Msg0";
evflag msg_f;
evflag moveen_f;
evflag movechi_f;
evflag moveid_f;
evflag movevfm_f;
evflag movehfm_f;
evflag optpi_f;
evflag optth_f;
evflag finished;
# 9 "../change_en.st" 2

ss set1 {
    state init {
   when() {

       newEn = actEn; pvPut(newEn); epicsThreadSleep(0.001);
              printf("Init state: actEn=%f, newEn=%f.\n", actEn,rqsPosEn);
              tmpdb = 0.0;
       thWrkng = 0; pvPut(thWrkng); epicsThreadSleep(0.001);
       chEnWrkng = 0; pvPut(chEnWrkng); epicsThreadSleep(0.001);
# 37 "../change_en.st"
              strcpy(piScanPosRd,"21:C1:MO:P2:ActPos");
              strcpy(piScanPosDr,"21:C1:MO:P2:RqsPos");
              strcpy(piScanDtTrg,"21:D1:scaler1.CNT");
              strcpy(piScanDet,"21:D1:scaler1_calc5.VAL");
              strcpy(piScanAfter,"21:C1:MO:Tn:Kill");



       efClear (clean_f); epicsThreadSleep(0.001); msgI = 9;
         startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
       efClear(start_f); epicsThreadSleep(0.001);
         abortBtn = 0; pvPut(abortBtn); epicsThreadSleep(0.001);
       thWrkng = 0; pvPut(thWrkng); epicsThreadSleep(0.001);
       efClear(abort_f); epicsThreadSleep(0.001);
       sprintf(msgQ, "Ready."); efSet(msg_f); epicsThreadSleep(0.001);
          } state mntr
    }

    state mntr {
 when (efTestAndClear(msg_f)) {
   printf("state mntr: entering msg.\n");
%% tsLocalTime(&tmc);
%% tsStampToText (&tmc, TS_TEXT_MMDDYY, pVar->time_str);
   if(strstr(msg[msgI],msgQ) == NULL) {
     if (msgI > 0) {
          msgI -= 1;
     } else {
             for (i=9; i>0; i--) {
           strcpy (msg[i], msg[i-1]); pvPut(msg[i]); epicsThreadSleep(0.001);
             }
     }
   }
   sprintf (msg[msgI], "%8.8s %s", &time_str[9], msgQ); pvPut(msg[msgI]); epicsThreadSleep(0.001);
   efClear(msg_f); epicsThreadSleep(0.001);
          printf("state mntr: leaving msg.\n");
        } state mntr
 when (efTest(abort_f) && abortBtn == 1) {
         printf("state mntr: entering abort.\n");
                EnAbort = 1; pvPut(EnAbort); epicsThreadSleep(0.001);
                if(idEnaBtn == 1) { IDStop = 1; pvPut(IDStop); epicsThreadSleep(0.001);}
                if(chiEnaBtn == 1) { ChiAbort = 1; pvPut(ChiAbort); epicsThreadSleep(0.001);}
  if(vfmEnaBtn == 1) { VFMAbort = 1; pvPut(VFMAbort); epicsThreadSleep(0.001);}
  if(hfmEnaBtn == 1) { HFMAbort = 1; pvPut(HFMAbort); epicsThreadSleep(0.001);}
  if(piEnaBtn == 1) {
         piScanAbort = 1; pvPut(piScanAbort); epicsThreadSleep(0.1);
         piScanAbort = 1; pvPut(piScanAbort); epicsThreadSleep(0.1);

  }
                epicsThreadSleep(0.5);
                EnKill = 1; pvPut(EnKill);
  if(chiEnaBtn == 1) { ChiKill = 1; pvPut(ChiKill); epicsThreadSleep(0.001);}
  if(vfmEnaBtn == 1) { VFMKill = 1; pvPut(VFMKill); epicsThreadSleep(0.001);}
  if(hfmEnaBtn == 1) { HFMKill = 1; pvPut(HFMKill); epicsThreadSleep(0.001);}
         detMode = 1; pvPut(detMode); epicsThreadSleep(0.001);
         sprintf(msgQ, "**Job aborted. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
         printf("state mntr: **Job is aborted. Ready.\n");
  efClear(moveen_f); epicsThreadSleep(0.001); efClear(moveid_f); epicsThreadSleep(0.001);
  efClear(movechi_f); epicsThreadSleep(0.001);
                efClear(movevfm_f); epicsThreadSleep(0.001); efClear(movehfm_f); epicsThreadSleep(0.001);
  efClear(optpi_f); epicsThreadSleep(0.001); efClear(optth_f); epicsThreadSleep(0.001);
  startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001); efClear(start_f); epicsThreadSleep(0.001);
         abortBtn = 0; pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
         thWrkng = 0; pvPut(thWrkng); epicsThreadSleep(0.001);
                chEnWrkng = 0; pvPut(chEnWrkng); epicsThreadSleep(0.001);
                printf("state mntr: leaving abort.\n");
 } state mntr
 when(efTest(start_f) && startBtn == 1 && EnRunPrg == 1) {
       sprintf(msgQ, "**Energy assembly moving"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state mntr: Energy assembly is still moving. Quit.\n");
       startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
       efClear(start_f); epicsThreadSleep(0.001);
 } state mntr
 when(efTest(start_f) && startBtn == 1 && idEnaBtn == 1 && IDStatus == 1) {
       sprintf(msgQ, "**Undulator is moving."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state mntr: Undulator is still moving. Quit.\n");
       startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
       efClear(start_f); epicsThreadSleep(0.001);
 } state mntr
 when(efTest(start_f) && startBtn == 1 && chiEnaBtn == 1 && ChiRunPrg == 1) {
       sprintf(msgQ, "**CHI or Pitch moving"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state mntr: CHI or Pitch axis is still moving. Quit.\n");
       startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
       efClear(start_f); epicsThreadSleep(0.001);
 } state mntr
 when(efTest(start_f) && startBtn == 1 && vfmEnaBtn == 1 && VFMRunPrg == 1) {
       sprintf(msgQ, "**VFMirror still moving."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state mntr: VFMirror still moving. Quit.\n");
       startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
       efClear(start_f); epicsThreadSleep(0.001);
 } state mntr
 when(efTest(start_f) && startBtn == 1 && hfmEnaBtn == 1 && HFMRunPrg == 1) {
       sprintf(msgQ, "**HFMirror still moving."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state mntr: HFMirror still moving. Quit.\n");
       startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
       efClear(start_f); epicsThreadSleep(0.001);
 } state mntr
 when(efTest(start_f) && startBtn == 1 && piEnaBtn == 1 && piScanBusy == 1 ) {
       sprintf(msgQ, "**Pitch still optimized."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state mntr: Pitch Scan is still working. Quit.\n");
       startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
       efClear(start_f); epicsThreadSleep(0.001);
 } state mntr
 when (efTest(start_f) && startBtn == 1 && (newEn < 5.0 || newEn > 22.0)) {
       sprintf(msgQ, "**Energy out of range."); efSet(msg_f); epicsThreadSleep(0.001);
       printf("state mntr: Requested Energy is out of range, ENERGYMIN=%f, ENERGYMAX=%f.\n", 5.0, 22.0);
              startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
       efClear(start_f); epicsThreadSleep(0.001);
 } state mntr
 when (efTest(start_f) && startBtn == 1 && centrWrkng == 1) {
       sprintf(msgQ, "**Center-Beam working."); efSet(msg_f); epicsThreadSleep(0.001);
       printf("state mntr: Center-Beam script is working.\n");
              startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
       efClear(start_f); epicsThreadSleep(0.001);
 } state mntr
        when (efTest(start_f) && startBtn == 1 && (newEn >= 5.0 && newEn <= 22.0)) {
              printf("state mntr: entering last when where move_en_f is set.\n");
       startEn = actEn; finishEn = newEn; deltaEn = actEn - newEn;
       if(deltaEn < 0) deltaEn = newEn - actEn;
       sprintf(msgQ, "Preparing to move."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("Preparing to combined motion.\n");
       startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
       efClear(start_f); epicsThreadSleep(0.001);

       pvGet(actEnID); epicsThreadSleep(0.001); startEnID = actEnID;
       pvGet(rqsHrmID); epicsThreadSleep(0.001); startHrmID = rqsHrmID;
       pvGet(actChi); epicsThreadSleep(0.001); startChi = actChi;
       pvGet(actPitch); epicsThreadSleep(0.001); startPi = actPitch;
       pvGet(actLnHFM); epicsThreadSleep(0.001); startLnHFM = actLnHFM;
       pvGet(actLnVFM); epicsThreadSleep(0.001); startLnVFM = actLnVFM;
       pvGet(curTheta); epicsThreadSleep(0.001); startTh = curTheta;
       efSet(moveen_f); epicsThreadSleep(0.001);
              printf("state mntr: leaving last when where move_en_f is set.\n");
 } state mntr
 when (efTestAndClear(clean_f)) {
         for(i=9; i>=0; i--) {
             strcpy (msg[i], ""); pvPut(msg[i]); epicsThreadSleep(0.001);
         }
         strcpy (msg[9], "Ready"); pvPut(msg[9]); epicsThreadSleep(0.001); msgI = 9;
         cleanBtn = 0; pvPut(cleanBtn); epicsThreadSleep(0.001); efClear(clean_f); epicsThreadSleep(0.001);
        } state mntr
 when (efTest(undo_f) && undoBtn == 1) {
         printf("mntr: entering undo.\n");
                chEnWrkng = 1; pvPut(chEnWrkng); epicsThreadSleep(0.001);
                EnAbort = 1; pvPut(EnAbort); epicsThreadSleep(0.001);
  rqsPosEn = startEn; pvPut(rqsPosEn); epicsThreadSleep(0.001);
                printf("undo: Moving En to %f.).\n", startEn);
         if(idEnaBtn == 1) {
                       if(IDStatus == 1) {IDStop = 1; pvPut(IDStop); epicsThreadSleep(0.1);}
         rqsHrmID = startHrmID; pvPut(rqsHrmID); epicsThreadSleep(0.001);
         rqsEnID = startEnID; printf("undo: Moving ID to %f.\n", rqsEnID);
         pvPut(rqsEnID); epicsThreadSleep(0.001);
                       IDStart = 1; pvPut(IDStart); epicsThreadSleep(0.001);
         }
  if(vfmEnaBtn == 1) {
                      VFMAbort = 1; pvPut(VFMAbort); epicsThreadSleep(0.001);
        rqsLnVFM = startLnVFM; pvPut(rqsLnVFM); epicsThreadSleep(0.001);
                      printf("undo: Moving VFM to %f.).\n", rqsLnVFM);
                }
  if(hfmEnaBtn == 1) {
        HFMAbort = 1; pvPut(HFMAbort); epicsThreadSleep(0.001);
        rqsLnHFM = startLnHFM; pvPut(rqsLnHFM); epicsThreadSleep(0.001);
                      printf("undo: Moving HFM to %f.).\n", rqsLnHFM);
                }

  if(piEnaBtn == 1) {
         if(piScanBusy == 1) {
                            piScanAbort = 1; pvPut(piScanAbort); epicsThreadSleep(0.1);
              piScanAbort = 1; pvPut(piScanAbort); epicsThreadSleep(0.1);
       epicsThreadSleep(0.5);
                            printf("undo: Abort pitch scan.\n");
                       }
                       ChiAbort = 1; pvPut(ChiAbort); epicsThreadSleep(0.1);
         rqsPitch = startPi; pvPut(rqsPitch); epicsThreadSleep(0.1);
                       printf("undo: Moving Pitch to %f.).\n", rqsPitch);
  }
                if(chiEnaBtn == 1) {
                       if(ChiRunPrg == 0) {ChiAbort = 1; pvPut(ChiAbort); epicsThreadSleep(0.001);}
         rqsPosChi = startChi; pvPut(rqsPosChi); epicsThreadSleep(0.001);
                       printf("undo: Moving CHI to %f.).\n", rqsPosChi);
                }
                if(thEnaBtn == 1) {curTheta = startTh; pvPut(curTheta); epicsThreadSleep(0.001); }
                printf("undo: Moving Theta to %f.).\n", curTheta);
  epicsThreadSleep(0.5);




         detMode = 1; pvPut(detMode); epicsThreadSleep(0.001);
         sprintf(msgQ, "Undo finished. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
  efClear(moveen_f); epicsThreadSleep(0.001); efClear(moveid_f); epicsThreadSleep(0.001);
  efClear(movechi_f); epicsThreadSleep(0.001);
                efClear(movevfm_f); epicsThreadSleep(0.001); efClear(movehfm_f); epicsThreadSleep(0.001);
  efClear(optpi_f); epicsThreadSleep(0.001); efClear(optth_f); epicsThreadSleep(0.001);
  startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001); efClear(start_f); epicsThreadSleep(0.001);
         abortBtn = 0; pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
  undoBtn = 0; pvPut(undoBtn); epicsThreadSleep(0.001); efClear(undo_f); epicsThreadSleep(0.001);
         thWrkng = 0; pvPut(thWrkng); epicsThreadSleep(0.001);
                chEnWrkng = 0; pvPut(chEnWrkng); epicsThreadSleep(0.001);
         printf("mntr: leaving undo.\n");
  } state mntr
    }
}

ss set2 {
    state init2 {
          when (efTest(moveen_f)) {
     epicsThreadSleep(0.001);
   } state move_en
    }
    state move_en {
 when (efTestAndClear(msg_f)) {
   printf("state move_en: entering msg.\n");
%% tsLocalTime(&tmc);
%% tsStampToText (&tmc, TS_TEXT_MMDDYY, pVar->time_str);
   if(strstr(msg[msgI],msgQ) == NULL) {
     if (msgI > 0) {
          msgI -= 1;
     } else {
             for (i=9; i>0; i--) {
           strcpy (msg[i], msg[i-1]); pvPut(msg[i]); epicsThreadSleep(0.001);
             }
     }
   }
   sprintf (msg[msgI], "%8.8s %s", &time_str[9], msgQ); pvPut(msg[msgI]); epicsThreadSleep(0.001);
   efClear(msg_f); epicsThreadSleep(0.001);
   printf("state move_en: leaving msg.\n");
        } state move_en
 when (efTest(abort_f) && abortBtn == 1) {
         printf("state move_en: entering abort.\n");
                EnAbort = 1; pvPut(EnAbort); epicsThreadSleep(0.001);
                if(idEnaBtn == 1) { IDStop = 1; pvPut(IDStop); epicsThreadSleep(0.001);}
                if(chiEnaBtn == 1) { ChiAbort = 1; pvPut(ChiAbort); epicsThreadSleep(0.001);}
  if(vfmEnaBtn == 1) { VFMAbort = 1; pvPut(VFMAbort); epicsThreadSleep(0.001);}
  if(hfmEnaBtn == 1) { HFMAbort = 1; pvPut(HFMAbort); epicsThreadSleep(0.001);}
  if(piEnaBtn == 1) {
         piScanAbort = 1; pvPut(piScanAbort); epicsThreadSleep(0.1);
         piScanAbort = 1; pvPut(piScanAbort); epicsThreadSleep(0.1);

  }
                epicsThreadSleep(0.5);
                EnKill = 1; pvPut(EnKill); epicsThreadSleep(0.001);
  if(chiEnaBtn == 1) { ChiKill = 1; pvPut(ChiKill); epicsThreadSleep(0.001);}
  if(vfmEnaBtn == 1) { VFMKill = 1; pvPut(VFMKill); epicsThreadSleep(0.001);}
  if(hfmEnaBtn == 1) { HFMKill = 1; pvPut(HFMKill); epicsThreadSleep(0.001);}
         detMode = 1; pvPut(detMode); epicsThreadSleep(0.001);
         sprintf(msgQ, "**Job aborted. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
  efClear(moveen_f); epicsThreadSleep(0.001); efClear(moveid_f); epicsThreadSleep(0.001);
  efClear(movechi_f); epicsThreadSleep(0.001);
                efClear(movevfm_f); epicsThreadSleep(0.001); efClear(movehfm_f); epicsThreadSleep(0.001);
  efClear(optpi_f); epicsThreadSleep(0.001); efClear(optth_f); epicsThreadSleep(0.001);
  startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001); efClear(start_f); epicsThreadSleep(0.001);
         abortBtn = 0; pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
         thWrkng = 0; pvPut(thWrkng); epicsThreadSleep(0.001);
                chEnWrkng = 0; pvPut(chEnWrkng); epicsThreadSleep(0.001);
         printf("state move_en: leaving abort.\n");
 } state init2
        when(efTest(moveen_f) && deltaEn <= 0.1) {
       printf("state move_en: entering deltaEn < 0.1.\n");
       sprintf(msgQ, "En=%2.3f tuning Chi&Thet", newEn); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state move: deltaEn < 0.1: Moving just Energy to %f. Plus optimization.\n", newEn);
              chEnWrkng = 1; pvPut(chEnWrkng); epicsThreadSleep(0.001);
       EnAbort = 1; pvPut(EnAbort); epicsThreadSleep(0.001);
       rqsPosEn = newEn; pvPut(rqsPosEn); epicsThreadSleep(0.001);
              epicsThreadSleep(20);
       EnKill = 1; pvPut(EnKill); epicsThreadSleep(0.001);
       efClear(moveen_f); epicsThreadSleep(0.001); efClear(moveid_f); epicsThreadSleep(0.001);
       efClear(movevfm_f); epicsThreadSleep(0.001); efClear(movehfm_f); epicsThreadSleep(0.001);
       if(chiEnaBtn == 1) { efSet(movechi_f); epicsThreadSleep(0.001); }
       else { efClear(movechi_f); epicsThreadSleep(0.001); }
       if(piEnaBtn == 1) { efSet(optpi_f); epicsThreadSleep(0.001); }
       else {
                    efClear(optpi_f); epicsThreadSleep(0.001);
                    efClear(optth_f); epicsThreadSleep(0.001); efClear(finished); epicsThreadSleep(0.001);
              }
       printf("state move_en: leaving deltaEn < 0.1.\n");
        } state move_en
 when (efTest(moveen_f) && deltaEn > 0.1) {
        printf("state move_en: entering move En to RqsPos.\n");
        sprintf(msgQ, "Move En to %2.3f.", newEn); efSet(msg_f); epicsThreadSleep(0.001);
        printf("state move: deltaEn >0.1: Moving Energy to %f.\n", newEn);
               chEnWrkng = 1; pvPut(chEnWrkng); epicsThreadSleep(0.001);
        EnAbort = 1; pvPut(EnAbort); epicsThreadSleep(0.2);
        rqsPosEn = newEn; pvPut(rqsPosEn); epicsThreadSleep(0.001);
        if(chiEnaBtn == 1) { efSet(movechi_f); epicsThreadSleep(0.001); }
        else { efClear(movechi_f); epicsThreadSleep(0.001); }
        if(idEnaBtn == 1) { efSet(moveid_f); epicsThreadSleep(0.001); }
        else { efClear(moveid_f); epicsThreadSleep(0.001); }
        if(vfmEnaBtn == 1) { efSet(movevfm_f); epicsThreadSleep(0.001); }
        else { efClear(movevfm_f); epicsThreadSleep(0.001); }
        if(hfmEnaBtn == 1) { efSet(movehfm_f); epicsThreadSleep(0.001); }
        else { efClear(movehfm_f); epicsThreadSleep(0.001); }
        if(piEnaBtn == 1) { efSet(optpi_f); epicsThreadSleep(0.001); }
        else { efClear(optpi_f); epicsThreadSleep(0.001); efClear(optth_f); epicsThreadSleep(0.001); efClear(finished); epicsThreadSleep(0.001);}
        efClear(moveen_f); epicsThreadSleep(0.001);
        printf("state move_en: leavingg move En to RqsPos.\n");
  } state move_en
  when (efTest(movechi_f)) {
         printf("state move_en: entering move Chi: startEn=%f, finishEn=%f, deltaEn=%f.\n", startEn, finishEn, deltaEn);


                chEnWrkng = 1; pvPut(chEnWrkng); epicsThreadSleep(0.001);
         ChiAbort = 1; pvPut(ChiAbort); epicsThreadSleep(0.001);
  tmpdb = actChi - (startEn * chiSca);

  if (tmpdb > (-2.0) && tmpdb < 2.0) {
                     chiOff = tmpdb; pvPut(chiOff); epicsThreadSleep(0.001);
                }
  rqsPosChi = finishEn * chiSca + chiOff;
                sprintf(msgQ, "Move CHI to %2.5f.", rqsPosChi); efSet(msg_f); epicsThreadSleep(0.001);
         printf("state move: deltaEn >0.1: Moving CHI to %f.\n", rqsPosChi);
  pvPut(rqsPosChi); epicsThreadSleep(0.001);
         efClear(movechi_f); epicsThreadSleep(0.001);
         printf("state move_en: leaving move Chi.\n");
  } state move_en
  when (efTest(moveid_f)) {
         printf("state move_en: entering move ID.\n");
                chEnWrkng = 1; pvPut(chEnWrkng); epicsThreadSleep(0.001);
  if(finishEn >= hrmSwEn && hrmSwEn > 12 && hrmSwEn < 13.5) {
                           rqsHrmID = 3.0; pvPut(rqsHrmID); epicsThreadSleep(0.001);
             rqsEnID = finishEn + idOff2;
                }
         else {
             rqsHrmID = 1.0; pvPut(rqsHrmID); epicsThreadSleep(0.001);
                           rqsEnID = finishEn + idOff1;
  }
         sprintf(msgQ, "Move ID to %2.3f.", rqsEnID); efSet(msg_f); epicsThreadSleep(0.001);
         printf("state move: deltaEn >0.1: Moving ID to %f.\n", rqsEnID);
  pvPut(rqsEnID); epicsThreadSleep(0.001); IDStart = 1; pvPut(IDStart); epicsThreadSleep(0.001);
         efClear(moveid_f); epicsThreadSleep(0.001);
         printf("state move_en: leaving move ID.\n");
  } state move_en
  when (efTest(movevfm_f)) {
         printf("state move_en: entering move VFM.\n");
                chEnWrkng = 1; pvPut(chEnWrkng); epicsThreadSleep(0.001);
  printf("movevfm: finishEn=%f, startEn=%f.\n", finishEn, startEn);
  if(finishEn < 5.5) {
                    if(startEn < 5.5 && (actLnVFM > -3.0 && actLnVFM < 6.0)) {i = 0;}
      else { rqsLnVFM = vfmGl; i = 1; }
  }
  else if (finishEn > 10.5) {
                    if(startEn > 10.5 && (actLnVFM < -3.0 && actLnVFM > -16.0)) {i = 0;}
      else {rqsLnVFM = vfmPt; i = 1; }
  }
  else {
                      if((startEn >= 5.5 && startEn <= 10.5) && (actLnVFM > 6.0 && actLnVFM < 20.0)) {i = 0;}
        else { rqsLnVFM = vfmPd; i = 1; }
  }
                if(i == 0) {
                  sprintf(msgQ, "VFM cur. stripe fits."); efSet(msg_f); epicsThreadSleep(0.001);
                  printf("state move: deltaEn >0.1: Vfm current-stripe fits.\n");
  }
  else {
                  sprintf(msgQ, "VFM to %2.1f.", rqsLnVFM); efSet(msg_f); epicsThreadSleep(0.001);
                  printf("state move: deltaEn >0.1: Moving VFM to %f.\n", rqsLnVFM);
                  VFMAbort = 1; pvPut(VFMAbort); epicsThreadSleep(0.1); pvPut(rqsLnVFM); epicsThreadSleep(0.001);
  }
         efClear(movevfm_f); epicsThreadSleep(0.001);
         printf("state move_en: leaving move VFM.\n");
  } state move_en
  when (efTest(movehfm_f)) {
         printf("state move_en: entering move HFM.\n");
                chEnWrkng = 1; pvPut(chEnWrkng); epicsThreadSleep(0.001);
         printf("movehfm: finishEn=%f, startEn=%f.\n", finishEn, startEn);
  if(finishEn < 5.5) {
                    if(startEn < 5.5 && (actLnHFM > -10 && actLnHFM < 0.1)) {i = 0;}
      else { rqsLnHFM = hfmGl; i = 1; }
  }
  else if (finishEn > 10.5) {
                        if(startEn > 10.5 && (actLnHFM < -10 && actLnHFM > -19.0)) {i = 0;}
          else { rqsLnHFM = hfmPt; i = 1; }
  }
  else {
                       if((startEn >= 5.5 && startEn <= 10.5) && (actLnHFM > 0.1 && actLnHFM < 13.0)) {i = 0;}
         else { rqsLnHFM = hfmPd; i = 1; }
  }
                if(i == 0) {
                sprintf(msgQ, "HFM cur. stripe fits."); efSet(msg_f); epicsThreadSleep(0.001);
                printf("state move: deltaEn >0.1: HFM current-stripe fits.\n");
  }
  else {
                sprintf(msgQ, "HFM to %2.1f.", rqsLnHFM); efSet(msg_f); epicsThreadSleep(0.001);
                printf("state move: deltaEn >0.1: Moving HFM to %f.\n", rqsLnHFM);
         HFMAbort = 1; pvPut(HFMAbort); epicsThreadSleep(0.1); pvPut(rqsLnHFM); epicsThreadSleep(0.001);
  }
         efClear(movehfm_f); epicsThreadSleep(0.001);
         printf("state move_en: leaving move HFM.\n");
  } state move_en
  when (delay(480)) {
        sprintf(msgQ, "**Timeout. Abort"); efSet(msg_f); epicsThreadSleep(0.001);
        printf("move_en: Timeout. Abort.\n");
        efClear(moveen_f); epicsThreadSleep(0.001); efClear(moveid_f); epicsThreadSleep(0.001);
        efClear(movechi_f); epicsThreadSleep(0.001);
               efClear(movevfm_f); epicsThreadSleep(0.001); efClear(movehfm_f); epicsThreadSleep(0.001);
        efClear(optpi_f); epicsThreadSleep(0.001); efClear(optth_f); epicsThreadSleep(0.001);
        efClear(finished); epicsThreadSleep(0.001);
        abortBtn = 1; pvPut(abortBtn); epicsThreadSleep(0.001);
  } state init2
  when (efTest(optpi_f) && EnRunPrg == 0 && ChiRunPrg == 0 && IDStatus == 0 && VFMRunPrg == 0 && HFMRunPrg == 0 && delay(1)) {
        printf("state move_en: entering scan Pitch.\n");
               chEnWrkng = 1; pvPut(chEnWrkng); epicsThreadSleep(0.001);
        EnKill = 1; pvPut(EnKill); epicsThreadSleep(0.001);
        if(vfmEnaBtn == 1) {VFMKill = 1; pvPut(VFMKill); epicsThreadSleep(0.001); }
        if(hfmEnaBtn == 1) {HFMKill = 1; pvPut(HFMKill); epicsThreadSleep(0.001); }
        printf("opt-pitch: ActPitch=%f.\n", actPitch);
        sprintf(msgQ, "Optimizing Pitch."); efSet(msg_f); epicsThreadSleep(0.001);
        printf("opt-pitch: Optimizing Pitch.\n");
        ChiAbort = 1; pvPut(ChiAbort); epicsThreadSleep(0.001);
        curTheta = 0.0; pvPut(curTheta); epicsThreadSleep(0.001);
        detMode = 0; pvPut(detMode); epicsThreadSleep(0.001);
               pvPut(piScanPosRd); epicsThreadSleep(0.001);
               pvPut(piScanPosDr); epicsThreadSleep(0.001);
               pvPut(piScanDtTrg); epicsThreadSleep(0.001);
               pvPut(piScanDet); epicsThreadSleep(0.001);
               pvPut(piScanAfter); epicsThreadSleep(0.001);
               piScanPosStl = 0.0; pvPut(piScanPosStl); epicsThreadSleep(0.001);
               piScanDetStl = 0.0; pvPut(piScanDetStl); epicsThreadSleep(0.001);
               piScanUpdt = 0.2; pvPut(piScanUpdt); epicsThreadSleep(0.001);
               piScanLinr = 0; pvPut(piScanLinr); epicsThreadSleep(0.001);
               piScanAbslt = 0; pvPut(piScanAbslt); epicsThreadSleep(0.001);
               piScanPeakP = 3; pvPut(piScanPeakP); epicsThreadSleep(0.001);
        piScanCntr = actPitch; pvPut(piScanCntr); epicsThreadSleep(0.001);
        piScanWdth = scWdth; pvPut(piScanWdth); epicsThreadSleep(0.001);
        piScanStep = scStep; pvPut(piScanStep); epicsThreadSleep(0.001);
        epicsThreadSleep(0.1);
        piScanStart = 1; pvPut(piScanStart); epicsThreadSleep(0.001);
        efClear(optpi_f); epicsThreadSleep(0.001);
               if(thEnaBtn == 1) {
                    efSet(optth_f); epicsThreadSleep(0.001);
               }
        else { efClear(optth_f); epicsThreadSleep(0.001); }
        printf("state move_en: leavingg scan Pitch.\n");
         } state move_en
  when (efTest(optth_f) && EnRunPrg == 0 && piScanBusy == 0 && delay(1)) {
        printf("state move_en: entering scan Theta.\n");
               chEnWrkng = 1; pvPut(chEnWrkng); epicsThreadSleep(0.001);
        thWrkng = 1; pvPut(thWrkng); epicsThreadSleep(0.001);
        detMode = 1; pvPut(detMode); epicsThreadSleep(0.001);
        sprintf(msgQ, "Optimize piezo."); efSet(msg_f); epicsThreadSleep(0.001);
        printf("opt-theta: Optimizing Theta with piezo drive.\n");
        maxTheta = curTheta; maxCnts = 0;
        line = 0; step = thStep;
 %% do {
      cnts = 0;
      for (j=0; j<3; j++) {
                           epicsThreadSleep(0.2);
      pvGet(detCnts); epicsThreadSleep(0.001);
      cnts = cnts + detCnts;
      }
      cnts = cnts/3.0;
                    epicsThreadSleep(0.2);
      pvGet(curTheta); epicsThreadSleep(0.001);
                    epicsThreadSleep(0.001);
             printf("opt-theta: line=%d, curTheta=%f, cnts=%f.\n", line, curTheta, cnts);
      if(cnts >= maxCnts) {maxTheta = curTheta; maxCnts = cnts;}
      else {
   if(line == 1) { step = -step; maxCnts = 0; printf("opt-theta: Reverse direction.\n");}
   else { printf("opt-theta: Optimization finished.\n"); break; }
      }
      line++;

      curTheta += step;
      if (curTheta < -4.9 || curTheta > 4.9) {
                   sprintf(msgQ, "**Theta out of range."); efSet(msg_f); epicsThreadSleep(0.001);
                          printf("opt-theta: **Theta out of range. Stop.\n");
            break;
             }
             printf("opt-theta: curTheta=%f.\n",curTheta);
      pvPut(curTheta); epicsThreadSleep(0.1);
%% } while(1);
               printf("opt-theta: Exit the loop. Final theta=%f.\n", maxTheta);
        line = 0;
        curTheta = maxTheta - 100.0 * step;
        if(curTheta < -4.9 || curTheta > 4.9) { pvPut(curTheta); epicsThreadSleep(0.001); }
        curTheta = maxTheta; pvPut(curTheta); epicsThreadSleep(0.001);
               efClear(optth_f); epicsThreadSleep(0.001);
        efSet(finished); epicsThreadSleep(0.001);
        efClear(moveen_f); epicsThreadSleep(0.001); efClear(moveid_f); epicsThreadSleep(0.001);
        efClear(movechi_f); epicsThreadSleep(0.001);
               efClear(movevfm_f); epicsThreadSleep(0.001); efClear(movehfm_f); epicsThreadSleep(0.001);
        efClear(optpi_f); epicsThreadSleep(0.001); efClear(optth_f); epicsThreadSleep(0.001);
        thWrkng = 0; pvPut(thWrkng); epicsThreadSleep(0.001);
        printf("state move_en: leaving scan Theta.\n");
  } state move_en
  when(efTest(finished)) {
               chEnWrkng = 0; pvPut(chEnWrkng); epicsThreadSleep(0.001);
        efClear(finished); epicsThreadSleep(0.001);
        sprintf(msgQ, "Ready."); efSet(msg_f); epicsThreadSleep(0.001);
               printf("move_en: Theta opt finished. Ready.\n");
  } state init2
 when (efTest(undo_f) && undoBtn == 1) {
         printf("undo: when undo_f .\n");
                chEnWrkng = 1; pvPut(chEnWrkng); epicsThreadSleep(0.001);
                EnAbort = 1; pvPut(EnAbort); epicsThreadSleep(0.001);
  rqsPosEn = startEn; pvPut(rqsPosEn); epicsThreadSleep(0.001);
                printf("undo: Moving En to %f.).\n", startEn);
         if(idEnaBtn == 1) {
                       if(IDStatus == 1) {IDStop = 1; pvPut(IDStop); epicsThreadSleep(0.1);}
         rqsHrmID = startHrmID; pvPut(rqsHrmID); epicsThreadSleep(0.001);
         rqsEnID = startEnID; printf("undo: Moving ID to %f.\n", rqsEnID);
         pvPut(rqsEnID); epicsThreadSleep(0.001);
                       IDStart = 1; pvPut(IDStart); epicsThreadSleep(0.001);
         }
  if(vfmEnaBtn == 1) {
                      VFMAbort = 1; pvPut(VFMAbort); epicsThreadSleep(0.001);
        rqsLnVFM = startLnVFM; pvPut(rqsLnVFM); epicsThreadSleep(0.001);
                      printf("undo: Moving VFM to %f.).\n", rqsLnVFM);
                }
  if(hfmEnaBtn == 1) {
        HFMAbort = 1; pvPut(HFMAbort); epicsThreadSleep(0.001);
        rqsLnHFM = startLnHFM; pvPut(rqsLnHFM); epicsThreadSleep(0.001);
                      printf("undo: Moving HFM to %f.).\n", rqsLnHFM);
                }

  if(piEnaBtn == 1) {
         if(piScanBusy == 1) {
                            piScanAbort = 1; pvPut(piScanAbort); epicsThreadSleep(0.1);
              piScanAbort = 1; pvPut(piScanAbort); epicsThreadSleep(0.1);
       epicsThreadSleep(0.5);
                            printf("undo: Abort pitch scan.\n");
                       }
                       ChiAbort = 1; pvPut(ChiAbort); epicsThreadSleep(0.1);
         rqsPitch = startPi; pvPut(rqsPitch); epicsThreadSleep(0.1);
                       printf("undo: Moving Pitch to %f.).\n", rqsPitch);
  }
                if(chiEnaBtn == 1) {
                       if(ChiRunPrg == 0) {ChiAbort = 1; pvPut(ChiAbort); epicsThreadSleep(0.001);}
         rqsPosChi = startChi; pvPut(rqsPosChi); epicsThreadSleep(0.001);
                       printf("undo: Moving CHI to %f.).\n", rqsPosChi);
                }
                if(thEnaBtn == 1) {curTheta = startTh; pvPut(curTheta); epicsThreadSleep(0.001); }
                printf("undo: Moving Theta to %f.).\n", curTheta);
  epicsThreadSleep(0.5);




         detMode = 1; pvPut(detMode); epicsThreadSleep(0.001);
         sprintf(msgQ, "Undo finished. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
  efClear(moveen_f); epicsThreadSleep(0.001); efClear(moveid_f); epicsThreadSleep(0.001);
  efClear(movechi_f); epicsThreadSleep(0.001);
                efClear(movevfm_f); epicsThreadSleep(0.001); efClear(movehfm_f); epicsThreadSleep(0.001);
  efClear(optpi_f); epicsThreadSleep(0.001); efClear(optth_f); epicsThreadSleep(0.001);
  startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001); efClear(start_f); epicsThreadSleep(0.001);
         abortBtn = 0; pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
  undoBtn = 0; pvPut(undoBtn); epicsThreadSleep(0.001); efClear(undo_f); epicsThreadSleep(0.001);
         thWrkng = 0; pvPut(thWrkng); epicsThreadSleep(0.001);
                chEnWrkng = 0; pvPut(chEnWrkng); epicsThreadSleep(0.001);
  } state init2
    }
}
