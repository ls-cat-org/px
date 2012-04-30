/* SNC Version 2.0.12: Fri May 28 19:40:48 2010: change_en.i */

/* Event flags */
#define start_f	1
#define abort_f	2
#define clean_f	3
#define undo_f	4
#define msg_f	5
#define moveen_f	6
#define movechi_f	7
#define moveid_f	8
#define movevfm_f	9
#define movehfm_f	10
#define optpi_f	11
#define optth_f	12
#define finished	13

/* Program "change_en" */
#include "seqCom.h"

#define NUM_SS 2
#define NUM_CHANNELS 92
#define NUM_EVENTS 13
#define NUM_QUEUES 0

#define MAX_STRING_SIZE 40

#define ASYNC_OPT FALSE
#define CONN_OPT TRUE
#define DEBUG_OPT FALSE
#define MAIN_OPT FALSE
#define NEWEF_OPT TRUE
#define REENT_OPT TRUE

extern struct seqProgram change_en;

/* Variable declarations */
struct UserVar {
	char	time_str[80];
	int	status;
	int	msgI;
	int	i;
	int	j;
	int	line;
	double	deltaEn;
	double	finishEn;
	double	maxTheta;
	double	maxCnts;
	double	cnts;
	double	step;
	double	tmpdb;
	double	startEn;
	double	startEnID;
	double	startHrmID;
	double	startChi;
	double	startPi;
	double	startTh;
	double	startLnHFM;
	double	startLnVFM;
	int	startBtn;
	int	abortBtn;
	int	cleanBtn;
	int	undoBtn;
	int	abortCentr;
	int	centrWrkng;
	int	tbMiSwBtn;
	int	imgHCentr;
	int	imgVCentr;
	int	chEnWrkng;
	int	thWrkng;
	int	idEnaBtn;
	int	chiEnaBtn;
	int	vfmEnaBtn;
	int	hfmEnaBtn;
	int	piEnaBtn;
	int	thEnaBtn;
	double	newEn;
	double	hrmSwEn;
	double	idOff1;
	double	idOff2;
	double	chiSca;
	double	chiOff;
	double	vfmPd;
	double	vfmGl;
	double	vfmPt;
	double	hfmPd;
	double	hfmGl;
	double	hfmPt;
	double	scWdth;
	double	scStep;
	double	thStep;
	double	detCnts;
	int	detMode;
	char	piScanNm[MAX_STRING_SIZE];
	int	piScanBusy;
	int	piScanStart;
	int	piScanAbort;
	int	piScanCmnd;
	int	piScanLinr;
	int	piScanAbslt;
	int	piScanPeakP;
	double	piScanCntr;
	double	piScanWdth;
	double	piScanStep;
	char	piScanDet[MAX_STRING_SIZE];
	float	piScanPosStl;
	float	piScanDetStl;
	float	piScanUpdt;
	char	piScanPosRd[MAX_STRING_SIZE];
	char	piScanPosDr[MAX_STRING_SIZE];
	char	piScanDtTrg[MAX_STRING_SIZE];
	char	piScanAfter[MAX_STRING_SIZE];
	double	actEn;
	double	rqsPosEn;
	long	EnAbort;
	long	EnKill;
	long	EnRunPrg;
	double	actEnID;
	double	rqsEnID;
	double	rqsHrmID;
	int	IDStart;
	int	IDStop;
	int	IDStatus;
	double	actChi;
	double	rqsPosChi;
	long	ChiAbort;
	long	ChiKill;
	long	ChiRunPrg;
	double	actPitch;
	double	rqsPitch;
	double	curTheta;
	double	actLnVFM;
	double	rqsLnVFM;
	long	VFMAbort;
	long	VFMKill;
	long	VFMRunPrg;
	double	actLnHFM;
	double	rqsLnHFM;
	long	HFMAbort;
	long	HFMKill;
	long	HFMRunPrg;
	char	msgQ[MAX_STRING_SIZE];
	char	msg[10][MAX_STRING_SIZE];
};

/* C code definitions */
# line 6 "../change_en.st"
#include <string.h>
# line 7 "../change_en.st"
#include <math.h>
# line 8 "../change_en.st"
#include <tsDefs.h>
# line 28 "../change_en.h"
TS_STAMP tmc;

/* Entry handler */
static void entry_handler(SS_ID ssId, struct UserVar *pVar)
{
}

/* Code for state "init" in state set "set1" */

/* Delay function for state "init" in state set "set1" */
static void D_set1_init(SS_ID ssId, struct UserVar *pVar)
{
# line 52 "../change_en.st"
}

