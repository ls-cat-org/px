DROP SCHEMA px_iss010 CASCADE;
CREATE SCHEMA px_iss010;
GRANT USAGE ON SCHEMA px_iss010 TO PUBLIC;
--
--         Diffractometer/Robot State Machine
--
--   #    State              Expiration   Who Changes     Next    On Error
--
--   0    Init               None          either           1
--   1    DiffHasAR          Watchdog      Diff             2       0
--   2    ReadyForCryoBack   Watchdog      Robot            3       0
--   3    MoveCryoBack       Watchdog      Diff             4       0
--   4    RobotHasAR         Watchdog      Robot            5       0
--   5    RobotDone          20 Seconds    Diff             1       0
--

--   0   Diffractometer aborts current mode and claims air rights
--       Robot aborts if inside exclusion zone
--
--   1   Diffractometer moves to "Robot Mounting" posisition and changes state when ready.
--
--   2   Robot grabs crystal and signals when ready for air rights
--
--   3   Diffractometer moves cryo back and drops air rights when done
--
--   4   Robot does stuff over the diffractometer and signals when done
--
--   5   Diffractometer grabs air rights
--
--   Expiration time of 0 means no expiration (only used in Init state)
--
--   If either the Robot or the diffractometer detects an expired state then it must abort and sent the new state to Init
--


