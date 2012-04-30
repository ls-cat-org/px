# 1 "../vfminout.st"
# 1 "<built-in>"
# 1 "<command line>"
# 1 "../vfminout.st"
program vfminout("coioc=21linux")

option +r;
option +a;

%%#include <string.h>
%%#include <math.h>
%%#include <tsDefs.h>
# 1 "../vfminout.h" 1


%%TS_STAMP tmc;

char time_str[80];

int i;
int status;
int msgI;

int startFdbk;
int startShSt;
int startAttUnit;
double startAtt;
double startMKys;
double startDSyc;
double startDSys;
double startDSxs;
double startVFMh;
double startVFMa;
double startTBh;
double startTBa;
double startDTd;
double startDTh;
double startDTx;
double startDTvOff;
double startDTav;
double startDTsv;

int preFdbk;
int preHtchSh;
int preAttUnit;
double preAtt;
double preMKys;
double preDSys;
double preDSxs;

double runDSyc;
double runVFMh;
double runTBh;
double runTBa;

double runDTd;
double runDTh;
double runDTx;

double postDTvOff;
double postDTvAng;
double postDTvSh;

int vfmInBtn; assign vfmInBtn to "{coioc}:vfmio:StartVFMin"; monitor vfmInBtn; evflag vfmin_f; sync vfmInBtn vfmin_f;
int vfmOutBtn; assign vfmOutBtn to "{coioc}:vfmio:StartVFMout"; monitor vfmOutBtn; evflag vfmout_f; sync vfmOutBtn vfmout_f;
int abortBtn; assign abortBtn to "{coioc}:vfmio:Abort"; monitor abortBtn; evflag abort_f; sync abortBtn abort_f;
int undoBtn; assign undoBtn to "{coioc}:vfmio:Undo"; monitor undoBtn; evflag undo_f; sync undoBtn undo_f;
int cleanBtn; assign cleanBtn to "{coioc}:vfmio:Clean"; monitor cleanBtn; evflag clean_f; sync cleanBtn clean_f;

int stopFdbkBtn; assign stopFdbkBtn to "{coioc}:fdbk:StopStart"; monitor stopFdbkBtn; evflag stopfdbk_f; sync stopFdbkBtn stopfdbk_f;
int fdbkWrkng; assign fdbkWrkng to "{coioc}:fdbk:fdbkWrkng"; monitor fdbkWrkng;

int chEnWrkng; assign chEnWrkng to "{coioc}:mono:ChEnWrkng"; monitor chEnWrkng;
int centrWrkng; assign centrWrkng to "{coioc}:mono:CentrWrkng"; monitor centrWrkng;

int vfmIOWrkng; assign vfmIOWrkng to "{coioc}:vfmio:VFMioWrkng"; monitor vfmIOWrkng;

int htchShOp; assign htchShOp to "PC:21ID:Rem_DshtrOpen"; monitor htchShOp;
int htchShCl; assign htchShCl to "PC:21ID:Rem_DshtrClose"; monitor htchShCl;
int htchShSt; assign htchShSt to "PC:21ID:STA_D_SHUTTER_CLOSED"; monitor htchShSt;

double attUnit; assign attUnit to "21:D1:AttUnit"; monitor attUnit;
double attAct; assign attAct to "21:D1:AttAct"; monitor attAct;
double attRqs; assign attRqs to "21:D1:AttRqs"; monitor attRqs;

double attIn; assign attIn to "{coioc}:vfmio:AttIn"; monitor attIn;
double attOut; assign attOut to "{coioc}:vfmio:AttOut"; monitor attOut;
double dsHi; assign dsHi to "{coioc}:vfmio:DShi"; monitor dsHi;
double dsHo; assign dsHo to "{coioc}:vfmio:DSho"; monitor dsHo;
double tbHi; assign tbHi to "{coioc}:vfmio:TBhi"; monitor tbHi;
double tbHo; assign tbHo to "{coioc}:vfmio:TBho"; monitor tbHo;
double tbAi; assign tbAi to "{coioc}:vfmio:TBai"; monitor tbAi;
double tbAo; assign tbAo to "{coioc}:vfmio:TBao"; monitor tbAo;
double vfmHi; assign vfmHi to "{coioc}:vfmio:VFMhi"; monitor vfmHi;
double vfmHo; assign vfmHo to "{coioc}:vfmio:VFMho"; monitor vfmHo;
double dtOfIn; assign dtOfIn to "{coioc}:vfmio:DTVofi"; monitor dtOfIn;
double dtOfOut; assign dtOfOut to "{coioc}:vfmio:DTVofo"; monitor dtOfOut;
double dtAnIn; assign dtAnIn to "{coioc}:vfmio:DTVani"; monitor dtAnIn;
double dtAnOut; assign dtAnOut to "{coioc}:vfmio:DTVano"; monitor dtAnOut;
double dtShIn; assign dtShIn to "{coioc}:vfmio:DTVshi"; monitor dtShIn;
double dtShOut; assign dtShOut to "{coioc}:vfmio:DTVsho"; monitor dtShOut;

double actMKys; assign actMKys to "21:C1:MK:YS:ActPos"; monitor actMKys;
double rqsMKys; assign rqsMKys to "21:C1:MK:YS:RqsPos"; monitor rqsMKys;
long MKvAbort; assign MKvAbort to "21:C1:MK:Av:Abort"; monitor MKvAbort;
long MKRunPrg; assign MKRunPrg to "21:C1:MK:Av:RunPrg"; monitor MKRunPrg;

