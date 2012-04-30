/* SNC Version 2.0.12: Fri May 28 19:40:48 2010: vfminout.i */

/* Event flags */
#define vfmin_f	1
#define vfmout_f	2
#define abort_f	3
#define undo_f	4
#define clean_f	5
#define stopfdbk_f	6
#define msg_f	7
#define movevfm_f	8
#define postmove_f	9
#define finished_f	10
#define fiundo_f	11

/* Program "vfminout" */
#include "seqCom.h"

#define NUM_SS 2
#define NUM_CHANNELS 97
#define NUM_EVENTS 11
#define NUM_QUEUES 0

#define MAX_STRING_SIZE 40

#define ASYNC_OPT TRUE
#define CONN_OPT TRUE
#define DEBUG_OPT FALSE
#define MAIN_OPT FALSE
#define NEWEF_OPT TRUE
#define REENT_OPT TRUE

extern struct seqProgram vfminout;

/* Variable declarations */
struct UserVar {
	char	time_str[80];
	int	i;
	int	status;
	int	msgI;
	int	startFdbk;
	int	startShSt;
	int	startAttUnit;
	double	startAtt;
	double	startMKys;
	double	startDSyc;
	double	startDSys;
	double	startDSxs;
	double	startVFMh;
	double	startVFMa;
	double	startTBh;
	double	startTBa;
	double	startDTd;
	double	startDTh;
	double	startDTx;
	double	startDTvOff;
	double	startDTav;
	double	startDTsv;
	int	preFdbk;
	int	preHtchSh;
	int	preAttUnit;
	double	preAtt;
	double	preMKys;
	double	preDSys;
	double	preDSxs;
	double	runDSyc;
	double	runVFMh;
	double	runTBh;
	double	runTBa;
	double	runDTd;
	double	runDTh;
	double	runDTx;
	double	postDTvOff;
	double	postDTvAng;
	double	postDTvSh;
	int	vfmInBtn;
	int	vfmOutBtn;
	int	abortBtn;
	int	undoBtn;
	int	cleanBtn;
	int	stopFdbkBtn;
	int	fdbkWrkng;
	int	chEnWrkng;
	int	centrWrkng;
	int	vfmIOWrkng;
	int	htchShOp;
	int	htchShCl;
	int	htchShSt;
	double	attUnit;
	double	attAct;
	double	attRqs;
	double	attIn;
	double	attOut;
	double	dsHi;
	double	dsHo;
	double	tbHi;
	double	tbHo;
	double	tbAi;
	double	tbAo;
	double	vfmHi;
	double	vfmHo;
	double	dtOfIn;
	double	dtOfOut;
	double	dtAnIn;
	double	dtAnOut;
	double	dtShIn;
	double	dtShOut;
	double	actMKys;
	double	rqsMKys;
	long	MKvAbort;
	long	MKRunPrg;
	double	actDSyc;
	double	rqsDSyc;
	double	actDSys;
	double	rqsDSys;
	double	actDSxs;
	double	rqsDSxs;
	long	DSyAuto;
	long	DSyStart;
	long	DSyAbort;
	long	DSyRunPrg;
	long	DSxAbort;
	long	DSxRunPrg;
	double	actKBvy;
	double	rqsKBvy;
	long	VFMauto;
	long	VFMstart;
	long	VFMAbort;
	long	VFMRunPrg;
	double	actTBh;
	double	rqsTBh;
	double	actTBa;
	double	rqsTBa;
	long	TBvAuto;
	long	TBvStart;
	long	TBvAbort;
	long	TBvRunPrg;
	double	DTvdsOff;
	double	DTvdsAct;
	double	DTvdsRqs;
	double	DTvusAct;
	double	DTvusRqs;
	double	DTdAct;
	double	DTdRqs;
	double	DThAct;
	double	DThRqs;
	double	DTxAct;
	double	DTxRqs;
	double	DTdlAct;
	double	DTdlRqs;
	double	DTvCorAng;
	double	DTvCorSh;
	long	lpCorrOff;
	long	DTlpAuto;
	long	DTlpStart;
	long	DTlpAbort;
	long	DTlpRunPrg;
	long	stCorrOff;
	long	DTvAuto;
	long	DTvStart;
	long	DTvAbort;
	long	DTvRunPrg;
	char	msgQ[MAX_STRING_SIZE];
	char	msg[10][MAX_STRING_SIZE];
};

/* C code definitions */
# line 7 "../vfminout.st"
#include <string.h>
# line 8 "../vfminout.st"
#include <math.h>
# line 9 "../vfminout.st"
#include <tsDefs.h>
# line 4 "../vfminout.h"
TS_STAMP tmc;

/* Entry handler */
static void entry_handler(SS_ID ssId, struct UserVar *pVar)
{
}

/* Code for state "init" in state set "setQ" */

/* Delay function for state "init" in state set "setQ" */
static void D_setQ_init(SS_ID ssId, struct UserVar *pVar)
{
# line 46 "../vfminout.st"
}

