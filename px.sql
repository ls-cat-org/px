--
-- Support for px data collection
--
--
--DROP SCHEMA px CASCADE;
--CREATE SCHEMA px;
GRANT USAGE ON SCHEMA px TO PUBLIC;

CREATE TABLE px._marinit (
--
-- commands to run with the mar starts up
-- these commands are pushed onto the mar command queue
-- and run by pxMarServer
--
        mikey serial primary key,       -- table key
        miitem text not null,           -- initialzation command
        miorder int unique              -- order to run commands
);
ALTER TABLE px._marinit OWNER TO lsadmin;

INSERT INTO px._marinit (miorder,miitem) VALUES ( 1, 'set_thumbnail1,pgm,512,512');
INSERT INTO px._marinit (miorder,miitem) VALUES ( 2, 'set_thumbnail2,pgm,64,64');
INSERT INTO px._marinit (miorder,miitem) VALUES ( 3, 'readout,1');
INSERT INTO px._marinit (miorder,miitem) VALUES ( 4, 'readout,2');
INSERT INTO px._marinit (miorder,miitem) VALUES ( 5, 'dezinger,1');


CREATE OR REPLACE FUNCTION px.marinit() RETURNS void AS $$
--
-- access the _marinit table
--
  DECLARE
    r record;
    ntfy text;
  BEGIN
    PERFORM pg_advisory_lock( px.getstation(), 5);
    SELECT INTO ntfy cnotifydetector FROM px._config LEFT JOIN px.stations ON cstation=stnname WHERE stnkey=px.getstation();
    EXECUTE 'LISTEN ' || ntfy;
    FOR r IN SELECT * FROM px._marinit order by miorder LOOP
      PERFORM px.pushqueue( r.miitem);
    END LOOP;
    EXECUTE 'NOTIFY ' || ntfy;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.marinit() OWNER TO lsadmin;

--
-- Detector lock tables
--
CREATE TABLE px._id21d_detectorLock ( d int);
ALTER TABLE px._id21d_detectorLock OWNER TO lsadmin;

CREATE TABLE px._id21e_detectorLock ( d int);
ALTER TABLE px._id21e_detectorLock OWNER TO lsadmin;

CREATE TABLE px._id21f_detectorLock ( d int);
ALTER TABLE px._id21f_detectorLock OWNER TO lsadmin;

CREATE TABLE px._id21g_detectorLock ( d int);
ALTER TABLE px._id21g_detectorLock OWNER TO lsadmin;


--
-- Diffractometer lock tables
CREATE TABLE px._id21d_diffractometerLock ( d int);
ALTER TABLE px._id21d_diffractometerLock OWNER TO lsadmin;

CREATE TABLE px._id21e_diffractometerLock ( d int);
ALTER TABLE px._id21e_diffractometerLock OWNER TO lsadmin;

CREATE TABLE px._id21f_diffractometerLock ( d int);
ALTER TABLE px._id21f_diffractometerLock OWNER TO lsadmin;

CREATE TABLE px._id21g_diffractometerLock ( d int);
ALTER TABLE px._id21g_diffractometerLock OWNER TO lsadmin;

