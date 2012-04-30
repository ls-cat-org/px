# 1 "../fdbk_server.st"
# 1 "<built-in>"
# 1 "<command line>"
# 1 "../fdbk_server.st"
program fdbk_server("coioc=21linux, calcrec=21:D1:2:userCalc, detnm=21:D1:scaler1")

option +r;

%%#include <string.h>
%%#include <math.h>
%%#include <tsDefs.h>
# 1 "../fdbk_server.h" 1
# 11 "../fdbk_server.h"
%%TS_STAMP tmc;

char time_str[80];

int status;
int msgI;
int i;
int j;
int line;
int stFactor[3];

double pzStepTimesEn;
double curEn;
double fdbkEn;
double minerror;

double actTheta;
double maxTheta;
double maxCnts;
double maxInt;
double cnts;
double step;
double pzStep;
double urad2deg;

int stopStartBtn; assign stopStartBtn to "{coioc}:fdbk:StopStart"; monitor stopStartBtn; evflag stopstart_f; sync stopStartBtn stopstart_f;
int intPosMenu; assign intPosMenu to "{coioc}:fdbk:IntPos"; monitor intPosMenu; evflag intpos_f; sync intPosMenu intpos_f;
int monoMirMenu; assign monoMirMenu to "{coioc}:fdbk:MonoMir"; monitor monoMirMenu; evflag monomir_f; sync monoMirMenu monomir_f;
int offOnPIDMenu; assign offOnPIDMenu to "{coioc}:fdbk:OffOnPID"; monitor offOnPIDMenu; evflag offonpid_f; sync offOnPIDMenu offonpid_f;
int cleanBtn; assign cleanBtn to "{coioc}:fdbk:Clean"; monitor cleanBtn; evflag clean_f; sync cleanBtn clean_f;
int fdbkWrkng; assign fdbkWrkng to "{coioc}:fdbk:fdbkWrkng"; monitor fdbkWrkng;

double pzScale; assign pzScale to "{coioc}:fdbk:PZscale"; monitor pzScale;
double fwhmStepMin; assign fwhmStepMin to "{coioc}:fdbk:FWHMstep"; monitor fwhmStepMin;
int stFactor1; assign stFactor1 to "{coioc}:fdbk:StFactor1"; monitor stFactor1;
int stFactor2; assign stFactor2 to "{coioc}:fdbk:StFactor2"; monitor stFactor2;
int stFactor3; assign stFactor3 to "{coioc}:fdbk:StFactor3"; monitor stFactor3;

int chEnWrkng; assign chEnWrkng to "{coioc}:mono:ChEnWrkng"; monitor chEnWrkng;
int centrWrkng; assign centrWrkng to "{coioc}:mono:CentrWrkng"; monitor centrWrkng;


double curTheta; assign curTheta to "c3ioc:rmm01:ana01:ao01.VAL"; monitor curTheta;


double detCnts; assign detCnts to "{calcrec}2.VAL"; monitor detCnts;
double bpmY; assign bpmY to "{calcrec}4.VAL"; monitor bpmY;
double bpmX; assign bpmX to "{calcrec}5.VAL"; monitor bpmX;
int detMode; assign detMode to "{detnm}.CONT"; monitor detMode;
# 81 "../fdbk_server.h"
double ringCur; assign ringCur to "S:SRcurrentAI"; monitor ringCur;
double topUpTime; assign topUpTime to "Mt:TopUpTime2Inject"; monitor topUpTime;
int FESclosed; assign FESclosed to "PC:21ID:STA_A_SHUTTER_CLOSED"; monitor FESclosed;
int DSHclosed; assign DSHclosed to "PC:21ID:STA_D_SHUTTER_CLOSED"; monitor DSHclosed;


double actEnID; assign actEnID to "ID21us:Energy.VAL"; monitor actEnID;
int IDstatus; assign IDstatus to "ID21us:Busy.VAL"; monitor IDstatus;


