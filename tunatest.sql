begin;
select px.tunaLoadInit( 2);

-- Mount a sample
select px.tunaLoad( 2, 'px.requesttransfer( 2, x''02040101''::int)');

-- Wait until that sample is mounted
select px.tunaLoad( 2, 'WHILE px.getcurrentsampleid(2) != x''02040101''::int');
select px.tunaLoad( 2,   '1');
select px.tunaLoad( 2, 'RETURN');

-- Wait until we are idle
select px.tunaLoad( 2, 'WHILE ("State" & 235) = 99  from cats.machinestate() where "Station"=2');
select px.tunaLoad( 2,   '1');
select px.tunaLoad( 2, 'RETURN');

-- Wait for 30 seconds
select px.tunaLoad( 2, 'px.tunamemoryset( 2, ''WaitUntilTime'', (now() + ''30 seconds''::interval)::text)');
select px.tunaLoad( 2, 'WHILE px.tunamemoryget( 2, ''WaitUntilTime'')::timestamptz > now()');
select px.tunaLoad( 2,   '1');
select px.tunaLoad( 2,  'RETURN');

-- Mount a different sample
select px.tunaLoad( 2, 'px.requesttransfer( 2, x''02040102''::int)');

-- Wait until that sample is mounted
select px.tunaLoad( 2, 'WHILE px.getcurrentsampleid(2) != x''02040102''::int');
select px.tunaLoad( 2,   '1');
select px.tunaLoad( 2, 'RETURN');

-- Wait until we are idle
select px.tunaLoad( 2, 'WHILE ("State" & 235) = 99  from cats.machinestate() where "Station"=2');
select px.tunaLoad( 2,   '1');
select px.tunaLoad( 2, 'RETURN');

-- Wait for 30 seconds
select px.tunaLoad( 2, 'px.tunamemoryset( 2, ''WaitUntilTime'', (now() + ''30 seconds''::interval)::text)');
select px.tunaLoad( 2, 'WHILE px.tunamemoryget( 2, ''WaitUntilTime'')::timestamptz > now()');
select px.tunaLoad( 2,   '1');
select px.tunaLoad( 2,  'RETURN');





-- select px.tunaLoad( 2, 'WHILE now() < ''2009-12-4 13:01''');
-- select px.tunaLoad( 2, '1');
-- select px.tunaLoad( 2, 'RETURN');


-- select px.tunaLoad( 2, 'LOOP 2');
-- select px.tunaLoad( 2,   'LOOP 3');
-- select px.tunaLoad( 2,     '1');
-- select px.tunaLoad( 2,   'RETURN');
-- select px.tunaLoad( 2, 'RETURN');
commit;
