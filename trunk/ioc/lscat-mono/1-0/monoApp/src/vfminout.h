#define TIMEOUT 480

%%TS_STAMP tmc;

char   time_str[80];

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

int vfmInBtn;    assign vfmInBtn  to "{coioc}:vfmio:StartVFMin";   monitor vfmInBtn;   evflag vfmin_f;   sync vfmInBtn vfmin_f;
int vfmOutBtn;   assign vfmOutBtn to "{coioc}:vfmio:StartVFMout";  monitor vfmOutBtn;  evflag vfmout_f;  sync vfmOutBtn vfmout_f;
int abortBtn;    assign abortBtn  to "{coioc}:vfmio:Abort";        monitor abortBtn;   evflag abort_f;   sync abortBtn abort_f;
int undoBtn;     assign undoBtn   to "{coioc}:vfmio:Undo";         monitor undoBtn;    evflag undo_f;    sync undoBtn  undo_f;
int cleanBtn;    assign cleanBtn  to "{coioc}:vfmio:Clean";        monitor cleanBtn;   evflag clean_f;   sync cleanBtn clean_f;

int stopFdbkBtn; assign stopFdbkBtn  to "{coioc}:fdbk:StopStart";   monitor stopFdbkBtn;   evflag stopfdbk_f;   sync stopFdbkBtn stopfdbk_f;
int fdbkWrkng;   assign fdbkWrkng    to "{coioc}:fdbk:fdbkWrkng";   monitor fdbkWrkng;

int chEnWrkng;   assign chEnWrkng    to "{coioc}:mono:ChEnWrkng";   monitor chEnWrkng;
int centrWrkng;  assign centrWrkng   to "{coioc}:mono:CentrWrkng";  monitor centrWrkng;

int vfmIOWrkng;  assign vfmIOWrkng   to "{coioc}:vfmio:VFMioWrkng"; monitor vfmIOWrkng;

int htchShOp;    assign htchShOp  to "PC:21ID:Rem_DshtrOpen";        monitor htchShOp;         /* 0-waiting, 1-opening */
int htchShCl;    assign htchShCl  to "PC:21ID:Rem_DshtrClose";       monitor htchShCl;         /* 0-waiting, 1-closing */
int htchShSt;    assign htchShSt  to "PC:21ID:STA_D_SHUTTER_CLOSED"; monitor htchShSt;         /* 0-open, 1-closed */

double attUnit;  assign attUnit   to "21:D1:AttUnit";          monitor attUnit;    /* 0-Factor, 1-Percent */
double attAct;   assign attAct    to "21:D1:AttAct";           monitor attAct;
double attRqs;   assign attRqs    to "21:D1:AttRqs";           monitor attRqs;

double attIn;    assign attIn     to "{coioc}:vfmio:AttIn";   monitor attIn;
double attOut;   assign attOut    to "{coioc}:vfmio:AttOut";  monitor attOut;
double dsHi;     assign dsHi      to "{coioc}:vfmio:DShi";    monitor dsHi;
double dsHo;     assign dsHo      to "{coioc}:vfmio:DSho";    monitor dsHo;
double tbHi;     assign tbHi      to "{coioc}:vfmio:TBhi";    monitor tbHi;
double tbHo;     assign tbHo      to "{coioc}:vfmio:TBho";    monitor tbHo;
double tbAi;     assign tbAi      to "{coioc}:vfmio:TBai";    monitor tbAi;
double tbAo;     assign tbAo      to "{coioc}:vfmio:TBao";    monitor tbAo;
double vfmHi;    assign vfmHi     to "{coioc}:vfmio:VFMhi";   monitor vfmHi;
double vfmHo;    assign vfmHo     to "{coioc}:vfmio:VFMho";   monitor vfmHo;
double dtOfIn;   assign dtOfIn    to "{coioc}:vfmio:DTVofi";  monitor dtOfIn;
double dtOfOut;  assign dtOfOut   to "{coioc}:vfmio:DTVofo";  monitor dtOfOut;
double dtAnIn;   assign dtAnIn    to "{coioc}:vfmio:DTVani";  monitor dtAnIn;
double dtAnOut;  assign dtAnOut   to "{coioc}:vfmio:DTVano";  monitor dtAnOut;
double dtShIn;   assign dtShIn    to "{coioc}:vfmio:DTVshi";  monitor dtShIn;
double dtShOut;  assign dtShOut   to "{coioc}:vfmio:DTVsho";  monitor dtShOut;

