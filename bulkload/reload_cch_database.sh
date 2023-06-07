#to run one of these in the background type a '&' at the end of the line
#perl make_cumulative_det_log_cch.pl &
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_first_det_log_cch.sql &
#this runs them in the background, which mostly works on cynips, though it can cut the process off if it runs for hours
#check progress by typing 'jobs -l'

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


echo "\n\nrefresh ICPN and eflora synonymy-endemicity insert statements"
perl ../../Jepson-eFlora/eflora_condensed/make_ef_endemicity.pl

echo "\n\nrefresh CCH2 phenology trait table insert statements"
#perl make_CCH2_PHEN_traits.pl

echo "\n\nrefresh PURPLE flags insert statements"
perl make_PURPLE_flags.pl

echo "\n\nrefresh BLACK flags insert statements"
perl make_BLACK_flags.pl

echo "\n\nrefresh BLACK CDL NOMAP flags insert statements"
perl make_BLACK_CDL_NOMAP_flags.pl

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


#this only needs to be run once
#future load can upload just the load csv file to repopulate the cch_dets table, if needed
echo "\n\nrefresh 2018 det change insert statements"
#perl make_CDL_2018_det_log.pl

echo "\n\nupdate 2018 det changes into cch_dets table"
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


echo "insert all archived first and changed CCH dets into cch_dets table"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_first_det_log_cch.sql;
#activate for CSV formats
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_first_det_log_cch.sql;
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


echo "insert cumulative dets into cch_dets table"
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_cumulative_dets.sql;
echo "DONE!"

#####UPDATE MAIN DETS
date;

#sqlite3 output/db/cch1.db < output/load_first_det_main_cch.sql
echo "insert new first dets into cch_main table"
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_new_first_det_main10.sql;
sh bulkload_new_first_det_main.sh
echo "DONE!"



#####INSERT DETS to CCH_DETS and CCH_FLAGGED
date;
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_new_first_dets.sql;
echo "insert new first dets into cch_dets table"
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_new_first_dets01.sql;
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_local_new_first_dets.sql;
echo "DONE!"

open(LAST,">output/load_current_det_change_log.csv") || die; #csv file for names that changed from the last loading to the cch_dets table



date;
echo "insert all names that changed from the last loading to the cch_dets table"
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_current_det_changes.sql;
echo "insert new changed dets into cch_dets table 01"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_local_current_det_changes.sql;
echo "DONE!"



date;
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_current_det_flags.sql;
#activate for CSV formats
echo "insert new changed det flags into cch_flagged table"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_local_current_det_flags.sql;
#activate for CSV formats
#LOAD DATA LOCAL INFILE 'output/load_current_det_flags.csv'
#these are all REPLACE
echo "DONE!"


#THIS SQL FILE BELOW IS RETIRED
#echo "update first CCH dets into cch_main table, PART A"
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_first_det_mainA.sql;
#echo "DONE!"


date;
###########update SQL Query search fields

echo "insert all taxon name SQL query variants into cch_main"
#sqlite3 output/db/cch1.db < output/load_stripped_names_for_SQL.sql
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_stripped_names_for_SQL.sql;
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_stripped_names_for_SQL.sql;
echo "update taxon name SQL query variants into cch_main PART A... "
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < bulkload_stripped_names_main_csvA.sql;

echo "update taxon name SQL query variants into cch_main PART B.... "
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < bulkload_stripped_names_main_csvB.sql;

echo "update taxon name SQL query variants into cch_main PART C.... "
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < bulkload_stripped_names_main_csvC.sql;

echo "update taxon name SQL query variants into cch_main PART D.... "
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < bulkload_stripped_names_main_csvD.sql;

echo "DONE!"


echo "insert all hybrid SQL query variants into cch_main and cch_taxa"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_hybrid_names_main.sql;
echo "DONE!"

date;
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


#populate members table
echo "\n\nrefresh members table insert statements"
#perl make_members_cch.pl

#populate AID table
echo "\n\nrefresh AID cumulative table insert statements"
perl make_cch_aid_table.pl

echo "insert AID cumulative records into cch_aid table part A"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_aid_tableA.sql;
echo "DONE!"

echo "insert AID cumulative records into cch_aid table part B"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_aid_tableB.sql;
echo "DONE!"

echo "insert AID cumulative records into cch_aid table part C"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_aid_tableC.sql;
echo "DONE!"

echo "insert AID cumulative records into cch_aid table part D"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_aid_tableD.sql;
echo "DONE!"

