
#Add Last extract here
#.output CCH1_det_log_extract2022JAN26.txt
#change extract date below
#harvest all current dets in cch1.db
#export it to text file
#echo "\nExtracting det log from previous CCH_main"
#sqlite3 output/db/cch1.db <<'END_SQL'
#.timeout 2000
#.output CCH1_det_log_extract_2022MAR02.txt
#SELECT CCH1_LINK_ID, TaxonID,displayName,currentDetermination
#FROM cch_main

#END_SQL

date;

echo "\n\nrefresh CCH first det log table insert statements"
perl make_first_det_log_cch.pl

echo "\n\nrefresh archived CCH det change log table insert statements"
perl make_cumulative_det_log_cch.pl

#this now adds the updated suggs det data to the flag and main tables only
echo "\n\nrefresh SUGGS det log insert statements"
#processed_det_files/CCH1_suggs_det_log_converted.txt
perl make_suggs_det_log_cch.pl


echo "\n\nrefresh CCH2-main table insert statements"
perl make_main_table_cch.pl

echo "\n\nrefresh CAS-main table insert statements"
perl make_main_table_cch_CAS.pl

echo "\n\nrefresh HUH-main table insert statements"
perl make_main_table_cch_HUH.pl

echo "\n\nrefresh NY-main table insert statements"
perl make_main_table_cch_NY.pl

echo "\n\nrefresh US-main table insert statements"
perl make_main_table_cch_US.pl


echo "\n\nrefresh ICPN and eflora synonymy-endemicity insert statements"
#perl ../../Jepson-eFlora/eflora_condensed/make_ef_endemicity.pl

echo "\n\nrefresh CCH2 phenology trait table insert statements"
#perl make_CCH2_PHEN_traits.pl

echo "\n\nrefresh GEOREF county flags insert statements"
#perl make_GEOREF_county_flags.pl

echo "\n\nrefresh PURPLE flags insert statements"
perl make_PURPLE_flags.pl

echo "\n\nrefresh BLACK flags insert statements"
perl make_BLACK_flags.pl

echo "\n\nrefresh BLACK CDL NOMAP flags insert statements"
perl make_BLACK_CDL_NOMAP_flags.pl

echo "\n\nrefresh revised GEOREF insert statements"
perl make_revise_GEOREF_table.pl

date;




echo "\n\nprepare county corrections tables"
#perl process_CCH2_county_log.pl
#perl process_CDL_county_logs.pl

echo "\n\nrefresh CCH2 county correction insert statements"
#perl make_CCH2_county_corrections.pl

echo "\n\nrefresh pre-2018 CCH1 county correction insert statements"
#perl make_CDL_county_corrections.pl

echo "\n\nrefresh SUGGS county comment insert statements"
#perl make_CCH1_county_comment_flags.pl




echo "insert 2018 det changes into cch_dets table"
#sqlite3 output/db/cch_logs.db < output/load_CCH2018_det_changes.sql




#THIS SQL FILE BELOW IS RETIRED
#populate cch_logs table
#echo "insert full CCH det archive into cch_dets table in cch_logs Database"
#sqlite3 output/db/cch_logs.db < output/load_CCH_det_log_archive.sql

#now this can update the order to mark the first record
#THIS SQL FILE BELOW IS RETIRED
#sqlite3 output/db/cch_logs.db < output/load_first_det_log_cch.sql
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_first_det_log_cch.sql;
#echo "DONE!"

#THIS SQL FILE BELOW IS RETIRED
#echo "insert new first CCH2 dets into cch_main table"
#sqlite3 output/db/cch1.db < output/load_first_det_main_cch.sql
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_new_first_det_main_cch2.sql;
#echo "DONE!"


#THIS SQL FILE BELOW IS RETIRED
#echo "insert change det flags into cch_dets table"
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_cumulative_det_log_cch.sql;
#echo "DONE!"

#THIS SQL FILE BELOW IS RETIRED
#echo "insert first CCH dets into cch_dets table, PART A"
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_first_detA.sql;
#echo "DONE!"

#THIS SQL FILE BELOW IS RETIRED
#echo "insert first CCH dets into cch_dets table, PART B"
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_first_detB.sql;
#echo "DONE!"

