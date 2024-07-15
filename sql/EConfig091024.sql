begin;
UPDATE px.holderhistory SET hhState='Inactive' WHERE (hhPosition & x'ffff0000'::int) = x'02030000'::int;
UPDATE px.holderhistory SET hhState='Inactive' WHERE (hhPosition & x'ffff0000'::int) = x'02040000'::int;
UPDATE px.holderhistory SET hhState='Inactive' WHERE (hhPosition & x'ffff0000'::int) = x'02050000'::int;

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES ( x'02030000'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Station E SPINE Cassette 1' limit 1), 'Present');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES ( x'02040000'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Station E SPINE Cassette 2' limit 1), 'Present');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES ( x'02050000'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Station E Rigaku Cassette 3' limit 1), 'Present');

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'02030100'::int, (SELECT hkey FROM px.holders WHERE hBarCode='CD395A' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030101'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030102'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030103'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030104'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030105'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030106'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030107'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030108'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030109'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0203010a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');



INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'02030200'::int, (SELECT hkey FROM px.holders WHERE hBarCode='CD396A' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030201'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030202'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030203'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030204'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030205'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030206'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030207'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030208'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030209'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0203020a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');



INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'02030300'::int, (SELECT hkey FROM px.holders WHERE hBarCode='CD397A' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030301'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030302'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030303'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030304'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030305'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030306'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030307'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030308'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02030309'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0203030a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

------

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'02040100'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 1' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040101'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040102'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040103'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040104'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040105'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040106'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040107'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040108'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040109'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0204010a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'02040200'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 2' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040201'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040202'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040203'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040204'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040205'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040206'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040207'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040208'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040209'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0204020a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'02040300'::int, (SELECT hkey FROM px.holders WHERE hBarCode='SPINE Basket 3' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040301'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040302'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040303'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040304'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040305'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040306'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040307'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040308'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02040309'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0204030a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

------

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'02050400'::int, (SELECT hkey FROM px.holders WHERE hBarCode='029 Gold' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050401'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050402'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050403'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050404'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050405'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050406'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050407'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050408'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050409'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0205040a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 11');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0205040b'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 11');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 12');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0205040c'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 12');

--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'02050500'::int, (SELECT hkey FROM px.holders WHERE hBarCode='029 Purple' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050501'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050502'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050503'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050504'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050505'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050506'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050507'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050508'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050509'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0205050a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 11');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0205050b'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 11');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 12');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0205050c'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 12');

--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'02050600'::int, (SELECT hkey FROM px.holders WHERE hBarCode='029 Red' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050601'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050602'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050603'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050604'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050605'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050606'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050607'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050608'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'02050609'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0205060a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 11');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0205060b'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 11');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 12');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0205060c'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 12');

commit;
