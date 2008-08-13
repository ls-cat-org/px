--
-- Support for px data collection
--
--
DROP SCHEMA px CASCADE;
CREATE SCHEMA px;
GRANT USAGE ON SCHEMA px TO PUBLIC;

DROP SCHEMA pxlocks CASCADE;
CREATE SCHEMA pxlocks;

CREATE TABLE px._marinit (
--
-- commands to run with the mar starts up
-- these commands are pushed onto the mar command queue
-- and run by pxMarServer
--
	mikey serial primary key,	-- table key
	miitem text not null,		-- initialzation command
	miorder int unique		-- order to run commands
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
	mqkey serial primary key,			-- table key
	mqs timestamp with time zone default now(),	-- create time stamp
	mqc inet NOT NULL,				-- client address (address of marccd)
	mqcmd text NOT NULL				-- queued command
);
ALTER TABLE px._marqueue OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.pushqueue( cmd text) RETURNS VOID AS $$
--
-- Function to push command onto the queue
--
  DECLARE
    c text;	-- trimmed cmd
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

CREATE OR REPLACE FUNCTION px.pushqueue( cmd text, ca inet) RETURNS VOID AS $$
--
-- specify client address (ca) to queue up
  DECLARE
    c text;	-- trimmed cmd
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
    rtn text;	-- return value
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
    rtn text;	-- return value
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
	mkey serial primary key,			-- table key
	mc inet NOT NULL,				-- mar client (marccd server) ipaddress
	mts timestamp with time zone default now(),	-- creatation time stamp
        mtu timestamp with time zone default now(),     -- update time stamp (last time checked with same state)
	mrawresponse text,				-- string returned from marccd
	mcnt int default 1,				-- number of times this string has been returned
	mrawstate int					-- state returned by get_state
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
    mrr text;		-- most recent raw response received
    mk  int;		-- serial number of most recent response
    mrs int;		-- old raw state
    nrs int;		-- new raw state
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
    s int;	-- low 4 bits of status
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
    s bit(4);	-- 4 bits of task status
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


CREATE TYPE px.marheadertype AS ( sdist numeric, sexpt numeric, sstart numeric, saxis text, swidth numeric, dsdir text, sfn text, thelambda numeric);
CREATE OR REPLACE FUNCTION px.marHeader( k bigint) returns px.marheadertype AS $$
  DECLARE
    rtn px.marheadertype;
  BEGIN
    SELECT INTO rtn coalesce(sdist,'150')::numeric    as sdist,
                    coalesce(sexpt,'1.0')::numeric    as sexpt,
                    coalesce(sstart, '0')::numeric  as sstart,
                    coalesce(saxis, 'omega') as saxis,
                    coalesce(swidth,'1.0')   as swidth,
                    coalesce(dsdir, '/data/public') as dsdir,
                    coalesce(sfn, 'default') as sfn,
                    px.rt_get_wavelength() as thelambda
                    from px.shots
                    left join px.datasets on sdspid=dspid
                    where skey=k;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.marHeader( bigint) OWNER TO lsadmin;



CREATE TABLE px.stations (
--
-- stations allowed
--
	stnkey       serial primary key,	-- table key
	stnname      text not null unique,	-- station name
	stnshortname text not null unique,	-- short name used to create leagle variable names
	stndataroot  text not null,		-- default root data directory
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
	ckey             serial primary key,		-- table key
	cdetector        inet   not null,		-- ip address of the detector computer
	cdiffractometer  inet   not null,		-- ip address of the diffractometer
	crobot           inet   not null,		-- ip address of the robot process
	cstation         text				-- station where detector and diffractometer live
		references px.stations (stnname),
        cstnkey          bigint
                references px.stations (stnkey),
	cdifflocktable   text   not null,		-- name of diffractometer locking table
	cdetectlocktable text   not null,		-- name of detector locking table
	cnotifykill      text   not null,
	cnotifysnap      text   not null,
	cnotifyrun       text   not null,
	cnotifydetector  text   not null,
	cnotifydiffractometer text not null,
	cnotifypause	 text   not null,
	cnotifymessage   text   not null,
	cnotifywarning   text   not null,
        cnotifyerror     text   not null
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
  SELECT  stnkey FROM px.stations left join px._config on stnname=cstation where $1=cdetector or $1=cdiffractometer;
$$ LANGUAGE sql SECURITY DEFINER;
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

CREATE OR REPLACE FUNCTION px.ininotifies() RETURNS text AS $$
--
-- Used by the MD2 seqRun support code to setup notifies for the correct station
-- We are making use in seqRun of the format 'station_notifytype' so the underscore is important
--
  DECLARE
    notifyrun   text;	-- notify name for run
    notifysnap  text;	-- notify name for snap
    notifykill  text;	-- notify name for kill
    notifypause text;	-- notify name for pause
    rtn         text;   -- prefix for all the notify names: SEE KLUDGE ABOVE
  BEGIN
    PERFORM px.demandDiffractometerOn();
    rtn := NULL;
    SELECT INTO rtn, notifykill, notifysnap, notifyrun, notifypause split_part(cnotifykill,'_',1),cnotifykill, cnotifysnap, cnotifyrun, cnotifypause FROM px._config WHERE px.getstation( cstation)=px.getstation();
    IF FOUND THEN
      EXECUTE 'LISTEN ' || notifykill;
      EXECUTE 'LISTEN ' || notifysnap;
      EXECUTE 'LISTEN ' || notifyrun;
      EXECUTE 'LISTEN ' || notifypause;
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
	akey   serial primary key,	-- table key
	aaxis  text not null,		-- menu name of axis
	aepics text,			-- epics PV to use
	astn   int			-- station where this axis is used
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
	ssstate text primary key		-- the state of the shot
);
ALTER TABLE px.shotstates OWNER TO lsadmin;
GRANT SELECT ON px.shotstates TO PUBLIC;

