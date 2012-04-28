begin;
UPDATE px.holderhistory SET hhState='Inactive' WHERE (hhPosition & x'ffff0000'::int) = x'01030000'::int;
UPDATE px.holderhistory SET hhState='Inactive' WHERE (hhPosition & x'ffff0000'::int) = x'01040000'::int;
UPDATE px.holderhistory SET hhState='Inactive' WHERE (hhPosition & x'ffff0000'::int) = x'01050000'::int;

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES ( x'01030000'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Station F SPINE Cassette 1' limit 1), 'Present');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES ( x'01040000'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Station F SPINE Cassette 2' limit 1), 'Present');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES ( x'01050000'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Station F Rigaku Cassette 3' limit 1), 'Present');

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'01030100'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 1' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030101'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030102'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030103'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030104'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030105'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030106'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030107'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030108'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030109'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0103010a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');



INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'01030200'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 2' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030201'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030202'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030203'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030204'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030205'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030206'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030207'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030208'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030209'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0103020a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');



INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'01030300'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 3' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030301'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030302'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030303'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030304'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030305'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030306'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030307'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030308'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01030309'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0103030a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

------

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'01040100'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 1' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040101'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040102'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040103'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040104'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040105'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040106'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040107'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040108'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040109'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0104010a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'01040200'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 2' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040201'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040202'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040203'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040204'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040205'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040206'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040207'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040208'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040209'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0104020a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');


--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'01040300'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 3' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040301'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040302'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040303'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040304'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040305'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040306'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040307'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040308'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01040309'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0104030a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');


------

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'01050400'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Rigaku Magazine 1' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050401'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050402'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050403'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050404'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050405'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050406'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050407'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050408'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050409'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0105040a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 11');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0105040b'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 11');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 12');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0105040c'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 12');

--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'01050500'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Rigaku Magazine 2' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050501'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050502'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050503'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050504'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050505'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050506'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050507'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050508'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050509'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0105050a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 11');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0105050b'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 11');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 12');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0105050c'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 12');

--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'01050600'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Rigaku Magazine 3' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050601'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050602'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050603'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050604'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050605'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050606'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050607'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050608'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'01050609'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0105060a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 11');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0105060b'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 11');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 12');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0105060c'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 12');

commit;