/* Event function for state "init" in state set "setQ" */
static long E_setQ_init(SS_ID ssId, struct UserVar *pVar, short *pTransNum, short *pNextState)
{
# line 46 "../vfminout.st"
	if (TRUE)
	{
		*pNextState = 1;
		*pTransNum = 0;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "init" in state set "setQ" */
static void A_setQ_init(SS_ID ssId, struct UserVar *pVar, short transNum)
{
	switch(transNum)
	{
	case 0:
		{
# line 15 "../vfminout.st"
			printf("Init state.\n");
			(pVar->vfmIOWrkng) = 0;
# line 16 "../vfminout.st"
			seq_pvPut(ssId, 9 /* vfmIOWrkng */, 0);
# line 16 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 34 "../vfminout.st"
			seq_efClear(ssId, clean_f);
# line 34 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 34 "../vfminout.st"
			(pVar->msgI) = 9;
			(pVar->vfmInBtn) = 0;
# line 35 "../vfminout.st"
			seq_pvPut(ssId, 0 /* vfmInBtn */, 0);
# line 35 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmin_f);
# line 36 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmOutBtn) = 0;
# line 37 "../vfminout.st"
			seq_pvPut(ssId, 1 /* vfmOutBtn */, 0);
# line 37 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmout_f);
# line 38 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->abortBtn) = 0;
# line 39 "../vfminout.st"
			seq_pvPut(ssId, 2 /* abortBtn */, 0);
# line 39 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, abort_f);
# line 40 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, movevfm_f);
# line 41 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, postmove_f);
# line 42 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, finished_f);
# line 43 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fiundo_f);
# line 44 "../vfminout.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "Ready.");
# line 45 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 45 "../vfminout.st"
			epicsThreadSleep(0.001);
		}
		return;
	}
}
/* Code for state "mntr" in state set "setQ" */

/* Delay function for state "mntr" in state set "setQ" */
static void D_setQ_mntr(SS_ID ssId, struct UserVar *pVar)
{
# line 66 "../vfminout.st"
# line 97 "../vfminout.st"
# line 105 "../vfminout.st"
# line 113 "../vfminout.st"
# line 121 "../vfminout.st"
# line 129 "../vfminout.st"
# line 137 "../vfminout.st"
# line 145 "../vfminout.st"
# line 153 "../vfminout.st"
# line 199 "../vfminout.st"
# line 217 "../vfminout.st"
# line 224 "../vfminout.st"
# line 279 "../vfminout.st"
}

/* Event function for state "mntr" in state set "setQ" */
static long E_setQ_mntr(SS_ID ssId, struct UserVar *pVar, short *pTransNum, short *pNextState)
{
# line 66 "../vfminout.st"
	if (seq_efTestAndClear(ssId, msg_f))
	{
		*pNextState = 1;
		*pTransNum = 0;
		return TRUE;
	}
# line 97 "../vfminout.st"
	if (seq_efTest(ssId, abort_f) && (pVar->abortBtn) == 1)
	{
		*pNextState = 1;
		*pTransNum = 1;
		return TRUE;
	}
# line 105 "../vfminout.st"
	if (((seq_efTest(ssId, vfmin_f) && (pVar->vfmInBtn) == 1) || (seq_efTest(ssId, vfmout_f) && (pVar->vfmOutBtn) == 1)) && (pVar->chEnWrkng) == 1)
	{
		*pNextState = 1;
		*pTransNum = 2;
		return TRUE;
	}
# line 113 "../vfminout.st"
	if (((seq_efTest(ssId, vfmin_f) && (pVar->vfmInBtn) == 1) || (seq_efTest(ssId, vfmout_f) && (pVar->vfmOutBtn) == 1)) && (pVar->centrWrkng) == 1)
	{
		*pNextState = 1;
		*pTransNum = 3;
		return TRUE;
	}
# line 121 "../vfminout.st"
	if (((seq_efTest(ssId, vfmin_f) && (pVar->vfmInBtn) == 1) || (seq_efTest(ssId, vfmout_f) && (pVar->vfmOutBtn) == 1)) && (pVar->MKRunPrg) == 1)
	{
		*pNextState = 1;
		*pTransNum = 4;
		return TRUE;
	}
# line 129 "../vfminout.st"
	if (((seq_efTest(ssId, vfmin_f) && (pVar->vfmInBtn) == 1) || (seq_efTest(ssId, vfmout_f) && (pVar->vfmOutBtn) == 1)) && ((pVar->DSyRunPrg) == 1 || (pVar->DSxRunPrg) == 1))
	{
		*pNextState = 1;
		*pTransNum = 5;
		return TRUE;
	}
# line 137 "../vfminout.st"
	if (((seq_efTest(ssId, vfmin_f) && (pVar->vfmInBtn) == 1) || (seq_efTest(ssId, vfmout_f) && (pVar->vfmOutBtn) == 1)) && (pVar->VFMRunPrg) == 1)
	{
		*pNextState = 1;
		*pTransNum = 6;
		return TRUE;
	}
# line 145 "../vfminout.st"
	if (((seq_efTest(ssId, vfmin_f) && (pVar->vfmInBtn) == 1) || (seq_efTest(ssId, vfmout_f) && (pVar->vfmOutBtn) == 1)) && (pVar->TBvRunPrg) == 1)
	{
		*pNextState = 1;
		*pTransNum = 7;
		return TRUE;
	}
# line 153 "../vfminout.st"
	if (((seq_efTest(ssId, vfmin_f) && (pVar->vfmInBtn) == 1) || (seq_efTest(ssId, vfmout_f) && (pVar->vfmOutBtn) == 1)) && ((pVar->DTvRunPrg) == 1 || (pVar->DTlpRunPrg) == 1))
	{
		*pNextState = 1;
		*pTransNum = 8;
		return TRUE;
	}
# line 199 "../vfminout.st"
	if ((seq_efTest(ssId, vfmin_f) && (pVar->vfmInBtn) == 1) || (seq_efTest(ssId, vfmout_f) && (pVar->vfmOutBtn) == 1))
	{
		*pNextState = 1;
		*pTransNum = 9;
		return TRUE;
	}
# line 217 "../vfminout.st"
	if (seq_efTest(ssId, fiundo_f) && (pVar->MKRunPrg) == 0 && (pVar->DSyRunPrg) == 0 && (pVar->DSxRunPrg) == 0 && (pVar->TBvRunPrg) == 0 && (pVar->VFMRunPrg) == 0 && (pVar->DTlpRunPrg) == 0 && (pVar->DTvRunPrg) == 0)
	{
		*pNextState = 0;
		*pTransNum = 10;
		return TRUE;
	}
# line 224 "../vfminout.st"
	if (seq_efTestAndClear(ssId, clean_f))
	{
		*pNextState = 1;
		*pTransNum = 11;
		return TRUE;
	}
# line 279 "../vfminout.st"
	if (seq_efTest(ssId, undo_f) && (pVar->undoBtn) == 1)
	{
		*pNextState = 1;
		*pTransNum = 12;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "mntr" in state set "setQ" */
static void A_setQ_mntr(SS_ID ssId, struct UserVar *pVar, short transNum)
{
	switch(transNum)
	{
	case 0:
		{
# line 51 "../vfminout.st"
			printf("vfmio: mntr: entering msg.\n");
# line 53 "../vfminout.st"
 tsLocalTime(&tmc);
 tsStampToText (&tmc, TS_TEXT_MMDDYY, pVar->time_str);
# line 62 "../vfminout.st"
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
						seq_pvPut(ssId, 87 /* msg */ + ((pVar->i)), 0);
						epicsThreadSleep(0.001);
					}
				}
			}
# line 63 "../vfminout.st"
			sprintf((pVar->msg)[(pVar->msgI)], "%8.8s %s",  & (pVar->time_str)[9], (pVar->msgQ));
# line 63 "../vfminout.st"
			seq_pvPut(ssId, 87 /* msg */ + ((pVar->msgI)), 0);
# line 63 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, msg_f);
# line 64 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: mntr: leaving msg.\n");
		}
		return;
	case 1:
		{
# line 68 "../vfminout.st"
			printf("vfmio: mntr: entering abort.\n");
			(pVar->MKvAbort) = 1;
# line 69 "../vfminout.st"
			seq_pvPut(ssId, 34 /* MKvAbort */, 0);
# line 69 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSyAbort) = 1;
# line 70 "../vfminout.st"
			seq_pvPut(ssId, 44 /* DSyAbort */, 0);
# line 70 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSxAbort) = 1;
# line 71 "../vfminout.st"
			seq_pvPut(ssId, 46 /* DSxAbort */, 0);
# line 71 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->VFMAbort) = 1;
# line 72 "../vfminout.st"
			seq_pvPut(ssId, 52 /* VFMAbort */, 0);
# line 72 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->TBvAbort) = 1;
# line 73 "../vfminout.st"
			seq_pvPut(ssId, 60 /* TBvAbort */, 0);
# line 73 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTlpAbort) = 1;
# line 74 "../vfminout.st"
			seq_pvPut(ssId, 80 /* DTlpAbort */, 0);
# line 74 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvAbort) = 1;
# line 75 "../vfminout.st"
			seq_pvPut(ssId, 85 /* DTvAbort */, 0);
# line 75 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTlpAuto) = 0;
# line 76 "../vfminout.st"
			seq_pvPut(ssId, 78 /* DTlpAuto */, 0);
# line 76 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvAuto) = 0;
# line 77 "../vfminout.st"
			seq_pvPut(ssId, 83 /* DTvAuto */, 0);
# line 77 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSyAuto) = 0;
# line 78 "../vfminout.st"
			seq_pvPut(ssId, 42 /* DSyAuto */, 0);
# line 78 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->TBvAuto) = 0;
# line 79 "../vfminout.st"
			seq_pvPut(ssId, 60 /* TBvAbort */, 0);
# line 79 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTlpAuto) = 0;
# line 80 "../vfminout.st"
			seq_pvPut(ssId, 78 /* DTlpAuto */, 0);
# line 80 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvAuto) = 0;
# line 81 "../vfminout.st"
			seq_pvPut(ssId, 83 /* DTvAuto */, 0);
# line 81 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->lpCorrOff) = 1;
# line 82 "../vfminout.st"
			seq_pvPut(ssId, 77 /* lpCorrOff */, 0);
# line 82 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->stCorrOff) = 1;
# line 83 "../vfminout.st"
			seq_pvPut(ssId, 82 /* stCorrOff */, 0);
# line 83 "../vfminout.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "**Job aborted. Ready.");
# line 84 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 84 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: mntr: **Job is aborted. Ready.\n");
			seq_efClear(ssId, movevfm_f);
# line 86 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, postmove_f);
# line 87 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, finished_f);
# line 88 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fiundo_f);
# line 89 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmInBtn) = 0;
# line 90 "../vfminout.st"
			seq_pvPut(ssId, 0 /* vfmInBtn */, 0);
# line 90 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmin_f);
# line 91 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmOutBtn) = 0;
# line 92 "../vfminout.st"
			seq_pvPut(ssId, 1 /* vfmOutBtn */, 0);
# line 92 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmout_f);
# line 93 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->abortBtn) = 0;
# line 94 "../vfminout.st"
			seq_pvPut(ssId, 2 /* abortBtn */, 0);
# line 94 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 94 "../vfminout.st"
			seq_efClear(ssId, abort_f);
# line 94 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmIOWrkng) = 0;
# line 95 "../vfminout.st"
			seq_pvPut(ssId, 9 /* vfmIOWrkng */, 0);
# line 95 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: mntr: leaving abort.\n");
		}
		return;
	case 2:
		{
# line 99 "../vfminout.st"
			sprintf((pVar->msgQ), "**Change-Energy working.");
# line 99 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 99 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: mntr: Change-Energy working.\n");
			(pVar->vfmInBtn) = 0;
# line 101 "../vfminout.st"
			seq_pvPut(ssId, 0 /* vfmInBtn */, 0);
# line 101 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmin_f);
# line 102 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmOutBtn) = 0;
# line 103 "../vfminout.st"
			seq_pvPut(ssId, 1 /* vfmOutBtn */, 0);
# line 103 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmout_f);
# line 104 "../vfminout.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 3:
		{
# line 107 "../vfminout.st"
			sprintf((pVar->msgQ), "**Center-Beam working.");
# line 107 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 107 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: mntr: Center-Beam script is working.\n");
			(pVar->vfmInBtn) = 0;
# line 109 "../vfminout.st"
			seq_pvPut(ssId, 0 /* vfmInBtn */, 0);
# line 109 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmin_f);
# line 110 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmOutBtn) = 0;
# line 111 "../vfminout.st"
			seq_pvPut(ssId, 1 /* vfmOutBtn */, 0);
# line 111 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmout_f);
# line 112 "../vfminout.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 4:
		{
# line 115 "../vfminout.st"
			sprintf((pVar->msgQ), "**Masks moving.");
# line 115 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 115 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: mntr: Masks moving.\n");
			(pVar->vfmInBtn) = 0;
# line 117 "../vfminout.st"
			seq_pvPut(ssId, 0 /* vfmInBtn */, 0);
# line 117 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmin_f);
# line 118 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmOutBtn) = 0;
# line 119 "../vfminout.st"
			seq_pvPut(ssId, 1 /* vfmOutBtn */, 0);
# line 119 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmout_f);
# line 120 "../vfminout.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 5:
		{
# line 123 "../vfminout.st"
			sprintf((pVar->msgQ), "**DS slit moving.");
# line 123 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 123 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: mntr: DS slit moving.\n");
			(pVar->vfmInBtn) = 0;
# line 125 "../vfminout.st"
			seq_pvPut(ssId, 0 /* vfmInBtn */, 0);
# line 125 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmin_f);
# line 126 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmOutBtn) = 0;
# line 127 "../vfminout.st"
			seq_pvPut(ssId, 1 /* vfmOutBtn */, 0);
# line 127 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmout_f);
# line 128 "../vfminout.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 6:
		{
# line 131 "../vfminout.st"
			sprintf((pVar->msgQ), "**VFM moving.");
# line 131 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 131 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: mntr: VFM moving.\n");
			(pVar->vfmInBtn) = 0;
# line 133 "../vfminout.st"
			seq_pvPut(ssId, 0 /* vfmInBtn */, 0);
# line 133 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmin_f);
# line 134 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmOutBtn) = 0;
# line 135 "../vfminout.st"
			seq_pvPut(ssId, 1 /* vfmOutBtn */, 0);
# line 135 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmout_f);
# line 136 "../vfminout.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 7:
		{
# line 139 "../vfminout.st"
			sprintf((pVar->msgQ), "**MD2 Table moving.");
# line 139 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 139 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: mntr: MD2 Table moving.\n");
			(pVar->vfmInBtn) = 0;
# line 141 "../vfminout.st"
			seq_pvPut(ssId, 0 /* vfmInBtn */, 0);
# line 141 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmin_f);
# line 142 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmOutBtn) = 0;
# line 143 "../vfminout.st"
			seq_pvPut(ssId, 1 /* vfmOutBtn */, 0);
# line 143 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmout_f);
# line 144 "../vfminout.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 8:
		{
# line 147 "../vfminout.st"
			sprintf((pVar->msgQ), "**Detector moving.");
# line 147 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 147 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: mntr: Detector moving.\n");
			(pVar->vfmInBtn) = 0;
# line 149 "../vfminout.st"
			seq_pvPut(ssId, 0 /* vfmInBtn */, 0);
# line 149 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmin_f);
# line 150 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmOutBtn) = 0;
# line 151 "../vfminout.st"
			seq_pvPut(ssId, 1 /* vfmOutBtn */, 0);
# line 151 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmout_f);
# line 152 "../vfminout.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 9:
		{
# line 156 "../vfminout.st"
			seq_pvGet(ssId, 13 /* attUnit */, 0);
# line 156 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 156 "../vfminout.st"
			(pVar->startAttUnit) = (pVar->attUnit);
			seq_pvGet(ssId, 14 /* attAct */, 0);
# line 157 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 157 "../vfminout.st"
			(pVar->startAtt) = (pVar->attAct);
			seq_pvGet(ssId, 32 /* actMKys */, 0);
# line 158 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 158 "../vfminout.st"
			(pVar->startMKys) = (pVar->actMKys);
			seq_pvGet(ssId, 36 /* actDSyc */, 0);
# line 159 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 159 "../vfminout.st"
			(pVar->startDSyc) = (pVar->actDSyc);
			seq_pvGet(ssId, 38 /* actDSys */, 0);
# line 160 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 160 "../vfminout.st"
			(pVar->startDSys) = (pVar->actDSys);
			seq_pvGet(ssId, 40 /* actDSxs */, 0);
# line 161 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 161 "../vfminout.st"
			(pVar->startDSxs) = (pVar->actDSxs);
			seq_pvGet(ssId, 48 /* actKBvy */, 0);
# line 162 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 162 "../vfminout.st"
			(pVar->startVFMh) = (pVar->actKBvy);
			seq_pvGet(ssId, 54 /* actTBh */, 0);
# line 163 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 163 "../vfminout.st"
			(pVar->startTBh) = (pVar->actTBh);
			seq_pvGet(ssId, 56 /* actTBa */, 0);
# line 164 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 164 "../vfminout.st"
			(pVar->startTBa) = (pVar->actTBa);
			seq_pvGet(ssId, 67 /* DTdAct */, 0);
# line 165 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 165 "../vfminout.st"
			(pVar->startDTd) = (pVar->DTdAct);
			seq_pvGet(ssId, 69 /* DThAct */, 0);
# line 166 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 166 "../vfminout.st"
			(pVar->startDTh) = (pVar->DThAct);
			seq_pvGet(ssId, 71 /* DTxAct */, 0);
# line 167 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 167 "../vfminout.st"
			(pVar->startDTx) = (pVar->DTxAct);
			seq_pvGet(ssId, 62 /* DTvdsOff */, 0);
# line 168 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 168 "../vfminout.st"
			(pVar->startDTvOff) = (pVar->DTvdsOff);
			seq_pvGet(ssId, 75 /* DTvCorAng */, 0);
# line 169 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 169 "../vfminout.st"
			(pVar->startDTav) = (pVar->DTvCorAng);
			seq_pvGet(ssId, 76 /* DTvCorSh */, 0);
# line 170 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 170 "../vfminout.st"
			(pVar->startDTsv) = (pVar->DTvCorSh);
			(pVar->preFdbk) = 0;
# line 182 "../vfminout.st"
			if ((pVar->vfmInBtn) == 1)
			{
				(pVar->preHtchSh) = 1;
				(pVar->preAttUnit) = 0;
				(pVar->preAtt) = (pVar->attIn);
				(pVar->preMKys) = 1.0;
				(pVar->preDSys) = 2.0;
				(pVar->preDSxs) = 2.0;
				(pVar->runDSyc) = (pVar->dsHi);
				(pVar->runVFMh) = (pVar->vfmHi);
				(pVar->runTBh) = (pVar->tbHi);
				(pVar->runTBa) = (pVar->tbAi);
				(pVar->postDTvOff) = (pVar->dtOfIn);
				(pVar->postDTvAng) = (pVar->dtAnIn);
				(pVar->postDTvSh) = (pVar->dtShIn);
				seq_efClear(ssId, vfmin_f);
				(pVar->vfmInBtn) == 0;
				epicsThreadSleep(0.001);
				sprintf((pVar->msgQ), "Prepare to move IN.");
				seq_efSet(ssId, msg_f);
				epicsThreadSleep(0.001);
				printf("Prepare to move IN.\n");
				seq_efSet(ssId, movevfm_f);
				epicsThreadSleep(0.001);
				printf("vfmio: mntr: raising movevfm flag, leaving mntr-state.\n");
			}
# line 193 "../vfminout.st"
			else
			if ((pVar->vfmOutBtn) == 1)
			{
				(pVar->preHtchSh) = 1;
				(pVar->attUnit) = 0;
				(pVar->preAtt) = (pVar->attOut);
				(pVar->preMKys) = 2.0;
				(pVar->preDSys) = 0.2;
				(pVar->preDSxs) = 0.7;
				(pVar->runDSyc) = (pVar->dsHo);
				(pVar->runVFMh) = (pVar->vfmHo);
				(pVar->runTBh) = (pVar->tbHo);
				(pVar->runTBa) = (pVar->tbAo);
				(pVar->postDTvOff) = (pVar->dtOfOut);
				(pVar->postDTvAng) = (pVar->dtAnOut);
				(pVar->postDTvSh) = (pVar->dtShOut);
				seq_efClear(ssId, vfmout_f);
				(pVar->vfmOutBtn) == 0;
				epicsThreadSleep(0.001);
				sprintf((pVar->msgQ), "Prepare to move OUT.");
				seq_efSet(ssId, msg_f);
				epicsThreadSleep(0.001);
				printf("Prepare to move OUT.\n");
				seq_efSet(ssId, movevfm_f);
				epicsThreadSleep(0.001);
				printf("vfmio: mntr: raising movevfm flag, leaving mntr-state.\n");
			}
# line 198 "../vfminout.st"
			else
			{
				sprintf((pVar->msgQ), "Unknown flag. Abort.");
				seq_efSet(ssId, msg_f);
				epicsThreadSleep(0.001);
				printf("Unknown flag. Abort.\n");
				(pVar->abortBtn) = 1;
				seq_pvPut(ssId, 2 /* abortBtn */, 0);
				epicsThreadSleep(0.001);
			}
		}
		return;
	case 10:
		{
# line 201 "../vfminout.st"
			(pVar->vfmIOWrkng) = 0;
# line 201 "../vfminout.st"
			seq_pvPut(ssId, 9 /* vfmIOWrkng */, 0);
# line 201 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSyAuto) = 0;
# line 202 "../vfminout.st"
			seq_pvPut(ssId, 42 /* DSyAuto */, 0);
# line 202 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->TBvAuto) = 0;
# line 203 "../vfminout.st"
			seq_pvPut(ssId, 60 /* TBvAbort */, 0);
# line 203 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->lpCorrOff) = 1;
# line 204 "../vfminout.st"
			seq_pvPut(ssId, 77 /* lpCorrOff */, 0);
# line 204 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->stCorrOff) = 1;
# line 205 "../vfminout.st"
			seq_pvPut(ssId, 82 /* stCorrOff */, 0);
# line 205 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTlpAuto) = 0;
# line 206 "../vfminout.st"
			seq_pvPut(ssId, 78 /* DTlpAuto */, 0);
# line 206 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvAuto) = 0;
# line 207 "../vfminout.st"
			seq_pvPut(ssId, 83 /* DTvAuto */, 0);
# line 207 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTlpAbort) = 1;
# line 208 "../vfminout.st"
			seq_pvPut(ssId, 80 /* DTlpAbort */, 0);
# line 208 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvAbort) = 1;
# line 209 "../vfminout.st"
			seq_pvPut(ssId, 85 /* DTvAbort */, 0);
# line 209 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DThRqs) = (pVar->startDTh);
# line 210 "../vfminout.st"
			seq_pvPut(ssId, 70 /* DThRqs */, 0);
# line 210 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTxRqs) = (pVar->startDTx);
# line 211 "../vfminout.st"
			seq_pvPut(ssId, 72 /* DTxRqs */, 0);
# line 211 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTdRqs) = (pVar->startDTd);
# line 212 "../vfminout.st"
			seq_pvPut(ssId, 68 /* DTdRqs */, 0);
# line 212 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fiundo_f);
# line 214 "../vfminout.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "Undo finished. Ready.");
# line 215 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 215 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("mntr: Undo finished. Ready.\n");
		}
		return;
	case 11:
		{
# line 221 "../vfminout.st"
			for ((pVar->i) = 9; (pVar->i) >= 0; (pVar->i)--)
			{
				strcpy((pVar->msg)[(pVar->i)], "");
				seq_pvPut(ssId, 87 /* msg */ + ((pVar->i)), 0);
				epicsThreadSleep(0.001);
			}
# line 222 "../vfminout.st"
			strcpy((pVar->msg)[9], "Ready");
# line 222 "../vfminout.st"
			seq_pvPut(ssId, 87 /* msg */ + (9), 0);
# line 222 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 222 "../vfminout.st"
			(pVar->msgI) = 9;
			(pVar->cleanBtn) = 0;
# line 223 "../vfminout.st"
			seq_pvPut(ssId, 4 /* cleanBtn */, 0);
# line 223 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 223 "../vfminout.st"
			seq_efClear(ssId, clean_f);
# line 223 "../vfminout.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 12:
		{
# line 226 "../vfminout.st"
			printf("mntr: entering undo.\n");
			(pVar->vfmIOWrkng) = 1;
# line 227 "../vfminout.st"
			seq_pvPut(ssId, 9 /* vfmIOWrkng */, 0);
# line 227 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 229 "../vfminout.st"
			seq_efClear(ssId, movevfm_f);
# line 229 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, postmove_f);
# line 230 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, finished_f);
# line 231 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fiundo_f);
# line 232 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmInBtn) = 0;
# line 233 "../vfminout.st"
			seq_pvPut(ssId, 0 /* vfmInBtn */, 0);
# line 233 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmin_f);
# line 234 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmOutBtn) = 0;
# line 235 "../vfminout.st"
			seq_pvPut(ssId, 1 /* vfmOutBtn */, 0);
# line 235 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmout_f);
# line 236 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->abortBtn) = 0;
# line 237 "../vfminout.st"
			seq_pvPut(ssId, 2 /* abortBtn */, 0);
# line 237 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 237 "../vfminout.st"
			seq_efClear(ssId, abort_f);
# line 237 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->undoBtn) = 0;
# line 238 "../vfminout.st"
			seq_pvPut(ssId, 3 /* undoBtn */, 0);
# line 238 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 238 "../vfminout.st"
			seq_efClear(ssId, undo_f);
# line 238 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(0.001);
# line 241 "../vfminout.st"
			(pVar->MKvAbort) = 1;
# line 241 "../vfminout.st"
			seq_pvPut(ssId, 34 /* MKvAbort */, 0);
# line 241 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSyAbort) = 1;
# line 242 "../vfminout.st"
			seq_pvPut(ssId, 44 /* DSyAbort */, 0);
# line 242 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSxAbort) = 1;
# line 243 "../vfminout.st"
			seq_pvPut(ssId, 46 /* DSxAbort */, 0);
# line 243 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->VFMAbort) = 1;
# line 244 "../vfminout.st"
			seq_pvPut(ssId, 52 /* VFMAbort */, 0);
# line 244 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->TBvAbort) = 1;
# line 245 "../vfminout.st"
			seq_pvPut(ssId, 60 /* TBvAbort */, 0);
# line 245 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(0.001);
# line 248 "../vfminout.st"
			(pVar->attUnit) = (pVar->startAttUnit);
# line 248 "../vfminout.st"
			seq_pvPut(ssId, 13 /* attUnit */, 0);
# line 248 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->attRqs) = (pVar->startAtt);
# line 249 "../vfminout.st"
			seq_pvPut(ssId, 15 /* attRqs */, 0);
# line 249 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 251 "../vfminout.st"
			(pVar->rqsMKys) = (pVar->startMKys);
# line 251 "../vfminout.st"
			seq_pvPut(ssId, 33 /* rqsMKys */, 0);
# line 251 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsDSxs) = (pVar->startDSxs);
# line 252 "../vfminout.st"
			seq_pvPut(ssId, 41 /* rqsDSxs */, 0);
# line 252 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsKBvy) = (pVar->startVFMh);
# line 253 "../vfminout.st"
			seq_pvPut(ssId, 49 /* rqsKBvy */, 0);
# line 253 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 255 "../vfminout.st"
			(pVar->DSyAuto) = 1;
# line 255 "../vfminout.st"
			seq_pvPut(ssId, 41 /* rqsDSxs */, 0);
# line 255 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsDSyc) = (pVar->startDSyc);
# line 256 "../vfminout.st"
			seq_pvPut(ssId, 37 /* rqsDSyc */, 0);
# line 256 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsDSys) = (pVar->startDSys);
# line 257 "../vfminout.st"
			seq_pvPut(ssId, 39 /* rqsDSys */, 0);
# line 257 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(0.001);
			(pVar->DSyStart) = 1;
# line 259 "../vfminout.st"
			seq_pvPut(ssId, 43 /* DSyStart */, 0);
# line 259 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 261 "../vfminout.st"
			(pVar->TBvAuto) = 1;
# line 261 "../vfminout.st"
			seq_pvPut(ssId, 58 /* TBvAuto */, 0);
# line 261 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsTBh) = (pVar->startTBh);
# line 262 "../vfminout.st"
			seq_pvPut(ssId, 55 /* rqsTBh */, 0);
# line 262 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsTBa) = (pVar->startTBa);
# line 263 "../vfminout.st"
			seq_pvPut(ssId, 57 /* rqsTBa */, 0);
# line 263 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->TBvStart) = 1;
# line 264 "../vfminout.st"
			seq_pvPut(ssId, 59 /* TBvStart */, 0);
# line 264 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 266 "../vfminout.st"
			(pVar->DTlpAuto) = 1;
# line 266 "../vfminout.st"
			seq_pvPut(ssId, 78 /* DTlpAuto */, 0);
# line 266 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvAuto) = 1;
# line 267 "../vfminout.st"
			seq_pvPut(ssId, 83 /* DTvAuto */, 0);
# line 267 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->lpCorrOff) = 0;
# line 268 "../vfminout.st"
			seq_pvPut(ssId, 77 /* lpCorrOff */, 0);
# line 268 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->stCorrOff) = 0;
# line 269 "../vfminout.st"
			seq_pvPut(ssId, 82 /* stCorrOff */, 0);
# line 269 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(0.001);
			(pVar->DTvdsOff) = (pVar->startDTvOff);
# line 271 "../vfminout.st"
			seq_pvPut(ssId, 62 /* DTvdsOff */, 0);
# line 271 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvCorAng) = (pVar->startDTav);
# line 272 "../vfminout.st"
			seq_pvPut(ssId, 75 /* DTvCorAng */, 0);
# line 272 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvCorSh) = (pVar->startDTsv);
# line 273 "../vfminout.st"
			seq_pvPut(ssId, 76 /* DTvCorSh */, 0);
# line 273 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(3);
			sprintf((pVar->msgQ), "Undo in progress.");
# line 275 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 275 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("mntr: Undo in progress.\n");
			printf("mntr: leaving undo.\n");
			seq_efSet(ssId, fiundo_f);
# line 278 "../vfminout.st"
			epicsThreadSleep(0.001);
		}
		return;
	}
}
/* Code for state "init2" in state set "setX" */

/* Delay function for state "init2" in state set "setX" */
static void D_setX_init2(SS_ID ssId, struct UserVar *pVar)
{
# line 287 "../vfminout.st"
}

/* Event function for state "init2" in state set "setX" */
static long E_setX_init2(SS_ID ssId, struct UserVar *pVar, short *pTransNum, short *pNextState)
{
# line 287 "../vfminout.st"
	if (seq_efTest(ssId, movevfm_f))
	{
		*pNextState = 1;
		*pTransNum = 0;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "init2" in state set "setX" */
static void A_setX_init2(SS_ID ssId, struct UserVar *pVar, short transNum)
{
	switch(transNum)
	{
	case 0:
		{
# line 286 "../vfminout.st"
			epicsThreadSleep(0.001);
		}
		return;
	}
}
/* Code for state "move_vfm" in state set "setX" */

/* Delay function for state "move_vfm" in state set "setX" */
static void D_setX_move_vfm(SS_ID ssId, struct UserVar *pVar)
{
# line 306 "../vfminout.st"
# line 335 "../vfminout.st"
# line 388 "../vfminout.st"
# line 405 "../vfminout.st"
# line 413 "../vfminout.st"
	seq_delayInit(ssId, 0, (480));
# line 425 "../vfminout.st"
# line 442 "../vfminout.st"
# line 497 "../vfminout.st"
}

/* Event function for state "move_vfm" in state set "setX" */
static long E_setX_move_vfm(SS_ID ssId, struct UserVar *pVar, short *pTransNum, short *pNextState)
{
# line 306 "../vfminout.st"
	if (seq_efTestAndClear(ssId, msg_f))
	{
		*pNextState = 1;
		*pTransNum = 0;
		return TRUE;
	}
# line 335 "../vfminout.st"
	if (seq_efTest(ssId, abort_f) && (pVar->abortBtn) == 1)
	{
		*pNextState = 0;
		*pTransNum = 1;
		return TRUE;
	}
# line 388 "../vfminout.st"
	if (seq_efTest(ssId, movevfm_f))
	{
		*pNextState = 1;
		*pTransNum = 2;
		return TRUE;
	}
# line 405 "../vfminout.st"
	if (seq_efTest(ssId, postmove_f) && (pVar->MKRunPrg) == 0 && (pVar->DSyRunPrg) == 0 && (pVar->DSxRunPrg) == 0 && (pVar->TBvRunPrg) == 0 && (pVar->VFMRunPrg) == 0 && (pVar->DTlpRunPrg) == 0 && (pVar->DTvRunPrg) == 0)
	{
		*pNextState = 1;
		*pTransNum = 3;
		return TRUE;
	}
# line 413 "../vfminout.st"
	if (seq_delay(ssId, 0))
	{
		*pNextState = 0;
		*pTransNum = 4;
		return TRUE;
	}
# line 425 "../vfminout.st"
	if (seq_efTest(ssId, finished_f) && (pVar->MKRunPrg) == 0 && (pVar->DSyRunPrg) == 0 && (pVar->DSxRunPrg) == 0 && (pVar->TBvRunPrg) == 0 && (pVar->VFMRunPrg) == 0 && (pVar->DTlpRunPrg) == 0 && (pVar->DTvRunPrg) == 0)
	{
		*pNextState = 0;
		*pTransNum = 5;
		return TRUE;
	}
# line 442 "../vfminout.st"
	if (seq_efTest(ssId, fiundo_f) && (pVar->MKRunPrg) == 0 && (pVar->DSyRunPrg) == 0 && (pVar->DSxRunPrg) == 0 && (pVar->TBvRunPrg) == 0 && (pVar->VFMRunPrg) == 0 && (pVar->DTlpRunPrg) == 0 && (pVar->DTvRunPrg) == 0)
	{
		*pNextState = 0;
		*pTransNum = 6;
		return TRUE;
	}
# line 497 "../vfminout.st"
	if (seq_efTest(ssId, undo_f) && (pVar->undoBtn) == 1)
	{
		*pNextState = 1;
		*pTransNum = 7;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "move_vfm" in state set "setX" */
static void A_setX_move_vfm(SS_ID ssId, struct UserVar *pVar, short transNum)
{
	switch(transNum)
	{
	case 0:
		{
# line 291 "../vfminout.st"
			printf("vfmio: move_vfm: entering msg.\n");
# line 293 "../vfminout.st"
 tsLocalTime(&tmc);
 tsStampToText (&tmc, TS_TEXT_MMDDYY, pVar->time_str);
# line 302 "../vfminout.st"
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
						seq_pvPut(ssId, 87 /* msg */ + ((pVar->i)), 0);
						epicsThreadSleep(0.001);
					}
				}
			}
# line 303 "../vfminout.st"
			sprintf((pVar->msg)[(pVar->msgI)], "%8.8s %s",  & (pVar->time_str)[9], (pVar->msgQ));
# line 303 "../vfminout.st"
			seq_pvPut(ssId, 87 /* msg */ + ((pVar->msgI)), 0);
# line 303 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, msg_f);
# line 304 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: move_vfm: leaving msg.\n");
		}
		return;
	case 1:
		{
# line 308 "../vfminout.st"
			printf("vfmio: move_vfm: entering abort.\n");
			(pVar->MKvAbort) = 1;
# line 309 "../vfminout.st"
			seq_pvPut(ssId, 34 /* MKvAbort */, 0);
# line 309 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSyAbort) = 1;
# line 310 "../vfminout.st"
			seq_pvPut(ssId, 44 /* DSyAbort */, 0);
# line 310 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSxAbort) = 1;
# line 311 "../vfminout.st"
			seq_pvPut(ssId, 46 /* DSxAbort */, 0);
# line 311 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->VFMAbort) = 1;
# line 312 "../vfminout.st"
			seq_pvPut(ssId, 52 /* VFMAbort */, 0);
# line 312 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->TBvAbort) = 1;
# line 313 "../vfminout.st"
			seq_pvPut(ssId, 60 /* TBvAbort */, 0);
# line 313 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTlpAbort) = 1;
# line 314 "../vfminout.st"
			seq_pvPut(ssId, 80 /* DTlpAbort */, 0);
# line 314 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvAbort) = 1;
# line 315 "../vfminout.st"
			seq_pvPut(ssId, 85 /* DTvAbort */, 0);
# line 315 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSyAuto) = 0;
# line 316 "../vfminout.st"
			seq_pvPut(ssId, 42 /* DSyAuto */, 0);
# line 316 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->TBvAuto) = 0;
# line 317 "../vfminout.st"
			seq_pvPut(ssId, 60 /* TBvAbort */, 0);
# line 317 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTlpAuto) = 0;
# line 318 "../vfminout.st"
			seq_pvPut(ssId, 78 /* DTlpAuto */, 0);
# line 318 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvAuto) = 0;
# line 319 "../vfminout.st"
			seq_pvPut(ssId, 83 /* DTvAuto */, 0);
# line 319 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->lpCorrOff) = 1;
# line 320 "../vfminout.st"
			seq_pvPut(ssId, 77 /* lpCorrOff */, 0);
# line 320 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->stCorrOff) = 1;
# line 321 "../vfminout.st"
			seq_pvPut(ssId, 82 /* stCorrOff */, 0);
# line 321 "../vfminout.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "**Job aborted. Ready.");
# line 322 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 322 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: move_vfm: **Job is aborted. Ready.\n");
			seq_efClear(ssId, movevfm_f);
# line 324 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, postmove_f);
# line 325 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, finished_f);
# line 326 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fiundo_f);
# line 327 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmInBtn) = 0;
# line 328 "../vfminout.st"
			seq_pvPut(ssId, 0 /* vfmInBtn */, 0);
# line 328 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmin_f);
# line 329 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmOutBtn) = 0;
# line 330 "../vfminout.st"
			seq_pvPut(ssId, 1 /* vfmOutBtn */, 0);
# line 330 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmout_f);
# line 331 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->abortBtn) = 0;
# line 332 "../vfminout.st"
			seq_pvPut(ssId, 2 /* abortBtn */, 0);
# line 332 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 332 "../vfminout.st"
			seq_efClear(ssId, abort_f);
# line 332 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmIOWrkng) = 0;
# line 333 "../vfminout.st"
			seq_pvPut(ssId, 9 /* vfmIOWrkng */, 0);
# line 333 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: move_vfm: leaving abort.\n");
		}
		return;
	case 2:
		{
# line 337 "../vfminout.st"
			printf("vfmio: move_vfm: move everything.\n");
			seq_efClear(ssId, finished_f);
# line 338 "../vfminout.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "Move everything.");
# line 339 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 339 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmIOWrkng) = 1;
# line 340 "../vfminout.st"
			seq_pvPut(ssId, 9 /* vfmIOWrkng */, 0);
# line 340 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 342 "../vfminout.st"
			(pVar->stopFdbkBtn) = (pVar->preFdbk);
# line 342 "../vfminout.st"
			seq_pvPut(ssId, 5 /* stopFdbkBtn */, 0);
# line 342 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->htchShCl) = (pVar->preHtchSh);
# line 343 "../vfminout.st"
			seq_pvPut(ssId, 11 /* htchShCl */, 0);
# line 343 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 345 "../vfminout.st"
			(pVar->attUnit) = (pVar->preAttUnit);
# line 345 "../vfminout.st"
			seq_pvPut(ssId, 13 /* attUnit */, 0);
# line 345 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->attRqs) = (pVar->preAtt);
# line 346 "../vfminout.st"
			seq_pvPut(ssId, 15 /* attRqs */, 0);
# line 346 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 348 "../vfminout.st"
			(pVar->MKvAbort) = 1;
# line 348 "../vfminout.st"
			seq_pvPut(ssId, 34 /* MKvAbort */, 0);
# line 348 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSyAbort) = 1;
# line 349 "../vfminout.st"
			seq_pvPut(ssId, 44 /* DSyAbort */, 0);
# line 349 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSxAbort) = 1;
# line 350 "../vfminout.st"
			seq_pvPut(ssId, 46 /* DSxAbort */, 0);
# line 350 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->VFMAbort) = 1;
# line 351 "../vfminout.st"
			seq_pvPut(ssId, 52 /* VFMAbort */, 0);
# line 351 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->TBvAbort) = 1;
# line 352 "../vfminout.st"
			seq_pvPut(ssId, 60 /* TBvAbort */, 0);
# line 352 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: move_vfm: enabled all axis.\n");
# line 355 "../vfminout.st"
			(pVar->rqsMKys) = (pVar->preMKys);
# line 355 "../vfminout.st"
			seq_pvPut(ssId, 33 /* rqsMKys */, 0);
# line 355 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 357 "../vfminout.st"
			(pVar->rqsDSxs) = (pVar->preDSxs);
# line 357 "../vfminout.st"
			seq_pvPut(ssId, 41 /* rqsDSxs */, 0);
# line 357 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSyAuto) = 1;
# line 358 "../vfminout.st"
			seq_pvPut(ssId, 42 /* DSyAuto */, 0);
# line 358 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->rqsDSyc) = (pVar->runDSyc);
# line 359 "../vfminout.st"
			seq_pvPut(ssId, 37 /* rqsDSyc */, 0);
# line 359 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsDSys) = (pVar->preDSys);
# line 360 "../vfminout.st"
			seq_pvPut(ssId, 39 /* rqsDSys */, 0);
# line 360 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->DSyStart) = 1;
# line 361 "../vfminout.st"
			seq_pvPut(ssId, 43 /* DSyStart */, 0);
# line 361 "../vfminout.st"
			epicsThreadSleep(0.01);
# line 363 "../vfminout.st"
			(pVar->TBvAuto) = 1;
# line 363 "../vfminout.st"
			seq_pvPut(ssId, 58 /* TBvAuto */, 0);
# line 363 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->rqsTBa) = (pVar->runTBa);
# line 364 "../vfminout.st"
			seq_pvPut(ssId, 57 /* rqsTBa */, 0);
# line 364 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsTBh) = (pVar->runTBh);
# line 365 "../vfminout.st"
			seq_pvPut(ssId, 55 /* rqsTBh */, 0);
# line 365 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->TBvStart) = 1;
# line 366 "../vfminout.st"
			seq_pvPut(ssId, 59 /* TBvStart */, 0);
# line 366 "../vfminout.st"
			epicsThreadSleep(0.01);
			seq_pvFlush(ssId);
			printf("vfmio: move_vfm: started moving MK, DS, TB.\n");
# line 370 "../vfminout.st"
			(pVar->rqsKBvy) = (pVar->runVFMh);
# line 370 "../vfminout.st"
			seq_pvPut(ssId, 49 /* rqsKBvy */, 0);
# line 370 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 373 "../vfminout.st"
			(pVar->DTlpAuto) = 1;
# line 373 "../vfminout.st"
			seq_pvPut(ssId, 78 /* DTlpAuto */, 0);
# line 373 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->DTvAuto) = 1;
# line 374 "../vfminout.st"
			seq_pvPut(ssId, 83 /* DTvAuto */, 0);
# line 374 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->lpCorrOff) = 0;
# line 375 "../vfminout.st"
			seq_pvPut(ssId, 77 /* lpCorrOff */, 0);
# line 375 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->stCorrOff) = 0;
# line 376 "../vfminout.st"
			seq_pvPut(ssId, 82 /* stCorrOff */, 0);
# line 376 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->DTvdsOff) = (pVar->postDTvOff);
# line 377 "../vfminout.st"
			seq_pvPut(ssId, 62 /* DTvdsOff */, 0);
# line 377 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvCorAng) = (pVar->postDTvAng);
# line 378 "../vfminout.st"
			seq_pvPut(ssId, 75 /* DTvCorAng */, 0);
# line 378 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvCorSh) = (pVar->postDTvSh);
# line 379 "../vfminout.st"
			seq_pvPut(ssId, 76 /* DTvCorSh */, 0);
# line 379 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTxRqs) = 0.0;
# line 380 "../vfminout.st"
			seq_pvPut(ssId, 72 /* DTxRqs */, 0);
# line 380 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DThRqs) = 0.0;
# line 381 "../vfminout.st"
			seq_pvPut(ssId, 70 /* DThRqs */, 0);
# line 381 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_pvFlush(ssId);
			epicsThreadSleep(3);
			seq_pvFlush(ssId);
			seq_efClear(ssId, movevfm_f);
# line 385 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, postmove_f);
# line 386 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: move_vfm: leaving motion of everything.\n");
		}
		return;
	case 3:
		{
# line 390 "../vfminout.st"
			sprintf((pVar->msgQ), "DT corrections.");
# line 390 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 390 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("move_vfm: DT corrections.\n");
			(pVar->TBvAuto) = 0;
# line 392 "../vfminout.st"
			seq_pvPut(ssId, 58 /* TBvAuto */, 0);
# line 392 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->lpCorrOff) = 1;
# line 393 "../vfminout.st"
			seq_pvPut(ssId, 77 /* lpCorrOff */, 0);
# line 393 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->stCorrOff) = 1;
# line 394 "../vfminout.st"
			seq_pvPut(ssId, 82 /* stCorrOff */, 0);
# line 394 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->DTlpAuto) = 0;
# line 395 "../vfminout.st"
			seq_pvPut(ssId, 78 /* DTlpAuto */, 0);
# line 395 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->DTvAuto) = 0;
# line 396 "../vfminout.st"
			seq_pvPut(ssId, 83 /* DTvAuto */, 0);
# line 396 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->DTlpAbort) = 1;
# line 397 "../vfminout.st"
			seq_pvPut(ssId, 80 /* DTlpAbort */, 0);
# line 397 "../vfminout.st"
			epicsThreadSleep(0.1);
			(pVar->DTvAbort) = 1;
# line 398 "../vfminout.st"
			seq_pvPut(ssId, 85 /* DTvAbort */, 0);
# line 398 "../vfminout.st"
			epicsThreadSleep(0.1);
			epicsThreadSleep(1);
			(pVar->DTdRqs) = 700;
# line 400 "../vfminout.st"
			seq_pvPut(ssId, 68 /* DTdRqs */, 0);
# line 400 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(1);
			seq_efClear(ssId, postmove_f);
# line 402 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, finished_f);
# line 403 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("vfmio: move_vfm: leaving post-move.\n");
		}
		return;
	case 4:
		{
# line 407 "../vfminout.st"
			sprintf((pVar->msgQ), "**Timeout. Abort");
# line 407 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 407 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("move_vfm: Timeout. Abort.\n");
			seq_efClear(ssId, movevfm_f);
# line 409 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, postmove_f);
# line 410 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, finished_f);
# line 411 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->abortBtn) = 1;
# line 412 "../vfminout.st"
			seq_pvPut(ssId, 2 /* abortBtn */, 0);
# line 412 "../vfminout.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 5:
		{
# line 415 "../vfminout.st"
			(pVar->vfmIOWrkng) = 0;
# line 415 "../vfminout.st"
			seq_pvPut(ssId, 9 /* vfmIOWrkng */, 0);
# line 415 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(0.001);
			(pVar->DSyAuto) = 0;
# line 417 "../vfminout.st"
			seq_pvPut(ssId, 42 /* DSyAuto */, 0);
# line 417 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->TBvAuto) = 0;
# line 418 "../vfminout.st"
			seq_pvPut(ssId, 60 /* TBvAbort */, 0);
# line 418 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTlpAuto) = 0;
# line 419 "../vfminout.st"
			seq_pvPut(ssId, 78 /* DTlpAuto */, 0);
# line 419 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvAuto) = 0;
# line 420 "../vfminout.st"
			seq_pvPut(ssId, 83 /* DTvAuto */, 0);
# line 420 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(0.001);
			seq_efClear(ssId, finished_f);
# line 422 "../vfminout.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "Ready.");
# line 423 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 423 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("move_vfm: Move VFM finished. Ready.\n");
		}
		return;
	case 6:
		{
# line 427 "../vfminout.st"
			(pVar->vfmIOWrkng) = 0;
# line 427 "../vfminout.st"
			seq_pvPut(ssId, 9 /* vfmIOWrkng */, 0);
# line 427 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSyAuto) = 0;
# line 428 "../vfminout.st"
			seq_pvPut(ssId, 42 /* DSyAuto */, 0);
# line 428 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->TBvAuto) = 0;
# line 429 "../vfminout.st"
			seq_pvPut(ssId, 60 /* TBvAbort */, 0);
# line 429 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->lpCorrOff) = 1;
# line 430 "../vfminout.st"
			seq_pvPut(ssId, 77 /* lpCorrOff */, 0);
# line 430 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->stCorrOff) = 1;
# line 431 "../vfminout.st"
			seq_pvPut(ssId, 82 /* stCorrOff */, 0);
# line 431 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTlpAuto) = 0;
# line 432 "../vfminout.st"
			seq_pvPut(ssId, 78 /* DTlpAuto */, 0);
# line 432 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvAuto) = 0;
# line 433 "../vfminout.st"
			seq_pvPut(ssId, 83 /* DTvAuto */, 0);
# line 433 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTlpAbort) = 1;
# line 434 "../vfminout.st"
			seq_pvPut(ssId, 80 /* DTlpAbort */, 0);
# line 434 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvAbort) = 1;
# line 435 "../vfminout.st"
			seq_pvPut(ssId, 85 /* DTvAbort */, 0);
# line 435 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DThRqs) = (pVar->startDTh);
# line 436 "../vfminout.st"
			seq_pvPut(ssId, 70 /* DThRqs */, 0);
# line 436 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTxRqs) = (pVar->startDTx);
# line 437 "../vfminout.st"
			seq_pvPut(ssId, 72 /* DTxRqs */, 0);
# line 437 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTdRqs) = (pVar->startDTd);
# line 438 "../vfminout.st"
			seq_pvPut(ssId, 68 /* DTdRqs */, 0);
# line 438 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fiundo_f);
# line 439 "../vfminout.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "Undo finished. Ready.");
# line 440 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 440 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("mntr: Undo finished. Ready.\n");
		}
		return;
	case 7:
		{
# line 444 "../vfminout.st"
			printf("move_vfm: entering undo.\n");
			(pVar->vfmIOWrkng) = 1;
# line 445 "../vfminout.st"
			seq_pvPut(ssId, 9 /* vfmIOWrkng */, 0);
# line 445 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 447 "../vfminout.st"
			seq_efClear(ssId, movevfm_f);
# line 447 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, postmove_f);
# line 448 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, finished_f);
# line 449 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fiundo_f);
# line 450 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmInBtn) = 0;
# line 451 "../vfminout.st"
			seq_pvPut(ssId, 0 /* vfmInBtn */, 0);
# line 451 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmin_f);
# line 452 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->vfmOutBtn) = 0;
# line 453 "../vfminout.st"
			seq_pvPut(ssId, 1 /* vfmOutBtn */, 0);
# line 453 "../vfminout.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, vfmout_f);
# line 454 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->abortBtn) = 0;
# line 455 "../vfminout.st"
			seq_pvPut(ssId, 2 /* abortBtn */, 0);
# line 455 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 455 "../vfminout.st"
			seq_efClear(ssId, abort_f);
# line 455 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->undoBtn) = 0;
# line 456 "../vfminout.st"
			seq_pvPut(ssId, 3 /* undoBtn */, 0);
# line 456 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 456 "../vfminout.st"
			seq_efClear(ssId, undo_f);
# line 456 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(0.001);
# line 459 "../vfminout.st"
			(pVar->MKvAbort) = 1;
# line 459 "../vfminout.st"
			seq_pvPut(ssId, 34 /* MKvAbort */, 0);
# line 459 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSyAbort) = 1;
# line 460 "../vfminout.st"
			seq_pvPut(ssId, 44 /* DSyAbort */, 0);
# line 460 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DSxAbort) = 1;
# line 461 "../vfminout.st"
			seq_pvPut(ssId, 46 /* DSxAbort */, 0);
# line 461 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->VFMAbort) = 1;
# line 462 "../vfminout.st"
			seq_pvPut(ssId, 52 /* VFMAbort */, 0);
# line 462 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->TBvAbort) = 1;
# line 463 "../vfminout.st"
			seq_pvPut(ssId, 60 /* TBvAbort */, 0);
# line 463 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(0.001);
# line 466 "../vfminout.st"
			(pVar->attUnit) = (pVar->startAttUnit);
# line 466 "../vfminout.st"
			seq_pvPut(ssId, 13 /* attUnit */, 0);
# line 466 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->attRqs) = (pVar->startAtt);
# line 467 "../vfminout.st"
			seq_pvPut(ssId, 15 /* attRqs */, 0);
# line 467 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 469 "../vfminout.st"
			(pVar->rqsMKys) = (pVar->startMKys);
# line 469 "../vfminout.st"
			seq_pvPut(ssId, 33 /* rqsMKys */, 0);
# line 469 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsDSxs) = (pVar->startDSxs);
# line 470 "../vfminout.st"
			seq_pvPut(ssId, 41 /* rqsDSxs */, 0);
# line 470 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsKBvy) = (pVar->startVFMh);
# line 471 "../vfminout.st"
			seq_pvPut(ssId, 49 /* rqsKBvy */, 0);
# line 471 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 473 "../vfminout.st"
			(pVar->DSyAuto) = 1;
# line 473 "../vfminout.st"
			seq_pvPut(ssId, 41 /* rqsDSxs */, 0);
# line 473 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsDSyc) = (pVar->startDSyc);
# line 474 "../vfminout.st"
			seq_pvPut(ssId, 37 /* rqsDSyc */, 0);
# line 474 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsDSys) = (pVar->startDSys);
# line 475 "../vfminout.st"
			seq_pvPut(ssId, 39 /* rqsDSys */, 0);
# line 475 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(0.001);
			(pVar->DSyStart) = 1;
# line 477 "../vfminout.st"
			seq_pvPut(ssId, 43 /* DSyStart */, 0);
# line 477 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 479 "../vfminout.st"
			(pVar->TBvAuto) = 1;
# line 479 "../vfminout.st"
			seq_pvPut(ssId, 58 /* TBvAuto */, 0);
# line 479 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsTBh) = (pVar->startTBh);
# line 480 "../vfminout.st"
			seq_pvPut(ssId, 55 /* rqsTBh */, 0);
# line 480 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->rqsTBa) = (pVar->startTBa);
# line 481 "../vfminout.st"
			seq_pvPut(ssId, 57 /* rqsTBa */, 0);
# line 481 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->TBvStart) = 1;
# line 482 "../vfminout.st"
			seq_pvPut(ssId, 59 /* TBvStart */, 0);
# line 482 "../vfminout.st"
			epicsThreadSleep(0.001);
# line 484 "../vfminout.st"
			(pVar->DTlpAuto) = 1;
# line 484 "../vfminout.st"
			seq_pvPut(ssId, 78 /* DTlpAuto */, 0);
# line 484 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvAuto) = 1;
# line 485 "../vfminout.st"
			seq_pvPut(ssId, 83 /* DTvAuto */, 0);
# line 485 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->lpCorrOff) = 0;
# line 486 "../vfminout.st"
			seq_pvPut(ssId, 77 /* lpCorrOff */, 0);
# line 486 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->stCorrOff) = 0;
# line 487 "../vfminout.st"
			seq_pvPut(ssId, 82 /* stCorrOff */, 0);
# line 487 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(0.001);
			(pVar->DTvdsOff) = (pVar->startDTvOff);
# line 489 "../vfminout.st"
			seq_pvPut(ssId, 62 /* DTvdsOff */, 0);
# line 489 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvCorAng) = (pVar->startDTav);
# line 490 "../vfminout.st"
			seq_pvPut(ssId, 75 /* DTvCorAng */, 0);
# line 490 "../vfminout.st"
			epicsThreadSleep(0.001);
			(pVar->DTvCorSh) = (pVar->startDTsv);
# line 491 "../vfminout.st"
			seq_pvPut(ssId, 76 /* DTvCorSh */, 0);
# line 491 "../vfminout.st"
			epicsThreadSleep(0.001);
			epicsThreadSleep(3);
			sprintf((pVar->msgQ), "Undo in progress.");
# line 493 "../vfminout.st"
			seq_efSet(ssId, msg_f);
# line 493 "../vfminout.st"
			epicsThreadSleep(0.001);
			printf("move_vfm: Undo in progress.\n");
			printf("move_vfm: leaving undo.\n");
			seq_efSet(ssId, fiundo_f);
# line 496 "../vfminout.st"
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
  {"{coioc}:vfmio:StartVFMin", (void *)OFFSET(struct UserVar, vfmInBtn), "vfmInBtn", 
    "int", 1, 12, 1, 1, 0, 0, 0},

  {"{coioc}:vfmio:StartVFMout", (void *)OFFSET(struct UserVar, vfmOutBtn), "vfmOutBtn", 
    "int", 1, 13, 2, 1, 0, 0, 0},

  {"{coioc}:vfmio:Abort", (void *)OFFSET(struct UserVar, abortBtn), "abortBtn", 
    "int", 1, 14, 3, 1, 0, 0, 0},

  {"{coioc}:vfmio:Undo", (void *)OFFSET(struct UserVar, undoBtn), "undoBtn", 
    "int", 1, 15, 4, 1, 0, 0, 0},

  {"{coioc}:vfmio:Clean", (void *)OFFSET(struct UserVar, cleanBtn), "cleanBtn", 
    "int", 1, 16, 5, 1, 0, 0, 0},

  {"{coioc}:fdbk:StopStart", (void *)OFFSET(struct UserVar, stopFdbkBtn), "stopFdbkBtn", 
    "int", 1, 17, 6, 1, 0, 0, 0},

  {"{coioc}:fdbk:fdbkWrkng", (void *)OFFSET(struct UserVar, fdbkWrkng), "fdbkWrkng", 
    "int", 1, 18, 0, 1, 0, 0, 0},

  {"{coioc}:mono:ChEnWrkng", (void *)OFFSET(struct UserVar, chEnWrkng), "chEnWrkng", 
    "int", 1, 19, 0, 1, 0, 0, 0},

  {"{coioc}:mono:CentrWrkng", (void *)OFFSET(struct UserVar, centrWrkng), "centrWrkng", 
    "int", 1, 20, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:VFMioWrkng", (void *)OFFSET(struct UserVar, vfmIOWrkng), "vfmIOWrkng", 
    "int", 1, 21, 0, 1, 0, 0, 0},

  {"PC:21ID:Rem_DshtrOpen", (void *)OFFSET(struct UserVar, htchShOp), "htchShOp", 
    "int", 1, 22, 0, 1, 0, 0, 0},

  {"PC:21ID:Rem_DshtrClose", (void *)OFFSET(struct UserVar, htchShCl), "htchShCl", 
    "int", 1, 23, 0, 1, 0, 0, 0},

  {"PC:21ID:STA_D_SHUTTER_CLOSED", (void *)OFFSET(struct UserVar, htchShSt), "htchShSt", 
    "int", 1, 24, 0, 1, 0, 0, 0},

  {"21:D1:AttUnit", (void *)OFFSET(struct UserVar, attUnit), "attUnit", 
    "double", 1, 25, 0, 1, 0, 0, 0},

  {"21:D1:AttAct", (void *)OFFSET(struct UserVar, attAct), "attAct", 
    "double", 1, 26, 0, 1, 0, 0, 0},

  {"21:D1:AttRqs", (void *)OFFSET(struct UserVar, attRqs), "attRqs", 
    "double", 1, 27, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:AttIn", (void *)OFFSET(struct UserVar, attIn), "attIn", 
    "double", 1, 28, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:AttOut", (void *)OFFSET(struct UserVar, attOut), "attOut", 
    "double", 1, 29, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:DShi", (void *)OFFSET(struct UserVar, dsHi), "dsHi", 
    "double", 1, 30, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:DSho", (void *)OFFSET(struct UserVar, dsHo), "dsHo", 
    "double", 1, 31, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:TBhi", (void *)OFFSET(struct UserVar, tbHi), "tbHi", 
    "double", 1, 32, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:TBho", (void *)OFFSET(struct UserVar, tbHo), "tbHo", 
    "double", 1, 33, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:TBai", (void *)OFFSET(struct UserVar, tbAi), "tbAi", 
    "double", 1, 34, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:TBao", (void *)OFFSET(struct UserVar, tbAo), "tbAo", 
    "double", 1, 35, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:VFMhi", (void *)OFFSET(struct UserVar, vfmHi), "vfmHi", 
    "double", 1, 36, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:VFMho", (void *)OFFSET(struct UserVar, vfmHo), "vfmHo", 
    "double", 1, 37, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:DTVofi", (void *)OFFSET(struct UserVar, dtOfIn), "dtOfIn", 
    "double", 1, 38, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:DTVofo", (void *)OFFSET(struct UserVar, dtOfOut), "dtOfOut", 
    "double", 1, 39, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:DTVani", (void *)OFFSET(struct UserVar, dtAnIn), "dtAnIn", 
    "double", 1, 40, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:DTVano", (void *)OFFSET(struct UserVar, dtAnOut), "dtAnOut", 
    "double", 1, 41, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:DTVshi", (void *)OFFSET(struct UserVar, dtShIn), "dtShIn", 
    "double", 1, 42, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:DTVsho", (void *)OFFSET(struct UserVar, dtShOut), "dtShOut", 
    "double", 1, 43, 0, 1, 0, 0, 0},

  {"21:C1:MK:YS:ActPos", (void *)OFFSET(struct UserVar, actMKys), "actMKys", 
    "double", 1, 44, 0, 1, 0, 0, 0},

  {"21:C1:MK:YS:RqsPos", (void *)OFFSET(struct UserVar, rqsMKys), "rqsMKys", 
    "double", 1, 45, 0, 1, 0, 0, 0},

  {"21:C1:MK:Av:Abort", (void *)OFFSET(struct UserVar, MKvAbort), "MKvAbort", 
    "long", 1, 46, 0, 1, 0, 0, 0},

  {"21:C1:MK:Av:RunPrg", (void *)OFFSET(struct UserVar, MKRunPrg), "MKRunPrg", 
    "long", 1, 47, 0, 1, 0, 0, 0},

  {"21:D1:S1:YC:ActPos", (void *)OFFSET(struct UserVar, actDSyc), "actDSyc", 
    "double", 1, 48, 0, 1, 0, 0, 0},

  {"21:D1:S1:YC:RqsPos", (void *)OFFSET(struct UserVar, rqsDSyc), "rqsDSyc", 
    "double", 1, 49, 0, 1, 0, 0, 0},

  {"21:D1:S1:YS:ActPos", (void *)OFFSET(struct UserVar, actDSys), "actDSys", 
    "double", 1, 50, 0, 1, 0, 0, 0},

  {"21:D1:S1:YS:RqsPos", (void *)OFFSET(struct UserVar, rqsDSys), "rqsDSys", 
    "double", 1, 51, 0, 1, 0, 0, 0},

  {"21:D1:S1:XS:ActPos", (void *)OFFSET(struct UserVar, actDSxs), "actDSxs", 
    "double", 1, 52, 0, 1, 0, 0, 0},

  {"21:D1:S1:XS:RqsPos", (void *)OFFSET(struct UserVar, rqsDSxs), "rqsDSxs", 
    "double", 1, 53, 0, 1, 0, 0, 0},

  {"21:D1:S1:Av:AutoStart", (void *)OFFSET(struct UserVar, DSyAuto), "DSyAuto", 
    "long", 1, 54, 0, 1, 0, 0, 0},

  {"21:D1:S1:Av:Start", (void *)OFFSET(struct UserVar, DSyStart), "DSyStart", 
    "long", 1, 55, 0, 1, 0, 0, 0},

  {"21:D1:S1:Av:Abort", (void *)OFFSET(struct UserVar, DSyAbort), "DSyAbort", 
    "long", 1, 56, 0, 1, 0, 0, 0},

  {"21:D1:S1:Av:RunPrg", (void *)OFFSET(struct UserVar, DSyRunPrg), "DSyRunPrg", 
    "long", 1, 57, 0, 1, 0, 0, 0},

  {"21:D1:S1:Ah:Abort", (void *)OFFSET(struct UserVar, DSxAbort), "DSxAbort", 
    "long", 1, 58, 0, 1, 0, 0, 0},

  {"21:D1:S1:Ah:RunPrg", (void *)OFFSET(struct UserVar, DSxRunPrg), "DSxRunPrg", 
    "long", 1, 59, 0, 1, 0, 0, 0},

  {"21:D1:KB:VY:ActPos", (void *)OFFSET(struct UserVar, actKBvy), "actKBvy", 
    "double", 1, 60, 0, 1, 0, 0, 0},

  {"21:D1:KB:VY:RqsPos", (void *)OFFSET(struct UserVar, rqsKBvy), "rqsKBvy", 
    "double", 1, 61, 0, 1, 0, 0, 0},

  {"21:D1:KB:Vy:AutoStart", (void *)OFFSET(struct UserVar, VFMauto), "VFMauto", 
    "long", 1, 62, 0, 1, 0, 0, 0},

  {"21:D1:KB:Vy:Start", (void *)OFFSET(struct UserVar, VFMstart), "VFMstart", 
    "long", 1, 63, 0, 1, 0, 0, 0},

  {"21:D1:KB:Vy:Abort", (void *)OFFSET(struct UserVar, VFMAbort), "VFMAbort", 
    "long", 1, 64, 0, 1, 0, 0, 0},

  {"21:D1:KB:Vy:RunPrg", (void *)OFFSET(struct UserVar, VFMRunPrg), "VFMRunPrg", 
    "long", 1, 65, 0, 1, 0, 0, 0},

  {"21:D1:TB:H:ActPos", (void *)OFFSET(struct UserVar, actTBh), "actTBh", 
    "double", 1, 66, 0, 1, 0, 0, 0},

  {"21:D1:TB:H:RqsPos", (void *)OFFSET(struct UserVar, rqsTBh), "rqsTBh", 
    "double", 1, 67, 0, 1, 0, 0, 0},

  {"21:D1:TB:A:ActPos", (void *)OFFSET(struct UserVar, actTBa), "actTBa", 
    "double", 1, 68, 0, 1, 0, 0, 0},

  {"21:D1:TB:A:RqsPos", (void *)OFFSET(struct UserVar, rqsTBa), "rqsTBa", 
    "double", 1, 69, 0, 1, 0, 0, 0},

  {"21:D1:TB:Vr:AutoStart", (void *)OFFSET(struct UserVar, TBvAuto), "TBvAuto", 
    "long", 1, 70, 0, 1, 0, 0, 0},

  {"21:D1:TB:Vr:Start", (void *)OFFSET(struct UserVar, TBvStart), "TBvStart", 
    "long", 1, 71, 0, 1, 0, 0, 0},

  {"21:D1:TB:Vr:Abort", (void *)OFFSET(struct UserVar, TBvAbort), "TBvAbort", 
    "long", 1, 72, 0, 1, 0, 0, 0},

  {"21:D1:TB:Vr:RunPrg", (void *)OFFSET(struct UserVar, TBvRunPrg), "TBvRunPrg", 
    "long", 1, 73, 0, 1, 0, 0, 0},

  {"21:D1:DT:VDS:Offset", (void *)OFFSET(struct UserVar, DTvdsOff), "DTvdsOff", 
    "double", 1, 74, 0, 1, 0, 0, 0},

  {"21:D1:DT:VDS:ActPos", (void *)OFFSET(struct UserVar, DTvdsAct), "DTvdsAct", 
    "double", 1, 75, 0, 1, 0, 0, 0},

  {"21:D1:DT:VDS:RqsPos", (void *)OFFSET(struct UserVar, DTvdsRqs), "DTvdsRqs", 
    "double", 1, 76, 0, 1, 0, 0, 0},

  {"21:D1:DT:VUS:ActPos", (void *)OFFSET(struct UserVar, DTvusAct), "DTvusAct", 
    "double", 1, 77, 0, 1, 0, 0, 0},

  {"21:D1:DT:VUS:RqsPos", (void *)OFFSET(struct UserVar, DTvusRqs), "DTvusRqs", 
    "double", 1, 78, 0, 1, 0, 0, 0},

  {"21:D1:DT:Z0:ActPos", (void *)OFFSET(struct UserVar, DTdAct), "DTdAct", 
    "double", 1, 79, 0, 1, 0, 0, 0},

  {"21:D1:DT:Z0:RqsPos", (void *)OFFSET(struct UserVar, DTdRqs), "DTdRqs", 
    "double", 1, 80, 0, 1, 0, 0, 0},

  {"21:D1:DT:H0:ActPos", (void *)OFFSET(struct UserVar, DThAct), "DThAct", 
    "double", 1, 81, 0, 1, 0, 0, 0},

  {"21:D1:DT:H0:RqsPos", (void *)OFFSET(struct UserVar, DThRqs), "DThRqs", 
    "double", 1, 82, 0, 1, 0, 0, 0},

  {"21:D1:DT:XC:ActPos", (void *)OFFSET(struct UserVar, DTxAct), "DTxAct", 
    "double", 1, 83, 0, 1, 0, 0, 0},

  {"21:D1:DT:XC:RqsPos", (void *)OFFSET(struct UserVar, DTxRqs), "DTxRqs", 
    "double", 1, 84, 0, 1, 0, 0, 0},

  {"21:D1:DT:DL:ActPos", (void *)OFFSET(struct UserVar, DTdlAct), "DTdlAct", 
    "double", 1, 85, 0, 1, 0, 0, 0},

  {"21:D1:DT:DL:RqsPos", (void *)OFFSET(struct UserVar, DTdlRqs), "DTdlRqs", 
    "double", 1, 86, 0, 1, 0, 0, 0},

  {"21:D1:DT:St:aV", (void *)OFFSET(struct UserVar, DTvCorAng), "DTvCorAng", 
    "double", 1, 87, 0, 1, 0, 0, 0},

  {"21:D1:DT:St:S", (void *)OFFSET(struct UserVar, DTvCorSh), "DTvCorSh", 
    "double", 1, 88, 0, 1, 0, 0, 0},

  {"21:D1:DT:Lp:mLink", (void *)OFFSET(struct UserVar, lpCorrOff), "lpCorrOff", 
    "long", 1, 89, 0, 1, 0, 0, 0},

  {"21:D1:DT:Lp:AutoStart", (void *)OFFSET(struct UserVar, DTlpAuto), "DTlpAuto", 
    "long", 1, 90, 0, 1, 0, 0, 0},

  {"21:D1:DT:Lp:Start", (void *)OFFSET(struct UserVar, DTlpStart), "DTlpStart", 
    "long", 1, 91, 0, 1, 0, 0, 0},

  {"21:D1:DT:Lp:Abort", (void *)OFFSET(struct UserVar, DTlpAbort), "DTlpAbort", 
    "long", 1, 92, 0, 1, 0, 0, 0},

  {"21:D1:DT:Lp:RunPrg", (void *)OFFSET(struct UserVar, DTlpRunPrg), "DTlpRunPrg", 
    "long", 1, 93, 0, 1, 0, 0, 0},

  {"21:D1:DT:St:mLink", (void *)OFFSET(struct UserVar, stCorrOff), "stCorrOff", 
    "long", 1, 94, 0, 1, 0, 0, 0},

  {"21:D1:DT:St:AutoStart", (void *)OFFSET(struct UserVar, DTvAuto), "DTvAuto", 
    "long", 1, 95, 0, 1, 0, 0, 0},

  {"21:D1:DT:St:Start", (void *)OFFSET(struct UserVar, DTvStart), "DTvStart", 
    "long", 1, 96, 0, 1, 0, 0, 0},

  {"21:D1:DT:St:Abort", (void *)OFFSET(struct UserVar, DTvAbort), "DTvAbort", 
    "long", 1, 97, 0, 1, 0, 0, 0},

  {"21:D1:DT:St:RunPrg", (void *)OFFSET(struct UserVar, DTvRunPrg), "DTvRunPrg", 
    "long", 1, 98, 0, 1, 0, 0, 0},

  {"{coioc}:vfmio:Msg9", (void *)OFFSET(struct UserVar, msg[0][0]), "msg[0]", 
    "string", 1, 99, 0, 0, 0, 0, 0},

  {"{coioc}:vfmio:Msg8", (void *)OFFSET(struct UserVar, msg[1][0]), "msg[1]", 
    "string", 1, 100, 0, 0, 0, 0, 0},

  {"{coioc}:vfmio:Msg7", (void *)OFFSET(struct UserVar, msg[2][0]), "msg[2]", 
    "string", 1, 101, 0, 0, 0, 0, 0},

  {"{coioc}:vfmio:Msg6", (void *)OFFSET(struct UserVar, msg[3][0]), "msg[3]", 
    "string", 1, 102, 0, 0, 0, 0, 0},

  {"{coioc}:vfmio:Msg5", (void *)OFFSET(struct UserVar, msg[4][0]), "msg[4]", 
    "string", 1, 103, 0, 0, 0, 0, 0},

  {"{coioc}:vfmio:Msg4", (void *)OFFSET(struct UserVar, msg[5][0]), "msg[5]", 
    "string", 1, 104, 0, 0, 0, 0, 0},

  {"{coioc}:vfmio:Msg3", (void *)OFFSET(struct UserVar, msg[6][0]), "msg[6]", 
    "string", 1, 105, 0, 0, 0, 0, 0},

  {"{coioc}:vfmio:Msg2", (void *)OFFSET(struct UserVar, msg[7][0]), "msg[7]", 
    "string", 1, 106, 0, 0, 0, 0, 0},

  {"{coioc}:vfmio:Msg1", (void *)OFFSET(struct UserVar, msg[8][0]), "msg[8]", 
    "string", 1, 107, 0, 0, 0, 0, 0},

  {"{coioc}:vfmio:Msg0", (void *)OFFSET(struct UserVar, msg[9][0]), "msg[9]", 
    "string", 1, 108, 0, 0, 0, 0, 0},

};

/* Event masks for state set setQ */
	/* Event mask for state init: */
static bitMask	EM_setQ_init[] = {
	0x00000000,
	0x00000000,
	0x00000000,
	0x00000000,
};
	/* Event mask for state mntr: */
static bitMask	EM_setQ_mntr[] = {
	0x0018f8be,
	0x0a008000,
	0x20000202,
	0x00000004,
};

/* State Blocks */

static struct seqState state_setQ[] = {
	/* State "init" */ {
	/* state name */       "init",
	/* action function */ (ACTION_FUNC) A_setQ_init,
	/* event function */  (EVENT_FUNC) E_setQ_init,
	/* delay function */   (DELAY_FUNC) D_setQ_init,
	/* entry function */   (ENTRY_FUNC) 0,
	/* exit function */   (EXIT_FUNC) 0,
	/* event mask array */ EM_setQ_init,
	/* state options */   (0)},

	/* State "mntr" */ {
	/* state name */       "mntr",
	/* action function */ (ACTION_FUNC) A_setQ_mntr,
	/* event function */  (EVENT_FUNC) E_setQ_mntr,
	/* delay function */   (DELAY_FUNC) D_setQ_mntr,
	/* entry function */   (ENTRY_FUNC) 0,
	/* exit function */   (EXIT_FUNC) 0,
	/* event mask array */ EM_setQ_mntr,
	/* state options */   (0)},


};

/* Event masks for state set setX */
	/* Event mask for state init2: */
static bitMask	EM_setX_init2[] = {
	0x00000100,
	0x00000000,
	0x00000000,
	0x00000000,
};
	/* Event mask for state move_vfm: */
static bitMask	EM_setX_move_vfm[] = {
	0x0000cf98,
	0x0a008000,
	0x20000202,
	0x00000004,
};

/* State Blocks */

static struct seqState state_setX[] = {
	/* State "init2" */ {
	/* state name */       "init2",
	/* action function */ (ACTION_FUNC) A_setX_init2,
	/* event function */  (EVENT_FUNC) E_setX_init2,
	/* delay function */   (DELAY_FUNC) D_setX_init2,
	/* entry function */   (ENTRY_FUNC) 0,
	/* exit function */   (EXIT_FUNC) 0,
	/* event mask array */ EM_setX_init2,
	/* state options */   (0)},

	/* State "move_vfm" */ {
	/* state name */       "move_vfm",
	/* action function */ (ACTION_FUNC) A_setX_move_vfm,
	/* event function */  (EVENT_FUNC) E_setX_move_vfm,
	/* delay function */   (DELAY_FUNC) D_setX_move_vfm,
	/* entry function */   (ENTRY_FUNC) 0,
	/* exit function */   (EXIT_FUNC) 0,
	/* event mask array */ EM_setX_move_vfm,
	/* state options */   (0)},


};

/* State Set Blocks */
static struct seqSS seqSS[NUM_SS] = {
	/* State set "setQ" */ {
	/* ss name */            "setQ",
	/* ptr to state block */ state_setQ,
	/* number of states */   2,
	/* error state */        -1},


	/* State set "setX" */ {
	/* ss name */            "setX",
	/* ptr to state block */ state_setX,
	/* number of states */   2,
	/* error state */        -1},
};

/* Program parameter list */
static char prog_param[] = "coioc=21linux";

/* State Program table (global) */
struct seqProgram vfminout = {
	/* magic number */       20000315,
	/* *name */              "vfminout",
	/* *pChannels */         seqChan,
	/* numChans */           NUM_CHANNELS,
	/* *pSS */               seqSS,
	/* numSS */              NUM_SS,
	/* user variable size */ sizeof(struct UserVar),
	/* *pParams */           prog_param,
	/* numEvents */          NUM_EVENTS,
	/* encoded options */    (0 | OPT_ASYNC | OPT_CONN | OPT_NEWEF | OPT_REENT),
	/* entry handler */      (ENTRY_FUNC) entry_handler,
	/* exit handler */       (EXIT_FUNC) exit_handler,
	/* numQueues */          NUM_QUEUES,
};


/* Register sequencer commands and program */

void vfminoutRegistrar (void) {
    seqRegisterSequencerCommands();
    seqRegisterSequencerProgram (&vfminout);
}
epicsExportRegistrar(vfminoutRegistrar);

