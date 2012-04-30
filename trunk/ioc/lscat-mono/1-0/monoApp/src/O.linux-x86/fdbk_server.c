/* SNC Version 2.0.12: Fri May 28 19:40:48 2010: fdbk_server.i */

/* Event flags */
#define stopstart_f	1
#define intpos_f	2
#define monomir_f	3
#define offonpid_f	4
#define clean_f	5
#define msg_f	6
#define pause_f	7
#define fdbk_f	8
#define fdbk_run_f	9
#define setpoint_locked_f	10
#define waitfor_ringCur_f	11
#define waitfor_topUp_f	12
#define waitfor_FES_f	13
#define waitfor_DSH_f	14
#define waitfor_ID_f	15
#define waitfor_mono_f	16
#define waitfor_center_f	17
#define waitfor_detMode_f	18
#define waitfor_detCnts_f	19

/* Program "fdbk_server" */
#include "seqCom.h"

#define NUM_SS 2
#define NUM_CHANNELS 47
#define NUM_EVENTS 19
#define NUM_QUEUES 0

#define MAX_STRING_SIZE 40

#define ASYNC_OPT FALSE
#define CONN_OPT TRUE
#define DEBUG_OPT FALSE
#define MAIN_OPT FALSE
#define NEWEF_OPT TRUE
#define REENT_OPT TRUE

extern struct seqProgram fdbk_server;

/* Variable declarations */
struct UserVar {
	char	time_str[80];
	int	status;
	int	msgI;
	int	i;
	int	j;
	int	line;
	int	stFactor[3];
	double	pzStepTimesEn;
	double	curEn;
	double	fdbkEn;
	double	minerror;
	double	actTheta;
	double	maxTheta;
	double	maxCnts;
	double	maxInt;
	double	cnts;
	double	step;
	double	pzStep;
	double	urad2deg;
	int	stopStartBtn;
	int	intPosMenu;
	int	monoMirMenu;
	int	offOnPIDMenu;
	int	cleanBtn;
	int	fdbkWrkng;
	double	pzScale;
	double	fwhmStepMin;
	int	stFactor1;
	int	stFactor2;
	int	stFactor3;
	int	chEnWrkng;
	int	centrWrkng;
	double	curTheta;
	double	detCnts;
	double	bpmY;
	double	bpmX;
	int	detMode;
	double	ringCur;
	double	topUpTime;
	int	FESclosed;
	int	DSHclosed;
	double	actEnID;
	int	IDstatus;
	long	VFMRunPrg;
	long	HFMRunPrg;
	double	actEn;
	double	rqsPosEn;
	long	EnAbort;
	long	EnKill;
	long	EnRunPrg;
	int	flScanBusy;
	double	actPitch;
	double	rqsPitch;
	long	piAbort;
	long	piKill;
	long	piRunPrg;
	char	msgQ[MAX_STRING_SIZE];
	char	msg[10][MAX_STRING_SIZE];
};

/* C code definitions */
# line 6 "../fdbk_server.st"
#include <string.h>
# line 7 "../fdbk_server.st"
#include <math.h>
# line 8 "../fdbk_server.st"
#include <tsDefs.h>
# line 12 "../fdbk_server.h"
TS_STAMP tmc;

/* Entry handler */
static void entry_handler(SS_ID ssId, struct UserVar *pVar)
{
}

/* Code for state "init" in state set "setA" */

/* Delay function for state "init" in state set "setA" */
static void D_setA_init(SS_ID ssId, struct UserVar *pVar)
{
# line 38 "../fdbk_server.st"
}