long VFMRunPrg; assign VFMRunPrg to "21:D1:KB:Vx:RunPrg"; monitor VFMRunPrg;
long HFMRunPrg; assign HFMRunPrg to "21:D1:KB:Hy:RunPrg"; monitor HFMRunPrg;


double actEn; assign actEn to "21:C1:MO:E:ActPos"; monitor actEn;
double rqsPosEn; assign rqsPosEn to "21:C1:MO:E:RqsPos"; monitor rqsPosEn;
long EnAbort; assign EnAbort to "21:C1:MO:En:Abort"; monitor EnAbort;
long EnKill; assign EnKill to "21:C1:MO:En:Kill"; monitor EnKill;

long EnRunPrg; assign EnRunPrg to "21:C1:MO:En:RunPrg"; monitor EnRunPrg;
int flScanBusy; assign flScanBusy to "21:D1:scan4.BUSY"; monitor flScanBusy;


double actPitch; assign actPitch to "21:C1:MO:P2:ActPos"; monitor actPitch;
double rqsPitch; assign rqsPitch to "21:C1:MO:P2:RqsPos"; monitor rqsPitch;
long piAbort; assign piAbort to "21:C1:MO:Tn:Abort"; monitor piAbort;
long piKill; assign piKill to "21:C1:MO:Tn:Kill"; monitor piKill;

long piRunPrg; assign piRunPrg to "21:C1:MO:Tn:RunPrg"; monitor piRunPrg;



string msgQ;
string msg[10]; assign msg[0] to "{coioc}:fdbk:Msg9";
        assign msg[1] to "{coioc}:fdbk:Msg8";
                      assign msg[2] to "{coioc}:fdbk:Msg7";
                      assign msg[3] to "{coioc}:fdbk:Msg6";
                      assign msg[4] to "{coioc}:fdbk:Msg5";
                      assign msg[5] to "{coioc}:fdbk:Msg4";
                      assign msg[6] to "{coioc}:fdbk:Msg3";
                      assign msg[7] to "{coioc}:fdbk:Msg2";
                      assign msg[8] to "{coioc}:fdbk:Msg1";
                      assign msg[9] to "{coioc}:fdbk:Msg0";
evflag msg_f;
evflag pause_f;
evflag fdbk_f;
evflag fdbk_run_f;
evflag setpoint_locked_f;
evflag waitfor_ringCur_f;
evflag waitfor_topUp_f;
evflag waitfor_FES_f;
evflag waitfor_DSH_f;
evflag waitfor_ID_f;
evflag waitfor_mono_f;
evflag waitfor_center_f;
evflag waitfor_detMode_f;
evflag waitfor_detCnts_f;
# 9 "../fdbk_server.st" 2

