#define TIMEOUT 480
#define ENERGYMIN 5.5
#define ENERGYMAX 20.0
#define RINGCURMIN 60.0
#define TIME2INJMIN 5.0
#define MININT 500
#define MINERR 10
#define THETAMIN -4.9
#define THETAMAX 4.9

%%TS_STAMP tmc;

char   time_str[80];

int status;
int msgI;
int i;
int j;
int line;
int stFactor[3];

double pzStepTimesEn;  /* V/keV */
double curEn;   /* keV */
double fdbkEn;   /* keV */
double minerror;

double actTheta;
double maxTheta;
double maxCnts;
double maxInt;
double cnts;
double step;
double pzStep;
double urad2deg;

int stopStartBtn;    assign stopStartBtn  to "{coioc}:fdbk:StopStart";   monitor stopStartBtn;   evflag stopstart_f;   sync stopStartBtn stopstart_f;
int intPosMenu;      assign intPosMenu    to "{coioc}:fdbk:IntPos";      monitor intPosMenu;     evflag intpos_f;      sync intPosMenu intpos_f;
int monoMirMenu;     assign monoMirMenu   to "{coioc}:fdbk:MonoMir";     monitor monoMirMenu;    evflag monomir_f;     sync monoMirMenu monomir_f;
int offOnPIDMenu;    assign offOnPIDMenu  to "{coioc}:fdbk:OffOnPID";    monitor offOnPIDMenu;   evflag offonpid_f;    sync offOnPIDMenu offonpid_f;
int cleanBtn;        assign cleanBtn      to "{coioc}:fdbk:Clean";       monitor cleanBtn;       evflag clean_f;       sync cleanBtn clean_f;
int fdbkWrkng;       assign fdbkWrkng     to "{coioc}:fdbk:fdbkWrkng";   monitor fdbkWrkng;

double pzScale;      assign pzScale       to "{coioc}:fdbk:PZscale";     monitor pzScale;       /* V/urad */
double fwhmStepMin;  assign fwhmStepMin   to "{coioc}:fdbk:FWHMstep";    monitor fwhmStepMin;   /* sigma */
int    stFactor1;    assign stFactor1     to "{coioc}:fdbk:StFactor1";   monitor stFactor1;
int    stFactor2;    assign stFactor2     to "{coioc}:fdbk:StFactor2";   monitor stFactor2;
int    stFactor3;    assign stFactor3     to "{coioc}:fdbk:StFactor3";   monitor stFactor3;

int chEnWrkng;       assign chEnWrkng     to "{coioc}:mono:ChEnWrkng";   monitor chEnWrkng;
int centrWrkng;      assign centrWrkng    to "{coioc}:mono:CentrWrkng";  monitor centrWrkng;

/* Theta PVs  c3ioc:rmm01:ana01:ao01.VAL */
double curTheta;     assign curTheta      to "c3ioc:rmm01:ana01:ao01.VAL";   monitor curTheta;

/* BPM , Joerger */
double detCnts;  assign detCnts   to "{calcrec}2.VAL";     monitor detCnts;  /* or "21:D1:2:userCalc2.VAL" */
double bpmY;     assign bpmY      to "{calcrec}4.VAL";     monitor bpmY;     /* or "21:D1:2:userCalc4.VAL" */
double bpmX;     assign bpmX      to "{calcrec}5.VAL";     monitor bpmX;     /* or "21:D1:2:userCalc5.VAL" */
int    detMode;  assign detMode   to "{detnm}.CONT";       monitor detMode;  /* 0-OneShot, 1-AutoCount */