echo "insert AID cumulative records into cch_aid table part E"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_aid_tableE.sql;
echo "DONE!"

echo "insert AID cumulative records into cch_aid table part F"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_aid_tableF.sql;
echo "DONE!"

echo "insert AID cumulative records into cch_aid table part G"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_aid_tableG.sql;
echo "DONE!"

echo "insert AID cumulative records into cch_aid table part H"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_aid_tableH.sql;
echo "DONE!"

echo "\n\nparsing and normalizing CCH2 locality field"
perl process_CCH2_localities.pl

echo "\n\nparsing and normalizing CAS locality field"
perl process_CAS_localities.pl

echo "\n\nparsing and normalizing HUH locality field"
perl process_HUH_localities.pl

echo "\n\nparsing and normalizing NY locality field"
perl process_NY_localities.pl

echo "\n\nparsing and normalizing US locality field"
perl process_US_localities.pl



#####LOAD EFLORA NATIVITY ENDEMICITY STATUS ELEMENTS
##TJM STATUS
echo "insert TJM synonyms plus eflora status into cch_synonyms table in CCH Database"
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_TJM_status.sql;
echo "DONE!"

##TJM ENDEMICITY
echo "insert TJM synonyms with eflora endemic status into cch_synonyms table in CCH Database"
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_TJM_endemicity.sql
echo "DONE!"

##TJM NATIVITY
echo "insert the TJM synonyms with eFlora nativity into cch_synonyms table in CCH Database"
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_TJM_nativity.sql
echo "DONE!"

##CCH STATUS
echo "insert CCH names with eflora status into cch_synonyms table in CCH Database"
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_cch_status.sql;
echo "DONE!"

##CCH ENDEMICITY
echo "insert CCH names with eflora endemic status into cch_synonyms table in CCH Database"
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_cch_endemicity.sql
echo "DONE!"

##CCH NATIVITY
echo "insert the CCH names with eflora nativity into cch_synonyms table in CCH Database"
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_cch_nativity.sql
echo "DONE!"


##ICPN STATUS
echo "insert ICPN synonyms plus eflora status into cch_synonyms table in CCH Database"
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_ICPN_status.sql;
echo "DONE!"

##ICPN ENDEMICITY
echo "insert ICPN endemic status into cch_synonyms table in CCH Database"
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_ICPN_endemicity.sql
echo "DONE!"

##ICPN NATIVITY
echo "insert the ICPN nativity into cch_synonyms table in CCH Database"
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_ICPN_nativity.sql
echo "DONE!"

##EFLORA STATUS
#these are done last right now in order to overwrite any errors in the above files
#ICPN should be master but EFLORA is master at this time
echo "insert eflora and eflora status into cch_synonyms table in CCH Database"
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_status.sql;
echo "DONE!"

##EFLORA ENDEMICITY
echo "insert eflora endemic status into cch_synonyms table in CCH Database"
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_endemicity.sql
echo "DONE!"

##EFLORA NATIVITY
echo "insert the eFlora nativity into cch_synonyms table in CCH Database"
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_nativity.sql
echo "DONE!"



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

echo "\n\nrefresh old CCH buffer GEOREF insert statements"
perl make_buffer_GEOREF_table.pl

echo "\n\nrefresh converted NAD27 GEOREF insert statements"
perl make_converted_NAD27_GEOREF_table.pl


echo "update ALL cch_main NULL georef's with lat-longs from Baldwin 2017"
#sqlite3 output/db/cch1.db < output/load_baldwin_georefs.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_baldwin_georefs.sql;
echo "DONE!"

echo "insert CCH BUFFER  Georefs into cch_main table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_revised_GEOREF_table.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_BUFFER_GEOREF_table.sql;
echo "DONE!"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_HUH_BUFFER_GEOREF_table.sql;

mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_CAS_BUFFER_GEOREF_table.sql;

mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_RSA_BUFFER_GEOREF_table.sql;

mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_BUFFER_GEOREF_table.sql;

echo "insert CCH converted NAD27 Georefs into cch_main table in CCH Database"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_NAD27_revised_GEOREF_table.sql;


echo "find all heteroduplicate records with georefs"
#need a new export of 'output/CCH1_loc_parsed_GEOREF_'.$filedate.'.txt'
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < query_CCH_Heterodups.sql > output/CCH1_loc_parsed_GEOREF_2023JAN27.txt
echo "DONE!"

