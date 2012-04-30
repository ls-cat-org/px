--
-- Support for epics process variables
--
--
#DROP SCHEMA epics CASCADE;
CREATE SCHEMA epics;
GRANT USAGE ON SCHEMA epics TO PUBLIC;


CREATE TABLE epics._historyPvNames (
--
-- names of pvs in history table
	hpnKey serial primary key,		-- table key
	hpnName text NOT NULL unique		-- name of pv
);
ALTER TABLE epics._historyPvNames OWNER TO lsadmin;

CREATE TABLE epics._historyPvs (
	hpKey serial primary key,			-- table key
	hpN bigint NOT NULL,				-- must be associated with a pv
	hpValue text,					-- the value
	hpTS timestamp with time zone default now()	-- when we were created
);
ALTER TABLE epics._historyPvs OWNER TO lsadmin;

CREATE INDEX _historyPvsPvIndex ON epics._historyPvs (hpN);
CREATE INDEX _historyPvsTSIndex ON epics._historyPvs (hpTS);


CREATE TABLE epics._pvmonitors (
--
-- Main PV table
--
	pvmKey serial primary key,			-- table key
	pvmName text NOT NULL UNIQUE,				-- PV name
	pvmPrec  int default NULL,			-- give us this many decimal places
	pvmDTime numeric default 0,			-- update every dTime seconds even if the change is less than Delta
	pvmDelta numeric default NULL,			-- don't update until change of this amount is seen
	pvmValue text default NULL,			-- value of the pv
	pvmValueN numeric default NULL,			-- value of the pv
	pvmTs timestamp with time zone default now(),	-- last change
	pvmMonitorIndex int NOT NULL UNIQUE,		-- Used in camonotor routine to store index of pv: ASSUMES ONLY ONE camonitor
	pvmHistoryKey bigint NOT NULL UNIQUE		-- pointer to this pv's name in the history table (should it really be stored in pvmonitors too?)
		references epics._historyPvNames (hpnKey)
);
ALTER TABLE epics._pvmonitors OWNER TO lsadmin;

CREATE TABLE epics._actionList (
--
-- List of function names allowed as PV actions
-- This is used to prevent typos in epics._pvactions from bringing down the monitoring system
--
	alKey serial primary key,
	alAction     text NOT NULL UNIQUE
);
ALTER TABLE epics._actionList OWNER TO lsadmin;

INSERT INTO epics._actionList (alAction) VALUES ('epics._openSesame');


CREATE TABLE epics._pvactions (
--
-- Table of "actions" to trigger when a PV value comes in.
-- At least 1 of IsEqual, IsGT, or IsLT should be defined to trigger the action
-- and likewise for the reset functions
-- Use the Active flag to disable the action if needed
--

	pvaKey serial primary key,			-- table key
	pvaPv  bigint NOT NULL				-- pointer to pvmonitor table
		references epics._pvmonitors (pvmKey) ON UPDATE CASCADE,
	pvaActive         boolean default true,		-- Flag to activate/deactivate this action entirely
	pvaTriggered boolean default false,		-- True when we've already triggered this action
	pvaTrigIsEqual    numeric default NULL,		-- Exact Value of PV to trigger action
	pvaTrigIsGT       numeric default NULL,		-- Value GT this triggers action
	pvaTrigIsLT       numeric default NULL,		-- Value LT this triggers action
	pvaTrigResetEqual numeric default NULL,		-- Exact value of PV to reset trigger
	pvaTrigResetGT    numeric default NULL,		-- Value GT this triggers reset
	pvaTrigResetLT    numeric default NULL,		-- Value LT this triggers reset
	pvaAction         text NOT NULL			-- Function name to call
		references epics._actionList (alAction),
	pvaLastTrigger    timestamp with time zone default NULL,	-- time of last trigger
	pvaLastReset      timestamp with time zone default NULL		-- time of last reset
);
ALTER TABLE epics._pvactions OWNER TO lsadmin;

      
INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:STA_D_BEAM_READY'),
	1, 1, 'epics._openSesame');

INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PB:21ID:STA_D_BEAM_READY'),
	1, 1, 'epics._openSesame');

INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:STA_E_BEAM_READY'),
	1, 1, 'epics._openSesame');

INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PB:21ID:STA_E_BEAM_READY'),
	1, 1, 'epics._openSesame');

INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:STA_F_BEAM_READY'),
	1, 1, 'epics._openSesame');

INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PB:21ID:STA_F_BEAM_READY'),
	1, 1, 'epics._openSesame');

INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:STA_G_BEAM_READY'),
	1, 1, 'epics._openSesame');

INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PB:21ID:STA_G_BEAM_READY'),
	1, 1, 'epics._openSesame');


INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:IA_STA_F_DR2_CLOS'),
	0, 1, 'px._moveDetectorOut');

INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:OA_STA_F_VOICE_1'),
	0, 1, 'px._moveDetectorIn');

INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='21:F1:DT:St:InPos'),
	1, 0, 'epics._maybeKillMotor');


INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:IA_STA_FG_G_DR1_CLOS'),
	0, 1, 'px._moveDetectorOut');

INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:OA_STA_FG_G_VOICE_1'),
	0, 1, 'px._moveDetectorIn');

INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='21:G1:DT:St:InPos'),
	1, 0, 'epics._maybeKillMotor');


INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:IA_STA_D_DR2_CLOS'),
	0, 1, 'px._moveDetectorOut');

INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:OA_STA_D_VOICE_1'),
	0, 1, 'px._moveDetectorIn');

INSERT INTO epics._pvactions (pvaPv, pvaTrigIsEqual, pvaTrigResetEqual, pvaAction) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='21:D1:DT:St:InPos'),
	1, 0, 'epics._maybeKillMotor');



