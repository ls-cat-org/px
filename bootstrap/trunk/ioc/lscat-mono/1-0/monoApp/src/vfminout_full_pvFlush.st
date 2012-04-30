program vfminout("coioc=21linux")

option +r;
option +a;

%%#include <string.h>
%%#include <math.h>
%%#include <tsDefs.h>	/* defenition for TS_STAMP, tsLocalTime()  */
#include "vfminout.h"

ss setQ {
    state init {
	  when() {
	      /* New numbers will come from  Autosave at IOC reboot */
              printf("Init state.\n");
 	      vfmIOWrkng  = 0;      pvPut(vfmIOWrkng);  epicsThreadSleep(0.001);
	/*    07.07.2010           */
	/*    attIn   = 50;        */
	/*    attOut  = 1;         */
	/*    dsHi    = 5.340;     */
	/*    dsHo    = -3.110;    */
	/*    tbHi    = 8.723;     */
	/*    tbHo    = -13.427;   */
	/*    tbAi    = 6.1;       */
	/*    tbAo    = 0;         */
	/*    vfmHi   = 0.6;       */
	/*    vfmHo   = 4;         */
	/*    dtOfIn  = 207.658;   */
	/*    dtOfOut = 208.567;   */
	/*    dtAnIn  = 3.626;     */
	/*    dtAnOut = 0.626;     */
	/*    dtShIn  = 21.744;    */
	/*    dtShOut = -1.4;      */
	      efClear (clean_f);      epicsThreadSleep(0.001);   msgI = 9;
  	      vfmInBtn = 0;           pvPut(vfmInBtn);           epicsThreadSleep(0.001);
	      efClear(vfmin_f);       epicsThreadSleep(0.001);
  	      vfmOutBtn = 0;          pvPut(vfmOutBtn);          epicsThreadSleep(0.001);
	      efClear(vfmout_f);      epicsThreadSleep(0.001);
  	      abortBtn = 0;   	      pvPut(abortBtn);           epicsThreadSleep(0.001);
	      efClear(abort_f);       epicsThreadSleep(0.001);
	      efClear(movevfm_f);     epicsThreadSleep(0.001);
              efClear(postmove_f);    epicsThreadSleep(0.001);
	      efClear(finished_f);    epicsThreadSleep(0.001);
	      efClear(fiundo_f);      epicsThreadSleep(0.001);
	      sprintf(msgQ,"Ready."); efSet(msg_f);              epicsThreadSleep(0.001);
          } state mntr
    }

    state mntr {
	when (efTestAndClear(msg_f)) {
	  printf("state mntr: entering msg.\n");
%%        tsLocalTime(&tmc);
%%        tsStampToText (&tmc, TS_TEXT_MMDDYY, pVar->time_str);
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
	      MKvAbort = 1;    pvPut(MKvAbort);    epicsThreadSleep(0.001);
	      DSyAbort = 1;    pvPut(DSyAbort);    epicsThreadSleep(0.001);
	      DSxAbort = 1;    pvPut(DSxAbort);    epicsThreadSleep(0.001);
	      VFMAbort = 1;    pvPut(VFMAbort);    epicsThreadSleep(0.001);
	      TBvAbort = 1;    pvPut(TBvAbort);    epicsThreadSleep(0.001);
	      DTlpAbort = 1;   pvPut(DTlpAbort);   epicsThreadSleep(0.001);
	      DTvAbort = 1;    pvPut(DTvAbort);    epicsThreadSleep(0.001);
              pvFlush();
	      DTlpAuto  = 0;   pvPut(DTlpAuto);    epicsThreadSleep(0.001);
	      DTvAuto   = 0;   pvPut(DTvAuto);     epicsThreadSleep(0.001);
	      DSyAuto   = 0;   pvPut(DSyAuto);     epicsThreadSleep(0.001);
	      TBvAuto   = 0;   pvPut(TBvAbort);    epicsThreadSleep(0.001);
	      DTlpAuto  = 0;   pvPut(DTlpAuto);    epicsThreadSleep(0.001);
	      DTvAuto   = 0;   pvPut(DTvAuto);     epicsThreadSleep(0.001);
              pvFlush();
	      sprintf(msgQ, "**Job aborted. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
	      printf("state mntr: **Job is aborted. Ready.\n");
	      efClear(movevfm_f);  epicsThreadSleep(0.001);
	      efClear(postmove_f); epicsThreadSleep(0.001);
	      efClear(finished_f); epicsThreadSleep(0.001);
	      efClear(fiundo_f);    epicsThreadSleep(0.001);
  	      vfmInBtn = 0;           pvPut(vfmInBtn);           epicsThreadSleep(0.001);
	      efClear(vfmin_f);       epicsThreadSleep(0.001);
  	      vfmOutBtn = 0;          pvPut(vfmOutBtn);          epicsThreadSleep(0.001);
	      efClear(vfmout_f);      epicsThreadSleep(0.001);
	      abortBtn = 0;  pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
	      vfmIOWrkng = 0;  pvPut(vfmIOWrkng);  epicsThreadSleep(0.001);
              printf("state mntr: leaving abort.\n");
	} state mntr
	when(((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && chEnWrkng == 1) {
	      sprintf(msgQ,  "**Change-Energy working."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state mntr: Change-Energy working.\n");
	      vfmInBtn = 0;  pvPut(vfmInBtn);  epicsThreadSleep(0.001);
	      efClear(vfmin_f); epicsThreadSleep(0.001);
	      vfmOutBtn = 0;  pvPut(vfmOutBtn);  epicsThreadSleep(0.001);
	      efClear(vfmout_f); epicsThreadSleep(0.001);
	} state mntr
	when (((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && centrWrkng == 1) {
	      sprintf(msgQ,  "**Center-Beam working."); efSet(msg_f); epicsThreadSleep(0.001);
	      printf("state mntr: Center-Beam script is working.\n");
	      vfmInBtn = 0;  pvPut(vfmInBtn);  epicsThreadSleep(0.001);
	      efClear(vfmin_f); epicsThreadSleep(0.001);
	      vfmOutBtn = 0;  pvPut(vfmOutBtn);  epicsThreadSleep(0.001);
	      efClear(vfmout_f); epicsThreadSleep(0.001);
	} state mntr
	when (((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && MKRunPrg == 1) {
	      sprintf(msgQ,  "**Masks moving."); efSet(msg_f); epicsThreadSleep(0.001);
	      printf("state mntr: Masks moving.\n");
	      vfmInBtn = 0;  pvPut(vfmInBtn);  epicsThreadSleep(0.001);
	      efClear(vfmin_f); epicsThreadSleep(0.001);
	      vfmOutBtn = 0;  pvPut(vfmOutBtn);  epicsThreadSleep(0.001);
	      efClear(vfmout_f); epicsThreadSleep(0.001);
	} state mntr
	when (((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && (DSyRunPrg == 1 || DSxRunPrg == 1)) {
	      sprintf(msgQ,  "**DS slit moving."); efSet(msg_f); epicsThreadSleep(0.001);
	      printf("state mntr: DS slit moving.\n");
	      vfmInBtn = 0;  pvPut(vfmInBtn);  epicsThreadSleep(0.001);
	      efClear(vfmin_f); epicsThreadSleep(0.001);
	      vfmOutBtn = 0;  pvPut(vfmOutBtn);  epicsThreadSleep(0.001);
	      efClear(vfmout_f); epicsThreadSleep(0.001);
	} state mntr
	when (((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && VFMRunPrg == 1) {
	      sprintf(msgQ,  "**VFM moving."); efSet(msg_f); epicsThreadSleep(0.001);
	      printf("state mntr: VFM moving.\n");
	      vfmInBtn = 0;  pvPut(vfmInBtn);  epicsThreadSleep(0.001);
	      efClear(vfmin_f); epicsThreadSleep(0.001);
	      vfmOutBtn = 0;  pvPut(vfmOutBtn);  epicsThreadSleep(0.001);
	      efClear(vfmout_f); epicsThreadSleep(0.001);
	} state mntr
	when (((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && TBvRunPrg == 1) {
	      sprintf(msgQ,  "**MD2 Table moving."); efSet(msg_f); epicsThreadSleep(0.001);
	      printf("state mntr: MD2 Table moving.\n");
	      vfmInBtn = 0;  pvPut(vfmInBtn);  epicsThreadSleep(0.001);
	      efClear(vfmin_f); epicsThreadSleep(0.001);
	      vfmOutBtn = 0;  pvPut(vfmOutBtn);  epicsThreadSleep(0.001);
	      efClear(vfmout_f); epicsThreadSleep(0.001);
	} state mntr
	when (((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) && (DTvRunPrg == 1 || DTlpRunPrg == 1)) {
	      sprintf(msgQ,  "**Detector moving."); efSet(msg_f); epicsThreadSleep(0.001);
	      printf("state mntr: Detector moving.\n");
	      vfmInBtn = 0;  pvPut(vfmInBtn);  epicsThreadSleep(0.001);
	      efClear(vfmin_f); epicsThreadSleep(0.001);
	      vfmOutBtn = 0;  pvPut(vfmOutBtn);  epicsThreadSleep(0.001);
	      efClear(vfmout_f); epicsThreadSleep(0.001);
	} state mntr
	when ((efTest(vfmin_f) && vfmInBtn == 1) || (efTest(vfmout_f) && vfmOutBtn == 1)) {
	      /* save parameters for undo-prg to use */
	      pvGet(attUnit);    epicsThreadSleep(0.001);    startAttUnit = attUnit;
	      pvGet(attAct);     epicsThreadSleep(0.001);    startAtt  =  attAct;
	      pvGet(actMKys);    epicsThreadSleep(0.001);    startMKys = actMKys;
              pvGet(actDSyc);    epicsThreadSleep(0.001);    startDSyc = actDSyc;
	      pvGet(actDSys);    epicsThreadSleep(0.001);    startDSys = actDSys;
	      pvGet(actDSxs);    epicsThreadSleep(0.001);    startDSxs = actDSxs;
	      pvGet(actKBvy);    epicsThreadSleep(0.001);    startVFMh = actKBvy;
	      pvGet(actTBh);     epicsThreadSleep(0.001);    startTBh  =  actTBh;
	      pvGet(actTBa);     epicsThreadSleep(0.001);    startTBa  =  actTBa;
	      pvGet(DTdAct);     epicsThreadSleep(0.001);    startDTd  =  DTdAct;
	      pvGet(DThAct);     epicsThreadSleep(0.001);    startDTh  =  DThAct;
	      pvGet(DTxAct);     epicsThreadSleep(0.001);    startDTx  =  DTxAct;
	      pvGet(DTvdsOff);   epicsThreadSleep(0.001);    startDTvOff = DTvdsOff;
	      pvGet(DTvCorAng);  epicsThreadSleep(0.001);    startDTav = DTvCorAng;
	      pvGet(DTvCorSh);   epicsThreadSleep(0.001);    startDTsv = DTvCorSh;
	      preFdbk = 0;
              if (vfmInBtn == 1) {
		  preHtchSh = 1; preAttUnit   = 0;   preAtt = attIn;
		  preMKys = 1.0; preDSys = 10.0; preDSxs = 10.0;
		  runDSyc = dsHi; runVFMh = vfmHi;  runTBh = tbHi; runTBa = tbAi;
                  postDTvOff = dtOfIn; postDTvAng = dtAnIn; postDTvSh = dtShIn;
	          efClear(vfmin_f); epicsThreadSleep(0.001);
	          sprintf(msgQ,  "Prepare to move IN."); efSet(msg_f); epicsThreadSleep(0.001);
                  printf("Prepare to move IN.\n");
	          efSet(movevfm_f); epicsThreadSleep(0.001);
                  printf("state mntr: raising movevfm flag, leaving mntr-state.\n");
	      }
	      else if (vfmOutBtn == 1) {
		  preHtchSh = 1; attUnit   = 0;   preAtt = attOut;
		  preMKys = 2.0; preDSys = 0.2;  preDSxs = 0.7;
		  runDSyc = dsHo; runVFMh = vfmHo;  runTBh = tbHo; runTBa = tbAo;
                  postDTvOff = dtOfOut; postDTvAng = dtAnOut; postDTvSh = dtShOut;
	          efClear(vfmout_f); epicsThreadSleep(0.001);
	          sprintf(msgQ,  "Prepare to move OUT."); efSet(msg_f); epicsThreadSleep(0.001);
                  printf("Prepare to move OUT.\n");
	          efSet(movevfm_f); epicsThreadSleep(0.001);
                  printf("state mntr: raising movevfm flag, leaving mntr-state.\n");
	      }
              else  {
	          sprintf(msgQ,  "Unknown flag. Abort."); efSet(msg_f); epicsThreadSleep(0.001);
                  printf("Unknown flag. Abort.\n");
		  abortBtn = 1;   pvPut(abortBtn);  epicsThreadSleep(0.001);
	      }
	} state mntr
	when(efTest(fiundo_f) && MKRunPrg == 0 && DSyRunPrg == 0 && DSxRunPrg == 0 && TBvRunPrg == 0 && VFMRunPrg == 0 && DTlpRunPrg == 0 && DTvRunPrg == 0) {
              vfmIOWrkng = 0;  pvPut(vfmIOWrkng);  epicsThreadSleep(0.001);
	      MKvAbort = 1;    pvPut(MKvAbort);    epicsThreadSleep(0.001);
	      DSyAbort = 1;    pvPut(DSyAbort);    epicsThreadSleep(0.001);
	      DSxAbort = 1;    pvPut(DSxAbort);    epicsThreadSleep(0.001);
	      VFMAbort = 1;    pvPut(VFMAbort);    epicsThreadSleep(0.001);
	      TBvAbort = 1;    pvPut(TBvAbort);    epicsThreadSleep(0.001);
	      DTlpAbort = 1;   pvPut(DTlpAbort);   epicsThreadSleep(0.001);
	      DTvAbort = 1;    pvPut(DTvAbort);    epicsThreadSleep(0.001);
              pvFlush();
	      DSyAuto   = 0;   pvPut(DSyAuto);     epicsThreadSleep(0.001);
	      TBvAuto   = 0;   pvPut(TBvAbort);    epicsThreadSleep(0.001);
	      DTlpAuto  = 0;   pvPut(DTlpAuto);    epicsThreadSleep(0.001);
	      DTvAuto   = 0;   pvPut(DTvAuto);     epicsThreadSleep(0.001);
              pvFlush();
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
                vfmIOWrkng = 1;      pvPut(vfmIOWrkng);         epicsThreadSleep(0.001);

	        efClear(movevfm_f);  epicsThreadSleep(0.001);
	        efClear(postmove_f); epicsThreadSleep(0.001);
	        efClear(finished_f); epicsThreadSleep(0.001);
	        efClear(fiundo_f);   epicsThreadSleep(0.001);
  	        vfmInBtn = 0;        pvPut(vfmInBtn);           epicsThreadSleep(0.001);
	        efClear(vfmin_f);    epicsThreadSleep(0.001);
  	        vfmOutBtn = 0;       pvPut(vfmOutBtn);          epicsThreadSleep(0.001);
	        efClear(vfmout_f);   epicsThreadSleep(0.001);
	        abortBtn = 0;  pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
		undoBtn = 0;   pvPut(undoBtn);  epicsThreadSleep(0.001); efClear(undo_f);  epicsThreadSleep(0.001);
		pvFlush();

                MKvAbort = 1;    pvPut(MKvAbort);   epicsThreadSleep(0.001);
                DSyAbort = 1;    pvPut(DSyAbort);   epicsThreadSleep(0.001);
                DSxAbort = 1;    pvPut(DSxAbort);   epicsThreadSleep(0.001);
                VFMAbort = 1;    pvPut(VFMAbort);   epicsThreadSleep(0.001);
                TBvAbort = 1;    pvPut(TBvAbort);   epicsThreadSleep(0.001);
		pvFlush();

	        attUnit   = startAttUnit;    pvPut(attUnit);    pvFlush();
	        attRqs    = startAtt;        pvPut(attRqs);     epicsThreadSleep(0.001);

		rqsMKys   = startMKys;       pvPut(rqsMKys);    pvFlush();
        	rqsDSxs   = startDSxs;       pvPut(rqsDSxs);    pvFlush();
	        rqsKBvy   = startVFMh;       pvPut(rqsKBvy);    pvFlush();

		DSyAuto   = 1;               pvPut(rqsDSxs);    pvFlush();
                rqsDSyc   = startDSyc;       pvPut(rqsDSyc);    epicsThreadSleep(0.001);
                rqsDSys   = startDSys;       pvPut(rqsDSys);    epicsThreadSleep(0.001);
                pvFlush();
		DSyStart  = 1;               pvPut(DSyStart);   pvFlush();

	  	TBvAuto   = 1;               pvPut(TBvAuto);    pvFlush();
	        rqsTBh    = startTBh;        pvPut(rqsTBh);     pvFlush();
	        rqsTBa    = startTBa;        pvPut(rqsTBa);     pvFlush();
	  	TBvStart  = 1;               pvPut(TBvStart);   pvFlush();

	  	DTlpAuto  = 1;               pvPut(DTlpAuto);   pvFlush();
	  	DTvAuto   = 1;               pvPut(DTvAuto);    pvFlush();
		lpCorrOff = 0;               pvPut(lpCorrOff);  pvFlush();
		stCorrOff = 0;               pvPut(stCorrOff);  pvFlush();
                pvFlush();
                DTvdsOff  = startDTvOff;     pvPut(DTvdsOff);   pvFlush();
	        DTvCorAng = startDTav;       pvPut(DTvCorAng);  pvFlush();
	        DTvCorSh  = startDTsv;       pvPut(DTvCorSh);   pvFlush();
                DThRqs    = startDTh;        pvPut(DThRqs);     pvFlush();
	        DTxRqs    = startDTx;        pvPut(DTxRqs);     pvFlush();
		lpCorrOff = 1;               pvPut(lpCorrOff);  pvFlush();
		stCorrOff = 1;               pvPut(stCorrOff);  pvFlush();
	  	DTlpAuto  = 0;               pvPut(DTlpAuto);   pvFlush();
	  	DTvAuto   = 0;               pvPut(DTvAuto);    pvFlush();
                DTlpAbort = 1;               pvPut(DTlpAbort);  pvFlush();
                DTvAbort  = 1;               pvPut(DTvAbort);   pvFlush();
	        DTdRqs    = startDTd;        pvPut(DTdRqs);     pvFlush();
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
	  printf("state move_en: entering msg.\n");
%%        tsLocalTime(&tmc);
%%        tsStampToText (&tmc, TS_TEXT_MMDDYY, pVar->time_str);
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
        } state move_vfm
	when (efTest(abort_f) && abortBtn == 1) {
              printf("state move_vfm: entering abort.\n");
	      MKvAbort = 1;    pvPut(MKvAbort);   epicsThreadSleep(0.001);
	      DSyAbort = 1;    pvPut(DSyAbort);   epicsThreadSleep(0.001);
	      DSxAbort = 1;    pvPut(DSxAbort);   epicsThreadSleep(0.001);
	      VFMAbort = 1;    pvPut(VFMAbort);   epicsThreadSleep(0.001);
	      TBvAbort = 1;    pvPut(TBvAbort);   epicsThreadSleep(0.001);
	      DTlpAbort = 1;   pvPut(DTlpAbort);  epicsThreadSleep(0.001);
	      DTvAbort = 1;    pvPut(DTvAbort);   epicsThreadSleep(0.001);
              pvFlush();
	      DSyAuto   = 0;   pvPut(DSyAuto);     epicsThreadSleep(0.001);
	      TBvAuto   = 0;   pvPut(TBvAbort);    epicsThreadSleep(0.001);
	      DTlpAuto  = 0;   pvPut(DTlpAuto);    epicsThreadSleep(0.001);
	      DTvAuto   = 0;   pvPut(DTvAuto);     epicsThreadSleep(0.001);
              pvFlush();
	      sprintf(msgQ, "**Job aborted. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
	      printf("state mntr: **Job is aborted. Ready.\n");
	      efClear(movevfm_f);  epicsThreadSleep(0.001);
	      efClear(postmove_f); epicsThreadSleep(0.001);
	      efClear(finished_f); epicsThreadSleep(0.001);
	      efClear(fiundo_f);    epicsThreadSleep(0.001);
  	      vfmInBtn = 0;           pvPut(vfmInBtn);           epicsThreadSleep(0.001);
	      efClear(vfmin_f);       epicsThreadSleep(0.001);
  	      vfmOutBtn = 0;          pvPut(vfmOutBtn);          epicsThreadSleep(0.001);
	      efClear(vfmout_f);      epicsThreadSleep(0.001);
	      abortBtn = 0;  pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
	      vfmIOWrkng = 0;  pvPut(vfmIOWrkng);  epicsThreadSleep(0.001);
              printf("state move_vfm: leaving abort.\n");
	} state init2
	when (efTest(movevfm_f))  {
	        printf("state move_vfm: move everything.\n");
	        sprintf(msgQ,  "Move everything."); efSet(msg_f);   epicsThreadSleep(0.001);
                vfmIOWrkng = 1;            pvPut(vfmIOWrkng);       epicsThreadSleep(0.001);

	        stopFdbkBtn = preFdbk;     pvPut(stopFdbkBtn);      epicsThreadSleep(0.001);
	        htchShCl  = preHtchSh;     pvPut(htchShCl);         epicsThreadSleep(0.001);

	        attUnit   = preAttUnit;    pvPut(attUnit);          epicsThreadSleep(0.001);
	        attRqs    = preAtt;        pvPut(attRqs);           epicsThreadSleep(0.001);

	        MKvAbort = 1;    pvPut(MKvAbort);    epicsThreadSleep(0.001);
	        DSyAbort = 1;    pvPut(DSyAbort);    epicsThreadSleep(0.001);
	        DSxAbort = 1;    pvPut(DSxAbort);    epicsThreadSleep(0.001);
	        VFMAbort = 1;    pvPut(VFMAbort);    epicsThreadSleep(0.001);
	        TBvAbort = 1;    pvPut(TBvAbort);    epicsThreadSleep(0.001);
                pvFlush();

	        rqsMKys   = preMKys;       pvPut(rqsMKys);          epicsThreadSleep(0.001);

	        rqsDSxs   = preDSxs;       pvPut(rqsDSxs);          epicsThreadSleep(0.001);
		DSyAuto   = 1;             pvPut(rqsDSxs);          epicsThreadSleep(0.5);
                rqsDSyc   = runDSyc;       pvPut(rqsDSyc);          epicsThreadSleep(0.001);
	        rqsDSys   = preDSys;       pvPut(rqsDSys);          epicsThreadSleep(0.001);
                pvFlush();
		DSyStart  = 1;             pvPut(DSyStart);         epicsThreadSleep(0.001);

	  	TBvAuto   = 1;             pvPut(TBvAuto);          epicsThreadSleep(0.5);
	        rqsTBa    = runTBa;        pvPut(rqsTBa);           epicsThreadSleep(0.001);
	        rqsTBh    = runTBh;        pvPut(rqsTBh);           epicsThreadSleep(0.001);
                pvFlush();
	  	TBvStart  = 1;             pvPut(TBvStart);          epicsThreadSleep(0.001);

		rqsKBvy   = runVFMh;       pvPut(rqsKBvy);          epicsThreadSleep(0.001);

	        DTdRqs    = 700;           pvPut(DTdRqs);           epicsThreadSleep(0.001);

	        efClear(movevfm_f); epicsThreadSleep(0.001);
	        efSet(postmove_f); epicsThreadSleep(0.001);
	        printf("state move_vfm: leaving motion of everything.\n");
        } state move_vfm
	 when (efTest(postmove_f) && MKRunPrg == 0 && DSyRunPrg == 0 && DSxRunPrg == 0 && TBvRunPrg == 0 && VFMRunPrg == 0 && DTlpRunPrg == 0 && DTvRunPrg == 0)  {
	       sprintf(msgQ,  "DT corrections."); efSet(msg_f); epicsThreadSleep(0.001);
               printf("move_vfm: DT corrections.\n");
	       DTlpAuto  = 1;              pvPut(DTlpAuto);     epicsThreadSleep(0.5);
	       DTvAuto   = 1;              pvPut(DTvAuto);      epicsThreadSleep(0.5);
	       lpCorrOff = 0;              pvPut(lpCorrOff);    epicsThreadSleep(0.5);
	       stCorrOff = 0;              pvPut(stCorrOff);    epicsThreadSleep(0.5);
               pvFlush();
               DTvdsOff  = postDTvOff;     pvPut(DTvCorSh);     epicsThreadSleep(0.001);     
	       DTvCorAng = postDTvAng;     pvPut(DTvCorAng);    epicsThreadSleep(0.001);
	       DTvCorSh  = postDTvSh;      pvPut(DTvCorSh);     epicsThreadSleep(0.001);
               DThRqs    = 0.0;            pvPut(DThRqs);       epicsThreadSleep(0.001);
	       DTxRqs    = 0.0;            pvPut(DTxRqs);       epicsThreadSleep(0.001);
	       lpCorrOff = 1;              pvPut(lpCorrOff);    pvFlush();
	       stCorrOff = 1;              pvPut(stCorrOff);    pvFlush();
	       DTlpAuto  = 0;              pvPut(DTlpAuto);     pvFlush();
	       DTvAuto   = 0;              pvPut(DTvAuto);      pvFlush();
               DTlpAbort = 1;              pvPut(DTlpAbort);    pvFlush();
               DTvAbort  = 1;              pvPut(DTvAbort);     pvFlush();
	       DTdRqs    = 700;            pvPut(DTdRqs);       pvFlush();
	       efClear(postmove_f); epicsThreadSleep(0.001);
	       efSet(finished_f); epicsThreadSleep(0.001);
	       printf("state move_en: leaving post-move.\n");
	 } state move_vfm
	 when (delay(TIMEOUT)) {
	       sprintf(msgQ,  "**Timeout. Abort"); efSet(msg_f); epicsThreadSleep(0.001);
	       printf("move_vfm: Timeout. Abort.\n");
	       efClear(movevfm_f);  epicsThreadSleep(0.001);
	       efClear(postmove_f); epicsThreadSleep(0.001);
	       efClear(finished_f); epicsThreadSleep(0.001);
	       abortBtn = 1;        pvPut(abortBtn);         epicsThreadSleep(0.001);
	 } state init2
	 when(efTest(finished_f) && MKRunPrg == 0 && DSyRunPrg == 0 && DSxRunPrg == 0 && TBvRunPrg == 0 && VFMRunPrg == 0 && DTlpRunPrg == 0 && DTvRunPrg == 0) {
               vfmIOWrkng = 0;     pvPut(vfmIOWrkng);  epicsThreadSleep(0.001);
	       MKvAbort = 1;    pvPut(MKvAbort);    epicsThreadSleep(0.001);
	       DSyAbort = 1;    pvPut(DSyAbort);    epicsThreadSleep(0.001);
	       DSxAbort = 1;    pvPut(DSxAbort);    epicsThreadSleep(0.001);
	       VFMAbort = 1;    pvPut(VFMAbort);    epicsThreadSleep(0.001);
	       TBvAbort = 1;    pvPut(TBvAbort);    epicsThreadSleep(0.001);
	       DTlpAbort = 1;   pvPut(DTlpAbort);   epicsThreadSleep(0.001);
	       DTvAbort = 1;    pvPut(DTvAbort);    epicsThreadSleep(0.001);
               pvFlush();
	       DSyAuto   = 0;   pvPut(DSyAuto);     epicsThreadSleep(0.001);
	       TBvAuto   = 0;   pvPut(TBvAbort);    epicsThreadSleep(0.001);
	       DTlpAuto  = 0;   pvPut(DTlpAuto);    epicsThreadSleep(0.001);
	       DTvAuto   = 0;   pvPut(DTvAuto);     epicsThreadSleep(0.001);
               pvFlush();
	       efClear(finished_f); epicsThreadSleep(0.001);
	       sprintf(msgQ,  "Ready."); efSet(msg_f); epicsThreadSleep(0.001);
               printf("move_vfm: Move VFM finished. Ready.\n");
	 } state init2
	when(efTest(fiundo_f) && MKRunPrg == 0 && DSyRunPrg == 0 && DSxRunPrg == 0 && TBvRunPrg == 0 && VFMRunPrg == 0 && DTlpRunPrg == 0 && DTvRunPrg == 0) {
               vfmIOWrkng = 0;     pvPut(vfmIOWrkng);  epicsThreadSleep(0.001);
	       MKvAbort = 1;    pvPut(MKvAbort);    epicsThreadSleep(0.001);
	       DSyAbort = 1;    pvPut(DSyAbort);    epicsThreadSleep(0.001);
	       DSxAbort = 1;    pvPut(DSxAbort);    epicsThreadSleep(0.001);
	       VFMAbort = 1;    pvPut(VFMAbort);    epicsThreadSleep(0.001);
	       TBvAbort = 1;    pvPut(TBvAbort);    epicsThreadSleep(0.001);
	       DTlpAbort = 1;   pvPut(DTlpAbort);   epicsThreadSleep(0.001);
	       DTvAbort = 1;    pvPut(DTvAbort);    epicsThreadSleep(0.001);
               pvFlush();
	       DSyAuto   = 0;   pvPut(DSyAuto);     epicsThreadSleep(0.001);
	       TBvAuto   = 0;   pvPut(TBvAbort);    epicsThreadSleep(0.001);
	       DTlpAuto  = 0;   pvPut(DTlpAuto);    epicsThreadSleep(0.001);
	       DTvAuto   = 0;   pvPut(DTvAuto);     epicsThreadSleep(0.001);
               pvFlush();
	       efClear(fiundo_f); epicsThreadSleep(0.001);
	       sprintf(msgQ, "Undo finished. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
	       printf("mntr: Undo finished. Ready.\n");
	} state init2
	when (efTest(undo_f) && undoBtn == 1) {
	       printf("move_vfm: entering undo.\n");
               vfmIOWrkng = 1;      pvPut(vfmIOWrkng);         epicsThreadSleep(0.001);

	       efClear(movevfm_f);  epicsThreadSleep(0.001);
	       efClear(postmove_f); epicsThreadSleep(0.001);
	       efClear(finished_f); epicsThreadSleep(0.001);
	       efClear(fiundo_f);   epicsThreadSleep(0.001);
  	       vfmInBtn = 0;        pvPut(vfmInBtn);           epicsThreadSleep(0.001);
	       efClear(vfmin_f);    epicsThreadSleep(0.001);
  	       vfmOutBtn = 0;       pvPut(vfmOutBtn);          epicsThreadSleep(0.001);
	       efClear(vfmout_f);   epicsThreadSleep(0.001);
	       abortBtn = 0;  pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
	       undoBtn = 0;   pvPut(undoBtn);  epicsThreadSleep(0.001); efClear(undo_f);  epicsThreadSleep(0.001);
	       pvFlush();

                MKvAbort = 1;    pvPut(MKvAbort);   epicsThreadSleep(0.001);
                DSyAbort = 1;    pvPut(DSyAbort);   epicsThreadSleep(0.001);
                DSxAbort = 1;    pvPut(DSxAbort);   epicsThreadSleep(0.001);
                VFMAbort = 1;    pvPut(VFMAbort);   epicsThreadSleep(0.001);
                TBvAbort = 1;    pvPut(TBvAbort);   epicsThreadSleep(0.001);
		pvFlush();

	        attUnit   = startAttUnit;    pvPut(attUnit);    pvFlush();
	        attRqs    = startAtt;        pvPut(attRqs);     epicsThreadSleep(0.001);

		rqsMKys   = startMKys;       pvPut(rqsMKys);    pvFlush();
        	rqsDSxs   = startDSxs;       pvPut(rqsDSxs);    pvFlush();
	        rqsKBvy   = startVFMh;       pvPut(rqsKBvy);    pvFlush();

		DSyAuto   = 1;               pvPut(rqsDSxs);    pvFlush();
                rqsDSyc   = startDSyc;       pvPut(rqsDSyc);    epicsThreadSleep(0.001);
                rqsDSys   = startDSys;       pvPut(rqsDSys);    epicsThreadSleep(0.001);
                pvFlush();
		DSyStart  = 1;               pvPut(DSyStart);   pvFlush();

	  	TBvAuto   = 1;               pvPut(TBvAuto);    pvFlush();
	        rqsTBh    = startTBh;        pvPut(rqsTBh);     pvFlush();
	        rqsTBa    = startTBa;        pvPut(rqsTBa);     pvFlush();
	  	TBvStart  = 1;               pvPut(TBvStart);   pvFlush();

	  	DTlpAuto  = 1;               pvPut(DTlpAuto);   pvFlush();
	  	DTvAuto   = 1;               pvPut(DTvAuto);    pvFlush();
		lpCorrOff = 0;               pvPut(lpCorrOff);  pvFlush();
		stCorrOff = 0;               pvPut(stCorrOff);  pvFlush();
                pvFlush();
                DTvdsOff  = startDTvOff;     pvPut(DTvdsOff);   pvFlush();
	        DTvCorAng = startDTav;       pvPut(DTvCorAng);  pvFlush();
	        DTvCorSh  = startDTsv;       pvPut(DTvCorSh);   pvFlush();
                DThRqs    = startDTh;        pvPut(DThRqs);     pvFlush();
	        DTxRqs    = startDTx;        pvPut(DTxRqs);     pvFlush();
		lpCorrOff = 1;               pvPut(lpCorrOff);  pvFlush();
		stCorrOff = 1;               pvPut(stCorrOff);  pvFlush();
	  	DTlpAuto  = 0;               pvPut(DTlpAuto);   pvFlush();
	  	DTvAuto   = 0;               pvPut(DTvAuto);    pvFlush();
                DTlpAbort = 1;               pvPut(DTlpAbort);  pvFlush();
                DTvAbort  = 1;               pvPut(DTvAbort);   pvFlush();
	        DTdRqs    = startDTd;        pvPut(DTdRqs);     pvFlush();

	       sprintf(msgQ, "Undo in progress."); efSet(msg_f); epicsThreadSleep(0.001);
	       printf("move_vfm: Undo in progress.\n");
	       printf("move_vfm: leaving undo.\n");
	       efSet(fiundo_f); epicsThreadSleep(0.001);
	} state move_vfm
    }
}