#THIS SQL FILE BELOW IS RETIRED
#echo "insert all archived first CCH dets into cch_main table"
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_first_det_main_cch.sql;
#echo "DONE!"

#THIS SQL FILE BELOW IS RETIRED
#now this can update the order to mark the last record
#echo "insert last CCH dets into cch_logs Database"
#sqlite3 output/db/cch_logs.db < output/load_last_det_log_cch.sql


date;

#####UPDATE DETS TABLE

date;

echo "insert all archived first and changed CCH dets into cch_dets table"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_first_det_log_cch.sql;
#this sql file contains the below command which then loads the named file
#LOAD DATA LOCAL INFILE 'output/load_first_detA.csv'
#    [IGNORE|REPLACE]
#    INTO TABLE cch_dets
#    CHARACTER SET utf8mb4_unicode_ci
#    FIELDS
#        TERMINATED BY ','
#        OPTIONALLY ENCLOSED BY '"'
#        ESCAPED BY '^'
#    [IGNORE number LINES]
#these are all REPLACE
echo "DONE!"

#####UPDATE MAIN DETS

echo "insert new first dets into cch_main table"
#sqlite3 output/db/cch1.db < output/load_first_det_main_cch.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_new_first_det_main.sql;
echo "DONE!"




#####INSERT DETS to CCH_DETS and CCH_FLAGGED
echo "insert all new first dets to the cch_dets table"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_new_first_dets.sql;
#this sql file contains a SQL command which loads the below named file
#LOAD DATA LOCAL INFILE 'output/load_CCH2_new_first_det_log.csv'
#LOAD DATA LOCAL INFILE 'output/load_CAS_new_first_det_log.csv'
#LOAD DATA LOCAL INFILE 'output/load_HUH_new_first_det_log.csv'
#LOAD DATA LOCAL INFILE 'output/load_NY_new_first_det_log.csv'
#LOAD DATA LOCAL INFILE 'output/load_US_new_first_det_log.csv'
#these are all REPLACE
echo "DONE!"

echo "insert all names that changed from the last loading to the cch_dets table"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_current_det_changes.sql;
#this sql file contains a SQL command which loads the below named file
#LOAD DATA LOCAL INFILE 'output/load_CCH2_current_det_change_log.csv'
#LOAD DATA LOCAL INFILE 'output/load_CAS_current_det_change_log.csv'
#LOAD DATA LOCAL INFILE 'output/load_HUH_current_det_change_log.csv'
#LOAD DATA LOCAL INFILE 'output/load_NY_current_det_change_log.csv'
#LOAD DATA LOCAL INFILE 'output/load_US_current_det_change_log.csv'
#these are all REPLACE
echo "DONE!"

echo "insert taxon name change flags to the cch_flagged table"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_current_det_flags.sql;
#this sql file contains a SQL command which loads the below named file
#LOAD DATA LOCAL INFILE 'output/load_CCH2_current_det_flags.csv'
#LOAD DATA LOCAL INFILE 'output/load_CAS_current_det_flags.csv'
#LOAD DATA LOCAL INFILE 'output/load_HUH_current_det_flags.csv'
#LOAD DATA LOCAL INFILE 'output/load_NY_current_det_flags.csv'
#LOAD DATA LOCAL INFILE 'output/load_US_current_det_flags.csv'
#these are all REPLACE
echo "DONE!"

#THIS SQL FILE BELOW IS RETIRED
#echo "update first CCH dets into cch_main table, PART A"
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_first_det_mainA.sql;
#echo "DONE!"



###########update SQL Query search fields

echo "insert all SQL query variant taxon names into cch_main"
#sqlite3 output/db/cch1.db < output/load_stripped_names_for_SQL.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_stripped_names_for_SQL.sql;
echo "DONE!"




#####INSERT DET COMMENT LOGS to cch_dets

echo "insert SUGGS dets into cch_dets table in CCH Database"
#sqlite3 output/db/cch_logs.db < output/load_suggs_det_log_cch.sql
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_suggs_det_log_cch.sql;
echo "DONE!"

echo "insert Comment Log Det Questioned in cch_flagged table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_flag_det_questioned.sql
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_flag_det_questioned.sql;
echo "DONE!"

