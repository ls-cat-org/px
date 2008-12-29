begin;
UPDATE px.holderhistory SET hhState='Inactive' WHERE (hhPosition & x'ffff0000'::int) = x'04030000'::int;
UPDATE px.holderhistory SET hhState='Inactive' WHERE (hhPosition & x'ffff0000'::int) = x'04040000'::int;
UPDATE px.holderhistory SET hhState='Inactive' WHERE (hhPosition & x'ffff0000'::int) = x'04050000'::int;

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES ( x'04030000'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Station G SPINE Cassette 1' limit 1), 'Present');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES ( x'04040000'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Station G SPINE Cassette 2' limit 1), 'Present');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES ( x'04050000'::int, (SELECT hkey FROM px.holders WHERE hBarCode='Station G SPINE Cassette 3' limit 1), 'Present');

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'04030100'::int, (SELECT hkey FROM px.holders WHERE hBarCode='CD011A' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030101'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030102'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030103'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030104'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030105'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030106'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030107'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030108'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030109'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0403010a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');



INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'04030200'::int, (SELECT hkey FROM px.holders WHERE hBarCode='CD480A' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030201'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030202'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030203'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030204'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030205'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030206'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030207'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030208'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030209'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0403020a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');



INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'04030300'::int, (SELECT hkey FROM px.holders WHERE hBarCode='CD013A' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030301'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030302'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030303'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030304'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030305'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030306'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030307'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030308'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04030309'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0403030a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

------

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'04040100'::int, (SELECT hkey FROM px.holders WHERE hBarCode='CD396A' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040101'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040102'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040103'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040104'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040105'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040106'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040107'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040108'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040109'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0404010a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');


--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'04040200'::int, (SELECT hkey FROM px.holders WHERE hBarCode='CD397A' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040201'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040202'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040203'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040204'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040205'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040206'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040207'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040208'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040209'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0404020a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'04040300'::int, (SELECT hkey FROM px.holders WHERE hBarCode='CD012A' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040301'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040302'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040303'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040304'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040305'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040306'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040307'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040308'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04040309'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0404030a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

------
------

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'04050100'::int, (SELECT hkey FROM px.holders WHERE hBarCode='CD549A' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050101'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050102'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050103'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050104'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050105'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050106'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050107'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050108'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050109'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0405010a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');


--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'04050200'::int, (SELECT hkey FROM px.holders WHERE hBarCode='CD398A' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050201'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050202'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050203'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050204'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050205'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050206'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050207'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050208'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050209'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0405020a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');

--

INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState) VALUES (x'04050300'::int, (SELECT hkey FROM px.holders WHERE hBarCode='CD086A' LIMIT 1), 'Present');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 01');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050301'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 1');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 02');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050302'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 2');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 03');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050303'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 3');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 04');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050304'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 4');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 05');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050305'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 5');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 06');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050306'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 6');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 07');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050307'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 7');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 08');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050308'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 8');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 09');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'04050309'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 9');

INSERT INTO px.holders (hType, hName) VALUES ('CrystalCap HT   HR8', 'Sample 10');
INSERT INTO px.holderhistory (hhPosition, hhHolder, hhState, hhExpId, hhMaterial) VALUES ( x'0405030a'::int, currval( 'px.holders_hkey_seq'), 'Present', 57378, 'Empty Loop 10');


commit;