double actDSyc; assign actDSyc to "21:D1:S1:YC:ActPos"; monitor actDSyc;
double rqsDSyc; assign rqsDSyc to "21:D1:S1:YC:RqsPos"; monitor rqsDSyc;
double actDSys; assign actDSys to "21:D1:S1:YS:ActPos"; monitor actDSys;
double rqsDSys; assign rqsDSys to "21:D1:S1:YS:RqsPos"; monitor rqsDSys;
double actDSxs; assign actDSxs to "21:D1:S1:XS:ActPos"; monitor actDSxs;
double rqsDSxs; assign rqsDSxs to "21:D1:S1:XS:RqsPos"; monitor rqsDSxs;
long DSyAuto; assign DSyAuto to "21:D1:S1:Av:AutoStart"; monitor DSyAuto;
long DSyStart; assign DSyStart to "21:D1:S1:Av:Start"; monitor DSyStart;
long DSyAbort; assign DSyAbort to "21:D1:S1:Av:Abort"; monitor DSyAbort;
long DSyRunPrg; assign DSyRunPrg to "21:D1:S1:Av:RunPrg"; monitor DSyRunPrg;
long DSxAbort; assign DSxAbort to "21:D1:S1:Ah:Abort"; monitor DSxAbort;
long DSxRunPrg; assign DSxRunPrg to "21:D1:S1:Ah:RunPrg"; monitor DSxRunPrg;

double actKBvy; assign actKBvy to "21:D1:KB:VY:ActPos"; monitor actKBvy;
double rqsKBvy; assign rqsKBvy to "21:D1:KB:VY:RqsPos"; monitor rqsKBvy;


long VFMauto; assign VFMauto to "21:D1:KB:Vy:AutoStart"; monitor VFMauto;
long VFMstart; assign VFMstart to "21:D1:KB:Vy:Start"; monitor VFMstart;
long VFMAbort; assign VFMAbort to "21:D1:KB:Vy:Abort"; monitor VFMAbort;
long VFMRunPrg; assign VFMRunPrg to "21:D1:KB:Vy:RunPrg"; monitor VFMRunPrg;

double actTBh; assign actTBh to "21:D1:TB:H:ActPos"; monitor actTBh;
double rqsTBh; assign rqsTBh to "21:D1:TB:H:RqsPos"; monitor rqsTBh;
double actTBa; assign actTBa to "21:D1:TB:A:ActPos"; monitor actTBa;
double rqsTBa; assign rqsTBa to "21:D1:TB:A:RqsPos"; monitor rqsTBa;
long TBvAuto; assign TBvAuto to "21:D1:TB:Vr:AutoStart"; monitor TBvAuto;
long TBvStart; assign TBvStart to "21:D1:TB:Vr:Start"; monitor TBvStart;
long TBvAbort; assign TBvAbort to "21:D1:TB:Vr:Abort"; monitor TBvAbort;
long TBvRunPrg; assign TBvRunPrg to "21:D1:TB:Vr:RunPrg"; monitor TBvRunPrg;



double DTvdsOff; assign DTvdsOff to "21:D1:DT:VDS:Offset"; monitor DTvdsOff;
double DTvdsAct; assign DTvdsAct to "21:D1:DT:VDS:ActPos"; monitor DTvdsAct;
double DTvdsRqs; assign DTvdsRqs to "21:D1:DT:VDS:RqsPos"; monitor DTvdsRqs;
double DTvusAct; assign DTvusAct to "21:D1:DT:VUS:ActPos"; monitor DTvusAct;
double DTvusRqs; assign DTvusRqs to "21:D1:DT:VUS:RqsPos"; monitor DTvusRqs;

double DTdAct; assign DTdAct to "21:D1:DT:Z0:ActPos"; monitor DTdAct;
double DTdRqs; assign DTdRqs to "21:D1:DT:Z0:RqsPos"; monitor DTdRqs;
double DThAct; assign DThAct to "21:D1:DT:H0:ActPos"; monitor DThAct;
double DThRqs; assign DThRqs to "21:D1:DT:H0:RqsPos"; monitor DThRqs;
double DTxAct; assign DTxAct to "21:D1:DT:XC:ActPos"; monitor DTxAct;
double DTxRqs; assign DTxRqs to "21:D1:DT:XC:RqsPos"; monitor DTxRqs;
double DTdlAct; assign DTdlAct to "21:D1:DT:DL:ActPos"; monitor DTdlAct;
double DTdlRqs; assign DTdlRqs to "21:D1:DT:DL:RqsPos"; monitor DTdlRqs;

double DTvCorAng; assign DTvCorAng to "21:D1:DT:St:aV"; monitor DTvCorAng;
double DTvCorSh; assign DTvCorSh to "21:D1:DT:St:S"; monitor DTvCorSh;

long lpCorrOff; assign lpCorrOff to "21:D1:DT:Lp:mLink"; monitor lpCorrOff;
long DTlpAuto; assign DTlpAuto to "21:D1:DT:Lp:AutoStart"; monitor DTlpAuto;
long DTlpStart; assign DTlpStart to "21:D1:DT:Lp:Start"; monitor DTlpStart;
long DTlpAbort; assign DTlpAbort to "21:D1:DT:Lp:Abort"; monitor DTlpAbort;
long DTlpRunPrg; assign DTlpRunPrg to "21:D1:DT:Lp:RunPrg"; monitor DTlpRunPrg;

long stCorrOff; assign stCorrOff to "21:D1:DT:St:mLink"; monitor stCorrOff;
long DTvAuto; assign DTvAuto to "21:D1:DT:St:AutoStart"; monitor DTvAuto;
long DTvStart; assign DTvStart to "21:D1:DT:St:Start"; monitor DTvStart;
long DTvAbort; assign DTvAbort to "21:D1:DT:St:Abort"; monitor DTvAbort;
long DTvRunPrg; assign DTvRunPrg to "21:D1:DT:St:RunPrg"; monitor DTvRunPrg;