echo "find all heteroduplicate records that need georefs"
#need a new export of 'output/CCH1_loc_parsed_GEOREF_NULL_'.$filedate.'.txt';
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < query_CCH_NULL_GEOREF.sql > output/CCH1_NULL_GEOREF_2023JAN27.txt
echo "DONE!"


#find old georeferences for new specimens based on parsed loc names
#requires an output file of all of the extant georeferences in CCH1
#CCH1_location_georef_cumulative.txt, created by the main loading scripts
#retired, it is better to query these data from the database and not rely on initial bulkload files
#perl find_CCH2_heterodups.pl

echo "find old georeferences for new specimens based on parse loc names ...process_CCH2_heterodups.pl"
#processes the output from the previous query, CCH1_loc_parsed_GEOREF.txt
#assigns georeferences to new specimens based on the specimens with locs and no georefs in CCH1_loc_parsed_NULL.txt
perl process_CCH2_heterodups.pl




echo "\n\nrefresh revised GEOREF insert statements"
perl make_revise_GEOREF_table.pl

echo "insert UCJEPS-CCH revised Georefs into cch_main table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_revised_GEOREF_table.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_revised_GEOREF_table.sql;
echo "DONE!"

#These georefs can be added to the revised georef file and counted as light blue flags
echo "insert heteroduplicate georefs for CCH1 records still with null georefs"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_heterodup_GEOREFS.sql;


####LOAD DATE FLAGS

echo "insert date flag warnings into cch_flagged table in CCH Database"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_local_date_flags.sql;
#activate for CSV formats
#LOAD DATA LOCAL INFILE 'output/load_date_flags.csv'
#these are all REPLACE
echo "DONE!"


echo "update PART A formatted LJD EJD dates into cch_main... bulkload_formatted_dates_A.sh"
sh bulkload_formatted_dates_A.sh

echo "update PART B formatted LJD EJD dates into cch_main... bulkload_formatted_dates_B.sh"
sh bulkload_formatted_dates_B.sh

echo "update PART C formatted LJD EJD dates into cch_main... bulkload_formatted_dates_C.sh"
sh bulkload_formatted_dates_C.sh

echo "update PART D formatted LJD EJD dates into cch_main... bulkload_formatted_dates_D.sh"
sh bulkload_formatted_dates_D.sh

echo "update PART A formatted LJD EJD dates into cch_main... bulkload_JD_updates_A.sh"
sh bulkload_JD_updates_A.sh

echo "update PART B formatted LJD EJD dates into cch_main... bulkload_JD_updates_B.sh"
sh bulkload_JD_updates_B.sh

echo "update PART C formatted LJD EJD dates into cch_main... bulkload_JD_updates_C.sh"
sh bulkload_JD_updates_C.sh

echo "update PART D formatted LJD EJD dates into cch_main... bulkload_JD_updates_D.sh"
sh bulkload_JD_updates_D.sh




#activate to check file line length problems
#echo "The longest line in the file load_US_stripped_names_for_SQL.csv has $(awk '{print length}' "load_US_stripped_names_for_SQL.csv" | sort -rn | head -1) characters"


####LOAD ELEVATION FLAGS

echo "insert elevaton warnings into cch_flagged table"
#sqlite3 output/db/cch1.db < output/load_elevation_flagging.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_local_elevation_flagging.sql;
#activate for CSV formats
#LOAD DATA LOCAL INFILE 'output/load_elevation_flagging.csv'
#these are all REPLACE
echo "DONE!"




####LOAD COUNTY CORRECTIONS
echo "insert CCH2 county corrections into cch_flagged table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_CCH2_county_corrections.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_local_county_corrections.sql;
#activate for CSV formats
#LOAD DATA LOCAL INFILE 'output/load_county_corrections.csv'

echo "update all other CCH2 county into cch_flagged table in CCH Database"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_verbatim_counties.sql;

echo "get county export file from cch_main for county georef flags"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < CCH1-county-export.sql > output/CCH1-county-export-2023FEB02.txt



####LOAD LOCALITY SQL Query strings
echo "update CCH1 locQ strings into cch_loc table in CCH Database"
#load_stripped_loc_names.sql
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_stripped_loc_names.sql;

echo "update CAS locQ strings into cch_loc table in CCH Database"
#load_stripped_loc_names.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_CAS_stripped_loc_names.sql;

echo "update HUH locQ strings into cch_loc table in CCH Database"
#load_stripped_loc_names.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_HUH_stripped_loc_names.sql;

echo "update NY locQ strings into cch_loc table in CCH Database"
#load_stripped_loc_names.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_NY_stripped_loc_names.sql;