double actMKys;  assign actMKys   to "21:C1:MK:YS:ActPos";    monitor actMKys;
double rqsMKys;  assign rqsMKys   to "21:C1:MK:YS:RqsPos";    monitor rqsMKys;
long   MKvAbort; assign MKvAbort  to "21:C1:MK:Av:Abort";     monitor MKvAbort;  /* val 1 */
long   MKRunPrg; assign MKRunPrg  to "21:C1:MK:Av:RunPrg";    monitor MKRunPrg;  /* 0-idle, 1-running */

double actDSyc;  assign actDSyc   to "21:D1:S1:YC:ActPos";    monitor actDSyc;
double rqsDSyc;  assign rqsDSyc   to "21:D1:S1:YC:RqsPos";    monitor rqsDSyc;
double actDSys;  assign actDSys   to "21:D1:S1:YS:ActPos";    monitor actDSys;
double rqsDSys;  assign rqsDSys   to "21:D1:S1:YS:RqsPos";    monitor rqsDSys;
double actDSxs;  assign actDSxs   to "21:D1:S1:XS:ActPos";    monitor actDSxs;
double rqsDSxs;  assign rqsDSxs   to "21:D1:S1:XS:RqsPos";    monitor rqsDSxs;
long   DSyAuto;  assign DSyAuto   to "21:D1:S1:Av:AutoStart"; monitor DSyAuto;    /* 0-Auto, 1-Man */
long   DSyStart; assign DSyStart  to "21:D1:S1:Av:Start";     monitor DSyStart;   /* val 1 */
long   DSyAbort; assign DSyAbort  to "21:D1:S1:Av:Abort";     monitor DSyAbort;   /* val 1 */
long  DSyRunPrg; assign DSyRunPrg to "21:D1:S1:Av:RunPrg";    monitor DSyRunPrg;  /* 0-idle, 1-running */
long   DSxAbort; assign DSxAbort  to "21:D1:S1:Ah:Abort";     monitor DSxAbort;   /* val 1 */
long  DSxRunPrg; assign DSxRunPrg to "21:D1:S1:Ah:RunPrg";    monitor DSxRunPrg;  /* 0-idle, 1-running */

double actKBvy;  assign actKBvy   to "21:D1:KB:VY:ActPos";    monitor actKBvy;
double rqsKBvy;  assign rqsKBvy   to "21:D1:KB:VY:RqsPos";    monitor rqsKBvy;
/* double actKBvp;  assign actKBvp   to "21:D1:KB:VP:ActPos";    monitor actKBvp;  */
/* double rqsKBvp;  assign rqsKBvp   to "21:D1:KB:VP:RqsPos";    monitor rqsKBvp;  */
long   VFMauto;  assign VFMauto   to "21:D1:KB:Vy:AutoStart"; monitor VFMauto;    /* 0-Auto, 1-Man */
long   VFMstart; assign VFMstart  to "21:D1:KB:Vy:Start";     monitor VFMstart;   /* val 1 */
long   VFMAbort; assign VFMAbort  to "21:D1:KB:Vy:Abort";     monitor VFMAbort;   /* val 1 */
long  VFMRunPrg; assign VFMRunPrg to "21:D1:KB:Vy:RunPrg";    monitor VFMRunPrg;  /* 0-idle, 1-running */

double actTBh;   assign actTBh    to "21:D1:TB:H:ActPos";     monitor actTBh;
double rqsTBh;   assign rqsTBh    to "21:D1:TB:H:RqsPos";     monitor rqsTBh;
double actTBa;   assign actTBa    to "21:D1:TB:A:ActPos";     monitor actTBa;
double rqsTBa;   assign rqsTBa    to "21:D1:TB:A:RqsPos";     monitor rqsTBa;
long   TBvAuto;  assign TBvAuto   to "21:D1:TB:Vr:AutoStart"; monitor TBvAuto;    /* 0-Auto, 1-Man */
long   TBvStart; assign TBvStart  to "21:D1:TB:Vr:Start";     monitor TBvStart;   /* val 1 */
long   TBvAbort; assign TBvAbort  to "21:D1:TB:Vr:Abort";     monitor TBvAbort;   /* val 1 */
long  TBvRunPrg; assign TBvRunPrg to "21:D1:TB:Vr:RunPrg";    monitor TBvRunPrg;  /* 0-idle, 1-running */