echo "insert Comment Log Det Revised in cch_flagged table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_flag_det_update.sql
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_flag_det_changed.sql;
echo "DONE!"

echo "update displayName with Comment Log Dets in main table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_suggs_main_det_update.sql
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_suggs_main_det_update.sql;
echo "DONE!"


date;

#####UPDATE MAIN TABLE CAS
echo "insert CAS records into main table, PART A"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_CAS_mainA.sql;
echo "DONE!"

echo "insert CAS records into main table, PART B"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_CAS_mainB.sql;
echo "DONE!"

echo "insert CAS records into main table, PART C"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_CAS_mainC.sql;
echo "DONE!"

echo "insert CAS records into main table, PART D"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_CAS_mainD.sql;
echo "DONE!"

echo "insert CAS records into main table, PART E"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_CAS_mainE.sql;
echo "DONE!"

echo "insert CAS records into main table, PART F"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_CAS_mainF.sql;
echo "DONE!"

echo "insert CAS records into main table, PART G"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_CAS_mainG.sql;
echo "DONE!"

echo "insert CAS records into main table, PART H"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_CAS_mainH.sql;
echo "DONE!"

#####UPDATE MAIN TABLE NY
echo "insert NY records into main table, PART A"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_NY_mainA.sql;
echo "DONE!"


#####UPDATE MAIN TABLE US
echo "insert US records into main table, PART A"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_US_mainA.sql;
echo "DONE!"


#####UPDATE MAIN TABLE HUH
echo "insert HUH records into main table, PART A"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_HUH_mainA.sql;
echo "DONE!"

echo "insert HUH records into main table, PART B"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_HUH_mainB.sql;
echo "DONE!"

date;

#####UPDATE MAIN TABLE
echo "insert taxa into main table, PART A"
#sqlite3 output/db/cch1.db < output/load_mainA.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainA.sql;
echo "DONE!"

echo "insert taxa into main table, PART B"
#sqlite3 output/db/cch1.db < output/load_mainB.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainB.sql;
echo "DONE!"

echo "insert taxa into main table, PART C"
#sqlite3 output/db/cch1.db < output/load_mainC.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainC.sql;
echo "DONE!"

echo "insert taxa into main table, PART D"
#sqlite3 output/db/cch1.db < output/load_mainD.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainD.sql;
echo "DONE!"

echo "insert taxa into main table, PART E"
#sqlite3 output/db/cch1.db < output/load_mainE.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainE.sql;
echo "DONE!"

echo "insert taxa into main table, PART F"
#sqlite3 output/db/cch1.db < output/load_mainF.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainF.sql;
echo "DONE!"

echo "insert taxa into main table, PART G"
#sqlite3 output/db/cch1.db < output/load_mainG.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainG.sql;
echo "DONE!"

echo "insert taxa into main table, PART H"
#sqlite3 output/db/cch1.db < output/load_mainH.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainH.sql;
echo "DONE!"

echo "insert taxa into main table, PART I"
#sqlite3 output/db/cch1.db < output/load_mainI.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainI.sql;
echo "DONE!"

echo "insert taxa into main table, PART J"
#sqlite3 output/db/cch1.db < output/load_mainJ.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainJ.sql;
echo "DONE!"

echo "insert taxa into main table, PART K"
#sqlite3 output/db/cch1.db < output/load_mainK.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainK.sql;
echo "DONE!"

echo "insert taxa into main table, PART L"
#sqlite3 output/db/cch1.db < output/load_mainL.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainL.sql;
echo "DONE!"

echo "insert taxa into main table, PART M"
#sqlite3 output/db/cch1.db < output/load_mainM.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainM.sql;
echo "DONE!"

echo "insert taxa into main table, PART N"
#sqlite3 output/db/cch1.db < output/load_mainN.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainN.sql;
echo "DONE!"

echo "insert taxa into main table, PART O"
#sqlite3 output/db/cch1.db < output/load_mainO.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainO.sql;
echo "DONE!"

echo "insert taxa into main table, PART P"
#sqlite3 output/db/cch1.db < output/load_mainP.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainP.sql;
echo "DONE!"

echo "insert taxa into main table, PART Q"
#sqlite3 output/db/cch1.db < output/load_mainQ.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainQ.sql;
echo "DONE!"