CREATE TABLE px._marqueue (
--
-- command queue for the mar detector
--
        mqkey serial primary key,                       -- table key
        mqs timestamp with time zone default now(),     -- create time stamp
        mqc inet NOT NULL,                              -- client address (address of marccd)
        mqcmd text NOT NULL                             -- queued command
);
ALTER TABLE px._marqueue OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.pushqueue( cmd text) RETURNS VOID AS $$
--
-- Function to push command onto the queue
--
  DECLARE
    c text;     -- trimmed cmd
    ntfy text;
  BEGIN
    SELECT INTO ntfy cnotifydetector FROM px._config LEFT JOIN px.stations ON cstation=stnname WHERE stnkey=px.getstation();
    c = trim( cmd);
    IF length( c) > 0 THEN
      INSERT INTO px._marqueue (mqcmd,mqc) SELECT c, cdetector from px._config where cdiffractometer=inet_client_addr() or cdetector=inet_client_addr() limit 1;
      EXECUTE 'NOTIFY ' || ntfy;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.pushqueue( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.pushqueue( theStn bigint, cmd text) RETURNS VOID AS $$
--
-- Function to push command onto the queue
--
  DECLARE
    c text;     -- trimmed cmd
    ntfy text;
  BEGIN
    SELECT INTO ntfy cnotifydetector FROM px._config LEFT JOIN px.stations ON cstation=stnname WHERE stnkey=theStn;
    c = trim( cmd);
    IF length( c) > 0 THEN
      INSERT INTO px._marqueue (mqcmd,mqc) SELECT c, cdetector from px._config where cstnkey=theStn limit 1;
      EXECUTE 'NOTIFY ' || ntfy;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.pushqueue( bigint, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.pushqueue( cmd text, ca inet) RETURNS VOID AS $$
--
-- specify client address (ca) to queue up
  DECLARE
    c text;     -- trimmed cmd
    ntfy text;
  BEGIN
    SELECT INTO ntfy cnotifydetector FROM px._config LEFT JOIN px.stations ON cstation=stnname WHERE stnkey=px.getstation();
    c = trim( cmd);
    IF length( c) > 0 THEN
      INSERT INTO px._marqueue (mqcmd,mqc) VALUES (c, ca);
      EXECUTE 'NOTIFY ' || ntfy;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.pushqueue( text, inet) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.popqueue() RETURNS text AS $$
--
-- Function to pop command off the queue
--
  DECLARE
    rtn text;   -- return value
    mqk int;    -- serial number of returned value
  BEGIN
    SELECT INTO rtn, mqk mqcmd, mqkey FROM px._marqueue where mqc=inet_client_addr() ORDER BY mqkey ASC LIMIT 1;
    IF NOT FOUND THEN
      RETURN '';
    END IF;
    DELETE FROM px._marqueue WHERE mqkey = mqk;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.popqueue() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.popqueue( cmd text) RETURNS text AS $$
--
-- Function to pop a specific command off the queue, even if it's not next
--
  DECLARE
    rtn text;   -- return value
    mqk int;    -- serial number of returned value
  BEGIN
    SELECT INTO rtn, mqk mqcmd, mqkey FROM px._marqueue WHERE mqcmd=cmd and mqc=inet_client_addr() ORDER BY mqkey ASC LIMIT 1;
    IF NOT FOUND THEN
      RETURN '';
    END IF;
    DELETE FROM px._marqueue WHERE mqkey = mqk;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.popqueue( text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.flushqueue() RETURNS VOID AS $$
--
-- Function to flush the queue
--
  BEGIN
    DELETE FROM px._marqueue where mqc=inet_client_addr();
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.flushqueue( ) OWNER TO lsadmin;


CREATE TABLE px._mar (
--
-- Raw responses from pxMarServer
-- Currently pxMarServer accesses this table directly
-- Good for debugging, not recommended for production
--
        mkey serial primary key,                        -- table key
        mc inet NOT NULL,                               -- mar client (marccd server) ipaddress
        mts timestamp with time zone default now(),     -- creatation time stamp
        mtu timestamp with time zone default now(),     -- update time stamp (last time checked with same state)
        mrawresponse text,                              -- string returned from marccd
        mcnt int default 1,                             -- number of times this string has been returned
        mrawstate int                                   -- state returned by get_state
);
ALTER TABLE px._mar OWNER TO lsadmin;
--
-- Need grants for direct access
GRANT SELECT, INSERT, UPDATE ON px._mar TO PUBLIC;
GRANT SELECT, INSERT, UPDATE ON px._mar_mkey_seq TO PUBLIC;

CREATE OR REPLACE FUNCTION px._mar_insert_tf() RETURNS trigger AS $$
--
-- Consolidate _mar by converting inserts to update when possible
--
  DECLARE
    mrr text;           -- most recent raw response received
    mk  int;            -- serial number of most recent response
    mrs int;            -- old raw state
    nrs int;            -- new raw state
  BEGIN
    SELECT INTO mk, mrr, mrs mkey, mrawresponse, mrawstate FROM px._mar where mc=inet_client_addr() ORDER BY mkey DESC LIMIT 1;
    IF not found OR NEW.mrawresponse != mrr THEN
      nrs = NULL;
      IF position( 'is_state' in NEW.mrawresponse) = 1 THEN
        nrs = split_part( NEW.mrawresponse, ',', 2)::int;
      END IF;
      NEW.mrawstate = nrs;
      RETURN NEW;
    END IF;
    UPDATE px._mar SET mtu=now(), mcnt=mcnt+1 WHERE mkey=mk;
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px._mar_insert_tf() OWNER TO lsadmin;

CREATE TRIGGER _mar_insert_trigger BEFORE INSERT ON px._mar FOR EACH ROW EXECUTE PROCEDURE px._mar_insert_tf();


CREATE OR REPLACE FUNCTION px.marstatus( status int) returns text as $$
-- returns the task as a string
--
  DECLARE
    s int;      -- low 4 bits of status
    rtn text;   -- the return value
  BEGIN
    s = (status::bit(32) & x'0000000f'::bit(32))::int;
    rtn = case s
      when 0 then 'idle'
      when 1 then 'acquire'
      when 2 then 'readout'
      when 3 then 'correct'
      when 4 then 'writing'
      when 5 then 'abortint'
      when 6 then 'unavailable'
      when 7 then 'error'
      when 8 then 'busy'
      else 'illegal state ' || s
      end;
    RETURN rtn;
   END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.marstatus( status int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.martaskstatus( status int, task int) returns text as $$
--
-- returns the status of the given marccd task
  DECLARE
    s bit(4);   -- 4 bits of task status
    rtn text;   -- the return value
  BEGIN
    s = (((status::bit(32) >> (4*(task+1))) & x'0000000f'::bit(32))::int)::bit(4);
    rtn = case s
      when b'0110' then 'executing/error'
      when b'0100' then 'error'
      when b'0011' then 'executing/queued'
      when b'0010' then 'executing'
      when b'0001' then 'queued'
      when b'0000' then 'idle'
      else 'illegal status ' || s::int
      end;
    return rtn;
    END;
$$ LANGUAGE plpgsql RETURNS NULL ON NULL INPUT SECURITY DEFINER;
ALTER FUNCTION px.martaskstatus( int, int) OWNER TO lsadmin;


--
-- allows the marccd status timing to be printed out nicely
--
CREATE OR REPLACE VIEW px.mar ( mkey, mqc, mts, mtu, mtd, mstatus, maquire, mread, mcorrect, mwrite, mdezinger) AS
        SELECT mkey, host(mc),mts, mtu, mtu-mts, px.marstatus( mrawstate), px.martaskstatus( mrawstate,0),px.martaskstatus( mrawstate,1),px.martaskstatus( mrawstate,2),px.martaskstatus( mrawstate,3),px.martaskstatus( mrawstate,4)
           FROM px._mar;


CREATE TYPE px.marheadertype AS ( sdist numeric, sexpt numeric, sstart numeric, saxis text, swidth numeric, dsdir text, sfn text, thelambda numeric, sphi numeric, skappa numeric);

CREATE OR REPLACE FUNCTION px.marHeader( k bigint) returns px.marheadertype AS $$
  DECLARE
    rtn px.marheadertype;
  BEGIN
    SELECT INTO rtn coalesce(sdist,  dsdist)::numeric      as sdist,
                    coalesce(sexpt,  coalesce( dsexp,'1.0'))::numeric       as sexpt,
                    coalesce(sstart, coalesce( dsstart, '0'))::numeric        as sstart,
                    coalesce(saxis,  coalesce( dsoscaxis,'omega'))          as saxis,
                    coalesce(swidth, coalesce( dsowidth, '1.0'))::numeric   as swidth,
                    coalesce(dsdir, '/data/public')                         as dsdir,
                    coalesce(sfn, 'default')                                as sfn,
                    px.rt_get_wavelength()::numeric                         as thelambda,
                    coalesce( sphi, coalesce( dsphi, '0'))::numeric         as sphi,
                    coalesce( skappa, coalesce( dskappa, '0'))::numeric     as skappa
                    from px.shots
                    left join px.datasets on sdspid=dspid
                    where skey=k;
    IF NOT FOUND THEN
      return NULL;
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.marHeader( bigint) OWNER TO lsadmin;



CREATE TABLE px.stations (
--
-- stations allowed
--
        stnkey       serial primary key,        -- table key
        stnname      text not null unique,      -- station name
        stnshortname text not null unique,      -- short name used to create legal variable names
        stndataroot  text not null,             -- default root data directory
        stnid        int references px.holderpositions (hpid)
);
ALTER TABLE px.stations OWNER TO lsadmin;
GRANT SELECT ON px.stations TO PUBLIC;

INSERT INTO px.stations (stnName, stnShortName, stnDataRoot) VALUES ( '21-ID-D', 'idd', 'd');
INSERT INTO px.stations (stnName, stnShortName, stnDataRoot) VALUES ( '21-ID-E', 'ide', 'e');
INSERT INTO px.stations (stnName, stnShortName, stnDataRoot) VALUES ( '21-ID-F', 'idf', 'f');
INSERT INTO px.stations (stnName, stnShortName, stnDataRoot) VALUES ( '21-ID-G', 'idg', 'g');


CREATE TABLE px._config (
--
-- per station configuration
--
-- Note that the station is stored as text rather than the key to the station table
-- this may be a little slower but more immune configuration errors
--
-- KLUDGE: notify names are of the form 'STATION_TYPE' with a single underscore and STATION is in (id21d,id21e,id21f,id21g) while TYPE is in (kill,snap,run)
-- Don't change this format without also changing client code (pxPanel)
--
        ckey             serial primary key,            -- table key
        cdetector        inet   not null,               -- ip address of the detector computer
        cdiffractometer  inet   not null,               -- ip address of the diffractometer
        crobot           inet   not null,               -- ip address of the robot control process (our python script)
        ccats            inet   not null,               -- ip address of the CATS robot (the Stuabli controller)
        cstation         text   not null                -- station where detector and diffractometer live
                references px.stations (stnname),
        cstnkey          bigint not null
                references px.stations (stnkey),
        cdifflocktable   text   not null,               -- name of diffractometer locking table
        cdetectlocktable text   not null,               -- name of detector locking table
        cnotifykill      text   not null,
        cnotifysnap      text   not null,
        cnotifyrun       text   not null,
        cnotifydetector  text   not null,
        cnotifydiffractometer text not null,
        cnotifypause     text   not null,
        cnotifymessage   text   not null,
        cnotifywarning   text   not null,
        cnotifyerror     text   not null,
        cnotifyxfer      text   not null,
        cnotifyrobot     text   not null,
	cnotifycenter    text   not null,
	cnotifylogin     text   not null
);
ALTER TABLE px._config OWNER TO lsadmin;
GRANT SELECT ON px._config TO PUBLIC;

INSERT INTO px._config (cdetector, cdiffractometer, cstation, cdifflocktable, cdetectlocktable, cnotifykill, cnotifysnap, cnotifyrun, cnotifydetector, cnotifypause) VALUES (
  inet '10.1.252.166', inet '10.1.252.18', '21-ID-F', 'px._id21f_diffractometerLock', 'px._id21f_detectorLock', 'id21f_kill', 'id21f_snap', 'id21f_run', 'id21f_det', 'id21f_pause'
);

INSERT INTO px._config (cdetector, cdiffractometer, cstation, cdifflocktable, cdetectlocktable, cnotifykill, cnotifysnap, cnotifyrun, cnotifydetector, cnotifypause) VALUES (
  inet '10.1.252.140', inet '10.1.252.19', '21-ID-G', 'px._id21g_diffractometerLock', 'px._id21g_detectorLock', 'id21g_kill', 'id21g_snap', 'id21g_run', 'id21g_det', 'id21g_pause'
);

--
-- Testing: Mung on contrabass test program
INSERT INTO px._config (cdetector, cdiffractometer, cstation, cdifflocktable, cdetectlocktable, cnotifykill, cnotifysnap, cnotifyrun, cnotifydetector, cnotifypause) VALUES (
  inet '10.1.0.3', inet '10.1.252.164', '21-ID-E', 'px._id21e_diffractometerLock', 'px._id21e_detectorLock', 'id21e_kill', 'id21e_snap', 'id21e_run', 'id21e_det', 'id21e_pause'
);



CREATE OR REPLACE FUNCTION px.getstation( theip inet) RETURNS int AS $$
--
-- Returns the station key given an ip address
--
  SELECT  stnkey FROM px.stations left join px._config on stnname=cstation where $1=cdetector or $1=cdiffractometer or $1=crobot
$$ LANGUAGE sql SECURITY DEFINER STABLE;
ALTER FUNCTION px.getstation( inet) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getstation() RETURNS int AS $$
--
-- Returns the station key for this connection
  SELECT px.getstation( inet_client_addr());
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.getstation() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getstation( thestn text) RETURNS int AS $$
--
-- Return the station key given the text (full or short) of the station name
  SELECT stnkey FROM px.stations where $1=stnname or $1=stnshortname;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.getstation( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getcatsaddr() RETURNS text AS $$
  SELECT host(ccats) FROM px._config WHERE cstnkey = px.getStation();
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.getcatsaddr() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getcatsaddr( thestn text) RETURNS text AS $$
  SELECT host(ccats) FROM px._config WHERE $1=cstation;
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.getcatsaddr( text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.inidetector() RETURNS void AS $$
--
-- Initialize the detector
-- The intent is to create lock tables in this function if needed
-- TODO
  DECLARE
  BEGIN
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.inidetector() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.demandDiffractometerOn() RETURNS void AS $$
  DECLARE
  BEGIN
  PERFORM pg_advisory_lock( px.getstation(), 1);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.demandDiffractometerOn() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.dropDiffractometerOn() RETURNS void AS $$
  DECLARE
  BEGIN
  PERFORM pg_advisory_unlock( px.getstation(), 1);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.dropDiffractometerOn() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.checkDiffractometerOn() RETURNS boolean AS $$
  --
  -- returns false if the diffractometer is on
  --
  DECLARE
    rtn boolean;
  BEGIN
    SELECT pg_try_advisory_lock( px.getstation(), 1) INTO rtn;
    IF rtn THEN
      PERFORM pg_advisory_unlock( px.getstation(), 1);
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.checkDiffractometerOn() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ininotifies() RETURNS text AS $$
--
-- Used by the MD2 seqRun support code to setup notifies for the correct station
-- We are making use in seqRun of the format 'station_notifytype' so the underscore is important
--
  DECLARE
    notifyrun   text;   -- notify name for run
    notifysnap  text;   -- notify name for snap
    notifykill  text;   -- notify name for kill
    notifypause text;   -- notify name for pause
    notifyxfer  text;   -- notify name for xfer
    notifymess  text;   -- notify name for messages
    notifywarn  text;   -- notify name for warnings
    notifyerr   text;   -- notify name for errors
    rtn         text;   -- prefix for all the notify names: SEE KLUDGE ABOVE
  BEGIN
    PERFORM px.demandDiffractometerOn();
    rtn := NULL;
    SELECT  split_part(cnotifykill,'_',1), cnotifykill, cnotifysnap, cnotifyrun, cnotifypause, cnotifyxfer, cnotifymessage, cnotifywarning, cnotifyerror
       INTO rtn,                           notifykill,  notifysnap,  notifyrun,  notifypause,  notifyxfer,  notifymess,      notifywarn,    notifyerr
       FROM px._config WHERE px.getstation( cstation)=px.getstation();

    IF FOUND THEN
      EXECUTE 'LISTEN ' || notifykill;
      EXECUTE 'LISTEN ' || notifysnap;
      EXECUTE 'LISTEN ' || notifyrun;
      EXECUTE 'LISTEN ' || notifypause;
      EXECUTE 'LISTEN ' || notifyxfer;
      EXECUTE 'LISTEN ' || notifymess;
      EXECUTE 'LISTEN ' || notifywarn;
      EXECUTE 'LISTEN ' || notifyerr;
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ininotifies() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.lock_detector() RETURNS void AS $$
-- indicate that the detector is ready for action but isn't doing anything right now
  BEGIN
    PERFORM pg_advisory_lock( px.getstation(), 3);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.lock_detector() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.lock_detector_nowait() RETURNS int AS $$
-- test to see if the detector is integrating (1 means no but we are running)
  DECLARE
    tmp boolean;
  BEGIN
    SELECT pg_try_advisory_lock( px.getstation(), 3) INTO tmp;
    IF tmp THEN
      return 1;
    END IF;
    return 0;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.lock_detector_nowait() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.lock_detector_test() RETURNS int AS $$
-- test to see if the detector is integrating (1 means no but we are running)
  DECLARE
    tmp boolean;
  BEGIN
    SELECT pg_try_advisory_lock( px.getstation(), 3) INTO tmp;
    IF tmp THEN
      PERFORM pg_advisory_unlock( px.getstation(), 3);
      return 1;
    END IF;
    return 0;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.lock_detector_test() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.lock_detector_test( stn int) RETURNS int AS $$
-- test to see if the detector is integrating (1 means no but we are running)
  DECLARE
    tmp boolean;
  BEGIN
    SELECT pg_try_advisory_lock( stn, 3) into tmp;
    IF tmp THEN
      PERFORM pg_advisory_unlock( stn, 3);
      return 1;
    END IF;
    return 0;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.lock_detector_test( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.unlock_detector() RETURNS void AS $$
-- indicate the start of integration
  BEGIN
    PERFORM pg_advisory_unlock( px.getstation(), 3);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.unlock_detector() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.lock_diffractometer() RETURNS void AS $$
-- indicate we are either exposing or are ready to start exposing
  BEGIN
    PERFORM pg_advisory_lock( px.getstation(), 4);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.lock_diffractometer() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.lock_diffractometer_nowait() RETURNS int AS $$
-- test to see if the MD2 is ready to start exposing
  DECLARE
    tmp boolean;
  BEGIN
    SELECT pg_try_advisory_lock( px.getstation(), 4) INTO tmp;
    IF tmp THEN
      return 1;
    END IF;
    return 0;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.lock_diffractometer_nowait() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.lock_diffractometer_test() RETURNS int AS $$
-- test to see if the MD2 is ready to start exposing
  DECLARE
    tmp boolean;
  BEGIN
    SELECT pg_try_advisory_lock( px.getstation(), 4) INTO tmp;
    IF tmp THEN
      PERFORM pg_advisory_unlock( px.getstation(), 4);
      return 1;
    END IF;
    return 0;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.lock_diffractometer_test() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.lock_diffractometer_test( stn int) RETURNS int AS $$
-- test to see if the MD2 is ready to start exposing
  DECLARE
    tmp boolean;
  BEGIN
    SELECT pg_try_advisory_lock( stn, 4) INTO tmp;
    IF tmp THEN
      PERFORM pg_advisory_unlock( stn, 4);
      return 1;
    END IF;
    return 0;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.lock_diffractometer_test( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.unlock_diffractometer() RETURNS void AS $$
  -- grabs the diffractometer lock indicating ready to start exposure
  BEGIN
    PERFORM pg_advisory_unlock( px.getstation(), 4);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.unlock_diffractometer() OWNER TO lsadmin;


CREATE TABLE px.axes (
--
-- axes that are allowable
--
-- since PV's on different stations have different names we need to say
-- which station here cause they'll all have omega and phi.
--
        akey   serial primary key,      -- table key
        aaxis  text not null,           -- menu name of axis
        aepics text,                    -- epics PV to use
        astn   int                      -- station where this axis is used
                references px.stations (stnkey) ON UPDATE CASCADE
);
ALTER TABLE px.axes OWNER TO lsadmin;
GRANT SELECT ON px.axes TO PUBLIC;

INSERT INTO px.axes (aaxis, aepics, astn) VALUES ( 'omega', '', (select stnkey from px.stations where stnname='21-ID-D'));
INSERT INTO px.axes (aaxis, aepics, astn) VALUES ( 'omega', '', (select stnkey from px.stations where stnname='21-ID-E'));
INSERT INTO px.axes (aaxis, aepics, astn) VALUES ( 'omega', '', (select stnkey from px.stations where stnname='21-ID-F'));
INSERT INTO px.axes (aaxis, aepics, astn) VALUES ( 'omega', '', (select stnkey from px.stations where stnname='21-ID-G'));

CREATE TABLE px.shotstates (
--
-- Allowed values for the shot state
        ssstate text primary key                -- the state of the shot
);
ALTER TABLE px.shotstates OWNER TO lsadmin;
GRANT SELECT ON px.shotstates TO PUBLIC;

INSERT INTO px.shotstates (ssstate) VALUES ( 'NotTaken');
INSERT INTO px.shotstates (ssstate) VALUES ( 'Preparing');
INSERT INTO px.shotstates (ssstate) VALUES ( 'Moving');
INSERT INTO px.shotstates (ssstate) VALUES ( 'Exposing');
INSERT INTO px.shotstates (ssstate) VALUES ( 'FinishingUp');
INSERT INTO px.shotstates (ssstate) VALUES ( 'Done');

CREATE TABLE px.expunits (
        eu  text primary key,   -- the long version of the units
        eus text unique         -- short version for small labels
);
INSERT INTO px.expunits (eu, eus) VALUES ( 'Seconds',   'secs');
INSERT INTO px.expunits (eu, eus) VALUES ( 'Io Counts', 'cnts');

CREATE TABLE  px.oscsenses (
        os text primary key
);
ALTER TABLE px.oscsenses OWNER TO lsadmin;
GRANT SELECT ON px.oscsenses to PUBLIC;

INSERT INTO px.oscsenses (os) VALUES ( '+');
INSERT INTO px.oscsenses (os) VALUES ( '-');
INSERT INTO px.oscsenses (os) VALUES ( '+/-');
INSERT INTO px.oscsenses (os) VALUES ( '-/+');

--
-- fix_fn
-- removes illegal characters from file name
--
CREATE OR REPLACE FUNCTION px.fix_fn( fn text) RETURNS text as $$
  SELECT regexp_replace( $1, '[^-._a-zA-Z0-9]*', '','g');
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.fix_fn( text) OWNER TO lsadmin;

--
-- fix_dir
-- removes illegal characters from directory
--
CREATE OR REPLACE FUNCTION px.fix_dir( dir text) RETURNS text as $$
  DECLARE
    rtn text;
  BEGIN
    SELECT regexp_replace( dir, '[^-._a-zA-Z0-9/]*', '', 'g') INTO rtn;	-- remove illegal characters
    SELECT regexp_replace( rtn, E'^\\.+', '') INTO rtn;			-- don't allow begining dots
    SELECT regexp_replace( rtn, E'\\.\\.+', '', 'g') INTO rtn;		-- remove double (or worse) dots
    SELECT regexp_replace( rtn, '^/+', '') INTO rtn;			-- remove begining slashs
    SELECT regexp_replace( rtn, '/+', '/', 'g') INTO rtn;		-- make multiple slashs just one
    SELECT regexp_replace( rtn, '/+$', '')  INTO rtn;			-- kill the trailing slash
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.fix_dir( text) OWNER TO lsadmin;

CREATE TABLE px.dirstates (
        dirs text primary key
);

INSERT INTO px.dirstates (dirs) VALUES ('New');
INSERT INTO px.dirstates (dirs) VALUES ('Valid');
INSERT INTO px.dirstates (dirs) VALUES ('Invalid');
INSERT INTO px.dirstates (dirs) VALUES ('Wrong Permissions');

CREATE OR REPLACE FUNCTION px.chkdir( token text) returns void AS $$
  SELECT px.pushqueue( 'checkdir,'|| $1);
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.chkdir( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.chkdir( theStn bigint, token text) returns void AS $$
  SELECT px.pushqueue( $1, 'checkdir,'|| $2);
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.chkdir( bigint, text) OWNER TO lsadmin;


CREATE TABLE px.datasets (
        dskey      serial primary key,                          -- table key
        dspid      text NOT NULL UNIQUE,                        -- used to find the "shots"
        dscreatets timestamp with time zone default now(),      -- creatation time stamp
        dsdonets   timestamp with time zone default NULL,	-- time of last done frame
        dsesaf     int default NULL,                            -- The ESAF used for this experiment
-- A real references is not used as we currently delete the esaf routinely (during a modification, for example)
-- until this is thought trhough and tested completely it is better just to leave the reference hanging
--              references esaf.esafs (eexperimentid),
        dsdir      text NOT NULL default 'data',                -- the collection directory
        dsdirs     text NOT NULL default 'New'                  -- the directory state
                references px.dirstates (dirs),
        dsfp       text default 'default',                      -- file prfix
        dsstn      bigint                                       -- station to collect in
                references px.stations (stnkey) ON UPDATE CASCADE,
        dsoscaxis  text         default 'omega',                -- the Axis to move, presumably NULL means don't move a thing
        dsstart    numeric      default 0,                      -- starting angle of the dataset
        dsdelta    numeric      default 1,                      -- distance to next starting angle (usually owidth)
        dsowidth   numeric default 1,                           -- oscillation width
        dsnoscs    int default 1,                               -- number of oscillations per image
        dsoscsense text default '+'                             -- sense of oscillation relative to end-start direction
                references px.oscsenses (os) ON UPDATE CASCADE,
        dsnwedge   int          default 0,                      -- shots before flipping 180, 0 means don't do this
        dsend      numeric      default 90,                     -- ending angle
        dsexp      numeric      default 1,                      -- Exposure: how long to keep shutter open
        dsexpunit  text         default 'Seconds'               -- units of exposure: usually secs
                 references px.expunits (eu) ON UPDATE CASCADE,
        dsphi      numeric DEFAULT NULL,                        -- set phi (NULL means don't touch)
        dsomega    numeric DEFAULT NULL,                        -- set omega (NULL means don't touch)
        dskappa    numeric DEFAULT NULL,                        -- set kappa (NULL means don't touch)
        dsdist     numeric DEFAULT NULL,                        -- set distance (NULL means don't touch)
        dsnrg      numeric DEFAULT NULL,                        -- set energy (NULL means don't touch)
        dscomment  text DEFAULT NULL,                           -- comment
	dsobfuscated boolean default false,			-- fp and dir have been obfuscated
        dsparent   text DEFAULT NULL references px.datasets (dspid),
        dspositions int[] default '{0}',                        -- references px.holderpositions (hpid) -- holder positions for new shots (should be a reference)
	dseditts timestamp with time zone default now(),	-- time of last edit
	dseditnum integer default 0				-- increment each time an edit is made
);
ALTER TABLE px.datasets OWNER TO lsadmin;
CREATE INDEX dsTsIndex ON px.datasets (dscreatets);

GRANT SELECT, INSERT, UPDATE, DELETE ON px.datasets TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON px.datasets_dskey_seq TO PUBLIC;

--
-- kludge: we should have a Reference to esaf.esafs as that is what is intended
-- postgres would then automatically add the index
--
create index esaf_idx on px.datasets (dsesaf);


CREATE OR REPLACE FUNCTION px.datasetsupdatetf() returns trigger as $$
  DECLARE
    
  BEGIN
    new.dseditts = now();		-- any change updates the time stamp
    new.dseditnum = old.dseditnum+1;	-- enumerate changes
    return new;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.datasetsupdatetf() OWNER TO lsadmin;

CREATE TRIGGER datasetsUpdateTrigger BEFORE UPDATE ON px.datasets FOR EACH ROW EXECUTE PROCEDURE px.datasetsUpdateTF();


CREATE OR REPLACE FUNCTION px.next_prefix( prefix text, sample int) RETURNS text AS $$
  DECLARE
    rtn   text;
    stn   int;
    dwr   int;
    cyl   int;
    smp   int;
  BEGIN
    stn := (sample & x'ff000000'::int) >> 24;
    dwr := ((sample & x'00ff0000'::int) >> 16) - 2;             -- the "lids" are dewars 3,4,5 but the user knows them as 1,2,3
    cyl := (((sample & x'0000ff00'::int) >>  8)-1) % 3 + 1;     -- This converts the puck number stored in the ID into something the user _might_ understand
    smp := (sample & x'000000ff'::int);

    rtn := prefix || '_' || dwr || '_' || cyl || '_' || trim(to_char(smp,'00'));
    return rtn;    

  END
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.next_prefix( text, int) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.newdataset( theStn bigint, expid int) RETURNS text AS $$
--
-- used by px.login
-- called indirectly by BLUMax through px.newdataset( expid)
--
-- create a new data set with an experiment id of expid
  DECLARE
    rtn text;           -- new token
  BEGIN
    SELECT INTO rtn md5( (nextval( 'px.datasets_dskey_seq')+random())::text);
    INSERT INTO px.datasets (dspid, dsstn, dsesaf, dsdir) VALUES (rtn, theStn, expid, (select stndataroot from px.stations where stnkey=theStn));
    PERFORM px.chkdir( rtn);
    PERFORM px.mkshots( rtn);
    RETURN rtn;
  END;

$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.newdataset( bigint, int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.newdataset( expid int) RETURNS text AS $$
--
-- called from BLUMax
--
-- create a new data set with an experiment id of expid
  DECLARE
    rtn text;
  BEGIN
    SELECT INTO rtn px.newdataset( px.getstation(), expid);
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.newdataset( int ) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.copydataset( theStn bigint, token text, newDir text, newPrefix text) RETURNS text AS $$
  --
  -- Called from px.editDS
  -- and indirectly from BLUMax via px.copydataset( token, newDir, newPrefix)
  --
  -- Perhaps makes a copy of a dataset with dspid = token using the new director and prefix specified.
  -- If the directory and prefix exist already using this ESAF then the existing dataset is returned.
  --
  DECLARE
    pfx text;           -- prefix after being cleaned up
    dir text;           -- directory after being cleaned up
    rtn text;           -- new token
    theEsaf int;	-- our esaf
  BEGIN
    SELECT INTO theEsaf dsesaf FROM px.datasets WHERE dspid = token;
    SELECT INTO rtn dspid FROM px.datasets WHERE dsdir = newDir and dsfp = newPrefix and dsesaf = theEsaf;
    IF NOT FOUND THEN
      SELECT INTO rtn md5( (nextval( 'px.datasets_dskey_seq')+random())::text);
      pfx := px.fix_fn( newPrefix);
      dir := px.fix_dir( newDir);
      EXECUTE 'CREATE TEMPORARY TABLE "' || rtn || '" AS SELECT * FROM px.datasets WHERE dspid=''' || token || '''';
      EXECUTE 'UPDATE "' || rtn || '" SET dspid=''' || rtn || ''', dskey=nextval( ''px.datasets_dskey_seq''), dsfp=''' || pfx || ''', dsdir=''' || dir || ''', dsstn=' || theStn::text;
      EXECUTE 'INSERT INTO px.datasets SELECT * FROM "' || rtn || '"';
      EXECUTE 'DROP TABLE "' || rtn || '"';
    END IF;
    PERFORM px.chkdir( theStn, rtn);
    PERFORM px.mkshots( rtn);

    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.copydataset( bigint, text, text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.copydataset( token text, newDir text, newPrefix text) RETURNS text AS $$
  SELECT px.copydataset( px.getstation(), $1, $2, $3);
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.copydataset( text, text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.spawndataset( token text, sample int) RETURNS text AS $$
  --
  -- Called from px.mkshots
  --
  DECLARE
    tmp text;           -- used to see if the directory needs checking
    p  record;          -- parent datasets
    rtn text;           -- new token
  BEGIN

  SELECT dspid INTO rtn FROM px.datasets WHERE dsparent=token and dspositions=array[sample];
  IF NOT FOUND THEN
    SELECT md5( (nextval( 'px.datasets_dskey_seq')+random())::text) INTO rtn;
    EXECUTE 'CREATE TEMPORARY TABLE "' || rtn || '" AS SELECT * FROM px.datasets WHERE dspid=''' || token || '''';
    EXECUTE 'UPDATE "' || rtn || '" SET dspid=''' || rtn || ''', dskey=nextval( ''px.datasets_dskey_seq''), dsfp=px.next_prefix(dsfp,'||sample||'), dsstn=px.getstation(), dsparent='''||token||''', dspositions=''{'||sample||'}''';
    EXECUTE 'INSERT INTO px.datasets SELECT * FROM "' || rtn || '"';
    EXECUTE 'DROP TABLE "' || rtn || '"';
  END IF;

  SELECT dsdirs INTO tmp FROM px.datasets WHERE dspid = rtn;
  IF tmp != 'Valid' THEN
    PERFORM px.chkdir( rtn);
  END IF;
  PERFORM px.mkshots( rtn);

  RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.spawndataset( text, int) OWNER TO lsadmin;

--
-- getdataset returns one row for a given dataset
--
CREATE OR REPLACE FUNCTION px.getdataset( pid text) RETURNS SETOF px.datasets AS $$
  SELECT * FROM px.datasets where dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.getdataset( text) OWNER TO lsadmin;

--
-- getdatasets returns all dataset for the connecting client
--
CREATE OR REPLACE FUNCTION px.getdatasets() RETURNS SETOF px.datasets AS $$
  SELECT * FROM px.datasets where dsstn=px.getstation() order by dsfp, dscreatets DESC;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.getdatasets() OWNER TO lsadmin;


--
-- getdatasets returns all dataset for the connecting client with a given ESAF
--
CREATE OR REPLACE FUNCTION px.getdatasets( expid int) RETURNS SETOF px.datasets AS $$
  SELECT * FROM px.datasets where dsstn=px.getstation() and dsesaf=$1 order by dsfp, dscreatets DESC;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.getdatasets( int) OWNER TO lsadmin;


--
-- getdatasets returns all dataset for the selected client with a given ESAF
--
CREATE OR REPLACE FUNCTION px.getdatasets( stnkey int, expid int) RETURNS SETOF px.datasets AS $$
  SELECT * FROM px.datasets where dsstn=$1 and dsesaf=$2 order by dsfp, dscreatets DESC;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.getdatasets( int, int) OWNER TO lsadmin;

CREATE TABLE px.editDStable (
       edsKey serial primary key,	-- our key
       edsName text not null,		-- the name of the item to change
       edsFunc text not null,		-- the function to call
       edsQuotes boolean not null       -- need quotes?
);
ALTER TABLE px.editDStable OWNER TO lsadmin;

INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'dir', 'px.ds_set_dir',         true);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'fp',  'px.ds_set_fp',          true);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'start', 'px.ds_set_start',     false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'owidth', 'px.ds_set_owidth',   false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'delta', 'px.ds_set_delta',     false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'noscs', 'px.ds_set_noscs',     false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'nwedge', 'px.ds_set_nwedge',   false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'end', 'px.ds_set_end',         false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'nframes', 'px.ds_set_nframes', false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'exp', 'px.ds_set_exp',         false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'phi', 'px.ds_set_phi',         false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'omega', 'px.ds_set_omega',     false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'kappa', 'px.ds_set_kappa',     false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'dist', 'px.ds_set_dist',       false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'energy', 'px.ds_set_energy',   false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'wavelength', 'px.ds_set_wavelength', false);
INSERT INTO px.editDStable (edsName, edsFunc, edsQuotes) VALUES ( 'state', 'px.ds_set_state',     true);


CREATE OR REPLACE FUNCTION px.editDS( thePid text, theStn bigint, theKey text, theValue text) returns XML AS $$
  DECLARE
    rtn xml;
    qs text;
    thedspid text;
    eds record;
    needq boolean;	-- need quotes
    cDir text;		-- current directory
    cFp  text;		-- current file prefix
    curSam int;         -- the current sample
  BEGIN
    PERFORM 1 WHERE rmt.checkstnaccess( theStn, thePid);
    IF NOT FOUND THEN
      return xmlelement( name "editDS", xmlattributes( 'false' as success, 'access refused' as msg));
    END IF;


    SELECT dsdir, dsfp, dspid INTO cDir, cFp, thedspid FROM px.datasets LEFT JOIN px.stnstatus ON ssdsedit=dspid where ssstn=theStn LIMIT 1;

    IF theKey='dir' and theValue != cDir THEN
      SELECT px.copydataset( theStn, thedspid, theValue, cFp) INTO thedspid;
      PERFORM px.setCurrentToken( theStn, thedspid);
    END IF;

    IF theKey='fp' and theValue != cFp THEN
      SELECT px.copydataset( theStn, thedspid, cDir, theValue) INTO thedspid;
      PERFORM px.setCurrentToken( theStn, thedspid);
    END IF;

    -- Make sure we collect (only) on the current sample
    SELECT coalesce(px.getCurrentSampleID( theStn),0) INTO curSam;
    UPDATE px.datasets SET dspositions[1] = cursam WHERE dspid = thedspid;

    SELECT edsFunc, edsQuotes INTO qs, needq FROM px.editDStable WHERE edsName = theKey;
    IF NOT FOUND THEN
      return xmlelement( name "editDS", xmlattributes( 'false' as success, 'key not found' as msg));
    END IF;

    SELECT ssdsedit INTO thedspid FROM px.stnstatus WHERE ssstn=theStn;
    IF NOT FOUND THEN
      return xmlelement( name "editDS", xmlattributes( 'false' as success, 'status not found' as msg));
    END IF;

    IF theKey != 'dir' and theKey != 'fp' THEN
      IF needq THEN
       qs := qs || '(''' || thedspid || ''',''' || theValue || ''')';
      ELSE
       qs := qs || '(''' || thedspid || ''',' || theValue || ')';
      END IF;

      EXECUTE 'select ' || qs;
    END IF;

    SELECT * INTO eds FROM px.datasets WHERE dspid=thedspid;
    rtn := xmlelement( name "editDS", xmlattributes(  eds.dspid as dspid, eds.dsdir as dsdir, eds.dsdirs as dsdirs, eds.dsfp as dsfp, eds.dsstart as dsstart, eds.dsdelta as dsdelta, eds.dsowidth as dsowidth,
                            eds.dsnwedge as dsnwedge, eds.dsend as dsend, eds.dsexp as dsexp, eds.dsexpunit as dsexpunit, eds.dsphi as dsphi, eds.dsomega as dsomega, eds.dskappa as dskappa,
                            eds.dsdist as dsdist, eds.dsnrg as dsnrg, px.ds_get_nframes( eds.dspid) as nframes, eds.dseditnum as dseditnum));
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.editDS( text, bigint, text, text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.runDS( thePid text, theStn bigint, theType text) RETURNS XML AS $$
  DECLARE
    cursam int;
    thedspid text;
    theStartAngle numeric;

  BEGIN
    PERFORM 1 WHERE rmt.checkstnaccess( theStn, thePid);
    IF NOT FOUND THEN
      return xmlelement( name "runDS", xmlattributes( 'false' as success, 'access refused' as msg));
    END IF;

    -- Make sure we collect (only) on the current sample
    SELECT ssdsedit INTO thedspid FROM px.stnstatus WHERE ssstn = theStn;
    SELECT coalesce(px.getCurrentSampleID( theStn),0) INTO curSam;
    UPDATE px.datasets SET dspositions[1] = cursam WHERE dspid = thedspid;

    -- Get the start angle for snap and orthosnap
    SELECT INTO theStartAngle dsstart FROM px.datasets WHERE dspid = thedspid;

    -- Make sure we don't start up an old dataset
    PERFORM px.runqueue_clear( theStn);

    IF theType = 'snap' THEN
      PERFORM px.mksnap( theStn, ssdsedit,  theStartAngle::numeric) FROM px.stnstatus WHERE ssstn=theStn;
    END IF;
    IF theType = 'orthosnap' THEN
      PERFORM px.mkorthosnap( theStn, ssdsedit,  theStartAngle::numeric) FROM px.stnstatus WHERE ssstn=theStn;
    END IF;
    IF theType = 'norm' THEN
      PERFORM px.pushrunqueue( theStn, ssdsedit, 'normal') FROM px.stnstatus WHERE ssstn=theStn;
      PERFORM px.unpause( theStn);
    END IF;

    return xmlelement( name "runDS", xmlattributes( 'true' as success));
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.runDS( text, bigint, text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.getCurrentToken( theStn bigint) returns text AS $$
  DECLARE
    rtn text;
  BEGIN
    SELECT ssdsedit INTO rtn FROM px.stnstatus WHERE ssstn=theStn;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getCurrentToken(bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getCurrentToken() returns text AS $$
  BEGIN
    return px.getCurrentToken( px.getStation());
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getCurrentToken() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.setCurrentToken( theStn bigint, token text) returns void AS $$
  DECLARE
    rtn text;
  BEGIN
    UPDATE px.stnstatus SET ssdsedit=token WHERE ssstn=theStn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.setCurrentToken(bigint, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.setCurrentToken( token text) returns void AS $$
  BEGIN
    PERFORM px.setCurrentToken( px.getStation(), token);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.setCurrentToken( text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.getDS( thePid text, theDspid text) returns xml AS $$
  DECLARE
    rtn xml;
    esaf int;
    eds record;
    scnt int;
  BEGIN
    PERFORM 1 WHERE rmt.checkDSAccess( thePid, theDspid);
    IF NOT FOUND THEN
      return xmlelement( name "getDS",  xmlattributes( false as success, 'access denied' as msg));
    END IF;

    SELECT count(*) INTO scnt FROM px.shots WHERE sdspid=theDspid and sState='Done';
    IF NOT FOUND THEN
      scnt := 0;
    END IF;

    SELECT * INTO eds FROM px.datasets WHERE dspid=thedspid;
      rtn := xmlelement( name "editDS", xmlattributes(  eds.dspid as dspid, eds.dsdir as dsdir, eds.dsdirs as dsdirs, eds.dsfp as dsfp, eds.dsstart as dsstart, eds.dsdelta as dsdelta, eds.dsowidth as dsowidth,
                            eds.dsnwedge as dsnwedge, eds.dsend as dsend, eds.dsexp as dsexp, eds.dsexpunit as dsexpunit, eds.dsphi as dsphi, eds.dsomega as dsomega, eds.dskappa as dskappa,
                            eds.dsdist as dsdist, eds.dsnrg as dsnrg, eds.dsdonets as dsts, px.ds_get_nframes( eds.dspid) as nframes, scnt as ndone, eds.dseditnum as dseditnum));

  return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getDS( text, text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.dfpList( thePid text, theStn bigint) returns xml AS $$
  DECLARE
    dss record;
    esaf int;
    rtn xml;
    tmp xml;
  BEGIN
    PERFORM 1 WHERE rmt.checkstnaccess( theStn, thePid);
    IF NOT FOUND THEN
      return xmlelement( name "dfpList");
    END IF;

    SELECT ssesaf INTO esaf FROM px.stnstatus WHERE ssstn = theStn;
    IF NOT FOUND THEN
      return xmlelement( name "dfpList");
    END IF;
    
    FOR dss IN SELECT dspid, dsdir, dsfp, dsdonets FROM px.datasets WHERE dsstn=theStn and dsesaf=esaf and dsdonets is not null ORDER BY dsdonets desc LOOP
      PERFORM 1 FROM px.datasets WHERE dss.dsdir=dsdir and dss.dsfp=dsfp and dsdonets < dss.dsdonets;
      IF NOT FOUND THEN
        tmp := xmlconcat( tmp, xmlelement( name item, xmlattributes( dss.dspid as dspid, dss.dsdonets as dsts, dss.dsdir as dsdir, dss.dsfp as dsfp)));
      END IF;
    END LOOP;
    rtn = xmlelement( name "dfpList", tmp);
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.dfpList( text, bigint) OWNER TO lsadmin;





--
-- ESAF
CREATE OR REPLACE FUNCTION px.ds_set_esaf( token text, arg2 int) RETURNS void as $$
  BEGIN UPDATE px.datasets set dsesaf=arg2 where dspid=token; end;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_esaf( text, int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_esaf( token text) RETURNS int as $$
  SELECT dsesaf from px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_esaf( text) OWNER TO lsadmin;


--
-- Sample
CREATE OR REPLACE FUNCTION px.ds_set_sample( token text, arg2 int) RETURNS void AS $$
  BEGIN
    UPDATE px.datasets set dspositions[1]=arg2 WHERE dspid=token;
    PERFORM px.mkshots( token);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_sample( text, int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_set_samples( token text, arg2 int[]) RETURNS void AS $$
  BEGIN
    UPDATE px.datasets SET dspositions=arg2 WHERE dspid=token;
    PERFORM px.mkshots( token);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_samples( text, int[]) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_samples( token text) RETURNS setof int as $$
  DECLARE
    samples int[];  
  BEGIN
    SELECT dspositions INTO samples FROM px.datasets WHERE dspid = token;
    IF FOUND THEN
      FOR i IN array_lower( samples, 1) .. array_upper( samples, 1) LOOP
        return next samples[i];
      END LOOP;
    END IF;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_samples( text) OWNER TO lsadmin;

--
-- WHO
CREATE OR REPLACE FUNCTION px.ds_set_who( token text, arg2 bigint) RETURNS void as $$
  BEGIN UPDATE px.datasets set dswho=arg2 where dspid=token; end;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_who( text, bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_Get_who( token text) RETURNS bigint as $$
  SELECT dswho FROM  px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_Get_who( text) OWNER TO lsadmin;



--
-- INST
CREATE OR REPLACE FUNCTION px.ds_set_inst( token text, arg2 bigint) RETURNS void as $$
  BEGIN UPDATE px.datasets set dsinst=arg2 where dspid=token; end; $$
LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_inst( text, bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_inst( token text) RETURNS bigint as $$
  SELECT dsinst FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_inst( text) OWNER TO lsadmin;


--
-- DIR
CREATE OR REPLACE FUNCTION px.ds_set_dir( token text, arg2 text) RETURNS void as $$
  BEGIN
    UPDATE px.datasets set dsdir=px.fix_dir(arg2) where dspid=token;
    PERFORM px.chkdir( token);
    PERFORM px.mkshots( token);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_dir( text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_dir( token text) RETURNS text as $$
  SELECT dsdir FROM  px.datasets where dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_dir( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_set_dirs( token text, arg2 text) RETURNS void as $$
  BEGIN
    UPDATE px.datasets SET dsdirs=arg2 WHERE dspid=token;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_dirs( text, text) OWNER TO lsadmin;


--
-- File Prefix
--
CREATE OR REPLACE FUNCTION px.ds_set_fp( token text, arg2 text) RETURNS void as $$
  BEGIN
    UPDATE px.datasets SET dsfp=px.fix_fn(arg2) WHERE dspid=token;
    PERFORM px.mkshots( token);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_fp( text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_fp( token text) RETURNS text as $$
  SELECT dsfp FROM px.datasets  where dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_fp( text) OWNER TO lsadmin;


--
-- Oscaxis
--
CREATE OR REPLACE FUNCTION px.ds_set_oscaxis( token text, arg2 text) RETURNS void as $$
  BEGIN
    PERFORM akey FROM px.axes WHERE aaxis='arg2' and astn=px.getstation();
    IF FOUND THEN
      UPDATE px.datasets SET dsoscaxis=arg2 WHERE dspid=token;
      PERFORM px.mkshots( token);
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_oscaxis( text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_oscaxis( token text) RETURNS text as $$
  SELECT dsoscaxis FROM  px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_oscaxis( text) OWNER TO lsadmin;


--
-- Start
--
CREATE OR REPLACE FUNCTION px.ds_set_start( token text, arg2 numeric) RETURNS void as $$
  BEGIN
    UPDATE px.datasets set dsstart=arg2 where dspid=token;
    PERFORM px.mkshots( token);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_start( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_start( token text) RETURNS numeric as $$
  SELECT dsstart FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_start( text) OWNER TO lsadmin;


--
-- Width
--
CREATE OR REPLACE FUNCTION px.ds_set_owidth( token text, arg2 numeric) RETURNS void as $$
  BEGIN
    UPDATE px.datasets set dsowidth=arg2 where dspid=token;
    PERFORM px.mkshots( token);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_owidth( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_owidth( token text) RETURNS numeric as $$
  SELECT dsowidth FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_owidth( text) OWNER TO lsadmin;

--
-- Delta
--
CREATE OR REPLACE FUNCTION px.ds_set_delta( token text, arg2 numeric) RETURNS void as $$
  BEGIN
    UPDATE px.datasets set dsdelta=arg2  where dspid=token;
    PERFORM px.mkshots( token);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_delta( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_delta( token text) RETURNS numeric as $$
  SELECT dsdelta FROM  px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_delta( text) OWNER TO lsadmin;


--
-- N Oscs
--
CREATE OR REPLACE FUNCTION px.ds_set_noscs( token text, arg2 numeric) RETURNS void as $$
  BEGIN
    UPDATE px.datasets set dsnoscs=arg2 where dspid=token;
    PERFORM px.mkshots( token);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_noscs( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_noscs( token text) RETURNS int as $$
  SELECT dsnoscs FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_noscs( text) OWNER TO lsadmin;

--
-- Osc Sense
--
CREATE OR REPLACE FUNCTION px.ds_set_oscsense( token text, arg2 text) RETURNS void as $$
  BEGIN
    PERFORM os FROM px.oscsenses WHERE os=arg2;
    IF FOUND THEN
      UPDATE px.datasets set dsoscsense=arg2 WHERE dspid=token;
      PERFORM px.mkshots( token);
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_oscsense( text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_oscsense( token text) RETURNS text as $$
  SELECT dsoscsense FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_oscsense( text) OWNER TO lsadmin;


--
-- N Wedge
CREATE OR REPLACE FUNCTION px.ds_set_nwedge( token text, arg2 int) RETURNS void as $$
  BEGIN
    IF arg2 >= 0 THEN
      UPDATE px.datasets set dsnwedge=arg2 where dspid=token;
      PERFORM px.mkshots( token);
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_nwedge( text, int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_nwedge( token text) RETURNS int as $$
  UPDATE px.stnstatus  SET ssdsedit=$1 WHERE ssstn=px.getstation();
  SELECT dsnwedge FROM  px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_nwedge( text) OWNER TO lsadmin;

--
-- End
--
CREATE OR REPLACE FUNCTION px.ds_set_end( token text, arg2 numeric) RETURNS void as $$
  BEGIN
    UPDATE px.datasets set dsend=arg2 where dspid=token;
    PERFORM px.mkshots( token);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_end( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_end( token text) RETURNS numeric as $$
  SELECT dsend FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_end( text) OWNER TO lsadmin;

--
-- N Frames
-- This is not really a database parameter, but we treat it as one for this interface
-- Instead, we use delta and end to calculate nframes and
-- nframes and delta to calculate end
CREATE OR REPLACE FUNCTION px.ds_set_nframes( token text, nframes int) RETURNS void AS $$
  DECLARE
    ds record;  -- the dataset entry
    d  numeric;     -- our version of delta
    e  numeric;     -- new end
    
  BEGIN
    SELECT INTO ds * FROM px.datasets WHERE dspid=token;
    IF FOUND THEN
      d := abs(coalesce(ds.dsdelta, ds.dsowidth));
      IF d > 0 and ds.dsstart is not null THEN
        IF ds.dsnwedge > 0 THEN
          e := ds.dsstart + d * nframes/2;
        ELSE
          e := ds.dsstart + d * nframes;
        END IF;
        UPDATE px.datasets set dsend = e WHERE dskey=ds.dskey;
        PERFORM px.mkshots( token);
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_nframes( text, int) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.ds_get_nframes( token text) RETURNS int AS $$
  DECLARE
    rtn int;    -- the return values
    ds record;  -- the current dataset record
  BEGIN
    rtn := 0;
    SELECT INTO ds * FROM px.datasets WHERE dspid=token;
    IF FOUND THEN
      IF coalesce( ds.dsdelta, 0) > 0 THEN
        IF ds.dsnwedge > 0 THEN
          rtn := ((ds.dsend - ds.dsstart)/ds.dsdelta)::int * 2;
        ELSE
          rtn := ((ds.dsend - ds.dsstart)/ds.dsdelta)::int;
        END IF;
      END IF;
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_nframes( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_nRemaining( token text, theType text) RETURNS int AS $$
  DECLARE
    rtn int;    -- the count
  BEGIN
    SELECT INTO rtn count(*) FROM px.shots WHERE sdspid=token and stype=theType and sstate != 'Done';
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_nRemaining( text, text) OWNER TO lsadmin;

--
-- Exposure Time
--
CREATE OR REPLACE FUNCTION px.ds_set_exp( token text, arg2 numeric) RETURNS void as $$
  BEGIN
    UPDATE px.datasets set dsexp=arg2 where dspid=token;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_exp( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_exp( token text) RETURNS numeric as $$
  SELECT dsexp FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_exp( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_et( token text, type text) RETURNS interval AS $$
--
-- returns time to complete dataset or snap
-- KLUDGE: note that the overhead (1.5 seconds) is hard coded here and this is clearly a bad idea
--
  SELECT (px.ds_get_nRemaining( $1, $2) * (px.ds_get_exp( $1) + 1.5)) * interval '1 second';
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_et( text, text) OWNER TO lsadmin;


--
-- Exposure Units
--
CREATE OR REPLACE FUNCTION px.ds_set_expunit( token text, arg2 text) RETURNS void as $$
  BEGIN UPDATE px.datasets set dsexpunit=arg2 where dspid=token; end; $$
LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_expunit( text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_expunit( token text) RETURNS text as $$
  SELECT dsexpunit FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_expunit( text) OWNER TO lsadmin;

--
-- Phi
--
CREATE OR REPLACE FUNCTION px.ds_set_phi( token text, arg2 numeric) RETURNS void as $$
  BEGIN UPDATE px.datasets set dsphi=arg2 where dspid=token; end; $$
LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_phi( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_phi( token text) RETURNS numeric as $$
  SELECT dsphi FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_phi( text) OWNER TO lsadmin;

--
-- Omega
--
CREATE OR REPLACE FUNCTION px.ds_set_omega( token text, arg2 numeric) RETURNS void as $$
  BEGIN UPDATE px.datasets set dsomega=arg2 where dspid=token; end; $$
LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_omega( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_omega( token text) RETURNS numeric as $$
  SELECT dsomega FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_omega( text) OWNER TO lsadmin;

--
-- Kappa
--
CREATE OR REPLACE FUNCTION px.ds_set_kappa( token text, arg2 numeric) RETURNS void as $$
  BEGIN UPDATE px.datasets set dskappa=arg2 where dspid=token; end; $$
LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_kappa( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_kappa( token text) RETURNS numeric as $$
  SELECT dskappa FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_kappa( text) OWNER TO lsadmin;

--
-- Distance
--
CREATE OR REPLACE FUNCTION px.ds_set_dist( token text, arg2 numeric) RETURNS void as $$
  BEGIN UPDATE px.datasets set dsdist=arg2 where dspid=token; end; $$
LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_dist( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_dist( token text) RETURNS numeric as $$
  SELECT dsdist FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_dist( text) OWNER TO lsadmin;

--
-- Energy
--
CREATE OR REPLACE FUNCTION px.ds_set_energy( token text, arg2 numeric) RETURNS void as $$
  BEGIN UPDATE px.datasets set dsnrg=arg2 where dspid=token; end; $$
LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_energy( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_energy( token text) RETURNS numeric as $$
  SELECT dsnrg FROM  px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_energy( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_set_wavelength( token text, arg2 numeric) RETURNS void as $$
  UPDATE px.datasets SET dsnrg=12.3984172/$2  WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_wavelength( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_wavelength( token text) RETURNS numeric as $$
  SELECT 12.3984172/dsnrg FROM  px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_wavelength( text) OWNER TO lsadmin;

--
-- Comment
--
CREATE OR REPLACE FUNCTION px.ds_set_comment( token text, arg2 text) RETURNS void as $$
  BEGIN UPDATE px.datasets set dscomment=arg2 where dspid=token; end; $$
LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_comment( text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_comment( token text) RETURNS text as $$
  SELECT dscomment FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_comment( text) OWNER TO lsadmin;



--
-- type of shots
--
CREATE TABLE px.stypes (
        st text primary key
);
ALTER TABLE px.stypes OWNER TO lsadmin;
GRANT SELECT ON px.stypes TO PUBLIC;
INSERT INTO px.stypes (st) VALUES ('normal');
INSERT INTO px.stypes (st) VALUES ('snap');

CREATE TABLE px.shots (
        skey     serial         primary key,            -- table key
        sts     timestamp with time zone default now(), -- time of creation or last status change
        sdspid   text                                   -- PID of dataset
                references px.datasets (dspid) ON UPDATE CASCADE ON DELETE CASCADE,
        stype    text           NOT NULL                -- type of dataset this is part of (needed to uniquely identify shot)
                references px.stypes ON UPDATE CASCADE,
        sindex   int            NOT NULL,               -- frame number within this sequence
        sfn      text           DEFAULT NULL,           -- the file name
        sstart   numeric        DEFAULT NULL,           -- Starting angle:not sure what NULL would mean with soscaxis not NULL
        saxis    text           DEFAULT NULL,           -- as run data collection axis
        swidth   numeric        DEFAULT NULL,           -- as run width
        sexpt    numeric        DEFAULT NULL,           -- as run exposure time
        sexpu    text           DEFAULT NULL            -- as run exposure time
                references px.expunits (eu) ON UPDATE CASCADE,
        sphi     numeric        DEFAULT NULL,           -- as run starting phi
        somega   numeric        DEFAULT NULL,           -- as run starting omega
        skappa   numeric        DEFAULT NULL,           -- as run starting kappa
        sdist    numeric        DEFAULT NULL,           -- as run starting distance
        snrg     numeric        DEFAULT NULL,           -- as run starting energy
        scmt     text           DEFAULT NULL,           -- comment
        sstate   text                                   -- current state of the shot
                 references px.shotstates (ssstate) ON UPDATE CASCADE,
        sposition int default 0 references px.holderpositions (hpid),   -- the location of the sample holder used (0=hand mounted),
	spath    text           DEFAULT NULL,		-- the full file path used
        sbupath  text           DEFAULT NULL,           -- the full path of the backup file
	sobfuscated boolean     DEFAULT false,		-- fn, path, and bupath have been obfuscated
	stimes   int            DEFAULT 0,              -- number of times this has been run
	sfsize   int            DEFAULT NULL,           -- size of the file in bytes
	stape    boolean        DEFALUT False		-- true if file is known to be on a backup tape
        UNIQUE (sdspid, stype, sindex)
);
ALTER TABLE px.shots OWNER TO lsadmin;
CREATE INDEX shotsTsIndex ON px.shots (sts);
CREATE INDEX shotsFnIndex ON px.shots (sfn);
GRANT SELECT, INSERT, UPDATE, DELETE ON px.shots TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON px.shots_skey_seq TO PUBLIC;



CREATE OR REPLACE FUNCTION px.shots_set_params( theKey bigint, phi numeric, kappa numeric) returns void as $$
  UPDATE px.shots SET sphi=$2, skappa=$3, sdist=( SELECT dsdist FROM px.datasets WHERE dspid=sdspid) WHERE skey=$1;
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.shots_set_params( bigint, numeric, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shots_set_state( theKey bigint, newState text) returns void as $$ 
  UPDATE px.shots SET sts=now(),sstate=$2 WHERE skey=$1;
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.shots_set_state( bigint, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shots_count_done_snaps( thePid text) returns bigint as $$
  SELECT count(*) FROM px.shots WHERE sdspid=$1 AND stype='snap' AND sstate='Done';
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.shots_count_done_snaps( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shots_count_snaps( thePid text) returns bigint as $$
  SELECT count(*) FROM px.shots WHERE sdspid=$1 AND stype='snap';
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.shots_count_snaps( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shots_count_done_normals( thePid text) returns bigint as $$
  SELECT count(*) FROM px.shots WHERE sdspid=$1 AND stype='normal' AND sstate='Done';
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.shots_count_done_normals( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shots_get_esaf( theKey bigint) returns int as $$
  SELECT dsesaf FROM px.datasets LEFT JOIN px.shots on dspid=sdspid WHERE skey=$1;
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.shots_get_esaf( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shots_set_path( theKey bigint, theDir text) returns void as $$
  UPDATE px.shots SET spath=$2 WHERE skey=$1;
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.shots_set_path( bigint, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shots_set_bupath( theKey bigint, theDir text) returns void as $$
  UPDATE px.shots SET sbupath=$2 WHERE skey=$1;
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.shots_set_bupath( bigint, text) OWNER TO lsadmin;

CREATE TYPE px.shots_stats_type AS ( ntaken int, ntotal int);

CREATE OR REPLACE FUNCTION px.shots_get_snap_stats( token text) returns px.shots_stats_type as $$
  DECLARE
    rtn px.shots_stats_type;
  BEGIN
    SELECT INTO rtn.ntaken, rtn.ntotal count(*) - count( nullif( sstate, 'Done')), count(*) FROM px.shots WHERE sdspid=$1 and stype='snap';
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shots_get_snap_stats( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shots_get_normal_stats( token text) returns px.shots_stats_type as $$
  DECLARE
    rtn px.shots_stats_type;
  BEGIN
    SELECT INTO rtn.ntaken, rtn.ntotal count(*) - count( nullif( sstate, 'Done')), count(*) FROM px.shots WHERE sdspid=$1 and stype='normal';
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shots_get_normal_stats( text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.shots_set_expose( theKey int) returns void AS $$
  DECLARE
    ds record;  -- the dataset record
    token text; -- the record token
  BEGIN
    SELECT INTO token sdspid FROM px.shots WHERE skey=theKey;
    IF FOUND THEN
      SELECT INTO ds * FROM px.datasets WHERE dspid=token;
      UPDATE px.shots SET saxis=ds.dsoscaxis, swidth=ds.dsowidth, sexpt=ds.dsexp, sexpu=ds.dsexpunit, somega=ds.dsstart,sstate='Exposing' WHERE skey=theKey;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shots_set_expose( int) OWNER TO lsadmin;

CREATE TYPE px.nextshottype AS (dsdir text, dspid text, dsowidth numeric, dsoscaxis text, dsexp numeric, skey int, sstart numeric, sfn text,
        dsphi numeric, dsomega numeric, dskappa numeric, dsdist numeric, dsnrg numeric, dshpid int);

CREATE OR REPLACE FUNCTION px.nextshot() RETURNS SETOF px.nextshottype AS $$
  DECLARE
    rtn px.nextshottype;        -- the return value
    rq  record;                 -- the runqueue record at the top of the queueu
  BEGIN

   SELECT INTO rq * FROM px.runqueue WHERE rqStn=px.getStation() ORDER BY rqOrder ASC LIMIT 1;
    IF FOUND THEN
      SELECT INTO rtn dsdir, dspid, dsowidth, dsoscaxis, dsexp, skey, sstart, sfn, dsphi, dsomega, dskappa, dsdist, dsnrg, sposition
        FROM px.datasets
        LEFT JOIN  px.shots ON dspid=sdspid and stype=rq.rqType
        WHERE dspid=rq.rqToken and sstate != 'Done'
        ORDER BY sindex ASC
        LIMIT 1;
      IF NOT FOUND THEN
        PERFORM px.poprunqueue();
        SELECT INTO rtn * from px.nextshot();
        IF NOT FOUND THEN
          RETURN;
        END IF;
      END IF;
      RETURN NEXT rtn;
    END IF;
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.nextshot() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.shotsUpdateTF() RETURNS trigger AS $$
  DECLARE
  BEGIN
    IF coalesce(OLD.sbupath,'') != coalesce(NEW.sbupath,'') and NEW.sstate = 'Done' THEN
      UPDATE px.stnstatus SET ssskey = NEW.skey, sssfn = NEW.sfn, ssspath=NEW.spath, sssbupath=NEW.sbupath WHERE ssstn = px.getStation();
      INSERT INTO px.esafstatus (esskey, essfn, esspath, essbupath) VALUES (NEW.skey, NEW.sfn, NEW.spath, NEW.sbupath);
    END IF;
    IF OLD.sstate != NEW.sstate and NEW.sstate = 'Done' THEN
      PERFORM 1 FROM px.shots WHERE sdspid=NEW.sdspid and stype=NEW.stype and sstate!='Done' and sKey != NEW.sKey;
      IF NOT FOUND THEN
        PERFORM px.poprunqueue();
      END IF;
    END IF;
  RETURN NULL;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE TRIGGER shotsUpdateTrigger AFTER UPDATE ON px.shots FOR EACH ROW EXECUTE PROCEDURE px.shotsUpdateTF();

CREATE OR REPLACE FUNCTION px.shotsUpdate0TF() returns trigger AS $$
  DECLARE
  BEGIN
    IF OLD.sstate != 'Done' and NEW.sstate = 'Done' THEN
      NEW.stimes = OLD.stimes + 1;
      NEW.sts = now();
      update px.datasets set dsdonets = now() WHERE dspid=NEW.sdspid;
    END IF;
    return NEW;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shotsUpdate0TF() OWNER TO lsadmin;

CREATE TRIGGER shotsUpdate0Trigger BEFORE UPDATE ON px.shots FOR EACH ROW EXECUTE PROCEDURE px.shotsUpdate0TF();

CREATE OR REPLACE FUNCTION px.getshots( pid text, type text) RETURNS SETOF px.shots AS $$
  SELECT * FROM px.shots WHERE sdspid=$1 and stype=$2 ORDER BY sindex ASC;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.getshots( text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getshots( pid text) RETURNS SETOF px.shots AS $$
  DECLARE
    rtn record;
    childPid text;
  BEGIN
    -- is this PID a parent?
    PERFORM 1 FROM px.datasets WHERE dsparent=pid;
    IF NOT FOUND THEN
      FOR rtn IN SELECT * FROM px.shots WHERE sdspid=pid ORDER BY stype DESC, sindex ASC LOOP
        return next rtn;
      END LOOP;
    ELSE
      -- Find the first one in the run queue
      SELECT rqToken INTO childPid FROM px.runqueue LEFT JOIN px.datasets ON rqToken=dsparent WHERE rqStn=px.getStation() ORDER BY rqOrder;
      IF NOT FOUND THEN
        -- None in queue, find first with shots not taken
        SELECT dspid INTO childPid FROM px.datasets LEFT JOIN px.shots ON dspid=sdspid WHERE dsparent=pid and sstate='Not Taken' ORDER BY dskey LIMIT 1;
        IF NOT FOUND THEN
          -- OK, they are all taken, get get the last one and move on
          SELECT dspid INTO childPid FROM px.datasets WHERE dsparent=pid ORDER BY dskey DESC LIMIT 1;
        END IF;
      END IF;
      FOR rtn IN SELECT * FROM px.shots WHERE sdspid=childPid ORDER BY stype DESC, sindex ASC LOOP
        return next rtn;
      END LOOP;
    END IF;
    return;
  END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER;
ALTER FUNCTION px.getshots( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shot_set_fn( pid text, type text, i int, arg_1 text) RETURNS void AS $$
  BEGIN UPDATE px.shots SET sfn=arg_1 where sdspid=pid and stype=type and sindex=i; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shot_set_fn( text, text, int, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shot_set_start( pid text, type text, i int, arg_1 numeric) RETURNS void AS $$
  BEGIN UPDATE px.shots SET sstart=arg_1 where sdspid=pid and stype=type and sindex=i; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shot_set_start( text, text, int, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shot_set_axis( pid text, type text, i int, arg_1 text) RETURNS void AS $$
  BEGIN UPDATE px.shots SET saxis=arg_1 where sdspid=pid and stype=type and sindex=i; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shot_set_axis( text, text, int, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shot_set_width( pid text, type text, i int, arg_1 numeric) RETURNS void AS $$
  BEGIN UPDATE px.shots SET swidth=arg_1 where sdspid=pid and stype=type and sindex=i; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shot_set_width( text, text, int, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shot_set_expt( pid text, type text, i int, arg_1 numeric) RETURNS void AS $$
  BEGIN UPDATE px.shots SET sexpt=arg_1 where sdspid=pid and stype=type and sindex=i; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shot_set_expt( text, text, int, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shot_set_expu( pid text, type text, i int, arg_1 text) RETURNS void AS $$
  BEGIN UPDATE px.shots SET expu=arg_1 where sdspid=pid and stype=type and sindex=i; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shot_set_expu( text, text, int, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shot_set_phi( pid text, type text, i int, arg_1 numeric) RETURNS void AS $$
  BEGIN UPDATE px.shots SET phi=arg_1 where sdspid=pid and stype=type and sindex=i; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shot_set_phi( text, text, int, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shot_set_omega( pid text, type text, i int, arg_1 numeric) RETURNS void AS $$
  BEGIN UPDATE px.shots SET somega=arg_1 where sdspid=pid and stype=type and sindex=i; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shot_set_omega( text, text, int, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shot_set_kappa( pid text, type text, i int, arg_1 numeric) RETURNS void AS $$
  BEGIN UPDATE px.shots SET skappa=arg_1 where sdspid=pid and stype=type and sindex=i; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shot_set_kappa( text, text, int, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shot_set_dist( pid text, type text, i int, arg_1 numeric) RETURNS void AS $$
  BEGIN UPDATE px.shots SET sdist=arg_1 where sdspid=pid and stype=type and sindex=i; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shot_set_dist( text, text, int, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shot_set_energy( pid text, type text, i int, arg_1 numeric) RETURNS void AS $$
  BEGIN UPDATE px.shots SET snrg=arg_1 where sdspid=pid and stype=type and sindex=i; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shot_set_energy( text, text, int, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shot_set_comment( pid text, type text, i int, arg_1 text) RETURNS void AS $$
  BEGIN UPDATE px.shots SET scmt=arg_1 where sdspid=pid and stype=type and sindex=i; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shot_set_comment( text, text, int, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.shot_set_state( pid text, type text, i int, arg_1 text) RETURNS void AS $$
  BEGIN UPDATE px.shots SET sstate=arg_1 where sdspid=pid and stype=type and sindex=i; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.shot_set_state( text, text, int, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.startsnap( token text) RETURNS void AS $$
  DECLARE
    ntfy text;
  BEGIN
    SELECT INTO ntfy cnotifydetector FROM px._config LEFT JOIN px.stations ON cstation=stnname WHERE stnkey=px.getstation();
    EXECUTE 'NOTIFY ' || ntfy;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.startsnap( text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.retake( theKey int) RETURNS void AS $$
  DECLARE
    token text;         -- the token (for adding to queue)
    typ   text;         -- need the type to startup snaps (not normal)
  BEGIN
    SELECT INTO token,typ sdspid,stype FROM px.shots WHERE skey=theKey;
    UPDATE px.shots SET sstate='NotTaken' WHERE skey=theKey;
    PERFORM 1 from px.runqueue where rqToken=token and rqType=typ;
    IF NOT FOUND THEN
      PERFORM px.pushrunqueue( token, typ);
      PERFORM px.unpause();
    END IF;
--    IF typ = 'snap' THEN
--      PERFORM px.startrun();
--    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.retake( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.retakerest( theKey int) RETURNS void AS $$
  DECLARE
    ndx int;    -- starting index
    typ text;   -- type of shot
    token text; -- the pid
  BEGIN
    SELECT INTO ndx,typ,token sindex,stype,sdspid FROM px.shots WHERE skey=theKey;
    UPDATE px.shots SET sstate='NotTaken' WHERE sdspid=token and sindex >= ndx and stype=typ;
    PERFORM 1 from px.runqueue where rqToken=token and rqType=typ;
    IF NOT FOUND THEN
      PERFORM px.pushrunqueue( token, typ);
      PERFORM px.unpause();
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.retakerest( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.delshots( pid text, type text, starti int, endi int) RETURNS void AS $$
  DECLARE
  BEGIN
    DELETE FROM px.shots WHERE sdspid=pid and stype=type and sindex >= starti and sindex <= endi;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.delshots( text, text, int, int) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.mksnap( pid text, initialpos numeric) RETURNS void AS $$
  --
  --  fixed the ORDER BY
  --
  DECLARE
    nexti int;  -- next value of the index
    fp text;    -- file prefix
    ds record;  -- our dataset
    sample int; -- current sample number
    kidtok text; -- dspid of children

  BEGIN
    SELECT * INTO ds FROM px.datasets WHERE dspid=pid;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'token % not found', pid;
    END IF;

    IF array_lower( ds.dspositions, 1) != array_upper( ds.dspositions, 1) THEN
      -- Here we have multiple samples.  Make snaps but not for this one
      FOR kidtok IN SELECT dspid FROM px.datasets WHERE dsparent = pid ORDER BY dspositions[1] LOOP
        PERFORM px.mksnap( kidtok, initialpos);
      END LOOP;
    ELSE
      -- Here we just have one sample, use old code
      -- Need to add sposition <-----
      SELECT dsfp, coalesce( dspositions[1], 0) INTO fp, sample FROM px.datasets WHERE dspid=pid;
      SELECT coalesce(max(sindex)+1,1) INTO nexti FROM px.shots WHERE sdspid=pid and stype='snap';
      INSERT INTO px.shots (sdspid, stype, sindex, sfn, sstart, sstate, sposition) VALUES (
        pid, 'snap', nexti, fp || '_S.' || trim(to_char(nexti,'099')), initialpos, 'NotTaken', sample
      );
      PERFORM px.pushrunqueue( pid, 'snap');
      PERFORM px.unpause();
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.mksnap( text, numeric) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.mksnap( theStn bigint, pid text, initialpos numeric) RETURNS void AS $$
  DECLARE
    nexti int;  -- next value of the index
    fp text;    -- file prefix
    ds record;  -- our dataset
    sample int; -- current sample number
    kidtok text; -- dspid of children

  BEGIN
    --
    -- fixed order by
    --
    SELECT * INTO ds FROM px.datasets WHERE dspid=pid;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'token % not found', pid;
    END IF;

    IF array_lower( ds.dspositions, 1) != array_upper( ds.dspositions, 1) THEN
      -- Here we have multiple samples.  Make snaps but not for this one
      FOR kidtok IN SELECT dspid FROM px.datasets WHERE dsparent = pid ORDER BY dspositions[1] LOOP
        PERFORM px.mksnap( theStn, kidtok, initialpos);
      END LOOP;
    ELSE
      -- Here we just have one sample, use old code
      -- Need to add sposition <-----
      SELECT dsfp, coalesce( dspositions[1], 0) INTO fp, sample FROM px.datasets WHERE dspid=pid;
      SELECT coalesce(max(sindex)+1,1) INTO nexti FROM px.shots WHERE sdspid=pid and stype='snap';
      INSERT INTO px.shots (sdspid, stype, sindex, sfn, sstart, sstate, sposition) VALUES (
        pid, 'snap', nexti, fp || '_S.' || trim(to_char(nexti,'099')), initialpos, 'NotTaken', sample
      );
      PERFORM px.pushrunqueue( theStn, pid, 'snap');
      PERFORM px.unpause( theStn);
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.mksnap( bigint, text, numeric) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.mkorthosnap( pid text, initialpos numeric) RETURNS void AS $$
  BEGIN
    PERFORM px.mksnap( pid, initialpos);
    PERFORM px.mksnap( pid, initialpos+90);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.mkorthosnap( text, numeric ) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.mkorthosnap( theStn bigint, pid text, initialpos numeric) RETURNS void AS $$
  BEGIN
    PERFORM px.mksnap( theStn, pid, initialpos);
    PERFORM px.mksnap( theStn, pid, initialpos+90);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.mkorthosnap( text, numeric ) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.mkindexsnap( pid text, initialpos numeric, delta numeric, n int) RETURNS void AS $$
  BEGIN
    
    FOR i IN 0..n-1 LOOP
      PERFORM px.mksnap( pid, initialpos + i::numeric * delta);
    END LOOP;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.mkindexsnap( text, numeric, numeric, int) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.mkorthoindexsnap( pid text, initialpos numeric, delta numeric, n int) RETURNS void AS $$
  BEGIN
    
    FOR i IN 0..n-1 LOOP
      PERFORM px.mksnap( pid, initialpos + i::numeric * delta);
    END LOOP;

    FOR i IN 0..n-1 LOOP
      PERFORM px.mksnap( pid, initialpos + i::numeric * delta +90);
    END LOOP;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.mkorthoindexsnap( text, numeric, numeric, int) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.mkshots( token text) RETURNS void as $$
  DECLARE
    nframes int;                -- number of frames (1/2 # frames if wedges)
    newend  numeric;            -- caluculated end point
    sk      int;                -- the station key
    pid     text;               -- pid for shots/dataset
    fp      text;               -- the file prefix (already entered)
    fn      text;               -- the filename
    angle   numeric;            -- calculated diffraction angle
    delta   numeric;            -- difference between starting angles of adjacent frames
    n       int;                -- loop counter for wedge collection
    wnn     int;                -- loop counter for wedge name
    an      int;                -- counter for wedge collection used for angle calculation
    oldcnt  int;                -- count of old frames in this dataset
    ds      record;             -- dataset definition
    fmt     text;               -- format string for frame numbers
    sample  int;                -- current sample number
    kidtok  text;               -- dspid of children: used to find and kill orphans
    kidsample int;              -- dsposition[1] of children: used to find and kill orphans

  BEGIN

    SELECT * INTO ds from px.datasets where dspid=token;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'token % not found', token;
    END IF;

    IF array_lower( ds.dspositions, 1) != array_upper( ds.dspositions, 1) THEN
        -- Here we have more than one sample.   Make shots for each but not for this one
        FOR kidtok, kidsample IN SELECT dspid,dspositions[1] FROM px.datasets WHERE dsparent = token LOOP
          -- Delete children that are no longer in the parent's list of children
          IF not (kidsample = any( ds.dspositions)) THEN
            -- Only delete shots that are not taken
            DELETE FROM px.shots WHERE sdspid=kidtok and sstate != 'Done';
            -- See if any shots left
            PERFORM 1 FROM px.shots WHERE sdspid=kidtok;
            IF NOT FOUND THEN
              -- None found, also delete the dataset
              DELETE FROM px.datasets WHERE dspid = kidtok;
            ELSE
              UPDATE px.datasets SET dsparent=NULL WHERE dspid=kidtok;
            END IF;
          END IF;
        END LOOP;
        --
        -- Delete untaken parent shots
        DELETE FROM px.shots WHERE sdspid=token and sstate != 'Done';

        --
        -- Change everything to match the parent except dsfn, dspid, and dspositions
        UPDATE px.datasets SET
          dsesaf = ds.dsesaf, dsdir = ds.dsdir, dsdirs = ds.dsdirs, dsstn = ds.dsstn, dsoscaxis = ds.dsoscaxis,
          dsowidth = ds.dsowidth, dsnoscs = ds.dsnoscs, dsoscsense = ds.dsoscsense, dsnwedge = ds.dsnwedge,
          dsend = ds.dsend, dsexp = ds.dsexp, dsexpunit = ds.dsexpunit, dsphi = ds.dsphi, dsomega = ds.dsomega,
          dskappa = ds.dskappa, dsdist = ds.dsdist, dsnrg = ds.dsnrg, dscomment = ds.dscomment
          WHERE dsparent = token;

        --
        -- Create additional children data sets and make shots (via spawn)
        FOR i IN array_lower( ds.dspositions, 1) .. array_upper( ds.dspositions, 1) LOOP
          sample := ds.dspositions[i];
          PERFORM px.spawndataset( token, sample);
        END LOOP;


    ELSE
      -- Here we have only one sample.  Just make the shots.
      sample := ds.dspositions[1];

      -- But first take care of the case where this dataset used to be a parent
      FOR pid IN SELECT dspid FROM px.datasets WHERE dsparent = token LOOP
        DELETE FROM px.shots WHERE sdspid=pid AND sstate != 'Done';
        PERFORM 1 FROM px.shots WHERE sdspid=pid;
        IF FOUND THEN
          DELETE FROM px.datasets WHERE dspid=pid;
        ELSE
          UPDATE px.datasets SET dsparent=NULL WHERE dspid=pid;
        END IF;
      END LOOP;

      --
      -- get file prefix
      --
      fp := ds.dsfp;
    
      --
      -- Delete untaken frames
      PERFORM 1 FROM px.nextshot() WHERE dspid=token;
      IF FOUND THEN
        DELETE FROM px.shots WHERE sstate = 'NotTaken' and sdspid=token;
      ELSE
        DELETE FROM px.shots WHERE sstate != 'Done' and sdspid=token;
      END IF;
    
      --
      -- calculate delta and number of frames
      --
      delta := ds.dsdelta;
      IF ds.dsend = ds.dsstart+ds.dsowidth THEN
        delta = ds.dsowidth;
        nframes = 1;
      ELSE
        IF delta=0 THEN
          delta := ds.dsowidth;
        END IF;
        IF delta = 0 THEN
          RAISE EXCEPTION 'delta not given and cannot be calculated';
        END IF;
        nframes := CAST((ds.dsend-ds.dsstart)/delta AS int);
      END IF;
    
      UPDATE px.datasets set dsend=ds.dsstart+delta*nframes WHERE dspid=token;
      SELECT INTO ds.dsend dsend FROM px.datasets WHERE dspid=token;
    
      --
      -- set the format for the frame numbers
      -- not general but it is unlikely we'll need to worry about 10,000 or more for a while
      fmt := '099';
      if nframes > 999 THEN
        fmt := '0999';
      END IF;
    
      IF ds.dsnwedge = 0 THEN
        FOR i IN 1..nframes LOOP
          PERFORM skey FROM px.shots WHERE sdspid=token and sindex=i and stype='normal';
          IF NOT FOUND THEN
            fn := fp || '.' || trim(to_char(i, fmt));
            angle := ds.dsstart + (i-1) * delta;
          INSERT INTO px.shots ( sdspid, stype, sfn, sstart, sindex, sstate, sposition) VALUES (
              token,        -- sdspid
              'normal',     -- stype
              fn,           -- sfn
              angle,        -- sstart
              i,            -- sindex
              'NotTaken',   -- sstate
              sample        -- the sample
          );
          END IF;
        END LOOP;
      ELSE
        wnn := 0;
        n   := 0;
        an  := 0;
        WHILE n < 2*nframes LOOP
          FOR i IN 1..ds.dsnwedge LOOP
            PERFORM skey FROM px.shots WHERE sdspid=token and sindex=n+i and stype='normal';
            IF NOT FOUND THEN
              fn := fp || '_' || 'A' || '.' || trim( to_char( wnn+i, fmt));
              angle := ds.dsstart + (an+i-1) * delta;
              INSERT INTO px.shots ( sdspid, stype, sfn, sstart, sindex, sstate, sposition) VALUES (
                token,          -- sdspid
                'normal',       -- stype
                fn,             -- sfn
                angle,          -- sstart
                n+i,            -- sindex
                'NotTaken',     -- sstate
                sample          -- the sample
              );
            END IF;
        END LOOP;
          FOR i IN 1..ds.dsnwedge LOOP
            PERFORM skey FROM px.shots WHERE sdspid=token and sindex=n+ds.dsnwedge+i and stype='normal';
            IF NOT FOUND THEN
              fn := fp || '_' || 'B' || '.' || trim( to_char( wnn+i, fmt));
              angle := ds.dsstart + (an+i-1) * delta + 180;
              INSERT INTO px.shots ( sdspid, stype, sfn, sstart, sindex, sstate, sposition) VALUES (
                token,             -- sdspid
                'normal',          -- stype
                fn,                -- sfn
                angle,             -- sstart
                n+ds.dsnwedge+i,   -- sindex
                'NotTaken',        -- sstate
                sample             -- the sample
              );
            END IF;
        END LOOP;
          n   := n   + 2*ds.dsnwedge;
          an  := an  + ds.dsnwedge;
          wnn := wnn + ds.dsnwedge;
        END LOOP;
      END IF;
    END IF;
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.mkshots( text) OWNER TO lsadmin;

CREATE TABLE px.pauseStates (
       pss text primary key
);
ALTER TABLE px.pauseStates OWNER TO lsadmin;
INSERT INTO px.pauseStates (pss) values ('Please Pause');       -- request that the data collection pause
INSERT INTO px.pauseStates (pss) values ('I Paused');           -- Notification that the data collection has paused
INSERT INTO px.pauseStates (pss) values ('Not Paused');         -- We are not paused right now

CREATE TABLE px.pause (
       pKey serial primary key,                         -- our primary key
       ptc timestamp with time zone default now(),      -- when the state was requested
       pStn int references px.stations (stnkey),        -- the station we are pausing for
       pps  text references px.pauseStates (pss)        -- the actual request
);
ALTER TABLE px.pause OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.pauseUpdateTF()  returns trigger AS $$
  DECLARE
  BEGIN
    UPDATE px.stnstatus SET sspaused = (NEW.pps != 'Not Paused') WHERE ssstn=NEW.pstn;
    return NEW;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.pauseUpdateTF() OWNER TO lsadmin;

CREATE TRIGGER paused_trigger BEFORE UPDATE ON px.pause FOR EACH ROW EXECUTE PROCEDURE px.pauseUpdateTF();

CREATE OR REPLACE FUNCTION px.ispaused() RETURNS boolean AS $$
  SELECT pps != 'Not Paused' FROM px.pause WHERE pStn = px.getstation();
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ispaused() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ispausedi() RETURNS int AS $$
  SELECT case when pps != 'Not Paused' then 1 else 0 end FROM px.pause WHERE pStn = px.getstation();
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ispausedi() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.pauseRequest() RETURNS VOID AS $$
  DECLARE
    ntfy text;
  BEGIN
    PERFORM 1 FROM px.pause where pStn=px.getstation();
    IF FOUND THEN
      UPDATE px.pause set ptc=now(), pps='Please Pause' where pStn=px.getStation();
    ELSE
      INSERT INTO px.pause (ptc,pStn,pps) VALUES (now(),px.getStation(),'Please Pause');
    END IF;
    SELECT INTO ntfy cnotifypause FROM px._config LEFT JOIN px.stations ON cstation=stnname WHERE stnkey=px.getstation();
    EXECUTE 'NOTIFY ' || ntfy;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.pauseRequest() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.pauseRequest( theStn bigint) RETURNS VOID AS $$
  DECLARE
    ntfy text;
  BEGIN
    PERFORM 1 FROM px.pause where pStn=theStn;
    IF FOUND THEN
      UPDATE px.pause set ptc=now(), pps='Please Pause' where pStn=theStn;
    ELSE
      INSERT INTO px.pause (ptc,pStn,pps) VALUES (now(),theStn,'Please Pause');
    END IF;
    SELECT INTO ntfy cnotifypause FROM px._config LEFT JOIN px.stations ON cstation=stnname WHERE stnkey=theStn;
    EXECUTE 'NOTIFY ' || ntfy;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.pauseRequest( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.pauseTell() RETURNS VOID AS $$
  DECLARE
  BEGIN
    PERFORM 1 FROM px.pause where pStn=px.getstation();
    IF FOUND THEN
      UPDATE px.pause set ptc=now(), pps='I Paused' where pStn=px.getStation();
    ELSE
      INSERT INTO px.pause (ptc,pStn,pps) VALUES (now(),px.getStation(),'I Paused');
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.pauseTell() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.unpause() RETURNS VOID AS $$
  DECLARE
  BEGIN
    PERFORM 1 FROM px.pause where pStn=px.getstation();
    IF FOUND THEN
      UPDATE px.pause set ptc=now(), pps='Not Paused' where pStn=px.getStation();
    ELSE
      INSERT INTO px.pause (ptc,pStn,pps) VALUES (now(),px.getStation(),'Not Paused');
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.unpause() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.unpause( stn bigint) RETURNS VOID AS $$
  DECLARE
  BEGIN
    PERFORM 1 FROM px.pause where pStn=stn;
    IF FOUND THEN
      UPDATE px.pause set ptc=now(), pps='Not Paused' where pStn=stn;
    ELSE
      INSERT INTO px.pause (ptc,pStn,pps) VALUES (now(), stn,'Not Paused');
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.unpause( bigint) OWNER TO lsadmin;


CREATE TABLE px.runqueue (
    rqKey serial primary key,                           -- table key
    rqStn int references px.stations (stnkey),          -- station queue
    rqCTS timestamp with time zone default now(),       -- creatation time stamp
    rqOrder int not null,                       -- order to be taken
    rqToken text not null                               -- dataset
        references px.datasets (dspid) on update cascade,
    rqType  text not null                               -- type of frame to run
        references px.stypes (st) on update cascade,
    UNIQUE (rqStn, rqOrder)
);
ALTER TABLE px.runqueue OWNER TO lsadmin;
--GRANT SELECT, INSERT, UPDATE, DELETE ON px.runqueue TO PUBLIC;

CREATE OR REPLACE FUNCTION px.runqueue_delete_tf() RETURNS trigger AS $$
  DECLARE
    theStn bigint;
  BEGIN
    theStn := px.getStation();

    PERFORM 1 FROM px.runqueue WHERE rqStn=theStn;
    IF NOT FOUND and theStn is not null THEN
      PERFORM px.unpause();
    END IF;
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.runqueue_delete_tf() OWNER TO lsadmin;

CREATE TRIGGER runqueue_delete_trigger AFTER DELETE ON px.runqueue FOR EACH STATEMENT EXECUTE PROCEDURE px.runqueue_delete_tf();

CREATE OR REPLACE FUNCTION px.pushrunqueue( token text, stype text) RETURNS void AS $$
  DECLARE
    samples int[];      -- Array of samples in the dataset
    pid text;           -- dspid from a child
  BEGIN
    SELECT dspositions INTO samples FROM px.datasets WHERE dspid=token;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'token % not found', token;
    END IF;

    IF array_lower( samples, 1) != array_upper( samples, 1) THEN
      FOR pid IN SELECT dspid FROM px.datasets WHERE dsparent=token ORDER BY dspositions[1] LOOP
        PERFORM px.pushrunqueue( pid, stype);
      END LOOP;
    ELSE
      PERFORM dskey FROM px.datasets WHERE dspid=token and dsdirs='Valid';
      IF FOUND THEN
        PERFORM 1 from px.runqueue where rqToken=token and rqType=stype;
        IF NOT FOUND THEN
          INSERT INTO px.runqueue (rqStn, rqToken, rqType, rqOrder) VALUES ( px.getstation(), token, stype, (SELECT coalesce(max(rqOrder),0)+1 FROM px.runqueue WHERE rqStn=px.getStation()));
          PERFORM 1 FROM px.pause WHERE pStn=px.getstation() and pps='Not Paused';
          IF FOUND THEN
            PERFORM px.startrun();
          END IF;
        END IF;
      ELSE
        PERFORM px.pusherror( 20001, 'Directory ' || dsdir || ' not proven valid') FROM px.datasets WHERE dsdir=token;
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.pushrunqueue( text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.pushrunqueue( theStn bigint, token text, stype text) RETURNS void AS $$
  --
  -- a version without assuming we know where we are
  --
  DECLARE
    samples int[];      -- Array of samples in the dataset
    pid text;           -- dspid from a child
  BEGIN
    SELECT dspositions INTO samples FROM px.datasets WHERE dspid=token;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'token % not found', token;
    END IF;

    IF array_lower( samples, 1) != array_upper( samples, 1) THEN
      FOR pid IN SELECT dspid FROM px.datasets WHERE dsparent=token ORDER BY dspositions[1] LOOP
        PERFORM px.pushrunqueue( theStn, pid, stype);
      END LOOP;
    ELSE
      PERFORM dskey FROM px.datasets WHERE dspid=token and dsdirs='Valid';
      IF FOUND THEN
        PERFORM 1 from px.runqueue where rqToken=token and rqType=stype;
        IF NOT FOUND THEN
          INSERT INTO px.runqueue (rqStn, rqToken, rqType, rqOrder) VALUES ( theStn, token, stype, (SELECT coalesce(max(rqOrder),0)+1 FROM px.runqueue WHERE rqStn=theStn));
          PERFORM 1 FROM px.pause WHERE pStn=theStn and pps='Not Paused';
          IF FOUND THEN
            PERFORM px.startrun( theStn);
          END IF;
        END IF;
      ELSE
        PERFORM px.pusherror( 20001, 'Directory ' || dsdir || ' not proven valid') FROM px.datasets WHERE dsdir=token;
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.pushrunqueue( bigint, text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.runqueue_up( theKey bigint) RETURNS void AS $$
--
-- Move item up the runqueue (lower its order) by swapping with the next lower one
--
  DECLARE
    a   record; -- entry of the one we'd like to move
  BEGIN
    SELECT INTO a * FROM px.runqueue WHERE rqKey=theKey and rqStn = px.getStation();
    IF FOUND and a.rqOrder>1 THEN
      UPDATE px.runqueue SET rqOrder=(SELECT max(rqOrder)+1 FROM px.runqueue WHERE rqStn=px.getStation())  WHERE rqKey=a.rqKey;
      UPDATE px.runqueue SET rqOrder=a.rqOrder   WHERE rqOrder = a.rqOrder-1 and rqStn=px.getStation();
      UPDATE px.runqueue SET rqOrder=a.rqOrder-1 WHERE rqKey=a.rqKey;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.runqueue_up( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.runqueue_down( theKey bigint) RETURNS void AS $$
--
-- Move item down the runqueue (raise its order) by swapping with the next higher one
--
  DECLARE
    mx  int;    -- maximum value of the run queue order
    a   record; -- the record we'd like to move
  BEGIN
    SELECT INTO mx max(rqOrder) FROM px.runqueue WHERE rqStn=px.getStation();
    SELECT INTO a * FROM px.runqueue WHERE rqKey=theKey;
    IF FOUND and a.rqOrder < mx THEN
      UPDATE px.runqueue SET rqOrder=(SELECT max(rqOrder)+1 FROM px.runqueue WHERE rqStn=px.getStation())  WHERE rqKey=a.rqKey;
      UPDATE px.runqueue SET rqOrder=a.rqOrder   WHERE rqOrder = a.rqOrder+1 and rqStn=px.getStation();
      UPDATE px.runqueue SET rqOrder=a.rqOrder+1 WHERE rqKey=a.rqKey;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.runqueue_down( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.runqueue_top( theKey bigint) RETURNS void AS $$
--
-- Move item to the top of the runqueue
--
  DECLARE
    k bigint;  -- key in reorder loop
    i int;     -- value for the order in loop
    cv int;    -- current value of theKey's order
  BEGIN
    SELECT rqOrder INTO cv FROM px.runqueue WHERE rqKey=theKey;
    IF FOUND THEN
      UPDATE px.runqueue SET rqOrder=0 WHERE rqKey=theKey;	-- temporarly make 0 so we do not violate uniqueness in loop
      i := cv;
      -- Only loop over items above the one we are moving
      FOR k IN SELECT rqKey FROM px.runqueue WHERE rqStn=px.getStation() and rqOrder<cv and rqKey!= theKey ORDER BY rqOrder desc LOOP
        UPDATE px.runqueue SET rqOrder = i WHERE rqKey=k;
        i := i-1;
      END LOOP;
      UPDATE px.runqueue SET rqOrder=1 WHERE rqKey=theKey;	-- Now we can put it at the top of the list
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.runqueue_top( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.runqueue_bottom( theKey bigint) RETURNS void AS $$
--
-- Move item to the bottom of the runqueue
--
  DECLARE
    k bigint;  -- key in reorder loop
    i int;     -- value for the order in loop
    cv int;    -- current value of theKey's order
    mx int;    -- maximum value in the list (our new order)
  BEGIN
    SELECT rqOrder INTO cv FROM px.runqueue WHERE rqKey=theKey;
    IF FOUND THEN
      SELECT max(rqOrder) INTO mx FROM px.runqueue WHERE rqStn=px.getStation();

      UPDATE px.runqueue SET rqOrder=0 WHERE rqKey=theKey;	-- temporarly make 0 so we do not violate uniqueness in loop
      i := cv;
      -- Only loop over items above the one we are moving
      FOR k IN SELECT rqKey FROM px.runqueue WHERE rqStn=px.getStation() and rqOrder>cv ORDER BY rqOrder asc LOOP
        UPDATE px.runqueue SET rqOrder = i WHERE rqKey=k;
        i := i+1;
      END LOOP;
      UPDATE px.runqueue SET rqOrder=mx WHERE rqKey=theKey;	-- Now we can put it at the top of the list
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.runqueue_bottom( bigint) OWNER TO lsadmin;



CREATE TYPE px.runqueuetype AS ( dspid text, type text, k bigint, etc text);

CREATE OR REPLACE FUNCTION px.runqueue_get() returns SETOF px.runqueuetype AS $$
  DECLARE
    rtn px.runqueuetype;                -- the return value
    rq record;                          -- the runqueue entry
    startTime timestamp with time zone; -- start time of next dataset
    deltaTime interval;                 -- estimated time for this dataset
  BEGIN
    startTime := now();
    FOR rq IN SELECT * FROM px.runqueue WHERE rqStn=px.getStation() ORDER BY rqOrder LOOP
      deltaTime := px.ds_get_et( rq.rqToken, rq.rqType);
      startTime := startTime + deltaTime;
      rtn.etc   := to_char( startTime, 'HH24:MI');
      rtn.dspid := rq.rqToken;
      rtn.type  := rq.rqType;
      rtn.k     := rq.rqKey;
      RETURN NEXT rtn;
    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.runqueue_get() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.runqueue_get( theStn bigint) returns SETOF px.runqueuetype AS $$
  DECLARE
    rtn px.runqueuetype;                -- the return value
    rq record;                          -- the runqueue entry
    startTime timestamp with time zone; -- start time of next dataset
    deltaTime interval;                 -- estimated time for this dataset
  BEGIN
    startTime := now();
    FOR rq IN SELECT * FROM px.runqueue WHERE rqStn=theStn ORDER BY rqOrder LOOP
      deltaTime := px.ds_get_et( rq.rqToken, rq.rqType);
      startTime := startTime + deltaTime;
      rtn.etc   := to_char( startTime, 'HH24:MI');
      rtn.dspid := rq.rqToken;
      rtn.type  := rq.rqType;
      rtn.k     := rq.rqKey;
      RETURN NEXT rtn;
    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.runqueue_get( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.runqueue_get_xml( thePid text, theStn bigint) returns xml AS $$
  DECLARE
    rq record;
    tmp xml;
    tmp2 xml;
    rtn xml;
    startTime timestamp with time zone;
  BEGIN
    PERFORM 1 WHERE rmt.checkstnaccess( theStn, thePid);
    IF FOUND THEN
      startTime := now();

      FOR rq IN SELECT rqtoken, rqtype, dsfp, px.ds_get_et( rqtoken, rqtype) as deltaTime, count(*) as total, count(*)-count(nullif(sstate,'Done')) as done
            FROM px.runqueue
            LEFT JOIN px.datasets on rqtoken=dspid
            LEFT JOIN px.shots on rqtoken=sdspid
            WHERE rqStn=theStn
            GROUP BY rqtoken, rqtype, dsfp, et
            ORDER BY rqOrder
            LOOP

        startTime := startTime + rq.deltaTime;
	tmp = xmlconcat( tmp, xmlelement( name dataset, xmlattributes( rq.rqtoken as dspid, rq.rqtype as "type", rq.dsfp as dsfp, t
        tmp = xmlconcat( tmp, xmlelement( name dataset, xmlattributes( rq.dspid as dspid, rq.type as "type", rq.k as k, rq.etc as etc)));
      END LOOP;
      rtn = xmlelement( name runqueue, xmlattributes( 'true' as success), tmp);
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.runqueue_get_xml( text, bigint) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.runqueue_remove( k bigint) RETURNS void AS $$
  DECLARE
    ordr int;   -- the order of the item we are removing
    kk bigint;   -- key of item to reorder
 BEGIN
    SELECT INTO ordr rqOrder FROM px.runqueue WHERE rqKey=k and rqStn=px.getStation();
    DELETE FROM px.runqueue WHERE rqKey=k and rqStn=px.getStation();
    FOR kk IN SELECT rqKey FROM px.runqueue WHERE rqStn=px.getStation() and rqOrder > ordr ORDER BY rqOrder asc LOOP
      UPDATE px.runqueue SET rqOrder=rqOrder-1 WHERE rqKey=kk;
    END LOOP;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.runqueue_remove( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.runqueue_clear( theStn bigint) RETURNS void AS $$
  DECLARE
  BEGIN
    DELETE FROM px.runqueue WHERE rqStn=theStn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.runqueue_clear( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.runqueuecount() RETURNS int AS $$
  SELECT count(*)::int FROM px.runqueue WHERE rqStn=px.getstation();
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.runqueuecount() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getrunqueuetype() RETURNS text AS $$
  SELECT coalesce(rqType,'') FROM px.runqueue WHERE rqStn=px.getstation() ORDER BY rqCTS ASC limit 1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.getrunqueuetype() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.poprunqueue() RETURNS void AS $$
  --
  -- Remove the top item in the run queue and reorder it
  -- Also, add requestTransfer(0) to dismount the last sample in a multi sample data collection
  --
  DECLARE
    curParent text;  -- the parent of the current dataset
    curKey    bigint; -- the key of the current dataset
    rq record;  -- records to update
    i  int;     -- welecome to the new order
  BEGIN
    --  get the current parent and the current key
    SELECT rqKey, dsparent INTO curKey, curParent FROM px.runqueue LEFT JOIN px.datasets ON rqtoken=dspid WHERE rqStn=px.getstation() ORDER BY rqOrder ASC limit 1;
    IF NOT FOUND THEN
      return;
    END IF;

    DELETE FROM px.runqueue WHERE rqKey = curKey;
    i := 1;
    FOR rq IN SELECT * FROM px.runqueue WHERE rqStn=px.getstation() ORDER BY rqOrder ASC LOOP
      UPDATE px.runqueue set rqOrder=i WHERE rqKey=rq.rqKey;
      i := i+1;
    END LOOP;
    
    -- If this was a robot mounted sample part of a multiple select
    -- and no more multiple selects exist in the runqueue then add a
    -- "transfer 0" command to the md2 queue to dismount the sample at
    -- the end

    IF curParent is not NULL THEN
      -- see if any other children remain
      PERFORM 1 FROM px.runqueue LEFT JOIN px.datasets ON rqtoken=dspid WHERE rqStn=px.getstation() and dsparent is not null;
      IF NOT FOUND THEN
      --        PERFORM px.requestTransfer( 0);
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.poprunqueue() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.clearrunqueue() RETURNS void AS $$
  DELETE FROM px.runqueue WHERE rqStn = px.getstation();
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.clearrunqueue() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.startrun() returns void AS $$
  DECLARE
    nt text;    -- notify condition
  BEGIN
    SELECT INTO nt cnotifyrun FROM px._config left join px.stations on stnname=cstation WHERE stnkey=px.getstation();
    IF FOUND THEN
      UPDATE px.pause SET ptc=now(), pps='Not Paused' WHERE pStn=px.getStation();
      EXECUTE 'NOTIFY ' || nt;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.startrun() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.startrun( theStn bigint) returns void AS $$
  DECLARE
    nt text;    -- notify condition
  BEGIN
    SELECT INTO nt cnotifyrun FROM px._config left join px.stations on stnname=cstation WHERE stnkey=theStn;
    IF FOUND THEN
      UPDATE px.pause SET ptc=now(), pps='Not Paused' WHERE pStn=theStn;
      EXECUTE 'NOTIFY ' || nt;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.startrun( bigint) OWNER TO lsadmin;



CREATE TABLE px.epicsLink (
--
-- Table to link motors and stuff
--
        elKey  serial primary key,              -- table key
        elStn  bigint default NULL              -- station
                references px.stations (stnkey),        
        elName text NOT NULL,                   -- our name for this variable
        elPV   text NOT NULL
                references epics._motions (mMotorPvName) ON UPDATE CASCADE
);
ALTER TABLE px.epicsLink OWNER TO lsadmin;

INSERT INTO px.epicsLink (elStn, elName, elPV) VALUES ( (select stnKey from px.stations where stnname='21-ID-G'), 'distance', '21:G1:DT:D');
INSERT INTO px.epicsLink (elStn, elName, elPV) VALUES ( (select stnKey from px.stations where stnname='21-ID-F'), 'distance', '21:F1:DT:D');

CREATE TABLE px.epicsPVMLink (
--
-- Table to link motors and stuff
--
        epvmlKey  serial primary key,           -- table key
        epvmlStn  bigint default NULL           -- station
                references px.stations (stnkey),        
        epvmlName text NOT NULL,                        -- our name for this variable
        epvmlPV   text NOT NULL
                references epics._pvmonitors (pvmName) ON UPDATE CASCADE
);
ALTER TABLE px.epicsPVMLink OWNER TO lsadmin;

INSERT INTO px.epicsPVMLink (epvmlStn, epvmlName, epvmlPV) VALUES ( (select stnKey from px.stations where stnname='21-ID-F'), 'Io', '21:F1:scaler1_cts3.A');
INSERT INTO px.epicsPVMLink (epvmlStn, epvmlName, epvmlPV) VALUES ( (select stnKey from px.stations where stnname='21-ID-G'), 'Io', '21:G1:scaler1_cts3.A');

INSERT INTO px.epicsPVMLink (epvmlStn, epvmlName, epvmlPV) VALUES ( (select stnKey from px.stations where stnname='21-ID-D'), 'Search', 'PA:21ID:OA_STA_D_VOICE_1');
INSERT INTO px.epicsPVMLink (epvmlStn, epvmlName, epvmlPV) VALUES ( (select stnKey from px.stations where stnname='21-ID-E'), 'Search', 'PA:21ID:OA_STA_DE_E_VOICE_1');
INSERT INTO px.epicsPVMLink (epvmlStn, epvmlName, epvmlPV) VALUES ( (select stnKey from px.stations where stnname='21-ID-F'), 'Search', 'PA:21ID:OA_STA_F_VOICE_1');
INSERT INTO px.epicsPVMLink (epvmlStn, epvmlName, epvmlPV) VALUES ( (select stnKey from px.stations where stnname='21-ID-G'), 'Search', 'PA:21ID:OA_STA_FG_G_VOICE_1');

INSERT INTO px.epicsPVMLink (epvmlStn, epvmlName, epvmlPV) VALUES ( (select stnKey from px.stations where stnname='21-ID-D'), 'Door', 'PA:21ID:IA_STA_D_DR2_CLOS');
INSERT INTO px.epicsPVMLink (epvmlStn, epvmlName, epvmlPV) VALUES ( (select stnKey from px.stations where stnname='21-ID-E'), 'Door', 'PA:21ID:IA_STA_E_DR1_CLOS');
INSERT INTO px.epicsPVMLink (epvmlStn, epvmlName, epvmlPV) VALUES ( (select stnKey from px.stations where stnname='21-ID-F'), 'Door', 'PA:21ID:IA_STA_F_DR2_CLOS');
INSERT INTO px.epicsPVMLink (epvmlStn, epvmlName, epvmlPV) VALUES ( (select stnKey from px.stations where stnname='21-ID-G'), 'Door', 'PA:21ID:IA_STA_G_DR1_CLOS');


CREATE OR REPLACE FUNCTION px.isthere( motion text, value numeric) RETURNS boolean AS $$
  DECLARE
    stopped boolean;
    rtn boolean;
  BEGIN
    SELECT epics.isthere( elPV, value) INTO rtn FROM px.epicsLink WHERE elStn=px.getStation() and elName=motion;
    IF NOT rtn THEN
      SELECT px.isstopped( motion) INTO stopped;
      IF stopped THEN
        PERFORM px.moveit( motion, value);
      END IF;
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.isthere( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.isthere( motion text) RETURNS boolean AS $$
  DECLARE
    rtn boolean;
  BEGIN
    SELECT epics.isthere( elPV) INTO rtn FROM px.epicsLink WHERE elStn=px.getstation() and elName=motion;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.isthere( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.isstopped( motion text) RETURNS boolean AS $$
  DECLARE
    rtn boolean;
  BEGIN
    rtn = NULL;
    SELECT epics.isstopped( elPV) INTO rtn FROM px.epicsLink WHERE elName=motion and elStn=px.getStation()::bigint;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.isstopped( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.moveit( motion text, value numeric) RETURNS VOID AS $$
  DECLARE
  BEGIN
  -- PERFORM px.isthere( motion, value);
   PERFORM epics.moveit( elPV, value) FROM px.epicsLink WHERE elName=motion and elStn=px.getStation();
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.moveit( text, numeric) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.rt_get_bcx() returns text as $$
  DECLARE
    rtn text;
  BEGIN
    SELECT epics.caget( epvmlpv) INTO rtn FROM px.epicspvmlink WHERE epvmlname='bcx' and epvmlstn=px.getStation();
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_bcx() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_get_bcy() returns text as $$
  DECLARE
    rtn text;
  BEGIN
    SELECT epics.caget( epvmlpv) INTO rtn FROM px.epicspvmlink WHERE epvmlname='bcy' and epvmlstn=px.getStation();
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_bcy() OWNER TO lsadmin;



CREATE OR REPLACE FUNCTION px.rt_get_dist() returns text AS $$
  DECLARE
    rtn text;   -- return value
  BEGIN
    -- SELECT INTO rtn to_char( mactpos, '9999.9') FROM epics.motions LEFT JOIN  px.epicsLink ON elPV=mmotorpvname WHERE elStn=px.getstation() and elName='distance';
    SELECT INTO rtn to_char( epics.position(elPV)::numeric, '9999.9') FROM px.epicsLink WHERE elStn=px.getstation() and elName='distance';
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_dist() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_get_dist( stn bigint) returns text AS $$
  DECLARE
    rtn text;   -- return value
  BEGIN
    -- SELECT INTO rtn to_char( mactpos, '9999.9') FROM epics.motions LEFT JOIN  px.epicsLink ON elPV=mmotorpvname WHERE elStn=px.getstation() and elName='distance';
    SELECT INTO rtn to_char( epics.position(elPV)::numeric, '9999.9') FROM px.epicsLink WHERE elStn=stn and elName='distance';
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_dist( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_can_home_omega() returns boolean AS $$
  SELECT px.rt_get_dist() >= 100.0;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.rt_can_home_omega() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_set_dist( d numeric) returns void AS $$
  DECLARE
  BEGIN
    PERFORM px.moveit( 'distance', d);
    RETURN;
  END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER;
ALTER FUNCTION px.rt_set_dist( numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_set_dist( d text) returns void AS $$
  DECLARE
  BEGIN
    PERFORM px.moveit( 'distance', d::numeric);
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_set_dist( text) OWNER TO lsadmin;

--CREATE OR REPLACE FUNCTION px.rt_set_dist( d numeric) returns void AS $$
--  DECLARE
--  BEGIN
--    PERFORM px.moveit( 'distance', d);
--    RETURN;
--  END;
--$$ LANGUAGE plpgsql SECURITY DEFINER;
--ALTER FUNCTION px.rt_set_dist( numeric) OWNER TO lsadmin;


CREATE TABLE px.distSaves (
--
-- distSaves
-- Stores "In" and "Out" detector positions
-- to automatically move the detector out of the way
-- when the user enters the hutch
--
        dsKey serial primary key,       -- table key
        dsStn bigint                    -- pointer to station
                references px.stations (stnkey),
        dsTs  timestamp with time zone, -- time last In position was saved
        dsIn  numeric default 500,      -- saved data collection position
        dsOut numeric default 500       -- Position for detector out of the way
);
ALTER TABLE px.distSaves OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px._moveDetectorOut( pvmk bigint, value numeric) RETURNS void AS $$
-- _moveDetectorOut
-- "Action" function called when an epics variable (pvmk is the pvmonitors key) changes.  See actions in epics.sql
--
  DECLARE
    moving boolean;     -- check to see if the motor is moving.  Do nothing if it is.
    stn    bigint;      -- pointer to station
    dist   numeric;     -- saved detector position
  BEGIN
    SELECT INTO stn epvmlStn FROM px.epicsPVMLink LEFT JOIN epics._pvmonitors ON epvmlPV=pvmname WHERE pvmKey=pvmk limit 1;
    IF FOUND THEN
      SELECT INTO moving not (minpos=1) FROM epics.motions LEFT JOIN px.epicsLink on mmotorpvname=elPV WHERE elName='distance' and elStn=stn;
      IF NOT moving THEN
        SELECT INTO dist mrqspos FROM epics.motions LEFT JOIN  px.epicsLink ON elPV=mmotorpvname WHERE elStn=stn and elName='distance';
        UPDATE px.distSaves SET dsIn=dist, dsTs=now() WHERE dsStn=stn;
        PERFORM epics.moveit( elPV, dsOut) FROM px.distSaves,px.epicsLink WHERE elName='distance' and elStn=stn and dsStn=stn;
      END IF;
    END IF;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px._moveDetectorOut( bigint, numeric) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px._moveDetectorIn( pvmk bigint, value numeric) RETURNS void AS $$
-- _moveDetectorIn
-- "Action" function called when an epics variable (pvmk is the pvmonitors key) changes.  See actions in epics.sql
--
  DECLARE
    moving boolean;     -- check to see if the motor is moving.  Do nothing if it is.
    stn    bigint;      -- pointer to station
  BEGIN
    SELECT INTO stn epvmlStn FROM px.epicsPVMLink LEFT JOIN epics._pvmonitors ON epvmlPV=pvmname WHERE pvmKey=pvmk limit 1;
    IF FOUND THEN
      SELECT INTO moving not (minpos=1) FROM epics.motions LEFT JOIN px.epicsLink on mmotorpvname=elPV WHERE elName='distance' and elStn=stn;
      IF NOT moving THEN
        PERFORM epics.moveit( elPV, dsIn) FROM px.distSaves,px.epicsLink WHERE elName='distance' and elStn=stn and dsStn=stn;
      END IF;
    END IF;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px._moveDetectorIn( bigint, numeric) OWNER TO lsadmin;

CREATE TABLE px._energyLookUpMethods (
        elum text primary key
);
ALTER TABLE px._energyLookUpMethods OWNER TO lsadmin;
INSERT INTO px._energyLookUpMethods (elum) VALUES ('table');
INSERT INTO px._energyLookUpMethods (elum) VALUES ('epics');

CREATE TABLE px._energyHistory (
--
-- Stores the current and past values of the energy for each station
-- Not used for stations that get the energy directly from epics
--
        ehKey serial primary key,                       -- table key
        ehTs  timestamp with time zone default now(),   -- time entry was created
        ehStn bigint not null                                   -- the station
                references px.stations (stnkey),
        ehValue numeric default NULL                    -- the actual value  (NULL signifies unknown value)
);
ALTER TABLE px._energyHistory OWNER TO lsadmin;

CREATE TABLE px._energyLookUp (
        eluKey serial primary key,      -- table key
        eluStn bigint unique            -- our station
                references px.stations (stnkey),
        eluType text                    -- table or epics method of retrieving wavelength
                references px._energyLookUpMethods (elum) ON UPDATE CASCADE,
        eluEpics text                   -- epics PV name of epics energy pv
                references epics._pvmonitors (pvmname) ON UPDATE CASCADE
);
ALTER TABLE px._energyLookUp OWNER TO lsadmin;
        
CREATE VIEW px.energyLookUp (eluKey, eluStn, eluValue) AS
        SELECT eluKey, eluStn,
                CASE eluType
                WHEN 'table' THEN ehValue
                WHEN 'epics' THEN pvmValueN
                END
        FROM px._energyLookUp
        LEFT JOIN px._energyHistory ON eluStn=ehStn
        LEFT JOIN epics._pvmonitors ON eluEpics=pvmname
        WHERE ehKey in (select max(ehkey) FROM px._energyHistory GROUP BY ehStn) OR pvmkey is not NULL;

ALTER TABLE px.energyLookUp OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.rt_get_wavelength() returns text AS $$
  DECLARE
    rtn text;
    val numeric;
  BEGIN
    PERFORM epics.updatePvmVar( eluEpics) FROM px._energyLookUp WHERE eluStn=px.getStation() and eluType='epics';
    SELECT eluValue INTO val FROM px.energyLookUp WHERE eluStn=px.getStation();
    IF NOT FOUND OR abs(val) < 2.0 THEN
      rtn := '--';
    ELSE
      SELECT to_char( 12.3984172/val, '0.99999') INTO rtn;
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_wavelength() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_get_wavelength( stn bigint) returns text AS $$
  DECLARE
    rtn text;
    val numeric;
  BEGIN
    PERFORM epics.updatePvmVar( eluEpics) FROM px._energyLookUp WHERE eluStn=stn and eluType='epics';
    SELECT eluValue INTO val FROM px.energyLookUp WHERE eluStn=stn;
    IF NOT FOUND OR abs(val) < 2.0 THEN
      rtn := '--';
    ELSE
      SELECT to_char( 12.3984172/val, '0.99999') INTO rtn;
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_wavelength( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_set_wavelength( lambda text) returns void AS $$
  DECLARE
  BEGIN
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_set_wavelength( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_get_energy() returns text AS $$
  DECLARE
    rtn text;
  BEGIN
    PERFORM epics.updatePvmVar( eluEpics) FROM px._energyLookUp WHERE eluStn=px.getStation() and eluType='epics';
    SELECT INTO rtn to_char(eluValue, '99.99999') FROM px.energyLookUp WHERE eluStn=px.getStation();
    IF NOT FOUND THEN
      rtn := '12.73';
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_energy() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_get_energy( stn bigint) returns text AS $$
  DECLARE
    rtn text;
  BEGIN
    PERFORM epics.updatePvmVar( eluEpics) FROM px._energyLookUp WHERE eluStn=stn and eluType='epics';
    SELECT INTO rtn to_char(eluValue, '99.99999') FROM px.energyLookUp WHERE eluStn=stn;
    IF NOT FOUND THEN
      rtn := '12.73';
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_energy() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_set_energy( e text) returns void AS $$
  DECLARE
  BEGIN
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_set_energy( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_get_ni0() returns text AS $$
--
-- Normalized Io
  DECLARE
    theCurrent numeric;
    theIzero   numeric;
    rtn        text;
  BEGIN
    --SELECT INTO theCurrent pvmvaluen FROM epics._pvmonitors WHERE pvmname='S:SRcurrentAI';
    --SELECT INTO theIzero  pvmvaluen FROM epics._pvmonitors LEFT JOIN px.epicsPVMLink ON epvmlPV=pvmname WHERE epvmlStn=px.getstation() and epvmlName='Io';

    SELECT epics.caget( epvmlname) INTO theIzero FROM px.epicsPVMLink WHERE epvmlStn=px.getstation() AND epvmlName='Io';
    IF NOT FOUND THEN
      theIzero := 1;
    END IF;

    IF theIzero < 1 THEN
      theIzero = 0;
    END IF;
    
    theCurrent := epics.caget( 'S:SRcurrentAI');
    IF theCurrent < 10.0 THEN
      rtn := '--';
    ELSE
      SELECT INTO rtn to_char( theIzero/theCurrent, '999999');
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_ni0() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_get_ni0( stn bigint) returns text AS $$
--
-- Normalized Io
  DECLARE
    theCurrent numeric;
    theIzero   numeric;
    rtn        text;
  BEGIN
    --SELECT INTO theCurrent pvmvaluen FROM epics._pvmonitors WHERE pvmname='S:SRcurrentAI';
    --SELECT INTO theIzero  pvmvaluen FROM epics._pvmonitors LEFT JOIN px.epicsPVMLink ON epvmlPV=pvmname WHERE epvmlStn=px.getstation() and epvmlName='Io';

    SELECT epics.caget( epvmlpv) INTO theIzero FROM px.epicsPVMLink WHERE epvmlStn=stn AND epvmlName='Io';
    IF NOT FOUND THEN
      theIzero := 1;
    END IF;

    IF theIzero < 1 THEN
      theIzero = 0;
    END IF;
    
    theCurrent := epics.caget( 'S:SRcurrentAI');
    IF theCurrent < 10.0 THEN
      rtn := '--';
    ELSE
      SELECT INTO rtn to_char( theIzero/theCurrent, '999999');
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_ni0() OWNER TO lsadmin;


CREATE TYPE px.locationType AS ( x numeric, y numeric, z numeric);

CREATE OR REPLACE FUNCTION px.rt_get_magnetPosition() returns px.locationType AS $$
  DECLARE
    rtn px.LocationType;
    x1 numeric;
    x2 numeric;
    y1 numeric;
    y2 numeric;
    y3 numeric;
  BEGIN
    SELECT epics.caget( epvmlpv) INTO x1 FROM px.epicsPVMLink WHERE epvmlStn=px.getStation() AND epvmlName='TableX1';
    SELECT epics.caget( epvmlpv) INTO x2 FROM px.epicsPVMLink WHERE epvmlStn=px.getStation() AND epvmlName='TableX2';
    SELECT epics.caget( epvmlpv) INTO y1 FROM px.epicsPVMLink WHERE epvmlStn=px.getStation() AND epvmlName='TableY1';
    SELECT epics.caget( epvmlpv) INTO y2 FROM px.epicsPVMLink WHERE epvmlStn=px.getStation() AND epvmlName='TableY2';
    SELECT epics.caget( epvmlpv) INTO y3 FROM px.epicsPVMLink WHERE epvmlStn=px.getStation() AND epvmlName='TableY3';

    rtn.x = x2;
    rtn.y = (y2 + y3) / 2.0;
    rtn.z = (y1 - rtn.y) * 650.0 / 1100.0;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_magnetPosition() OWNER TO lsadmin;



CREATE OR REPLACE FUNCTION px.rt_get_blstatus() returns text AS $$
--
-- Beamline status
  DECLARE
  BEGIN
    RETURN 'No Beam Today';
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_blstatus() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_open_fes() returns void AS $$
--
-- Open Front End Shutter
  DECLARE
  BEGIN
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_open_fes() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_open_ss() returns void AS $$
--
-- Open Station Shutter
  DECLARE
  BEGIN
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_open_ss() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_close_ss() returns void AS $$
--
-- Close Station Shutter
  DECLARE
  BEGIN
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_close_ss() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.getName( theId int) returns text AS $$
  DECLARE
    rtn text;   -- our return value
    hn  text;   -- name from holder
  BEGIN
    rtn := NULL;
    --
    -- Get the name of the holder position
    --
    SELECT hpname INTO rtn FROM px.holderpositions WHERE hpid=theId;

    IF NOT FOUND THEN
      -- Not every 32 bit integer corresponds to a valid holder position
      return 'Not Found';
    END IF;
    --
    --  if there is a holder in this position use that name
    --
    SELECT hname INTO hn FROM px.holders LEFT JOIN px.holderhistory ON hhHolder=hkey WHERE hhState='Present' and hhPosition=theId ORDER BY hhLast DESC LIMIT 1;
    IF FOUND THEN
      rtn := hn;
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getName( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getConfigFile( thePid text, theId int) returns text AS $$
  DECLARE
    rtn text;
    stn int;
  BEGIN
    rtn = '';
    stn = ((theId & x'ff000000'::int) >> 24) & x'000000ff'::int;
    PERFORM 1 WHERE rmt.checkstnaccess( stn, thePid);
    IF FOUND THEN
      SELECT px.getConfigFile( theId) INTO rtn;
    END IF;
    -- KLUDGE: assume that anything using this function needs
    -- URL's changed from 'contrabass.ls-cat.org' to 'ls-cat.org' for the images
    --
    rtn = replace( rtn, 'http://contrabass.ls-cat.org', 'http://ls-cat.org');

    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getConfigFile( text, int) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.getConfigFile( theId int) returns text AS $$
  DECLARE
    itm record;         -- the record of the item pointed to by theId
    chitms record;      -- the record(s) of the child items under theId
    rtn text;           -- xml return text
    inf text;           -- Information on this ID
    stn int;		-- the station
    lid int;		-- the dewar
    puc int;		-- the puck
    pindex int;         -- index of the puck location (1= lid 1 puck 1, ... 10=lid 3 puck 3)  0=N/A
    pOk boolean;        -- the puck is ok
  BEGIN

    --
    -- See if the puck is actually making contact with the switch
    --  

    rtn := '';
    SELECT *  INTO itm FROM px.holderPositions WHERE hpId = theId;
    IF FOUND THEN
      rtn := '<?xml version="1.0" encoding="UTF-8"?>' || E'\n';
      --
      -- Config files are different for samples
      -- if LSB is non-zero then we have a sample
      rtn := rtn || '<Config ';
        -- This is not a sample (150 by 150 images)
      IF itm.hpImageURL IS NOT NULL THEN
        rtn = rtn || 'image="' || itm.hpImageURL || '" ';
      END IF;
      IF itm.hpImageMaskURL IS NOT NULL THEN
        rtn = rtn || 'overlayImage="' || itm.hpImageMaskURL || '" ';
      END IF;

      rtn = rtn || E'>\n';
      rtn = rtn || E'  <Color name="current" r="255" g="0" b = "0" a="100" />\n';
      rtn = rtn || E'  <Selected r="120" g="120" b = "0" a="127" />\n';
      rtn = rtn || E'  <Disabled r="255"  g="255"  b = "255" a="127" />\n';
      FOR chitms IN SELECT *
          FROM px.holderPositions
          LEFT JOIN px.holderHistory on hpid=hhPosition
          WHERE hpId > theId and hpidres=itm.hpidres>>8 and hpId < (theId + itm.hpIdRes) and hpIndex>0 and hhstate!='Inactive'
          LOOP
        stn = ((chitms.hpId & x'ff000000'::int) >> 24) & x'000000ff'::int;
        lid = ((chitms.hpId & x'00ff0000'::int) >> 16) & x'000000ff'::int;
        puc = ((chitms.hpId & x'0000ff00'::int) >>  8) & x'000000ff'::int;
        pindex = 0;
        pOk = true;
        IF lid > 0 and puc > 0 THEN
          pindex = (lid-3)*3 + ((puc-1)%3);
          SELECT INTO pOk ((B'1'::bit(99) >> (pindex+12)) & dii) != B'0'::bit(99) FROM cats.di WHERE distn=stn;
         END IF;
        IF pOk THEN
          rtn = rtn || '<Child id="' || chitms.hpId || '" found="True" index="' || chitms.hpIndex || E'" />\n';
        ELSE
          rtn = rtn || '<Child id="' || chitms.hpId || '" found="False" index="' || chitms.hpIndex || E'" />\n';
        END IF;
      END LOOP;

      SELECT hname || E'\n' ||
        coalesce( 'ESAF: ' || hhExpId, 'None') || E'\n' ||
        coalesce( hhMaterial, 'No Material Info') || E'\n'
        -- Stick in total exposure here once px.hots supports the sample
        INTO inf
        FROM px.holders LEFT JOIN px.holderhistory ON hhHolder=hkey
        WHERE hhPosition=theId and (hhstate='Present' or hhstate='TempStorage')
        ORDER BY hhLast DESC
        LIMIT 1;
      IF FOUND THEN
        rtn := rtn || inf;
      ELSE
        rtn := rtn || coalesce( itm.hpName,'Unknown');
      END IF;
      rtn = rtn || E'</Config>\n';
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getConfigFile( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getAllPuckPositionsxml( thePid text, stn int) returns xml AS $$
  DECLARE
    rtn xml;
  BEGIN
    PERFORM 1 WHERE rmt.checkstnaccess( stn, thePid);
    IF FOUND THEN
      SELECT px.getAllPuckPositionsxml( stn) INTO rtn;
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getAllPuckPositionsxml( text, int) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.getAllPuckPositionsxml( stn int) returns xml as $$
  -- returns xml listing all puck id's in station stn
  DECLARE
    rtn xml;
    tmp xml;
    poses record;
  BEGIN
    SELECT xmlagg( xmlelement( name "Child",
                     xmlattributes( hpid as id,
                                    hpindex as index,
                                    (((hpid & x'00ff0000'::int) >> 16) - 3)*3 + hpindex as pucknum,
                                    htype as type,
                                    hname as name,
                                    hbarcode as barcode,
                                    hrfid as rfid)))
           INTO tmp
           FROM px.holderpositions
           LEFT JOIN px.holderhistory ON hpid=hhposition
           LEFT JOIN px.holders ON hhholder=hkey
           WHERE hhstate='Present' and
                 hpid & x'000000ff'::int=0 and
                 hpid & x'0000ff00'::int !=0 and
                 hpid & x'ff000000'::int = (stn<<24);
    rtn := xmlelement( name "allPuckPositions", xmlattributes( stn as station), tmp);
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getAllPuckPositionsxml( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getCurrentStationId() returns int as $$
  DECLARE
    rtn int;
  BEGIN
    SELECT hhPosition
      INTO rtn
      FROM px.holders
      LEFT JOIN px.stations ON hname=stnname
      LEFT JOIN px.holderhistory ON hkey=hhholder
      WHERE htype='Station' AND stnkey=px.getstation() AND hhstate='Present';
    IF NOT FOUND THEN
      return 0;
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getCurrentStationId() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getCurrentStationId( theStn bigint) returns int as $$
  DECLARE
    rtn int;
  BEGIN
    SELECT hhPosition
      INTO rtn
      FROM px.holders
      LEFT JOIN px.stations ON hname=stnname
      LEFT JOIN px.holderhistory ON hkey=hhholder
      WHERE htype='Station' AND stnkey=theStn AND hhstate='Present';
    IF NOT FOUND THEN
      return 0;
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getCurrentStationId( bigint) OWNER TO lsadmin;

CREATE TYPE px.nextActionType AS ( key bigint, action text);

CREATE OR REPLACE FUNCTION px.nextAction() returns px.nextActionType as $$
    -- noAction
    -- collect
    -- transfer
    -- center
  DECLARE
    rtn px.nextActionType;    -- return value
    tmp px._md2queue;    --
  BEGIN
    rtn.key    := 0;
    rtn.action := 'noAction';
    SELECT * INTO tmp FROM px.md2popqueue();
    IF length( tmp.md2cmd)>0 THEN
      rtn.action := tmp.md2Cmd;
      rtn.key    := tmp.md2Key;
    ELSE
      IF not px.ispaused() THEN
        PERFORM 1 FROM px.runqueue WHERE rqstn = px.getstation();
        IF FOUND THEN
          rtn.action := 'collect';
          rtn.key    := 0;
        END IF;
      END IF;
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.nextAction() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.md2ReturnValue( key bigint, val text) RETURNS VOID AS $$
  DECLARE
  BEGIN
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.md2ReturnValue( bigint, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.md2ReturnValue( key bigint) RETURNS VOID AS $$
  DECLARE
  BEGIN
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.md2ReturnValue( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.md2CallFailed( key bigint) RETURNS VOID  AS $$
  DECLARE
  BEGIN
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.md2CallFailed( bigint) OWNER TO lsadmin;



CREATE TABLE px.nextSamples ( 
       nsKey serial primary key,
       nsStn int not null references px.stations (stnKey) on update cascade,
       nsId int not null
);
ALTER TABLE px.nextSamples OWNER TO lsadmin;

CREATE TABLE px.lastSamples ( 
       lsKey serial primary key,
       lsts timestamp with time zone default now(),
       lsStn int not null references px.stations (stnKey) on update cascade,
       lsId int not null
);
ALTER TABLE px.lastSamples OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.lastSample( theStn bigint) returns int as $$
  DECLARE
    rtn int;
  BEGIN
    SELECT lsId INTO rtn FROM px.lastSamples WHERE lsStn=theStn ORDER BY lsKey DESC LIMIT 1;
    IF NOT FOUND THEN
      rtn = 0;
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.lastSample( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.lastSample() returns int as $$
  DECLARE
  BEGIN
    return px.lastSamples( px.getStation());
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.lastSample() OWNER TO lsadmin;



CREATE OR REPLACE FUNCTION px.nextSample() returns int as $$
  DECLARE
    rtn int;
    k  bigint;
  BEGIN
    rtn = 0;
    SELECT nsId, nsKey INTO rtn, k FROM px.nextSamples WHERE nsStn=px.getstation() ORDER BY nsKey DESC LIMIT 1;
    IF FOUND THEN
      DELETE FROM px.nextSamples WHERE nsKey=k;
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.nextSample() OWNER TO lsadmin;



CREATE OR REPLACE FUNCTION px.requestTransfer( theId int) returns void AS $$
  DECLARE
  BEGIN
    INSERT INTO px.nextSamples (nsStn, nsId) VALUES (px.getstation(), theId);
    INSERT INTO px.lastSamples (lsStn, lsId) VALUES (px.getstation(), theId);
    PERFORM px.md2pushqueue( 'transfer');
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.requestTransfer( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.requestTransfer( stn bigint, theId int) returns void AS $$
  DECLARE
  BEGIN
    INSERT INTO px.nextSamples (nsStn, nsId) VALUES (stn, theId);
    INSERT INTO px.lastSamples (lsStn, lsId) VALUES (stn, theId);
    PERFORM px.md2pushqueue( stn, 'transfer');
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.requestTransfer( bigint, int) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.startTransfer( theId int, present boolean, phiX numeric, phiY numeric, phiZ numeric, cenX numeric, cenY numeric, estTime numeric) returns int AS $$
  DECLARE
    mp px.locationtype;         -- current table
    tp record;                  -- saved position
    rtn int;
    xx numeric;			-- corrected coordinates to send to robot
    yy numeric;
    zz numeric;
    xx1 numeric;		-- corrected coordinates to send to robot prior to final rotation
    yy1 numeric;
    zz1 numeric;
    theStn int;			-- our station
    angr float;			-- rotation angle (in rads)
  BEGIN
    --    RAISE exception 'Here I am: theId=%  present=%  phiX=%  phiY=%  phiZ=% cenX=%  cenY=%', to_hex(theId), present, phiX, phiY, phiZ, cenX, cenY;
    SELECT px.getStation() INTO theStn;
    IF NOT FOUND or theStn < 1 or theStn > 4 THEN
      return 0;
    END IF;

    SELECT * FROM px.rt_get_magnetPosition() INTO mp;           -- magnet position relative to table
    SELECT * INTO tp FROM px.transferPoints WHERE tpStn=theStn ORDER BY tpKey DESC LIMIT 1;    -- magnet position relative to MD2
    -- MD2 uses a righthanded coordinate system with x downstream and z up
    -- LS-CAT uses a righthanded coordinate system with y up and z downstream
    -- Here we compute the CATS coordinate corrections.  Here x, y, z is in the CATS system

    --
    -- F and G are the same
    --
    IF theStn = 3 or theStn = 4 THEN
      -- CATS uses a righthanded coordinate system with x into the beam and z up
      xx := round(1000 * (-(mp.z - tp.tpTableZ) - (phiX - tp.tpPhiAxisX) - (cenX - tp.tpCenX)));
      yy := round(1000 * (-(mp.x - tp.tpTableX)  - (phiY - tp.tpPhiAxisY)));
      zz := round(1000 * ((mp.y - tp.tpTableY)  + (phiZ - tp.tpPhiAxisZ) + (cenY - tp.tpCenY)));
    END IF;

    --
    -- but D is rotated 180 degrees about Z
    --
    IF theStn = 1 THEN
      -- CATS uses a righthanded coordinate system with x downstream and z up
      xx := -round(1000 * (-(mp.z - tp.tpTableZ) - (phiX - tp.tpPhiAxisX) - (cenX - tp.tpCenX)));
      yy := -round(1000 * (-(mp.x - tp.tpTableX)  - (phiY - tp.tpPhiAxisY)));
      zz := round(1000 * ((mp.y - tp.tpTableY)  + (phiZ - tp.tpPhiAxisZ) + (cenY - tp.tpCenY)));
    END IF;

    
    --
    -- E is upside down and tilted back 20°
    --
    IF theStn = 2 THEN
      -- CATS uses a righthanded coordinate system with x inboard and z down (and a little downstream)  (that makes y upstream and a little down)
      -- first compute where z is down and y is upstream;
      xx1 := 1000 * (-(mp.x - tp.tpTableX) - (phiY - tp.tpPhiAxisY));
      yy1 := 1000 * (-(mp.z - tp.tpTableZ) - (phiX - tp.tpPhiAxisX) - (cenX - tp.tpCenX));
      zz1 := 1000 * (-(mp.y - tp.tpTableY) - (phiZ - tp.tpPhiAxisZ) - (cenY - tp.tpCenY));

      -- Now rotate 20° about x
      angr = 20.0 * PI()/180.0;
      xx = round( xx1);
      yy = round( yy1 * cos(angr)  + zz1*sin(angr));
      zz = round(-yy1 * sin(angr)  + zz1*cos(angr)); 
      
      raise notice 'xx1: %   yy1: %  zz1: %  xx: %   yy: %   zz: %', xx1, yy1, zz1, xx, yy, zz;
    END IF;



    --    raise exception 'startTransfer: theId=%, xx=%, yy=%, zz=%', to_hex(theId), xx::int, yy::int, zz::int;

    SELECT  px.startTransfer( theId, present, xx::int, yy::int, zz::int, esttime) into rtn;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.startTransfer( int, boolean, numeric, numeric, numeric, numeric, numeric, numeric) OWNER TO lsadmin;


CREATE TABLE px.transferArgs (
       taKey serial primary key,
       taTS timestamp with time zone not null default now(),
       taStn bigint references px.stations (stnKey),
       taCursam int,
       taId int,
       taPresent boolean,
       taXX int,
       taYY int,
       taZZ int,
       taEstTime numeric
);
ALTER TABLE px.transferArgs OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.startTransfer( theId int, present boolean, xx int, yy int, zz int, esttime numeric) returns int AS $$
  -- returns 1 if transfer is allowed, 0 if unknown sample is already present
  DECLARE
    cursam int; -- the current sample
  BEGIN
    SELECT px.getCurrentSampleID() INTO cursam;
    IF NOT FOUND THEN
      return 0;
    END IF;

    INSERT INTO px.transferArgs (taStn, taId, tacursam, taPresent, taXx, taYY, taZZ, taesttime) VALUES (px.getstation(), theId, cursam, present, xx, yy, zz, esttime);

    IF cursam = 0 and present THEN
      -- manually mounted sample, 
      PERFORM px.pusherror( 20002, 'A manually mounted sample is already present');
      return 0;
    END IF;
    IF cursam = 0 THEN
      --      PERFORM cats.put_bcrd( theId, xx, yy, zz, esttime);
      PERFORM cats.put( theId, xx, yy, zz, esttime);
    ELSE
      IF theId = 0 THEN
        PERFORM cats.get( xx, yy, zz, esttime);
      ELSE
        IF theId = cursam THEN
          PERFORM cats.get(xx, yy, zz, esttime);
          -- PERFORM cats.put_bcrd( theId, xx, yy, zz, esttime);
          PERFORM cats.put( theId, xx, yy, zz, esttime);
        ELSE
          -- PERFORM cats.getput_bcrd( theId, xx, yy, zz, esttime);
          PERFORM cats.getput( theId, xx, yy, zz, esttime);
        END IF;
      END IF;
    END IF;
    --
    -- This anticipates a requrest for robot air rights
    -- starting the detector now will save some time later, perhaps
    --
    PERFORM px.rt_set_dist( 700);
    return 1;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.startTransfer( int, boolean, int, int, int, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.startTransfer( theId int, present boolean) returns int AS $$
  SELECT px.startTransfer( $1, $2, 0, 0, 0);
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.startTransfer( int, boolean) OWNER TO lsadmin;



CREATE OR REPLACE FUNCTION px.lockCryo() RETURNS void AS $$
  DECLARE
  BEGIN
    PERFORM pg_advisory_lock( px.getstation(), 6);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.lockCryo() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.unlockCryo() RETURNS void AS $$
  DECLARE
  BEGIN
    PERFORM pg_advisory_unlock( px.getstation(), 6);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.unlockCryo() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.waitCryo() RETURNS void AS $$
  DECLARE
  BEGIN
    PERFORM pg_advisory_lock( px.getstation(), 6);
    PERFORM pg_advisory_unlock( px.getstation(), 6);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.waitCryo() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.endTransfer() RETURNS void AS $$
  DECLARE
    ntfy text;
  BEGIN
    SELECT cnotifyxfer INTO ntfy FROM px._config WHERE cstnkey=px.getstation();
    IF FOUND THEN
      EXECUTE 'NOTIFY ' || ntfy;
    END IF;        
    PERFORM px.pushError( 30000, 'Mounted Sample Changed');
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.endTransfer() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.dropAirRights( ) returns VOID AS $$
  DECLARE
  BEGIN
    PERFORM pg_advisory_unlock( px.getstation(), 2);
  END;    
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.dropAirRights()  OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.demandAirRights( ) returns VOID AS $$
  BEGIN
    PERFORM pg_advisory_lock( px.getstation(), 2);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.demandAirRights() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.checkAirRights( ) returns boolean AS $$
  DECLARE
    rtn boolean;
  BEGIN
    SELECT pg_try_advisory_lock( px.getstation(), 2) INTO rtn;
    IF rtn THEN
      PERFORM pg_advisory_unlock( px.getstation(), 2);
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.checkAirRights() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.requestAirRights( ) returns boolean AS $$
  DECLARE
    rtn boolean;
  BEGIN
    SELECT pg_try_advisory_lock( px.getstation(), 2) INTO rtn;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.requestAirRights() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.requestRobotAirRights( ) returns boolean AS $$
  DECLARE
    rtn boolean;
    md2on boolean;
    curDist numeric;
    stopped boolean;
  BEGIN
    rtn = False;

    SELECT not px.checkDiffractometerOn() INTO md2on;
    IF not md2on THEN
      -- Never grant rights or allow the robot to proceed if
      -- the diffractometer is not on
      PERFORM cats.panic();
    END IF;
    IF md2on THEN
      SELECT px.rt_get_dist() INTO curDist;
      SELECT px.isstopped('distance') INTO stopped;
      IF curDist < 400 THEN
        rtn := False;
        IF stopped THEN
          PERFORM px.rt_set_dist( 651);
        END IF;
      ELSE
        SELECT px.requestAirRights() INTO rtn;
        IF rtn THEN
          PERFORM cats.cmdTimingGotAir();
        END IF;
      END IF;
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.requestRobotAirRights() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.dropRobotAirRights( ) returns void AS $$
  DECLARE
    ntfy text;  -- notify to send
    smpl int;   -- the mounted sample
    dist numeric; -- next sample distance
  BEGIN
    PERFORM px.dropAirRights();
    SELECT px.getCurrentSampleId() INTO smpl;
    SELECT dsdist INTO dist FROM px.nextShot();
    IF FOUND and dist is not null THEN
      PERFORM px.rt_set_dist( dist);
    END IF;

    IF smpl != 0 THEN
      SELECT cnotifyxfer INTO ntfy FROM px._config WHERE cstnkey=px.getstation();
      EXECUTE 'NOTIFY ' || ntfy;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.dropRobotAirRights() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.getCurrentSampleID() returns int as $$
  DECLARE
    rtn int;
    stnid int;
    diffid int;
  BEGIN
    rtn := 0;
    SELECT px.getCurrentStationId() INTO stnid;
    IF stnid > 0 THEN
      diffid := stnid + x'00020000'::int;
      SELECT hpid
        INTO rtn
        FROM px.holderPositions
        WHERE hpId > stnid and hpId < stnid+x'01000000'::int and hpTempLoc=diffid;
      IF NOT FOUND THEN
        return 0;
      END IF;
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getCurrentSampleID() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getCurrentSampleID( theStn bigint) returns int as $$
  DECLARE
    rtn int;
    stnid int;
    diffid int;
  BEGIN
    rtn := 0;
    SELECT px.getCurrentStationId( theStn) INTO stnid;
    IF stnid > 0 THEN
      diffid := stnid + x'00020000'::int;
      SELECT hpid
        INTO rtn
        FROM px.holderPositions
        WHERE hpId > stnid and hpId < stnid+x'01000000'::int and hpTempLoc=diffid;
      IF NOT FOUND THEN
        return 0;
      END IF;
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getCurrentSampleID( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.currentSampleDPS() returns text AS $$
  DECLARE
    rtn text;
    curs int;
    d int;
    p int;
    s int;
  BEGIN
    rtn := '';
    SELECT px.getCurrentSampleID() INTO curs;
    IF curs != 0 THEN
      d := ((curs & x'00ff0000'::int) >> 16) - 2;
      p := (((curs & x'0000ff00'::int) >> 8) - 1) % 3 + 1;
      s := (curs & x'000000ff'::int);
      rtn := 'D' || d || ' P' || p || ' S' || s;
    END IF;
    return rtn;
  END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER;
ALTER FUNCTION px.currentSampleDPS() OWNER TO lsadmin;
 
CREATE OR REPLACE FUNCTION px.getContents( theId int) returns setof int as $$
  DECLARE
    res int;
    rtn int;
  BEGIN
    SELECT hpidres INTO res FROM px.holderpositions WHERE hpid=theId;
    IF NOT FOUND THEN
      RETURN;
    END IF;
    FOR rtn IN SELECT hpid
                 FROM px.holderpositions
                 LEFT JOIN px.holderhistory ON hhPosition=hpid
                 WHERE hpid>theId and hpid<theid+res and hpidres = res>>8 and hhState != 'Inactive' and hpIndex>0
                 ORDER BY hpid
                 LOOP
      return next rtn;
    END LOOP;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getContents( int) OWNER TO lsadmin;


CREATE TABLE px.holderstates (
       ss text primary key
);
ALTER TABLE px.holderstates OWNER TO lsadmin;

INSERT INTO px.holderstates (ss) VALUES ('Unknown');
INSERT INTO px.holderstates (ss) VALUES ('Present');
INSERT INTO px.holderstates (ss) VALUES ('Absent');
INSERT INTO px.holderstates (ss) VALUES ('TempStorage');
INSERT INTO px.holderstates (ss) VALUES ('Inactive');           -- set if this position is not currently installed


CREATE TABLE px.holderPositions (
       -- This is a table of all the positions for sample holders
       --
       -- The ID is given by a 32 bit integer
       -- Bits  0 -  7 : sample number
       -- Bits  8 - 15 : puck number 
       -- Bits 16 - 23 : dewar number (diffractometer and tool each are considered a type of dewar and have a location defined in this table)
       -- Bits 24 - 31 : station number
       --
       -- | Station | Dewar  |  Puck  | Sample |
       --    MSB                          LSB

       -- Sample  = 0 means entry defines a puck position
       -- Puck    = 0 means entry defines a dewar position
       -- Dewar   = 0 means entry defines a station position
       -- Station = 0 means location is unknown

       hpKey serial primary key,                -- our key
       hpId int unique,                         -- unique idenifier for this location
       hpIdRes int NOT NULL,                    -- children have ids > hpId and < hpId+hpIdRes
       hpIndex int,                             -- Parent's selection index
       hpName text,                             -- name of this item
       hpImageURL text default NULL,            -- Image, if any, to use for this holder position
       hpImageMaskURL text default NULL,        -- Image, if any, to use for the selection mask for position contained herein
       hpTempLoc int default 0                  -- current location id of sample normally stored here (0 means item not in temp storage)
       );
ALTER TABLE px.holderPositions OWNER TO lsadmin;


CREATE TABLE px.holderTypes (
       ht text primary key
);
ALTER TABLE px.holdertypes OWNER TO lsadmin;
INSERT INTO px.holdertypes (ht) VALUES ('Station');
INSERT INTO px.holdertypes (ht) VALUES ('Dewar');
INSERT INTO px.holdertypes (ht) VALUES ('SPINE Basket');
INSERT INTO px.holdertypes (ht) VALUES ('Rigaku Magazine');
INSERT INTO px.holdertypes (ht) VALUES ('ALS Puck');
INSERT INTO px.holdertypes (ht) VALUES ('UNI Puck');
INSERT INTO px.holdertypes (ht) VALUES ('CrystalCap HT   HR8');
INSERT INTO px.holdertypes (ht) VALUES ('CrystalCap Magnetic (ALS) HR4');



CREATE TABLE px.holders (
       hKey serial primary key,         -- Our key
       hType text references px.holdertypes (ht) on update cascade,
       hName text,                      -- Whatever name we want for this holder
       hBarCode text unique,            -- unique id for this sample: NULL means we don't know or don't care
       hRFID text unique                -- unique id for this sample: NULL means we don't know or don't care
);
ALTER TABLE px.holders OWNER TO lsadmin;


CREATE TABLE px.holderHistory (
       hhKey serial primary key,                -- our key
       hhPosition int references px.holderPositions (hpId),
       hhHolder   bigint references px.holders (hKey),
       hhState text default 'Unknown' not null references px.holderstates (ss) on update cascade,
       hhExpId int default null,                -- The experiment id that includes this sample: should be a reference
       hhMaterial text default null,    -- name of the sample from ESAF: should be a reference to esaf.materials (matname) but this requires a different mechanism for esaf updates than is currently employed
       hhStart timestamp with time zone default now(),
       hhLast  timestamp with time Zone default now()
);
ALTER TABLE px.holderHistory OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.holderHistoryInsertTF() returns trigger as $$
  DECLARE
  BEGIN
    IF NEW.hhPosition is not null THEN
      NEW.hhState := 'Present';
      UPDATE px.holderHistory SET hhState='Inactive' WHERE hhPosition=NEW.hhPosition;
    END IF;
    return NEW;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.holderHistoryInsertTF() OWNER TO lsadmin;
CREATE TRIGGER hh_insert_trigger BEFORE INSERT ON px.holderhistory FOR EACH ROW EXECUTE PROCEDURE px.holderHistoryInsertTF();

CREATE OR REPLACE FUNCTION px.holderHistoryUpdateTF() returns trigger as $$
  DECLARE
    cld int;  -- child of this holder

  BEGIN
    IF NEW.hhPosition is not null THEN
      IF NEW.hhState != 'Present' AND OLD.hhState = 'Present' THEN
        FOR cld IN SELECT getcontents FROM px.getContents( NEW.hhPosition) LOOP
          UPDATE px.holderHistory SET hhState=NEW.hhState WHERE hhState='Present' and hhPosition = cld;
        END LOOP;
      END IF;
    END IF;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.holderHistoryUpdateTF() OWNER TO lsadmin;
CREATE TRIGGER hh_update_trigger AFTER UPDATE ON px.holderhistory FOR EACH ROW EXECUTE PROCEDURE px.HolderHistoryUpdateTF();

       
CREATE OR REPLACE FUNCTION px.possibleChildren( expId int, theId int) returns setof text as $$
  DECLARE
    rtn text;
  BEGIN
    IF (theId & x'0000ff00'::int) != 0 THEN
      -- id is a cylinder, return possible sample names
      FOR rtn IN SELECT matname FROM esaf.materials WHERE matexpid=expId ORDER BY matName LOOP
        return next rtn;
      END LOOP;
    ELSEIF (theId & x'00ff0000'::int) != 0 THEN
     -- id is a dewar, return Pucks, Cassettes, Magazines, Baskets, etc
      FOR rtn IN SELECT hName FROM px.holderHistory LEFT JOIN px.holders ON hhHolder=hKey WHERE hhExpId=expId and hhState != 'Inactive' ORDER BY hName LOOP
        return next rtn;
      END LOOP;
    END IF;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.possibleChildren( int, int) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.insertHolder( expId int, theId int, theName text, theType text, barcode text, rfid text) returns int as $$
  DECLARE
    rtn int;
    hh  record;
  BEGIN
    IF ((theId & x'ffff0000'::int) = theId) THEN
      raise exception 'insert only supported for samples and cylinders (pucks, magazines, baskets, etc)';
    END IF;
    IF (theId & x'000000ff'::int) != 0 THEN
      -- Sample
      SELECT * INTO hh FROM px.holderHistory LEFT JOIN px.holders ON hhHolder=hKey WHERE hhExpId=expId and hhMaterial=theName;
      IF FOUND THEN
        UPDATE px.holders set hName=theName, hBarCode=coalesce(barcode, hBarCode), hRFID=coalesce( rfid, hRFID), hType=coalesce(theType, hType) WHERE hKey=hh.hhHolder;
        UPDATE px.holderHistory set hhLast=now(), hhPosition=theId WHERE hhKey=hh.hhKey;
        GET DIAGNOSTICS rtn = ROW_COUNT;
      ELSE
        INSERT INTO px.holders (hName, hBarCode, hRFID, hType) VALUES (theName, barcode, rfid, theType);
        INSERT INTO px.holderHistory (hhPosition, hhMaterial, hhHolder) VALUES (theId, theName, currval( 'px.holders_hKey_seq'));
        GET DIAGNOSTICS rtn = ROW_COUNT;
      END IF; 

    ELSE
      -- Cylinder
      SELECT * INTO hh FROM px.holderHistory LEFT JOIN px.holders ON hhHolder=hKey WHERE hhExpId=expId and hName=theName;
      IF FOUND THEN
        UPDATE px.holders set hBarCode=coalesce( barcode, hBarCode), hRFID=coalesce( rfid, hRFID), hType=coalesce(theType, hType) WHERE hKey=hh.hhHolder;
        INSERT INTO px.holderHistory (hhPosition,hhHolder) values (theId, hh.hhHolder);
        GET DIAGNOSTICS rtn = ROW_COUNT;
      ELSE
        INSERT INTO px.holders (hName, hBarCode, hRFID, hType) values (theName, barcode, rfid, theType);
        INSERT INTO px.holderHistory (hhPosition,hhHolder) values (theId, currval('px.holders_hkey_seq'));
        GET DIAGNOSTICS rtn = ROW_COUNT;
      END IF;
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.insertHolder( int, int, text, text, text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.insertHolder( expId int, theId int, theName text) returns int as $$
  SELECT px.insertHolder( $1, $2, $3, NULL, NULL, NULL);
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.insertHolder( int, int, text) OWNER TO lsadmin;


CREATE  OR REPLACE FUNCTION px.insertPuck( expId int, theId int, theName text, barcode text, rfid text, addsamples boolean) RETURNS int AS $$
  DECLARE
    rtn int;
    cnt int;
    smp record;
  BEGIN
    SELECT px.insertHolder( expId, theId, theName, NULL, barcode, rfid) INTO cnt;
    IF NOT FOUND or cnt=0 THEN
      return 0;
    END IF;
    rtn := cnt;

    IF addsamples THEN
      FOR smp IN SELECT * from px.holderpositions where (hpid & x'ffffff00'::int) = theId and hpidres = 1 LOOP
        PERFORM px.insertHolder( expId, smp.hpid, 'Sample ' || smp.hpindex::text, NULL, NULL, NULL);
        rtn := rtn + 1;
      END LOOP;
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.insertPuck( int, int, text, text, text, boolean) OWNER TO lsadmin;




CREATE TABLE px._md2queue (
       md2Key serial primary key,       -- our key
       md2ts timestamp with time zone not null default now(),
       md2Addr inet not null,           -- IP Address of the MD2
       md2Cmd text not null             -- the Command
);
ALTER TABLE px._md2queue OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.md2pushqueue( cmd text) RETURNS VOID AS $$
  DECLARE
    c text;     -- trimmed command
    ntfy text;  -- used to generate notify command
  BEGIN
    SELECT cnotifydiffractometer INTO ntfy FROM px._config WHERE cstnkey=px.getstation();
    IF NOT FOUND THEN
      RETURN;
    END IF;
    c := trim( cmd);
    IF length( c) > 0 THEN
      INSERT INTO px._md2queue (md2Cmd, md2Addr)
        SELECT c, cdiffractometer::inet
          FROM px._config
          WHERE cstnkey=px.getstation()
          LIMIT 1;
      IF FOUND THEN
        EXECUTE 'NOTIFY ' || ntfy;
      END IF;
    END IF;
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.md2pushqueue( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.md2pushqueue( stn bigint, cmd text) RETURNS VOID AS $$
  DECLARE
    c text;     -- trimmed command
    ntfy text;  -- used to generate notify command
  BEGIN
    SELECT cnotifydiffractometer INTO ntfy FROM px._config WHERE cstnkey=stn;
    IF NOT FOUND THEN
      RETURN;
    END IF;
    c := trim( cmd);
    IF length( c) > 0 THEN
      INSERT INTO px._md2queue (md2Cmd, md2Addr)
        SELECT c, cdiffractometer::inet
          FROM px._config
          WHERE cstnkey=stn
          LIMIT 1;
      IF FOUND THEN
        EXECUTE 'NOTIFY ' || ntfy;
      END IF;
    END IF;
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.md2pushqueue( bigint, text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.md2popqueue() returns px._md2queue AS $$
  DECLARE
    rtn px._md2queue;           -- return value
  BEGIN
--    rtn := NULL;
    SELECT md2key, md2cmd INTO rtn.md2key, rtn.md2cmd FROM px._md2queue WHERE md2Addr=inet_client_addr() ORDER BY md2Key ASC LIMIT 1;
    IF NOT FOUND THEN
      return NULL;
    END IF;
    DELETE FROM px._md2queue WHERE md2Key=rtn.md2key;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.md2popqueue() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getHolderPositionState( theId int) returns text as $$
  DECLARE
    rtn text;
    stn int;		-- the station
    lid int;		-- the dewar
    puc int;		-- the puck
    pindex int;         -- index of the puck location (1= lid 1 puck 1, ... 10=lid 3 puck 3)  0=N/A
    pOk boolean;        -- the puck is ok
  BEGIN
    rtn := 'Unknown';
    stn = ((theId & x'ff000000'::int) >> 24) & x'000000ff'::int;
    lid = ((theId & x'00ff0000'::int) >> 16) & x'000000ff'::int;
    puc = ((theId & x'0000ff00'::int) >>  8) & x'000000ff'::int;
    pindex = 0;
    pOk = true;
    IF lid > 0 and puc > 0 THEN
      pindex = (lid-3)*3 + ((puc-1)%3);
      SELECT INTO pOk ((B'1'::bit(99) >> (pindex+12)) & dii) != B'0'::bit(99) FROM cats.di WHERE distn=stn;
    END IF;
    IF not pOk THEN
      rtn := 'Absent';
    ELSE
      SELECT hhState INTO rtn FROM px.holderHistory WHERE hhPosition=theId ORDER BY hhKey DESC LIMIT 1;
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getHolderPositionState( int) OWNER TO lsadmin;


CREATE TABLE px.errorSeverity (
       es text primary key,             -- text version of message
       ess int not null unique          -- sort order of severity (0=message, 2=fatal)
);
ALTER TABLE px.errorSeverity OWNER TO lsadmin;
INSERT INTO px.errorSeverity (ess, es) VALUES ( 0, 'message');
INSERT INTO px.errorSeverity (ess, es) VALUES ( 1, 'warning');
INSERT INTO px.errorSeverity (ess, es) VALUES ( 2, 'fatal');

CREATE TABLE px.errors (
       eKey serial primary key,                                 -- the Key
       eSeverity text not null references px.errorSeverity (es),        -- severity of error
       eid int not null unique,                                 -- identifier for this error (for client processing)
       eTerse text not null,                                    -- terse error
       eVerbose text not null                                   -- long winded version of the error
);
ALTER TABLE px.errors OWNER TO lsadmin;

INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('message', 1, 'Test Message 1', 'This message is here to test the error handling severity 0');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('message', 2, 'Test Message 2', 'This alternate message is here to test the error handling severity 0');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('warning', 3, 'Test Warning 1', 'This warning is here to test the error handling severity 1');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('warning', 4, 'Test Warning 2', 'This alternate warning is here to test the error handling severity 1');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('fatal',   5, 'Test Error 1',   'This error is here to test the error handling severity 2');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('fatal',   6, 'Test Error 2',   'This alternate error is here to test the error handling severity 2');

INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('warning', 10001, 'Backup file not written: timeout', 'The hard link to the data file was not made due to a timeout');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('warning', 10002, 'Backup directory not created', 'A system error occured when attempting to create the backup directory');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('warning', 10003, 'Could not create link to data file', 'A backup copy of the data file could not be made');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('fatal',   10004, 'Could not create data directory', 'An attempt to create the data directory failed, cannot continue');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('warning', 10005, 'Shot definition deleted', 'The definition of this shot has been deleted after the image was queued for collection.  Disposing of the data.');

INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('warning', 20001, 'Is marccd running?', 'The requested data directory has not been validated.  Usually this is because marccd is not running');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('warning', 20002, 'Cannot Mount', 'Remove the currently mounted sample by hand and try again');



CREATE TABLE px.activeErrors (
       eaKey serial primary key,                        -- the key
       eaId int not null references px.errors (eid),    -- the error
       eaTs timestamp with time zone not null default now(), -- first occurance of this error
       eaStn int not null references px.stations (stnKey),
       eaDetails text,
       eaAcknowledged boolean not null default False,
       eaTsLast timestamp with time zone not null default now(), -- last occurance of this error
       eaCount int not null default 1                            -- number of errors yet to be ackknowledged
);
ALTER TABLE px.activeErrors OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.activeErrorInsertTF() returns trigger as $$
  DECLARE
    prev record;
  BEGIN
    SELECT * INTO prev FROM px.activeErrors WHERE eaStn=px.getStation() and not eaAcknowledged and eaId=NEW.eaid;
    IF FOUND THEN
      UPDATE px.activeErrors SET eaCount = eaCount+1, eaTsLast=now() WHERE eaKey=prev.eaKey;
      return NULL;
    END IF;
    return NEW;
  END;
$$ LANGUAGE PLPGSQL SECURITY DEFINER;
ALTER FUNCTION px.activeerrorinserttf() OWNER TO lsadmin;
CREATE TRIGGER activeErrorsInsertTrigger BEFORE INSERT ON px.activeerrors FOR EACH ROW EXECUTE PROCEDURE px.activeerrorinserttf();


CREATE TYPE px.errorType AS ( etKey bigint, etSeverity text, etId int, etTerse text, etVerbose text, etDetails text, etts timestamptz);

CREATE OR REPLACE FUNCTION px.nextErrors() returns setof px.errorType AS $$
  DECLARE
    rtn px.errorType;
  BEGIN
    FOR rtn IN SELECT eaKey, eSeverity, eiD, eTerse, eVerbose, eaDetails, eaTs
                 FROM px.activeErrors
                 LEFT JOIN px.errors ON eaId=eId
                 WHERE eaStn=px.getstation() and eaAcknowledged = False
                 ORDER BY eaTs desc LOOP
      return next rtn;
    END LOOP;
    DELETE FROM px.activeerrors WHERE eaAcknowledged and eats < now() - '10 minutes'::interval and eaStn=px.getstation();
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.nextErrors() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.nextErrors( theStn bigint) returns setof px.errorType AS $$
  DECLARE
    rtn px.errorType;
  BEGIN
    FOR rtn IN SELECT eaKey, eSeverity, eiD, eTerse, eVerbose, eaDetails, eaTs
                 FROM px.activeErrors
                 LEFT JOIN px.errors ON eaId=eId
                 WHERE eaStn=theStn and eaAcknowledged = False
                 ORDER BY eaTs desc LOOP
      return next rtn;
    END LOOP;
--    DELETE FROM px.activeerrors WHERE eaAcknowledged;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.nextErrors( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.acknowledgeError( theId int) RETURNS VOID AS $$
  DECLARE
  BEGIN
    UPDATE px.activeErrors SET eaAcknowledged=True WHERE eaId=theId and eaStn=px.getstation();
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.acknowledgeError( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.pushError( theId int, theDetails text) RETURNS VOID AS $$
  DECLARE
   sever int;
   ntfy text;
  BEGIN
    INSERT INTO px.activeErrors (eaId, eaStn, eaDetails) VALUES (theId, px.getstation()::int, theDetails);
    SELECT ess INTO sever FROM px.errors LEFT JOIN px.errorSeverity on eSeverity=es WHERE eid = theId;
    IF FOUND THEN
      SELECT CASE WHEN sever=0 THEN cnotifymessage
                  WHEN sever=1 THEN cnotifywarning
                  ELSE cnotifyerror
                  END
             INTO ntfy
             FROM px._config
             LEFT JOIN px.stations ON stnname=cstation
             WHERE stnkey=px.getstation();
      IF FOUND THEN
        EXECUTE 'NOTIFY ' || ntfy;
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.pushError( int, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.pushError( theStn bigint, theId int, theDetails text) RETURNS VOID AS $$
  DECLARE
   sever int;
   ntfy text;
  BEGIN
    INSERT INTO px.activeErrors (eaId, eaStn, eaDetails) VALUES (theId, theStn::int, theDetails);
    SELECT ess INTO sever FROM px.errors LEFT JOIN px.errorSeverity on eSeverity=es WHERE eid = theId;
    IF FOUND THEN
      SELECT CASE WHEN sever=0 THEN cnotifymessage
                  WHEN sever=1 THEN cnotifywarning
                  ELSE cnotifyerror
                  END
             INTO ntfy
             FROM px._config
             LEFT JOIN px.stations ON stnname=cstation
             WHERE stnkey=theStn;
      IF FOUND THEN
        EXECUTE 'NOTIFY ' || ntfy;
      END IF;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.pushError( bigint, int, text) OWNER TO lsadmin;



CREATE TYPE px.ui_stationType AS ( stnkey bigint, stnname text);
CREATE OR REPLACE FUNCTION px.ui_stations( esaf int) returns SETOF px.ui_stationType AS $$
  DECLARE
    rtn px.ui_stationType;
  BEGIN
    FOR rtn IN SELECT DISTINCT dsstn, stnname
      FROM px.datasets
      LEFT JOIN px.stations ON stnkey=dsstn
      WHERE dsesaf=esaf
      ORDER BY stnname
      LOOP
      return next rtn;
    END LOOP;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ui_stations( int) OWNER TO lsadmin;

CREATE TYPE px.ui_prefixType AS ( fp text, pid text);
CREATE OR REPLACE FUNCTION px.ui_prefixes( esaf int, station int) returns setof px.ui_prefixType AS $$
  DECLARE
    rtn px.ui_prefixType;
  BEGIN
    FOR rtn IN SELECT dsfp, dspid
      FROM px.datasets
      WHERE dsesaf=esaf and dsstn=station
      ORDER BY dskey desc
     LOOP
     return next rtn;
    END LOOP;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ui_prefixes( int, int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ui_snapNorms( pid text) returns setof text as $$
  DECLARE
    rtn text;
  BEGIN
    FOR rtn IN SELECT DISTINCT stype
      FROM px.shots
      WHERE sdspid=pid and sstate='Done'
      ORDER BY stype
    LOOP
      return next rtn;
    END LOOP;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ui_snapNorms( text) OWNER TO lsadmin;

CREATE TYPE px.ui_shotType AS ( skey bigint, sfn text);
CREATE OR REPLACE FUNCTION px.ui_shots( pid text, typ text) returns setof px.ui_shotType AS $$
  DECLARE
    rtn px.ui_shotType;
  BEGIN
    FOR rtn IN SELECT skey, sfn
      FROM px.shots
      WHERE stype=typ and sdspid=pid
      ORDER BY sindex
      LOOP
      return next rtn;
    END LOOP;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ui_shots( text, text) OWNER TO lsadmin;

CREATE TYPE px.ui_detailType AS ( skey bigint, sindex int, sfn text, sstart numeric, swidth numeric, sexpt numeric, sexpu text, sphi numeric, somega numeric,
       skappa numeric, sdist numeric, snrg numeric, scmt text, sstate text, sposition int, sts timestamptz, dsdir text);


CREATE OR REPLACE FUNCTION px.ui_details( pid text, snapnorm text, theKey bigint, esaf int) returns setof px.ui_detailType AS $$
  DECLARE
    rtn px.ui_detailType;
  BEGIN
    FOR rtn IN SELECT 
          skey, sindex, sfn, coalesce(sstart,0) as sstart, coalesce(swidth,dsowidth,0) as swidth, coalesce(sexpt,dsexp,0) as sexpt,
          coalesce(sexpu,dsexpunit,'') as sexpu, coalesce(sphi,dsphi,0) as sphi, coalesce(somega,dsomega,0) as somega,
          coalesce(skappa,dskappa,0) as skappa, coalesce(sdist,dsdist,0) as sdist, coalesce(snrg,dsnrg,0) as snrg, coalesce(scmt,dscomment,'') as scmt,
          sstate, coalesce(sposition,dspositions[1],0) as sposition, sts, coalesce(dsdir,'') as dsdir
       FROM px.shots
       LEFT JOIN px.datasets on dspid=sdspid
       WHERE sdspid=pid and stype=snapnorm and sstate='Done' and skey=theKey and dsesaf=esaf
       ORDER BY sindex
       LOOP
         return next rtn;
     END LOOP;
     return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ui_details( text, text, bigint, int) OWNER TO lsadmin;


CREATE TABLE px.transferPoints (
       tpKey serial primary key,
       tpStn bigint references px.Stations (stnkey),
       tpStamp timestamp with time zone default now(),
       tpTableX numeric,
       tpTableY numeric,
       tpTableZ numeric,
       tpPhiAxisX numeric,
       tpPhiAxisY numeric,
       tpPhiAxisZ numeric,
       tpCenX numeric,
       tpCenY numeric,
       tpOmega numeric,
       tpKappa numeric
);
ALTER TABLE px.transferPoints OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.SetTransferPoint( tableX numeric, tableY numeric, tableZ numeric, phiX numeric, phiY numeric, phiZ numeric, cenX numeric, cenY numeric, omega numeric, kappa numeric) returns void as $$
  BEGIN
    UPDATE cats._toolcorrection SET tcx=0, tcy=0, tcz=0 WHERE tcstn=px.getStation();
    INSERT INTO px.transferPoints( tpStn, tpTableX, tpTableY, tpTableZ, tpPhiAxisX, tpPhiAxisY, tpPhiAxisZ, tpCenX, tpCenY, tpOmega, tpKappa) VALUES 
      ( px.getStation(), tableX, tableY, tableZ, phiX, phiY, phiZ, cenX, cenY, omega, kappa);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.SetTransferPoint( numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.SetTransferPoint( phiX numeric, phiY numeric, phiZ numeric, cenX numeric, cenY numeric) returns void AS $$
  DECLARE
   mp px.locationType;
  BEGIN
    SELECT * from px.rt_get_magnetPosition() INTO mp;
    PERFORM px.setTransferPoint( mp.x, mp.y, mp.z, phiX, phiY, phiZ, cenX, cenY, 0.0, 0.0);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.SetTransferPoint( numeric, numeric, numeric, numeric, numeric) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.abortTransfer() returns void AS $$
  BEGIN
  PERFORM cats.panic();
  return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.abortTransfer() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.logmagnetstate( boolean) returns void AS $$
-- OK, maybe this should be in the cats schema instead of the px schema, but here it is
  INSERT INTO cats.magnetstates (msStn, msSamplePresent) VALUES ( px.getStation(), $1);
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.logmagnetstate( boolean) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getmagnetstate() returns boolean AS $$
  SELECT msSamplePresent FROM cats.magnetstates WHERE msStn=px.getStation() ORDER BY msKey DESC LIMIT 1;
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.getmagnetstate() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getmagnetstate( bigint) returns boolean AS $$
  SELECT msSamplePresent FROM cats.magnetstates WHERE msStn=$1 ORDER BY msKey DESC LIMIT 1;
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.getmagnetstate( bigint) OWNER TO lsadmin;



CREATE TABLE px.lockstates  (
       lskey serial primary key,
       lsstate int not null unique,
       lstext text
);
ALTER TABLE px.lockstates OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.locks( theStn bigint) returns int AS $$
  SELECT bit_or((2^(objid::int-1))::int) FROM pg_locks LEFT JOIN pg_stat_activity ON procpid=pid WHERE locktype='advisory' and classid=$1;
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.locks( bigint) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.stnstatusxml() returns xml AS $$
  DECLARE
    lcks record;
    theStn record;
    rtn xml;
    tmp xml;
    tmp2 xml;
    shts record;
    st int;
    stt text;
  BEGIN
    FOR theStn IN SELECT * FROM px.stations ORDER BY stnkey LOOP
      SELECT bit_or((2^(objid::int-1))::int) INTO st FROM pg_locks LEFT JOIN pg_stat_activity ON procpid=pid WHERE locktype='advisory' and classid=theStn.stnkey;
      SELECT lstext INTO stt FROM px.lockstates WHERE lsstate=(st & b'111111'::int);
      SELECT * INTO shts
          FROM px.stnstatus
          LEFT JOIN px.shots ON ssskey=skey
          LEFT JOIN px.datasets ON sdspid=dspid
          WHERE ssStn=theStn.stnkey and ssesaf=dsesaf;
      IF FOUND THEN
        tmp2 := xmlelement( name file, xmlattributes( shts.skey as skey, shts.sfn as label, shts.spath as path, shts.sbupath as bupath, shts.ssesaf as esaf, case when shts.sspaused then 'true' else 'false' end as paused));
      ELSE
        tmp2 := NULL;
      END IF;
      tmp := xmlconcat( tmp, xmlelement( name lockstatus, xmlattributes( theStn.stnkey as stnkey, theStn.stnName as stnname, st as lockState, stt as label),tmp2));
    END LOOP;
    rtn := xmlelement( name "stationStatus", tmp);
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.stnstatusxml() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.stnstatusxml( thePid text) returns xml AS $$
  DECLARE
    lcks record;
    theStn record;
    rtn xml;
    tmp xml;
    tmp2 xml;
    tmp3 xml;
    tmp4 xml;
    tmp5 xml;
    tmp6 xml;
    tmp7 xml;
    shts record;
    st int;
    stt text;
    eds record;  -- editing dataset
    rqs record;  -- runqueue
    esaf int;    -- current esaf
    kvpname text;
    kvpvalue text;
    thePrefix text;
    theStatus text;
  BEGIN
    FOR theStn IN SELECT * FROM px.stations WHERE rmt.checkstnaccess( stnkey, thePid) ORDER BY stnkey LOOP
      SELECT bit_or((2^(objid::int-1))::int) INTO st FROM pg_locks LEFT JOIN pg_stat_activity ON procpid=pid WHERE locktype='advisory' and classid=theStn.stnkey;
      SELECT lstext INTO stt FROM px.lockstates WHERE lsstate=(st & b'111111'::int);
      SELECT INTO esaf ssesaf FROM px.stnstatus WHERE ssstn=theStn.stnkey;
      SELECT * INTO shts
          FROM px.stnstatus
          LEFT JOIN px.shots ON ssskey=skey
          LEFT JOIN px.datasets ON sdspid=dspid
          WHERE ssStn=theStn.stnkey and ssesaf=dsesaf;
      tmp2 := NULL;
      IF FOUND THEN
        tmp2 := xmlelement( name file, xmlattributes( shts.skey as skey, shts.sfn as label, shts.spath as path, shts.sbupath as bupath));
      END IF;
      tmp3 := NULL;
      SELECT * INTO eds FROM px.datasets WHERE dspid=shts.ssdsedit;
      IF FOUND THEN
        tmp3 := xmlelement( name edit, xmlattributes(  eds.dspid as dspid, eds.dsdir as dsdir, eds.dsdirs as dsdirs, eds.dsfp as dsfp, eds.dsstart as dsstart, eds.dsdelta as dsdelta, eds.dsowidth as dsowidth,
                            eds.dsnwedge as dsnwedge, eds.dsend as dsend, eds.dsexp as dsexp, eds.dsexpunit as dsexpunit, eds.dsphi as dsphi, eds.dsomega as dsomega, eds.dskappa as dskappa,
                            eds.dsdist as dsdist, eds.dsnrg as dsnrg, px.ds_get_nframes( eds.dspid) as nframes, eds.dseditnum as dseditnum));
      END IF;
      tmp4 := NULL;
      FOR rqs IN SELECT * FROM px.runqueue_get( theStn.stnkey) LOOP
        SELECT dsfp, (count(*)-count(nullif(sstate,'Done')))::text || '/' || count(*)::text INTO thePrefix, theStatus
              FROM px.datasets
              LEFT JOIN px.shots ON dspid=sdspid
              WHERE sdspid=rqs.dspid and stype=rqs.type
              GROUP BY dsfp
              LIMIT 1;
        tmp4 := xmlconcat( tmp4, xmlelement( name entry, xmlattributes( rqs.dspid as dspid, rqs.type as "type", rqs.k as k, rqs.etc as etc, thePrefix as fp, theStatus as status)));
      END LOOP;

      tmp5 = NULL;
      FOR kvpname, kvpvalue IN SELECT kvname, kvvalue FROM px.kvs WHERE kvstn=theStn.stnkey LOOP
        tmp5 = xmlconcat( tmp5, xmlelement( name kvpair, xmlattributes( kvpname as name, kvpvalue as value)));
      END LOOP;

      SELECT cats.getrobotstatekvpxml( theStn.stnkey) INTO tmp6;
      SELECT px.uistatus_get_xml( thePid, theStn.stnkey) INTO tmp7;

      tmp := xmlconcat( tmp, xmlelement( name station, xmlattributes( theStn.stnkey as stnkey, theStn.stnName as stnname),
                             xmlelement( name kvpair, xmlattributes( esaf as value, 'esaf' as name)),
                             xmlelement( name kvpair, xmlattributes( shts.ssmode as value, 'mode' as name)),
                             xmlelement( name kvpair, xmlattributes( shts.ssselectedposition as value, 'selectedPostion' as name)),
                             xmlelement( name kvpair, xmlattributes( st as value, 'lockState' as name)),
                             xmlelement( name kvpair, xmlattributes( stt as value, 'label' as name)),
                             xmlelement( name kvpair, xmlattributes( px.rt_get_dist( theStn.stnkey) as value, 'dist' as name)),
                             xmlelement( name kvpair, xmlattributes( px.rt_get_wavelength( theStn.stnkey) as value, 'wavelength' as name)),
                             xmlelement( name kvpair, xmlattributes( px.rt_get_ni0( theStn.stnkey) as value, 'ni0' as name)),
                             tmp2, tmp3, xmlelement( name runqueue, tmp4), tmp5, tmp6, tmp7
                        ));
    END LOOP;
    rtn := xmlelement( name "stationStatus", xmlelement( name aps, xmlelement( name kvpair, xmlattributes(  'current' as name, epics.caget( 'S:SRcurrentAI')::numeric(5,1) as value))), tmp);
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.stnstatusxml( text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.stnstatusxml( theExpNo int) returns xml AS $$
  DECLARE
    rtn xml;
    tmp  xml;
    tmp2 xml;
    shts record;
    theStn record;
    stt text;
    st int;
  BEGIN
    FOR theStn IN SELECT * FROM px.stations ORDER BY stnkey LOOP
      PERFORM 1 FROM px.stnstatus WHERE ssesaf=theExpNo and ssstn=theStn.stnkey;
      stt := NULL;
      st  := NULL;
      IF FOUND THEN
        SELECT bit_or((2^(objid::int-1))::int) INTO st FROM pg_locks LEFT JOIN pg_stat_activity ON procpid=pid WHERE locktype='advisory' and classid=theStn.stnkey;
        SELECT lstext INTO stt FROM px.lockstates WHERE lsstate=(st & b'111111'::int);
      END IF;
      SELECT skey, coalesce(sfn,'') as sfn, coalesce(spath,'') as spath, coalesce(sbupath,'') as sbupath INTO shts
          FROM px.esafstatus
          LEFT JOIN px.shots ON esskey=skey
          LEFT JOIN px.datasets ON sdspid=dspid
          WHERE esStn=theStn.stnkey and esesaf = theExpNo;
      IF FOUND THEN
        tmp2 := xmlelement( name file, xmlattributes( shts.skey as skey, shts.sfn as label, shts.spath as path, shts.sbupath as bupath));
      ELSE
        tmp2 := NULL;
      END IF;
      tmp := xmlconcat( tmp, xmlelement( name station, xmlattributes( theStn.stnkey as stnkey, theStn.stnname as stnname, st as lockState, stt as lockText), tmp2));
    END LOOP;
    rtn := xmlelement( name "stationStatus", tmp);
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.stnstatusxml( int) OWNER TO lsadmin;


CREATE TABLE px.stnmodes (
       sm text primary key
);
ALTER TABLE px.stnmodes OWNER TO lsadmin;

INSERT INTO px.stnmodes (sm) VALUES ('CollectState');
INSERT INTO px.stnmodes (sm) VALUES ('CenterState');
INSERT INTO px.stnmodes (sm) VALUES ('ParamsState');
INSERT INTO px.stnmodes (sm) VALUES ('RecoverState');
INSERT INTO px.stnmodes (sm) VALUES ('SampleState');
INSERT INTO px.stnmodes (sm) VALUES ('TransferState');



CREATE TABLE px.stnstatus (
	sskey serial primary key,
        ssts timestamp with time zone default now(),
	ssstn bigint references px.stations (stnkey) unique,
	ssesaf int,
	ssskey bigint references px.shots (skey) on delete set null unique,
	sssfn  text default null,	-- copy of shots table entry
	ssspath text default null,      -- copy of shots table entry
        sssbupath text default null,     -- copy of shots table entry
        ssdsedit text default null references px.datasets (dspid),
        sspaused boolean not null default false,
	ssmode text default null references px.stnmodes (sm) on update cascade on delete set null
);
ALTER TABLE px.stnstatus OWNER TO lsadmin;

CREATE TABLE px.uistatus (
       --
       -- Support to synchronize remote UI's
       -- 
       uikey serial primary key,	-- our key
       uisskey bigint not null		-- the station status this is part of
       	       references px.stnstatus (sskey) on delete cascade,
       uin int not null default 0,	-- the edit number for this variable
       uik text,			-- the k of the kv pair
       uiv text				-- the v of the kv pair
);
ALTER TABLE px.uistatus OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.uistatusUpdateTF() returns trigger as $$
  --
  -- Auto increment the edit number for each field
  --
  DECLARE
  BEGIN
    new.uin = old.uin + 1;
    return new;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.uistatusUpdateTF() OWNER TO lsadmin;

CREATE TRIGGER uistatusUpdateTrigger BEFORE UPDATE ON px.uistatus FOR EACH ROW EXECUTE PROCEDURE px.uistatusUpdateTF();


CREATE OR REPLACE FUNCTION px.uistatus_set( pid text, theStn bigint, theKey text, theValue text) returns void as $$
  --
  --  Set a key/value pair for the UI
  --
  DECLARE
    theSSKey bigint;
  BEGIN

    PERFORM 1 WHERE rmt.checkstnaccess( theStn, pid);
    IF NOT FOUND THEN
      --
      -- Silently ignore invalid request
      --
      return;
    END IF;
    --
    -- Assume that there is an entry for this theStn in stnstatus as one should be created when
    -- logging in
    --
    SELECT INTO theSSKey sskey FROM px.stnstatus LEFT JOIN px.uistatus on sskey=uisskey WHERE ssstn=theStn and uik=theKey;
    IF FOUND THEN
      UPDATE px.uistatus SET uiv = theValue WHERE uisskey = theSSKey and uik = theKey;
    ELSE
      INSERT INTO px.uistatus (uisskey, uik, uiv) VALUES ((SELECT sskey FROM px.stnstatus WHERE ssstn=theStn), theKey, theValue);
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.uistatus_set( text, bigint, text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.uistatus_get_xml( pid text, theStn bigint) returns xml as $$
  DECLARE
    rtn xml;
    tmp xml;
    k text;
    v text;
    n int;
  BEGIN
    PERFORM 1 WHERE rmt.checkstnaccess( theStn, pid);
    IF NOT FOUND THEN
      return xmlelement( name uistatus, xmlattributes( 'false' as success, 'Access denied' as msg));
    END IF;
    
    FOR k, v, n IN SELECT uik, uiv, uin FROM px.stnstatus LEFT JOIN px.uistatus ON sskey=uisskey WHERE ssstn = theStn and uik is not null LOOP
      tmp = xmlconcat( tmp, xmlelement( name kvpair, xmlattributes( k as name, v as value, n as nedit)));
    END LOOP;
    rtn = xmlelement( name uistatus, xmlattributes( theStn as stn), tmp);
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.uistatus_get_xml( text, bigint) OWNER TO lsadmin;



CREATE TABLE px.esafstatus (
	eskey serial primary key,
        ests timestamp with time zone default now(),
	esstn bigint references px.stations (stnkey),
	esesaf int,
	esskey bigint references px.shots (skey) on delete set null unique,
        essfn text default null,
        esspath text default null,
        essbupath text default null,
        esdsedit text default null references px.datasets (dspid)
        unique (esesaf,esstn)
);
ALTER TABLE px.esafstatus OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.esafstatusInsertTF() returns trigger AS $$
  DECLARE
    expid int;
  BEGIN
    SELECT ssesaf INTO expid FROM px.stnstatus WHERE ssstn=px.getStation();
    IF NOT FOUND OR expid is NULL or expid=0 THEN
      RETURN NULL;
    END IF;

    PERFORM 1 FROM px.esafstatus WHERE esstn=px.getstation() and esesaf=expid;
    IF FOUND THEN
      UPDATE px.esafstatus SET ests=now(), esskey=NEW.esskey WHERE esstn=px.getStation() and esesaf=expid;
      return NULL;
    END IF;

    NEW.esesaf := expid;
    NEW.esstn  := px.getStation();
    return NEW;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.esafstatusInsertTF() OWNER TO lsadmin;
CREATE TRIGGER esafstatusInsertTrigger BEFORE INSERT ON px.esafstatus FOR EACH ROW EXECUTE PROCEDURE px.esafstatusInsertTF();



CREATE OR REPLACE FUNCTION px.stnstatusUpdateTF() returns trigger AS $$
  DECLARE
  BEGIN
    NEW.ssts = now();
    return NEW;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.stnstatusUpdateTF() OWNER TO lsadmin;
CREATE TRIGGER stnstatusUpdateTrigger BEFORE UPDATE ON px.stnstatus FOR EACH ROW EXECUTE PROCEDURE px.stnstatusUpdateTF();


CREATE OR REPLACE FUNCTION px.login( expid int, thepwd text) returns boolean as $$
  DECLARE
    rtn boolean;
  BEGIN
    SELECT INTO rtn px.login( px.getstation(), expid, thepwd);
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.login( int, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.login( theStn bigint, expid int, thepwd text) returns boolean as $$
  DECLARE
    rtn boolean;
    lastInfo record;
    token text;
  BEGIN
    PERFORM px.logout( theStn);
    SELECT esaf.checkPassword( expid, thepwd) INTO rtn;
    IF rtn = True THEN
      INSERT INTO px.stnstatus (ssstn, ssesaf) VALUES (theStn, expid);
      SELECT INTO lastInfo *
             FROM px.datasets
             LEFT JOIN px.shots ON dspid=sdspid
             WHERE dsesaf=expid
               and dsstn=theStn
             ORDER BY sts desc
             LIMIT 1;
      IF FOUND THEN
        UPDATE px.stnstatus SET ssskey=lastInfo.skey, ssdsedit=lastInfo.dspid WHERE ssstn=theStn;
      ELSE
        SELECT INTO token px.newdataset( theStn, expid);
	UPDATE px.stnstatus SET ssdsedit=token WHERE ssstn=theStn;
      END IF;
      PERFORM px.autologinnotify( theStn);
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.login( bigint, int, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.logout() returns void as $$
  DECLARE
  BEGIN
    PERFORM px.logout( px.getstation());
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.logout() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.logout( theStn bigint) returns void as $$
  DECLARE
  BEGIN
    --UPDATE px.stnstatus SET ssesaf=NULL WHERE ssstn=theStn;
    DELETE FROM px.stnstatus WHERE ssstn=theStn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.logout( bigint) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.whoami( theStn bigint) returns text AS $$
  DECLARE
    rtn text;
  BEGIN
    SELECT INTO rtn 'e' || ssesaf from px.stnstatus WHERE ssstn=theStn;
    IF FOUND THEN
      return rtn;
    END IF;
    return NULL;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.whoami( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.whoami() returns text AS $$
  SELECT px.whoami( px.getstation());
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.whoami() OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.rt_get_twitter() returns text AS $$
--
-- Normalized Io
  DECLARE
    theCurrent numeric;
    theIzero   numeric;
    stn        record;
    rtn        text;
    tmp        text;
  BEGIN
    theCurrent := epics.caget( 'S:SRcurrentAI');
    rtn := 'APS: ' || to_char(theCurrent, '99999.9');
    FOR stn IN SELECT * from px.stations LOOP
      select epics.caget( epvmlpv) into tmp FROM px.epicsPVMLink WHERE epvmlStn=stn.stnkey AND epvmlName='Io';
      raise notice 'theIzero (maybe): %', tmp;
      IF tmp LIKE '0.0%' THEN
        theIzero := 0;
      ELSE
        SELECT coalesce(epics.caget( epvmlpv),'0') INTO theIzero FROM px.epicsPVMLink WHERE epvmlStn=stn.stnkey AND epvmlName='Io';
        IF NOT FOUND THEN
          theIzero := 1;
        END IF;
        IF theIzero < 1 THEN
          theIzero = 0;
        END IF;
      END IF;
      rtn := rtn || '  ' || stn.stnshortname || ': ' || (theIzero::int)::text;
    END LOOP;

    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_twitter() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getShotsXml( pid text, token text) returns xml as $$
  --
  -- just like the original get shots execpt return is xml.
  -- pid is the session pid from the rmt schema
  -- token is the dataset pid: dspid
  --
  DECLARE
    rtn xml;
    tmp xml;
    shts record;
    aok boolean;
    paused_t text;
  BEGIN
    SELECT rmt.checkTokenAccess( pid, token) INTO aok;
    IF NOT FOUND or NOT aok THEN
      return '<shots/>'::xml;
    END IF;

    tmp := NULL;
    FOR shts IN SELECT * FROM px.getShots( token) LOOP
      tmp := xmlconcat( tmp, xmlelement( name shot, xmlattributes( shts.sfn as sfn, shts.stype as stype, shts.sstart as sstart, shts.sstate as sstate, shts.sindex as sindex, shts.skey as skey, shts.sbupath as sbupath)));
    END LOOP;

    SELECT case when px.stnstatus.sspaused then 'true' else 'false' end INTO paused_t FROM px.stnstatus LEFT JOIN px.datasets on dspid=token WHERE ssstn=dsstn;
    rtn := xmlelement( name "shots", xmlattributes( token as sdspid, paused_t as paused), tmp);

    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getShotsXml( text, text) OWNER TO lsadmin;


CREATE TABLE px.kvs (
       kvkey serial primary key,
       kvts  timestamptz not null default now(),
       kvstn bigint references px.stations (stnkey),
       kvname text not null,
       kvvalue text,
       UNIQUE( kvstn, kvname)
);
ALTER TABLE px.kvs OWNER TO lsadmin;
CREATE INDEX kvsNameIndex ON px.kvs (kvstn,kvname);

CREATE OR REPLACE FUNCTION px.kvsInsertTF() returns trigger as $$
  DECLARE

  BEGIN
    NEW.kvstn = px.getStation();
    PERFORM 1 FROM px.kvs WHERE kvname=NEW.kvname and kvstn=NEW.kvstn;
    IF FOUND THEN
      UPDATE px.kvs SET kvts=now(), kvvalue=NEW.kvvalue WHERE kvname=NEW.kvname and kvstn=NEW.kvstn;
      return NULL;
    END IF;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.kvsInsertTF() OWNER TO lsadmin;
CREATE TRIGGER kvsInsertTrigger BEFORE INSERT ON px.kvs FOR EACH ROW EXECUTE PROCEDURE px.kvsInsertTF();

CREATE OR REPLACE FUNCTION px.kvupdate( kvps text[]) returns void as $$
  DECLARE
  BEGIN
    FOR i IN array_lower( kvps,1) .. array_upper( kvps,1) BY 2 LOOP
      INSERT INTO px.kvs (kvname,kvvalue) VALUES (kvps[i],kvps[i+1]);
    END LOOP;
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.kvupdate( text[]) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.kvget( theStn bigint, k text) returns text as $$
  SELECT  kvvalue FROM px.kvs WHERE kvstn=$1 and kvname=$2 LIMIT 1;
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.kvget( bigint, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.kvget( k text) returns text as $$
  SELECT  kvvalue FROM px.kvs WHERE kvstn=px.getStation() and kvname=$1 LIMIT 1;
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.kvget( text) OWNER TO lsadmin;


CREATE TABLE px.tunamemory (
       --
       -- Simple key/value memory for tuna programs
       -- Each station gets it's own memory space
       -- Currently Memory is both global and persistant
       --
       mKey serial primary key,				-- our table key
       mCreateTS timestamptz default now(),		-- creation time stamp
       mSetTS    timestamptz default now(),		-- time varaible was last set
       mGetTS    timestamptz default null,		-- time varable was last read
       mStn bigint references px.stations( stnkey),	-- station number
       mK   text not null,				-- variable name
       mV   text default null,				-- value
       UNIQUE( mStn, mK)				-- only single values are permitted
);
ALTER TABLE px.tunamemory OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.tunamemoryget( theStn bigint, k text) returns text as $$
  DECLARE
    theKey bigint;
    rtn text;
  BEGIN
    SELECT mKey, mV INTO theKey, rtn FROM px.tunamemory WHERE mStn=theStn and mK=k;
    IF FOUND THEN
        UPDATE px.tunamemory SET mGetTS=now() WHERE mKey=theKey;
        return  rtn;
    END IF;
    return null;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.tunamemoryget( bigint, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.tunamemoryset( theStn bigint, k text, v text) returns void as $$
  DECLARE
  BEGIN
    PERFORM 0 FROM px.tunamemory WHERE mStn = theStn and mK = k;
    IF FOUND THEN
      UPDATE px.tunamemory SET mV=v, mSetTS=now() WHERE mStn=theStn and mK=k;
    ELSE
      INSERT INTO px.tunamemory (mStn,mK,mV) VALUES (theStn,k,v);
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.tunamemoryset( bigint, text, text) OWNER TO lsadmin;


CREATE TABLE px.tunacode (
--
-- something's fishy about this
--
       tcKey serial primary key,				-- our table key
       tcstn bigint references px.stations (stnkey),    -- Keep the stations separate
       tccreatets timestamptz not null default now(),	-- time our entry was created
       tccstartts timestamptz default null,		-- time first iteration was started
       tcstartts  timestamptz default null,		-- time most recent iteration was started
       tccendts   timestamptz default null,		-- time most recent iteration ended
       tcn        int default 0,			-- Number of times this line has been run;
       tclevel    int default 0,			-- Stack level to support loops
       tcinstruction text default ''			-- default instruction       
);
ALTER TABLE px.tunacode OWNER TO lsadmin;

CREATE TABLE px.tunapc (
       -- tuna program counter
       -- A running program has one or more program counters
       --
       pcKey serial primary key,		-- our table key
       pcStn bigint references px.stations (stnkey),
       pcStack int default 0,			-- level: subroutine calls insert a new pc
       pcpc bigint references px.tunacode,	-- pointer to our program
       UNIQUE( pcStn, pcStack)			-- only allow one pointer per stack level
);
ALTER TABLE px.tunapc OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.tunaNextPC( theStn bigint) returns bigint as $$
  DECLARE
    stack int;		-- how deep are we?
    instruct text;	-- the current instruction: control statements are dealt with here
    icount int;		-- the iteration counter of the current statement
    pc  bigint;		-- current program counter
    rtn bigint;		-- return value: the next program counter for the next non-statement instruction
    tmp bigint;		-- address of RETURN statement
    test text;		-- SQL that evaluates to a boolean
    testResult boolean;	-- the result of executing "test"
  BEGIN

    -- Get the stack level and the current program counter
    SELECT pcStack, pcpc INTO stack, pc FROM px.tunapc WHERE pcstn=theStn ORDER BY pcStack desc;  -- unique contraint on px.tunapc forces this to return 0 or 1 rows
    IF NOT FOUND THEN
       -- No legal program, just exit now
       return 0;
    END IF;

    -- Get the next line of the program
    SELECT tcKey INTO rtn FROM px.tunacode WHERE tcstn=theStn and tcKey > pc ORDER BY tcKey asc LIMIT 1;
    IF NOT FOUND THEN
      -- Th-Th-Th-That's all folks!
      -- No more code to run
      rtn := 0;
      stack := -1;
     END IF;

    -- Check for control statements
    WHILE stack >= 0 LOOP    
      SELECT tcinstruction, tcn INTO instruct,icount FROM px.tunacode WHERE tcKey=rtn;
      IF NOT FOUND THEN
       -- This is probably an error condition, like a line got deleted while running.
        rtn := 0;
        EXIT;
      END IF;

      -- Dumb parser, should be OK for now


      IF instruct = 'RETURN' and stack=0 THEN
        -- Return from main does the expected thing.
        rtn := 0;
        EXIT;

      ELSEIF instruct = 'RETURN' THEN
        -- subroutine return: main return is handled above so we know that here stack>0
        DELETE FROM px.tunapc WHERE pcStn=theStn and pcStack >= stack;
        -- recurse to find the next line
        rtn := px.tunaNextPC( theStn);
        EXIT;

      ELSEIF instruct like 'WHILE %' or instruct like 'LOOP %' THEN
        -- Loops
        --
        -- The "WHILE" argument evaluates to a boolean
        -- The "LOOP" argument evaluates in an integer which is then compared to the statement iteration counter
        --
        --
        -- Update time stamp(s)
        --
        UPDATE px.tunacode SET tccstartts=coalesce( tccstartts,clock_timestamp()), tcstartts=clock_timestamp() WHERE tcKey=rtn;
        --
        -- Reset inner loop counters, if any
        --
        UPDATE px.tunacode SET tcn=0 WHERE tcStn=theStn and tcKey>rtn and tclevel > stack and tcKey< (select tcKey FROM px.tunacode WHERE tcKey>rtn and tcinstruction='RETURN' ORDER BY tcKey asc LIMIT 1);

        --
        -- Set up the test string
        --
        IF instruct like 'WHILE %' THEN
          -- Simple evaluation
          SELECT substring( instruct, 7) INTO test;
        ELSE
          -- Compare with iteration counter
          SELECT icount || ' < (' || substring( instruct, 6) || ')' INTO test;
        END IF;

        -- make the test
        EXECUTE 'SELECT ' || test INTO testResult;
        --
        -- Update counters and time stamp
        --

        UPDATE px.tunacode SET tcn=tcn+1, tccendts=clock_timestamp() WHERE tcKey=rtn;

        -- See what to do next;
        IF testResult THEN
          -- increment the program counter stack
          INSERT INTO px.tunapc (pcstn, pcpc, pcStack) VALUES (theStn, rtn, stack+1);
          
          -- recurse to get the next line of executable code
          SELECT px.tunaNextPC( theStn) INTO rtn;

          EXIT;
        ELSE
          -- Find the corresponding RETURN statement
          SELECT tcKey INTO tmp FROM px.tunacode WHERE tcStn=theStn and tcKey > rtn and tclevel=stack+1 and tcinstruction='RETURN' ORDER BY tcKey asc LIMIT 1;
          IF NOT FOUND THEN
            -- No return? Should raise error but will return end of program instead.
            rtn := 0;
            EXIT;
          END IF;
          -- Set the program counter at this position
          UPDATE px.tunapc SET pcpc=tmp WHERE pcstn=theStn and pcStack=stack;

          -- Find the next instruction
          SELECT tcKey INTO rtn FROM px.tunacode WHERE tcStn=theStn and tcKey > tmp ORDER BY tcKey asc LIMIT 1;

          IF NOT FOUND THEN
            -- Program ended in a subroutine.  Should raise error but will return end of program instead.
            rtn := 0;
            EXIT;
          END IF;

        END IF;
      ELSEIF instruct = 'START' THEN
        -- 
        -- START should never appear anywhere except as the first line of code
        -- and hence can never be the next statement
        --
        RAISE EXCEPTION 'START found as the next statement contrary to expectations.';
      ELSE
        --
        -- This is not a control statement, return it
        --
        -- make the program counter point here
        UPDATE px.tunapc SET pcpc=rtn WHERE pcstn=theStn and pcStack=stack;
        EXIT;
      END IF;

    END LOOP;

    IF rtn = 0 THEN
      -- Officially end the program by deleting the counters
      DELETE FROM px.tunapc WHERE pcstn=theStn;
    END IF;

    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.tunaNextPC( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.tunaLoadInit( theStn bigint) returns void as $$
  DECLARE
  BEGIN
    -- clear out the previous program, if any
    DELETE FROM px.tunapc   WHERE pcStn=theStn;
    DELETE FROM px.tunacode WHERE tcStn=theStn;
    
    -- Add the start statement
    INSERT INTO px.tunacode (tcstn, tcinstruction, tclevel) VALUES (theStn, 'START', 0);
    INSERT INTO px.tunapc   (pcstn, pcpc, pcstack) VALUES (theStn, currval('px.tunacode_tckey_seq'), 0);

  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.tunaLoadInit( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.tunaLoad( theStn bigint, istep text) returns void as $$
  DECLARE
    theLevel int;	-- current level of code
    lastIStep text;	-- the previous instruction step
  BEGIN

    IF istep = 'START' THEN
      RAISE EXCEPTION 'START is a reserved keyword';
    END IF;

    -- Figure out the current level
    SELECT tclevel,tcinstruction INTO theLevel, lastIStep FROM px.tunacode WHERE tcstn=theStn ORDER BY tckey desc LIMIT 1;
    IF NOT FOUND THEN
      -- Easy, this is the first line
      theLevel := 0;
    ELSE
      IF lastIStep='RETURN' THEN
        theLevel := theLevel - 1;
      END IF;
    END IF;

    IF theLevel < 0 THEN
      RAISE EXCEPTION 'Too many RETURN statements';
    END IF;

    IF istep like 'WHILE %' or istep like 'LOOP %' THEN
      theLevel := theLevel + 1;
    END IF;
  
    --  Add the step
   INSERT INTO px.tunacode (tcstn, tcinstruction, tclevel) VALUES (theStn, istep, theLevel);

  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.tunaLoad( bigint, text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.tunaStep( theStn bigint) returns int as $$
  --
  -- Execute one line of tuna code
  -- and advance program counter
  --
  -- key words: RETURN, WHILE, LOOP
  --
  DECLARE
    rtn int;	-- number of lines run: 0 or 1, 0 signaling the end of the program
    pc bigint;	-- program counter
    stack int;  -- stack level
    npc bigint;	-- new program counter
    theI text;	-- the instruction
  BEGIN
    rtn := 0;
    
    --
    -- Get the next program counter
    -- This function returns the address of an executable line, not a control structure
    --
    SELECT px.tunaNextPC( theStn) INTO pc;
    IF pc = 0 THEN
      DELEtE FROM px.tunapc WHERE pcStn=theStn;
      return 0;
    END IF;

    --
    -- Get our instruction
    --
    SELECT tcinstruction INTO theI FROM px.tunacode WHERE tckey = pc;

    --
    -- Update time stamp(s)
    --
    UPDATE px.tunacode SET tccstartts=coalesce( tccstartts,clock_timestamp()), tcstartts=clock_timestamp() WHERE tcKey=pc;
    
    IF length( theI) > 0 THEN
      rtn := 1;
      --
      -- Do the user's bidding.  Scary.  At least only select calls are allowed.
      EXECUTE 'SELECT ' || theI;
    END IF;
    --
    -- Update counters and time stamp
    --
    UPDATE px.tunacode SET tcn=tcn+1, tccendts=clock_timestamp() WHERE tcKey=pc;

    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.tunaStep( bigint) OWNER TO lsadmin;




CREATE OR REPLACE FUNCTION px.testSamples( theStn int, samples int[], ntimes int, wtime int) returns void AS $$
  DECLARE
    s int;	-- the current sample
    tms text;   -- tunamemoryset( theStn,
    tmse text;   -- ')'
    tmg text;   -- tunamemoryget( theStn,
    tmge text;  -- ')'
    dew text;
    puc text;
    sam text;
    lab text;
  BEGIN

    tms := 'px.tunamemoryset('||theStn::text||',';
    tmse := ')';
    tmg := 'px.tunamemoryget('||theStn::text||',';
    tmge := ')';

    PERFORM px.tunaLoadInit( theStn);	-- initialize tuna program
    PERFORM px.tunaLoad( theStn, tms || '''loopCounter'',''' || ntimes::text || '''' || tmse );  -- initialize the loop counter
    PERFORM px.tunaLoad( theStn, 'WHILE ' || tmg || '''loopCounter'''||tmge||'::int > 0');             -- start loop

    FOR i IN array_lower( samples, 1) .. array_upper( samples, 1) LOOP
      IF (((samples[i] & x'ff000000'::int)>>24) & x'ff'::int) = theStn THEN
        s := samples[i];
        dew := (((s & x'00ff0000'::int) >> 16)  - 2)::text;
        puc := ((((s & x'0000ff00'::int) >>  8) -1 )%3 + 1)::text;
        sam :=   (s & x'000000ff'::int)::text;

        lab := 'Dewar: ' || dew || ' Puck: ' || puc || ' Sample: ' || sam;

        PERFORM px.tunaLoad( theStn, tms || '''Status'', ''Mounting ' || lab || '''' || tmse);
        PERFORM px.tunaLoad( theStn, tms || '''terseStatus'', ''Mounting''' || tmse);
        PERFORM px.tunaLoad( theStn, tms || '''sampleNo'', '''|| s::text || '''' || tmse);

        PERFORM px.tunaLoad( theStn, 'px.requestTransfer( ' || theStn::text || ',''' || s::text || ''')' );

        -- Wait until the correct sample is mounted
        PERFORM px.tunaLoad( theStn, 'WHILE px.getCurrentSampleId( ' || theStn::text || ') != '||s::text);
        PERFORM px.tunaLoad( theStn,   '1');
        PERFORM px.tunaLoad( theStn, 'RETURN');

        PERFORM px.tunaLoad( theStn, tms || '''Status'', ''Mounted ' || lab || '''' || tmse);
        PERFORM px.tunaLoad( theStn, tms || '''terseStatus'', ''Mounted''' || tmse);

        -- Sleep, part one
        PERFORM px.tunaLoad( theStn, tms || '''WaitUntilTime'', (now()+'''||wtime::text||' seconds''::interval)::text'  ||tmse);

        -- Wait for the robot to finish its cycle
        -- Not in exclusion zone, path not running, Diffractometer on and has AR, cryo locked
        PERFORM px.tunaLoad( theStn, 'WHILE ("State" & 739) != 99 FROM cats.machinestate('|| theStn::text ||')');
        PERFORM px.tunaLoad( theStn,   '1');
        PERFORM px.tunaLoad( theStn, 'RETURN');

        PERFORM px.tunaLoad( theStn, tms || '''Status'', '|| '''Waiting for the thaw ' || lab || '''' || tmse);
        PERFORM px.tunaLoad( theStn, tms || '''terseStatus'', ''Waiting''' || tmse);

        -- Sleep, part two
        PERFORM px.tunaLoad( theStn, 'WHILE ' || tmg || '''WaitUntilTime'''|| tmge || '::timestamptz > now()');
        PERFORM px.tunaLoad( theStn,   '1');
        PERFORM px.tunaLoad( theStn, 'RETURN');

      END IF;
    END LOOP;
    -- Decrement Counter
    PERFORM px.tunaLoad( theStn, tms || '''loopCounter'', (' || tmg || '''loopCounter''' || tmge || '::int - 1)::text'||tmse);
    PERFORM px.tunaLoad( theStn, 'RETURN'); -- end loop

    PERFORM px.tunaLoad( theStn, tms || '''Status'', '|| '''Dismounting ' || lab || '''' || tmse);
    PERFORM px.tunaLoad( theStn, tms || '''terseStatus'', ''Dismounting''' || tmse);
    PERFORM px.tunaLoad( theStn, tms || '''sampleNo'', ''0''' || tmse);

    PERFORM px.tunaLoad( theStn, 'px.requestTransfer( ' || theStn::text || ', 0)' );

    -- Wait until the correct sample is mounted
    PERFORM px.tunaLoad( theStn, 'WHILE px.getCurrentSampleId( ' || theStn::text || ') != 0');
    PERFORM px.tunaLoad( theStn,   '1');
    PERFORM px.tunaLoad( theStn, 'RETURN');

    -- Wait for the robot to finish its cycle
    PERFORM px.tunaLoad( theStn, 'WHILE ("State" & 739) != 99 FROM cats.machinestate(' || theStn::text || ')');
    PERFORM px.tunaLoad( theStn,   '1');
    PERFORM px.tunaLoad( theStn, 'RETURN');

    PERFORM px.tunaLoad( theStn, tms || '''Status'', '|| '''Done''' || tmse);
    PERFORM px.tunaLoad( theStn, tms || '''terseStatus'', ''Done''' || tmse);


  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.testSamples( int, int[], int, int) OWNER TO lsadmin;


CREATE TABLE px.trigcamtable (
       tckey serial primary key,
       tcStn bigint not null,
       tcts timestamptz not null,
       tcIp inet not null,
       tcPort int not null,
       tcZoom int,
       tcStartAngle float,
       tcSpeed float
);
ALTER TABLE px.trigcamtable OWNER TO lsadmin;

CREATE TYPE px.trigcamtype AS ( ip inet, port int, ts timestamptz, zoom int, startAngle float, speed float);

CREATE OR REPLACE FUNCTION px.gettrigcam( theStn bigint) RETURNS px.trigcamtype AS $$
  DECLARE
    rtn px.trigcamtype;
  BEGIN
    SELECT tcip, tcport, tcts, tcZoom, tcStartAngle, tcSpeed INTO rtn.ip, rtn.port, rtn.ts, rtn.zoom, rtn.startAngle, rtn.speed FROM px.trigcamtable WHERE tcStn=theStn ORDER BY tcts DESC LIMIT 1;
    --    DELETE FROM px.trigcamtable WHERE tcStn = theStn;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.gettrigcam( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.gettrigcam() RETURNS px.trigcamtype AS $$
  DECLARE
    rtn px.trigcamtype;
  BEGIN
    rtn = px.gettrigcam( px.getStation());
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.gettrigcam() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.gettrigcam( ntfy text) RETURNS px.trigcamtype AS $$
  DECLARE
    rtn px.trigcamtype;
    theStn bigint;
  BEGIN
    SELECT INTO theStn cstn FROM rmt.cams WHERE ntfy=ccenternotify;
    rtn := NULL;
    IF FOUND THEN
      rtn = px.gettrigcam( theStn);
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.gettrigcam(text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.trigcam( theStn bigint, ts timestamptz, zoom int, startAngle float, speed float) RETURNS VOID AS $$
  DECLARE
    theIp inet;
    thePort int;
    ntfy text; 
 BEGIN

  SELECT coalesce( cip, '127.0.0.1'::inet), coalesce(cport,0) INTO theIp, thePort FROM px.centertable WHERE cstn=theStn ORDER BY ckey DESC LIMIT 1;
  IF NOT FOUND THEN
    theIp := '127.0.0.1'::inet;
    thePort := 0;
  END IF;

  DELETE FROM px.trigcamtable WHERE tcStn = theStn;
  INSERT INTO px.trigcamtable (tcStn, tcts, tcZoom, tcStartAngle, tcSpeed, tcip, tcport) VALUES ( theStn, ts, zoom, startAngle, speed, theIp, thePort);
  SELECT cnotifycenter INTO ntfy FROM px._config WHERE cstnkey=theStn;
  EXECUTE 'NOTIFY ' || ntfy;

  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.trigcam( bigint, timestamptz, int, float, float) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.trigcam( ts timestamptz, zoom int, startAngle float, speed float) RETURNS VOID AS $$
  BEGIN
    PERFORM px.trigcam(px.getStation(), ts, zoom, startAngle, speed);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.trigcam( timestamptz, int, float, float) OWNER TO lsadmin;

CREATE TABLE px.centertable (
       ckey serial primary key,
       cts timestamptz default now(),
       cstn bigint not null,

       cpid text references rmt.pids (ppid),	-- request authentication
       cip inet not null,			-- ip address of requesting machine
       cport int not null,			-- requesting port

       czoom int not null default 1,
       cx float,	-- Centering table horizontal (focus direction)
       cy float,	-- Centering table vertical
       cz float,	-- Alignment table y (horizontal as seen on screen)
       b  float,	-- y offset to edge of screen
       t0 float         -- angle
);
ALTER TABLE px.centertable OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.setcenter( theStn bigint, thePid text, theIp inet, thePort int, zoom int, x float, y float, z float, b float, t0 float) returns void AS $$
  BEGIN
    PERFORM 1 WHERE rmt.checkstnaccess( theStn, thePid);
    IF FOUND THEN
      DELETE FROM px.centertable WHERE cstn=theStn;
      INSERT INTO px.centertable (cstn, cpid, cip, cport, czoom,cx,cy,cz, cb, ct0) VALUES (theStn, thePid, theIp, thePort, zoom, x, y, z, b, t0);
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.setcenter( bigint, text, inet, int, int, float, float, float, float, float) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.setcenter( thePid text, theIp inet, thePort int, zoom int, x float, y float, z float, b float, t0 float) returns void AS $$
  BEGIN
    PERFORM px.setcenter( px.getStation(), thePid, theIp, thePort, zoom, x, y, z, b, t0);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.setcenter( text, inet, int, int, float, float, float, float, float) OWNER TO lsadmin;


DROP TYPE px.centertype CASCADE;
CREATE TYPE px.centertype AS (pid text, ip inet, port int, zoom int, x float, y float, z float, b float, t0 float);

CREATE OR REPLACE FUNCTION px.getcenter( theStn bigint) returns px.centertype AS $$
  DECLARE
    rtn px.centertype;  
  BEGIN
    SELECT cpid, cip, cport, czoom, cx, cy, cz, cb, ct0 INTO rtn.pid, rtn.ip, rtn.port, rtn.zoom, rtn.x, rtn.y, rtn.z, rtn.b, rtn.t0 FROM px.centertable WHERE cstn=theStn ORDER BY ckey DESC LIMIT 1;
    IF NOT FOUND THEN
      rtn.pid = '0';
      rtn.ip  = '127.0.0.1'::inet;
      rtn.port = 0;
      rtn.zoom = 1;
      rtn.x = 0.0;
      rtn.y = 0.0;
      rtn.z = 0.0;
      rtn.b = 0.0;
      rtn.t0 = 0.0;
    END IF;
    --    DELETE FROM px.centertable WHERE cstn=theStn;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getcenter( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getcenter() returns px.centertype AS $$
  DECLARE
    rtn px.centertype;
  BEGIN
    SELECT * from px.getcenter( px.getStation()) INTO rtn;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getcenter() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getcenter( ntfy text) returns px.centertype AS $$
  DECLARE
    rtn px.centertype;
    theStn bigint;
  BEGIN
    SELECT INTO theStn cstn FROM rmt.cams WHERE ccenternotify=ntfy limit 1;
    SELECT INTO rtn * FROM px.getcenter( theStn);
    IF NOT FOUND THEN
      RETURN NULL;
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getcenter( text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.autologininit( theStn bigint) returns void as $$
  DECLARE
    ntfy text;
  BEGIN
    SELECT INTO ntfy cnotifylogin FROM px._config WHERE cstnkey=theStn;
    IF FOUND THEN
      EXECUTE 'LISTEN ' || ntfy;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.autologininit( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.autologininit() returns void as $$
  SELECT px.autologininit( px.getstation());
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.autologininit() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.autologinnotify( theStn bigint) returns void as $$
  DECLARE
    ntfy text;
  BEGIN
    SELECT INTO ntfy cnotifylogin FROM px._config WHERE cstnkey=theStn;
    IF FOUND THEN
      EXECUTE 'NOTIFY ' || ntfy;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.autologinnotify( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.autologinnotify() returns void as $$
  SELECT px.autologinnotify( px.getstation());
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px.autologinnotify() OWNER TO lsadmin;


CREATE TYPE px.lnnamestype AS (src text, dest text);
CREATE OR REPLACE FUNCTION px.lnnames( pid text) returns setof px.lnnamestype AS $$
  DECLARE
    rtn px.lnnamestype;
  BEGIN
    FOR rtn.src, rtn.dest IN SELECT sfn, sbupath FROM px.shots WHERE sdspid = pid and sstate='Done' and sfn is not null and sbupath is not null ORDER BY sfn LOOP
      return next rtn;
    END LOOP;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.lnnames( text) OWNER TO lsadmin;