/* Event function for state "init" in state set "setA" */
static long E_setA_init(SS_ID ssId, struct UserVar *pVar, short *pTransNum, short *pNextState)
{
# line 38 "../fdbk_server.st"
	if (TRUE)
	{
		*pNextState = 1;
		*pTransNum = 0;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "init" in state set "setA" */
static void A_setA_init(SS_ID ssId, struct UserVar *pVar, short transNum)
{
	switch(transNum)
	{
	case 0:
		{
# line 14 "../fdbk_server.st"
			(pVar->status) = 0;
# line 14 "../fdbk_server.st"
			(pVar->curEn) = 0.0;
# line 14 "../fdbk_server.st"
			(pVar->fdbkEn) = 0.0;
# line 14 "../fdbk_server.st"
			(pVar->minerror) = 0.0;
			(pVar->actTheta) = 0.0;
# line 15 "../fdbk_server.st"
			(pVar->maxTheta) = 0.0;
# line 15 "../fdbk_server.st"
			(pVar->maxCnts) = 0.0;
# line 15 "../fdbk_server.st"
			(pVar->step) = 0.0;
			(pVar->line) = 0;
# line 18 "../fdbk_server.st"
			(pVar->stopStartBtn) = 0;
# line 18 "../fdbk_server.st"
			seq_pvPut(ssId, 0 /* stopStartBtn */, 0);
# line 18 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 20 "../fdbk_server.st"
			(pVar->fdbkWrkng) = 0;
# line 20 "../fdbk_server.st"
			seq_pvPut(ssId, 5 /* fdbkWrkng */, 0);
# line 20 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			(pVar->intPosMenu) = 0;
# line 21 "../fdbk_server.st"
			seq_pvPut(ssId, 1 /* intPosMenu */, 0);
# line 21 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			(pVar->monoMirMenu) = 0;
# line 22 "../fdbk_server.st"
			seq_pvPut(ssId, 2 /* monoMirMenu */, 0);
# line 22 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			(pVar->offOnPIDMenu) = 0;
# line 23 "../fdbk_server.st"
			seq_pvPut(ssId, 3 /* offOnPIDMenu */, 0);
# line 23 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_f);
# line 24 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_run_f);
# line 25 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 27 "../fdbk_server.st"
			(pVar->pzStepTimesEn) = 0.1;
# line 27 "../fdbk_server.st"
			(pVar->pzStep) = 0.0;
# line 27 "../fdbk_server.st"
			(pVar->urad2deg) = 5.73e-5;
			(pVar->fwhmStepMin) = 0.02;
# line 28 "../fdbk_server.st"
			seq_pvPut(ssId, 7 /* fwhmStepMin */, 0);
# line 28 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			(pVar->pzScale) = 73.2;
# line 29 "../fdbk_server.st"
			seq_pvPut(ssId, 6 /* pzScale */, 0);
# line 29 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 31 "../fdbk_server.st"
			(pVar->stFactor1) = 2;
# line 31 "../fdbk_server.st"
			seq_pvPut(ssId, 8 /* stFactor1 */, 0);
# line 31 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			(pVar->stFactor2) = 1;
# line 32 "../fdbk_server.st"
			seq_pvPut(ssId, 9 /* stFactor2 */, 0);
# line 32 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			(pVar->stFactor3) = 1;
# line 33 "../fdbk_server.st"
			seq_pvPut(ssId, 10 /* stFactor3 */, 0);
# line 33 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 35 "../fdbk_server.st"
			seq_efClear(ssId, clean_f);
# line 35 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 35 "../fdbk_server.st"
			(pVar->msgI) = 9;
			sprintf((pVar->msgQ), "Server ready.");
# line 36 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 36 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:init:Feedback server ready.\n");
		}
		return;
	}
}
/* Code for state "mntr" in state set "setA" */

/* Delay function for state "mntr" in state set "setA" */
static void D_setA_mntr(SS_ID ssId, struct UserVar *pVar)
{
# line 55 "../fdbk_server.st"
# line 73 "../fdbk_server.st"
# line 82 "../fdbk_server.st"
# line 91 "../fdbk_server.st"
# line 99 "../fdbk_server.st"
# line 107 "../fdbk_server.st"
# line 115 "../fdbk_server.st"
# line 123 "../fdbk_server.st"
# line 131 "../fdbk_server.st"
# line 139 "../fdbk_server.st"
# line 147 "../fdbk_server.st"
# line 155 "../fdbk_server.st"
# line 162 "../fdbk_server.st"
}

/* Event function for state "mntr" in state set "setA" */
static long E_setA_mntr(SS_ID ssId, struct UserVar *pVar, short *pTransNum, short *pNextState)
{
# line 55 "../fdbk_server.st"
	if (seq_efTestAndClear(ssId, msg_f))
	{
		*pNextState = 1;
		*pTransNum = 0;
		return TRUE;
	}
# line 73 "../fdbk_server.st"
	if (seq_efTestAndClear(ssId, stopstart_f) && (pVar->stopStartBtn) == 0)
	{
		*pNextState = 1;
		*pTransNum = 1;
		return TRUE;
	}
# line 82 "../fdbk_server.st"
	if ((pVar->stopStartBtn) == 1 && (pVar->ringCur) < 60.0)
	{
		*pNextState = 2;
		*pTransNum = 2;
		return TRUE;
	}
# line 91 "../fdbk_server.st"
	if ((pVar->stopStartBtn) == 1 && (pVar->topUpTime) < 5.0)
	{
		*pNextState = 2;
		*pTransNum = 3;
		return TRUE;
	}
# line 99 "../fdbk_server.st"
	if ((pVar->stopStartBtn) == 1 && (pVar->FESclosed) == 1)
	{
		*pNextState = 2;
		*pTransNum = 4;
		return TRUE;
	}
# line 107 "../fdbk_server.st"
	if ((pVar->stopStartBtn) == 1 && (pVar->DSHclosed) == 1)
	{
		*pNextState = 2;
		*pTransNum = 5;
		return TRUE;
	}
# line 115 "../fdbk_server.st"
	if ((pVar->stopStartBtn) == 1 && ((pVar->IDstatus) == 1 || ((pVar->actEnID) - (pVar->actEn)) > 0.5))
	{
		*pNextState = 2;
		*pTransNum = 6;
		return TRUE;
	}
# line 123 "../fdbk_server.st"
	if ((pVar->stopStartBtn) == 1 && ((pVar->chEnWrkng) == 1 || (pVar->EnRunPrg) == 1 || (pVar->piRunPrg) == 1 || (pVar->flScanBusy) == 1))
	{
		*pNextState = 2;
		*pTransNum = 7;
		return TRUE;
	}
# line 131 "../fdbk_server.st"
	if ((pVar->stopStartBtn) == 1 && (pVar->centrWrkng) == 1)
	{
		*pNextState = 2;
		*pTransNum = 8;
		return TRUE;
	}
# line 139 "../fdbk_server.st"
	if ((pVar->stopStartBtn) == 1 && (pVar->detMode) == 0)
	{
		*pNextState = 2;
		*pTransNum = 9;
		return TRUE;
	}
# line 147 "../fdbk_server.st"
	if ((pVar->stopStartBtn) == 1 && (pVar->detCnts) < 500)
	{
		*pNextState = 2;
		*pTransNum = 10;
		return TRUE;
	}
# line 155 "../fdbk_server.st"
	if ((pVar->stopStartBtn) == 1 && !seq_efTest(ssId, fdbk_f) && !seq_efTest(ssId, fdbk_run_f))
	{
		*pNextState = 1;
		*pTransNum = 11;
		return TRUE;
	}
# line 162 "../fdbk_server.st"
	if (seq_efTestAndClear(ssId, clean_f))
	{
		*pNextState = 1;
		*pTransNum = 12;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "mntr" in state set "setA" */
static void A_setA_mntr(SS_ID ssId, struct UserVar *pVar, short transNum)
{
	switch(transNum)
	{
	case 0:
		{
# line 43 "../fdbk_server.st"
 tsLocalTime(&tmc);
 tsStampToText (&tmc, TS_TEXT_MMDDYY, pVar->time_str);
# line 52 "../fdbk_server.st"
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
						seq_pvPut(ssId, 37 /* msg */ + ((pVar->i)), 0);
						epicsThreadSleep(0.001);
					}
				}
			}
# line 53 "../fdbk_server.st"
			sprintf((pVar->msg)[(pVar->msgI)], "%8.8s %s",  & (pVar->time_str)[9], (pVar->msgQ));
# line 53 "../fdbk_server.st"
			seq_pvPut(ssId, 37 /* msg */ + ((pVar->msgI)), 0);
# line 53 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, msg_f);
# line 54 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 1:
		{
# line 57 "../fdbk_server.st"
			sprintf((pVar->msgQ), "Feedback stopped.");
# line 57 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 57 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: Feedback stopped.\n");
			(pVar->fdbkWrkng) = 0;
# line 59 "../fdbk_server.st"
			seq_pvPut(ssId, 5 /* fdbkWrkng */, 0);
# line 59 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, pause_f);
# line 60 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_f);
# line 61 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_run_f);
# line 62 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, setpoint_locked_f);
# line 63 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_ringCur_f);
# line 64 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_topUp_f);
# line 65 "../fdbk_server.st"
			epicsThreadSleep(1.0);
			seq_efClear(ssId, waitfor_FES_f);
# line 66 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_DSH_f);
# line 67 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_ID_f);
# line 68 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_mono_f);
# line 69 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_detMode_f);
# line 70 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_detCnts_f);
# line 71 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, stopstart_f);
# line 72 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 2:
		{
# line 76 "../fdbk_server.st"
			sprintf((pVar->msgQ), "**RingCurr low, pause");
# line 76 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 76 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: Ring current is low - pause.\n");
			seq_efSet(ssId, pause_f);
# line 78 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_f);
# line 79 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_run_f);
# line 80 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, waitfor_ringCur_f);
# line 81 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 3:
		{
# line 85 "../fdbk_server.st"
			sprintf((pVar->msgQ), "**Injection, pause");
# line 85 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 85 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: Injection - pause.\n");
			seq_efSet(ssId, pause_f);
# line 87 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_f);
# line 88 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_run_f);
# line 89 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, waitfor_topUp_f);
# line 90 "../fdbk_server.st"
			seq_pvFlush(ssId);
		}
		return;
	case 4:
		{
# line 93 "../fdbk_server.st"
			sprintf((pVar->msgQ), "**FES closed, pause.");
# line 93 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 93 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: FES closed - pause.\n");
			seq_efSet(ssId, pause_f);
# line 95 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_f);
# line 96 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_run_f);
# line 97 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, waitfor_FES_f);
# line 98 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 5:
		{
# line 101 "../fdbk_server.st"
			sprintf((pVar->msgQ), "**D-shut closed, pause.");
# line 101 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 101 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: D-shutter closed - pause.\n");
			seq_efSet(ssId, pause_f);
# line 103 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_f);
# line 104 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_run_f);
# line 105 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, waitfor_DSH_f);
# line 106 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 6:
		{
# line 109 "../fdbk_server.st"
			sprintf((pVar->msgQ), "**ID moving or off");
# line 109 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 109 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr:ID moving or offset is wrong - pause\n");
			seq_efSet(ssId, pause_f);
# line 111 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_f);
# line 112 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_run_f);
# line 113 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, waitfor_ID_f);
# line 114 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 7:
		{
# line 117 "../fdbk_server.st"
			sprintf((pVar->msgQ), "**Energy change, pause");
# line 117 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 117 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: Energy changing - pause\n");
			seq_efSet(ssId, pause_f);
# line 119 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_f);
# line 120 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_run_f);
# line 121 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, waitfor_mono_f);
# line 122 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 8:
		{
# line 125 "../fdbk_server.st"
			sprintf((pVar->msgQ), "**Beam cntrng, pause");
# line 125 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 125 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: Energy changing - pause\n");
			seq_efSet(ssId, pause_f);
# line 127 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_f);
# line 128 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_run_f);
# line 129 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, waitfor_center_f);
# line 130 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 9:
		{
# line 133 "../fdbk_server.st"
			sprintf((pVar->msgQ), "**Wrong Joerger mode");
# line 133 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 133 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: Wrong Joerger mode. \n");
			seq_efSet(ssId, pause_f);
# line 135 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_f);
# line 136 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_run_f);
# line 137 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, waitfor_detMode_f);
# line 138 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 10:
		{
# line 141 "../fdbk_server.st"
			sprintf((pVar->msgQ), "**Beam lost, pause");
# line 141 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 141 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: Beam is lost - stop.\n");
			seq_efSet(ssId, pause_f);
# line 143 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_f);
# line 144 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_run_f);
# line 145 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, waitfor_detCnts_f);
# line 146 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 11:
		{
# line 149 "../fdbk_server.st"
			seq_efClear(ssId, stopstart_f);
# line 149 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			(pVar->fdbkEn) = (pVar->actEn);
# line 150 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			sprintf((pVar->msgQ), "Lock En=%2.3f", (pVar->fdbkEn));
# line 151 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 151 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: Lock En=%2.5f \n", (pVar->fdbkEn));
			seq_efClear(ssId, pause_f);
# line 153 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efSet(ssId, fdbk_f);
# line 154 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 12:
		{
# line 159 "../fdbk_server.st"
			for ((pVar->i) = 9; (pVar->i) >= 0; (pVar->i)--)
			{
				strcpy((pVar->msg)[(pVar->i)], "");
				seq_pvPut(ssId, 37 /* msg */ + ((pVar->i)), 0);
				epicsThreadSleep(0.001);
			}
# line 160 "../fdbk_server.st"
			strcpy((pVar->msg)[9], "Ready");
# line 160 "../fdbk_server.st"
			seq_pvPut(ssId, 37 /* msg */ + (9), 0);
# line 160 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 160 "../fdbk_server.st"
			(pVar->msgI) = 9;
			(pVar->cleanBtn) = 0;
# line 161 "../fdbk_server.st"
			seq_pvPut(ssId, 4 /* cleanBtn */, 0);
# line 161 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 161 "../fdbk_server.st"
			seq_efClear(ssId, clean_f);
# line 161 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	}
}
/* Code for state "waitforsmth" in state set "setA" */

/* Delay function for state "waitforsmth" in state set "setA" */
static void D_setA_waitforsmth(SS_ID ssId, struct UserVar *pVar)
{
# line 179 "../fdbk_server.st"
# line 196 "../fdbk_server.st"
# line 201 "../fdbk_server.st"
# line 206 "../fdbk_server.st"
# line 211 "../fdbk_server.st"
# line 216 "../fdbk_server.st"
# line 221 "../fdbk_server.st"
# line 227 "../fdbk_server.st"
# line 233 "../fdbk_server.st"
# line 238 "../fdbk_server.st"
# line 243 "../fdbk_server.st"
}

/* Event function for state "waitforsmth" in state set "setA" */
static long E_setA_waitforsmth(SS_ID ssId, struct UserVar *pVar, short *pTransNum, short *pNextState)
{
# line 179 "../fdbk_server.st"
	if (seq_efTestAndClear(ssId, msg_f))
	{
		*pNextState = 2;
		*pTransNum = 0;
		return TRUE;
	}
# line 196 "../fdbk_server.st"
	if (seq_efTest(ssId, stopstart_f) && (pVar->stopStartBtn) == 0)
	{
		*pNextState = 1;
		*pTransNum = 1;
		return TRUE;
	}
# line 201 "../fdbk_server.st"
	if (seq_efTest(ssId, waitfor_ringCur_f) && (pVar->stopStartBtn) == 1 && (pVar->ringCur) > 60.0)
	{
		*pNextState = 1;
		*pTransNum = 2;
		return TRUE;
	}
# line 206 "../fdbk_server.st"
	if (seq_efTest(ssId, waitfor_topUp_f) && (pVar->stopStartBtn) == 1 && (pVar->topUpTime) > 5.0)
	{
		*pNextState = 1;
		*pTransNum = 3;
		return TRUE;
	}
# line 211 "../fdbk_server.st"
	if (seq_efTest(ssId, waitfor_FES_f) && (pVar->stopStartBtn) == 1 && (pVar->FESclosed) == 0)
	{
		*pNextState = 1;
		*pTransNum = 4;
		return TRUE;
	}
# line 216 "../fdbk_server.st"
	if (seq_efTest(ssId, waitfor_DSH_f) && (pVar->stopStartBtn) == 1 && (pVar->DSHclosed) == 0)
	{
		*pNextState = 1;
		*pTransNum = 5;
		return TRUE;
	}
# line 221 "../fdbk_server.st"
	if (seq_efTest(ssId, waitfor_ID_f) && (pVar->stopStartBtn) == 1 && (pVar->IDstatus) == 0 && ((pVar->actEnID) - (pVar->actEn)) < 0.5)
	{
		*pNextState = 1;
		*pTransNum = 6;
		return TRUE;
	}
# line 227 "../fdbk_server.st"
	if (seq_efTest(ssId, waitfor_mono_f) && (pVar->stopStartBtn) == 1 && (pVar->chEnWrkng) == 0 && (pVar->EnRunPrg) == 0 && (pVar->piRunPrg) == 0 && (pVar->flScanBusy) == 0)
	{
		*pNextState = 1;
		*pTransNum = 7;
		return TRUE;
	}
# line 233 "../fdbk_server.st"
	if (seq_efTest(ssId, waitfor_center_f) && (pVar->stopStartBtn) == 1 && (pVar->centrWrkng) == 0)
	{
		*pNextState = 1;
		*pTransNum = 8;
		return TRUE;
	}
# line 238 "../fdbk_server.st"
	if (seq_efTest(ssId, waitfor_detMode_f) && (pVar->stopStartBtn) == 1 && (pVar->detMode) == 1)
	{
		*pNextState = 1;
		*pTransNum = 9;
		return TRUE;
	}
# line 243 "../fdbk_server.st"
	if (seq_efTest(ssId, waitfor_detCnts_f) && (pVar->stopStartBtn) == 1 && (pVar->detCnts) > 500)
	{
		*pNextState = 1;
		*pTransNum = 10;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "waitforsmth" in state set "setA" */
static void A_setA_waitforsmth(SS_ID ssId, struct UserVar *pVar, short transNum)
{
	switch(transNum)
	{
	case 0:
		{
# line 167 "../fdbk_server.st"
 tsLocalTime(&tmc);
 tsStampToText (&tmc, TS_TEXT_MMDDYY, pVar->time_str);
# line 176 "../fdbk_server.st"
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
						seq_pvPut(ssId, 37 /* msg */ + ((pVar->i)), 0);
						epicsThreadSleep(0.001);
					}
				}
			}
# line 177 "../fdbk_server.st"
			sprintf((pVar->msg)[(pVar->msgI)], "%8.8s %s",  & (pVar->time_str)[9], (pVar->msgQ));
# line 177 "../fdbk_server.st"
			seq_pvPut(ssId, 37 /* msg */ + ((pVar->msgI)), 0);
# line 177 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, msg_f);
# line 178 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 1:
		{
# line 181 "../fdbk_server.st"
			sprintf((pVar->msgQ), "Feedback stopped.");
# line 181 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 181 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: Feedback stopped.\n");
			seq_efSet(ssId, pause_f);
# line 183 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_f);
# line 184 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, fdbk_run_f);
# line 185 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, setpoint_locked_f);
# line 186 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_ringCur_f);
# line 187 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_topUp_f);
# line 188 "../fdbk_server.st"
			epicsThreadSleep(1.0);
			seq_efClear(ssId, waitfor_FES_f);
# line 189 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_DSH_f);
# line 190 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_ID_f);
# line 191 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_mono_f);
# line 192 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_detMode_f);
# line 193 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, waitfor_detCnts_f);
# line 194 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, stopstart_f);
# line 195 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 2:
		{
# line 198 "../fdbk_server.st"
			sprintf((pVar->msgQ), "Ring current good.");
# line 198 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 198 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: Ring current is good.\n");
			seq_efClear(ssId, waitfor_ringCur_f);
# line 200 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 3:
		{
# line 203 "../fdbk_server.st"
			sprintf((pVar->msgQ), "Injection completed.");
# line 203 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 203 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: Injection completed.\n");
			seq_efClear(ssId, waitfor_topUp_f);
# line 205 "../fdbk_server.st"
			epicsThreadSleep(1.0);
		}
		return;
	case 4:
		{
# line 208 "../fdbk_server.st"
			sprintf((pVar->msgQ), "FES is opened.");
# line 208 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 208 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: FES is opened.\n");
			seq_efClear(ssId, waitfor_FES_f);
# line 210 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 5:
		{
# line 213 "../fdbk_server.st"
			sprintf((pVar->msgQ), "DSH is opened.");
# line 213 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 213 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: DSH is opened.\n");
			seq_efClear(ssId, waitfor_DSH_f);
# line 215 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 6:
		{
# line 218 "../fdbk_server.st"
			sprintf((pVar->msgQ), "ID  is OK.");
# line 218 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 218 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: ID  is OK.\n");
			seq_efClear(ssId, waitfor_ID_f);
# line 220 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 7:
		{
# line 223 "../fdbk_server.st"
			seq_pvGet(ssId, 26 /* actEn */, 0);
# line 223 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 223 "../fdbk_server.st"
			(pVar->fdbkEn) = (pVar->actEn);
			sprintf((pVar->msgQ), "En=%2.3f Pt=%1.5f", (pVar->fdbkEn), (pVar->actPitch));
# line 224 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 224 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state waitfor_mono: Changed En=%2.5f.\n", (pVar->fdbkEn));
			seq_efClear(ssId, waitfor_mono_f);
# line 226 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 8:
		{
# line 229 "../fdbk_server.st"
			seq_pvGet(ssId, 26 /* actEn */, 0);
# line 229 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 229 "../fdbk_server.st"
			(pVar->fdbkEn) = (pVar->actEn);
			sprintf((pVar->msgQ), "Done with cntrng");
# line 230 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 230 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state waitfor_mono: Done with centering.\n", (pVar->fdbkEn));
			seq_efClear(ssId, waitfor_center_f);
# line 232 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 9:
		{
# line 235 "../fdbk_server.st"
			sprintf((pVar->msgQ), "Joerger mode OK");
# line 235 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 235 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: Joerger mode OK.\n");
			seq_efClear(ssId, waitfor_detMode_f);
# line 237 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 10:
		{
# line 240 "../fdbk_server.st"
			sprintf((pVar->msgQ), "Beam intensity OK");
# line 240 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 240 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:state mntr: Beam intensity OK.\n");
			seq_efClear(ssId, waitfor_detCnts_f);
# line 242 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	}
}
/* Code for state "initfdbk" in state set "setB" */

/* Delay function for state "initfdbk" in state set "setB" */
static void D_setB_initfdbk(SS_ID ssId, struct UserVar *pVar)
{
# line 263 "../fdbk_server.st"
# line 271 "../fdbk_server.st"
# line 337 "../fdbk_server.st"
# line 358 "../fdbk_server.st"
# line 379 "../fdbk_server.st"
}

/* Event function for state "initfdbk" in state set "setB" */
static long E_setB_initfdbk(SS_ID ssId, struct UserVar *pVar, short *pTransNum, short *pNextState)
{
# line 263 "../fdbk_server.st"
	if (seq_efTestAndClear(ssId, msg_f))
	{
		*pNextState = 0;
		*pTransNum = 0;
		return TRUE;
	}
# line 271 "../fdbk_server.st"
	if (seq_efTest(ssId, pause_f))
	{
		*pNextState = 0;
		*pTransNum = 1;
		return TRUE;
	}
# line 337 "../fdbk_server.st"
	if (seq_efTest(ssId, fdbk_f) && (pVar->intPosMenu) == 0 && (pVar->offOnPIDMenu) == 0 && (pVar->monoMirMenu) == 0)
	{
		*pNextState = 1;
		*pTransNum = 2;
		return TRUE;
	}
# line 358 "../fdbk_server.st"
	if (seq_efTest(ssId, fdbk_f) && (pVar->intPosMenu) == 0 && (pVar->offOnPIDMenu) == 1 && (pVar->monoMirMenu) == 0)
	{
		*pNextState = 1;
		*pTransNum = 3;
		return TRUE;
	}
# line 379 "../fdbk_server.st"
	if (seq_efTest(ssId, fdbk_f) && (pVar->intPosMenu) == 1 && (pVar->offOnPIDMenu) == 1 && (pVar->monoMirMenu) == 1)
	{
		*pNextState = 1;
		*pTransNum = 4;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "initfdbk" in state set "setB" */
static void A_setB_initfdbk(SS_ID ssId, struct UserVar *pVar, short transNum)
{
	switch(transNum)
	{
	case 0:
		{
# line 251 "../fdbk_server.st"
 tsLocalTime(&tmc);
 tsStampToText (&tmc, TS_TEXT_MMDDYY, pVar->time_str);
# line 260 "../fdbk_server.st"
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
						seq_pvPut(ssId, 37 /* msg */ + ((pVar->i)), 0);
						epicsThreadSleep(0.001);
					}
				}
			}
# line 261 "../fdbk_server.st"
			sprintf((pVar->msg)[(pVar->msgI)], "%8.8s %s",  & (pVar->time_str)[9], (pVar->msgQ));
# line 261 "../fdbk_server.st"
			seq_pvPut(ssId, 37 /* msg */ + ((pVar->msgI)), 0);
# line 261 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, msg_f);
# line 262 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 1:
		{
# line 265 "../fdbk_server.st"
			sprintf((pVar->msgQ), "Init state, pause.");
# line 265 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 265 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:initfdbk: Pause.\n");
# line 268 "../fdbk_server.st"
			seq_efClear(ssId, fdbk_f);
# line 268 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, pause_f);
# line 269 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			(pVar->fdbkWrkng) = 0;
# line 270 "../fdbk_server.st"
			seq_pvPut(ssId, 5 /* fdbkWrkng */, 0);
# line 270 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 2:
		{
# line 274 "../fdbk_server.st"
			(pVar->detMode) = 1;
# line 274 "../fdbk_server.st"
			seq_pvPut(ssId, 17 /* detMode */, 0);
# line 274 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 277 "../fdbk_server.st"
			(pVar->pzStepTimesEn) = (400.0 * (pVar->fwhmStepMin)) / ((pVar->pzScale) * 2.3548);
			(pVar->pzStep) = (pVar->pzStepTimesEn) / (pVar->fdbkEn);
			(pVar->stFactor)[0] = (pVar->stFactor1);
# line 279 "../fdbk_server.st"
			(pVar->stFactor)[1] = (pVar->stFactor2);
# line 279 "../fdbk_server.st"
			(pVar->stFactor)[2] = (pVar->stFactor3);
			(pVar->maxCnts) = 0;
# line 280 "../fdbk_server.st"
			(pVar->line) = 0;
# line 335 "../fdbk_server.st"
			for ((pVar->i) = 0; (pVar->i) < 2; (pVar->i)++)
			{
				seq_pvGet(ssId, 13 /* curTheta */, 0);
				epicsThreadSleep(0.001);
				(pVar->maxTheta) = (pVar->curTheta);
				(pVar->step) = (pVar->pzStep) * (pVar->stFactor)[(pVar->i)];
				(pVar->maxCnts) = 0;
				(pVar->line) = 0;
 do {
				(pVar->cnts) = 0;
				for ((pVar->j) = 0; (pVar->j) < 3; (pVar->j)++)
				{
					epicsThreadSleep(0.2);
					seq_pvGet(ssId, 14 /* detCnts */, 0);
					epicsThreadSleep(0.001);
					(pVar->cnts) = (pVar->cnts) + (pVar->detCnts);
				}
				(pVar->cnts) = (pVar->cnts) / 3.0;
				epicsThreadSleep(0.2);
				seq_pvGet(ssId, 13 /* curTheta */, 0);
				epicsThreadSleep(0.001);
				printf("fdbk:initfdbk: line=%d, step=%f, curTheta=%f, cnts=%f.\n", (pVar->line), (pVar->step), (pVar->curTheta), (pVar->cnts));
				if ((pVar->cnts) >= (pVar->maxCnts))
				{
					(pVar->maxTheta) = (pVar->curTheta);
					(pVar->maxCnts) = (pVar->cnts);
				}
				else
				{
					if ((pVar->line) == 1)
					{
						(pVar->step) = -(pVar->step);
						(pVar->maxCnts) = 0;
						printf("fdbk:initfdbk: Reverse direction.\n");
					}
					else
					{
						printf("fdbk:initfdbk: Maximum is found.\n");
						break;
					}
				}
				(pVar->line)++;
				(pVar->curTheta) += (pVar->step);
				if ((pVar->curTheta) < -4.9 || (pVar->curTheta) > 4.9)
				{
					printf("fdbk:initfdbk: piezo is out of range: curTheta=%f.\n", (pVar->curTheta));
					(pVar->actTheta) = (pVar->curTheta) - (pVar->step);
					(pVar->rqsPitch) = (pVar->actPitch) - (pVar->actTheta) * (pVar->pzScale) * (pVar->urad2deg);
					seq_pvPut(ssId, 33 /* rqsPitch */, 0);
					epicsThreadSleep(0.001);
					(pVar->curTheta) = 0;
				}
				printf("fdbk:initfdbk: curTheta=%f.\n", (pVar->curTheta));
				seq_pvPut(ssId, 13 /* curTheta */, 0);
				epicsThreadSleep(0.001);
				if ((pVar->cnts) < 500 || seq_efTest(ssId, pause_f))
				{
					printf("fdbk:initfdbk: MININT reached or Pause caught. Break the do-loop.\n");
					seq_efSet(ssId, pause_f);
					epicsThreadSleep(0.001);
					seq_efClear(ssId, fdbk_f);
					epicsThreadSleep(0.001);
					break;
				}
 } while(1);
				if ((pVar->cnts) < 500 || seq_efTest(ssId, pause_f))
				{
					printf("fdbk:initfdbk: MININT reached or Pause caught. Break the for-loop.\n");
					seq_efSet(ssId, pause_f);
					epicsThreadSleep(0.001);
					seq_efClear(ssId, fdbk_f);
					epicsThreadSleep(0.001);
					break;
				}
				else
				{
					(pVar->curTheta) = (pVar->maxTheta) - 10.0 * (pVar->step);
					if ((pVar->curTheta) < -4.9 || (pVar->curTheta) > 4.9)
					{
						seq_pvPut(ssId, 13 /* curTheta */, 0);
						epicsThreadSleep(0.001);
					}
					(pVar->curTheta) = (pVar->maxTheta);
					seq_pvPut(ssId, 13 /* curTheta */, 0);
					epicsThreadSleep(0.001);
					(pVar->maxInt) = (pVar->maxCnts);
					sprintf((pVar->msgQ), "Lock maxI=%7.0f", (pVar->maxInt));
					seq_efSet(ssId, msg_f);
					epicsThreadSleep(0.001);
					printf("fdbk:initfdbk: maxInt found: i=%d,  maxInt=%f, maxTheta=%f.\n", (pVar->i), (pVar->maxInt), (pVar->maxTheta));
					seq_efSet(ssId, setpoint_locked_f);
					epicsThreadSleep(0.001);
					seq_efSet(ssId, fdbk_run_f);
					epicsThreadSleep(0.001);
				}
			}
# line 336 "../fdbk_server.st"
			seq_efClear(ssId, fdbk_f);
# line 336 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 3:
		{
# line 352 "../fdbk_server.st"
			sprintf((pVar->msgQ), "Option unavailable");
# line 352 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 352 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:fdbk_run: Intensity/PID fdbk unavailable. Stop.\n");
			seq_efClear(ssId, fdbk_f);
# line 354 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 357 "../fdbk_server.st"
			seq_efSet(ssId, pause_f);
# line 357 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 4:
		{
# line 373 "../fdbk_server.st"
			sprintf((pVar->msgQ), "Option unavailable");
# line 373 "../fdbk_server.st"
			seq_efSet(ssId, msg_f);
# line 373 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:fdbk_run: Y-Pos/PID fdbk unavailable. Stop.\n");
			seq_efClear(ssId, fdbk_f);
# line 375 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 378 "../fdbk_server.st"
			seq_efSet(ssId, pause_f);
# line 378 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	}
}
/* Code for state "fdbk_run" in state set "setB" */

/* Delay function for state "fdbk_run" in state set "setB" */
static void D_setB_fdbk_run(SS_ID ssId, struct UserVar *pVar)
{
# line 396 "../fdbk_server.st"
# line 404 "../fdbk_server.st"
# line 451 "../fdbk_server.st"
}

/* Event function for state "fdbk_run" in state set "setB" */
static long E_setB_fdbk_run(SS_ID ssId, struct UserVar *pVar, short *pTransNum, short *pNextState)
{
# line 396 "../fdbk_server.st"
	if (seq_efTestAndClear(ssId, msg_f))
	{
		*pNextState = 1;
		*pTransNum = 0;
		return TRUE;
	}
# line 404 "../fdbk_server.st"
	if (seq_efTest(ssId, pause_f))
	{
		*pNextState = 0;
		*pTransNum = 1;
		return TRUE;
	}
# line 451 "../fdbk_server.st"
	if (seq_efTest(ssId, fdbk_run_f) && (pVar->intPosMenu) == 0 && (pVar->offOnPIDMenu) == 0 && (pVar->monoMirMenu) == 0)
	{
		*pNextState = 1;
		*pTransNum = 2;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "fdbk_run" in state set "setB" */
static void A_setB_fdbk_run(SS_ID ssId, struct UserVar *pVar, short transNum)
{
	switch(transNum)
	{
	case 0:
		{
# line 384 "../fdbk_server.st"
 tsLocalTime(&tmc);
 tsStampToText (&tmc, TS_TEXT_MMDDYY, pVar->time_str);
# line 393 "../fdbk_server.st"
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
						seq_pvPut(ssId, 37 /* msg */ + ((pVar->i)), 0);
						epicsThreadSleep(0.001);
					}
				}
			}
# line 394 "../fdbk_server.st"
			sprintf((pVar->msg)[(pVar->msgI)], "%8.8s %s",  & (pVar->time_str)[9], (pVar->msgQ));
# line 394 "../fdbk_server.st"
			seq_pvPut(ssId, 37 /* msg */ + ((pVar->msgI)), 0);
# line 394 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, msg_f);
# line 395 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 1:
		{
# line 399 "../fdbk_server.st"
			printf("fdbk:fdbk_run: Pause.\n");
# line 401 "../fdbk_server.st"
			seq_efClear(ssId, fdbk_run_f);
# line 401 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			seq_efClear(ssId, pause_f);
# line 402 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			(pVar->fdbkWrkng) = 0;
# line 403 "../fdbk_server.st"
			seq_pvPut(ssId, 5 /* fdbkWrkng */, 0);
# line 403 "../fdbk_server.st"
			epicsThreadSleep(0.001);
		}
		return;
	case 2:
		{
# line 406 "../fdbk_server.st"
			(pVar->fdbkWrkng) = 1;
# line 406 "../fdbk_server.st"
			seq_pvPut(ssId, 5 /* fdbkWrkng */, 0);
# line 406 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 408 "../fdbk_server.st"
			seq_pvGet(ssId, 13 /* curTheta */, 0);
# line 408 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 408 "../fdbk_server.st"
			(pVar->maxTheta) = (pVar->curTheta);
			(pVar->step) = (pVar->pzStep);
# line 409 "../fdbk_server.st"
			(pVar->maxCnts) = 0;
# line 409 "../fdbk_server.st"
			(pVar->line) = 0;
# line 411 "../fdbk_server.st"
 do {
# line 411 "../fdbk_server.st"
			(pVar->cnts) = 0;
# line 416 "../fdbk_server.st"
			for ((pVar->j) = 0; (pVar->j) < 10; (pVar->j)++)
			{
				epicsThreadSleep(0.2);
				seq_pvGet(ssId, 14 /* detCnts */, 0);
				epicsThreadSleep(0.001);
				(pVar->cnts) = (pVar->cnts) + (pVar->detCnts);
			}
# line 417 "../fdbk_server.st"
			(pVar->cnts) = (pVar->cnts) / 10.0;
# line 417 "../fdbk_server.st"
			epicsThreadSleep(0.2);
			seq_pvGet(ssId, 13 /* curTheta */, 0);
# line 418 "../fdbk_server.st"
			epicsThreadSleep(0.001);
			printf("fdbk:fdbk_run: line=%d, step=%f, curTheta=%f, cnts=%f.\n", (pVar->line), (pVar->step), (pVar->curTheta), (pVar->cnts));
			if ((pVar->cnts) >= (pVar->maxCnts))
			{
				(pVar->maxTheta) = (pVar->curTheta);
				(pVar->maxCnts) = (pVar->cnts);
			}
# line 424 "../fdbk_server.st"
			else
			{
				if ((pVar->line) == 1)
				{
					(pVar->step) = -(pVar->step);
					(pVar->maxCnts) = 0;
					printf("fdbk:fdbk_run: Reverse direction.\n");
				}
				else
				{
					printf("fdbk:fdbk_run: Optimization finished.\n");
					break;
				}
			}
# line 425 "../fdbk_server.st"
			(pVar->line)++;
# line 427 "../fdbk_server.st"
			(pVar->curTheta) += (pVar->step);
# line 435 "../fdbk_server.st"
			if ((pVar->curTheta) < -4.9 || (pVar->curTheta) > 4.9)
			{
				sprintf((pVar->msgQ), "**Piezo out of range");
				seq_efSet(ssId, msg_f);
				epicsThreadSleep(0.001);
				printf("fdbk:fdbk_run: **Theta out of range. Stop.\n");
				seq_efClear(ssId, fdbk_run_f);
				epicsThreadSleep(0.001);
				seq_efSet(ssId, pause_f);
				epicsThreadSleep(0.001);
				break;
			}
# line 436 "../fdbk_server.st"
			printf("fdbk:fdbk_run: curTheta=%f.\n", (pVar->curTheta));
			seq_pvPut(ssId, 13 /* curTheta */, 0);
# line 437 "../fdbk_server.st"
			epicsThreadSleep(0.001);
# line 444 "../fdbk_server.st"
			if ((pVar->cnts) < 500 || seq_efTest(ssId, pause_f))
			{
				sprintf((pVar->msgQ), "Break the loop");
				seq_efSet(ssId, msg_f);
				epicsThreadSleep(0.001);
				printf("fdbk:fdbk_run: MININT reached or Pause caught. Break the do-loop.\n");
				seq_efSet(ssId, pause_f);
				epicsThreadSleep(0.001);
				seq_efClear(ssId, fdbk_run_f);
				epicsThreadSleep(0.001);
				break;
			}
# line 447 "../fdbk_server.st"
 } while(1);
# line 447 "../fdbk_server.st"
			printf("fdbk:fdbk_run: Exit the loop. i=%d theta=%f.\n", (pVar->i), (pVar->maxTheta));
			(pVar->curTheta) = (pVar->maxTheta) - 2.0 * (pVar->step);
			if ((pVar->curTheta) < -4.9 || (pVar->curTheta) > 4.9)
			{
				seq_pvPut(ssId, 13 /* curTheta */, 0);
				epicsThreadSleep(0.001);
			}
# line 450 "../fdbk_server.st"
			(pVar->curTheta) = (pVar->maxTheta);
# line 450 "../fdbk_server.st"
			seq_pvPut(ssId, 13 /* curTheta */, 0);
# line 450 "../fdbk_server.st"
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
  {"{coioc}:fdbk:StopStart", (void *)OFFSET(struct UserVar, stopStartBtn), "stopStartBtn", 
    "int", 1, 20, 1, 1, 0, 0, 0},

  {"{coioc}:fdbk:IntPos", (void *)OFFSET(struct UserVar, intPosMenu), "intPosMenu", 
    "int", 1, 21, 2, 1, 0, 0, 0},

  {"{coioc}:fdbk:MonoMir", (void *)OFFSET(struct UserVar, monoMirMenu), "monoMirMenu", 
    "int", 1, 22, 3, 1, 0, 0, 0},

  {"{coioc}:fdbk:OffOnPID", (void *)OFFSET(struct UserVar, offOnPIDMenu), "offOnPIDMenu", 
    "int", 1, 23, 4, 1, 0, 0, 0},

  {"{coioc}:fdbk:Clean", (void *)OFFSET(struct UserVar, cleanBtn), "cleanBtn", 
    "int", 1, 24, 5, 1, 0, 0, 0},

  {"{coioc}:fdbk:fdbkWrkng", (void *)OFFSET(struct UserVar, fdbkWrkng), "fdbkWrkng", 
    "int", 1, 25, 0, 1, 0, 0, 0},

  {"{coioc}:fdbk:PZscale", (void *)OFFSET(struct UserVar, pzScale), "pzScale", 
    "double", 1, 26, 0, 1, 0, 0, 0},

  {"{coioc}:fdbk:FWHMstep", (void *)OFFSET(struct UserVar, fwhmStepMin), "fwhmStepMin", 
    "double", 1, 27, 0, 1, 0, 0, 0},

  {"{coioc}:fdbk:StFactor1", (void *)OFFSET(struct UserVar, stFactor1), "stFactor1", 
    "int", 1, 28, 0, 1, 0, 0, 0},

  {"{coioc}:fdbk:StFactor2", (void *)OFFSET(struct UserVar, stFactor2), "stFactor2", 
    "int", 1, 29, 0, 1, 0, 0, 0},

  {"{coioc}:fdbk:StFactor3", (void *)OFFSET(struct UserVar, stFactor3), "stFactor3", 
    "int", 1, 30, 0, 1, 0, 0, 0},

  {"{coioc}:mono:ChEnWrkng", (void *)OFFSET(struct UserVar, chEnWrkng), "chEnWrkng", 
    "int", 1, 31, 0, 1, 0, 0, 0},

  {"{coioc}:mono:CentrWrkng", (void *)OFFSET(struct UserVar, centrWrkng), "centrWrkng", 
    "int", 1, 32, 0, 1, 0, 0, 0},

  {"c3ioc:rmm01:ana01:ao01.VAL", (void *)OFFSET(struct UserVar, curTheta), "curTheta", 
    "double", 1, 33, 0, 1, 0, 0, 0},

  {"{calcrec}2.VAL", (void *)OFFSET(struct UserVar, detCnts), "detCnts", 
    "double", 1, 34, 0, 1, 0, 0, 0},

  {"{calcrec}4.VAL", (void *)OFFSET(struct UserVar, bpmY), "bpmY", 
    "double", 1, 35, 0, 1, 0, 0, 0},

  {"{calcrec}5.VAL", (void *)OFFSET(struct UserVar, bpmX), "bpmX", 
    "double", 1, 36, 0, 1, 0, 0, 0},

  {"{detnm}.CONT", (void *)OFFSET(struct UserVar, detMode), "detMode", 
    "int", 1, 37, 0, 1, 0, 0, 0},

  {"S:SRcurrentAI", (void *)OFFSET(struct UserVar, ringCur), "ringCur", 
    "double", 1, 38, 0, 1, 0, 0, 0},

  {"Mt:TopUpTime2Inject", (void *)OFFSET(struct UserVar, topUpTime), "topUpTime", 
    "double", 1, 39, 0, 1, 0, 0, 0},

  {"PC:21ID:STA_A_SHUTTER_CLOSED", (void *)OFFSET(struct UserVar, FESclosed), "FESclosed", 
    "int", 1, 40, 0, 1, 0, 0, 0},

  {"PC:21ID:STA_D_SHUTTER_CLOSED", (void *)OFFSET(struct UserVar, DSHclosed), "DSHclosed", 
    "int", 1, 41, 0, 1, 0, 0, 0},

  {"ID21us:Energy.VAL", (void *)OFFSET(struct UserVar, actEnID), "actEnID", 
    "double", 1, 42, 0, 1, 0, 0, 0},

  {"ID21us:Busy.VAL", (void *)OFFSET(struct UserVar, IDstatus), "IDstatus", 
    "int", 1, 43, 0, 1, 0, 0, 0},

  {"21:D1:KB:Vx:RunPrg", (void *)OFFSET(struct UserVar, VFMRunPrg), "VFMRunPrg", 
    "long", 1, 44, 0, 1, 0, 0, 0},

  {"21:D1:KB:Hy:RunPrg", (void *)OFFSET(struct UserVar, HFMRunPrg), "HFMRunPrg", 
    "long", 1, 45, 0, 1, 0, 0, 0},

  {"21:C1:MO:E:ActPos", (void *)OFFSET(struct UserVar, actEn), "actEn", 
    "double", 1, 46, 0, 1, 0, 0, 0},

  {"21:C1:MO:E:RqsPos", (void *)OFFSET(struct UserVar, rqsPosEn), "rqsPosEn", 
    "double", 1, 47, 0, 1, 0, 0, 0},

  {"21:C1:MO:En:Abort", (void *)OFFSET(struct UserVar, EnAbort), "EnAbort", 
    "long", 1, 48, 0, 1, 0, 0, 0},

  {"21:C1:MO:En:Kill", (void *)OFFSET(struct UserVar, EnKill), "EnKill", 
    "long", 1, 49, 0, 1, 0, 0, 0},

  {"21:C1:MO:En:RunPrg", (void *)OFFSET(struct UserVar, EnRunPrg), "EnRunPrg", 
    "long", 1, 50, 0, 1, 0, 0, 0},

  {"21:D1:scan4.BUSY", (void *)OFFSET(struct UserVar, flScanBusy), "flScanBusy", 
    "int", 1, 51, 0, 1, 0, 0, 0},

  {"21:C1:MO:P2:ActPos", (void *)OFFSET(struct UserVar, actPitch), "actPitch", 
    "double", 1, 52, 0, 1, 0, 0, 0},

  {"21:C1:MO:P2:RqsPos", (void *)OFFSET(struct UserVar, rqsPitch), "rqsPitch", 
    "double", 1, 53, 0, 1, 0, 0, 0},

  {"21:C1:MO:Tn:Abort", (void *)OFFSET(struct UserVar, piAbort), "piAbort", 
    "long", 1, 54, 0, 1, 0, 0, 0},

  {"21:C1:MO:Tn:Kill", (void *)OFFSET(struct UserVar, piKill), "piKill", 
    "long", 1, 55, 0, 1, 0, 0, 0},

  {"21:C1:MO:Tn:RunPrg", (void *)OFFSET(struct UserVar, piRunPrg), "piRunPrg", 
    "long", 1, 56, 0, 1, 0, 0, 0},

  {"{coioc}:fdbk:Msg9", (void *)OFFSET(struct UserVar, msg[0][0]), "msg[0]", 
    "string", 1, 57, 0, 0, 0, 0, 0},

  {"{coioc}:fdbk:Msg8", (void *)OFFSET(struct UserVar, msg[1][0]), "msg[1]", 
    "string", 1, 58, 0, 0, 0, 0, 0},

  {"{coioc}:fdbk:Msg7", (void *)OFFSET(struct UserVar, msg[2][0]), "msg[2]", 
    "string", 1, 59, 0, 0, 0, 0, 0},

  {"{coioc}:fdbk:Msg6", (void *)OFFSET(struct UserVar, msg[3][0]), "msg[3]", 
    "string", 1, 60, 0, 0, 0, 0, 0},

  {"{coioc}:fdbk:Msg5", (void *)OFFSET(struct UserVar, msg[4][0]), "msg[4]", 
    "string", 1, 61, 0, 0, 0, 0, 0},

  {"{coioc}:fdbk:Msg4", (void *)OFFSET(struct UserVar, msg[5][0]), "msg[5]", 
    "string", 1, 62, 0, 0, 0, 0, 0},

  {"{coioc}:fdbk:Msg3", (void *)OFFSET(struct UserVar, msg[6][0]), "msg[6]", 
    "string", 1, 63, 0, 0, 0, 0, 0},

  {"{coioc}:fdbk:Msg2", (void *)OFFSET(struct UserVar, msg[7][0]), "msg[7]", 
    "string", 1, 64, 0, 0, 0, 0, 0},

  {"{coioc}:fdbk:Msg1", (void *)OFFSET(struct UserVar, msg[8][0]), "msg[8]", 
    "string", 1, 65, 0, 0, 0, 0, 0},

  {"{coioc}:fdbk:Msg0", (void *)OFFSET(struct UserVar, msg[9][0]), "msg[9]", 
    "string", 1, 66, 0, 0, 0, 0, 0},

};

/* Event masks for state set setA */
	/* Event mask for state init: */
static bitMask	EM_setA_init[] = {
	0x00000000,
	0x00000000,
	0x00000000,
};
	/* Event mask for state mntr: */
static bitMask	EM_setA_mntr[] = {
	0x80100362,
	0x010c4fe5,
	0x00000000,
};
	/* Event mask for state waitforsmth: */
static bitMask	EM_setA_waitforsmth[] = {
	0x801ff842,
	0x010c4fe5,
	0x00000000,
};

/* State Blocks */

static struct seqState state_setA[] = {
	/* State "init" */ {
	/* state name */       "init",
	/* action function */ (ACTION_FUNC) A_setA_init,
	/* event function */  (EVENT_FUNC) E_setA_init,
	/* delay function */   (DELAY_FUNC) D_setA_init,
	/* entry function */   (ENTRY_FUNC) 0,
	/* exit function */   (EXIT_FUNC) 0,
	/* event mask array */ EM_setA_init,
	/* state options */   (0)},

	/* State "mntr" */ {
	/* state name */       "mntr",
	/* action function */ (ACTION_FUNC) A_setA_mntr,
	/* event function */  (EVENT_FUNC) E_setA_mntr,
	/* delay function */   (DELAY_FUNC) D_setA_mntr,
	/* entry function */   (ENTRY_FUNC) 0,
	/* exit function */   (EXIT_FUNC) 0,
	/* event mask array */ EM_setA_mntr,
	/* state options */   (0)},

	/* State "waitforsmth" */ {
	/* state name */       "waitforsmth",
	/* action function */ (ACTION_FUNC) A_setA_waitforsmth,
	/* event function */  (EVENT_FUNC) E_setA_waitforsmth,
	/* delay function */   (DELAY_FUNC) D_setA_waitforsmth,
	/* entry function */   (ENTRY_FUNC) 0,
	/* exit function */   (EXIT_FUNC) 0,
	/* event mask array */ EM_setA_waitforsmth,
	/* state options */   (0)},


};

/* Event masks for state set setB */
	/* Event mask for state initfdbk: */
static bitMask	EM_setB_initfdbk[] = {
	0x00e001c0,
	0x00000000,
	0x00000000,
};
	/* Event mask for state fdbk_run: */
static bitMask	EM_setB_fdbk_run[] = {
	0x00e002c0,
	0x00000000,
	0x00000000,
};

/* State Blocks */

static struct seqState state_setB[] = {
	/* State "initfdbk" */ {
	/* state name */       "initfdbk",
	/* action function */ (ACTION_FUNC) A_setB_initfdbk,
	/* event function */  (EVENT_FUNC) E_setB_initfdbk,
	/* delay function */   (DELAY_FUNC) D_setB_initfdbk,
	/* entry function */   (ENTRY_FUNC) 0,
	/* exit function */   (EXIT_FUNC) 0,
	/* event mask array */ EM_setB_initfdbk,
	/* state options */   (0)},

	/* State "fdbk_run" */ {
	/* state name */       "fdbk_run",
	/* action function */ (ACTION_FUNC) A_setB_fdbk_run,
	/* event function */  (EVENT_FUNC) E_setB_fdbk_run,
	/* delay function */   (DELAY_FUNC) D_setB_fdbk_run,
	/* entry function */   (ENTRY_FUNC) 0,
	/* exit function */   (EXIT_FUNC) 0,
	/* event mask array */ EM_setB_fdbk_run,
	/* state options */   (0)},


};

/* State Set Blocks */
static struct seqSS seqSS[NUM_SS] = {
	/* State set "setA" */ {
	/* ss name */            "setA",
	/* ptr to state block */ state_setA,
	/* number of states */   3,
	/* error state */        -1},


	/* State set "setB" */ {
	/* ss name */            "setB",
	/* ptr to state block */ state_setB,
	/* number of states */   2,
	/* error state */        -1},
};

/* Program parameter list */
static char prog_param[] = "coioc=21linux, calcrec=21:D1:2:userCalc, detnm=21:D1:scaler1";

/* State Program table (global) */
struct seqProgram fdbk_server = {
	/* magic number */       20000315,
	/* *name */              "fdbk_server",
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

void fdbk_serverRegistrar (void) {
    seqRegisterSequencerCommands();
    seqRegisterSequencerProgram (&fdbk_server);
}
epicsExportRegistrar(fdbk_serverRegistrar);