CREATE OR REPLACE FUNCTION epics._pvmUpdateTF2() RETURNS TRIGGER AS $$
  DECLARE
    al record;	-- action list for this PV
  BEGIN
    FOR al IN SELECT * FROM epics._pvactions WHERE pvaPv = NEW.pvmKey LOOP
      IF al.pvaActive and not al.pvaTriggered and
        (coalesce(al.pvaTrigIsEqual=new.pvmValueN,false) or
         coalesce(al.pvaTrigIsGT<new.pvmValueN,false) or
         coalesce(al.pvaTrigIsLT>new.pvmValueN,false)) THEN
        UPDATE epics._pvactions SET pvaLastTrigger=now(), pvaTriggered=true WHERE pvaKey=al.pvaKey;
        EXECUTE 'SELECT ' || al.pvaAction || '(' || al.pvaPv || ',' || new.pvmValueN || ')';
      END IF;
      IF al.pvaActive and al.pvaTriggered and
         (coalesce(al.pvaTrigResetEqual=new.pvmValueN,false) or
          coalesce(al.pvaTrigResetGT<new.pvmValueN,false) or
          coalesce(al.pvaTrigResetLT>new.pvmValueN,false)) THEN
        UPDATE epics._pvactions set pvaLastReset=now(), pvaTriggered=false where pvaKey=al.pvaKey;
      END IF;
    END LOOP;
    return NULL;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION epics._pvmUpdateTF2() OWNER TO lsadmin;
CREATE TRIGGER pvmonitorUpdateTrigger2 AFTER UPDATE ON epics._pvmonitors FOR EACH ROW EXECUTE PROCEDURE epics._pvmUpdateTF2();


CREATE TABLE epics._shutterOpenTable (
	soKey serial primary key,
	soBrA bigint NOT NULL			-- pointer to chain A Beam Ready PV
		references epics._pvmonitors (pvmKey) ON UPDATE CASCADE,
	soBrB bigint NOT NULL			-- pointer to chain B Beam Ready PV
		references epics._pvmonitors (pvmKey) ON UPDATE CASCADE,
	soSO  bigint NOT NULL			-- pointer to shutter open PV
		references epics._pvmonitors (pvmKey) ON UPDATE CASCADE
);
ALTER TABLE epics._shutterOpenTable OWNER TO lsadmin;

INSERT INTO epics._shutterOpenTable (soBrA, soBrB, soSo) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:STA_D_BEAM_READY'),
	(select pvmkey from epics._pvmonitors where pvmname='PB:21ID:STA_D_BEAM_READY'),
	(select pvmkey from epics._pvmonitors where pvmname='PC:21ID:Rem_DshtrOpen'));

INSERT INTO epics._shutterOpenTable (soBrA, soBrB, soSo) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:STA_E_BEAM_READY'),
	(select pvmkey from epics._pvmonitors where pvmname='PB:21ID:STA_E_BEAM_READY'),
	(select pvmkey from epics._pvmonitors where pvmname='PC:21ID:Rem_EshtrOpen'));

INSERT INTO epics._shutterOpenTable (soBrA, soBrB, soSo) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:STA_F_BEAM_READY'),
	(select pvmkey from epics._pvmonitors where pvmname='PB:21ID:STA_F_BEAM_READY'),
	(select pvmkey from epics._pvmonitors where pvmname='PC:21ID:Rem_FshtrOpen'));

INSERT INTO epics._shutterOpenTable (soBrA, soBrB, soSo) VALUES (
	(select pvmkey from epics._pvmonitors where pvmname='PA:21ID:STA_G_BEAM_READY'),
	(select pvmkey from epics._pvmonitors where pvmname='PB:21ID:STA_G_BEAM_READY'),
	(select pvmkey from epics._pvmonitors where pvmname='PC:21ID:Rem_GshtrOpen'));