echo "update US locQ strings into cch_loc table in CCH Database"
#load_stripped_loc_names.sql
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_US_stripped_loc_names.sql;


#the is loaded first, then the old hash file corrections are loaded
#these correspond to the county comments below, if the user suggested a revision
echo "insert CCH1 county comments into cch_flagged table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_CCH1_county_comment_flags.sql


##habit
##the order here is important. These are update queries,
##the family data is first, then genus will overwrite family when genus has a value..
##and down to infrataxa, where the entries with LIFE FORM there replace all other values
#accuracy increases with each update
echo "insert eflora family-level habit into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_fhabit.sql
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_fhabit.sql

echo "insert eflora genus-level habit into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_ghabit.sql
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_ghabit.sql

echo "insert eflora species-level habit into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_sphabit.sql
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_sphabit.sql

echo "insert eflora species with infra taxa-level habit into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_shabit.sql
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_shabit.sql

echo "insert eflora infra taxa-level habit into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_ihabit.sql
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_ihabit.sql

echo "insert eflora genus-level nativity into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_gNAT.sql
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_fNAT.sql

echo "insert eflora genus-level nativity into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_gNAT.sql
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_gNAT.sql

echo "insert eflora species-level nativity into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_spNAT.sql
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_spNAT.sql

echo "insert eflora species with infra taxa-level nativity into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_sNAT.sql
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_sNAT.sql

echo "insert eflora infra taxa-level nativity into cch_synonyms table in CCH Database"
#sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_iNAT.sql
mysql --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < ../../Jepson-eFlora/eflora_condensed/output/load_eflora_iNAT.sql


###############UPDATE FLAGGING TABLE ELEMENTS
echo "get records from cch_main for import into GIS for YELLOW FLAGGING"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < YF-export.sql > output/YF-georef-results-2023FEB02.txt



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

echo "update CCH1 YELLOW flags into cch_flagged table"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_YELLOW_flags.sql;
echo "DONE!"

echo "update CCH1 JEPSON regions into cch_main table"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_JEPCODE_main.sql;
echo "DONE!"

echo "update CCH1 OOCA flags into cch_flagged table"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_OOCA_flags.sql;
echo "DONE!"

####LOAD CYAN FLAGS
#no CYAN file for NY, all CA specimens in GBIF are georeferenced
#no CYAN file for US, no corrections yet

echo "update CCH1 CYAN flags into cch_flagged table"
#mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < load_local_CYAN_flags.sql;
#activate for CSV formats
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_CYAN_flags.sql;

mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_BALDWIN_GEOREF_additions.sql;
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_BALDWIN_GEOREF_CYAN_FLAG_additions.sql;


echo "update Baldwin CYAN flags into cch_flagged table"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps <load_local_CYAN_baldwin_flags.sql
#LOAD DATA LOCAL INFILE 'output/load_CYAN_flags.csv'
#US AND NY missing files as they are empty as of Oct 2022
echo "DONE!"


echo "update CCH1 BUFFER CYAN flags into cch_flagged table"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_BUFFER_CYAN_flags.sql;
echo "DONE!"

echo "update CCH1 NAD27 converted CYAN flags into cch_flagged table"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_NAD27_CYAN_flags.sql;
echo "DONE!"

#These georefs can be added to the revised georef file and counted as light blue flags
echo "update CCH1 heteroduplicate CYAN flags into cch_flagged table"
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < output/load_heterodup_CYAN_flags.sql;


echo "insert PHENOLOGY traits into cch_flagged table"
#sqlite3 output/db/cch1.db < output/load_CCH2_PHEN_traits.sql




echo "insert CCH2 members data into members table in CCH Database"
#sqlite3 output/db/cch_members.db < output/load_members.sql

#get coordinates output for yellow flag GIS update
mysql --host=andricus.bnhm.berkeley.edu --user=jason_alexander --password=DipLacus5*5 --database=ucjeps < YF-export.sql > output/YF-georef-results-2023JAN27.txt


#RETIRED, no longer added to CCH1
#echo "insert modified comments into comments table"
#sqlite3 cch1.db < output/load_mod_comments.sql

#RETIRED, no longer added to CCH1
#echo "insert CDL datastamps into cch_timestamp table"
#sqlite3 cch1.db < output/load_CCH1_datestamps.sql

#RETIRED, no longer added to CCH1
#echo "insert CDL-DBM 2018 county corrections into cch_flagged table in CCH Database"
#sqlite3 output/db/cch1.db < output/load_CDL_hash_county_corrections.sql

date;