echo "insert taxa into main table, PART R"
#sqlite3 output/db/cch1.db < output/load_mainQ.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainR.sql;
echo "DONE!"

echo "insert taxa into main table, PART S"
#sqlite3 output/db/cch1.db < output/load_mainQ.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainS.sql;
echo "DONE!"

echo "insert taxa into main table, PART T"
#sqlite3 output/db/cch1.db < output/load_mainQ.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainT.sql;
echo "DONE!"

echo "insert taxa into main table, PART U"
#sqlite3 output/db/cch1.db < output/load_mainQ.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainU.sql;
echo "DONE!"

echo "insert taxa into main table, PART V"
#sqlite3 output/db/cch1.db < output/load_mainQ.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainV.sql;
echo "DONE!"

echo "insert taxa into main table, PART W"
#sqlite3 output/db/cch1.db < output/load_mainQ.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainW.sql;
echo "DONE!"

echo "insert taxa into main table, PART X"
#sqlite3 output/db/cch1.db < output/load_mainQ.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainX.sql;
echo "DONE!"

echo "insert taxa into main table, PART Y"
#sqlite3 output/db/cch1.db < output/load_mainQ.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainY.sql;
echo "DONE!"

echo "insert taxa into main table, PART Z"
#sqlite3 output/db/cch1.db < output/load_mainQ.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_mainZ.sql;
echo "DONE!"

date;





#populate members table
echo "\n\nrefresh members table insert statements"
#perl make_members_cch.pl

echo "\n\nparsing and normalizing CCH2 locality field"
#perl process_CCH2_localities.pl

echo "insert first load of synonyms plus eflora status into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_status.sql

echo "insert eflora endemic status into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_endemicity.sql

#HTTP GET https://ucjeps.cspace.berkeley.edu/cspace-services/collectionobjects?kw=UC1532594 HTTP/1.1


#queried CCH2 fields
#InstitutionCode	occid	occurrenceID	catalogNumber	otherCatalogNumbers	Sciname	tidinterpreted	taxonRemarks	identificationQualifier	identifiedBy	#10
#dateIdentified	identificationRemarks	typeStatus	recordedBy	associatedCollectors	recordNumber	year	month	day	verbatimEventDate	#20
#country	stateProvince	county	locality	locationRemarks	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	verbatimCoordinates	#30
#georeferencedBy	georeferenceSources	georeferenceRemarks	minimumElevationInMeters	maximumElevationInMeters	verbatimElevation	habitat	occurrenceRemarks	associatedTaxa	verbatimAttributes	#40
#reproductiveCondition	cultivationStatus	dateLastModified #43

#the above only loads CCH2 records
#Seinet has to be loaded
#as separate files for each herbarium
#including NY and GH

#######GEOREFERENCE CORRECTIONS AND UPDATES
echo "update CCH2 NULL georef's with lat-longs from Baldwin 2017"
#sqlite3 output/db/cch1.db < output/load_baldwin_georefs.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_baldwin_georefs.sql;
echo "DONE!"

echo "update CAS GBIF NULL georef's with lat-longs from Baldwin 2017"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_CAS_baldwin_georefs.sql;
echo "DONE!"

echo "update HUH GBIF NULL georef's with lat-longs from Baldwin 2017"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_HUH_baldwin_georefs.sql;
echo "DONE!"

echo "update NY GBIF NULL georef's with lat-longs from Baldwin 2017"
#THIS TABLE IS EMPTY, there are NY specimens in Baldwin, 
#all of the NY specimens in GBIF for California have coordinates
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_NY_baldwin_georefs.sql;
echo "DONE!"

echo "update US GBIF NULL georef's with lat-longs from Baldwin 2017"
#THIS TABLE IS EMPTY, PROBABLY CORRECT RESULT
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_US_baldwin_georefs.sql;
echo "DONE!"


echo "insert UCJEPS-CCH revised Georefs into cch_georef table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_revised_GEOREF_table.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_revised_GEOREF_table.sql;
echo "DONE!"


####LOAD CYAN FLAGS
#no CYAN file for NY, all CA specimens in GBIF are georeferenced
#no CYAN file for US, no corrections yet