CREATE OR REPLACE FUNCTION epics._openSesame( pvmk bigint, value numeric) RETURNS void AS $$
  DECLARE
    sot record;	-- shutter open table record
  BEGIN
    SELECT INTO sot *
      FROM epics._shutterOpenTable  WHERE sobra=pvmk or sobrb=pvmk;

    IF FOUND THEN
      PERFORM 1 FROM epics._pvmonitors as p1, epics._pvmonitors as p2 WHERE p1.pvmKey=sot.sobra and p1.pvmValueN=1 and p2.pvmKey=sot.sobrb and p2.pvmValueN=1;
      IF FOUND THEN
        PERFORM epics.pushputqueue( sot.soso, '1', now()+'10 seconds');
      END IF;
    END IF;    
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION epics._openSesame( bigint, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION epics._maybeKillMotor( pvmk bigint, value numeric) RETURNS void AS $$
  --
  -- action function for when a motor is "in position": triggered by RunPrg going to 0 (reset by going to 1)
  --
  DECLARE
    motion record;	-- the entire epics._motions record for this motor
  BEGIN
    -- get the epics._motions record: TODO figure out if this could ever return more than one row and what to do then.
    SELECT INTO  motion * FROM epics._motions WHERE mRunPrg=pvmk and mweareincontrol limit 1;
    IF FOUND THEN
      UPDATE epics._motions set mweareincontrol=false WHERE mkey=motion.mkey;
      IF motion.mKillPrefs = 'killafter' or (motion.mKillPrefs = 'restore' and motion.mPrevAmpEna=false) THEN
        PERFORM epics.pushputqueue( motion.mKill, 1, now()+'10 seconds');
      END IF;
    END IF;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION epics._maybeKillMotor( bigint, numeric) OWNER TO lsadmin;


CREATE TABLE epics._motionkillprefs (
-- Preferences for kill/abort of motors afterwards
	mkp text primary key
);
ALTER TABLE epics._motionkillprefs OWNER TO lsadmin;

INSERT INTO epics._motionkillprefs (mkp) VALUES ( 'killafter');
INSERT INTO epics._motionkillprefs (mkp) VALUES ( 'leaveon');
INSERT INTO epics._motionkillprefs (mkp) VALUES ( 'restore');

CREATE TABLE epics._motions (
	mKey serial primary key,		-- table key
        mRequestTS timestamp with time zone default now(),
	mMotorPvName text NOT NULL unique,		-- PV of this axis
	mAssemblyPvName text NOT NULL,		-- for abort, kill, etc
	mPrec  int default 0,			-- use this many decimal places
	mDelta numeric default 0,		-- notify us of changes as small as this
	
	mRqsPos bigint default NULL		-- requested position
		references epics._pvmonitors (pvmKey),
	mActPos bigint default NULL		-- actual position
		references epics._pvmonitors (pvmKey),
	mInPos  bigint default NULL		-- in-position flag
		references epics._pvmonitors (pvmKey),
	mLl     bigint default NULL		-- lower limit
		references epics._pvmonitors (pvmKey),
	mHl     bigint default NULL		-- high limit
		references epics._pvmonitors (pvmKey),
	mLlHit  bigint default NULL		-- lower limit reached
		references epics._pvmonitors (pvmKey),
	mHlHit  bigint default NULL		-- high limit reached
		references epics._pvmonitors (pvmKey),
	mAbort  bigint default NULL		-- abort motion
		references epics._pvmonitors (pvmKey),
	mKill   bigint default NULL		-- kill motion
		references epics._pvmonitors (pvmKey),
	mAmpEna bigint default NULL		-- amplifier enabled
		references epics._pvmonitors (pvmKey),

        mManMode bigint default NULL            -- manual mode
                references epics._pvmonitors (pvmKey),
	mRunPrg bigint default NULL		-- run program
		references epics._pvmonitors (pvmKey),
	mKillPrefs text				-- how do we want to leave this after motion is done?
		references epics._motionkillprefs (mkp),
	mPrevAmpEna boolean default NULL,	-- previous amplifier enabled (for mkillprefs = 'restore')
	mWeAreInControl boolean default False	-- Indicates we initialed the motion and will reset kill/abort
);
ALTER TABLE epics._motions OWNER TO lsadmin;

CREATE OR REPLACE VIEW epics.motions ( mkey, mMotorPvName, mAssemblyPvName, mPrec, mDelta, mRqsPos, mActPos, mInPos, mLl, mHl, mLlHit, mHlHit, mAbort, mKill, mAmpEna, mManMode, mKillPrefs, mPrevAmpEna, mWeAreInControl, mRunPrg, mRequestTS) AS
        SELECT mKey, mMotorPvName, mAssemblyPvName, mPrec, mDelta, 
                mRqsPosPv.pvmValueN   as mRqsPos,
                mActPosPv.pvmValueN   as mActPos,
                mInPosPv.pvmValueN    as mInPos,
                mLlPv.pvmValueN       as mLl,
                mHlPv.pvmValueN       as mHl,
                mLlHitPv.pvmValueN    as mLlHit,
                mHlHitPv.pvmValueN    as mHlHit,
                mAbortPv.pvmValueN    as mAbort,
                mKillPv.pvmValueN     as mKill,
                mAmpEnaPv.pvmValueN   as mAmpEna,
                mManModePv.pvmValueN  as mManMode,
                mKillPrefs,
                mPrevAmpEna,
                mWeAreInControl,
                mRunPrgPv.pvmValueN as mRunPrg,
                mRequestTS
                FROM epics._motions AS m
                LEFT JOIN epics._pvmonitors AS mRqsPosPv  ON mRqsPosPv.pvmKey = m.mRqsPos
                LEFT JOIN epics._pvmonitors AS mActPosPv  ON mActPosPv.pvmKey = m.mActPos
                LEFT JOIN epics._pvmonitors AS mInPosPv   ON mInPosPv.pvmKey  = m.mInPos
                LEFT JOIN epics._pvmonitors AS mLlPv      ON mLlPv.pvmKey     = m.mLl
                LEFT JOIN epics._pvmonitors AS mHlPv      ON mHlPv.pvmKey     = m.mHl
                LEFT JOIN epics._pvmonitors AS mLlHitPv   ON mLlHitPv.pvmKey  = m.mLlHit
                LEFT JOIN epics._pvmonitors AS mHlHitPv   ON mHlHitPv.pvmKey  = m.mHlHit
                LEFT JOIN epics._pvmonitors AS mAbortPv   ON mAbortPv.pvmKey  = m.mAbort
                LEFT JOIN epics._pvmonitors AS mKillPv    ON mKillPv.pvmKey   = m.mKill
                LEFT JOIN epics._pvmonitors AS mAmpEnaPv  ON mAmpEnaPv.pvmKey = m.mAmpEna
                LEFT JOIN epics._pvmonitors AS mManModePv ON mManModePv.pvmKey = m.mManMode
                LEFT JOIN epics._pvmonitors AS mRunPrgPv  ON mRunPrgPv.pvmKey = m.mRunPrg;

ALTER TABLE epics.motions OWNER TO lsadmin;
GRANT SELECT ON epics.motions TO PUBLIC;

CREATE TABLE epics.errors (
       --
       -- error messages generated while servicing pvs
       --
       eKey serial primary key,
       ets timestamp with time zone not null default now(),
       epvn text default null,
       emsg text not null
);
create index error_idx on epics.errors (epvn);
ALTER TABLE epics.errors OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION epics.updatePvmVar( pv text) returns void AS $$
  BEGIN
    UPDATE epics._pvmonitors SET pvmValue=epics.caget( pvmName) WHERE pvmName=pv;
    UPDATE epics._pvmonitors SET pvmValueN=pvmValue::numeric WHERE pvmName=pv;
  END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER;
ALTER FUNCTION epics.updatePvmVar( text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION epics.updatePvmVars( pv text) returns void as $$
  DECLARE
    m record;
  BEGIN 
    SELECT * INTO m FROM epics._motions WHERE mMotorPvName = pv;
    IF NOT FOUND THEN
      RETURN;
    END IF;
    UPDATE epics._pvmonitors SET pvmValue=epics.caget(pvmName) WHERE pvmKey=m.mRqsPos;
    UPDATE epics._pvmonitors SET pvmValue=epics.caget(pvmName) WHERE pvmKey=m.mActPos;
    UPDATE epics._pvmonitors SET pvmValue=epics.caget(pvmName) WHERE pvmKey=m.mInPos;
    UPDATE epics._pvmonitors SET pvmValue=epics.caget(pvmName) WHERE pvmKey=m.mLl;
    UPDATE epics._pvmonitors SET pvmValue=epics.caget(pvmName) WHERE pvmKey=m.mLl;
    UPDATE epics._pvmonitors SET pvmValue=epics.caget(pvmName) WHERE pvmKey=m.mHl;
    UPDATE epics._pvmonitors SET pvmValue=epics.caget(pvmName) WHERE pvmKey=m.mLlHit;
    UPDATE epics._pvmonitors SET pvmValue=epics.caget(pvmName) WHERE pvmKey=m.mHlHit;
    UPDATE epics._pvmonitors SET pvmValue=epics.caget(pvmName) WHERE pvmKey=m.mAmpEna;
    UPDATE epics._pvmonitors SET pvmValue=epics.caget(pvmName) WHERE pvmKey=m.mManMode;
    UPDATE epics._pvmonitors SET pvmValue=epics.caget(pvmName) WHERE pvmKey=m.mRunPrg;
    return;
  END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER;
ALTER FUNCTION epics.updatePvmVars( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION epics.moveit( pvname text, reqpos numeric) returns boolean AS $$
  --
  -- Return value: FALSE  check error table
  --               TRUE   Command attempted
  --
  DECLARE
    mrec   record;	-- motions record
    usmrec record;	-- Corresponding _motions record
  BEGIN
    -- Update epics variables
    PERFORM epics.updatePvmVars( pvname);

    SELECT INTO mrec * FROM epics.motions WHERE mmotorpvname=pvname;
    IF NOT FOUND THEN
      --
      -- Perhaps we should allow the case where the PV is not in "motions" but is legally changable in "_pvmonitors"
      -- Wait 'til we need it
      INSERT INTO epics.errors (epvn, emsg) VALUES ( pvname,  'PV name "'||pvname||'" Not found');
      return false;
    END IF;

    -- Don't move nothing until we need to
    --
    IF (mrec.mrunprg=0) and abs(mrec.mactpos-reqpos)<=10^(-mrec.mprec) THEN
      return true;
    END IF;

    --
    -- Check that the motor is in automatic mode
    --
    IF mrec.mmanmode != 0 THEN
      INSERT INTO epics.errors (epvn, emsg) VALUES ( pvname,  'PV '||pvname||' is in manual mode: I cannot move it.');
      return false;
    END IF;

    --
    -- Check Soft Limits
    --
    IF mrec.mll = mrec.mhl THEN
      INSERT INTO epics.errors (epvn, emsg) VALUES ( pvname,  'The high and low soft limits for motor '||pvname||' are both '||mrec.mll::text||'.  Please contact beamline staff.');
      return false;
    END IF;      

    IF mrec.mll > reqpos THEN
      INSERT INTO epics.errors (epvn, emsg) VALUES ( pvname,  'Requested postion for "'||pvname||'" of '||reqpos::text||' is less than lower limit of '|| mrec.mll::text);
      return false;
    END IF;

    IF mrec.mhl < reqpos THEN
      INSERT INTO epics.errors (epvn, emsg) VALUES ( pvname,  'Requested postion for "'||pvname||'" of '||reqpos::text||' is greater than upper limit of '|| mrec.mhl::text);
      return false;
    END IF;

    --
    -- Check Hard Limits
    --
    IF mrec.mactpos > reqpos and mrec.mllhit != 0 THEN
      INSERT INTO epics.errors (epvn, emsg) VALUES ( pvname,  'Requested postion for "'||pvname||'" of '||reqpos::text||' is not allowed as the lower hard limit has already been reached');
      return false;
    END IF;

    IF mrec.mactpos < reqpos and mrec.mhlhit != 0 THEN
      INSERT INTO epics.errors (epvn, emsg) VALUES ( pvname,  'Requested postion for "'||pvname||'" of '||reqpos::text||' is not allowed as the upper hard limit has already been reached');
      return false;
    END IF;


    -- Get the pvnames for the various PVs associated with this motion
    --
    SELECT INTO usmrec * FROM epics._motions WHERE _motions.mkey=mrec.mkey;
    --
    -- Save the current value ampena (amp enable)
    UPDATE epics._motions SET mPrevAmpEna= (mrec.mampena != 0), mWeAreInControl=true WHERE mkey=usmrec.mkey;
    --
    -- If the motor is currently moving, stop it
    -- If the motor is off, start it.
    -- The same command does it all.
    --
    --    PERFORM epics.pushputqueue( usmrec.mabort, 1);
    PERFORM epics.caput( pvmName, 1::text) FROM epics._pvmonitors WHERE pvmKey=usmrec.mabort::bigint;

    --
    -- Send the motor on its way
    --
    --    PERFORM epics.pushputqueue( usmrec.mrqspos::int, reqpos);
    PERFORM epics.caput( pvmName, reqpos::text) FROM epics._pvmonitors WHERE pvmKey=usmrec.mrqspos::bigint;
    UPDATE epics._motions SET mrequestts = now() WHERE mkey=mrec.mkey;
    return true;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION epics.moveit( text, numeric) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION epics.position( pv text) returns numeric as $$
  DECLARE
    rtn numeric;
    tmp text;
  BEGIN
    SELECT INTO tmp epics._caget( pvmMonitorIndex) FROM epics._pvmonitors WHERE pvmKey IN (SELECT mActPos FROM epics._motions WHERE mMotorPvName=$1 LIMIT 1);
    IF tmp = 'None' THEN
      rtn := '99999.99999';
    ELSE
      SELECT INTO rtn tmp::numeric;
      IF abs(rtn) < 1e-20 THEN
        rtn = 0;
      END IF;
      PERFORM epics.updatePvmVars( pv);
    END IF;
    return rtn;
  END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER;
ALTER FUNCTION epics.position( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION epics.isthere( pv text) returns boolean as $$
  DECLARE
    rtn boolean;
    rqspos numeric;
  BEGIN
    SELECT epics.caget( pvmName)::numeric INTO rqspos FROM epics._pvmonitors WHERE pvmKey IN (SELECT mRqsPos FROM epics._motions WHERE mMotorPvName=$1 LIMIT 1);
    SELECT epics.isstopped( pv) and abs(epics.position( pv) - rqspos) <= 10^(-mPrec) INTO rtn FROM epics._motions WHERE mMotorPvName=$1 LIMIT 1;
    return rtn;
  END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER;
ALTER FUNCTION epics.isthere( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION epics.isthere( pv text, pos numeric) returns boolean as $$
  DECLARE
    rtn boolean;
    rqspos numeric;
  BEGIN
    SELECT epics.caget( pvmName)::numeric INTO rqspos FROM epics._pvmonitors WHERE pvmKey IN (SELECT mRqsPos FROM epics._motions WHERE mMotorPvName=$1 LIMIT 1);
    SELECT epics.isstopped( pv) and abs(epics.position( pv) - pos) <= 10^(-mPrec) INTO rtn FROM epics._motions WHERE mMotorPvName=$1 LIMIT 1;
    return rtn;
  END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER;
ALTER FUNCTION epics.isthere( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION epics.isstopped( pv text) returns boolean as $$
  DECLARE
    runprg boolean;
    ampena boolean;
    rtn boolean;
    runprgkey bigint;
    ampenakey bigint;
    requestts timestamp with time zone;
  BEGIN
    PERFORM epics.updatePvmVars( pv);

    SELECT mRunPrg,mAmpEna,mRequestTS INTO runprgkey,ampenakey,requestts FROM epics._motions WHERE mMotorPvName=pv;

    --
    -- If the last request was too recent then assume we haven't started to move yet
    --
    IF now() - requestts < '1.1 seconds'::interval THEN
      return false;
    END IF;

    SELECT (epics.caget( pvmName)::text like '%1%') INTO runprg FROM epics._pvmonitors WHERE pvmKey=runprgkey;
    SELECT (epics.caget( pvmName)::text like '%1%') INTO ampena FROM epics._pvmonitors WHERE pvmKey=ampenakey;

    rtn := not ampena or not runprg;
    return rtn;
  END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER;
ALTER FUNCTION epics.isstopped( text) OWNER TO lsadmin;



CREATE TABLE epics._mfields (
-- pv field names to match pvmonitor entries with columns in _motions
	mf text primary key,		-- name of the field or rest of PV name
	mc text unique NOT NULL,	-- name of column in _motions
	mfMorA boolean,			-- True if motor field, False if assembly field
        mfUsePrec boolean,		-- Flag to use precision field or use zero
	mfUseDelta boolean		-- Flag to use delta
);
ALTER TABLE epics._mfields OWNER TO lsadmin;

INSERT INTO epics._mfields (mf, mc, mfMorA, mfUsePrec, mfUseDelta) VALUES ( ':RqsPos',      'mRqsPos', True,  True,  True);
INSERT INTO epics._mfields (mf, mc, mfMorA, mfUsePrec, mfUseDelta) VALUES ( ':ActPos',      'mActPos', True,  True,  True);
INSERT INTO epics._mfields (mf, mc, mfMorA, mfUsePrec, mfUseDelta) VALUES ( ':AmpEna',      'mAmpEna', True,  False, False);
INSERT INTO epics._mfields (mf, mc, mfMorA, mfUsePrec, mfUseDelta) VALUES ( ':RqsPos.DRVL', 'mLl',     True,  False, False);
INSERT INTO epics._mfields (mf, mc, mfMorA, mfUsePrec, mfUseDelta) VALUES ( ':RqsPos.DRVH', 'mHl',     True,  False, False);
INSERT INTO epics._mfields (mf, mc, mfMorA, mfUsePrec, mfUseDelta) VALUES ( ':NgLimSet',    'mLlHit',  True,  False, False);
INSERT INTO epics._mfields (mf, mc, mfMorA, mfUsePrec, mfUseDelta) VALUES ( ':PsLimSet',    'mHlHit',  True,  False, False);
INSERT INTO epics._mfields (mf, mc, mfMorA, mfUsePrec, mfUseDelta) VALUES ( ':Abort',       'mAbort',  False, False, False);
INSERT INTO epics._mfields (mf, mc, mfMorA, mfUsePrec, mfUseDelta) VALUES ( ':Kill',        'mKill',   False, False, False);
INSERT INTO epics._mfields (mf, mc, mfMorA, mfUsePrec, mfUseDelta) VALUES ( ':InPos',       'mInPos',  False, False, False);

CREATE TABLE epics._pv2motion (
-- Table to link pv to motion
-- Needed since several motions may refer to the same assembly
	pv2mKey    serial primary key,	-- table key
	pv2mPv     bigint references epics._pvmonitors (pvmKey),	-- pointer to pv
	pv2mM      bigint references epics._motions (mkey),	-- pointer to motion
	pv2mField  text   references epics._mfields (mf),	-- pointer to field
	pv2mNotify text   NOT NULL,
	UNIQUE (pv2mPv, pv2mM, pv2mNotify)			-- the notify to call
);
ALTER TABLE epics._pv2motion OWNER TO lsadmin;



CREATE OR REPLACE FUNCTION epics._pvmonitorInsert() RETURNS trigger AS $$
--
-- Trigger function called when inserting a new PV
-- This function fixes up the 'monitorIndex' Field and
-- puts in the link to the history table
--
  DECLARE
    theHpnKey bigint;		-- the key to this pv's entry in the history name table
  BEGIN
    --
    -- create next index: this is used in Max's caMonitor program to index the array of PVs
    --
    SELECT INTO NEW.pvmMonitorIndex coalesce( max( pvmMonitorIndex),-1)+1 FROM epics._pvmonitors;
    --
    -- Get the history name index
    SELECT INTO theHpnKey hpnKey FROM epics._historyPvNames WHERE hpnName=NEW.pvmName;
    IF NOT FOUND THEN
      INSERT INTO epics._historyPvNames (hpnName) VALUES (NEW.pvmName);
      SELECT INTO theHpnKey lastval();
    END IF;
    NEW.pvmHistoryKey := theHpnKey;

    RETURN NEW;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION epics._pvmonitorInsert() OWNER TO lsadmin;

CREATE TRIGGER pvmonitorInsertTrigger BEFORE INSERT ON epics._pvmonitors FOR EACH ROW EXECUTE PROCEDURE epics._pvmonitorInsert();

CREATE OR REPLACE FUNCTION epics._pvmonitorUpdate() RETURNS trigger AS $$
  DECLARE
    lnk record;		-- link table entries for this pv
  BEGIN
    --
    -- When it is a new value then add it to the history values
    -- and send out the notifies
    --
    IF OLD.pvmValuen is null or NEW.pvmValue != OLD.pvmValue THEN
      NEW.pvmValueN := NEW.pvmValue::numeric;
      NEW.pvmTs     := now();
    END IF;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION epics._pvmonitorUpdate() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION epics.pvUpdateValue( thePid bigint, index int, value text) RETURNS void AS $$
  DECLARE
  BEGIN
    PERFORM 1 FROM epics._pids WHERE pid=thePid;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Updating PV Info with Illegal PID %: Please Kill Yourself', thePid;
    END IF;
    UPDATE epics._pvmonitors SET pvmts=now(), pvmValue=value, pvmValuen=value::numeric WHERE pvmMonitorIndex = index;      
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION epics.pvUpdateValue( bigint, int, text) OWNER TO lsadmin;

CREATE TRIGGER pvmonitorUpdateTrigger BEFORE UPDATE ON epics._pvmonitors FOR EACH ROW EXECUTE PROCEDURE epics._pvmonitorUpdate();

CREATE TYPE epics.pvmonitor AS (pvmKey int, pvfield text, pvmName text, pvmPrec int, pvmDelta numeric);

CREATE OR REPLACE FUNCTION epics._genmotionpvs( k int) RETURNS  void AS $$
--
-- From the _motions table generate the entries in the _pvmonitors table and the linking table
-- We should have the camonitor program store a numeric type and use the prec variable on this end to generate text fields
-- that would allow multiple requests for the same PV but with different requirements for precision and/or delta to live happly
-- But alas, the first one wins here and the rest use the precision and delta determined by it
--
  DECLARE
    m epics._motions;		-- the epics motions record
    rtn epics.pvmonitor;	-- the return value
    pvInfo record;		-- name of the pv and the field
    pvKey int;			-- Key from pvmonitors

  BEGIN
    --
    -- Get the needed entries from the motions table
    --
    SELECT INTO m * FROM epics._motions WHERE mkey=k;
    
    --
    -- Generate names based on the motion fields in mfields
    -- CASE is needed since some variables are base on the motor name and some on the assembly name
    --
    FOR pvInfo IN SELECT mf AS field, mc AS col,
	CASE WHEN mfUsePrec  THEN m.mPrec          ELSE 0                   END AS prec,
	CASE WHEN mfUseDelta THEN m.mDelta         ELSE 0                   END AS delta,
	CASE WHEN mfMorA     THEN m.mMotorPvName || mf ELSE m.mAssemblyPvName || mf END AS name
	FROM epics._mfields LOOP

      --
      -- Check to see if we already have this pv: Don't add it if so
      --
      SELECT INTO pvkey pvmKey FROM epics._pvmonitors WHERE pvmName = pvInfo.name;
      IF FOUND THEN
	NULL;
        EXECUTE 'UPDATE epics._motions SET ' || pvInfo.col || '=' || pvkey || ' WHERE mKey=' || k;
        --
        -- Just touch the pv2motion table (we'll use this to set the _motions fields when the pv updates
        -- Ignore prec and delta (TODO: fix this)
        -- INSERT INTO epics._pv2motion (pv2mPv, pv2mM, pv2mField, pv2mNotify) VALUES (pvkey, k, pvInfo.field, 'DummyNotify');
      ELSE
        --
        -- put in both the pvmonitor and the linking table entry
        --
        INSERT INTO epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES ( pvInfo.name, pvInfo.prec, pvInfo.delta);
        EXECUTE 'UPDATE epics._motions SET ' || pvInfo.col || '=currval('epics._pvmonitors_pvmkey_seq') WHERE mKey=' || k;
        -- INSERT INTO epics._pv2motion (pv2mPv, pv2mM, pv2mField, pv2mNotify) VALUES ( lastval(), k, pvInfo.field, 'DummyNotify');
      END IF;
    END LOOP;

    RETURN;

  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION epics._genmotionpvs( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION epics._genmotionpvs() RETURNS void AS $$
  BEGIN
    PERFORM epics._genmotionpvs( mkey) FROM epics._motions;   
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION epics._genmotionpvs() OWNER TO lsadmin;

CREATE TYPE epics.pvnamestype AS ( index int, name text, delta numeric, dtime numeric, prec int);

CREATE OR REPLACE FUNCTION epics.getPvNames( thePid bigint) RETURNS SETOF epics.pvnamestype AS $$
  DECLARE
    rtn epics.pvnamestype;
  BEGIN
    PERFORM 1 FROM epics._pids WHERE pid=thePid;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Getting PV Info with Illegal PID %: Please Kill Yourself', thePid;
    END IF;

    FOR rtn IN SELECT pvmMonitorIndex, pvmName, pvmDelta, pvmdTime, pvmPrec FROM epics._pvmonitors ORDER BY pvmMonitorIndex LOOP
      RETURN NEXT rtn;
    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION epics.getPvNames( bigint) OWNER TO lsadmin;



CREATE TABLE epics._putqueue (
-- Queue of pv values to put
	pqKey serial primary key,				-- table key
	pqIndex int NOT NULL,					-- index in camonitor's pv entry
	pqValue text NOT NULL,					-- value to put
	pqTS timestamptz           default now(),		-- time item was entered
	pqRunAfterTS timestamptz   default now(),		-- Don't run until at least this time
	pqRunExpiresTS timestamptz default now()+'5 seconds'	-- don't run, just delete after this time
);
ALTER TABLE epics._putqueue OWNER TO lsadmin;

CREATE TABLE epics._pids (
-- table of valid process IDs for camonitor
	pid serial primary key	-- table key
);
ALTER TABLE epics._pids OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION epics.iniCAMonitor() RETURNS bigint AS $$
	DELETE FROM epics._pids;
	INSERT INTO epics._pids DEFAULT VALUES;
	LISTEN caPutNotify;
	SELECT currval( 'epics._pids_pid_seq')::bigint;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION epics.iniCAMonitor() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION epics.pushPutQueue( k bigint, v text) RETURNS void AS $$
	INSERT INTO epics._putQueue (pqIndex, pqValue) SELECT pvmMonitorIndex, $2 FROM epics._pvMonitors WHERE pvmKey=$1;
	NOTIFY caPutNotify;
$$ LANGUAGE sql SECURITY DEFINER VOLATILE;
ALTER FUNCTION epics.pushPutQueue( bigint, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION epics.pushPutQueue( k bigint, v text, expires timestamptz) RETURNS void AS $$
	INSERT INTO epics._putQueue (pqIndex, pqValue, pqRunExpiresTS) SELECT pvmMonitorIndex, $2, $3 FROM epics._pvMonitors WHERE pvmKey=$1;
	NOTIFY caPutNotify;
$$ LANGUAGE sql SECURITY DEFINER VOLATILE;
ALTER FUNCTION epics.pushPutQueue( bigint, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION epics.pushPutQueue( k bigint, v text, delayed timestamptz, expires timestamptz) RETURNS void AS $$
	INSERT INTO epics._putQueue (pqIndex, pqValue, pqRunAfterTS, pqRunExpiresTS) SELECT pvmMonitorIndex, $2, $3, $4 FROM epics._pvMonitors WHERE pvmKey=$1;
	NOTIFY caPutNotify;
$$ LANGUAGE sql SECURITY DEFINER VOLATILE;
ALTER FUNCTION epics.pushPutQueue( bigint, text) OWNER TO lsadmin;



CREATE TABLE epics.caPutQueue (
       capKey serial primary key,
       capPv text not null,
       capVal text not null
);
ALTER TABLE epics.caPutQueue OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION epics.caPutPush( pv text, val text) returns void as $$
  INSERT INTO epics.caPutQueue (capPv, capVal) VALUES ($1, $2);
  NOTIFY caPutNotify;
$$ LANGUAGE SQL SECURITY DEFINER VOLATILE;
ALTER FUNCTION epics.caPutPush( text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION epics.caPutPop() returns setof epics.caPutQueue AS $$
  DECLARE
    rtn epics.caPutQueue;
  BEGIN
    FOR rtn IN SELECT * FROM epics.caPutQueue ORDER BY capKey asc LOOP
      DELETE FROM epics.caPutQueue WHERE capKey=rtn.capKey;
      return next rtn;
    END LOOP;
    return;
  END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER VOLATILE;
ALTER FUNCTION epics.caPutPop() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION epics.checkPID( thePid bigint) RETURNS int AS $$
	SELECT pid FROM epics._pids WHERE pid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION epics.checkPID( bigint) OWNER TO lsadmin;


CREATE TYPE epics.putQueueType AS ( index int, value text);

CREATE OR REPLACE FUNCTION epics.popPutQueue( thePid bigint) RETURNS SETOF epics.putQueueType AS $$
  DECLARE
    r   record;			-- record from queue
    k   int;			-- key of queue
    rtn epics.putQueueType;	-- index and value
  BEGIN
    -- remove expired entries
    DELETE FROM epics._putqueue WHERE pqRunExpiresTS <= now();

    -- check to be sure our camonitor process is the current one
    PERFORM 1 FROM epics._pids WHERE pid=thePid;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Popping Put Queue with Illegal PID %: Please Kill Yourself', thePid;
    END IF;

    --
    -- Loop through all active queue entries: 
    FOR r IN SELECT  pqIndex, pqValue, pqKey FROM epics._putqueue WHERE pqRunAfterTS <= now() ORDER BY pqKey LOOP
      rtn.index := r.pqIndex;
      rtn.value := r.pqValue;
      -- send to the camonitor program the pv/values we want to "put"
      RETURN NEXT rtn;
      -- remove the entry now that it is done
      DELETE FROM epics._putqueue WHERE pqKey=r.pqKey;
    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION epics.popPutQueue( bigint) OWNER TO lsadmin;


INSERT INTO epics._motions ( mMotorPvName, mAssemblyPvName, mPrec, mDelta) VALUES ( '21:G1:DT:D',  '21:G1:DT:St', 1, 0.02);
INSERT INTO epics._motions ( mMotorPvName, mAssemblyPvName, mPrec, mDelta) VALUES ( '21:G1:S1:YC', '21:G1:S1:Av', 2, 0.002);
INSERT INTO epics._motions ( mMotorPvName, mAssemblyPvName, mPrec, mDelta) VALUES ( '21:G1:S1:YS', '21:G1:S1:Av', 2, 0.002);

INSERT INTO epics._motions ( mMotorPvName, mAssemblyPvName, mPrec, mDelta) VALUES ( '21:F1:DT:D',  '21:F1:DT:St', 1, 0.02);
INSERT INTO epics._motions ( mMotorPvName, mAssemblyPvName, mPrec, mDelta) VALUES ( '21:F1:S1:YC', '21:F1:S1:Av', 2, 0.002);
INSERT INTO epics._motions ( mMotorPvName, mAssemblyPvName, mPrec, mDelta) VALUES ( '21:F1:S1:YS', '21:F1:S1:Av', 2, 0.002);

SELECT epics._genmotionpvs();

INSERT INTO epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES (
'S:SRcurrentAI', 1, 0.1); INSERT INTO epics._pvmonitors ( pvmName,
pvmPrec, pvmDelta) VALUES ( 'ID21ds:Gap', 3, 0.001); INSERT INTO
epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES (
'ID21ds:Energy', 3, 0.001); INSERT INTO epics._pvmonitors ( pvmName,
pvmPrec, pvmDelta) VALUES ( 'ID21us:Gap', 3, 0.001); INSERT INTO
epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES (
'ID21us:Energy', 3, 0.001);

INSERT INTO epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES ( 'S21us:ID:SrcPt:xAngleM', 1, 0.1);
INSERT INTO epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES ( 'S21us:ID:SrcPt:xPositionM', 1, 0.1);
INSERT INTO epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES ( 'S21us:ID:SrcPt:yAngleM', 1, 0.1);
INSERT INTO epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES ( 'S21us:ID:SrcPt:yPositionM', 1, 0.1);

INSERT INTO epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES ( 'S21ds:ID:SrcPt:xAngleM', 1, 0.1);
INSERT INTO epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES ( 'S21ds:ID:SrcPt:xPositionM', 1, 0.1);
INSERT INTO epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES ( 'S21ds:ID:SrcPt:yAngleM', 1, 0.1);
INSERT INTO epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES ( 'S21ds:ID:SrcPt:yPositionM', 1, 0.1);


INSERT INTO epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES ( '21:G1:scaler1_cts3.A', 0, 1);
INSERT INTO epics._pvmonitors ( pvmName, pvmPrec, pvmDelta) VALUES ( '21:F1:scaler1_cts3.A', 0, 1);


CREATE OR REPLACE FUNCTION epics.caget( pv text) returns text as $$
  DECLARE
    rtn text;
  BEGIN
    SELECT epics._caget( pvmmonitorindex::int) INTO rtn FROM epics._pvmonitors WHERE pvmname=pv;
    return rtn;
  END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER;
ALTER FUNCTION epics.caget( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION epics._caget( text) returns text as $$
  SELECT epics.caget( $1);
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION epics._caget( text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION epics.caput( pv text, v text) returns void as $$
  select  epics.caputpush( $1, $2);
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION epics.caput( text, text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION epics._caget( pvi int) returns text as $$

  if not GD.has_key( "mmap"):
    plpy.execute( "select pg_advisory_lock( 14850)")
    import mmap
    GD["mmap"] = mmap
    plpy.execute( "select pg_advisory_unlock( 14850)")
  mmap = GD["mmap"]

  if not GD.has_key( "mm"):
    plpy.execute( "select pg_advisory_lock( 14850)")
    mm = {}
    GD["mm"] = mm
    plpy.execute("select pg_advisory_unlock( 14850)")
  mm = GD["mm"]

  if not mm.has_key( "fd"):
    plpy.execute( "select pg_advisory_lock( 14850)")
    try:
      f = open( "/mnt/pvs/pvService", "r+")
      s  = mmap.mmap( f.fileno(), 0)
    except:
      plpy.warning( "something bad happend while trying to create mm")
      plpy.execute( "select pg_advisory_unlock( 14850)")
      return None

    mm["fd"] = f.fileno()
    mm["s"]  = s
    plpy.execute( "select pg_advisory_unlock( 14850)")

  try:
    plpy.execute( "select pg_advisory_lock( 14852, %d)" % (pvi))
    mm["s"].seek(256*pvi)
    readFlag = True
    val = ""
    while readFlag:
      tmp = mm["s"].read_byte()
      if tmp != "\0":
        val += tmp
      else:
        readFlag = False

  except:
    plpy.warning( "something bad happend while trying to read the pv value")
    del GD["mm"]
    plpy.execute( "select pg_advisory_unlock( 14852, %d)" % (pvi))
    return None

  plpy.execute( "select pg_advisory_unlock( 14852, %d)" % (pvi))
  if val==None or val=="None":
    val=str("505.911")
  return val
$$ LANGUAGE plpythonu SECURITY DEFINER;
ALTER FUNCTION epics._caget( int) OWNER TO lsadmin;


CREATE TABLE epics.blstatuspvs (
  blspkey serial primary key,
  blspstn int,
  blsp_a_fe int

CREATE TYPE epics.blstatustype AS (blsstn int, blsbeamon boolean, blstatusmsg text);
CREATE OR REPLACE FUNCTION epics.blstatus() returns setof epics.blstatustype AS $$
  DECLARE
  BEGIN
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION epics.blstatus() OWNER TO lsadmin;