INSERT INTO px.shotstates (ssstate) VALUES ( 'NotTaken');
INSERT INTO px.shotstates (ssstate) VALUES ( 'Preparing');
INSERT INTO px.shotstates (ssstate) VALUES ( 'Exposing');
INSERT INTO px.shotstates (ssstate) VALUES ( 'FinishingUp');
INSERT INTO px.shotstates (ssstate) VALUES ( 'Done');

CREATE TABLE px.expunits (
	eu  text primary key,	-- the long version of the units
	eus text unique		-- short version for small labels
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

CREATE TABLE px.dsstates (
	dss text primary key
);
ALTER TABLE px.dsstates OWNER TO lsadmin;
GRANT SELECT ON px.dsstates TO PUBLIC;

INSERT INTO px.dsstates (dss) VALUES ('active');
INSERT INTO px.dsstates (dss) VALUES ('inactive');
INSERT INTO px.dsstates (dss) VALUES ('creating');

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
  SELECT regexp_replace( $1, '[^-._a-zA-Z0-9/]*', '','g');
$$ LANGUAGE sql SECURITY DEFINER;
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


CREATE TABLE px.datasets (
	dskey      serial primary key,				-- table key
	dspid      text NOT NULL UNIQUE,			-- used to find the "shots"
	dscreatets timestamp with time zone default now(),	-- creatation time stamp
	dsstate    text NOT NULL DEFAULT 'active'		-- active or not
		references px.dsstates (dss),
	dsesaf	   int default NULL,				-- The ESAF used for this experiment
-- A real references is not used as we currently delete the esaf routinely (during a modification, for example)
-- until this is thought trhough and tested completely it is better just to leave the reference hanging
--		references esaf.esafs (eexperimentid),
	dswho      bigint default NULL,				-- Who set up this dataset
--		references esaf._people (pbadgeno),
	dsinst     bigint default NULL,				-- The institution that "owns" the data collection time
--		references lsched.schedinsts (sikey),
	dsdir      text	NOT NULL default 'data',		-- the collection directory
	dsdirs     text NOT NULL default 'New'			-- the directory state
		references px.dirstates (dirs),
	dsfp	   text default 'default',			-- file prfix
	dsstn	   bigint					-- station to collect in
		references px.stations (stnkey) ON UPDATE CASCADE,
	dsoscaxis  text		default 'omega',		-- the Axis to move, presumably NULL means don't move a thing
	dsstart    numeric      default 0,			-- starting angle of the dataset
        dsdelta    numeric      default 1,			-- distance to next starting angle (usually owidth)
	dsowidth   numeric default 1,				-- oscillation width
	dsnoscs    int default 1,				-- number of oscillations per image
	dsoscsense text	default '+'				-- sense of oscillation relative to end-start direction
		references px.oscsenses (os) ON UPDATE CASCADE,
	dsnwedge   int		default 0,			-- shots before flipping 180, 0 means don't do this
	dsend      numeric      default 90,			-- ending angle
	dsexp	   numeric	default 1,			-- Exposure: how long to keep shutter open
	dsexpunit  text		default 'Seconds'		-- units of exposure: usually secs
		 references px.expunits (eu) ON UPDATE CASCADE,
	dsphi      numeric DEFAULT NULL,			-- set phi (NULL means don't touch)
	dsomega    numeric DEFAULT NULL,			-- set omega (NULL means don't touch)
	dskappa    numeric DEFAULT NULL,			-- set kappa (NULL means don't touch)
	dsdist     numeric DEFAULT NULL,			-- set distance (NULL means don't touch)
	dsnrg      numeric DEFAULT NULL,			-- set energy (NULL means don't touch)
        dscomment  text DEFAULT NULL,				-- comment
        dsposition int default 0 references px.holderpositions (hpid)	-- holder position for new shots
);
ALTER TABLE px.datasets OWNER TO lsadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON px.datasets TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON px.datasets_dskey_seq TO PUBLIC;

--
-- kludge: we should have a Reference to esaf.esafs as that is what is intended
-- postgres would then automatically add the index
--
create index esaf_idx on px.datasets (dsesaf);


CREATE OR REPLACE FUNCTION px.next_prefix( prefix text) RETURNS text AS $$
  DECLARE
    nexti int;
    rtn   text;
  BEGIN

    rtn := rtrim(prefix,'0123456789');

    SELECT INTO nexti max(coalesce(substr( dsfp, length(rtrim(dsfp,'0123456789'))+1)::int,0)) FROM px.datasets WHERE dsfp similar to replace(rtn,'_','\\_') || '[0-9]+';
    IF FOUND AND nexti is not null THEN
      nexti := nexti + 1;
      rtn := rtn || nexti;
    ELSE
      rtn := prefix || '_1';
    END IF;

    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.next_prefix( text) OWNER TO lsadmin;




CREATE OR REPLACE FUNCTION px.newdataset( expid int) RETURNS text AS $$
--
-- create a new data set with an experiment id of expid
  DECLARE
    rtn text;		-- new token
  BEGIN
    SELECT INTO rtn md5( nextval( 'px.datasets_dskey_seq')+random());
    INSERT INTO px.datasets (dspid, dsstn, dsesaf, dsdir) VALUES (rtn, px.getstation(), expid, (select stndataroot from px.stations where stnkey=px.getstation()));
    PERFORM px.chkdir( rtn);
    PERFORM px.mkshots( rtn);
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.newdataset( int ) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.newdataset() RETURNS text AS $$
--
-- create a new data set without an experiment id
  DECLARE
    rtn text;		-- new token
  BEGIN
    SELECT INTO rtn md5( nextval( 'px.datasets_dskey_seq')+random());
    INSERT INTO px.datasets (dspid, dsstn, dsdir) VALUES (rtn, px.getstation(), (select stndataroot from px.stations where stnkey=px.getstation()));
    PERFORM px.chkdir( rtn);
    PERFORM px.mkshots( rtn);
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.newdataset( ) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.newdataset( token text) RETURNS text AS $$
--
-- create a new data set based on the old one
  DECLARE
    rtn text;		-- new token
  BEGIN

    SELECT INTO rtn md5( nextval( 'px.datasets_dskey_seq')+random());

    EXECUTE 'CREATE TEMPORARY TABLE "' || rtn || '" AS SELECT * FROM px.datasets WHERE dspid=''' || token || '''';
    EXECUTE 'UPDATE "' || rtn || '" SET dspid=''' || rtn || ''', dskey=nextval( ''px.datasets_dskey_seq''), dsstn=px.getstation()';
    EXECUTE 'INSERT INTO px.datasets SELECT * FROM "' || rtn || '"';
    EXECUTE 'DROP TABLE "' || rtn || '"';
    PERFORM px.chkdir( rtn);
    PERFORM px.mkshots( rtn);


    -- From old dataset
    -- Delete all normal frames if none have been taken
    PERFORM skey FROM px.shots WHERE sdspid=token and sstate='Done' and stype='normal' limit 1;
    IF NOT FOUND THEN
      DELETE FROM px.shots WHERE sdspid=token and stype='normal';
    END IF;

    -- From old dataset
    -- Delete all frames if none have been taken: delete the dataset as well.
    PERFORM skey FROM px.shots WHERE sdspid=token and sstate='Done' limit 1;
    IF NOT FOUND THEN
      DELETE FROM px.shots WHERE sdspid=token;
      DELETE FROM px.datasets WHERE dspid=token;
    END IF;

    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.newdataset( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.copydataset( token text) RETURNS text AS $$
  DECLARE
    rtn text;		-- new token
  BEGIN
    SELECT INTO rtn md5( nextval( 'px.datasets_dskey_seq')+random());
    EXECUTE 'CREATE TEMPORARY TABLE "' || rtn || '" AS SELECT * FROM px.datasets WHERE dspid=''' || token || '''';
    EXECUTE 'UPDATE "' || rtn || '" SET dspid=''' || rtn || ''', dskey=nextval( ''px.datasets_dskey_seq''), dsfp=px.next_prefix(dsfp), dsstn=px.getstation()';
    EXECUTE 'INSERT INTO px.datasets SELECT * FROM "' || rtn || '"';
    EXECUTE 'DROP TABLE "' || rtn || '"';
    PERFORM px.chkdir( rtn);
    PERFORM px.mkshots( rtn);

    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.copydataset( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.copydataset( token text, newPrefix text) RETURNS text AS $$
  DECLARE
    pfx text;		-- prefix after being cleaned up
    rtn text;		-- new token
  BEGIN
    SELECT INTO rtn md5( nextval( 'px.datasets_dskey_seq')+random());
    pfx := px.fix_fn( newPrefix);
    EXECUTE 'CREATE TEMPORARY TABLE "' || rtn || '" AS SELECT * FROM px.datasets WHERE dspid=''' || token || '''';
    EXECUTE 'UPDATE "' || rtn || '" SET dspid=''' || rtn || ''', dskey=nextval( ''px.datasets_dskey_seq''), dsfp=''' || pfx || ''', dsstn=px.getstation()';
    EXECUTE 'INSERT INTO px.datasets SELECT * FROM "' || rtn || '"';
    EXECUTE 'DROP TABLE "' || rtn || '"';
    PERFORM px.chkdir( rtn);
    PERFORM px.mkshots( rtn);

    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.copydataset( text, text) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.copydataset( token text, newDir text, newPrefix text) RETURNS text AS $$
  DECLARE
    pfx text;		-- prefix after being cleaned up
    dir text;		-- directory after being cleaned up
    rtn text;		-- new token
  BEGIN
    SELECT INTO rtn md5( nextval( 'px.datasets_dskey_seq')+random());
    pfx := px.fix_fn( newPrefix);
    dir := px.fix_dir( newDir);
    EXECUTE 'CREATE TEMPORARY TABLE "' || rtn || '" AS SELECT * FROM px.datasets WHERE dspid=''' || token || '''';
    EXECUTE 'UPDATE "' || rtn || '" SET dspid=''' || rtn || ''', dskey=nextval( ''px.datasets_dskey_seq''), dsfp=''' || pfx || ''', dsdir=''' || dir || ''', dsstn=px.getstation()';
    EXECUTE 'INSERT INTO px.datasets SELECT * FROM "' || rtn || '"';
    EXECUTE 'DROP TABLE "' || rtn || '"';
    PERFORM px.chkdir( rtn);
    PERFORM px.mkshots( rtn);

    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.copydataset( text, text, text) OWNER TO lsadmin;

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
  BEGIN UPDATE px.datasets set dsposition=arg2 WHERE dspid=token; END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_sample( text, int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_sample( token text) RETURNS int as $$
  SELECT dsposition from px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_sample( text) OWNER TO lsadmin;




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
ALTER FUNCTION px.ds_set_owidth( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_delta( token text) RETURNS numeric as $$
  SELECT dsdelta FROM  px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_owidth( text) OWNER TO lsadmin;


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
    ds record;	-- the dataset entry
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
    rtn int;	-- the return values
    ds record;	-- the current dataset record
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
    rtn int;	-- the count
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
-- State
--
CREATE OR REPLACE FUNCTION px.ds_set_state( token text, arg2 text) RETURNS void as $$
  BEGIN UPDATE px.datasets set dsstate=arg2 where dspid=token; end; $$
LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.ds_set_state( text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.ds_get_state( token text) RETURNS text as $$
  SELECT dsstate FROM px.datasets WHERE dspid=$1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ds_get_state( text) OWNER TO lsadmin;


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
	skey     serial		primary key,		-- table key
	sts	timestamp with time zone default now(),	-- time of creation or last status change
	sdspid	 text					-- PID of dataset
		references px.datasets (dspid) ON UPDATE CASCADE ON DELETE CASCADE,
	stype    text           NOT NULL		-- type of dataset this is part of (needed to uniquely identify shot)
		references px.stypes ON UPDATE CASCADE,
	sindex	 int		NOT NULL,		-- frame number within this sequence
	sfn      text		DEFAULT NULL,		-- the file name
	sstart	 numeric	DEFAULT NULL,		-- Starting angle:not sure what NULL would mean with soscaxis not NULL
        saxis    text		DEFAULT NULL,		-- as run data collection axis
        swidth   numeric        DEFAULT NULL,		-- as run width
        sexpt    numeric        DEFAULT NULL,		-- as run exposure time
        sexpu    text           DEFAULT NULL		-- as run exposure time
		references px.expunits (eu) ON UPDATE CASCADE,
	sphi     numeric        DEFAULT NULL,		-- as run starting phi
        somega   numeric        DEFAULT NULL,		-- as run starting omega
        skappa   numeric        DEFAULT NULL,           -- as run starting kappa
        sdist    numeric        DEFAULT NULL,           -- as run starting distance
        snrg     numeric        DEFAULT NULL,           -- as run starting energy
        scmt     text           DEFAULT NULL,		-- comment
	sstate   text					-- current state of the shot
		 references px.shotstates (ssstate) ON UPDATE CASCADE,
        sposition int default 0 references px.holderpositions (hpid),   -- the location of the sample holder used (0=hand mounted)
	UNIQUE (sdspid, stype, sindex)
);
ALTER TABLE px.shots OWNER TO lsadmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON px.shots TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON px.shots_skey_seq TO PUBLIC;

CREATE OR REPLACE FUNCTION px.shots_set_expose( theKey int) returns void AS $$
  DECLARE
    ds record;	-- the dataset record
    token text;	-- the record token
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
    rtn px.nextshottype;	-- the return value
    rq  record;			-- the runqueue record at the top of the queueu
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
    IF NEW.sstate = 'Done' THEN
      PERFORM 1 FROM px.shots WHERE sdspid=NEW.sdspid and stype=NEW.stype and sstate!='Done' and sKey != NEW.sKey;
      IF NOT FOUND THEN
        PERFORM px.poprunqueue();
      END IF;
    END IF;
  RETURN NULL;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE TRIGGER shotsUpdateTrigger AFTER UPDATE ON px.shots FOR EACH ROW EXECUTE PROCEDURE px.shotsUpdateTF();

CREATE OR REPLACE FUNCTION px.getshots( pid text, type text) RETURNS SETOF px.shots AS $$
  SELECT * FROM px.shots WHERE sdspid=$1 and stype=$2 ORDER BY sindex ASC;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.getshots( text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getshots( pid text) RETURNS SETOF px.shots AS $$
  SELECT * FROM px.shots WHERE sdspid=$1 ORDER BY stype, sindex ASC;
$$ LANGUAGE sql SECURITY DEFINER;
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
    token text;		-- the token (for adding to queue)
    typ   text;		-- need the type to startup snaps (not normal)
  BEGIN
    SELECT INTO token,typ sdspid,stype FROM px.shots WHERE skey=theKey;
    UPDATE px.shots SET sstate='NotTaken' WHERE skey=theKey;
    PERFORM 1 from px.runqueue where rqToken=token and rqType=typ;
    IF NOT FOUND THEN
      PERFORM px.pushrunqueue( token, typ);
      PERFORM px._md2pushqueue( 'collect');
    END IF;
--    IF typ = 'snap' THEN
--      PERFORM px.startrun();
--    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.retake( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.retakerest( theKey int) RETURNS void AS $$
  DECLARE
    ndx int;	-- starting index
    typ text;   -- type of shot
    token text; -- the pid
  BEGIN
    SELECT INTO ndx,typ,token sindex,stype,sdspid FROM px.shots WHERE skey=theKey;
    UPDATE px.shots SET sstate='NotTaken' WHERE sdspid=token and sindex >= ndx and stype=typ;
    PERFORM 1 from px.runqueue where rqToken=token and rqType=typ;
    IF NOT FOUND THEN
      PERFORM px.pushrunqueue( token, typ);
      PERFORM px._md2pushqueue( 'collect');
    END IF;
--    IF typ = 'snap' THEN
--      PERFORM px.startrun();
--    END IF;
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
  DECLARE
    nexti int;  -- next value of the index
    fp text;	-- file prefix
  BEGIN
    SELECT INTO fp dsfp from px.datasets where dspid=pid;
    SELECT INTO nexti coalesce(max(sindex)+1,1) from px.shots where sdspid=pid and stype='snap';
    INSERT INTO px.shots (sdspid, stype, sindex, sfn, sstart, sstate) VALUES (
      pid, 'snap', nexti, fp || '_S.' || trim(to_char(nexti,'099')), initialpos, 'NotTaken'
    );
    PERFORM px.pushrunqueue( pid, 'snap');
    PERFORM px._md2pushqueue( 'collect');
--    PERFORM px.startrun();
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.mksnap( text, numeric) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.mkorthosnap( pid text, initialpos numeric) RETURNS void AS $$
  BEGIN
    PERFORM px.mksnap( pid, initialpos);
    PERFORM px.mksnap( pid, initialpos+90);
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


CREATE OR REPLACE FUNCTION px.mkshots( token text) RETURNS text as $$
  DECLARE
    nframes int;		-- number of frames (1/2 # frames if wedges)
    newend  numeric;		-- caluculated end point
    sk      int;		-- the station key
    pid     text;		-- pid for shots/dataset
    fp      text;		-- the file prefix (already entered)
    fn      text;		-- the filename
    angle   numeric;		-- calculated diffraction angle
    delta   numeric;		-- difference between starting angles of adjacent frames
    n       int;		-- loop counter for wedge collection
    wnn     int;                -- loop counter for wedge name
    an      int;		-- counter for wedge collection used for angle calculation
    oldcnt  int;		-- count of old frames in this dataset
    ds      record;		-- dataset definition
    fmt     text;               -- format string for frame numbers

  BEGIN
    SELECT INTO ds * from px.datasets where dspid=token;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'token % not found', token;
    END IF;

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
            token,	-- sdspid
            'normal',	-- stype
            fn,		-- sfn
            angle,	-- sstart
            i,		-- sindex
            'NotTaken',	-- sstate
            ds.dsposition -- the sample
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
              token,		-- sdspid
              'normal',		-- stype
              fn,		-- sfn
              angle,		-- sstart
              n+i,		-- sindex
              'NotTaken',	-- sstate
              ds.dsposition -- the sample
            );
          END IF;
	END LOOP;
        FOR i IN 1..ds.dsnwedge LOOP
          PERFORM skey FROM px.shots WHERE sdspid=token and sindex=n+ds.dsnwedge+i and stype='normal';
          IF NOT FOUND THEN
            fn := fp || '_' || 'B' || '.' || trim( to_char( wnn+i, fmt));
            angle := ds.dsstart + (an+i-1) * delta + 180;
            INSERT INTO px.shots ( sdspid, stype, sfn, sstart, sindex, sstate, sposition) VALUES (
              token,		-- sdspid
              'normal',		-- stype
              fn,		-- sfn
              angle,		-- sstart
              n+ds.dsnwedge+i,	-- sindex
              'NotTaken',	-- sstate
              ds.dsposition -- the sample
            );
          END IF;
	END LOOP;
        n   := n   + 2*ds.dsnwedge;
        an  := an  + ds.dsnwedge;
        wnn := wnn + ds.dsnwedge;
      END LOOP;
    END IF;
    RETURN token;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.mkshots( text) OWNER TO lsadmin;

CREATE TABLE px.pauseStates (
       pss text primary key
);
ALTER TABLE px.pauseStates OWNER TO lsadmin;
INSERT INTO px.pauseStates (pss) values ('Please Pause');	-- request that the data collection pause
INSERT INTO px.pauseStates (pss) values ('I Paused');		-- Notification that the data collection has paused
INSERT INTO px.pauseStates (pss) values ('Not Paused');		-- We are not paused right now

CREATE TABLE px.pause (
       pKey serial primary key,				-- our primary key
       ptc timestamp with time zone default now(),	-- when the state was requested
       pStn int references px.stations (stnkey),	-- the station we are pausing for
       pps  text references px.pauseStates (pss)	-- the actual request
);
ALTER TABLE px.pause OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.ispaused() RETURNS boolean AS $$
  SELECT pps != 'Not Paused' FROM px.pause WHERE pStn = px.getstation();
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.ispaused() OWNER TO lsadmin;


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

CREATE OR REPLACE FUNCTION px.pauseRequest( stn bigint) RETURNS VOID AS $$
  DECLARE
    ntfy text;
  BEGIN
    PERFORM 1 FROM px.pause where pStn=stn;
    IF FOUND THEN
      UPDATE px.pause set ptc=now(), pps='Please Pause' where pStn=px.getStation();
    ELSE
      INSERT INTO px.pause (ptc,pStn,pps) VALUES (now(),stn,'Please Pause');
    END IF;
    SELECT INTO ntfy cnotifypause FROM px._config LEFT JOIN px.stations ON cstation=stnname WHERE stnkey=stn;
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
      UPDATE px.pause set ptc=now(), pps='Not Paused' where pStn=px.getStation();
    ELSE
      INSERT INTO px.pause (ptc,pStn,pps) VALUES (now(), stn,'Not Paused');
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.unpause( bigint) OWNER TO lsadmin;


CREATE TABLE px.runqueue (
    rqKey serial primary key,				-- table key
    rqStn int references px.stations (stnkey),		-- station queue
    rqCTS timestamp with time zone default now(),	-- creatation time stamp
    rqOrder int not null,			-- order to be taken
    rqToken text not null				-- dataset
	references px.datasets (dspid),
    rqType  text not null				-- type of frame to run
	references px.stypes (st),
    UNIQUE (rqStn, rqOrder)
);
ALTER TABLE px.runqueue OWNER TO lsadmin;
--GRANT SELECT, INSERT, UPDATE, DELETE ON px.runqueue TO PUBLIC;

CREATE OR REPLACE FUNCTION px.runqueue_delete_tf() RETURNS trigger AS $$
  DECLARE
  BEGIN
    PERFORM 1 FROM px.runqueue WHERE rqStn=px.getstation();
    IF NOT FOUND THEN
      PERFORM px.unpause();
    END IF;
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.runqueue_delete_tf() OWNER TO lsadmin;

CREATE TRIGGER runqueue_delete_trigger AFTER DELETE ON px.runqueue FOR EACH STATEMENT EXECUTE PROCEDURE px.runqueue_delete_tf();

CREATE OR REPLACE FUNCTION px.pushrunqueue( token text, stype text) RETURNS void AS $$
  DECLARE
  BEGIN
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
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.pushrunqueue( text, text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.runqueue_up( theKey bigint) RETURNS void AS $$
--
-- Move item up the runqueue (lower its order) by swapping with the next lower one
--
  DECLARE
    a   record;	-- entry of the one we'd like to move
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
    a   record;	-- the record we'd like to move
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

CREATE TYPE px.runqueuetype AS ( dspid text, type text, k bigint, etc text);

CREATE OR REPLACE FUNCTION px.runqueue_get() returns SETOF px.runqueuetype AS $$
  DECLARE
    rtn px.runqueuetype;		-- the return value
    rq record;				-- the runqueue entry
    startTime timestamp with time zone;	-- start time of next dataset
    deltaTime interval;			-- estimated time for this dataset
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


CREATE OR REPLACE FUNCTION px.runqueue_remove( k bigint) RETURNS void AS $$
  DECLARE
    ordr int;	-- the order of the item we are removing
  BEGIN
    SELECT INTO ordr rqOrder FROM px.runqueue WHERE rqKey=k and rqStn=px.getStation();
    DELETE FROM px.runqueue WHERE rqKey=k and rqStn=px.getStation();
    UPDATE px.runqueue SET rqOrder=rqOrder-1 WHERE rqOrder > ordr;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.runqueue_remove( bigint) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.runqueuecount() RETURNS int AS $$
  SELECT count(*)::int FROM px.runqueue WHERE rqStn=px.getstation();
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.runqueuecount() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getrunqueuetype() RETURNS text AS $$
  SELECT coalesce(rqType,'') FROM px.runqueue WHERE rqStn=px.getstation() ORDER BY rqCTS ASC limit 1;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.getrunqueuetype() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.poprunqueue() RETURNS void AS $$
  DECLARE
    rq record;	-- records to update
    i  int;     -- welecome to the new order
  BEGIN
    DELETE FROM px.runqueue WHERE rqKey IN (select rqKey from px.runqueue where rqStn=px.getstation() ORDER BY rqOrder ASC limit 1);
    i := 1;
    FOR rq IN SELECT * FROM px.runqueue WHERE rqStn=px.getstation() ORDER BY rqOrder ASC LOOP
      UPDATE px.runqueue set rqOrder=i WHERE rqKey=rq.rqKey;
      i := i+1;
    END LOOP;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.poprunqueue() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.clearrunqueue() RETURNS void AS $$
  DELETE FROM px.runqueue WHERE rqStn = px.getstation();
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.clearrunqueue() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.startrun() returns void AS $$
  DECLARE
    nt text;	-- notify condition
  BEGIN
    SELECT INTO nt cnotifyrun FROM px._config left join px.stations on stnname=cstation WHERE stnkey=px.getstation();
    IF FOUND THEN
      UPDATE px.pause SET ptc=now(), pps='Not Paused' WHERE pStn=px.getStation();
      EXECUTE 'NOTIFY ' || nt;
    END IF;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.startrun() OWNER TO lsadmin;



CREATE TABLE px.epicsLink (
--
-- Table to link motors and stuff
--
	elKey  serial primary key,		-- table key
	elStn  bigint default NULL		-- station
		references px.stations (stnkey),	
	elName text NOT NULL,			-- our name for this variable
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
	epvmlKey  serial primary key,		-- table key
	epvmlStn  bigint default NULL		-- station
		references px.stations (stnkey),	
	epvmlName text NOT NULL,			-- our name for this variable
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
    rtn boolean;
  BEGIN
    SELECT INTO rtn (minpos=1) and abs(mactpos-value)<=10^(-mprec) FROM epics.motions LEFT JOIN px.epicsLink on mmotorpvname=elPV WHERE elName=motion and elStn=px.getstation();
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.isthere( text, numeric) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.isthere( motion text) RETURNS boolean AS $$
  DECLARE
    rtn boolean;
  BEGIN
    return true;  -- Kludge to run data collection until epics support is fixed 080121 KB
    SELECT INTO rtn (minpos=1) and not mweareincontrol FROM epics.motions LEFT JOIN px.epicsLink on mmotorpvname=elPV WHERE elName=motion and elStn=px.getstation();
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.isthere( text) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.moveit( motion text, value numeric) RETURNS VOID AS $$
  DECLARE
  BEGIN
   PERFORM epics.moveit( elPV, value) FROM px.epicsLink WHERE elName=motion and elStn=px.getStation();
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.moveit( text, numeric) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px.rt_get_dist() returns text AS $$
  DECLARE
    rtn text;	-- return value
  BEGIN
    SELECT INTO rtn to_char( mactpos, '9999.9') FROM epics.motions LEFT JOIN  px.epicsLink ON elPV=mmotorpvname WHERE elStn=px.getstation() and elName='distance';
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_dist() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_can_home_omega() returns boolean AS $$
  SELECT px.rt_get_dist() >= 100.0;
$$ LANGUAGE sql SECURITY DEFINER;
ALTER FUNCTION px.rt_can_home_omega() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.rt_set_dist( d text) returns void AS $$
  DECLARE
  BEGIN
    PERFORM px.moveit( 'distance', d::numeric);
    RETURN;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_set_dist( text) OWNER TO lsadmin;


CREATE TABLE px.distSaves (
--
-- distSaves
-- Stores "In" and "Out" detector positions
-- to automatically move the detector out of the way
-- when the user enters the hutch
--
	dsKey serial primary key,	-- table key
	dsStn bigint			-- pointer to station
		references px.stations (stnkey),
	dsTs  timestamp with time zone, -- time last In position was saved
	dsIn  numeric default 500,	-- saved data collection position
	dsOut numeric default 500	-- Position for detector out of the way
);
ALTER TABLE px.distSaves OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px._moveDetectorOut( pvmk bigint, value numeric) RETURNS void AS $$
-- _moveDetectorOut
-- "Action" function called when an epics variable (pvmk is the pvmonitors key) changes.  See actions in epics.sql
--
  DECLARE
    moving boolean;	-- check to see if the motor is moving.  Do nothing if it is.
    stn    bigint;	-- pointer to station
    dist   numeric;	-- saved detector position
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
    moving boolean;	-- check to see if the motor is moving.  Do nothing if it is.
    stn    bigint;	-- pointer to station
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

CREATE TABLE px._beamcenterHistory (
	bcKey	serial primary key,		-- table key
	bcStn	bigint				-- the station
		references px.stations (stnkey),
	bxX1


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
	ehKey serial primary key,			-- table key
	ehTs  timestamp with time zone default now(),	-- time entry was created
	ehStn bigint not null					-- the station
		references px.stations (stnkey),
	ehValue numeric default NULL			-- the actual value  (NULL signifies unknown value)
);
ALTER TABLE px._energyHistory OWNER TO lsadmin;

CREATE TABLE px._energyLookUp (
	eluKey serial primary key,	-- table key
	eluStn bigint unique		-- our station
		references px.stations (stnkey),
	eluType text			-- table or epics method of retrieving wavelength
		references px._energyLookUpMethods (elum) ON UPDATE CASCADE,
	eluEpics text			-- epics PV name of epics energy pv
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
  BEGIN
    SELECT INTO rtn to_char(12.3984172/eluValue, '0.99999') FROM px.energyLookUp WHERE eluStn=px.getStation();
    IF NOT FOUND THEN
      rtn := '0.9747';
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_wavelength() OWNER TO lsadmin;

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
    SELECT INTO rtn to_char(eluValue, '99.99999') FROM px.energyLookUp WHERE eluStn=px.getStation();
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
    SELECT INTO theCurrent pvmvaluen FROM epics._pvmonitors WHERE pvmname='S:SRcurrentAI';
    SELECT INTO theIzero  pvmvaluen FROM epics._pvmonitors LEFT JOIN px.epicsPVMLink ON epvmlPV=pvmname WHERE epvmlStn=px.getstation() and epvmlName='Io';

    IF theCurrent < 10.0 THEN
      rtn := '--';
    ELSE
      SELECT INTO rtn to_char( theIzero/theCurrent, '999999');
    END IF;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.rt_get_ni0() OWNER TO lsadmin;


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
    rtn text;	-- our return value
    hn  text;   -- name from holder
  BEGIN
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
ALTER FUNCTION px.getName( int)	OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.getConfigFile( theId int) returns text AS $$
  DECLARE
    itm record;		-- the record of the item pointed to by theId
    chitms record;	-- the record(s) of the child items under theId
    rtn text;		-- xml return text
    inf text;		-- Information on this ID
  BEGIN
    rtn := '';
    SELECT *  INTO itm FROM px.holderPositions WHERE hpId = theId;
    IF FOUND THEN
      rtn := '<?xml version="1.0" encoding="UTF-8"?>';
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
      rtn = rtn || E'  <Selected r="120" g="120" b = "0" a="127" />\n';
      rtn = rtn || E'  <Disabled r="10"  g="10"  b = "10" a="127" />\n';
      FOR chitms IN SELECT *
          FROM px.holderPositions
          LEFT JOIN px.holderHistory on hpid=hhPosition
          WHERE hpId > theId and hpidres=itm.hpidres>>8 and hpId < (theId + itm.hpIdRes) and hpIndex>0 and hhstate!='Inactive'
          LOOP
        rtn = rtn || '<Child id="' || chitms.hpId || '" index="' || chitms.hpIndex || E'" />\n';
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

CREATE TYPE px.nextActionType AS ( key bigint, action text);

CREATE OR REPLACE FUNCTION px.nextAction() returns px.nextActionType as $$
    -- pause
    -- collect
    -- transfer
    -- center
  DECLARE
    rtn px.nextActionType;    -- return value
    tmp px._md2queue;    --
  BEGIN
    rtn.key    := 0;
    rtn.action := 'pause';
    SELECT * INTO tmp FROM px.md2popqueue();
    IF length( tmp.md2cmd)>0 THEN
      rtn.action := tmp.md2Cmd;
      rtn.key    := tmp.md2Key;
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
    PERFORM px.md2pushqueue( 'transfer');
    PERFORM cats.put( theId);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.requestTransfer( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.dropAirRights( ) returns VOID AS $$
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
INSERT INTO px.holderstates (ss) VALUES ('Inactive');		-- set if this position is not currently installed


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

       hpKey serial primary key,		-- our key
       hpId int unique,				-- unique idenifier for this location
       hpIdRes int NOT NULL,			-- children have ids > hpId and < hpId+hpIdRes
       hpIndex int,				-- Parent's selection index
       hpName text,				-- name of this item
       hpImageURL text default NULL,		-- Image, if any, to use for this holder position
       hpImageMaskURL text default NULL,	-- Image, if any, to use for the selection mask for position contained herein
       hpTempLoc int default 0			-- current location id of sample normally stored here (0 means item not in temp storage)
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
       hKey serial primary key,		-- Our key
       hType text references px.holdertypes (ht) on update cascade,
       hName text,			-- Whatever name we want for this holder
       hBarCode text unique,		-- unique id for this sample: NULL means we don't know or don't care
       hRFID text unique		-- unique id for this sample: NULL means we don't know or don't care
);
ALTER TABLE px.holders OWNER TO lsadmin;


CREATE TABLE px.holderHistory (
       hhKey serial primary key,		-- our key
       hhPosition int references px.holderPositions (hpId),
       hhHolder   bigint references px.holders (hKey),
       hhState text default 'Unknown' not null references px.holderstates (ss) on update cascade,
       hhExpId int default null,		-- The experiment id that includes this sample: should be a reference
       hhMaterial text default null,	-- name of the sample from ESAF: should be a reference to esaf.materials (matname) but this requires a different mechanism for esaf updates than is currently employed
       hhStart timestamp with time zone default now(),
       hhLast  timestamp with time Zone default now()
);
ALTER TABLE px.holderHistory OWNER TO lsadmin;

       
CREATE TABLE px._md2queue (
       md2Key serial primary key,	-- our key
       md2ts timestamp with time zone not null default now(),
       md2Addr inet not null,		-- IP Address of the MD2
       md2Cmd text not null		-- the Command
);
ALTER TABLE px._md2queue OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px.md2pushqueue( cmd text) RETURNS VOID AS $$
  DECLARE
    c text;	-- trimmed command
    ntfy text;	-- used to generate notify command
  BEGIN
    SELECT cnotifydiffractometer INTO ntfy FROM px._config WHERE cstnkey=px.getstation();
    IF NOT FOUND THEN
      RETURN;
    END IF;
    c := trim( cmd);
    IF length( c) > 0 THEN
      INSERT INTO px._md2queue (md2Cmd, md2Addr)
        SELECT c, cdiffractometer
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


CREATE OR REPLACE FUNCTION px.md2popqueue() returns px._md2queue AS $$
  DECLARE
    rtn px._md2queue;		-- return value
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
  BEGIN
    rtn := 'Unknown';
    SELECT hhState INTO rtn FROM px.holderHistory WHERE hhPosition=theId ORDER BY hhKey DESC LIMIT 1;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.getHolderPositionState( int) OWNER TO lsadmin;


CREATE TABLE px.errorSeverity (
       es text primary key,		-- text version of message
       ess int not null unique		-- sort order of severity (0=message, 2=fatal)
);
ALTER TABLE px.errorSeverity OWNER TO lsadmin;
INSERT INTO px.errorSeverity (ess, es) VALUES ( 0, 'message');
INSERT INTO px.errorSeverity (ess, es) VALUES ( 1, 'warning');
INSERT INTO px.errorSeverity (ess, es) VALUES ( 2, 'fatal');

CREATE TABLE px.errors (
       eKey serial primary key,					-- the Key
       eSeverity text not null references px.errorSeverity (es),	-- severity of error
       eid int not null unique,					-- identifier for this error (for client processing)
       eTerse text not null,					-- terse error
       eVerbose text not null					-- long winded version of the error
);
ALTER TABLE px.errors OWNER TO lsadmin;

INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('message', 1, 'Test Message 1', 'This message is here to test the error handling severity 0');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('message', 2, 'Test Message 2', 'This alternate message is here to test the error handling severity 0');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('warning', 3, 'Test Warning 1', 'This warning is here to test the error handling severity 1');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('warning', 4, 'Test Warning 2', 'This alternate warning is here to test the error handling severity 1');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('fatal',   5, 'Test Error 1',   'This error is here to test the error handling severity 2');
INSERT INTO px.errors (eSeverity, eid, eTerse, eVerbose) VALUES ('fatal',   6, 'Test Error 2',   'This alternate error is here to test the error handling severity 2');


CREATE TABLE px.activeErrors (
       eaKey serial primary key,			-- the key
       eaId int not null references px.errors (eid),	-- the error
       eaTs timestamp with time zone not null default now(),
       eaStn int not null references px.stations (stnKey),
       eaDetails text,
       eaAcknowledged boolean not null default False
);
ALTER TABLE px.activeErrors OWNER TO lsadmin;


CREATE TYPE px.errorType AS ( etKey bigint, etSeverity text, etId int, etTerse text, etVerbose text, etDetails text, etts timestamptz);

CREATE OR REPLACE FUNCTION px.nextErrors() returns setof px.errorType AS $$
  DECLARE
    rtn px.errorType;
  BEGIN
    FOR rtn IN SELECT eaKey, es, eiD, eTerse, eVerbose, eaDetails, eaTs
                 FROM px.activeErrors
                 LEFT JOIN px.errors ON eaId=eId
                 WHERE eaStn=px.getstation() and eaAcknowledged = False
                 ORDER BY ess desc,eaTs desc LOOP
      return next rtn;
    END LOOP;
    return;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px.nextErrors() OWNER TO lsadmin;

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
    INSERT INTO px.activeErrors (eaId, eaStn, eaDetails) VALUES (theId, px.getstation(), theDetails);
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