/* Detector PVs */

double DTvdsOff;  assign DTvdsOff   to "21:D1:DT:VDS:Offset";     monitor DTvdsOff;
double DTvdsAct;  assign DTvdsAct   to "21:D1:DT:VDS:ActPos";     monitor DTvdsAct;
double DTvdsRqs;  assign DTvdsRqs   to "21:D1:DT:VDS:RqsPos";     monitor DTvdsRqs;
double DTvusAct;  assign DTvusAct   to "21:D1:DT:VUS:ActPos";     monitor DTvusAct;
double DTvusRqs;  assign DTvusRqs   to "21:D1:DT:VUS:RqsPos";     monitor DTvusRqs;

double DTdAct;    assign DTdAct     to "21:D1:DT:Z0:ActPos";      monitor DTdAct;
double DTdRqs;    assign DTdRqs     to "21:D1:DT:Z0:RqsPos";      monitor DTdRqs;
double DThAct;    assign DThAct     to "21:D1:DT:H0:ActPos";      monitor DThAct;
double DThRqs;    assign DThRqs     to "21:D1:DT:H0:RqsPos";      monitor DThRqs;
double DTxAct;    assign DTxAct     to "21:D1:DT:XC:ActPos";      monitor DTxAct;
double DTxRqs;    assign DTxRqs     to "21:D1:DT:XC:RqsPos";      monitor DTxRqs;
double DTdlAct;   assign DTdlAct    to "21:D1:DT:DL:ActPos";      monitor DTdlAct;
double DTdlRqs;   assign DTdlRqs    to "21:D1:DT:DL:RqsPos";      monitor DTdlRqs;

double DTvCorAng; assign DTvCorAng  to "21:D1:DT:St:aV";          monitor DTvCorAng;
double DTvCorSh;  assign DTvCorSh   to "21:D1:DT:St:S";           monitor DTvCorSh;

long   lpCorrOff; assign lpCorrOff  to "21:D1:DT:Lp:mLink";       monitor lpCorrOff;   /* 0- corr OFF, 1-corr ON */
long   DTlpAuto;  assign DTlpAuto   to "21:D1:DT:Lp:AutoStart";   monitor DTlpAuto;    /* 0-Auto, 1-Man */
long   DTlpStart; assign DTlpStart  to "21:D1:DT:Lp:Start";       monitor DTlpStart;   /* val 1 */
long   DTlpAbort; assign DTlpAbort  to "21:D1:DT:Lp:Abort";       monitor DTlpAbort;   /* val 1 */
long  DTlpRunPrg; assign DTlpRunPrg to "21:D1:DT:Lp:RunPrg";      monitor DTlpRunPrg;  /* 0-idle, 1-running */

long   stCorrOff; assign stCorrOff  to "21:D1:DT:St:mLink";       monitor stCorrOff;   /* 0- corr OFF, 1-corr ON */
long   DTvAuto;   assign DTvAuto    to "21:D1:DT:St:AutoStart";   monitor DTvAuto;    /* 0-Auto, 1-Man */
long   DTvStart;  assign DTvStart   to "21:D1:DT:St:Start";       monitor DTvStart;   /* val 1 */
long   DTvAbort;  assign DTvAbort   to "21:D1:DT:St:Abort";       monitor DTvAbort;   /* val 1 */
long   DTvRunPrg; assign DTvRunPrg  to "21:D1:DT:St:RunPrg";      monitor DTvRunPrg;  /* 0-idle, 1-running */

string msgQ;
string msg[10];       assign msg[0]  to "{coioc}:vfmio:Msg9";
		      assign msg[1]  to "{coioc}:vfmio:Msg8";
                      assign msg[2]  to "{coioc}:vfmio:Msg7";
                      assign msg[3]  to "{coioc}:vfmio:Msg6";
                      assign msg[4]  to "{coioc}:vfmio:Msg5";
                      assign msg[5]  to "{coioc}:vfmio:Msg4";
                      assign msg[6]  to "{coioc}:vfmio:Msg3";
                      assign msg[7]  to "{coioc}:vfmio:Msg2";
                      assign msg[8]  to "{coioc}:vfmio:Msg1";
                      assign msg[9]  to "{coioc}:vfmio:Msg0";
evflag msg_f;
evflag movevfm_f;
evflag postmove_f;
evflag finished_f;
evflag fiundo_f;
