#define TIMEOUT 480
#define ENERGYMIN 5.0
#define ENERGYMAX 22.0
#define CHIMIN -4.0
#define CHIMAX 4.0
#define THETAMIN -9.9
#define THETAMAX 9.9
#define LANEMIN -19.0
#define LANEMAX 18.0
#define VFMENSWLO 5.5
#define VFMENSWHI 22.0
#define VFMENSWMD 10.5
#define HFMENSWLO 5.5
#define HFMENSWHI 22.0
#define HFMENSWMD 10.5
#define VFMLNMIN -16.0
#define VFMLNPDGL 6.0
#define VFMLNGLPT -3.0
#define VFMLNMAX  20.0
#define HFMLNMIN -19.0
#define HFMLNPDGL 0.1
#define HFMLNGLPT -10
#define HFMLNMAX  13.0
#define DELAYLO 240
#define DELAYHI 360

%%TS_STAMP tmc;

char   time_str[80];

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

int startBtn;    assign startBtn  to "{coioc}:mono:Start";    monitor startBtn;   evflag start_f;   sync startBtn start_f;
int abortBtn;    assign abortBtn  to "{coioc}:mono:Abort";    monitor abortBtn;   evflag abort_f;   sync abortBtn abort_f;
int cleanBtn;    assign cleanBtn  to "{coioc}:mono:Clean";    monitor cleanBtn;   evflag clean_f;   sync cleanBtn clean_f;
int undoBtn;     assign undoBtn   to "{coioc}:mono:Undo";     monitor undoBtn;    evflag undo_f;    sync undoBtn  undo_f;

/* CenterBeam proc PVs */
int abortCentr;  assign abortCentr to "{coioc}:mono:AbortCentr"; monitor abortCentr;
int centrWrkng;  assign centrWrkng to "{coioc}:mono:CentrWrkng"; monitor centrWrkng;
int tbMiSwBtn;   assign tbMiSwBtn  to "{coioc}:mono:TBMIsw";     monitor tbMiSwBtn;
int imgHCentr;   assign imgHCentr  to "{coioc}:mono:ImgHCentr";  monitor imgHCentr;
int imgVCentr;   assign imgVCentr  to "{coioc}:mono:ImgVCentr";  monitor imgVCentr;
/*---*/

int chEnWrkng;   assign chEnWrkng to "{coioc}:mono:ChEnWrkng";  monitor chEnWrkng;
int thWrkng;     assign thWrkng   to "{coioc}:mono:ThWrkng";  monitor thWrkng;
int idEnaBtn;    assign idEnaBtn  to "{coioc}:mono:IDena";    monitor idEnaBtn;
int chiEnaBtn;   assign chiEnaBtn to "{coioc}:mono:CHIena";   monitor chiEnaBtn;
int vfmEnaBtn;   assign vfmEnaBtn to "{coioc}:mono:VFMena";   monitor vfmEnaBtn;
int hfmEnaBtn;   assign hfmEnaBtn to "{coioc}:mono:HFMena";   monitor hfmEnaBtn;
int piEnaBtn;    assign piEnaBtn  to "{coioc}:mono:PIena";    monitor piEnaBtn;
int thEnaBtn;    assign thEnaBtn  to "{coioc}:mono:THena";    monitor thEnaBtn;