/* PID */
/* string rdbckPVPID;  assign rdbckPVPID   to "{pid}.INP";    monitor rdbckPVPID;  */
/* string cntrlPVPID;  assign cntrlPVPID   to "{pid}.OUTL";   monitor cntrlPVPID;  */
/* double setpntPID;   assign setpntPID    to "{pid}.VAL";    monitor setpntPID;  */
/* double rdbckPID;    assign readbckPID   to "{pid}.CVAL";   monitor rdbckPID;  */
/* double updtrtPID;   assign updtrtPID    to "{pid}.SCAN";   monitor updtrtPID;  */
/* ????int fdbkEnaPID;     assign fdbkEnaPID   to "{pid}.FBON";   monitor fdbkEnaPID;  */
/* double kpPID;       assign kpPID        to "{pid}.KP";     monitor kpPID;  */
/* double kiPID;       assign kiPID        to "{pid}.KI";     monitor kiPID;  */
/* double kdPID;       assign kdPID        to "{pid}.KD";     monitor kdPID;  */
/* double pPID;        assign pPID         to "{pid}.P";      monitor pPID;  */
/* double iPID;        assign iPID         to "{pid}.I";      monitor iPID;  */
/* double dPID;        assign dPID         to "{pid}.D";      monitor dPID;  */
/* double deltatPID;   assign deltatPID    to "{pid}.DT";     monitor deltatPID;  */
/* double errorPID;    assign errorPID     to "{pid}.ERR";    monitor errorPID;  */
/* double outputPID;   assign outputPID    to "{pid}.OVAL";   monitor outputPID;  */
/* double loLiPID;     assign loLiPID      to "{pid}.DRVL";   monitor loLiPID;  */
/* double hiLiPID;     assign hiLiPID      to "{pid}.DRVH";   monitor hiLiPID;  */

/* APS ring */
double ringCur;   assign ringCur    to "S:SRcurrentAI";                 monitor ringCur;
double topUpTime; assign topUpTime  to "Mt:TopUpTime2Inject";           monitor topUpTime;
int FESclosed;    assign FESclosed  to "PC:21ID:STA_A_SHUTTER_CLOSED";  monitor FESclosed;
int DSHclosed;    assign DSHclosed  to "PC:21ID:STA_D_SHUTTER_CLOSED";  monitor DSHclosed;

/* Undulator PVs */
double actEnID;   assign actEnID    to "ID21us:Energy.VAL";      monitor actEnID;
int    IDstatus;  assign IDstatus   to "ID21us:Busy.VAL";        monitor IDstatus;

/* Mirrors PVs */
long   VFMRunPrg; assign VFMRunPrg  to "21:D1:KB:Vx:RunPrg";   monitor VFMRunPrg;
long   HFMRunPrg; assign HFMRunPrg  to "21:D1:KB:Hy:RunPrg";   monitor HFMRunPrg;

/* Energy assembly*/
double actEn;       assign actEn       to "21:C1:MO:E:ActPos";    monitor actEn;
double rqsPosEn;    assign rqsPosEn    to "21:C1:MO:E:RqsPos";    monitor rqsPosEn;
long   EnAbort;     assign EnAbort     to "21:C1:MO:En:Abort";    monitor EnAbort;
long   EnKill;      assign EnKill      to "21:C1:MO:En:Kill";     monitor EnKill;
/*long   EnInPos;   assign EnInPos     to "21:C1:MO:En:InPos";    monitor EnInPos;  */
long   EnRunPrg;    assign EnRunPrg    to "21:C1:MO:En:RunPrg";   monitor EnRunPrg;
int    flScanBusy;  assign flScanBusy  to "21:D1:scan4.BUSY";     monitor flScanBusy;

/* Pitch PVs */
double actPitch;    assign actPitch      to "21:C1:MO:P2:ActPos";   monitor actPitch;
double rqsPitch;    assign rqsPitch      to "21:C1:MO:P2:RqsPos";   monitor rqsPitch;
long   piAbort;     assign piAbort       to "21:C1:MO:Tn:Abort";    monitor piAbort;
long   piKill;      assign piKill        to "21:C1:MO:Tn:Kill";     monitor piKill;
/*long   piInPos;  assign piInPos   to "21:C1:MO:Tn:InPos";    monitor piInPos;  */
long   piRunPrg;    assign piRunPrg      to "21:C1:MO:Tn:RunPrg";   monitor piRunPrg;
/* PitchAbort and PitchKill are those same that control CHI !!!! */


string msgQ;
string msg[10];       assign msg[0]  to "{coioc}:fdbk:Msg9";
		      assign msg[1]  to "{coioc}:fdbk:Msg8";
                      assign msg[2]  to "{coioc}:fdbk:Msg7";
                      assign msg[3]  to "{coioc}:fdbk:Msg6";
                      assign msg[4]  to "{coioc}:fdbk:Msg5";
                      assign msg[5]  to "{coioc}:fdbk:Msg4";
                      assign msg[6]  to "{coioc}:fdbk:Msg3";
                      assign msg[7]  to "{coioc}:fdbk:Msg2";
                      assign msg[8]  to "{coioc}:fdbk:Msg1";
                      assign msg[9]  to "{coioc}:fdbk:Msg0";
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