/* Event function for state "init" in state set "set1" */
static long E_set1_init(SS_ID ssId, struct UserVar *pVar, short *pTransNum, short *pNextState)
{
# line 52 "../change_en.st"
	if (TRUE)
	{
		*pNextState = 1;
		*pTransNum = 0;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "init" in state set "set1" */
static void A_set1_init(SS_ID ssId, struct UserVar *pVar, short transNum)
{
	switch(transNum)
	{
	case 0:
		{
# line 14 "../change_en.st"
			(pVar->newEn) = (pVar->actEn);
# line 14 "../change_en.st"
			seq_pvPut(ssId, 17 /* newEn */, 0);
# line 14 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("Init state: actEn=%f, newEn=%f.\n", (pVar->actEn), (pVar->rqsPosEn));
			(pVar->tmpdb) = 0.0;
			(pVar->thWrkng) = 0;
# line 17 "../change_en.st"
			seq_pvPut(ssId, 10 /* thWrkng */, 0);
# line 17 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->chEnWrkng) = 0;
# line 18 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 18 "../change_en.st"
			epicsThreadSleep(0.001);
# line 37 "../change_en.st"
			strcpy((pVar->piScanPosRd), "21:C1:MO:P2:ActPos");
			strcpy((pVar->piScanPosDr), "21:C1:MO:P2:RqsPos");
			strcpy((pVar->piScanDtTrg), "21:D1:scaler1.CNT");
			strcpy((pVar->piScanDet), "21:D1:scaler1_calc5.VAL");
			strcpy((pVar->piScanAfter), "21:C1:MO:Tn:Kill");
# line 45 "../change_en.st"
			seq_efClear(ssId, clean_f);
# line 45 "../change_en.st"
			epicsThreadSleep(0.001);
# line 45 "../change_en.st"
			(pVar->msgI) = 9;
			(pVar->startBtn) = 0;
# line 46 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 46 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, start_f);
# line 47 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->abortBtn) = 0;
# line 48 "../change_en.st"
			seq_pvPut(ssId, 1 /* abortBtn */, 0);
# line 48 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->thWrkng) = 0;
# line 49 "../change_en.st"
			seq_pvPut(ssId, 10 /* thWrkng */, 0);
# line 49 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, abort_f);
# line 50 "../change_en.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "Ready.");
# line 51 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 51 "../change_en.st"
			epicsThreadSleep(0.001);
		}
		return;
	}
}
/* Code for state "mntr" in state set "set1" */

/* Delay function for state "mntr" in state set "set1" */
static void D_set1_mntr(SS_ID ssId, struct UserVar *pVar)
{
# line 72 "../change_en.st"
# line 102 "../change_en.st"
# line 108 "../change_en.st"
# line 114 "../change_en.st"
# line 120 "../change_en.st"
# line 126 "../change_en.st"
# line 132 "../change_en.st"
# line 138 "../change_en.st"
# line 144 "../change_en.st"
# line 150 "../change_en.st"
# line 169 "../change_en.st"
# line 176 "../change_en.st"
# line 236 "../change_en.st"
}

/* Event function for state "mntr" in state set "set1" */
static long E_set1_mntr(SS_ID ssId, struct UserVar *pVar, short *pTransNum, short *pNextState)
{
# line 72 "../change_en.st"
	if (seq_efTestAndClear(ssId, msg_f))
	{
		*pNextState = 1;
		*pTransNum = 0;
		return TRUE;
	}
# line 102 "../change_en.st"
	if (seq_efTest(ssId, abort_f) && (pVar->abortBtn) == 1)
	{
		*pNextState = 1;
		*pTransNum = 1;
		return TRUE;
	}
# line 108 "../change_en.st"
	if (seq_efTest(ssId, start_f) && (pVar->startBtn) == 1 && (pVar->EnRunPrg) == 1)
	{
		*pNextState = 1;
		*pTransNum = 2;
		return TRUE;
	}
# line 114 "../change_en.st"
	if (seq_efTest(ssId, start_f) && (pVar->startBtn) == 1 && (pVar->idEnaBtn) == 1 && (pVar->IDStatus) == 1)
	{
		*pNextState = 1;
		*pTransNum = 3;
		return TRUE;
	}
# line 120 "../change_en.st"
	if (seq_efTest(ssId, start_f) && (pVar->startBtn) == 1 && (pVar->chiEnaBtn) == 1 && (pVar->ChiRunPrg) == 1)
	{
		*pNextState = 1;
		*pTransNum = 4;
		return TRUE;
	}
# line 126 "../change_en.st"
	if (seq_efTest(ssId, start_f) && (pVar->startBtn) == 1 && (pVar->vfmEnaBtn) == 1 && (pVar->VFMRunPrg) == 1)
	{
		*pNextState = 1;
		*pTransNum = 5;
		return TRUE;
	}
# line 132 "../change_en.st"
	if (seq_efTest(ssId, start_f) && (pVar->startBtn) == 1 && (pVar->hfmEnaBtn) == 1 && (pVar->HFMRunPrg) == 1)
	{
		*pNextState = 1;
		*pTransNum = 6;
		return TRUE;
	}
# line 138 "../change_en.st"
	if (seq_efTest(ssId, start_f) && (pVar->startBtn) == 1 && (pVar->piEnaBtn) == 1 && (pVar->piScanBusy) == 1)
	{
		*pNextState = 1;
		*pTransNum = 7;
		return TRUE;
	}
# line 144 "../change_en.st"
	if (seq_efTest(ssId, start_f) && (pVar->startBtn) == 1 && ((pVar->newEn) < 5.0 || (pVar->newEn) > 22.0))
	{
		*pNextState = 1;
		*pTransNum = 8;
		return TRUE;
	}
# line 150 "../change_en.st"
	if (seq_efTest(ssId, start_f) && (pVar->startBtn) == 1 && (pVar->centrWrkng) == 1)
	{
		*pNextState = 1;
		*pTransNum = 9;
		return TRUE;
	}
# line 169 "../change_en.st"
	if (seq_efTest(ssId, start_f) && (pVar->startBtn) == 1 && ((pVar->newEn) >= 5.0 && (pVar->newEn) <= 22.0))
	{
		*pNextState = 1;
		*pTransNum = 10;
		return TRUE;
	}
# line 176 "../change_en.st"
	if (seq_efTestAndClear(ssId, clean_f))
	{
		*pNextState = 1;
		*pTransNum = 11;
		return TRUE;
	}
# line 236 "../change_en.st"
	if (seq_efTest(ssId, undo_f) && (pVar->undoBtn) == 1)
	{
		*pNextState = 1;
		*pTransNum = 12;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "mntr" in state set "set1" */
static void A_set1_mntr(SS_ID ssId, struct UserVar *pVar, short transNum)
{
	switch(transNum)
	{
	case 0:
		{
# line 57 "../change_en.st"
			printf("state mntr: entering msg.\n");
# line 59 "../change_en.st"
 tsLocalTime(&tmc);
 tsStampToText (&tmc, TS_TEXT_MMDDYY, pVar->time_str);
# line 68 "../change_en.st"
			if (strstr((pVar->msg)[(pVar->msgI)], (pVar->msgQ)) == NULL)
			{
				if ((pVar->msgI) > 0)
				{
					(pVar->msgI) -= 1;
				}
				else
				{
					for ((pVar->i) = 9; (pVar->i) > 0; (pVar->i)--)
					{
						strcpy((pVar->msg)[(pVar->i)], (pVar->msg)[(pVar->i) - 1]);
						seq_pvPut(ssId, 82 /* msg */ + ((pVar->i)), 0);
						epicsThreadSleep(0.001);
					}
				}
			}
# line 69 "../change_en.st"
			sprintf((pVar->msg)[(pVar->msgI)], "%8.8s %s",  & (pVar->time_str)[9], (pVar->msgQ));
# line 69 "../change_en.st"
			seq_pvPut(ssId, 82 /* msg */ + ((pVar->msgI)), 0);
# line 69 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, msg_f);
# line 70 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state mntr: leaving msg.\n");
		}
		return;
	case 1:
		{
# line 74 "../change_en.st"
			printf("state mntr: entering abort.\n");
			(pVar->EnAbort) = 1;
# line 75 "../change_en.st"
			seq_pvPut(ssId, 55 /* EnAbort */, 0);
# line 75 "../change_en.st"
			epicsThreadSleep(0.001);
			if ((pVar->idEnaBtn) == 1)
			{
				(pVar->IDStop) = 1;
				seq_pvPut(ssId, 62 /* IDStop */, 0);
				epicsThreadSleep(0.001);
			}
# line 77 "../change_en.st"
			if ((pVar->chiEnaBtn) == 1)
			{
				(pVar->ChiAbort) = 1;
				seq_pvPut(ssId, 66 /* ChiAbort */, 0);
				epicsThreadSleep(0.001);
			}
# line 78 "../change_en.st"
			if ((pVar->vfmEnaBtn) == 1)
			{
				(pVar->VFMAbort) = 1;
				seq_pvPut(ssId, 74 /* VFMAbort */, 0);
				epicsThreadSleep(0.001);
			}
# line 79 "../change_en.st"
			if ((pVar->hfmEnaBtn) == 1)
			{
				(pVar->HFMAbort) = 1;
				seq_pvPut(ssId, 79 /* HFMAbort */, 0);
				epicsThreadSleep(0.001);
			}
# line 84 "../change_en.st"
			if ((pVar->piEnaBtn) == 1)
			{
				(pVar->piScanAbort) = 1;
				seq_pvPut(ssId, 37 /* piScanAbort */, 0);
				epicsThreadSleep(0.1);
				(pVar->piScanAbort) = 1;
				seq_pvPut(ssId, 37 /* piScanAbort */, 0);
				epicsThreadSleep(0.1);
			}
# line 85 "../change_en.st"
			epicsThreadSleep(0.5);
			(pVar->EnKill) = 1;
# line 86 "../change_en.st"
			seq_pvPut(ssId, 56 /* EnKill */, 0);
			if ((pVar->chiEnaBtn) == 1)
			{
				(pVar->ChiKill) = 1;
				seq_pvPut(ssId, 67 /* ChiKill */, 0);
				epicsThreadSleep(0.001);
			}
# line 88 "../change_en.st"
			if ((pVar->vfmEnaBtn) == 1)
			{
				(pVar->VFMKill) = 1;
				seq_pvPut(ssId, 75 /* VFMKill */, 0);
				epicsThreadSleep(0.001);
			}
# line 89 "../change_en.st"
			if ((pVar->hfmEnaBtn) == 1)
			{
				(pVar->HFMKill) = 1;
				seq_pvPut(ssId, 80 /* HFMKill */, 0);
				epicsThreadSleep(0.001);
			}
# line 90 "../change_en.st"
			(pVar->detMode) = 1;
# line 90 "../change_en.st"
			seq_pvPut(ssId, 33 /* detMode */, 0);
# line 90 "../change_en.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "**Job aborted. Ready.");
# line 91 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 91 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state mntr: **Job is aborted. Ready.\n");
			seq_efClear(ssId, moveen_f);
# line 93 "../change_en.st"
			epicsThreadSleep(0.001);
# line 93 "../change_en.st"
			seq_efClear(ssId, moveid_f);
# line 93 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movechi_f);
# line 94 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movevfm_f);
# line 95 "../change_en.st"
			epicsThreadSleep(0.001);
# line 95 "../change_en.st"
			seq_efClear(ssId, movehfm_f);
# line 95 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, optpi_f);
# line 96 "../change_en.st"
			epicsThreadSleep(0.001);
# line 96 "../change_en.st"
			seq_efClear(ssId, optth_f);
# line 96 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->startBtn) = 0;
# line 97 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 97 "../change_en.st"
			epicsThreadSleep(0.001);
# line 97 "../change_en.st"
			seq_efClear(ssId, start_f);
# line 97 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->abortBtn) = 0;
# line 98 "../change_en.st"
			seq_pvPut(ssId, 1 /* abortBtn */, 0);
# line 98 "../change_en.st"
			epicsThreadSleep(0.001);
# line 98 "../change_en.st"
			seq_efClear(ssId, abort_f);
# line 98 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->thWrkng) = 0;
# line 99 "../change_en.st"
			seq_pvPut(ssId, 10 /* thWrkng */, 0);
# line 99 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->chEnWrkng) = 0;
# line 100 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 100 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state mntr: leaving abort.\n");
		}
		return;
	case 2:
		{
# line 104 "../change_en.st"
			sprintf((pVar->msgQ), "**Energy assembly moving");
# line 104 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 104 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state mntr: Energy assembly is still moving. Quit.\n");
			(pVar->startBtn) = 0;
# line 106 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 106 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, start_f);
# line 107 "../change_en.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 3:
		{
# line 110 "../change_en.st"
			sprintf((pVar->msgQ), "**Undulator is moving.");
# line 110 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 110 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state mntr: Undulator is still moving. Quit.\n");
			(pVar->startBtn) = 0;
# line 112 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 112 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, start_f);
# line 113 "../change_en.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 4:
		{
# line 116 "../change_en.st"
			sprintf((pVar->msgQ), "**CHI or Pitch moving");
# line 116 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 116 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state mntr: CHI or Pitch axis is still moving. Quit.\n");
			(pVar->startBtn) = 0;
# line 118 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 118 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, start_f);
# line 119 "../change_en.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 5:
		{
# line 122 "../change_en.st"
			sprintf((pVar->msgQ), "**VFMirror still moving.");
# line 122 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 122 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state mntr: VFMirror still moving. Quit.\n");
			(pVar->startBtn) = 0;
# line 124 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 124 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, start_f);
# line 125 "../change_en.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 6:
		{
# line 128 "../change_en.st"
			sprintf((pVar->msgQ), "**HFMirror still moving.");
# line 128 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 128 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state mntr: HFMirror still moving. Quit.\n");
			(pVar->startBtn) = 0;
# line 130 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 130 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, start_f);
# line 131 "../change_en.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 7:
		{
# line 134 "../change_en.st"
			sprintf((pVar->msgQ), "**Pitch still optimized.");
# line 134 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 134 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state mntr: Pitch Scan is still working. Quit.\n");
			(pVar->startBtn) = 0;
# line 136 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 136 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, start_f);
# line 137 "../change_en.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 8:
		{
# line 140 "../change_en.st"
			sprintf((pVar->msgQ), "**Energy out of range.");
# line 140 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 140 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state mntr: Requested Energy is out of range, ENERGYMIN=%f, ENERGYMAX=%f.\n", 5.0, 22.0);
			(pVar->startBtn) = 0;
# line 142 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 142 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, start_f);
# line 143 "../change_en.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 9:
		{
# line 146 "../change_en.st"
			sprintf((pVar->msgQ), "**Center-Beam working.");
# line 146 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 146 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state mntr: Center-Beam script is working.\n");
			(pVar->startBtn) = 0;
# line 148 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 148 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, start_f);
# line 149 "../change_en.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 10:
		{
# line 152 "../change_en.st"
			printf("state mntr: entering last when where move_en_f is set.\n");
			(pVar->startEn) = (pVar->actEn);
# line 153 "../change_en.st"
			(pVar->finishEn) = (pVar->newEn);
# line 153 "../change_en.st"
			(pVar->deltaEn) = (pVar->actEn) - (pVar->newEn);
			if ((pVar->deltaEn) < 0)
				(pVar->deltaEn) = (pVar->newEn) - (pVar->actEn);
# line 155 "../change_en.st"
			sprintf((pVar->msgQ), "Preparing to move.");
# line 155 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 155 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("Preparing to combined motion.\n");
			(pVar->startBtn) = 0;
# line 157 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 157 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, start_f);
# line 158 "../change_en.st"
			epicsThreadSleep(0.001);
# line 160 "../change_en.st"
			seq_pvGet(ssId, 58 /* actEnID */, 0);
# line 160 "../change_en.st"
			epicsThreadSleep(0.001);
# line 160 "../change_en.st"
			(pVar->startEnID) = (pVar->actEnID);
			seq_pvGet(ssId, 60 /* rqsHrmID */, 0);
# line 161 "../change_en.st"
			epicsThreadSleep(0.001);
# line 161 "../change_en.st"
			(pVar->startHrmID) = (pVar->rqsHrmID);
			seq_pvGet(ssId, 64 /* actChi */, 0);
# line 162 "../change_en.st"
			epicsThreadSleep(0.001);
# line 162 "../change_en.st"
			(pVar->startChi) = (pVar->actChi);
			seq_pvGet(ssId, 69 /* actPitch */, 0);
# line 163 "../change_en.st"
			epicsThreadSleep(0.001);
# line 163 "../change_en.st"
			(pVar->startPi) = (pVar->actPitch);
			seq_pvGet(ssId, 77 /* actLnHFM */, 0);
# line 164 "../change_en.st"
			epicsThreadSleep(0.001);
# line 164 "../change_en.st"
			(pVar->startLnHFM) = (pVar->actLnHFM);
			seq_pvGet(ssId, 72 /* actLnVFM */, 0);
# line 165 "../change_en.st"
			epicsThreadSleep(0.001);
# line 165 "../change_en.st"
			(pVar->startLnVFM) = (pVar->actLnVFM);
			seq_pvGet(ssId, 71 /* curTheta */, 0);
# line 166 "../change_en.st"
			epicsThreadSleep(0.001);
# line 166 "../change_en.st"
			(pVar->startTh) = (pVar->curTheta);
			seq_efSet(ssId, moveen_f);
# line 167 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state mntr: leaving last when where move_en_f is set.\n");
		}
		return;
	case 11:
		{
# line 173 "../change_en.st"
			for ((pVar->i) = 9; (pVar->i) >= 0; (pVar->i)--)
			{
				strcpy((pVar->msg)[(pVar->i)], "");
				seq_pvPut(ssId, 82 /* msg */ + ((pVar->i)), 0);
				epicsThreadSleep(0.001);
			}
# line 174 "../change_en.st"
			strcpy((pVar->msg)[9], "Ready");
# line 174 "../change_en.st"
			seq_pvPut(ssId, 82 /* msg */ + (9), 0);
# line 174 "../change_en.st"
			epicsThreadSleep(0.001);
# line 174 "../change_en.st"
			(pVar->msgI) = 9;
			(pVar->cleanBtn) = 0;
# line 175 "../change_en.st"
			seq_pvPut(ssId, 2 /* cleanBtn */, 0);
# line 175 "../change_en.st"
			epicsThreadSleep(0.001);
# line 175 "../change_en.st"
			seq_efClear(ssId, clean_f);
# line 175 "../change_en.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 12:
		{
# line 178 "../change_en.st"
			printf("mntr: entering undo.\n");
			(pVar->chEnWrkng) = 1;
# line 179 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 179 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->EnAbort) = 1;
# line 180 "../change_en.st"
			seq_pvPut(ssId, 55 /* EnAbort */, 0);
# line 180 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->rqsPosEn) = (pVar->startEn);
# line 181 "../change_en.st"
			seq_pvPut(ssId, 54 /* rqsPosEn */, 0);
# line 181 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("undo: Moving En to %f.).\n", (pVar->startEn));
# line 189 "../change_en.st"
			if ((pVar->idEnaBtn) == 1)
			{
				if ((pVar->IDStatus) == 1)
				{
					(pVar->IDStop) = 1;
					seq_pvPut(ssId, 62 /* IDStop */, 0);
					epicsThreadSleep(0.1);
				}
				(pVar->rqsHrmID) = (pVar->startHrmID);
				seq_pvPut(ssId, 60 /* rqsHrmID */, 0);
				epicsThreadSleep(0.001);
				(pVar->rqsEnID) = (pVar->startEnID);
				printf("undo: Moving ID to %f.\n", (pVar->rqsEnID));
				seq_pvPut(ssId, 59 /* rqsEnID */, 0);
				epicsThreadSleep(0.001);
				(pVar->IDStart) = 1;
				seq_pvPut(ssId, 61 /* IDStart */, 0);
				epicsThreadSleep(0.001);
			}
# line 194 "../change_en.st"
			if ((pVar->vfmEnaBtn) == 1)
			{
				(pVar->VFMAbort) = 1;
				seq_pvPut(ssId, 74 /* VFMAbort */, 0);
				epicsThreadSleep(0.001);
				(pVar->rqsLnVFM) = (pVar->startLnVFM);
				seq_pvPut(ssId, 73 /* rqsLnVFM */, 0);
				epicsThreadSleep(0.001);
				printf("undo: Moving VFM to %f.).\n", (pVar->rqsLnVFM));
			}
# line 199 "../change_en.st"
			if ((pVar->hfmEnaBtn) == 1)
			{
				(pVar->HFMAbort) = 1;
				seq_pvPut(ssId, 79 /* HFMAbort */, 0);
				epicsThreadSleep(0.001);
				(pVar->rqsLnHFM) = (pVar->startLnHFM);
				seq_pvPut(ssId, 78 /* rqsLnHFM */, 0);
				epicsThreadSleep(0.001);
				printf("undo: Moving HFM to %f.).\n", (pVar->rqsLnHFM));
			}
# line 211 "../change_en.st"
			if ((pVar->piEnaBtn) == 1)
			{
				if ((pVar->piScanBusy) == 1)
				{
					(pVar->piScanAbort) = 1;
					seq_pvPut(ssId, 37 /* piScanAbort */, 0);
					epicsThreadSleep(0.1);
					(pVar->piScanAbort) = 1;
					seq_pvPut(ssId, 37 /* piScanAbort */, 0);
					epicsThreadSleep(0.1);
					epicsThreadSleep(0.5);
					printf("undo: Abort pitch scan.\n");
				}
				(pVar->ChiAbort) = 1;
				seq_pvPut(ssId, 66 /* ChiAbort */, 0);
				epicsThreadSleep(0.1);
				(pVar->rqsPitch) = (pVar->startPi);
				seq_pvPut(ssId, 70 /* rqsPitch */, 0);
				epicsThreadSleep(0.1);
				printf("undo: Moving Pitch to %f.).\n", (pVar->rqsPitch));
			}
# line 216 "../change_en.st"
			if ((pVar->chiEnaBtn) == 1)
			{
				if ((pVar->ChiRunPrg) == 0)
				{
					(pVar->ChiAbort) = 1;
					seq_pvPut(ssId, 66 /* ChiAbort */, 0);
					epicsThreadSleep(0.001);
				}
				(pVar->rqsPosChi) = (pVar->startChi);
				seq_pvPut(ssId, 65 /* rqsPosChi */, 0);
				epicsThreadSleep(0.001);
				printf("undo: Moving CHI to %f.).\n", (pVar->rqsPosChi));
			}
# line 217 "../change_en.st"
			if ((pVar->thEnaBtn) == 1)
			{
				(pVar->curTheta) = (pVar->startTh);
				seq_pvPut(ssId, 71 /* curTheta */, 0);
				epicsThreadSleep(0.001);
			}
# line 218 "../change_en.st"
			printf("undo: Moving Theta to %f.).\n", (pVar->curTheta));
			epicsThreadSleep(0.5);
# line 224 "../change_en.st"
			(pVar->detMode) = 1;
# line 224 "../change_en.st"
			seq_pvPut(ssId, 33 /* detMode */, 0);
# line 224 "../change_en.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "Undo finished. Ready.");
# line 225 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 225 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, moveen_f);
# line 226 "../change_en.st"
			epicsThreadSleep(0.001);
# line 226 "../change_en.st"
			seq_efClear(ssId, moveid_f);
# line 226 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movechi_f);
# line 227 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movevfm_f);
# line 228 "../change_en.st"
			epicsThreadSleep(0.001);
# line 228 "../change_en.st"
			seq_efClear(ssId, movehfm_f);
# line 228 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, optpi_f);
# line 229 "../change_en.st"
			epicsThreadSleep(0.001);
# line 229 "../change_en.st"
			seq_efClear(ssId, optth_f);
# line 229 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->startBtn) = 0;
# line 230 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 230 "../change_en.st"
			epicsThreadSleep(0.001);
# line 230 "../change_en.st"
			seq_efClear(ssId, start_f);
# line 230 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->abortBtn) = 0;
# line 231 "../change_en.st"
			seq_pvPut(ssId, 1 /* abortBtn */, 0);
# line 231 "../change_en.st"
			epicsThreadSleep(0.001);
# line 231 "../change_en.st"
			seq_efClear(ssId, abort_f);
# line 231 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->undoBtn) = 0;
# line 232 "../change_en.st"
			seq_pvPut(ssId, 3 /* undoBtn */, 0);
# line 232 "../change_en.st"
			epicsThreadSleep(0.001);
# line 232 "../change_en.st"
			seq_efClear(ssId, undo_f);
# line 232 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->thWrkng) = 0;
# line 233 "../change_en.st"
			seq_pvPut(ssId, 10 /* thWrkng */, 0);
# line 233 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->chEnWrkng) = 0;
# line 234 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 234 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("mntr: leaving undo.\n");
		}
		return;
	}
}
/* Code for state "init2" in state set "set2" */

/* Delay function for state "init2" in state set "set2" */
static void D_set2_init2(SS_ID ssId, struct UserVar *pVar)
{
# line 244 "../change_en.st"
}

/* Event function for state "init2" in state set "set2" */
static long E_set2_init2(SS_ID ssId, struct UserVar *pVar, short *pTransNum, short *pNextState)
{
# line 244 "../change_en.st"
	if (seq_efTest(ssId, moveen_f))
	{
		*pNextState = 1;
		*pTransNum = 0;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "init2" in state set "set2" */
static void A_set2_init2(SS_ID ssId, struct UserVar *pVar, short transNum)
{
	switch(transNum)
	{
	case 0:
		{
# line 243 "../change_en.st"
			epicsThreadSleep(0.001);
		}
		return;
	}
}
/* Code for state "move_en" in state set "set2" */

/* Delay function for state "move_en" in state set "set2" */
static void D_set2_move_en(SS_ID ssId, struct UserVar *pVar)
{
# line 263 "../change_en.st"
# line 292 "../change_en.st"
# line 312 "../change_en.st"
# line 332 "../change_en.st"
# line 350 "../change_en.st"
# line 367 "../change_en.st"
# line 395 "../change_en.st"
# line 423 "../change_en.st"
# line 433 "../change_en.st"
	seq_delayInit(ssId, 0, (480));
# line 468 "../change_en.st"
	seq_delayInit(ssId, 1, (1));
# line 519 "../change_en.st"
	seq_delayInit(ssId, 2, (1));
# line 525 "../change_en.st"
# line 584 "../change_en.st"
}

/* Event function for state "move_en" in state set "set2" */
static long E_set2_move_en(SS_ID ssId, struct UserVar *pVar, short *pTransNum, short *pNextState)
{
# line 263 "../change_en.st"
	if (seq_efTestAndClear(ssId, msg_f))
	{
		*pNextState = 1;
		*pTransNum = 0;
		return TRUE;
	}
# line 292 "../change_en.st"
	if (seq_efTest(ssId, abort_f) && (pVar->abortBtn) == 1)
	{
		*pNextState = 0;
		*pTransNum = 1;
		return TRUE;
	}
# line 312 "../change_en.st"
	if (seq_efTest(ssId, moveen_f) && (pVar->deltaEn) <= 0.1)
	{
		*pNextState = 1;
		*pTransNum = 2;
		return TRUE;
	}
# line 332 "../change_en.st"
	if (seq_efTest(ssId, moveen_f) && (pVar->deltaEn) > 0.1)
	{
		*pNextState = 1;
		*pTransNum = 3;
		return TRUE;
	}
# line 350 "../change_en.st"
	if (seq_efTest(ssId, movechi_f))
	{
		*pNextState = 1;
		*pTransNum = 4;
		return TRUE;
	}
# line 367 "../change_en.st"
	if (seq_efTest(ssId, moveid_f))
	{
		*pNextState = 1;
		*pTransNum = 5;
		return TRUE;
	}
# line 395 "../change_en.st"
	if (seq_efTest(ssId, movevfm_f))
	{
		*pNextState = 1;
		*pTransNum = 6;
		return TRUE;
	}
# line 423 "../change_en.st"
	if (seq_efTest(ssId, movehfm_f))
	{
		*pNextState = 1;
		*pTransNum = 7;
		return TRUE;
	}
# line 433 "../change_en.st"
	if (seq_delay(ssId, 0))
	{
		*pNextState = 0;
		*pTransNum = 8;
		return TRUE;
	}
# line 468 "../change_en.st"
	if (seq_efTest(ssId, optpi_f) && (pVar->EnRunPrg) == 0 && (pVar->ChiRunPrg) == 0 && (pVar->IDStatus) == 0 && (pVar->VFMRunPrg) == 0 && (pVar->HFMRunPrg) == 0 && seq_delay(ssId, 1))
	{
		*pNextState = 1;
		*pTransNum = 9;
		return TRUE;
	}
# line 519 "../change_en.st"
	if (seq_efTest(ssId, optth_f) && (pVar->EnRunPrg) == 0 && (pVar->piScanBusy) == 0 && seq_delay(ssId, 2))
	{
		*pNextState = 1;
		*pTransNum = 10;
		return TRUE;
	}
# line 525 "../change_en.st"
	if (seq_efTest(ssId, finished))
	{
		*pNextState = 0;
		*pTransNum = 11;
		return TRUE;
	}
# line 584 "../change_en.st"
	if (seq_efTest(ssId, undo_f) && (pVar->undoBtn) == 1)
	{
		*pNextState = 0;
		*pTransNum = 12;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "move_en" in state set "set2" */
static void A_set2_move_en(SS_ID ssId, struct UserVar *pVar, short transNum)
{
	switch(transNum)
	{
	case 0:
		{
# line 248 "../change_en.st"
			printf("state move_en: entering msg.\n");
# line 250 "../change_en.st"
 tsLocalTime(&tmc);
 tsStampToText (&tmc, TS_TEXT_MMDDYY, pVar->time_str);
# line 259 "../change_en.st"
			if (strstr((pVar->msg)[(pVar->msgI)], (pVar->msgQ)) == NULL)
			{
				if ((pVar->msgI) > 0)
				{
					(pVar->msgI) -= 1;
				}
				else
				{
					for ((pVar->i) = 9; (pVar->i) > 0; (pVar->i)--)
					{
						strcpy((pVar->msg)[(pVar->i)], (pVar->msg)[(pVar->i) - 1]);
						seq_pvPut(ssId, 82 /* msg */ + ((pVar->i)), 0);
						epicsThreadSleep(0.001);
					}
				}
			}
# line 260 "../change_en.st"
			sprintf((pVar->msg)[(pVar->msgI)], "%8.8s %s",  & (pVar->time_str)[9], (pVar->msgQ));
# line 260 "../change_en.st"
			seq_pvPut(ssId, 82 /* msg */ + ((pVar->msgI)), 0);
# line 260 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, msg_f);
# line 261 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state move_en: leaving msg.\n");
		}
		return;
	case 1:
		{
# line 265 "../change_en.st"
			printf("state move_en: entering abort.\n");
			(pVar->EnAbort) = 1;
# line 266 "../change_en.st"
			seq_pvPut(ssId, 55 /* EnAbort */, 0);
# line 266 "../change_en.st"
			epicsThreadSleep(0.001);
			if ((pVar->idEnaBtn) == 1)
			{
				(pVar->IDStop) = 1;
				seq_pvPut(ssId, 62 /* IDStop */, 0);
				epicsThreadSleep(0.001);
			}
# line 268 "../change_en.st"
			if ((pVar->chiEnaBtn) == 1)
			{
				(pVar->ChiAbort) = 1;
				seq_pvPut(ssId, 66 /* ChiAbort */, 0);
				epicsThreadSleep(0.001);
			}
# line 269 "../change_en.st"
			if ((pVar->vfmEnaBtn) == 1)
			{
				(pVar->VFMAbort) = 1;
				seq_pvPut(ssId, 74 /* VFMAbort */, 0);
				epicsThreadSleep(0.001);
			}
# line 270 "../change_en.st"
			if ((pVar->hfmEnaBtn) == 1)
			{
				(pVar->HFMAbort) = 1;
				seq_pvPut(ssId, 79 /* HFMAbort */, 0);
				epicsThreadSleep(0.001);
			}
# line 275 "../change_en.st"
			if ((pVar->piEnaBtn) == 1)
			{
				(pVar->piScanAbort) = 1;
				seq_pvPut(ssId, 37 /* piScanAbort */, 0);
				epicsThreadSleep(0.1);
				(pVar->piScanAbort) = 1;
				seq_pvPut(ssId, 37 /* piScanAbort */, 0);
				epicsThreadSleep(0.1);
			}
# line 276 "../change_en.st"
			epicsThreadSleep(0.5);
			(pVar->EnKill) = 1;
# line 277 "../change_en.st"
			seq_pvPut(ssId, 56 /* EnKill */, 0);
# line 277 "../change_en.st"
			epicsThreadSleep(0.001);
			if ((pVar->chiEnaBtn) == 1)
			{
				(pVar->ChiKill) = 1;
				seq_pvPut(ssId, 67 /* ChiKill */, 0);
				epicsThreadSleep(0.001);
			}
# line 279 "../change_en.st"
			if ((pVar->vfmEnaBtn) == 1)
			{
				(pVar->VFMKill) = 1;
				seq_pvPut(ssId, 75 /* VFMKill */, 0);
				epicsThreadSleep(0.001);
			}
# line 280 "../change_en.st"
			if ((pVar->hfmEnaBtn) == 1)
			{
				(pVar->HFMKill) = 1;
				seq_pvPut(ssId, 80 /* HFMKill */, 0);
				epicsThreadSleep(0.001);
			}
# line 281 "../change_en.st"
			(pVar->detMode) = 1;
# line 281 "../change_en.st"
			seq_pvPut(ssId, 33 /* detMode */, 0);
# line 281 "../change_en.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "**Job aborted. Ready.");
# line 282 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 282 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, moveen_f);
# line 283 "../change_en.st"
			epicsThreadSleep(0.001);
# line 283 "../change_en.st"
			seq_efClear(ssId, moveid_f);
# line 283 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movechi_f);
# line 284 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movevfm_f);
# line 285 "../change_en.st"
			epicsThreadSleep(0.001);
# line 285 "../change_en.st"
			seq_efClear(ssId, movehfm_f);
# line 285 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, optpi_f);
# line 286 "../change_en.st"
			epicsThreadSleep(0.001);
# line 286 "../change_en.st"
			seq_efClear(ssId, optth_f);
# line 286 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->startBtn) = 0;
# line 287 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 287 "../change_en.st"
			epicsThreadSleep(0.001);
# line 287 "../change_en.st"
			seq_efClear(ssId, start_f);
# line 287 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->abortBtn) = 0;
# line 288 "../change_en.st"
			seq_pvPut(ssId, 1 /* abortBtn */, 0);
# line 288 "../change_en.st"
			epicsThreadSleep(0.001);
# line 288 "../change_en.st"
			seq_efClear(ssId, abort_f);
# line 288 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->thWrkng) = 0;
# line 289 "../change_en.st"
			seq_pvPut(ssId, 10 /* thWrkng */, 0);
# line 289 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->chEnWrkng) = 0;
# line 290 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 290 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state move_en: leaving abort.\n");
		}
		return;
	case 2:
		{
# line 294 "../change_en.st"
			printf("state move_en: entering deltaEn < 0.1.\n");
			sprintf((pVar->msgQ), "En=%2.3f tuning Chi&Thet", (pVar->newEn));
# line 295 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 295 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state move: deltaEn < 0.1: Moving just Energy to %f. Plus optimization.\n", (pVar->newEn));
			(pVar->chEnWrkng) = 1;
# line 297 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 297 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->EnAbort) = 1;
# line 298 "../change_en.st"
			seq_pvPut(ssId, 55 /* EnAbort */, 0);
# line 298 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->rqsPosEn) = (pVar->newEn);
# line 299 "../change_en.st"
			seq_pvPut(ssId, 54 /* rqsPosEn */, 0);
# line 299 "../change_en.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(20);
			(pVar->EnKill) = 1;
# line 301 "../change_en.st"
			seq_pvPut(ssId, 56 /* EnKill */, 0);
# line 301 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, moveen_f);
# line 302 "../change_en.st"
			epicsThreadSleep(0.001);
# line 302 "../change_en.st"
			seq_efClear(ssId, moveid_f);
# line 302 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movevfm_f);
# line 303 "../change_en.st"
			epicsThreadSleep(0.001);
# line 303 "../change_en.st"
			seq_efClear(ssId, movehfm_f);
# line 303 "../change_en.st"
			epicsThreadSleep(0.001);
			if ((pVar->chiEnaBtn) == 1)
			{
				seq_efSet(ssId, movechi_f);
				epicsThreadSleep(0.001);
			}
# line 305 "../change_en.st"
			else
			{
				seq_efClear(ssId, movechi_f);
				epicsThreadSleep(0.001);
			}
# line 306 "../change_en.st"
			if ((pVar->piEnaBtn) == 1)
			{
				seq_efSet(ssId, optpi_f);
				epicsThreadSleep(0.001);
			}
# line 310 "../change_en.st"
			else
			{
				seq_efClear(ssId, optpi_f);
				epicsThreadSleep(0.001);
				seq_efClear(ssId, optth_f);
				epicsThreadSleep(0.001);
				seq_efClear(ssId, finished);
				epicsThreadSleep(0.001);
			}
# line 311 "../change_en.st"
			printf("state move_en: leaving deltaEn < 0.1.\n");
		}
		return;
	case 3:
		{
# line 314 "../change_en.st"
			printf("state move_en: entering move En to RqsPos.\n");
			sprintf((pVar->msgQ), "Move En to %2.3f.", (pVar->newEn));
# line 315 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 315 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state move: deltaEn >0.1: Moving Energy to %f.\n", (pVar->newEn));
			(pVar->chEnWrkng) = 1;
# line 317 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 317 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->EnAbort) = 1;
# line 318 "../change_en.st"
			seq_pvPut(ssId, 55 /* EnAbort */, 0);
# line 318 "../change_en.st"
			epicsThreadSleep(0.2);
			(pVar->rqsPosEn) = (pVar->newEn);
# line 319 "../change_en.st"
			seq_pvPut(ssId, 54 /* rqsPosEn */, 0);
# line 319 "../change_en.st"
			epicsThreadSleep(0.001);
			if ((pVar->chiEnaBtn) == 1)
			{
				seq_efSet(ssId, movechi_f);
				epicsThreadSleep(0.001);
			}
# line 321 "../change_en.st"
			else
			{
				seq_efClear(ssId, movechi_f);
				epicsThreadSleep(0.001);
			}
# line 322 "../change_en.st"
			if ((pVar->idEnaBtn) == 1)
			{
				seq_efSet(ssId, moveid_f);
				epicsThreadSleep(0.001);
			}
# line 323 "../change_en.st"
			else
			{
				seq_efClear(ssId, moveid_f);
				epicsThreadSleep(0.001);
			}
# line 324 "../change_en.st"
			if ((pVar->vfmEnaBtn) == 1)
			{
				seq_efSet(ssId, movevfm_f);
				epicsThreadSleep(0.001);
			}
# line 325 "../change_en.st"
			else
			{
				seq_efClear(ssId, movevfm_f);
				epicsThreadSleep(0.001);
			}
# line 326 "../change_en.st"
			if ((pVar->hfmEnaBtn) == 1)
			{
				seq_efSet(ssId, movehfm_f);
				epicsThreadSleep(0.001);
			}
# line 327 "../change_en.st"
			else
			{
				seq_efClear(ssId, movehfm_f);
				epicsThreadSleep(0.001);
			}
# line 328 "../change_en.st"
			if ((pVar->piEnaBtn) == 1)
			{
				seq_efSet(ssId, optpi_f);
				epicsThreadSleep(0.001);
			}
# line 329 "../change_en.st"
			else
			{
				seq_efClear(ssId, optpi_f);
				epicsThreadSleep(0.001);
				seq_efClear(ssId, optth_f);
				epicsThreadSleep(0.001);
				seq_efClear(ssId, finished);
				epicsThreadSleep(0.001);
			}
# line 330 "../change_en.st"
			seq_efClear(ssId, moveen_f);
# line 330 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state move_en: leavingg move En to RqsPos.\n");
		}
		return;
	case 4:
		{
# line 334 "../change_en.st"
			printf("state move_en: entering move Chi: startEn=%f, finishEn=%f, deltaEn=%f.\n", (pVar->startEn), (pVar->finishEn), (pVar->deltaEn));
# line 337 "../change_en.st"
			(pVar->chEnWrkng) = 1;
# line 337 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 337 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->ChiAbort) = 1;
# line 338 "../change_en.st"
			seq_pvPut(ssId, 66 /* ChiAbort */, 0);
# line 338 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->tmpdb) = (pVar->actChi) - ((pVar->startEn) * (pVar->chiSca));
# line 343 "../change_en.st"
			if ((pVar->tmpdb) > (-2.0) && (pVar->tmpdb) < 2.0)
			{
				(pVar->chiOff) = (pVar->tmpdb);
				seq_pvPut(ssId, 22 /* chiOff */, 0);
				epicsThreadSleep(0.001);
			}
# line 344 "../change_en.st"
			(pVar->rqsPosChi) = (pVar->finishEn) * (pVar->chiSca) + (pVar->chiOff);
			sprintf((pVar->msgQ), "Move CHI to %2.5f.", (pVar->rqsPosChi));
# line 345 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 345 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state move: deltaEn >0.1: Moving CHI to %f.\n", (pVar->rqsPosChi));
			seq_pvPut(ssId, 65 /* rqsPosChi */, 0);
# line 347 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movechi_f);
# line 348 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state move_en: leaving move Chi.\n");
		}
		return;
	case 5:
		{
# line 352 "../change_en.st"
			printf("state move_en: entering move ID.\n");
			(pVar->chEnWrkng) = 1;
# line 353 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 353 "../change_en.st"
			epicsThreadSleep(0.001);
# line 357 "../change_en.st"
			if ((pVar->finishEn) >= (pVar->hrmSwEn) && (pVar->hrmSwEn) > 12 && (pVar->hrmSwEn) < 13.5)
			{
				(pVar->rqsHrmID) = 3.0;
				seq_pvPut(ssId, 60 /* rqsHrmID */, 0);
				epicsThreadSleep(0.001);
				(pVar->rqsEnID) = (pVar->finishEn) + (pVar->idOff2);
			}
# line 361 "../change_en.st"
			else
			{
				(pVar->rqsHrmID) = 1.0;
				seq_pvPut(ssId, 60 /* rqsHrmID */, 0);
				epicsThreadSleep(0.001);
				(pVar->rqsEnID) = (pVar->finishEn) + (pVar->idOff1);
			}
# line 362 "../change_en.st"
			sprintf((pVar->msgQ), "Move ID to %2.3f.", (pVar->rqsEnID));
# line 362 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 362 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state move: deltaEn >0.1: Moving ID to %f.\n", (pVar->rqsEnID));
			seq_pvPut(ssId, 59 /* rqsEnID */, 0);
# line 364 "../change_en.st"
			epicsThreadSleep(0.001);
# line 364 "../change_en.st"
			(pVar->IDStart) = 1;
# line 364 "../change_en.st"
			seq_pvPut(ssId, 61 /* IDStart */, 0);
# line 364 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, moveid_f);
# line 365 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state move_en: leaving move ID.\n");
		}
		return;
	case 6:
		{
# line 369 "../change_en.st"
			printf("state move_en: entering move VFM.\n");
			(pVar->chEnWrkng) = 1;
# line 370 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 370 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("movevfm: finishEn=%f, startEn=%f.\n", (pVar->finishEn), (pVar->startEn));
# line 375 "../change_en.st"
			if ((pVar->finishEn) < 5.5)
			{
				if ((pVar->startEn) < 5.5 && ((pVar->actLnVFM) > -3.0 && (pVar->actLnVFM) < 6.0))
				{
					(pVar->i) = 0;
				}
				else
				{
					(pVar->rqsLnVFM) = (pVar->vfmGl);
					(pVar->i) = 1;
				}
			}
# line 379 "../change_en.st"
			else
			if ((pVar->finishEn) > 10.5)
			{
				if ((pVar->startEn) > 10.5 && ((pVar->actLnVFM) < -3.0 && (pVar->actLnVFM) > -16.0))
				{
					(pVar->i) = 0;
				}
				else
				{
					(pVar->rqsLnVFM) = (pVar->vfmPt);
					(pVar->i) = 1;
				}
			}
# line 383 "../change_en.st"
			else
			{
				if (((pVar->startEn) >= 5.5 && (pVar->startEn) <= 10.5) && ((pVar->actLnVFM) > 6.0 && (pVar->actLnVFM) < 20.0))
				{
					(pVar->i) = 0;
				}
				else
				{
					(pVar->rqsLnVFM) = (pVar->vfmPd);
					(pVar->i) = 1;
				}
			}
# line 387 "../change_en.st"
			if ((pVar->i) == 0)
			{
				sprintf((pVar->msgQ), "VFM cur. stripe fits.");
				seq_efSet(ssId, msg_f);
				epicsThreadSleep(0.001);
				printf("state move: deltaEn >0.1: Vfm current-stripe fits.\n");
			}
# line 392 "../change_en.st"
			else
			{
				sprintf((pVar->msgQ), "VFM to %2.1f.", (pVar->rqsLnVFM));
				seq_efSet(ssId, msg_f);
				epicsThreadSleep(0.001);
				printf("state move: deltaEn >0.1: Moving VFM to %f.\n", (pVar->rqsLnVFM));
				(pVar->VFMAbort) = 1;
				seq_pvPut(ssId, 74 /* VFMAbort */, 0);
				epicsThreadSleep(0.1);
				seq_pvPut(ssId, 73 /* rqsLnVFM */, 0);
				epicsThreadSleep(0.001);
			}
# line 393 "../change_en.st"
			seq_efClear(ssId, movevfm_f);
# line 393 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state move_en: leaving move VFM.\n");
		}
		return;
	case 7:
		{
# line 397 "../change_en.st"
			printf("state move_en: entering move HFM.\n");
			(pVar->chEnWrkng) = 1;
# line 398 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 398 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("movehfm: finishEn=%f, startEn=%f.\n", (pVar->finishEn), (pVar->startEn));
# line 403 "../change_en.st"
			if ((pVar->finishEn) < 5.5)
			{
				if ((pVar->startEn) < 5.5 && ((pVar->actLnHFM) > -10 && (pVar->actLnHFM) < 0.1))
				{
					(pVar->i) = 0;
				}
				else
				{
					(pVar->rqsLnHFM) = (pVar->hfmGl);
					(pVar->i) = 1;
				}
			}
# line 407 "../change_en.st"
			else
			if ((pVar->finishEn) > 10.5)
			{
				if ((pVar->startEn) > 10.5 && ((pVar->actLnHFM) < -10 && (pVar->actLnHFM) > -19.0))
				{
					(pVar->i) = 0;
				}
				else
				{
					(pVar->rqsLnHFM) = (pVar->hfmPt);
					(pVar->i) = 1;
				}
			}
# line 411 "../change_en.st"
			else
			{
				if (((pVar->startEn) >= 5.5 && (pVar->startEn) <= 10.5) && ((pVar->actLnHFM) > 0.1 && (pVar->actLnHFM) < 13.0))
				{
					(pVar->i) = 0;
				}
				else
				{
					(pVar->rqsLnHFM) = (pVar->hfmPd);
					(pVar->i) = 1;
				}
			}
# line 415 "../change_en.st"
			if ((pVar->i) == 0)
			{
				sprintf((pVar->msgQ), "HFM cur. stripe fits.");
				seq_efSet(ssId, msg_f);
				epicsThreadSleep(0.001);
				printf("state move: deltaEn >0.1: HFM current-stripe fits.\n");
			}
# line 420 "../change_en.st"
			else
			{
				sprintf((pVar->msgQ), "HFM to %2.1f.", (pVar->rqsLnHFM));
				seq_efSet(ssId, msg_f);
				epicsThreadSleep(0.001);
				printf("state move: deltaEn >0.1: Moving HFM to %f.\n", (pVar->rqsLnHFM));
				(pVar->HFMAbort) = 1;
				seq_pvPut(ssId, 79 /* HFMAbort */, 0);
				epicsThreadSleep(0.1);
				seq_pvPut(ssId, 78 /* rqsLnHFM */, 0);
				epicsThreadSleep(0.001);
			}
# line 421 "../change_en.st"
			seq_efClear(ssId, movehfm_f);
# line 421 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state move_en: leaving move HFM.\n");
		}
		return;
	case 8:
		{
# line 425 "../change_en.st"
			sprintf((pVar->msgQ), "**Timeout. Abort");
# line 425 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 425 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("move_en: Timeout. Abort.\n");
			seq_efClear(ssId, moveen_f);
# line 427 "../change_en.st"
			epicsThreadSleep(0.001);
# line 427 "../change_en.st"
			seq_efClear(ssId, moveid_f);
# line 427 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movechi_f);
# line 428 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movevfm_f);
# line 429 "../change_en.st"
			epicsThreadSleep(0.001);
# line 429 "../change_en.st"
			seq_efClear(ssId, movehfm_f);
# line 429 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, optpi_f);
# line 430 "../change_en.st"
			epicsThreadSleep(0.001);
# line 430 "../change_en.st"
			seq_efClear(ssId, optth_f);
# line 430 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, finished);
# line 431 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->abortBtn) = 1;
# line 432 "../change_en.st"
			seq_pvPut(ssId, 1 /* abortBtn */, 0);
# line 432 "../change_en.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 9:
		{
# line 435 "../change_en.st"
			printf("state move_en: entering scan Pitch.\n");
			(pVar->chEnWrkng) = 1;
# line 436 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 436 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->EnKill) = 1;
# line 437 "../change_en.st"
			seq_pvPut(ssId, 56 /* EnKill */, 0);
# line 437 "../change_en.st"
			epicsThreadSleep(0.001);
			if ((pVar->vfmEnaBtn) == 1)
			{
				(pVar->VFMKill) = 1;
				seq_pvPut(ssId, 75 /* VFMKill */, 0);
				epicsThreadSleep(0.001);
			}
# line 439 "../change_en.st"
			if ((pVar->hfmEnaBtn) == 1)
			{
				(pVar->HFMKill) = 1;
				seq_pvPut(ssId, 80 /* HFMKill */, 0);
				epicsThreadSleep(0.001);
			}
# line 440 "../change_en.st"
			printf("opt-pitch: ActPitch=%f.\n", (pVar->actPitch));
			sprintf((pVar->msgQ), "Optimizing Pitch.");
# line 441 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 441 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("opt-pitch: Optimizing Pitch.\n");
			(pVar->ChiAbort) = 1;
# line 443 "../change_en.st"
			seq_pvPut(ssId, 66 /* ChiAbort */, 0);
# line 443 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->curTheta) = 0.0;
# line 444 "../change_en.st"
			seq_pvPut(ssId, 71 /* curTheta */, 0);
# line 444 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->detMode) = 0;
# line 445 "../change_en.st"
			seq_pvPut(ssId, 33 /* detMode */, 0);
# line 445 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_pvPut(ssId, 49 /* piScanPosRd */, 0);
# line 446 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_pvPut(ssId, 50 /* piScanPosDr */, 0);
# line 447 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_pvPut(ssId, 51 /* piScanDtTrg */, 0);
# line 448 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_pvPut(ssId, 45 /* piScanDet */, 0);
# line 449 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_pvPut(ssId, 52 /* piScanAfter */, 0);
# line 450 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->piScanPosStl) = 0.0;
# line 451 "../change_en.st"
			seq_pvPut(ssId, 46 /* piScanPosStl */, 0);
# line 451 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->piScanDetStl) = 0.0;
# line 452 "../change_en.st"
			seq_pvPut(ssId, 47 /* piScanDetStl */, 0);
# line 452 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->piScanUpdt) = 0.2;
# line 453 "../change_en.st"
			seq_pvPut(ssId, 48 /* piScanUpdt */, 0);
# line 453 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->piScanLinr) = 0;
# line 454 "../change_en.st"
			seq_pvPut(ssId, 39 /* piScanLinr */, 0);
# line 454 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->piScanAbslt) = 0;
# line 455 "../change_en.st"
			seq_pvPut(ssId, 40 /* piScanAbslt */, 0);
# line 455 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->piScanPeakP) = 3;
# line 456 "../change_en.st"
			seq_pvPut(ssId, 41 /* piScanPeakP */, 0);
# line 456 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->piScanCntr) = (pVar->actPitch);
# line 457 "../change_en.st"
			seq_pvPut(ssId, 42 /* piScanCntr */, 0);
# line 457 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->piScanWdth) = (pVar->scWdth);
# line 458 "../change_en.st"
			seq_pvPut(ssId, 43 /* piScanWdth */, 0);
# line 458 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->piScanStep) = (pVar->scStep);
# line 459 "../change_en.st"
			seq_pvPut(ssId, 44 /* piScanStep */, 0);
# line 459 "../change_en.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(0.1);
			(pVar->piScanStart) = 1;
# line 461 "../change_en.st"
			seq_pvPut(ssId, 36 /* piScanStart */, 0);
# line 461 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, optpi_f);
# line 462 "../change_en.st"
			epicsThreadSleep(0.001);
# line 465 "../change_en.st"
			if ((pVar->thEnaBtn) == 1)
			{
				seq_efSet(ssId, optth_f);
				epicsThreadSleep(0.001);
			}
# line 466 "../change_en.st"
			else
			{
				seq_efClear(ssId, optth_f);
				epicsThreadSleep(0.001);
			}
# line 467 "../change_en.st"
			printf("state move_en: leavingg scan Pitch.\n");
		}
		return;
	case 10:
		{
# line 470 "../change_en.st"
			printf("state move_en: entering scan Theta.\n");
			(pVar->chEnWrkng) = 1;
# line 471 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 471 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->thWrkng) = 1;
# line 472 "../change_en.st"
			seq_pvPut(ssId, 10 /* thWrkng */, 0);
# line 472 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->detMode) = 1;
# line 473 "../change_en.st"
			seq_pvPut(ssId, 33 /* detMode */, 0);
# line 473 "../change_en.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "Optimize piezo.");
# line 474 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 474 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("opt-theta: Optimizing Theta with piezo drive.\n");
			(pVar->maxTheta) = (pVar->curTheta);
# line 476 "../change_en.st"
			(pVar->maxCnts) = 0;
			(pVar->line) = 0;
# line 477 "../change_en.st"
			(pVar->step) = (pVar->thStep);
# line 479 "../change_en.st"
 do {
# line 479 "../change_en.st"
			(pVar->cnts) = 0;
# line 484 "../change_en.st"
			for ((pVar->j) = 0; (pVar->j) < 3; (pVar->j)++)
			{
				epicsThreadSleep(0.2);
				seq_pvGet(ssId, 32 /* detCnts */, 0);
				epicsThreadSleep(0.001);
				(pVar->cnts) = (pVar->cnts) + (pVar->detCnts);
			}
# line 485 "../change_en.st"
			(pVar->cnts) = (pVar->cnts) / 3.0;
			epicsThreadSleep(0.2);
			seq_pvGet(ssId, 71 /* curTheta */, 0);
# line 487 "../change_en.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(0.001);
			printf("opt-theta: line=%d, curTheta=%f, cnts=%f.\n", (pVar->line), (pVar->curTheta), (pVar->cnts));
			if ((pVar->cnts) >= (pVar->maxCnts))
			{
				(pVar->maxTheta) = (pVar->curTheta);
				(pVar->maxCnts) = (pVar->cnts);
			}
# line 494 "../change_en.st"
			else
			{
				if ((pVar->line) == 1)
				{
					(pVar->step) = -(pVar->step);
					(pVar->maxCnts) = 0;
					printf("opt-theta: Reverse direction.\n");
				}
				else
				{
					printf("opt-theta: Optimization finished.\n");
					break;
				}
			}
# line 495 "../change_en.st"
			(pVar->line)++;
# line 497 "../change_en.st"
			(pVar->curTheta) += (pVar->step);
# line 502 "../change_en.st"
			if ((pVar->curTheta) < -4.9 || (pVar->curTheta) > 4.9)
			{
				sprintf((pVar->msgQ), "**Theta out of range.");
				seq_efSet(ssId, msg_f);
				epicsThreadSleep(0.001);
				printf("opt-theta: **Theta out of range. Stop.\n");
				break;
			}
# line 503 "../change_en.st"
			printf("opt-theta: curTheta=%f.\n", (pVar->curTheta));
			seq_pvPut(ssId, 71 /* curTheta */, 0);
# line 504 "../change_en.st"
			epicsThreadSleep(0.1);
# line 506 "../change_en.st"
 } while(1);
# line 506 "../change_en.st"
			printf("opt-theta: Exit the loop. Final theta=%f.\n", (pVar->maxTheta));
			(pVar->line) = 0;
			(pVar->curTheta) = (pVar->maxTheta) - 100.0 * (pVar->step);
			if ((pVar->curTheta) < -4.9 || (pVar->curTheta) > 4.9)
			{
				seq_pvPut(ssId, 71 /* curTheta */, 0);
				epicsThreadSleep(0.001);
			}
# line 510 "../change_en.st"
			(pVar->curTheta) = (pVar->maxTheta);
# line 510 "../change_en.st"
			seq_pvPut(ssId, 71 /* curTheta */, 0);
# line 510 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, optth_f);
# line 511 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, finished);
# line 512 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, moveen_f);
# line 513 "../change_en.st"
			epicsThreadSleep(0.001);
# line 513 "../change_en.st"
			seq_efClear(ssId, moveid_f);
# line 513 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movechi_f);
# line 514 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movevfm_f);
# line 515 "../change_en.st"
			epicsThreadSleep(0.001);
# line 515 "../change_en.st"
			seq_efClear(ssId, movehfm_f);
# line 515 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, optpi_f);
# line 516 "../change_en.st"
			epicsThreadSleep(0.001);
# line 516 "../change_en.st"
			seq_efClear(ssId, optth_f);
# line 516 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->thWrkng) = 0;
# line 517 "../change_en.st"
			seq_pvPut(ssId, 10 /* thWrkng */, 0);
# line 517 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("state move_en: leaving scan Theta.\n");
		}
		return;
	case 11:
		{
# line 521 "../change_en.st"
			(pVar->chEnWrkng) = 0;
# line 521 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 521 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, finished);
# line 522 "../change_en.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "Ready.");
# line 523 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 523 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("move_en: Theta opt finished. Ready.\n");
		}
		return;
	case 12:
		{
# line 527 "../change_en.st"
			printf("undo: when undo_f .\n");
			(pVar->chEnWrkng) = 1;
# line 528 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 528 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->EnAbort) = 1;
# line 529 "../change_en.st"
			seq_pvPut(ssId, 55 /* EnAbort */, 0);
# line 529 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->rqsPosEn) = (pVar->startEn);
# line 530 "../change_en.st"
			seq_pvPut(ssId, 54 /* rqsPosEn */, 0);
# line 530 "../change_en.st"
			epicsThreadSleep(0.001);
			printf("undo: Moving En to %f.).\n", (pVar->startEn));
# line 538 "../change_en.st"
			if ((pVar->idEnaBtn) == 1)
			{
				if ((pVar->IDStatus) == 1)
				{
					(pVar->IDStop) = 1;
					seq_pvPut(ssId, 62 /* IDStop */, 0);
					epicsThreadSleep(0.1);
				}
				(pVar->rqsHrmID) = (pVar->startHrmID);
				seq_pvPut(ssId, 60 /* rqsHrmID */, 0);
				epicsThreadSleep(0.001);
				(pVar->rqsEnID) = (pVar->startEnID);
				printf("undo: Moving ID to %f.\n", (pVar->rqsEnID));
				seq_pvPut(ssId, 59 /* rqsEnID */, 0);
				epicsThreadSleep(0.001);
				(pVar->IDStart) = 1;
				seq_pvPut(ssId, 61 /* IDStart */, 0);
				epicsThreadSleep(0.001);
			}
# line 543 "../change_en.st"
			if ((pVar->vfmEnaBtn) == 1)
			{
				(pVar->VFMAbort) = 1;
				seq_pvPut(ssId, 74 /* VFMAbort */, 0);
				epicsThreadSleep(0.001);
				(pVar->rqsLnVFM) = (pVar->startLnVFM);
				seq_pvPut(ssId, 73 /* rqsLnVFM */, 0);
				epicsThreadSleep(0.001);
				printf("undo: Moving VFM to %f.).\n", (pVar->rqsLnVFM));
			}
# line 548 "../change_en.st"
			if ((pVar->hfmEnaBtn) == 1)
			{
				(pVar->HFMAbort) = 1;
				seq_pvPut(ssId, 79 /* HFMAbort */, 0);
				epicsThreadSleep(0.001);
				(pVar->rqsLnHFM) = (pVar->startLnHFM);
				seq_pvPut(ssId, 78 /* rqsLnHFM */, 0);
				epicsThreadSleep(0.001);
				printf("undo: Moving HFM to %f.).\n", (pVar->rqsLnHFM));
			}
# line 560 "../change_en.st"
			if ((pVar->piEnaBtn) == 1)
			{
				if ((pVar->piScanBusy) == 1)
				{
					(pVar->piScanAbort) = 1;
					seq_pvPut(ssId, 37 /* piScanAbort */, 0);
					epicsThreadSleep(0.1);
					(pVar->piScanAbort) = 1;
					seq_pvPut(ssId, 37 /* piScanAbort */, 0);
					epicsThreadSleep(0.1);
					epicsThreadSleep(0.5);
					printf("undo: Abort pitch scan.\n");
				}
				(pVar->ChiAbort) = 1;
				seq_pvPut(ssId, 66 /* ChiAbort */, 0);
				epicsThreadSleep(0.1);
				(pVar->rqsPitch) = (pVar->startPi);
				seq_pvPut(ssId, 70 /* rqsPitch */, 0);
				epicsThreadSleep(0.1);
				printf("undo: Moving Pitch to %f.).\n", (pVar->rqsPitch));
			}
# line 565 "../change_en.st"
			if ((pVar->chiEnaBtn) == 1)
			{
				if ((pVar->ChiRunPrg) == 0)
				{
					(pVar->ChiAbort) = 1;
					seq_pvPut(ssId, 66 /* ChiAbort */, 0);
					epicsThreadSleep(0.001);
				}
				(pVar->rqsPosChi) = (pVar->startChi);
				seq_pvPut(ssId, 65 /* rqsPosChi */, 0);
				epicsThreadSleep(0.001);
				printf("undo: Moving CHI to %f.).\n", (pVar->rqsPosChi));
			}
# line 566 "../change_en.st"
			if ((pVar->thEnaBtn) == 1)
			{
				(pVar->curTheta) = (pVar->startTh);
				seq_pvPut(ssId, 71 /* curTheta */, 0);
				epicsThreadSleep(0.001);
			}
# line 567 "../change_en.st"
			printf("undo: Moving Theta to %f.).\n", (pVar->curTheta));
			epicsThreadSleep(0.5);
# line 573 "../change_en.st"
			(pVar->detMode) = 1;
# line 573 "../change_en.st"
			seq_pvPut(ssId, 33 /* detMode */, 0);
# line 573 "../change_en.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "Undo finished. Ready.");
# line 574 "../change_en.st"
			seq_efSet(ssId, msg_f);
# line 574 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, moveen_f);
# line 575 "../change_en.st"
			epicsThreadSleep(0.001);
# line 575 "../change_en.st"
			seq_efClear(ssId, moveid_f);
# line 575 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movechi_f);
# line 576 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movevfm_f);
# line 577 "../change_en.st"
			epicsThreadSleep(0.001);
# line 577 "../change_en.st"
			seq_efClear(ssId, movehfm_f);
# line 577 "../change_en.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, optpi_f);
# line 578 "../change_en.st"
			epicsThreadSleep(0.001);
# line 578 "../change_en.st"
			seq_efClear(ssId, optth_f);
# line 578 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->startBtn) = 0;
# line 579 "../change_en.st"
			seq_pvPut(ssId, 0 /* startBtn */, 0);
# line 579 "../change_en.st"
			epicsThreadSleep(0.001);
# line 579 "../change_en.st"
			seq_efClear(ssId, start_f);
# line 579 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->abortBtn) = 0;
# line 580 "../change_en.st"
			seq_pvPut(ssId, 1 /* abortBtn */, 0);
# line 580 "../change_en.st"
			epicsThreadSleep(0.001);
# line 580 "../change_en.st"
			seq_efClear(ssId, abort_f);
# line 580 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->undoBtn) = 0;
# line 581 "../change_en.st"
			seq_pvPut(ssId, 3 /* undoBtn */, 0);
# line 581 "../change_en.st"
			epicsThreadSleep(0.001);
# line 581 "../change_en.st"
			seq_efClear(ssId, undo_f);
# line 581 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->thWrkng) = 0;
# line 582 "../change_en.st"
			seq_pvPut(ssId, 10 /* thWrkng */, 0);
# line 582 "../change_en.st"
			epicsThreadSleep(0.001);
			(pVar->chEnWrkng) = 0;
# line 583 "../change_en.st"
			seq_pvPut(ssId, 9 /* chEnWrkng */, 0);
# line 583 "../change_en.st"
			epicsThreadSleep(0.001);
		}
		return;
	}
}

/* Exit handler */
static void exit_handler(SS_ID ssId, struct UserVar *pVar)
{
}

/************************ Tables ***********************/

/* Database Blocks */
static struct seqChan seqChan[NUM_CHANNELS] = {
  {"{coioc}:mono:Start", (void *)OFFSET(struct UserVar, startBtn), "startBtn", 
    "int", 1, 14, 1, 1, 0, 0, 0},

  {"{coioc}:mono:Abort", (void *)OFFSET(struct UserVar, abortBtn), "abortBtn", 
    "int", 1, 15, 2, 1, 0, 0, 0},

  {"{coioc}:mono:Clean", (void *)OFFSET(struct UserVar, cleanBtn), "cleanBtn", 
    "int", 1, 16, 3, 1, 0, 0, 0},

  {"{coioc}:mono:Undo", (void *)OFFSET(struct UserVar, undoBtn), "undoBtn", 
    "int", 1, 17, 4, 1, 0, 0, 0},

  {"{coioc}:mono:AbortCentr", (void *)OFFSET(struct UserVar, abortCentr), "abortCentr", 
    "int", 1, 18, 0, 1, 0, 0, 0},

  {"{coioc}:mono:CentrWrkng", (void *)OFFSET(struct UserVar, centrWrkng), "centrWrkng", 
    "int", 1, 19, 0, 1, 0, 0, 0},

  {"{coioc}:mono:TBMIsw", (void *)OFFSET(struct UserVar, tbMiSwBtn), "tbMiSwBtn", 
    "int", 1, 20, 0, 1, 0, 0, 0},

  {"{coioc}:mono:ImgHCentr", (void *)OFFSET(struct UserVar, imgHCentr), "imgHCentr", 
    "int", 1, 21, 0, 1, 0, 0, 0},

  {"{coioc}:mono:ImgVCentr", (void *)OFFSET(struct UserVar, imgVCentr), "imgVCentr", 
    "int", 1, 22, 0, 1, 0, 0, 0},

  {"{coioc}:mono:ChEnWrkng", (void *)OFFSET(struct UserVar, chEnWrkng), "chEnWrkng", 
    "int", 1, 23, 0, 1, 0, 0, 0},

  {"{coioc}:mono:ThWrkng", (void *)OFFSET(struct UserVar, thWrkng), "thWrkng", 
    "int", 1, 24, 0, 1, 0, 0, 0},

  {"{coioc}:mono:IDena", (void *)OFFSET(struct UserVar, idEnaBtn), "idEnaBtn", 
    "int", 1, 25, 0, 1, 0, 0, 0},

  {"{coioc}:mono:CHIena", (void *)OFFSET(struct UserVar, chiEnaBtn), "chiEnaBtn", 
    "int", 1, 26, 0, 1, 0, 0, 0},

  {"{coioc}:mono:VFMena", (void *)OFFSET(struct UserVar, vfmEnaBtn), "vfmEnaBtn", 
    "int", 1, 27, 0, 1, 0, 0, 0},

  {"{coioc}:mono:HFMena", (void *)OFFSET(struct UserVar, hfmEnaBtn), "hfmEnaBtn", 
    "int", 1, 28, 0, 1, 0, 0, 0},

  {"{coioc}:mono:PIena", (void *)OFFSET(struct UserVar, piEnaBtn), "piEnaBtn", 
    "int", 1, 29, 0, 1, 0, 0, 0},

  {"{coioc}:mono:THena", (void *)OFFSET(struct UserVar, thEnaBtn), "thEnaBtn", 
    "int", 1, 30, 0, 1, 0, 0, 0},

  {"{coioc}:mono:RqsEn", (void *)OFFSET(struct UserVar, newEn), "newEn", 
    "double", 1, 31, 0, 1, 0, 0, 0},

  {"{coioc}:mono:HrmSwEn", (void *)OFFSET(struct UserVar, hrmSwEn), "hrmSwEn", 
    "double", 1, 32, 0, 1, 0, 0, 0},

  {"{coioc}:mono:IDoff1", (void *)OFFSET(struct UserVar, idOff1), "idOff1", 
    "double", 1, 33, 0, 1, 0, 0, 0},

  {"{coioc}:mono:IDoff2", (void *)OFFSET(struct UserVar, idOff2), "idOff2", 
    "double", 1, 34, 0, 1, 0, 0, 0},

  {"{coioc}:mono:ChiSca", (void *)OFFSET(struct UserVar, chiSca), "chiSca", 
    "double", 1, 35, 0, 1, 0, 0, 0},

  {"{coioc}:mono:ChiOff", (void *)OFFSET(struct UserVar, chiOff), "chiOff", 
    "double", 1, 36, 0, 1, 0, 0, 0},

  {"{coioc}:mono:VFMPd", (void *)OFFSET(struct UserVar, vfmPd), "vfmPd", 
    "double", 1, 37, 0, 1, 0, 0, 0},

  {"{coioc}:mono:VFMGl", (void *)OFFSET(struct UserVar, vfmGl), "vfmGl", 
    "double", 1, 38, 0, 1, 0, 0, 0},

  {"{coioc}:mono:VFMPt", (void *)OFFSET(struct UserVar, vfmPt), "vfmPt", 
    "double", 1, 39, 0, 1, 0, 0, 0},

  {"{coioc}:mono:HFMPd", (void *)OFFSET(struct UserVar, hfmPd), "hfmPd", 
    "double", 1, 40, 0, 1, 0, 0, 0},

  {"{coioc}:mono:HFMGl", (void *)OFFSET(struct UserVar, hfmGl), "hfmGl", 
    "double", 1, 41, 0, 1, 0, 0, 0},

  {"{coioc}:mono:HFMPt", (void *)OFFSET(struct UserVar, hfmPt), "hfmPt", 
    "double", 1, 42, 0, 1, 0, 0, 0},

  {"{coioc}:mono:ScWdth", (void *)OFFSET(struct UserVar, scWdth), "scWdth", 
    "double", 1, 43, 0, 1, 0, 0, 0},

  {"{coioc}:mono:ScStep", (void *)OFFSET(struct UserVar, scStep), "scStep", 
    "double", 1, 44, 0, 1, 0, 0, 0},

  {"{coioc}:mono:ThStep", (void *)OFFSET(struct UserVar, thStep), "thStep", 
    "double", 1, 45, 0, 1, 0, 0, 0},

  {"{detnm}_calc5.VAL", (void *)OFFSET(struct UserVar, detCnts), "detCnts", 
    "double", 1, 46, 0, 1, 0, 0, 0},

  {"{detnm}.CONT", (void *)OFFSET(struct UserVar, detMode), "detMode", 
    "int", 1, 47, 0, 1, 0, 0, 0},

  {"{scnm}.NAME", (void *)OFFSET(struct UserVar, piScanNm[0]), "piScanNm", 
    "string", 1, 48, 0, 1, 0, 0, 0},

  {"{scnm}.BUSY", (void *)OFFSET(struct UserVar, piScanBusy), "piScanBusy", 
    "int", 1, 49, 0, 1, 0, 0, 0},

  {"{scnm}.EXSC", (void *)OFFSET(struct UserVar, piScanStart), "piScanStart", 
    "int", 1, 50, 0, 0, 0, 0, 0},

  {"21:D1:AbortScans.PROC", (void *)OFFSET(struct UserVar, piScanAbort), "piScanAbort", 
    "int", 1, 51, 0, 0, 0, 0, 0},

  {"{scnm}.CMND", (void *)OFFSET(struct UserVar, piScanCmnd), "piScanCmnd", 
    "int", 1, 52, 0, 0, 0, 0, 0},

  {"{scnm}.P1SM", (void *)OFFSET(struct UserVar, piScanLinr), "piScanLinr", 
    "int", 1, 53, 0, 0, 0, 0, 0},

  {"{scnm}.P1AR", (void *)OFFSET(struct UserVar, piScanAbslt), "piScanAbslt", 
    "int", 1, 54, 0, 0, 0, 0, 0},

  {"{scnm}.PASM", (void *)OFFSET(struct UserVar, piScanPeakP), "piScanPeakP", 
    "int", 1, 55, 0, 0, 0, 0, 0},

  {"{scnm}.P1CP", (void *)OFFSET(struct UserVar, piScanCntr), "piScanCntr", 
    "double", 1, 56, 0, 0, 0, 0, 0},

  {"{scnm}.P1WD", (void *)OFFSET(struct UserVar, piScanWdth), "piScanWdth", 
    "double", 1, 57, 0, 0, 0, 0, 0},

  {"{scnm}.P1SI", (void *)OFFSET(struct UserVar, piScanStep), "piScanStep", 
    "double", 1, 58, 0, 0, 0, 0, 0},

  {"{scnm}.D01PV", (void *)OFFSET(struct UserVar, piScanDet[0]), "piScanDet", 
    "string", 1, 59, 0, 0, 0, 0, 0},

  {"{scnm}.PDLY", (void *)OFFSET(struct UserVar, piScanPosStl), "piScanPosStl", 
    "float", 1, 60, 0, 0, 0, 0, 0},

  {"{scnm}.DDLY", (void *)OFFSET(struct UserVar, piScanDetStl), "piScanDetStl", 
    "float", 1, 61, 0, 0, 0, 0, 0},

  {"{scnm}.ATIME", (void *)OFFSET(struct UserVar, piScanUpdt), "piScanUpdt", 
    "float", 1, 62, 0, 0, 0, 0, 0},

  {"{scnm}.R1PV", (void *)OFFSET(struct UserVar, piScanPosRd[0]), "piScanPosRd", 
    "string", 1, 63, 0, 0, 0, 0, 0},

  {"{scnm}.P1PV", (void *)OFFSET(struct UserVar, piScanPosDr[0]), "piScanPosDr", 
    "string", 1, 64, 0, 0, 0, 0, 0},

  {"{scnm}.T1PV", (void *)OFFSET(struct UserVar, piScanDtTrg[0]), "piScanDtTrg", 
    "string", 1, 65, 0, 0, 0, 0, 0},

  {"{scnm}.ASPV", (void *)OFFSET(struct UserVar, piScanAfter[0]), "piScanAfter", 
    "string", 1, 66, 0, 0, 0, 0, 0},

  {"21:C1:MO:E:ActPos", (void *)OFFSET(struct UserVar, actEn), "actEn", 
    "double", 1, 67, 0, 1, 0, 0, 0},

  {"21:C1:MO:E:RqsPos", (void *)OFFSET(struct UserVar, rqsPosEn), "rqsPosEn", 
    "double", 1, 68, 0, 1, 0, 0, 0},

  {"21:C1:MO:En:Abort", (void *)OFFSET(struct UserVar, EnAbort), "EnAbort", 
    "long", 1, 69, 0, 1, 0, 0, 0},

  {"21:C1:MO:En:Kill", (void *)OFFSET(struct UserVar, EnKill), "EnKill", 
    "long", 1, 70, 0, 1, 0, 0, 0},

  {"21:C1:MO:En:RunPrg", (void *)OFFSET(struct UserVar, EnRunPrg), "EnRunPrg", 
    "long", 1, 71, 0, 1, 0, 0, 0},

  {"ID21us:Energy.VAL", (void *)OFFSET(struct UserVar, actEnID), "actEnID", 
    "double", 1, 72, 0, 1, 0, 0, 0},

  {"ID21us:EnergySet.VAL", (void *)OFFSET(struct UserVar, rqsEnID), "rqsEnID", 
    "double", 1, 73, 0, 1, 0, 0, 0},

  {"ID21us:HarmonicValue", (void *)OFFSET(struct UserVar, rqsHrmID), "rqsHrmID", 
    "double", 1, 74, 0, 1, 0, 0, 0},

  {"ID21us:Start.VAL", (void *)OFFSET(struct UserVar, IDStart), "IDStart", 
    "int", 1, 75, 0, 1, 0, 0, 0},

  {"ID21us:Stop.VAL", (void *)OFFSET(struct UserVar, IDStop), "IDStop", 
    "int", 1, 76, 0, 1, 0, 0, 0},

  {"ID21us:Busy.VAL", (void *)OFFSET(struct UserVar, IDStatus), "IDStatus", 
    "int", 1, 77, 0, 1, 0, 0, 0},

  {"21:C1:MO:R2:ActPos", (void *)OFFSET(struct UserVar, actChi), "actChi", 
    "double", 1, 78, 0, 1, 0, 0, 0},

  {"21:C1:MO:R2:RqsPos", (void *)OFFSET(struct UserVar, rqsPosChi), "rqsPosChi", 
    "double", 1, 79, 0, 1, 0, 0, 0},

  {"21:C1:MO:Tn:Abort", (void *)OFFSET(struct UserVar, ChiAbort), "ChiAbort", 
    "long", 1, 80, 0, 1, 0, 0, 0},

  {"21:C1:MO:Tn:Kill", (void *)OFFSET(struct UserVar, ChiKill), "ChiKill", 
    "long", 1, 81, 0, 1, 0, 0, 0},

  {"21:C1:MO:Tn:RunPrg", (void *)OFFSET(struct UserVar, ChiRunPrg), "ChiRunPrg", 
    "long", 1, 82, 0, 1, 0, 0, 0},

  {"21:C1:MO:P2:ActPos", (void *)OFFSET(struct UserVar, actPitch), "actPitch", 
    "double", 1, 83, 0, 1, 0, 0, 0},

  {"21:C1:MO:P2:RqsPos", (void *)OFFSET(struct UserVar, rqsPitch), "rqsPitch", 
    "double", 1, 84, 0, 1, 0, 0, 0},

  {"c3ioc:rmm01:ana01:ao01.VAL", (void *)OFFSET(struct UserVar, curTheta), "curTheta", 
    "double", 1, 85, 0, 1, 0, 0, 0},

  {"21:D1:KB:VL:ActPos", (void *)OFFSET(struct UserVar, actLnVFM), "actLnVFM", 
    "double", 1, 86, 0, 1, 0, 0, 0},

  {"21:D1:KB:VL:RqsPos", (void *)OFFSET(struct UserVar, rqsLnVFM), "rqsLnVFM", 
    "double", 1, 87, 0, 1, 0, 0, 0},

  {"21:D1:KB:Vx:Abort", (void *)OFFSET(struct UserVar, VFMAbort), "VFMAbort", 
    "long", 1, 88, 0, 1, 0, 0, 0},

  {"21:D1:KB:Vx:Kill", (void *)OFFSET(struct UserVar, VFMKill), "VFMKill", 
    "long", 1, 89, 0, 1, 0, 0, 0},

  {"21:D1:KB:Vx:RunPrg", (void *)OFFSET(struct UserVar, VFMRunPrg), "VFMRunPrg", 
    "long", 1, 90, 0, 1, 0, 0, 0},

  {"21:D1:KB:HL:ActPos", (void *)OFFSET(struct UserVar, actLnHFM), "actLnHFM", 
    "double", 1, 91, 0, 1, 0, 0, 0},

  {"21:D1:KB:HL:RqsPos", (void *)OFFSET(struct UserVar, rqsLnHFM), "rqsLnHFM", 
    "double", 1, 92, 0, 1, 0, 0, 0},

  {"21:D1:KB:Hy:Abort", (void *)OFFSET(struct UserVar, HFMAbort), "HFMAbort", 
    "long", 1, 93, 0, 1, 0, 0, 0},

  {"21:D1:KB:Hy:Kill", (void *)OFFSET(struct UserVar, HFMKill), "HFMKill", 
    "long", 1, 94, 0, 1, 0, 0, 0},

  {"21:D1:KB:Hy:RunPrg", (void *)OFFSET(struct UserVar, HFMRunPrg), "HFMRunPrg", 
    "long", 1, 95, 0, 1, 0, 0, 0},

  {"{coioc}:mono:Msg9", (void *)OFFSET(struct UserVar, msg[0][0]), "msg[0]", 
    "string", 1, 96, 0, 0, 0, 0, 0},

  {"{coioc}:mono:Msg8", (void *)OFFSET(struct UserVar, msg[1][0]), "msg[1]", 
    "string", 1, 97, 0, 0, 0, 0, 0},

  {"{coioc}:mono:Msg7", (void *)OFFSET(struct UserVar, msg[2][0]), "msg[2]", 
    "string", 1, 98, 0, 0, 0, 0, 0},

  {"{coioc}:mono:Msg6", (void *)OFFSET(struct UserVar, msg[3][0]), "msg[3]", 
    "string", 1, 99, 0, 0, 0, 0, 0},

  {"{coioc}:mono:Msg5", (void *)OFFSET(struct UserVar, msg[4][0]), "msg[4]", 
    "string", 1, 100, 0, 0, 0, 0, 0},

  {"{coioc}:mono:Msg4", (void *)OFFSET(struct UserVar, msg[5][0]), "msg[5]", 
    "string", 1, 101, 0, 0, 0, 0, 0},

  {"{coioc}:mono:Msg3", (void *)OFFSET(struct UserVar, msg[6][0]), "msg[6]", 
    "string", 1, 102, 0, 0, 0, 0, 0},

  {"{coioc}:mono:Msg2", (void *)OFFSET(struct UserVar, msg[7][0]), "msg[7]", 
    "string", 1, 103, 0, 0, 0, 0, 0},

  {"{coioc}:mono:Msg1", (void *)OFFSET(struct UserVar, msg[8][0]), "msg[8]", 
    "string", 1, 104, 0, 0, 0, 0, 0},

  {"{coioc}:mono:Msg0", (void *)OFFSET(struct UserVar, msg[9][0]), "msg[9]", 
    "string", 1, 105, 0, 0, 0, 0, 0},

};

/* Event masks for state set set1 */
	/* Event mask for state init: */
static bitMask	EM_set1_init[] = {
	0x00000000,
	0x00000000,
	0x00000000,
	0x00000000,
};
	/* Event mask for state mntr: */
static bitMask	EM_set1_mntr[] = {
	0xbe0ac03e,
	0x00020000,
	0x84042080,
	0x00000000,
};

/* State Blocks */

static struct seqState state_set1[] = {
	/* State "init" */ {
	/* state name */       "init",
	/* action function */ (ACTION_FUNC) A_set1_init,
	/* event function */  (EVENT_FUNC) E_set1_init,
	/* delay function */   (DELAY_FUNC) D_set1_init,
	/* entry function */   (ENTRY_FUNC) 0,
	/* exit function */   (EXIT_FUNC) 0,
	/* event mask array */ EM_set1_init,
	/* state options */   (0)},

	/* State "mntr" */ {
	/* state name */       "mntr",
	/* action function */ (ACTION_FUNC) A_set1_mntr,
	/* event function */  (EVENT_FUNC) E_set1_mntr,
	/* delay function */   (DELAY_FUNC) D_set1_mntr,
	/* entry function */   (ENTRY_FUNC) 0,
	/* exit function */   (EXIT_FUNC) 0,
	/* event mask array */ EM_set1_mntr,
	/* state options */   (0)},


};

/* Event masks for state set set2 */
	/* Event mask for state init2: */
static bitMask	EM_set2_init2[] = {
	0x00000040,
	0x00000000,
	0x00000000,
	0x00000000,
};
	/* Event mask for state move_en: */
static bitMask	EM_set2_move_en[] = {
	0x0002bff4,
	0x00020000,
	0x84042080,
	0x00000000,
};

/* State Blocks */

static struct seqState state_set2[] = {
	/* State "init2" */ {
	/* state name */       "init2",
	/* action function */ (ACTION_FUNC) A_set2_init2,
	/* event function */  (EVENT_FUNC) E_set2_init2,
	/* delay function */   (DELAY_FUNC) D_set2_init2,
	/* entry function */   (ENTRY_FUNC) 0,
	/* exit function */   (EXIT_FUNC) 0,
	/* event mask array */ EM_set2_init2,
	/* state options */   (0)},

	/* State "move_en" */ {
	/* state name */       "move_en",
	/* action function */ (ACTION_FUNC) A_set2_move_en,
	/* event function */  (EVENT_FUNC) E_set2_move_en,
	/* delay function */   (DELAY_FUNC) D_set2_move_en,
	/* entry function */   (ENTRY_FUNC) 0,
	/* exit function */   (EXIT_FUNC) 0,
	/* event mask array */ EM_set2_move_en,
	/* state options */   (0)},


};

/* State Set Blocks */
static struct seqSS seqSS[NUM_SS] = {
	/* State set "set1" */ {
	/* ss name */            "set1",
	/* ptr to state block */ state_set1,
	/* number of states */   2,
	/* error state */        -1},


	/* State set "set2" */ {
	/* ss name */            "set2",
	/* ptr to state block */ state_set2,
	/* number of states */   2,
	/* error state */        -1},
};

/* Program parameter list */
static char prog_param[] = "coioc=21linux, scnm=21:D1:scan3, detnm=21:D1:scaler1";

/* State Program table (global) */
struct seqProgram change_en = {
	/* magic number */       20000315,
	/* *name */              "change_en",
	/* *pChannels */         seqChan,
	/* numChans */           NUM_CHANNELS,
	/* *pSS */               seqSS,
	/* numSS */              NUM_SS,
	/* user variable size */ sizeof(struct UserVar),
	/* *pParams */           prog_param,
	/* numEvents */          NUM_EVENTS,
	/* encoded options */    (0 | OPT_CONN | OPT_NEWEF | OPT_REENT),
	/* entry handler */      (ENTRY_FUNC) entry_handler,
	/* exit handler */       (EXIT_FUNC) exit_handler,
	/* numQueues */          NUM_QUEUES,
};


/* Register sequencer commands and program */

void change_enRegistrar (void) {
    seqRegisterSequencerCommands();
    seqRegisterSequencerProgram (&change_en);
}
epicsExportRegistrar(change_enRegistrar);