string msgQ;
string msg[10]; assign msg[0] to "{coioc}:vfmio:Msg9";
        assign msg[1] to "{coioc}:vfmio:Msg8";
                      assign msg[2] to "{coioc}:vfmio:Msg7";
                      assign msg[3] to "{coioc}:vfmio:Msg6";
                      assign msg[4] to "{coioc}:vfmio:Msg5";
                      assign msg[5] to "{coioc}:vfmio:Msg4";
                      assign msg[6] to "{coioc}:vfmio:Msg3";
                      assign msg[7] to "{coioc}:vfmio:Msg2";
                      assign msg[8] to "{coioc}:vfmio:Msg1";
                      assign msg[9] to "{coioc}:vfmio:Msg0";
evflag msg_f;
evflag movevfm_f;
evflag postmove_f;
evflag finished_f;
evflag fiundo_f;
# 10 "../vfminout.st" 2

ss setQ {
    state init {
   when() {

              printf("Init state.\n");
        vfmIOWrkng = 0; pvPut(vfmIOWrkng); epicsThreadSleep(0.001);
# 34 "../vfminout.st"
       efClear (clean_f); epicsThreadSleep(0.001); msgI = 9;
         vfmInBtn = 0; pvPut(vfmInBtn); epicsThreadSleep(0.001);
       efClear(vfmin_f); epicsThreadSleep(0.001);
         vfmOutBtn = 0; pvPut(vfmOutBtn); epicsThreadSleep(0.001);
       efClear(vfmout_f); epicsThreadSleep(0.001);
         abortBtn = 0; pvPut(abortBtn); epicsThreadSleep(0.001);
       efClear(abort_f); epicsThreadSleep(0.001);
       efClear(movevfm_f); epicsThreadSleep(0.001);
              efClear(postmove_f); epicsThreadSleep(0.001);
       efClear(finished_f); epicsThreadSleep(0.001);
       efClear(fiundo_f); epicsThreadSleep(0.001);
       sprintf(msgQ,"Ready."); efSet(msg_f); epicsThreadSleep(0.001);
          } state mntr
    }

    state mntr {
 when (efTestAndClear(msg_f)) {
   printf("vfmio: mntr: entering msg.\n");
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
          printf("vfmio: mntr: leaving msg.\n");
        } state mntr
 when (efTest(abort_f) && abortBtn == 1) {
              printf("vfmio: mntr: entering abort.\n");
       MKvAbort = 1; pvPut(MKvAbort); epicsThreadSleep(0.001);
       DSyAbort = 1; pvPut(DSyAbort); epicsThreadSleep(0.001);
       DSxAbort = 1; pvPut(DSxAbort); epicsThreadSleep(0.001);
       VFMAbort = 1; pvPut(VFMAbort); epicsThreadSleep(0.001);
       TBvAbort = 1; pvPut(TBvAbort); epicsThreadSleep(0.001);
       DTlpAbort = 1; pvPut(DTlpAbort); epicsThreadSleep(0.001);
       DTvAbort = 1; pvPut(DTvAbort); epicsThreadSleep(0.001);
       DTlpAuto = 0; pvPut(DTlpAuto); epicsThreadSleep(0.001);
       DTvAuto = 0; pvPut(DTvAuto); epicsThreadSleep(0.001);
       DSyAuto = 0; pvPut(DSyAuto); epicsThreadSleep(0.001);
       TBvAuto = 0; pvPut(TBvAbort); epicsThreadSleep(0.001);
       DTlpAuto = 0; pvPut(DTlpAuto); epicsThreadSleep(0.001);
       DTvAuto = 0; pvPut(DTvAuto); epicsThreadSleep(0.001);
  lpCorrOff = 1; pvPut(lpCorrOff); epicsThreadSleep(0.001);
  stCorrOff = 1; pvPut(stCorrOff); epicsThreadSleep(0.001);
       sprintf(msgQ, "**Job aborted. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
       printf("vfmio: mntr: **Job is aborted. Ready.\n");
       efClear(movevfm_f); epicsThreadSleep(0.001);
       efClear(postmove_f); epicsThreadSleep(0.001);
       efClear(finished_f); epicsThreadSleep(0.001);
       efClear(fiundo_f); epicsThreadSleep(0.001);
         vfmInBtn = 0; pvPut(vfmInBtn); epicsThreadSleep(0.001);
       efClear(vfmin_f); epicsThreadSleep(0.001);
         vfmOutBtn = 0; pvPut(vfmOutBtn); epicsThreadSleep(0.001);
       efClear(vfmout_f); epicsThreadSleep(0.001);
       abortBtn = 0; pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
       vfmIOWrkng = 0; pvPut(vfmIOWrkng); epicsThreadSleep(0.001);
              printf("vfmio: mntr: leaving abort.\n");
 } state mntr
 when(((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && chEnWrkng == 1) {
       sprintf(msgQ, "**Change-Energy working."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("vfmio: mntr: Change-Energy working.\n");
       vfmInBtn = 0; pvPut(vfmInBtn); epicsThreadSleep(0.001);
       efClear(vfmin_f); epicsThreadSleep(0.001);
       vfmOutBtn = 0; pvPut(vfmOutBtn); epicsThreadSleep(0.001);
       efClear(vfmout_f); epicsThreadSleep(0.001);
 } state mntr
 when (((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && centrWrkng == 1) {
       sprintf(msgQ, "**Center-Beam working."); efSet(msg_f); epicsThreadSleep(0.001);
       printf("vfmio: mntr: Center-Beam script is working.\n");
       vfmInBtn = 0; pvPut(vfmInBtn); epicsThreadSleep(0.001);
       efClear(vfmin_f); epicsThreadSleep(0.001);
       vfmOutBtn = 0; pvPut(vfmOutBtn); epicsThreadSleep(0.001);
       efClear(vfmout_f); epicsThreadSleep(0.001);
 } state mntr
 when (((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && MKRunPrg == 1) {
       sprintf(msgQ, "**Masks moving."); efSet(msg_f); epicsThreadSleep(0.001);
       printf("vfmio: mntr: Masks moving.\n");
       vfmInBtn = 0; pvPut(vfmInBtn); epicsThreadSleep(0.001);
       efClear(vfmin_f); epicsThreadSleep(0.001);
       vfmOutBtn = 0; pvPut(vfmOutBtn); epicsThreadSleep(0.001);
       efClear(vfmout_f); epicsThreadSleep(0.001);
 } state mntr
 when (((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && (DSyRunPrg == 1 || DSxRunPrg == 1)) {
       sprintf(msgQ, "**DS slit moving."); efSet(msg_f); epicsThreadSleep(0.001);
       printf("vfmio: mntr: DS slit moving.\n");
       vfmInBtn = 0; pvPut(vfmInBtn); epicsThreadSleep(0.001);
       efClear(vfmin_f); epicsThreadSleep(0.001);
       vfmOutBtn = 0; pvPut(vfmOutBtn); epicsThreadSleep(0.001);
       efClear(vfmout_f); epicsThreadSleep(0.001);
 } state mntr
 when (((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && VFMRunPrg == 1) {
       sprintf(msgQ, "**VFM moving."); efSet(msg_f); epicsThreadSleep(0.001);
       printf("vfmio: mntr: VFM moving.\n");
       vfmInBtn = 0; pvPut(vfmInBtn); epicsThreadSleep(0.001);
       efClear(vfmin_f); epicsThreadSleep(0.001);
       vfmOutBtn = 0; pvPut(vfmOutBtn); epicsThreadSleep(0.001);
       efClear(vfmout_f); epicsThreadSleep(0.001);
 } state mntr
 when (((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && TBvRunPrg == 1) {
       sprintf(msgQ, "**MD2 Table moving."); efSet(msg_f); epicsThreadSleep(0.001);
       printf("vfmio: mntr: MD2 Table moving.\n");
       vfmInBtn = 0; pvPut(vfmInBtn); epicsThreadSleep(0.001);
       efClear(vfmin_f); epicsThreadSleep(0.001);
       vfmOutBtn = 0; pvPut(vfmOutBtn); epicsThreadSleep(0.001);
       efClear(vfmout_f); epicsThreadSleep(0.001);
 } state mntr
 when (((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && (DTvRunPrg == 1 || DTlpRunPrg == 1)) {
       sprintf(msgQ, "**Detector moving."); efSet(msg_f); epicsThreadSleep(0.001);
       printf("vfmio: mntr: Detector moving.\n");
       vfmInBtn = 0; pvPut(vfmInBtn); epicsThreadSleep(0.001);
       efClear(vfmin_f); epicsThreadSleep(0.001);
       vfmOutBtn = 0; pvPut(vfmOutBtn); epicsThreadSleep(0.001);
       efClear(vfmout_f); epicsThreadSleep(0.001);
 } state mntr
 when ((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) {

       pvGet(attUnit); epicsThreadSleep(0.001); startAttUnit = attUnit;
       pvGet(attAct); epicsThreadSleep(0.001); startAtt = attAct;
       pvGet(actMKys); epicsThreadSleep(0.001); startMKys = actMKys;
              pvGet(actDSyc); epicsThreadSleep(0.001); startDSyc = actDSyc;
       pvGet(actDSys); epicsThreadSleep(0.001); startDSys = actDSys;
       pvGet(actDSxs); epicsThreadSleep(0.001); startDSxs = actDSxs;
       pvGet(actKBvy); epicsThreadSleep(0.001); startVFMh = actKBvy;
       pvGet(actTBh); epicsThreadSleep(0.001); startTBh = actTBh;
       pvGet(actTBa); epicsThreadSleep(0.001); startTBa = actTBa;
       pvGet(DTdAct); epicsThreadSleep(0.001); startDTd = DTdAct;
       pvGet(DThAct); epicsThreadSleep(0.001); startDTh = DThAct;
       pvGet(DTxAct); epicsThreadSleep(0.001); startDTx = DTxAct;
       pvGet(DTvdsOff); epicsThreadSleep(0.001); startDTvOff = DTvdsOff;
       pvGet(DTvCorAng); epicsThreadSleep(0.001); startDTav = DTvCorAng;
       pvGet(DTvCorSh); epicsThreadSleep(0.001); startDTsv = DTvCorSh;
       preFdbk = 0;
              if (vfmInBtn == 1) {
    preHtchSh = 1; preAttUnit = 0; preAtt = attIn;
    preMKys = 1.0; preDSys = 2.0; preDSxs = 2.0;
    runDSyc = dsHi; runVFMh = vfmHi; runTBh = tbHi; runTBa = tbAi;
                  postDTvOff = dtOfIn; postDTvAng = dtAnIn; postDTvSh = dtShIn;
           efClear(vfmin_f); vfmInBtn == 0; epicsThreadSleep(0.001);
           sprintf(msgQ, "Prepare to move IN."); efSet(msg_f); epicsThreadSleep(0.001);
                  printf("Prepare to move IN.\n");
           efSet(movevfm_f); epicsThreadSleep(0.001);
                  printf("vfmio: mntr: raising movevfm flag, leaving mntr-state.\n");
       }
       else if (vfmOutBtn == 1) {
    preHtchSh = 1; attUnit = 0; preAtt = attOut;
    preMKys = 2.0; preDSys = 0.2; preDSxs = 0.7;
    runDSyc = dsHo; runVFMh = vfmHo; runTBh = tbHo; runTBa = tbAo;
                  postDTvOff = dtOfOut; postDTvAng = dtAnOut; postDTvSh = dtShOut;
           efClear(vfmout_f); vfmOutBtn == 0; epicsThreadSleep(0.001);
           sprintf(msgQ, "Prepare to move OUT."); efSet(msg_f); epicsThreadSleep(0.001);
                  printf("Prepare to move OUT.\n");
           efSet(movevfm_f); epicsThreadSleep(0.001);
                  printf("vfmio: mntr: raising movevfm flag, leaving mntr-state.\n");
       }
              else {
           sprintf(msgQ, "Unknown flag. Abort."); efSet(msg_f); epicsThreadSleep(0.001);
                  printf("Unknown flag. Abort.\n");
    abortBtn = 1; pvPut(abortBtn); epicsThreadSleep(0.001);
       }
 } state mntr
 when(efTest(fiundo_f) && MKRunPrg == 0 && DSyRunPrg == 0 && DSxRunPrg == 0 && TBvRunPrg == 0 && VFMRunPrg == 0 && DTlpRunPrg == 0 && DTvRunPrg == 0) {
              vfmIOWrkng = 0; pvPut(vfmIOWrkng); epicsThreadSleep(0.001);
       DSyAuto = 0; pvPut(DSyAuto); epicsThreadSleep(0.001);
       TBvAuto = 0; pvPut(TBvAbort); epicsThreadSleep(0.001);
  lpCorrOff = 1; pvPut(lpCorrOff); epicsThreadSleep(0.001);
  stCorrOff = 1; pvPut(stCorrOff); epicsThreadSleep(0.001);
    DTlpAuto = 0; pvPut(DTlpAuto); epicsThreadSleep(0.001);
    DTvAuto = 0; pvPut(DTvAuto); epicsThreadSleep(0.001);
                DTlpAbort = 1; pvPut(DTlpAbort); epicsThreadSleep(0.001);
                DTvAbort = 1; pvPut(DTvAbort); epicsThreadSleep(0.001);
                DThRqs = startDTh; pvPut(DThRqs); epicsThreadSleep(0.001);
         DTxRqs = startDTx; pvPut(DTxRqs); epicsThreadSleep(0.001);
         DTdRqs = startDTd; pvPut(DTdRqs); epicsThreadSleep(0.001);
              epicsThreadSleep(0.001);
       efClear(fiundo_f); epicsThreadSleep(0.001);
       sprintf(msgQ, "Undo finished. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
       printf("mntr: Undo finished. Ready.\n");
 } state init
 when (efTestAndClear(clean_f)) {
         for(i=9; i>=0; i--) {
             strcpy (msg[i], ""); pvPut(msg[i]); epicsThreadSleep(0.001);
         }
         strcpy (msg[9], "Ready"); pvPut(msg[9]); epicsThreadSleep(0.001); msgI = 9;
         cleanBtn = 0; pvPut(cleanBtn); epicsThreadSleep(0.001); efClear(clean_f); epicsThreadSleep(0.001);
        } state mntr
 when (efTest(undo_f) && undoBtn == 1) {
         printf("mntr: entering undo.\n");
                vfmIOWrkng = 1; pvPut(vfmIOWrkng); epicsThreadSleep(0.001);

         efClear(movevfm_f); epicsThreadSleep(0.001);
         efClear(postmove_f); epicsThreadSleep(0.001);
         efClear(finished_f); epicsThreadSleep(0.001);
         efClear(fiundo_f); epicsThreadSleep(0.001);
           vfmInBtn = 0; pvPut(vfmInBtn); epicsThreadSleep(0.001);
         efClear(vfmin_f); epicsThreadSleep(0.001);
           vfmOutBtn = 0; pvPut(vfmOutBtn); epicsThreadSleep(0.001);
         efClear(vfmout_f); epicsThreadSleep(0.001);
         abortBtn = 0; pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
  undoBtn = 0; pvPut(undoBtn); epicsThreadSleep(0.001); efClear(undo_f); epicsThreadSleep(0.001);
  epicsThreadSleep(0.001);

                MKvAbort = 1; pvPut(MKvAbort); epicsThreadSleep(0.001);
                DSyAbort = 1; pvPut(DSyAbort); epicsThreadSleep(0.001);
                DSxAbort = 1; pvPut(DSxAbort); epicsThreadSleep(0.001);
                VFMAbort = 1; pvPut(VFMAbort); epicsThreadSleep(0.001);
                TBvAbort = 1; pvPut(TBvAbort); epicsThreadSleep(0.001);
  epicsThreadSleep(0.001);

         attUnit = startAttUnit; pvPut(attUnit); epicsThreadSleep(0.001);
         attRqs = startAtt; pvPut(attRqs); epicsThreadSleep(0.001);

  rqsMKys = startMKys; pvPut(rqsMKys); epicsThreadSleep(0.001);
         rqsDSxs = startDSxs; pvPut(rqsDSxs); epicsThreadSleep(0.001);
         rqsKBvy = startVFMh; pvPut(rqsKBvy); epicsThreadSleep(0.001);

  DSyAuto = 1; pvPut(rqsDSxs); epicsThreadSleep(0.001);
                rqsDSyc = startDSyc; pvPut(rqsDSyc); epicsThreadSleep(0.001);
                rqsDSys = startDSys; pvPut(rqsDSys); epicsThreadSleep(0.001);
                epicsThreadSleep(0.001);
  DSyStart = 1; pvPut(DSyStart); epicsThreadSleep(0.001);

    TBvAuto = 1; pvPut(TBvAuto); epicsThreadSleep(0.001);
         rqsTBh = startTBh; pvPut(rqsTBh); epicsThreadSleep(0.001);
         rqsTBa = startTBa; pvPut(rqsTBa); epicsThreadSleep(0.001);
    TBvStart = 1; pvPut(TBvStart); epicsThreadSleep(0.001);

    DTlpAuto = 1; pvPut(DTlpAuto); epicsThreadSleep(0.001);
    DTvAuto = 1; pvPut(DTvAuto); epicsThreadSleep(0.001);
  lpCorrOff = 0; pvPut(lpCorrOff); epicsThreadSleep(0.001);
  stCorrOff = 0; pvPut(stCorrOff); epicsThreadSleep(0.001);
                epicsThreadSleep(0.001);
                DTvdsOff = startDTvOff; pvPut(DTvdsOff); epicsThreadSleep(0.001);
         DTvCorAng = startDTav; pvPut(DTvCorAng); epicsThreadSleep(0.001);
         DTvCorSh = startDTsv; pvPut(DTvCorSh); epicsThreadSleep(0.001);
  epicsThreadSleep(3);
         sprintf(msgQ, "Undo in progress."); efSet(msg_f); epicsThreadSleep(0.001);
         printf("mntr: Undo in progress.\n");
         printf("mntr: leaving undo.\n");
         efSet(fiundo_f); epicsThreadSleep(0.001);
 } state mntr
    }
}

ss setX {
    state init2 {
          when (efTest(movevfm_f)) {
     epicsThreadSleep(0.001);
   } state move_vfm
    }
    state move_vfm {
 when (efTestAndClear(msg_f)) {
   printf("vfmio: move_vfm: entering msg.\n");
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
   printf("vfmio: move_vfm: leaving msg.\n");
        } state move_vfm
 when (efTest(abort_f) && abortBtn == 1) {
              printf("vfmio: move_vfm: entering abort.\n");
       MKvAbort = 1; pvPut(MKvAbort); epicsThreadSleep(0.001);
       DSyAbort = 1; pvPut(DSyAbort); epicsThreadSleep(0.001);
       DSxAbort = 1; pvPut(DSxAbort); epicsThreadSleep(0.001);
       VFMAbort = 1; pvPut(VFMAbort); epicsThreadSleep(0.001);
       TBvAbort = 1; pvPut(TBvAbort); epicsThreadSleep(0.001);
       DTlpAbort = 1; pvPut(DTlpAbort); epicsThreadSleep(0.001);
       DTvAbort = 1; pvPut(DTvAbort); epicsThreadSleep(0.001);
       DSyAuto = 0; pvPut(DSyAuto); epicsThreadSleep(0.001);
       TBvAuto = 0; pvPut(TBvAbort); epicsThreadSleep(0.001);
       DTlpAuto = 0; pvPut(DTlpAuto); epicsThreadSleep(0.001);
       DTvAuto = 0; pvPut(DTvAuto); epicsThreadSleep(0.001);
  lpCorrOff = 1; pvPut(lpCorrOff); epicsThreadSleep(0.001);
  stCorrOff = 1; pvPut(stCorrOff); epicsThreadSleep(0.001);
       sprintf(msgQ, "**Job aborted. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
       printf("vfmio: move_vfm: **Job is aborted. Ready.\n");
       efClear(movevfm_f); epicsThreadSleep(0.001);
       efClear(postmove_f); epicsThreadSleep(0.001);
       efClear(finished_f); epicsThreadSleep(0.001);
       efClear(fiundo_f); epicsThreadSleep(0.001);
         vfmInBtn = 0; pvPut(vfmInBtn); epicsThreadSleep(0.001);
       efClear(vfmin_f); epicsThreadSleep(0.001);
         vfmOutBtn = 0; pvPut(vfmOutBtn); epicsThreadSleep(0.001);
       efClear(vfmout_f); epicsThreadSleep(0.001);
       abortBtn = 0; pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
       vfmIOWrkng = 0; pvPut(vfmIOWrkng); epicsThreadSleep(0.001);
              printf("vfmio: move_vfm: leaving abort.\n");
 } state init2
 when (efTest(movevfm_f)) {
         printf("vfmio: move_vfm: move everything.\n");
         efClear(finished_f); epicsThreadSleep(0.001);
         sprintf(msgQ, "Move everything."); efSet(msg_f); epicsThreadSleep(0.001);
                vfmIOWrkng = 1; pvPut(vfmIOWrkng); epicsThreadSleep(0.001);

         stopFdbkBtn = preFdbk; pvPut(stopFdbkBtn); epicsThreadSleep(0.001);
         htchShCl = preHtchSh; pvPut(htchShCl); epicsThreadSleep(0.001);

         attUnit = preAttUnit; pvPut(attUnit); epicsThreadSleep(0.1);
         attRqs = preAtt; pvPut(attRqs); epicsThreadSleep(0.001);

         MKvAbort = 1; pvPut(MKvAbort); epicsThreadSleep(0.001);
         DSyAbort = 1; pvPut(DSyAbort); epicsThreadSleep(0.001);
         DSxAbort = 1; pvPut(DSxAbort); epicsThreadSleep(0.001);
         VFMAbort = 1; pvPut(VFMAbort); epicsThreadSleep(0.001);
         TBvAbort = 1; pvPut(TBvAbort); epicsThreadSleep(0.001);
         printf("vfmio: move_vfm: enabled all axis.\n");

         rqsMKys = preMKys; pvPut(rqsMKys); epicsThreadSleep(0.001);

         rqsDSxs = preDSxs; pvPut(rqsDSxs); epicsThreadSleep(0.001);
  DSyAuto = 1; pvPut(DSyAuto); epicsThreadSleep(0.1);
                rqsDSyc = runDSyc; pvPut(rqsDSyc); epicsThreadSleep(0.001);
         rqsDSys = preDSys; pvPut(rqsDSys); epicsThreadSleep(0.1);
  DSyStart = 1; pvPut(DSyStart); epicsThreadSleep(0.01);

    TBvAuto = 1; pvPut(TBvAuto); epicsThreadSleep(0.1);
         rqsTBa = runTBa; pvPut(rqsTBa); epicsThreadSleep(0.001);
         rqsTBh = runTBh; pvPut(rqsTBh); epicsThreadSleep(0.1);
    TBvStart = 1; pvPut(TBvStart); epicsThreadSleep(0.01);
  pvFlush();
         printf("vfmio: move_vfm: started moving MK, DS, TB.\n");

  rqsKBvy = runVFMh; pvPut(rqsKBvy); epicsThreadSleep(0.001);


        DTlpAuto = 1; pvPut(DTlpAuto); epicsThreadSleep(0.1);
        DTvAuto = 1; pvPut(DTvAuto); epicsThreadSleep(0.1);
        lpCorrOff = 0; pvPut(lpCorrOff); epicsThreadSleep(0.1);
        stCorrOff = 0; pvPut(stCorrOff); epicsThreadSleep(0.1);
               DTvdsOff = postDTvOff; pvPut(DTvdsOff); epicsThreadSleep(0.001);
        DTvCorAng = postDTvAng; pvPut(DTvCorAng); epicsThreadSleep(0.001);
        DTvCorSh = postDTvSh; pvPut(DTvCorSh); epicsThreadSleep(0.001);
        DTxRqs = 0.0; pvPut(DTxRqs); epicsThreadSleep(0.001);
               DThRqs = 0.0; pvPut(DThRqs); epicsThreadSleep(0.001);
               pvFlush();
        epicsThreadSleep(3);
        pvFlush();
         efClear(movevfm_f); epicsThreadSleep(0.001);
         efSet(postmove_f); epicsThreadSleep(0.001);
         printf("vfmio: move_vfm: leaving motion of everything.\n");
        } state move_vfm
  when (efTest(postmove_f) && MKRunPrg == 0 && DSyRunPrg == 0 && DSxRunPrg == 0 && TBvRunPrg == 0 && VFMRunPrg == 0 && DTlpRunPrg == 0 && DTvRunPrg == 0) {
        sprintf(msgQ, "DT corrections."); efSet(msg_f); epicsThreadSleep(0.001);
               printf("move_vfm: DT corrections.\n");
        TBvAuto = 0; pvPut(TBvAuto); epicsThreadSleep(0.001);
        lpCorrOff = 1; pvPut(lpCorrOff); epicsThreadSleep(0.1);
        stCorrOff = 1; pvPut(stCorrOff); epicsThreadSleep(0.1);
        DTlpAuto = 0; pvPut(DTlpAuto); epicsThreadSleep(0.1);
        DTvAuto = 0; pvPut(DTvAuto); epicsThreadSleep(0.1);
               DTlpAbort = 1; pvPut(DTlpAbort); epicsThreadSleep(0.1);
               DTvAbort = 1; pvPut(DTvAbort); epicsThreadSleep(0.1);
        epicsThreadSleep(1);
        DTdRqs = 700; pvPut(DTdRqs); epicsThreadSleep(0.001);
        epicsThreadSleep(1);
        efClear(postmove_f); epicsThreadSleep(0.001);
        efSet(finished_f); epicsThreadSleep(0.001);
        printf("vfmio: move_vfm: leaving post-move.\n");
  } state move_vfm
  when (delay(480)) {
        sprintf(msgQ, "**Timeout. Abort"); efSet(msg_f); epicsThreadSleep(0.001);
        printf("move_vfm: Timeout. Abort.\n");
        efClear(movevfm_f); epicsThreadSleep(0.001);
        efClear(postmove_f); epicsThreadSleep(0.001);
        efClear(finished_f); epicsThreadSleep(0.001);
        abortBtn = 1; pvPut(abortBtn); epicsThreadSleep(0.001);
  } state init2
  when(efTest(finished_f) && MKRunPrg == 0 && DSyRunPrg == 0 && DSxRunPrg == 0 && TBvRunPrg == 0 && VFMRunPrg == 0 && DTlpRunPrg == 0 && DTvRunPrg == 0) {
               vfmIOWrkng = 0; pvPut(vfmIOWrkng); epicsThreadSleep(0.001);
               epicsThreadSleep(0.001);
        DSyAuto = 0; pvPut(DSyAuto); epicsThreadSleep(0.001);
        TBvAuto = 0; pvPut(TBvAbort); epicsThreadSleep(0.001);
        DTlpAuto = 0; pvPut(DTlpAuto); epicsThreadSleep(0.001);
        DTvAuto = 0; pvPut(DTvAuto); epicsThreadSleep(0.001);
               epicsThreadSleep(0.001);
        efClear(finished_f); epicsThreadSleep(0.001);
        sprintf(msgQ, "Ready."); efSet(msg_f); epicsThreadSleep(0.001);
               printf("move_vfm: Move VFM finished. Ready.\n");
  } state init2
 when(efTest(fiundo_f) && MKRunPrg == 0 && DSyRunPrg == 0 && DSxRunPrg == 0 && TBvRunPrg == 0 && VFMRunPrg == 0 && DTlpRunPrg == 0 && DTvRunPrg == 0) {
               vfmIOWrkng = 0; pvPut(vfmIOWrkng); epicsThreadSleep(0.001);
       DSyAuto = 0; pvPut(DSyAuto); epicsThreadSleep(0.001);
       TBvAuto = 0; pvPut(TBvAbort); epicsThreadSleep(0.001);
  lpCorrOff = 1; pvPut(lpCorrOff); epicsThreadSleep(0.001);
  stCorrOff = 1; pvPut(stCorrOff); epicsThreadSleep(0.001);
    DTlpAuto = 0; pvPut(DTlpAuto); epicsThreadSleep(0.001);
    DTvAuto = 0; pvPut(DTvAuto); epicsThreadSleep(0.001);
                DTlpAbort = 1; pvPut(DTlpAbort); epicsThreadSleep(0.001);
                DTvAbort = 1; pvPut(DTvAbort); epicsThreadSleep(0.001);
                DThRqs = startDTh; pvPut(DThRqs); epicsThreadSleep(0.001);
         DTxRqs = startDTx; pvPut(DTxRqs); epicsThreadSleep(0.001);
         DTdRqs = startDTd; pvPut(DTdRqs); epicsThreadSleep(0.001);
        efClear(fiundo_f); epicsThreadSleep(0.001);
        sprintf(msgQ, "Undo finished. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
        printf("mntr: Undo finished. Ready.\n");
 } state init2
 when (efTest(undo_f) && undoBtn == 1) {
        printf("move_vfm: entering undo.\n");
               vfmIOWrkng = 1; pvPut(vfmIOWrkng); epicsThreadSleep(0.001);

        efClear(movevfm_f); epicsThreadSleep(0.001);
        efClear(postmove_f); epicsThreadSleep(0.001);
        efClear(finished_f); epicsThreadSleep(0.001);
        efClear(fiundo_f); epicsThreadSleep(0.001);
          vfmInBtn = 0; pvPut(vfmInBtn); epicsThreadSleep(0.001);
        efClear(vfmin_f); epicsThreadSleep(0.001);
          vfmOutBtn = 0; pvPut(vfmOutBtn); epicsThreadSleep(0.001);
        efClear(vfmout_f); epicsThreadSleep(0.001);
        abortBtn = 0; pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
        undoBtn = 0; pvPut(undoBtn); epicsThreadSleep(0.001); efClear(undo_f); epicsThreadSleep(0.001);
        epicsThreadSleep(0.001);

                MKvAbort = 1; pvPut(MKvAbort); epicsThreadSleep(0.001);
                DSyAbort = 1; pvPut(DSyAbort); epicsThreadSleep(0.001);
                DSxAbort = 1; pvPut(DSxAbort); epicsThreadSleep(0.001);
                VFMAbort = 1; pvPut(VFMAbort); epicsThreadSleep(0.001);
                TBvAbort = 1; pvPut(TBvAbort); epicsThreadSleep(0.001);
  epicsThreadSleep(0.001);

         attUnit = startAttUnit; pvPut(attUnit); epicsThreadSleep(0.001);
         attRqs = startAtt; pvPut(attRqs); epicsThreadSleep(0.001);

  rqsMKys = startMKys; pvPut(rqsMKys); epicsThreadSleep(0.001);
         rqsDSxs = startDSxs; pvPut(rqsDSxs); epicsThreadSleep(0.001);
         rqsKBvy = startVFMh; pvPut(rqsKBvy); epicsThreadSleep(0.001);

  DSyAuto = 1; pvPut(rqsDSxs); epicsThreadSleep(0.001);
                rqsDSyc = startDSyc; pvPut(rqsDSyc); epicsThreadSleep(0.001);
                rqsDSys = startDSys; pvPut(rqsDSys); epicsThreadSleep(0.001);
                epicsThreadSleep(0.001);
  DSyStart = 1; pvPut(DSyStart); epicsThreadSleep(0.001);

    TBvAuto = 1; pvPut(TBvAuto); epicsThreadSleep(0.001);
         rqsTBh = startTBh; pvPut(rqsTBh); epicsThreadSleep(0.001);
         rqsTBa = startTBa; pvPut(rqsTBa); epicsThreadSleep(0.001);
    TBvStart = 1; pvPut(TBvStart); epicsThreadSleep(0.001);

    DTlpAuto = 1; pvPut(DTlpAuto); epicsThreadSleep(0.001);
    DTvAuto = 1; pvPut(DTvAuto); epicsThreadSleep(0.001);
  lpCorrOff = 0; pvPut(lpCorrOff); epicsThreadSleep(0.001);
  stCorrOff = 0; pvPut(stCorrOff); epicsThreadSleep(0.001);
                epicsThreadSleep(0.001);
                DTvdsOff = startDTvOff; pvPut(DTvdsOff); epicsThreadSleep(0.001);
         DTvCorAng = startDTav; pvPut(DTvCorAng); epicsThreadSleep(0.001);
         DTvCorSh = startDTsv; pvPut(DTvCorSh); epicsThreadSleep(0.001);
  epicsThreadSleep(3);
        sprintf(msgQ, "Undo in progress."); efSet(msg_f); epicsThreadSleep(0.001);
        printf("move_vfm: Undo in progress.\n");
        printf("move_vfm: leaving undo.\n");
        efSet(fiundo_f); epicsThreadSleep(0.001);
 } state move_vfm
    }
}