CREATE OR REPLACE FUNCTION px_iss010.set_dr_state(the_stn int, new_state text, expire_delta int) returns text as $$
  DECLARE
    milli_epoch bigint;
    old_state   text;
    old_expires bigint;
    old_dr_state json;

  BEGIN
    milli_epoch  = (extract(epoch from now())*1000)::bigint;
    old_dr_state = px.kvget(the_stn, 'robot.state_machine')::json;
    old_state    = old_dr_state->>'state';
    old_expires  = old_dr_state->>'expires';

    --
    -- Climb out of the init state
    --
    IF old_state = 'Init' and new_state = 'DiffHasAR' THEN
      PERFORM px.kvset(the_stn, 'robot.state_machine', '{"state": "DiffHasAR", "expires": ' || (milli_epoch + expire_delta*1000) || '}');
      return new_state;
    END IF;

    --
    -- Refuse to move on if the current state has expired.  Reset instead.
    --
    IF old_expires < milli_epoch THEN
      PERFORM px.kvset(the_stn, 'robot.state_machine', '{"state": "Init", "expires": 0}');
      return 'Init';
    END IF;

    --
    --  Enforce transition rules
    --
    --  Note: there is no way in this function to determine for sure if it's the Robot
    --        or the Diffractometer that's making the request so we can't enforce that
    --        part of the protocol here.
    --
    IF     old_state = 'DiffHasAR'        and new_state = 'ReadyForCryoBack'
        OR old_state = 'ReadyForCryoBack' and new_state = 'MoveCryoBack'
        OR old_state = 'MoveCryoBack'     and new_state = 'RobotHasAR'
        OR old_state = 'RobotHasAR'       and new_state = 'RobotDone'
        OR old_state = 'RobotDone'        and new_state = 'DiffHasAR'
      THEN
        PERFORM px.kvset(the_stn, 'robot.state_machine', '{"state": "'||new_state||'", "expires": ' || (milli_epoch + expire_delta*1000) || '}');
        return new_state;
    END IF;

    PERFORM px.kvset(the_stn, 'robot.state_machine', '{"state": "Init", "expires": 0}');
    return 'Init';

  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.set_dr_state(int, text, int) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px_iss010.get_dr_state(the_stn int) returns text AS $$
  DECLARE
    the_dr_state json;
    the_state text;
    the_expires bigint;
    milli_epoch bigint;

  BEGIN
    milli_epoch  = (extract(epoch from now())*1000)::bigint;
    the_dr_state = px.kvget(the_stn, 'robot.state_machine')::json;
    the_state    = the_dr_state->>'state';
    the_expires  = the_dr_state->>'expires';

    IF the_expires < (milli_epoch) THEN
      IF the_state != 'Init' THEN
        PERFORM px.kvset(the_stn, 'robot.state_machine', '{"state": "Init", "expires": 0}');
      END IF;
      return 'Init';
    END IF;

    return the_state;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.get_dr_state(int) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px_iss010.reset_dr_expires(the_stn int, our_state text, our_delta_expires int) returns text AS $$
  DECLARE
    the_dr_state json;
    the_state text;
    the_expires bigint;
    milli_epoch bigint;
  BEGIN
    milli_epoch  = (extract(epoch from now())*1000)::bigint;
    the_dr_state = px.kvget(the_stn, 'robot.state_machine')::json;
    the_state    = the_dr_state->>'state';
    the_expires  = the_dr_state->>'expires';

    IF the_state = 'Init' THEN
      return the_state;
    END IF;

    IF the_state != our_state OR the_expires < milli_epoch THEN
      PERFORM px.kvset(the_stn, 'robot.state_machine', '{"state": "Init", "expires": 0}');
      return 'Init';
    END IF;

    PERFORM px.kvset(the_stn, 'robot.state_machine', '{"state": "' || our_state || '", "expires": ' || (milli_epoch + our_delta_expires*1000) || '}');
    return our_state;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.reset_dr_expires(int, text, int) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px_iss010.marinit() RETURNS void AS $$
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
ALTER FUNCTION px_iss010.marinit() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.demandDiffractometerOn() RETURNS text AS $$
  DECLARE
  BEGIN
    return px_iss010.set_dr_state(px.getstation(), 'DiffHasAR');
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.demandDiffractometerOn() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010 dropDiffractometerOn() RETURNS void AS $$
  DECLARE
  BEGIN
    PERFORM px_iss010.set_dr_state(px.getstation(), 'Init');
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.dropDiffractometerOn() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.checkDiffractometerOn() RETURNS boolean AS $$
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
ALTER FUNCTION px_iss010.checkDiffractometerOn() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.checkDiffractometerOn( thestn int) RETURNS boolean AS $$
  --
  -- returns false if the diffractometer is on
  --
  DECLARE
    rtn boolean;
  BEGIN
    SELECT pg_try_advisory_lock( thestn, 1) INTO rtn;
    IF rtn THEN
      PERFORM pg_advisory_unlock( thestn, 1);
    END IF;
    return rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.checkDiffractometerOn() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.setDetectorOn() RETURNS void AS $$
  DECLARE
  BEGIN
  --
  -- 3 is detector not exposing
  -- 5 is detector on
  --
  PERFORM pg_advisory_lock( px.getstation(), 3);
  PERFORM pg_advisory_lock( px.getstation(), 5);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.setDetectorOn() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.setDetectorOn(stn int) RETURNS void AS $$
  DECLARE
  BEGIN
  --
  -- 5 is detector on lock.  Note we are not grabbing the ready lock
  -- (3) unlike the other version of this function.
  --
  PERFORM pg_advisory_lock( stn, 5);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.setDetectorOn(int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.dropDetectorOn() RETURNS void AS $$
  DECLARE
  BEGIN
  --
  -- 3 is detector not exposing
  -- 5 is detector on
  --
  PERFORM pg_advisory_unlock( px.getstation(), 5);
  PERFORM pg_advisory_unlock( px.getstation(), 3);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.dropDetectorOn() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.checkDetectorOn() RETURNS int AS $$
  --
  -- returns 0 if the detector is on
  --
  DECLARE
    tst boolean;
  BEGIN
    SELECT pg_try_advisory_lock( px.getstation(), 5) INTO tst;
    IF tst THEN
      PERFORM pg_advisory_unlock( px.getstation(), 5);
      RETURN 1;
    END IF;
    return 0;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.checkDetectorOn() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.lock_detector() RETURNS void AS $$
-- indicate that the detector is ready for action but isn't doing anything right now
  BEGIN
    PERFORM pg_advisory_lock( px.getstation(), 3);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.lock_detector() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.lock_detector(stn int) RETURNS void AS $$
-- indicate that the detector is ready for action but isn't doing anything right now
  BEGIN
    PERFORM pg_advisory_lock( stn, 3);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.lock_detector(int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.lock_detector_nowait() RETURNS int AS $$
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
ALTER FUNCTION px_iss010.lock_detector_nowait() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.lock_detector_test() RETURNS int AS $$
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
ALTER FUNCTION px_iss010.lock_detector_test() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.lock_detector_test( stn int) RETURNS int AS $$
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
ALTER FUNCTION px_iss010.lock_detector_test( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.lock_detector_test_block( stn int) RETURNS void AS $$
  -- 
  -- wait for detector to grab its lock then return
  -- we never return with the detector lock
  --
  DECLARE
    tmp boolean;
  BEGIN

    LOOP
      -- Check the detector 'ready' lock
      SELECT pg_try_advisory_lock( stn, 3) INTO tmp;
      IF tmp THEN
        PERFORM pg_advisory_unlock( stn, 3);
      ELSE
        RETURN;
      END IF;

      -- Check the detector 'is on' lock
      SELECT pg_try_advisory_lock( stn, 5) INTO tmp;
      IF tmp THEN
        PERFORM pg_advisory_unlock( stn, 5);
        RAISE EXCEPTION 'Detector sofware is not running for station %', stn;
      END IF;

      -- Pause a moment to keep the cpu usage under control
      PERFORM pg_sleep(0.02);
    END LOOP;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.lock_detector_test_block( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.lock_detector_test_block() RETURNS void AS $$
  SELECT px.lock_detector_test_block( px.getstation());
$$ LANGUAGE SQL SECURITY DEFINER;
ALTER FUNCTION px_iss010.lock_detector_test_block() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.unlock_detector() RETURNS void AS $$
-- indicate the start of integration
  BEGIN
    PERFORM pg_advisory_unlock( px.getstation(), 3);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.unlock_detector() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.unlock_detector(stn int) RETURNS void AS $$
-- indicate the start of integration
  BEGIN
    PERFORM pg_advisory_unlock( stn, 3);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.unlock_detector(int) OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px_iss010.lock_diffractometer() RETURNS void AS $$
-- indicate we are either exposing or are ready to start exposing
  BEGIN
    PERFORM pg_advisory_lock( px.getstation(), 4);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.lock_diffractometer() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.lock_diffractometer(stn int) RETURNS void AS $$
-- indicate we are either exposing or are ready to start exposing
  BEGIN
    PERFORM pg_advisory_lock( stn, 4);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.lock_diffractometer(int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.lock_diffractometer_nowait() RETURNS int AS $$
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
ALTER FUNCTION px_iss010.lock_diffractometer_nowait() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.lock_diffractometer_test() RETURNS int AS $$
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
ALTER FUNCTION px_iss010.lock_diffractometer_test() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.lock_diffractometer_test( stn int) RETURNS int AS $$
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
ALTER FUNCTION px_iss010.lock_diffractometer_test( int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.unlock_diffractometer() RETURNS void AS $$
  -- grabs the diffractometer lock indicating ready to start exposure
  BEGIN
    PERFORM pg_advisory_unlock( px.getstation(), 4);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.unlock_diffractometer() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.unlock_diffractometer(stn int) RETURNS void AS $$
  -- grabs the diffractometer lock indicating ready to start exposure
  BEGIN
    PERFORM pg_advisory_unlock( stn, 4);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.unlock_diffractometer(int) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.seq_run_prep_OLD( shot_key bigint, kappa float, phi float, cx float, cy float, ax float, ay float, az float) RETURNS void AS $$
  DECLARE
    the_stn int;
  BEGIN
    the_stn := px.getstation();
    IF the_stn is null THEN
      RAISE EXCEPTION 'Cannot determine station number';
    END IF;

    --
    -- set the "as run" positions
    --
    UPDATE px.shots SET skappa=kappa, sphi=phi, scenx=cx, sceny=cy, salignx=ax, saligny=ay, salignz=az WHERE skey=shot_key;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Cannot update px.shots for skey=%', shot_key;
    END IF;

    -- Check that the detector is running
    PERFORM 1 WHERE px.checkDetectorOn() = 0;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'The detector software does not appear to be running';
    END IF;
    
    -- wait for the detector to grab its lock indicating that
    -- it is ready and willing to start integrating
    --
    PERFORM px.lock_detector_test_block( the_stn);

    --
    -- Get the diffractometer lock
    --
    PERFORM pg_advisory_lock( the_stn, 4);

    -- set status
    PERFORM px.shots_set_params( shot_key, kappa::numeric, phi::numeric);

    -- tell the detector to get to work
    PERFORM px.pushqueue( 'collect,' || shot_key::text);

  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.seq_run_prep_OLD( bigint, float, float, float, float, float, float, float) OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.lockCryo() RETURNS void AS $$
  DECLARE
  BEGIN
    PERFORM pg_advisory_lock( px.getstation(), 6);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.lockCryo() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.unlockCryo() RETURNS void AS $$
  DECLARE
  BEGIN
    PERFORM pg_advisory_unlock( px.getstation(), 6);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.unlockCryo() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.waitCryo() RETURNS void AS $$
  DECLARE
  BEGIN
    PERFORM pg_advisory_lock( px.getstation()::int, 6);
    PERFORM pg_advisory_unlock( px.getstation()::int, 6);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.waitCryo() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.dropAirRights( ) returns VOID AS $$
  DECLARE
  BEGIN
    PERFORM pg_advisory_unlock( px.getstation(), 2);
  END;    
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.dropAirRights()  OWNER TO lsadmin;


CREATE OR REPLACE FUNCTION px_iss010.demandAirRights( ) returns VOID AS $$
  BEGIN
    PERFORM pg_advisory_lock( px.getstation(), 2);
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.demandAirRights() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.checkAirRights( ) returns boolean AS $$
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
ALTER FUNCTION px_iss010.checkAirRights() OWNER TO lsadmin;

CREATE OR REPLACE FUNCTION px_iss010.requestAirRights( ) returns boolean AS $$
  DECLARE
    rtn boolean;
  BEGIN
    SELECT pg_try_advisory_lock( px.getstation(), 2) INTO rtn;
    RETURN rtn;
  END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER FUNCTION px_iss010.requestAirRights() OWNER TO lsadmin;