double newEn;    assign newEn     to "{coioc}:mono:RqsEn";    monitor newEn;
double hrmSwEn;  assign hrmSwEn   to "{coioc}:mono:HrmSwEn";  monitor hrmSwEn;
double idOff1;   assign idOff1    to "{coioc}:mono:IDoff1";   monitor idOff1;
double idOff2;   assign idOff2    to "{coioc}:mono:IDoff2";   monitor idOff2;
double chiSca;   assign chiSca    to "{coioc}:mono:ChiSca";   monitor chiSca;
double chiOff;   assign chiOff    to "{coioc}:mono:ChiOff";   monitor chiOff;
double vfmPd;    assign vfmPd     to "{coioc}:mono:VFMPd";    monitor vfmPd;
double vfmGl;    assign vfmGl     to "{coioc}:mono:VFMGl";    monitor vfmGl;
double vfmPt;    assign vfmPt     to "{coioc}:mono:VFMPt";    monitor vfmPt;
double hfmPd;    assign hfmPd     to "{coioc}:mono:HFMPd";    monitor hfmPd;
double hfmGl;    assign hfmGl     to "{coioc}:mono:HFMGl";    monitor hfmGl;
double hfmPt;    assign hfmPt     to "{coioc}:mono:HFMPt";    monitor hfmPt;
double scWdth;   assign scWdth    to "{coioc}:mono:ScWdth";   monitor scWdth;
double scStep;   assign scStep    to "{coioc}:mono:ScStep";   monitor scStep;
double thStep;   assign thStep    to "{coioc}:mono:ThStep";   monitor thStep;

double detCnts;  assign detCnts   to "{detnm}_calc5.VAL";     monitor detCnts;  /* or "21:D1:2:userCalc2.VAL" */
int    detMode;  assign detMode   to "{detnm}.CONT";          monitor detMode;  /* 0-OneShot, 1-AutoCount */

string piScanNm;     assign piScanNm      to "{scnm}.NAME";   monitor piScanNm;  /* "21:C1:scan2.NAME" */
int    piScanBusy;   assign piScanBusy    to "{scnm}.BUSY";   monitor piScanBusy;
int    piScanStart;  assign piScanStart   to "{scnm}.EXSC";  /* monitor piScanStart; */
int    piScanAbort;  assign piScanAbort   to "21:D1:AbortScans.PROC";  /* monitor piScanAbort; */
int    piScanCmnd;   assign piScanCmnd    to "{scnm}.CMND";  /* monitor piScanCmnd; */
int    piScanLinr;   assign piScanLinr    to "{scnm}.P1SM";  /* linear mode */
int    piScanAbslt;  assign piScanAbslt   to "{scnm}.P1AR";  /* absolute mode */
int    piScanPeakP;  assign piScanPeakP   to "{scnm}.PASM";  /* peak position after */
double piScanCntr;   assign piScanCntr    to "{scnm}.P1CP";  /* monitor piScanCntr; */
double piScanWdth;   assign piScanWdth    to "{scnm}.P1WD";  /* monitor piScanWdth; */
double piScanStep;   assign piScanStep    to "{scnm}.P1SI";  /* monitor piScanWdth; */
string piScanDet;    assign piScanDet     to "{scnm}.D01PV";
float  piScanPosStl; assign piScanPosStl  to "{scnm}.PDLY";
float  piScanDetStl; assign piScanDetStl  to "{scnm}.DDLY";
float  piScanUpdt;   assign piScanUpdt    to "{scnm}.ATIME";
string piScanPosRd;  assign piScanPosRd   to "{scnm}.R1PV";
string piScanPosDr;  assign piScanPosDr   to "{scnm}.P1PV";
string piScanDtTrg;  assign piScanDtTrg   to "{scnm}.T1PV";
string piScanAfter;  assign piScanAfter   to "{scnm}.ASPV";

/* string joerChNm; */

/* Energy assembly*/
double actEn;     assign actEn     to "21:C1:MO:E:ActPos";    monitor actEn;
double rqsPosEn;  assign rqsPosEn  to "21:C1:MO:E:RqsPos";    monitor rqsPosEn;
long   EnAbort;   assign EnAbort   to "21:C1:MO:En:Abort";    monitor EnAbort;
long   EnKill;    assign EnKill    to "21:C1:MO:En:Kill";     monitor EnKill;
/*long   EnInPos;   assign EnInPos   to "21:C1:MO:En:InPos";    monitor EnInPos;  */
long   EnRunPrg;  assign EnRunPrg  to "21:C1:MO:En:RunPrg";   monitor EnRunPrg;