echo "insert ALL CYAN flags into cch_flagged table in CCH Database"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_CYAN_flags.sql;
#LOAD DATA LOCAL INFILE 'output/load_CCH2_CYAN_flags.csv'
#LOAD DATA LOCAL INFILE 'output/load_CAS_CYAN_flags.csv'
#LOAD DATA LOCAL INFILE 'output/load_HUH_CYAN_flags.csv'
#LOAD DATA LOCAL INFILE 'output/load_CCH2_CYAN_flags_baldwin.csv'
#LOAD DATA LOCAL INFILE 'output/load_CAS_CYAN_flags_baldwin.csv'
#LOAD DATA LOCAL INFILE 'output/load_HUH_CYAN_flags_baldwin.csv'
#US AND NY missing files as they are empty as of Oct 2022
echo "DONE!"


####LOAD DATE FLAGS

echo "insert date flag warnings into cch_flagged table in CCH Database"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_date_flags.sql;
#LOAD DATA LOCAL INFILE 'output/load_CCH2_date_flag.csv'
#LOAD DATA LOCAL INFILE 'output/load_CAS_date_flag.csv'
#LOAD DATA LOCAL INFILE 'output/load_HUH_date_flag.csv'
#LOAD DATA LOCAL INFILE 'output/load_NY_date_flag.csv'
#LOAD DATA LOCAL INFILE 'output/load_US_date_flag.csv'
#these are all REPLACE
echo "DONE!"



echo "The longest line in the file load_US_stripped_names_for_SQL.csv has $(awk '{print length}' "load_US_stripped_names_for_SQL.csv" | sort -rn | head -1) characters"


####LOAD ELEVATION FLAGS

echo "insert elevaton warnings into cch_flagged table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_elevation_flagging.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_elevation_flags.sql;
#this sql file contains a SQL command which loads the below named file
#LOAD DATA LOCAL INFILE 'output/load_elevation_flagging.csv'
echo "DONE!"




####LOAD COUNTY CORRECTIONS
echo "insert CCH2 county corrections into cch_flagged table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_CCH2_county_corrections.sql

#the is loaded first, then the old hash file corrections are loaded
#these correspond to the county comments below, if the user suggested a revision
echo "insert CCH1 county comments into cch_flagged table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_CCH1_county_comment_flags.sql

echo "insert GEOREF county warnings into cch_flagged table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_GEOREF_county_flags.sql


echo "insert CDL-DBM 2018 county corrections into cch_flagged table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_CDL_hash_county_corrections.sql


##habit

echo "insert eflora family-level habit into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_fhabit.sql

echo "insert eflora genus-level habit into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_ghabit.sql

echo "insert eflora species-level habit into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_sphabit.sql

echo "insert eflora species with infra taxa-level habit into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_shabit.sql

echo "insert eflora infra taxa-level habit into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_ihabit.sql

##NATIVITY
echo "insert eflora genus-level nativity into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_gNAT.sql

echo "insert eflora species-level nativity into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_spNAT.sql

echo "insert eflora species with infra taxa-level nativity into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_sNAT.sql

echo "insert eflora infra taxa-level nativity into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_iNAT.sql

echo "insert the eFlora nativity into cch_synonyms table in CCH Database"
#this updaes the nativity for taxa that do not have an extracted life form character
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_nativity.sql




echo "insert PURPLE flags into cch_flagged table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_PURPLE_flags.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_PURPLE_flags.sql;
echo "DONE!"

echo "insert BLACK CDL NOMAP flags into cch_flagged table in CCH Database"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_BLACK_CDL_NOMAP_flags.sql;
echo "DONE!"

echo "insert BLACK flags into cch_flagged table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_BLACK_flags.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_BLACK_flags.sql;
echo "DONE!"

echo "insert PHENOLOGY traits into cch_flagged table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_CCH2_PHEN_traits.sql


echo "insert CCH2 members data into members table in CCH Database"
#sqlite3 output/db/cch_members.db < output/load_members.sql

#RETIRED, no longer added to CCH1
#echo "insert modified comments into comments table"
#sqlite3 cch1.db < output/load_mod_comments.sql

#RETIRED, no longer added to CCH1
#echo "insert CDL datastamps into cch_timestamp table"
#sqlite3 cch1.db < output/load_CCH1_datestamps.sql


