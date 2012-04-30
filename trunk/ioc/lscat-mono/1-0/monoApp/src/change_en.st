program change_en("coioc=21linux, scnm=21:D1:scan3, detnm=21:D1:scaler1")

option +r;

%%#include <string.h>
%%#include <math.h>
%%#include <tsDefs.h>	/* defenition for TS_STAMP, tsLocalTime()  */
#include "change_en.h"

ss set1 {
    state init {
	  when() {
	      /*??? New numbers should come from  Autosave at IOC reboot */
	      newEn = actEn;     pvPut(newEn);      epicsThreadSleep(0.001);
              printf("Init state: actEn=%f, newEn=%f.\n", actEn,rqsPosEn);
              tmpdb = 0.0;
	      thWrkng = 0;       pvPut(thWrkng);    epicsThreadSleep(0.001);
	      chEnWrkng = 0;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
       /*     tbMiSwBtn = 0;     pvPut(tbMiSwBtn);  epicsThreadSleep(0.001);  */
       /*     idEnaBtn = 1;      pvPut(idEnaBtn);   epicsThreadSleep(0.001);  */
       /*     chiEnaBtn = 1;     pvPut(chiEnaBtn);  epicsThreadSleep(0.001);  */
       /*     vfmEnaBtn = 1;     pvPut(vfmEnaBtn);  epicsThreadSleep(0.001);  */
       /*     hfmEnaBtn = 1;     pvPut(hfmEnaBtn);  epicsThreadSleep(0.001);  */
       /*     piEnaBtn = 1;      pvPut(piEnaBtn);   epicsThreadSleep(0.001);  */
       /*     thEnaBtn = 1;      pvPut(thEnaBtn);   epicsThreadSleep(0.001);  */
       /*     hrmSwEn = 13.0;    pvPut(hrmSwEn);    epicsThreadSleep(0.001);  */
       /*     idOff1 = 0.150;    pvPut(idOff1);     epicsThreadSleep(0.001);  */
       /*     idOff2 = 0.150;    pvPut(idOff2);     epicsThreadSleep(0.001);  */
       /*     chiSca = -0.009;   pvPut(chiSca);     epicsThreadSleep(0.001);  */
       /*     chiOff = -0.74;    pvPut(chiOff);     epicsThreadSleep(0.001);  */
       /*     vfmPd = 8.0;       pvPut(vfmPd);      epicsThreadSleep(0.001);  */
       /*     vfmGl = -3.0;      pvPut(vfmGl);      epicsThreadSleep(0.001);  */
       /*     vfmPt = -12.0;     pvPut(vfmPt);      epicsThreadSleep(0.001);  */
       /*     hfmPd = -14.0;     pvPut(hfmPd);      epicsThreadSleep(0.001);  */
       /*     hfmGl = -2.0;      pvPut(hfmGl);      epicsThreadSleep(0.001);  */
       /*     hfmPt = 10.0;      pvPut(hfmPt);      epicsThreadSleep(0.001);  */
              strcpy(piScanPosRd,"21:C1:MO:P2:ActPos");
              strcpy(piScanPosDr,"21:C1:MO:P2:RqsPos");
              strcpy(piScanDtTrg,"21:D1:scaler1.CNT");
              strcpy(piScanDet,"21:D1:scaler1_calc5.VAL");
              strcpy(piScanAfter,"21:C1:MO:Tn:Kill");
       /*     scWdth = 0.010;    pvPut(scWdth);     epicsThreadSleep(0.001);  */
       /*     scStep = 0.0004;   pvPut(scStep);     epicsThreadSleep(0.001);  */
       /*     thStep = 0.02;     pvPut(thStep);     epicsThreadSleep(0.001);  */
	      efClear (clean_f); epicsThreadSleep(0.001); msgI = 9;
  	      startBtn = 0;      pvPut(startBtn);   epicsThreadSleep(0.001);
	      efClear(start_f);  epicsThreadSleep(0.001);
  	      abortBtn = 0;   	 pvPut(abortBtn);   epicsThreadSleep(0.001);
	      thWrkng = 0;       pvPut(thWrkng);    epicsThreadSleep(0.001);
	      efClear(abort_f);  epicsThreadSleep(0.001);
	      sprintf(msgQ,  "Ready."); efSet(msg_f); epicsThreadSleep(0.001);
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
                EnAbort = 1;  pvPut(EnAbort); epicsThreadSleep(0.001);
                if(idEnaBtn == 1)  { IDStop = 1;    pvPut(IDStop);    epicsThreadSleep(0.001);}
                if(chiEnaBtn == 1) { ChiAbort = 1;  pvPut(ChiAbort);  epicsThreadSleep(0.001);}
		if(vfmEnaBtn == 1) { VFMAbort = 1;  pvPut(VFMAbort);  epicsThreadSleep(0.001);}
		if(hfmEnaBtn == 1) { HFMAbort = 1;  pvPut(HFMAbort);  epicsThreadSleep(0.001);}
		if(piEnaBtn == 1)  {
		       piScanAbort = 1; pvPut(piScanAbort);  epicsThreadSleep(0.1);
		       piScanAbort = 1; pvPut(piScanAbort);  epicsThreadSleep(0.1);
		    /* piScanCmnd = 0;  pvPut(piScanCmnd);   epicsThreadSleep(0.001);  */
		}
                epicsThreadSleep(0.5);
                EnKill = 1;  pvPut(EnKill);
		if(chiEnaBtn == 1)  { ChiKill = 1;   pvPut(ChiKill);  epicsThreadSleep(0.001);}
		if(vfmEnaBtn == 1)  { VFMKill = 1;   pvPut(VFMKill);  epicsThreadSleep(0.001);}
		if(hfmEnaBtn == 1)  { HFMKill = 1;   pvPut(HFMKill);  epicsThreadSleep(0.001);}
	        detMode = 1;        pvPut(detMode);  epicsThreadSleep(0.001);
	        sprintf(msgQ, "**Job aborted. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
	        printf("state mntr: **Job is aborted. Ready.\n");
		efClear(moveen_f);  epicsThreadSleep(0.001); efClear(moveid_f);  epicsThreadSleep(0.001);
		efClear(movechi_f); epicsThreadSleep(0.001);
                efClear(movevfm_f); epicsThreadSleep(0.001);  efClear(movehfm_f); epicsThreadSleep(0.001);
		efClear(optpi_f);   epicsThreadSleep(0.001); efClear(optth_f);   epicsThreadSleep(0.001);
		startBtn = 0;  pvPut(startBtn); epicsThreadSleep(0.001); efClear(start_f); epicsThreadSleep(0.001);
	        abortBtn = 0;  pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
	        thWrkng = 0;   pvPut(thWrkng);  epicsThreadSleep(0.001);
                chEnWrkng = 0;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
                printf("state mntr: leaving abort.\n");
	} state mntr
	when(efTest(start_f) && startBtn == 1 && EnRunPrg == 1) {
	      sprintf(msgQ,  "**Energy assembly moving"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state mntr: Energy assembly is still moving. Quit.\n");
	      startBtn = 0;  pvPut(startBtn);  epicsThreadSleep(0.001);
	      efClear(start_f); epicsThreadSleep(0.001);
	} state mntr
	when(efTest(start_f) && startBtn == 1 && idEnaBtn == 1 && IDStatus == 1) {
	      sprintf(msgQ,  "**Undulator is moving."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state mntr: Undulator is still moving. Quit.\n");
	      startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
	      efClear(start_f); epicsThreadSleep(0.001);
	} state mntr
	when(efTest(start_f) && startBtn == 1 && chiEnaBtn == 1 && ChiRunPrg == 1) {
	      sprintf(msgQ,  "**CHI or Pitch moving"); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state mntr: CHI or Pitch axis is still moving. Quit.\n");
	      startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
	      efClear(start_f); epicsThreadSleep(0.001);
	} state mntr
	when(efTest(start_f) && startBtn == 1 && vfmEnaBtn == 1 && VFMRunPrg == 1) {
	      sprintf(msgQ,  "**VFMirror still moving."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state mntr: VFMirror still moving. Quit.\n");
	      startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
	      efClear(start_f); epicsThreadSleep(0.001);
	} state mntr
	when(efTest(start_f) && startBtn == 1 && hfmEnaBtn == 1 && HFMRunPrg == 1) {
	      sprintf(msgQ,  "**HFMirror still moving."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state mntr: HFMirror still moving. Quit.\n");
	      startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
	      efClear(start_f); epicsThreadSleep(0.001);
	} state mntr
	when(efTest(start_f) && startBtn == 1 && piEnaBtn == 1 && piScanBusy == 1 ) {
	      sprintf(msgQ,  "**Pitch still optimized."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state mntr: Pitch Scan is still working. Quit.\n");
	      startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
	      efClear(start_f); epicsThreadSleep(0.001);
	} state mntr
	when (efTest(start_f) && startBtn == 1 && (newEn < ENERGYMIN || newEn > ENERGYMAX)) {
	      sprintf(msgQ,  "**Energy out of range."); efSet(msg_f); epicsThreadSleep(0.001);
	      printf("state mntr: Requested Energy is out of range, ENERGYMIN=%f, ENERGYMAX=%f.\n", ENERGYMIN, ENERGYMAX);
       	      startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
	      efClear(start_f); epicsThreadSleep(0.001);
	} state mntr
	when (efTest(start_f) && startBtn == 1 && centrWrkng == 1) {
	      sprintf(msgQ,  "**Center-Beam working."); efSet(msg_f); epicsThreadSleep(0.001);
	      printf("state mntr: Center-Beam script is working.\n");
       	      startBtn = 0; pvPut(startBtn); epicsThreadSleep(0.001);
	      efClear(start_f); epicsThreadSleep(0.001);
	} state mntr
        when (efTest(start_f) && startBtn == 1 && (newEn >= ENERGYMIN && newEn <= ENERGYMAX)) {
              printf("state mntr: entering last when where move_en_f is set.\n");
	      startEn = actEn; finishEn = newEn; deltaEn = actEn - newEn;
	      if(deltaEn < 0) deltaEn = newEn - actEn;
	      sprintf(msgQ,  "Preparing to move."); efSet(msg_f); epicsThreadSleep(0.001);
              printf("Preparing to combined motion.\n");
	      startBtn = 0;  pvPut(startBtn); epicsThreadSleep(0.001);
	      efClear(start_f); epicsThreadSleep(0.001);
	      /* save positions before changing energy */
	      pvGet(actEnID);  epicsThreadSleep(0.001); startEnID = actEnID;
	      pvGet(rqsHrmID); epicsThreadSleep(0.001); startHrmID = rqsHrmID;
	      pvGet(actChi);   epicsThreadSleep(0.001); startChi = actChi;
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
                chEnWrkng = 1;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
                EnAbort = 1;    pvPut(EnAbort);   epicsThreadSleep(0.001);
		rqsPosEn = startEn;  pvPut(rqsPosEn);   epicsThreadSleep(0.001);
                printf("undo: Moving En to %f.).\n", startEn);
	        if(idEnaBtn == 1)  {
                       if(IDStatus == 1) {IDStop = 1;    pvPut(IDStop);    epicsThreadSleep(0.1);}
		       rqsHrmID = startHrmID;  pvPut(rqsHrmID); epicsThreadSleep(0.001);
		       rqsEnID  = startEnID;   printf("undo: Moving ID to %f.\n", rqsEnID);
		       pvPut(rqsEnID);  epicsThreadSleep(0.001);
                       IDStart = 1; pvPut(IDStart); epicsThreadSleep(0.001);
	        }
		if(vfmEnaBtn == 1) {
                      VFMAbort = 1;            pvPut(VFMAbort);  epicsThreadSleep(0.001);
		      rqsLnVFM = startLnVFM;   pvPut(rqsLnVFM);  epicsThreadSleep(0.001);
                      printf("undo: Moving VFM to %f.).\n", rqsLnVFM);
                }
		if(hfmEnaBtn == 1) {
		      HFMAbort = 1;            pvPut(HFMAbort);  epicsThreadSleep(0.001);
		      rqsLnHFM = startLnHFM;   pvPut(rqsLnHFM);  epicsThreadSleep(0.001);
                      printf("undo: Moving HFM to %f.).\n", rqsLnHFM);
                }
		/* Pitch scan should be aborted before abortion of the Pi-Chi assembly */
		if(piEnaBtn == 1)  {
		       if(piScanBusy == 1) {
                            piScanAbort = 1;   pvPut(piScanAbort);  epicsThreadSleep(0.1);
		            piScanAbort = 1;   pvPut(piScanAbort);  epicsThreadSleep(0.1);
			    epicsThreadSleep(0.5);
                            printf("undo: Abort pitch scan.\n");
                       }
                       ChiAbort = 1;  pvPut(ChiAbort);  epicsThreadSleep(0.1);
		       rqsPitch = startPi;  pvPut(rqsPitch);  epicsThreadSleep(0.1);
                       printf("undo: Moving Pitch to %f.).\n", rqsPitch);
		}
                if(chiEnaBtn == 1) {
                       if(ChiRunPrg == 0) {ChiAbort = 1;  pvPut(ChiAbort);  epicsThreadSleep(0.001);}
		       rqsPosChi = startChi;  pvPut(rqsPosChi);  epicsThreadSleep(0.001);
                       printf("undo: Moving CHI to %f.).\n", rqsPosChi);
                }
                if(thEnaBtn == 1) {curTheta = startTh;  pvPut(curTheta);  epicsThreadSleep(0.001); }
                printf("undo: Moving Theta to %f.).\n", curTheta);
		epicsThreadSleep(0.5);
             /*   if(EnRunPrg == 0) {EnKill = 1;  pvPut(EnKill); epicsThreadSleep(0.001);}   */
	     /*	if(chiEnaBtn == 1 && ChiRunPrg == 0)  { pvPut(ChiKill);  epicsThreadSleep(0.001);}  */
	     /*	if(vfmEnaBtn == 1 && VFMRunPrg == 0)  { VFMKill = 1;   pvPut(VFMKill);  epicsThreadSleep(0.001);} */
	     /*	if(hfmEnaBtn == 1 && HFMRunPrg == 0)  { HFMKill = 1;   pvPut(HFMKill);  epicsThreadSleep(0.001);} */
	        detMode = 1;        pvPut(detMode);  epicsThreadSleep(0.001);
	        sprintf(msgQ, "Undo finished. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
		efClear(moveen_f);  epicsThreadSleep(0.001); efClear(moveid_f);  epicsThreadSleep(0.001);
		efClear(movechi_f); epicsThreadSleep(0.001);
                efClear(movevfm_f); epicsThreadSleep(0.001);  efClear(movehfm_f); epicsThreadSleep(0.001);
		efClear(optpi_f);   epicsThreadSleep(0.001); efClear(optth_f);   epicsThreadSleep(0.001);
		startBtn = 0;  pvPut(startBtn); epicsThreadSleep(0.001); efClear(start_f); epicsThreadSleep(0.001);
	        abortBtn = 0;  pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
		undoBtn = 0;   pvPut(undoBtn);  epicsThreadSleep(0.001); efClear(undo_f);  epicsThreadSleep(0.001);
	        thWrkng = 0;   pvPut(thWrkng);  epicsThreadSleep(0.001);
                chEnWrkng = 0; pvPut(chEnWrkng);  epicsThreadSleep(0.001);
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
        } state move_en
	when (efTest(abort_f) && abortBtn == 1) {
	        printf("state move_en: entering abort.\n");
                EnAbort = 1;  pvPut(EnAbort); epicsThreadSleep(0.001);
                if(idEnaBtn == 1)  { IDStop = 1;    pvPut(IDStop);    epicsThreadSleep(0.001);}
                if(chiEnaBtn == 1) { ChiAbort = 1;  pvPut(ChiAbort);  epicsThreadSleep(0.001);}
		if(vfmEnaBtn == 1) { VFMAbort = 1;  pvPut(VFMAbort);  epicsThreadSleep(0.001);}
		if(hfmEnaBtn == 1) { HFMAbort = 1;  pvPut(HFMAbort);  epicsThreadSleep(0.001);}
		if(piEnaBtn == 1)  {
		       piScanAbort = 1; pvPut(piScanAbort);  epicsThreadSleep(0.1);
		       piScanAbort = 1; pvPut(piScanAbort);  epicsThreadSleep(0.1);
		    /* piScanCmnd = 0;  pvPut(piScanCmnd);   epicsThreadSleep(0.001);  */
		}
                epicsThreadSleep(0.5);
                EnKill = 1;  pvPut(EnKill); epicsThreadSleep(0.001);
		if(chiEnaBtn == 1)  { ChiKill = 1;   pvPut(ChiKill);  epicsThreadSleep(0.001);}
		if(vfmEnaBtn == 1)  { VFMKill = 1;   pvPut(VFMKill);  epicsThreadSleep(0.001);}
		if(hfmEnaBtn == 1)  { HFMKill = 1;   pvPut(HFMKill);  epicsThreadSleep(0.001);}
	        detMode = 1;        pvPut(detMode);  epicsThreadSleep(0.001);
	        sprintf(msgQ, "**Job aborted. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
		efClear(moveen_f);  epicsThreadSleep(0.001); efClear(moveid_f);  epicsThreadSleep(0.001);
		efClear(movechi_f); epicsThreadSleep(0.001);
                efClear(movevfm_f); epicsThreadSleep(0.001);  efClear(movehfm_f); epicsThreadSleep(0.001);
		efClear(optpi_f);   epicsThreadSleep(0.001); efClear(optth_f);   epicsThreadSleep(0.001);
		startBtn = 0;  pvPut(startBtn); epicsThreadSleep(0.001); efClear(start_f); epicsThreadSleep(0.001);
	        abortBtn = 0;  pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
	        thWrkng = 0;   pvPut(thWrkng);  epicsThreadSleep(0.001);
                chEnWrkng = 0;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
	        printf("state move_en: leaving abort.\n");
	} state init2
        when(efTest(moveen_f) && deltaEn <= 0.1) {
	      printf("state move_en: entering deltaEn < 0.1.\n");
	      sprintf(msgQ,  "En=%2.3f tuning Chi&Thet", newEn); efSet(msg_f); epicsThreadSleep(0.001);
              printf("state move: deltaEn < 0.1: Moving just Energy to %f. Plus optimization.\n", newEn);
              chEnWrkng = 1;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
	      EnAbort = 1;       pvPut(EnAbort);  epicsThreadSleep(0.001);
	      rqsPosEn = newEn;  pvPut(rqsPosEn); epicsThreadSleep(0.001);
              epicsThreadSleep(20);
	      EnKill = 1;         pvPut(EnKill);      epicsThreadSleep(0.001);
	      efClear(moveen_f);  epicsThreadSleep(0.001); efClear(moveid_f);  epicsThreadSleep(0.001);
	      efClear(movevfm_f); epicsThreadSleep(0.001);  efClear(movehfm_f); epicsThreadSleep(0.001);
	      if(chiEnaBtn == 1) { efSet(movechi_f); epicsThreadSleep(0.001); }
	      else { efClear(movechi_f); epicsThreadSleep(0.001); }
	      if(piEnaBtn == 1)  { efSet(optpi_f); epicsThreadSleep(0.001); }
	      else {
                    efClear(optpi_f); epicsThreadSleep(0.001);
                    efClear(optth_f); epicsThreadSleep(0.001); efClear(finished); epicsThreadSleep(0.001);
              }
	      printf("state move_en: leaving deltaEn < 0.1.\n");
        } state move_en
	when (efTest(moveen_f) && deltaEn > 0.1)  {
	       printf("state move_en: entering move En to RqsPos.\n");
	       sprintf(msgQ,  "Move En to %2.3f.", newEn); efSet(msg_f); epicsThreadSleep(0.001);
	       printf("state move: deltaEn >0.1: Moving Energy to %f.\n", newEn);
               chEnWrkng = 1;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
	       EnAbort = 1;       pvPut(EnAbort);  epicsThreadSleep(0.2);
	       rqsPosEn = newEn;  pvPut(rqsPosEn); epicsThreadSleep(0.001);
	       if(chiEnaBtn == 1) { efSet(movechi_f); epicsThreadSleep(0.001); }
	       else { efClear(movechi_f); epicsThreadSleep(0.001); }
	       if(idEnaBtn == 1)  { efSet(moveid_f);  epicsThreadSleep(0.001); }
	       else { efClear(moveid_f); epicsThreadSleep(0.001); }
	       if(vfmEnaBtn == 1) { efSet(movevfm_f); epicsThreadSleep(0.001); }
	       else { efClear(movevfm_f); epicsThreadSleep(0.001); }
	       if(hfmEnaBtn == 1) { efSet(movehfm_f); epicsThreadSleep(0.001); }
	       else { efClear(movehfm_f); epicsThreadSleep(0.001); }
	       if(piEnaBtn == 1)  { efSet(optpi_f); epicsThreadSleep(0.001); }
	       else { efClear(optpi_f); epicsThreadSleep(0.001); efClear(optth_f); epicsThreadSleep(0.001); efClear(finished); epicsThreadSleep(0.001);}
	       efClear(moveen_f); epicsThreadSleep(0.001);
	       printf("state move_en: leavingg move En to RqsPos.\n");
	 } state move_en
	 when (efTest(movechi_f))  {
	        printf("state move_en: entering move Chi: startEn=%f, finishEn=%f, deltaEn=%f.\n", startEn, finishEn, deltaEn);
	        /* if(finishEn > startEn) {rqsPosChi = actChi + deltaEn* chiSca; pvPut(rqsPosChi); epicsThreadSleep(0.001);} */
	        /* else {rqsPosChi = actChi - deltaEn* chiSca; pvPut(rqsPosChi); epicsThreadSleep(0.001);}  */
                chEnWrkng = 1;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
	        ChiAbort = 1;    pvPut(ChiAbort); epicsThreadSleep(0.001);
		tmpdb = actChi - (startEn * chiSca);
		/* if (tmpdb > (-1.2) && tmpdb < (-0.4)) { */
		if (tmpdb > (-2.0) && tmpdb < 2.0) {
                     chiOff = tmpdb;   pvPut(chiOff);  epicsThreadSleep(0.001);
                }
		rqsPosChi = finishEn * chiSca + chiOff;
                sprintf(msgQ, "Move CHI to %2.5f.", rqsPosChi); efSet(msg_f); epicsThreadSleep(0.001);
	        printf("state move: deltaEn >0.1: Moving CHI to %f.\n", rqsPosChi);
		pvPut(rqsPosChi); epicsThreadSleep(0.001);
	        efClear(movechi_f); epicsThreadSleep(0.001);
	        printf("state move_en: leaving move Chi.\n");
	 } state move_en
	 when (efTest(moveid_f))  {
	        printf("state move_en: entering move ID.\n");
                chEnWrkng = 1;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
		if(finishEn >= hrmSwEn && hrmSwEn > 12 && hrmSwEn < 13.5) {
                           rqsHrmID  = 3.0;  pvPut(rqsHrmID); epicsThreadSleep(0.001);
		           rqsEnID = finishEn + idOff2;
                }
       		else  {
		           rqsHrmID  = 1.0;  pvPut(rqsHrmID); epicsThreadSleep(0.001);
                           rqsEnID = finishEn + idOff1;
		}
	        sprintf(msgQ, "Move ID to %2.3f.", rqsEnID); efSet(msg_f); epicsThreadSleep(0.001);
	        printf("state move: deltaEn >0.1: Moving ID to %f.\n", rqsEnID);
		pvPut(rqsEnID); epicsThreadSleep(0.001); IDStart = 1; pvPut(IDStart); epicsThreadSleep(0.001);
	        efClear(moveid_f); epicsThreadSleep(0.001);
	        printf("state move_en: leaving move ID.\n");
	 } state move_en
	 when (efTest(movevfm_f))  {
	        printf("state move_en: entering move VFM.\n");
                chEnWrkng = 1;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
		printf("movevfm: finishEn=%f, startEn=%f.\n", finishEn, startEn);
		if(finishEn < VFMENSWLO) {
                    if(startEn < VFMENSWLO && (actLnVFM > VFMLNGLPT && actLnVFM < VFMLNPDGL)) {i = 0;}
		    else { rqsLnVFM = vfmGl;  i = 1; }
		}
		else if (finishEn > VFMENSWMD) {
                    if(startEn > VFMENSWMD && (actLnVFM < VFMLNGLPT && actLnVFM > VFMLNMIN)) {i = 0;}
		    else {rqsLnVFM = vfmPt;  i = 1; }
		}
		else {
                      if((startEn >= VFMENSWLO && startEn <= VFMENSWMD) && (actLnVFM > VFMLNPDGL && actLnVFM < VFMLNMAX)) {i = 0;}
		      else  { rqsLnVFM = vfmPd; i = 1; }
		}
                if(i == 0) {
	                 sprintf(msgQ, "VFM cur. stripe fits."); efSet(msg_f); epicsThreadSleep(0.001);
	                 printf("state move: deltaEn >0.1: Vfm current-stripe fits.\n");
		}
		else {
	                 sprintf(msgQ, "VFM to %2.1f.", rqsLnVFM); efSet(msg_f); epicsThreadSleep(0.001);
	                 printf("state move: deltaEn >0.1: Moving VFM to %f.\n", rqsLnVFM);
	                 VFMAbort = 1;   pvPut(VFMAbort);  epicsThreadSleep(0.1); pvPut(rqsLnVFM); epicsThreadSleep(0.001);
		}
	        efClear(movevfm_f); epicsThreadSleep(0.001);
	        printf("state move_en: leaving move VFM.\n");
	 } state move_en
	 when (efTest(movehfm_f))  {
	        printf("state move_en: entering move HFM.\n");
                chEnWrkng = 1;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
	        printf("movehfm: finishEn=%f, startEn=%f.\n", finishEn, startEn);
		if(finishEn < HFMENSWLO) {
                    if(startEn < HFMENSWLO && (actLnHFM > HFMLNGLPT && actLnHFM < HFMLNPDGL)) {i = 0;}
		    else { rqsLnHFM = hfmGl;  i = 1; }
		}
		else if (finishEn > HFMENSWMD) {
                        if(startEn > HFMENSWMD && (actLnHFM < HFMLNGLPT && actLnHFM > HFMLNMIN)) {i = 0;}
		        else { rqsLnHFM = hfmPt; i = 1; }
		}
		else {
                       if((startEn >= HFMENSWLO && startEn <= HFMENSWMD) && (actLnHFM > HFMLNPDGL && actLnHFM < HFMLNMAX)) {i = 0;}
		       else  { rqsLnHFM = hfmPd; i = 1; }
		}
                if(i == 0) {
	               sprintf(msgQ, "HFM cur. stripe fits."); efSet(msg_f); epicsThreadSleep(0.001);
	               printf("state move: deltaEn >0.1: HFM current-stripe fits.\n");
		}
		else {
	               sprintf(msgQ, "HFM to %2.1f.", rqsLnHFM); efSet(msg_f); epicsThreadSleep(0.001);
	               printf("state move: deltaEn >0.1: Moving HFM to %f.\n", rqsLnHFM);
		       HFMAbort = 1;   pvPut(HFMAbort);  epicsThreadSleep(0.1); pvPut(rqsLnHFM); epicsThreadSleep(0.001);
		}
	        efClear(movehfm_f); epicsThreadSleep(0.001);
	        printf("state move_en: leaving move HFM.\n");
	 } state move_en
	 when (delay(TIMEOUT)) {
	       sprintf(msgQ,  "**Timeout. Abort"); efSet(msg_f); epicsThreadSleep(0.001);
	       printf("move_en: Timeout. Abort.\n");
	       efClear(moveen_f);  epicsThreadSleep(0.001); efClear(moveid_f);  epicsThreadSleep(0.001);
	       efClear(movechi_f); epicsThreadSleep(0.001);
               efClear(movevfm_f); epicsThreadSleep(0.001);  efClear(movehfm_f); epicsThreadSleep(0.001);
	       efClear(optpi_f);   epicsThreadSleep(0.001); efClear(optth_f);   epicsThreadSleep(0.001);
	       efClear(finished);  epicsThreadSleep(0.001);
	       abortBtn = 1;       pvPut(abortBtn);         epicsThreadSleep(0.001);
	 } state init2
	 when (efTest(optpi_f) && EnRunPrg == 0 && ChiRunPrg == 0 && IDStatus == 0 && VFMRunPrg == 0 && HFMRunPrg == 0 && delay(1))  {
	       printf("state move_en: entering scan Pitch.\n");
               chEnWrkng = 1;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
	       EnKill = 1;         pvPut(EnKill);  epicsThreadSleep(0.001);
	       if(vfmEnaBtn == 1) {VFMKill = 1; pvPut(VFMKill); epicsThreadSleep(0.001); }
	       if(hfmEnaBtn == 1) {HFMKill = 1; pvPut(HFMKill); epicsThreadSleep(0.001); }
	       printf("opt-pitch: ActPitch=%f.\n", actPitch);
	       sprintf(msgQ,  "Optimizing Pitch."); efSet(msg_f); epicsThreadSleep(0.001);
	       printf("opt-pitch: Optimizing Pitch.\n");
	       ChiAbort = 1;            pvPut(ChiAbort);     epicsThreadSleep(0.001);
	       curTheta = 0.0;          pvPut(curTheta);     epicsThreadSleep(0.001);
	       detMode = 0;             pvPut(detMode);      epicsThreadSleep(0.001);
               pvPut(piScanPosRd);      epicsThreadSleep(0.001);
               pvPut(piScanPosDr);      epicsThreadSleep(0.001);
               pvPut(piScanDtTrg);      epicsThreadSleep(0.001);
               pvPut(piScanDet);        epicsThreadSleep(0.001);
               pvPut(piScanAfter);      epicsThreadSleep(0.001);
               piScanPosStl = 0.0;      pvPut(piScanPosStl); epicsThreadSleep(0.001);
               piScanDetStl = 0.0;      pvPut(piScanDetStl); epicsThreadSleep(0.001);
               piScanUpdt = 0.2;        pvPut(piScanUpdt);   epicsThreadSleep(0.001);
               piScanLinr = 0;          pvPut(piScanLinr);   epicsThreadSleep(0.001);
               piScanAbslt = 0;         pvPut(piScanAbslt);  epicsThreadSleep(0.001);
               piScanPeakP = 3;         pvPut(piScanPeakP);  epicsThreadSleep(0.001);
	       piScanCntr = actPitch;   pvPut(piScanCntr);   epicsThreadSleep(0.001);
	       piScanWdth = scWdth;     pvPut(piScanWdth);   epicsThreadSleep(0.001);
	       piScanStep = scStep;     pvPut(piScanStep);   epicsThreadSleep(0.001);
	       epicsThreadSleep(0.1);
	       piScanStart = 1;         pvPut(piScanStart);  epicsThreadSleep(0.001);
	       efClear(optpi_f);  epicsThreadSleep(0.001);
               if(thEnaBtn == 1) {
                    efSet(optth_f); epicsThreadSleep(0.001);
               }
	       else { efClear(optth_f); epicsThreadSleep(0.001); }
	       printf("state move_en: leavingg scan Pitch.\n");
         } state move_en
	 when (efTest(optth_f) && EnRunPrg == 0 && piScanBusy == 0 && delay(1)) {
	       printf("state move_en: entering scan Theta.\n");
               chEnWrkng = 1;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
	       thWrkng = 1;  pvPut(thWrkng);   epicsThreadSleep(0.001);
	       detMode = 1;       pvPut(detMode);  epicsThreadSleep(0.001);
	       sprintf(msgQ,  "Optimize piezo."); efSet(msg_f); epicsThreadSleep(0.001);
	       printf("opt-theta: Optimizing Theta with piezo drive.\n");
	       maxTheta = curTheta;  maxCnts = 0;
	       line = 0; step = thStep;
 %%	       do {
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
			if(line == 1) { step = -step; maxCnts = 0;   printf("opt-theta: Reverse direction.\n");}
			else  { printf("opt-theta: Optimization finished.\n");  break; }
		    }
		    line++;
	            /* if (line>9) {step = 5.*thStep; line=0;} */
		    curTheta += step;
		    if (curTheta < -4.9 || curTheta > 4.9) {
	                  sprintf(msgQ,  "**Theta out of range."); efSet(msg_f); epicsThreadSleep(0.001);
                          printf("opt-theta: **Theta out of range. Stop.\n");
		          break;
	            }
	            printf("opt-theta: curTheta=%f.\n",curTheta);
		    pvPut(curTheta); epicsThreadSleep(0.1);
%%	       } while(1);
               printf("opt-theta: Exit the loop. Final theta=%f.\n", maxTheta);
	       line = 0;
	       curTheta = maxTheta - 100.0 * step;
	       if(curTheta < -4.9 || curTheta > 4.9) { pvPut(curTheta); epicsThreadSleep(0.001); }
	       curTheta = maxTheta; pvPut(curTheta); epicsThreadSleep(0.001);
               efClear(optth_f);   epicsThreadSleep(0.001);
	       efSet(finished);    epicsThreadSleep(0.001);
	       efClear(moveen_f);  epicsThreadSleep(0.001); efClear(moveid_f);  epicsThreadSleep(0.001);
	       efClear(movechi_f); epicsThreadSleep(0.001);
               efClear(movevfm_f); epicsThreadSleep(0.001);  efClear(movehfm_f); epicsThreadSleep(0.001);
	       efClear(optpi_f);   epicsThreadSleep(0.001); efClear(optth_f);   epicsThreadSleep(0.001);
	       thWrkng = 0;  pvPut(thWrkng);   epicsThreadSleep(0.001);
	       printf("state move_en: leaving scan Theta.\n");
	 } state move_en
	 when(efTest(finished)) {
               chEnWrkng = 0;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
	       efClear(finished); epicsThreadSleep(0.001);
	       sprintf(msgQ,  "Ready."); efSet(msg_f); epicsThreadSleep(0.001);
               printf("move_en: Theta opt finished. Ready.\n");
	 } state init2
	when (efTest(undo_f) && undoBtn == 1) {
	        printf("undo: when undo_f .\n");
                chEnWrkng = 1;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
                EnAbort = 1;    pvPut(EnAbort);   epicsThreadSleep(0.001);
		rqsPosEn = startEn;  pvPut(rqsPosEn);   epicsThreadSleep(0.001);
                printf("undo: Moving En to %f.).\n", startEn);
	        if(idEnaBtn == 1)  {
                       if(IDStatus == 1) {IDStop = 1;    pvPut(IDStop);    epicsThreadSleep(0.1);}
		       rqsHrmID = startHrmID;  pvPut(rqsHrmID); epicsThreadSleep(0.001);
		       rqsEnID  = startEnID;   printf("undo: Moving ID to %f.\n", rqsEnID);
		       pvPut(rqsEnID);  epicsThreadSleep(0.001);
                       IDStart = 1; pvPut(IDStart); epicsThreadSleep(0.001);
	        }
		if(vfmEnaBtn == 1) {
                      VFMAbort = 1;            pvPut(VFMAbort);  epicsThreadSleep(0.001);
		      rqsLnVFM = startLnVFM;   pvPut(rqsLnVFM);  epicsThreadSleep(0.001);
                      printf("undo: Moving VFM to %f.).\n", rqsLnVFM);
                }
		if(hfmEnaBtn == 1) {
		      HFMAbort = 1;            pvPut(HFMAbort);  epicsThreadSleep(0.001);
		      rqsLnHFM = startLnHFM;   pvPut(rqsLnHFM);  epicsThreadSleep(0.001);
                      printf("undo: Moving HFM to %f.).\n", rqsLnHFM);
                }
		/* Pitch scan should be aborted before abortion of the Pi-Chi assembly */
		if(piEnaBtn == 1)  {
		       if(piScanBusy == 1) {
                            piScanAbort = 1;   pvPut(piScanAbort);  epicsThreadSleep(0.1);
		            piScanAbort = 1;   pvPut(piScanAbort);  epicsThreadSleep(0.1);
			    epicsThreadSleep(0.5);
                            printf("undo: Abort pitch scan.\n");
                       }
                       ChiAbort = 1;  pvPut(ChiAbort);  epicsThreadSleep(0.1);
		       rqsPitch = startPi;  pvPut(rqsPitch);  epicsThreadSleep(0.1);
                       printf("undo: Moving Pitch to %f.).\n", rqsPitch);
		}
                if(chiEnaBtn == 1) {
                       if(ChiRunPrg == 0) {ChiAbort = 1;  pvPut(ChiAbort);  epicsThreadSleep(0.001);}
		       rqsPosChi = startChi;  pvPut(rqsPosChi);  epicsThreadSleep(0.001);
                       printf("undo: Moving CHI to %f.).\n", rqsPosChi);
                }
                if(thEnaBtn == 1) {curTheta = startTh;  pvPut(curTheta);  epicsThreadSleep(0.001); }
                printf("undo: Moving Theta to %f.).\n", curTheta);
		epicsThreadSleep(0.5);
             /*   if(EnRunPrg == 0) {EnKill = 1;  pvPut(EnKill); epicsThreadSleep(0.001);}   */
	     /*	if(chiEnaBtn == 1 && ChiRunPrg == 0)  { pvPut(ChiKill);  epicsThreadSleep(0.001);}  */
	     /*	if(vfmEnaBtn == 1 && VFMRunPrg == 0)  { VFMKill = 1;   pvPut(VFMKill);  epicsThreadSleep(0.001);} */
	     /*	if(hfmEnaBtn == 1 && HFMRunPrg == 0)  { HFMKill = 1;   pvPut(HFMKill);  epicsThreadSleep(0.001);} */
	        detMode = 1;        pvPut(detMode);  epicsThreadSleep(0.001);
	        sprintf(msgQ, "Undo finished. Ready."); efSet(msg_f); epicsThreadSleep(0.001);
		efClear(moveen_f);  epicsThreadSleep(0.001); efClear(moveid_f);  epicsThreadSleep(0.001);
		efClear(movechi_f); epicsThreadSleep(0.001);
                efClear(movevfm_f); epicsThreadSleep(0.001);  efClear(movehfm_f); epicsThreadSleep(0.001);
		efClear(optpi_f);   epicsThreadSleep(0.001); efClear(optth_f);   epicsThreadSleep(0.001);
		startBtn = 0;  pvPut(startBtn); epicsThreadSleep(0.001); efClear(start_f); epicsThreadSleep(0.001);
	        abortBtn = 0;  pvPut(abortBtn); epicsThreadSleep(0.001); efClear(abort_f); epicsThreadSleep(0.001);
		undoBtn = 0;   pvPut(undoBtn);  epicsThreadSleep(0.001); efClear(undo_f);  epicsThreadSleep(0.001);
	        thWrkng = 0;   pvPut(thWrkng);  epicsThreadSleep(0.001);
                chEnWrkng = 0;     pvPut(chEnWrkng);  epicsThreadSleep(0.001);
	 } state init2
    }
}