/* Undulator PVs */
double actEnID;   assign actEnID    to "ID21us:Energy.VAL";      monitor actEnID;
double rqsEnID;   assign rqsEnID    to "ID21us:EnergySet.VAL";   monitor rqsEnID;
double rqsHrmID;  assign rqsHrmID   to "ID21us:HarmonicValue";   monitor rqsHrmID;
int    IDStart;   assign IDStart    to "ID21us:Start.VAL";       monitor IDStart;
int    IDStop;    assign IDStop     to "ID21us:Stop.VAL";        monitor IDStop;
int    IDStatus;  assign IDStatus   to "ID21us:Busy.VAL";        monitor IDStatus;

/* CHI assembly */
double actChi;    assign actChi     to "21:C1:MO:R2:ActPos";   monitor actChi;
double rqsPosChi; assign rqsPosChi  to "21:C1:MO:R2:RqsPos";   monitor rqsPosChi;
long   ChiAbort;  assign ChiAbort   to "21:C1:MO:Tn:Abort";    monitor ChiAbort;
long   ChiKill;   assign ChiKill    to "21:C1:MO:Tn:Kill";     monitor ChiKill;
/*long   ChiInPos;  assign ChiInPos   to "21:C1:MO:Tn:InPos";    monitor ChiInPos;  */
long   ChiRunPrg; assign ChiRunPrg  to "21:C1:MO:Tn:RunPrg";   monitor ChiRunPrg;

/* Pitch PVs */
double actPitch;    assign actPitch      to "21:C1:MO:P2:ActPos";   monitor actPitch;
double rqsPitch;    assign rqsPitch      to "21:C1:MO:P2:RqsPos";   monitor rqsPitch;
/* PitchAbort and PitchKill are the same as CHI has !!!! */

/* Theta PVs  c3ioc:rmm01:ana01:ao01.VAL */
double curTheta;  assign curTheta   to "c3ioc:rmm01:ana01:ao01.VAL";   monitor curTheta;

/* Mirror PVs */
double actLnVFM;  assign actLnVFM   to "21:D1:KB:VL:ActPos";   monitor actLnVFM;
double rqsLnVFM;  assign rqsLnVFM   to "21:D1:KB:VL:RqsPos";   monitor rqsLnVFM;
long   VFMAbort;  assign VFMAbort   to "21:D1:KB:Vx:Abort";    monitor VFMAbort;
long   VFMKill;   assign VFMKill    to "21:D1:KB:Vx:Kill";     monitor VFMKill;
long   VFMRunPrg; assign VFMRunPrg  to "21:D1:KB:Vx:RunPrg";   monitor VFMRunPrg;

double actLnHFM;  assign actLnHFM   to "21:D1:KB:HL:ActPos";   monitor actLnHFM;
double rqsLnHFM;  assign rqsLnHFM   to "21:D1:KB:HL:RqsPos";   monitor rqsLnHFM;
long   HFMAbort;  assign HFMAbort   to "21:D1:KB:Hy:Abort";    monitor HFMAbort;
long   HFMKill;   assign HFMKill    to "21:D1:KB:Hy:Kill";     monitor HFMKill;
long   HFMRunPrg; assign HFMRunPrg  to "21:D1:KB:Hy:RunPrg";   monitor HFMRunPrg;

string msgQ;
string msg[10];       assign msg[0]  to "{coioc}:mono:Msg9";
		      assign msg[1]  to "{coioc}:mono:Msg8";
                      assign msg[2]  to "{coioc}:mono:Msg7";
                      assign msg[3]  to "{coioc}:mono:Msg6";
                      assign msg[4]  to "{coioc}:mono:Msg5";
                      assign msg[5]  to "{coioc}:mono:Msg4";
                      assign msg[6]  to "{coioc}:mono:Msg3";
                      assign msg[7]  to "{coioc}:mono:Msg2";
                      assign msg[8]  to "{coioc}:mono:Msg1";
                      assign msg[9]  to "{coioc}:mono:Msg0";
evflag msg_f;
evflag moveen_f;
evflag movechi_f;
evflag moveid_f;
evflag movevfm_f;
evflag movehfm_f;
evflag optpi_f;
evflag optth_f;
evflag finished;
