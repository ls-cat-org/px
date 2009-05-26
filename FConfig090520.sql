begin;
UPDATE px.holderhistory SET hhState='Inactive' WHERE (hhPosition & x'ffff0000'::int) = x'03030000'::int;
UPDATE px.holderhistory SET hhState='Inactive' WHERE (hhPosition & x'ffff0000'::int) = x'03040000'::int;
UPDATE px.holderhistory SET hhState='Inactive' WHERE (hhPosition & x'ffff0000'::int) = x'03050000'::int;

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES ( x'03030000'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Station F SPINE Cassette 1' limit 1), 'Present');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES ( x'03040000'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Station F Rigaku Cassette 2' limit 1), 'Present');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES ( x'03050000'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Station F Rigaku Cassette 3' limit 1), 'Present');

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'03030100'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 1' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030101'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030102'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030103'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030104'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030105'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030106'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030107'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030108'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030109'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0303010a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');



INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'03030200'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 2' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030201'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030202'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030203'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030204'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030205'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030206'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030207'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030208'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030209'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0303020a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');



INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'03030300'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 3' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030301'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030302'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030303'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030304'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030305'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030306'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030307'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030308'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03030309'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0303030a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

------

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'03040100'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 1' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040101'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040102'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040103'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040104'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040105'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040106'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040107'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040108'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040109'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0304010a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'03040200'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 2' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040201'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040202'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040203'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040204'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040205'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040206'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040207'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040208'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040209'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0304020a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'03040300'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 3' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040301'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040302'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040303'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040304'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040305'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040306'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040307'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040308'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03040309'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0304030a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

------

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'03050400'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Rigaku Magazine 1' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050401'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050402'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050403'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050404'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050405'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050406'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050407'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050408'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050409'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0305040a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 11');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0305040b'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 11');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 12');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0305040c'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 12');

--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'03050500'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Rigaku Magazine 2' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050501'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050502'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050503'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050504'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050505'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050506'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050507'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050508'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050509'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0305050a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 11');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0305050b'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 11');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 12');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0305050c'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 12');

--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'03050600'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Rigaku Magazine 3' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050601'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050602'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050603'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050604'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050605'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050606'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050607'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050608'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'03050609'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0305060a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 11');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0305060b'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 11');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 12');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0305060c'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 12');

commit;