ss setA {
    state init {
   when() {

        status = 0; curEn = 0.0; fdbkEn = 0.0; minerror = 0.0;
        actTheta = 0.0; maxTheta = 0.0; maxCnts = 0.0; step = 0.0;
               line = 0;

         stopStartBtn = 0; pvPut(stopStartBtn); epicsThreadSleep(0.001);

       fdbkWrkng = 0; pvPut(fdbkWrkng); epicsThreadSleep(0.001);
       intPosMenu = 0; pvPut(intPosMenu); epicsThreadSleep(0.001);
         monoMirMenu = 0; pvPut(monoMirMenu); epicsThreadSleep(0.001);
         offOnPIDMenu = 0; pvPut(offOnPIDMenu); epicsThreadSleep(0.001);
       efClear(fdbk_f); epicsThreadSleep(0.001);
          efClear(fdbk_run_f); epicsThreadSleep(0.001);

       pzStepTimesEn = 0.1; pzStep = 0.0; urad2deg = 5.73e-5;
       fwhmStepMin = 0.02; pvPut(fwhmStepMin); epicsThreadSleep(0.001);
       pzScale = 73.2; pvPut(pzScale); epicsThreadSleep(0.001);

       stFactor1 = 2; pvPut(stFactor1); epicsThreadSleep(0.001);
       stFactor2 = 1; pvPut(stFactor2); epicsThreadSleep(0.001);
              stFactor3 = 1; pvPut(stFactor3); epicsThreadSleep(0.001);

       efClear (clean_f); epicsThreadSleep(0.001); msgI = 9;
       sprintf(msgQ, "Server ready."); efSet(msg_f); epicsThreadSleep(0.001);
       printf("fdbk:init:Feedback server ready.\n");
          } state mntr
    }
    state mntr {
 when (efTestAndClear(msg_f)) {
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
        } state mntr
 when(efTestAndClear(stopstart_f) && stopStartBtn == 0 ) {
       sprintf(msgQ, "Feedback stopped."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: Feedback stopped.\n");
       fdbkWrkng = 0; pvPut(fdbkWrkng); epicsThreadSleep(0.001);
       efSet(pause_f); epicsThreadSleep(0.001);
              efClear(fdbk_f); epicsThreadSleep(0.001);
              efClear(fdbk_run_f); epicsThreadSleep(0.001);
       efClear(setpoint_locked_f); epicsThreadSleep(0.001);
              efClear(waitfor_ringCur_f); epicsThreadSleep(0.001);
       efClear(waitfor_topUp_f); epicsThreadSleep(1.0);
              efClear(waitfor_FES_f); epicsThreadSleep(0.001);
              efClear(waitfor_DSH_f); epicsThreadSleep(0.001);
              efClear(waitfor_ID_f); epicsThreadSleep(0.001);
              efClear(waitfor_mono_f); epicsThreadSleep(0.001);
              efClear(waitfor_detMode_f); epicsThreadSleep(0.001);
              efClear(waitfor_detCnts_f); epicsThreadSleep(0.001);
        efClear(stopstart_f); epicsThreadSleep(0.001);
 } state mntr
 when(stopStartBtn == 1 && ringCur < 60.0) {

       sprintf(msgQ, "**RingCurr low, pause"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: Ring current is low - pause.\n");
       efSet(pause_f); epicsThreadSleep(0.001);
       efClear(fdbk_f); epicsThreadSleep(0.001);
              efClear(fdbk_run_f); epicsThreadSleep(0.001);
       efSet(waitfor_ringCur_f); epicsThreadSleep(0.001);
 } state waitforsmth
 when(stopStartBtn == 1 && topUpTime < 5.0) {

       sprintf(msgQ, "**Injection, pause"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: Injection - pause.\n");
       efSet(pause_f); epicsThreadSleep(0.001);
       efClear(fdbk_f); epicsThreadSleep(0.001);
              efClear(fdbk_run_f); epicsThreadSleep(0.001);
       efSet(waitfor_topUp_f); pvFlush();
 } state waitforsmth
 when(stopStartBtn == 1 && FESclosed == 1) {
       sprintf(msgQ, "**FES closed, pause."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: FES closed - pause.\n");
       efSet(pause_f); epicsThreadSleep(0.001);
       efClear(fdbk_f); epicsThreadSleep(0.001);
              efClear(fdbk_run_f); epicsThreadSleep(0.001);
       efSet(waitfor_FES_f); epicsThreadSleep(0.001);
 } state waitforsmth
 when(stopStartBtn == 1 && DSHclosed == 1) {
       sprintf(msgQ, "**D-shut closed, pause."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: D-shutter closed - pause.\n");
       efSet(pause_f); epicsThreadSleep(0.001);
       efClear(fdbk_f); epicsThreadSleep(0.001);
              efClear(fdbk_run_f); epicsThreadSleep(0.001);
       efSet(waitfor_DSH_f); epicsThreadSleep(0.001);
 } state waitforsmth
 when(stopStartBtn == 1 && (IDstatus == 1 || (actEnID - actEn) > 0.5)) {
       sprintf(msgQ, "**ID moving or off"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr:ID moving or offset is wrong - pause\n");
              efSet(pause_f); epicsThreadSleep(0.001);
       efClear(fdbk_f); epicsThreadSleep(0.001);
              efClear(fdbk_run_f); epicsThreadSleep(0.001);
       efSet(waitfor_ID_f); epicsThreadSleep(0.001);
        } state waitforsmth
 when(stopStartBtn == 1 && (chEnWrkng == 1 || EnRunPrg == 1 || piRunPrg == 1 || flScanBusy == 1)) {
       sprintf(msgQ, "**Energy change, pause"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: Energy changing - pause\n");
              efSet(pause_f); epicsThreadSleep(0.001);
       efClear(fdbk_f); epicsThreadSleep(0.001);
              efClear(fdbk_run_f); epicsThreadSleep(0.001);
       efSet(waitfor_mono_f); epicsThreadSleep(0.001);
        } state waitforsmth
 when(stopStartBtn == 1 && centrWrkng == 1) {
       sprintf(msgQ, "**Beam cntrng, pause"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: Energy changing - pause\n");
              efSet(pause_f); epicsThreadSleep(0.001);
       efClear(fdbk_f); epicsThreadSleep(0.001);
              efClear(fdbk_run_f); epicsThreadSleep(0.001);
       efSet(waitfor_center_f); epicsThreadSleep(0.001);
        } state waitforsmth
 when(stopStartBtn == 1 && detMode == 0) {
       sprintf(msgQ, "**Wrong Joerger mode"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: Wrong Joerger mode. \n");
       efSet(pause_f); epicsThreadSleep(0.001);
       efClear(fdbk_f); epicsThreadSleep(0.001);
              efClear(fdbk_run_f); epicsThreadSleep(0.001);
       efSet(waitfor_detMode_f); epicsThreadSleep(0.001);
 } state waitforsmth
 when(stopStartBtn == 1 && detCnts < 500) {
       sprintf(msgQ, "**Beam lost, pause"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: Beam is lost - stop.\n");
       efSet(pause_f); epicsThreadSleep(0.001);
       efClear(fdbk_f); epicsThreadSleep(0.001);
              efClear(fdbk_run_f); epicsThreadSleep(0.001);
       efSet(waitfor_detCnts_f); epicsThreadSleep(0.001);
 } state waitforsmth
 when(stopStartBtn == 1 && !efTest(fdbk_f) && !efTest(fdbk_run_f)) {
        efClear(stopstart_f); epicsThreadSleep(0.001);
       fdbkEn = actEn; epicsThreadSleep(0.001);
       sprintf(msgQ, "Lock En=%2.3f", fdbkEn); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: Lock En=%2.5f \n", fdbkEn);
       efClear(pause_f); epicsThreadSleep(0.001);
       efSet(fdbk_f); epicsThreadSleep(0.001);
 } state mntr
 when (efTestAndClear(clean_f)) {
         for(i=9; i>=0; i--) {
             strcpy (msg[i], ""); pvPut(msg[i]); epicsThreadSleep(0.001);
         }
         strcpy (msg[9], "Ready"); pvPut(msg[9]); epicsThreadSleep(0.001); msgI = 9;
         cleanBtn = 0; pvPut(cleanBtn); epicsThreadSleep(0.001); efClear(clean_f); epicsThreadSleep(0.001);
        } state mntr
    }
    state waitforsmth {
 when (efTestAndClear(msg_f)) {
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
        } state waitforsmth
 when(efTest(stopstart_f) && stopStartBtn == 0 ) {
       sprintf(msgQ, "Feedback stopped."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: Feedback stopped.\n");
       efSet(pause_f); epicsThreadSleep(0.001);
              efClear(fdbk_f); epicsThreadSleep(0.001);
              efClear(fdbk_run_f); epicsThreadSleep(0.001);
       efClear(setpoint_locked_f); epicsThreadSleep(0.001);
              efClear(waitfor_ringCur_f); epicsThreadSleep(0.001);
       efClear(waitfor_topUp_f); epicsThreadSleep(1.0);
              efClear(waitfor_FES_f); epicsThreadSleep(0.001);
              efClear(waitfor_DSH_f); epicsThreadSleep(0.001);
              efClear(waitfor_ID_f); epicsThreadSleep(0.001);
              efClear(waitfor_mono_f); epicsThreadSleep(0.001);
              efClear(waitfor_detMode_f); epicsThreadSleep(0.001);
              efClear(waitfor_detCnts_f); epicsThreadSleep(0.001);
        efClear(stopstart_f); epicsThreadSleep(0.001);
 } state mntr
 when(efTest(waitfor_ringCur_f) && stopStartBtn == 1 && ringCur > 60.0) {
       sprintf(msgQ, "Ring current good."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: Ring current is good.\n");
       efClear(waitfor_ringCur_f); epicsThreadSleep(0.001);
        } state mntr
 when(efTest(waitfor_topUp_f) && stopStartBtn == 1 && topUpTime > 5.0) {
       sprintf(msgQ, "Injection completed."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: Injection completed.\n");
       efClear(waitfor_topUp_f); epicsThreadSleep(1.0);
        } state mntr
 when(efTest(waitfor_FES_f) && stopStartBtn == 1 && FESclosed == 0) {
       sprintf(msgQ, "FES is opened."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: FES is opened.\n");
       efClear(waitfor_FES_f); epicsThreadSleep(0.001);
        } state mntr
 when(efTest(waitfor_DSH_f) && stopStartBtn == 1 && DSHclosed == 0) {
       sprintf(msgQ, "DSH is opened."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: DSH is opened.\n");
       efClear(waitfor_DSH_f); epicsThreadSleep(0.001);
        } state mntr
 when(efTest(waitfor_ID_f) && stopStartBtn == 1 && IDstatus == 0 && (actEnID - actEn) < 0.5) {
       sprintf(msgQ, "ID  is OK."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: ID  is OK.\n");
       efClear(waitfor_ID_f); epicsThreadSleep(0.001);
        } state mntr
 when(efTest(waitfor_mono_f) && stopStartBtn == 1 && chEnWrkng == 0 && EnRunPrg == 0 && piRunPrg == 0 && flScanBusy == 0) {
       pvGet(actEn); epicsThreadSleep(0.001); fdbkEn = actEn;
       sprintf(msgQ, "En=%2.3f Pt=%1.5f", fdbkEn, actPitch); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state waitfor_mono: Changed En=%2.5f.\n", fdbkEn);
       efClear(waitfor_mono_f); epicsThreadSleep(0.001);
        } state mntr
 when(efTest(waitfor_center_f) && stopStartBtn == 1 && centrWrkng == 0) {
       pvGet(actEn); epicsThreadSleep(0.001); fdbkEn = actEn;
       sprintf(msgQ, "Done with cntrng"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state waitfor_mono: Done with centering.\n", fdbkEn);
       efClear(waitfor_center_f); epicsThreadSleep(0.001);
        } state mntr
 when(efTest(waitfor_detMode_f) && stopStartBtn == 1 && detMode == 1) {
       sprintf(msgQ, "Joerger mode OK"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: Joerger mode OK.\n");
       efClear(waitfor_detMode_f); epicsThreadSleep(0.001);
        } state mntr
 when(efTest(waitfor_detCnts_f) && stopStartBtn == 1 && detCnts > 500) {
       sprintf(msgQ, "Beam intensity OK"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:state mntr: Beam intensity OK.\n");
       efClear(waitfor_detCnts_f); epicsThreadSleep(0.001);
        } state mntr
   }
}

ss setB {
    state initfdbk {
 when (efTestAndClear(msg_f)) {
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
        } state initfdbk
 when (efTest(pause_f)) {
       sprintf(msgQ, "Init state, pause."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:initfdbk: Pause.\n");

              efClear(fdbk_f); epicsThreadSleep(0.001);
              efClear(pause_f); epicsThreadSleep(0.001);
       fdbkWrkng = 0; pvPut(fdbkWrkng); epicsThreadSleep(0.001);
        } state initfdbk
        when (efTest(fdbk_f) && intPosMenu == 0 && offOnPIDMenu == 0 && monoMirMenu == 0) {

        detMode = 1; pvPut(detMode); epicsThreadSleep(0.001);


        pzStepTimesEn = (400.0 * fwhmStepMin)/(pzScale * 2.3548);
        pzStep = pzStepTimesEn/fdbkEn;
        stFactor[0] = stFactor1; stFactor[1] = stFactor2; stFactor[2] = stFactor3;
               maxCnts = 0; line = 0;
           for(i = 0; i < 2; i++) {
     pvGet(curTheta); epicsThreadSleep(0.001); maxTheta = curTheta;
            step = pzStep * stFactor[i];
                   maxCnts = 0; line = 0;
   %% do {
         cnts = 0;
         for (j=0; j<3; j++) {
                           epicsThreadSleep(0.2);
                           pvGet(detCnts); epicsThreadSleep(0.001);
                           cnts = cnts + detCnts;
                       }
         cnts = cnts/3.0; epicsThreadSleep(0.2);
         pvGet(curTheta); epicsThreadSleep(0.001);
                printf("fdbk:initfdbk: line=%d, step=%f, curTheta=%f, cnts=%f.\n", line, step, curTheta, cnts);
         if(cnts >= maxCnts) { maxTheta = curTheta; maxCnts = cnts; }
         else {
                  if(line == 1) { step = -step; maxCnts = 0; printf("fdbk:initfdbk: Reverse direction.\n"); }
                  else { printf("fdbk:initfdbk: Maximum is found.\n"); break; }
         }
         line++;
         curTheta += step;
         if(curTheta < -4.9 || curTheta > 4.9) {
                      printf("fdbk:initfdbk: piezo is out of range: curTheta=%f.\n", curTheta);

       actTheta = curTheta - step;
       rqsPitch = actPitch - actTheta * pzScale * urad2deg;
                            pvPut(rqsPitch); epicsThreadSleep(0.001);
       curTheta = 0;
         }
                printf("fdbk:initfdbk: curTheta=%f.\n",curTheta);
         pvPut(curTheta); epicsThreadSleep(0.001);
         if(cnts < 500 || efTest(pause_f)) {
                             printf("fdbk:initfdbk: MININT reached or Pause caught. Break the do-loop.\n");
               efSet(pause_f); epicsThreadSleep(0.001);
               efClear(fdbk_f); epicsThreadSleep(0.001);
                             break;
                       }
%% } while(1);
     if(cnts < 500 || efTest(pause_f)) {
                         printf("fdbk:initfdbk: MININT reached or Pause caught. Break the for-loop.\n");
           efSet(pause_f); epicsThreadSleep(0.001);
           efClear(fdbk_f); epicsThreadSleep(0.001);
                         break;
                   }
                   else {
                curTheta = maxTheta - 10.0 * step;
                if(curTheta < -4.9 || curTheta > 4.9) { pvPut(curTheta); epicsThreadSleep(0.001); }
                curTheta = maxTheta; pvPut(curTheta); epicsThreadSleep(0.001);
         maxInt = maxCnts;
                sprintf(msgQ, "Lock maxI=%7.0f", maxInt); efSet(msg_f); epicsThreadSleep(0.001);
                       printf("fdbk:initfdbk: maxInt found: i=%d,  maxInt=%f, maxTheta=%f.\n", i, maxInt, maxTheta);
                efSet(setpoint_locked_f); epicsThreadSleep(0.001);
                efSet(fdbk_run_f); epicsThreadSleep(0.001);
     }
             }
        efClear(fdbk_f); epicsThreadSleep(0.001);
 } state fdbk_run
        when (efTest(fdbk_f) && intPosMenu == 0 && offOnPIDMenu == 1 && monoMirMenu == 0) {
# 352 "../fdbk_server.st"
       sprintf(msgQ, "Option unavailable"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:fdbk_run: Intensity/PID fdbk unavailable. Stop.\n");
       efClear(fdbk_f); epicsThreadSleep(0.001);


              efSet(pause_f); epicsThreadSleep(0.001);
 } state fdbk_run
        when (efTest(fdbk_f) && intPosMenu == 1 && offOnPIDMenu == 1 && monoMirMenu == 1) {
# 373 "../fdbk_server.st"
       sprintf(msgQ, "Option unavailable"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("fdbk:fdbk_run: Y-Pos/PID fdbk unavailable. Stop.\n");
       efClear(fdbk_f); epicsThreadSleep(0.001);


              efSet(pause_f); epicsThreadSleep(0.001);
 } state fdbk_run
    }
    state fdbk_run {
 when (efTestAndClear(msg_f)) {
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
        } state fdbk_run
 when (efTest(pause_f)) {

              printf("fdbk:fdbk_run: Pause.\n");

              efClear(fdbk_run_f); epicsThreadSleep(0.001);
              efClear(pause_f); epicsThreadSleep(0.001);
              fdbkWrkng = 0; pvPut(fdbkWrkng); epicsThreadSleep(0.001);
        } state initfdbk
 when (efTest(fdbk_run_f) && intPosMenu == 0 && offOnPIDMenu == 0 && monoMirMenu == 0) {
      fdbkWrkng = 1; pvPut(fdbkWrkng); epicsThreadSleep(0.001);

      pvGet(curTheta); epicsThreadSleep(0.001); maxTheta = curTheta;
      step = pzStep; maxCnts = 0; line = 0;
    %% do {
   cnts = 0;
   for (j=0; j<10; j++) {
                       epicsThreadSleep(0.2);
                       pvGet(detCnts); epicsThreadSleep(0.001);
                       cnts = cnts + detCnts;
                 }
   cnts = cnts/10.0; epicsThreadSleep(0.2);
   pvGet(curTheta); epicsThreadSleep(0.001);
          printf("fdbk:fdbk_run: line=%d, step=%f, curTheta=%f, cnts=%f.\n", line, step, curTheta, cnts);
   if(cnts >= maxCnts) { maxTheta = curTheta; maxCnts = cnts; }
   else {
        if(line == 1) { step = -step; maxCnts = 0; printf("fdbk:fdbk_run: Reverse direction.\n");}
        else { printf("fdbk:fdbk_run: Optimization finished.\n"); break; }
   }
   line++;

   curTheta += step;
   if (curTheta < -4.9 || curTheta > 4.9) {
              sprintf(msgQ, "**Piezo out of range"); efSet(msg_f); epicsThreadSleep(0.001);
                     printf("fdbk:fdbk_run: **Theta out of range. Stop.\n");

                     efClear(fdbk_run_f); epicsThreadSleep(0.001);
                     efSet(pause_f); epicsThreadSleep(0.001);
       break;
   }
          printf("fdbk:fdbk_run: curTheta=%f.\n",curTheta);
          pvPut(curTheta); epicsThreadSleep(0.001);
   if(cnts < 500 || efTest(pause_f)) {
                sprintf(msgQ, "Break the loop"); efSet(msg_f); epicsThreadSleep(0.001);
                       printf("fdbk:fdbk_run: MININT reached or Pause caught. Break the do-loop.\n");
         efSet(pause_f); epicsThreadSleep(0.001);
         efClear(fdbk_run_f); epicsThreadSleep(0.001);
                       break;
                 }

%% } while(1);
             printf("fdbk:fdbk_run: Exit the loop. i=%d theta=%f.\n", i, maxTheta);
      curTheta = maxTheta - 2.0 * step;
      if(curTheta < -4.9 || curTheta > 4.9) { pvPut(curTheta); epicsThreadSleep(0.001); }
      curTheta = maxTheta; pvPut(curTheta); epicsThreadSleep(0.001);
        } state fdbk_run
   }
 }