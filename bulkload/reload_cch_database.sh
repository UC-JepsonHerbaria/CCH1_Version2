
#Add Last extract here
#.output CCH1_det_log_extract2022JAN26.txt
#change extract date below
#harvest all current dets in cch1.db
#export it to text file
echo "\nExtracting det log from previous CCH_main"
sqlite3 output/db/cch1.db <<'END_SQL'
.timeout 2000
.output CCH1_det_log_extract2022MAY23.txt
SELECT CCH1_LINK_ID, TaxonID,displayName,currentDetermination
FROM cch_main

END_SQL


#echo "drop and recreate CCH1 MAIN databases"
#sqlite3 output/db/cch1.db < create_statements_cch.sql

#echo "create CCH1 database indexes.........."
#sqlite3 output/db/cch1.db < create_indexes_cch.sql

#echo "drop and recreate Member database"
#sqlite3 output/db/cch_members.db < create_statements_cch_members.sql

#acrtivate these if you need to recreate the cch det log file
#echo "drop and recreate CCH1 log database"
#sqlite3 output/db/cch_logs.db < create_statements_cch_detlog.sql

#echo "create CCH1 LOG database indexes.........."
#sqlite3 output/db/cch_logs.db < create_indexes_cch_logs.sql


#echo "drop and recreate CCH1 Interp databases"
#sqlite3 cch1Interp.db < create_statements_cch_interp.sql

#echo "create Interp database indexes.........."
#sqlite3 cch1Interp.db < create_indexes_cch_interp.sql


#echo "create one index.........."
#sqlite3 cch1.db < create_single_index_cch.sql

#echo "drop and recreate single table"
#sqlite3 cch1.db < create_single_table_cch.sql


#echo "\n\nrefresh timestamp insert statements"
#perl make_CDL_datestamps.pl


echo "\n\nrefresh main table insert statements"
perl make_main_table_cch.pl

echo "\n\nrefresh ICPN and eflora synonymy-endemicity insert statements"
perl /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/make_ef_endemicity.pl

echo "\n\nrefresh CCH2 phenology trait table insert statements"
perl make_CCH2_PHEN_traits.pl

echo "\n\nrefresh GEOREF county flags insert statements"
perl make_GEOREF_county_flags.pl

echo "\n\nrefresh PURPLE flags insert statements"
perl make_PURPLE_flags.pl

echo "\n\nrefresh BLACK flags insert statements"
perl make_BLACK_flags.pl

echo "\n\nrefresh BLACK CDL NOMAP flags insert statements"
perl make_BLACK_CDL_NOMAP_flags.pl

echo "\n\nrefresh revised GEOREF insert statements"
perl make_revise_GEOREF_table.pl


echo "\n\nprepare county corrections tables"
perl process_CCH2_county_log.pl
perl process_CDL_county_logs.pl

echo "\n\nrefresh CCH2 county correction insert statements"
perl make_CCH2_county_corrections.pl

echo "\n\nrefresh pre-2018 CCH1 county correction insert statements"
perl make_CDL_county_corrections.pl

echo "\n\nrefresh SUGGS county comment insert statements"
perl make_CCH1_county_comment_flags.pl

echo "\n\nrefresh SUGGS det log insert statements"
#processed_det_files/CCH1_suggs_det_log_converted.txt
perl make_suggs_det_log_cch.pl

echo "\n\nrefresh first det log table insert statements"
#perl make_first_det_log_cch.pl


#echo "\n\nrefresh det change log table insert statements"
#perl make_cch_cumulative_dets_table.pl

#add all name change flags first
echo "insert change det log into cch_main database"
#sqlite3 output/db/cch1.db < output/load_current_det_changes.sql

#populate cch_logs table
#echo "insert full CCH det archive into cch_dets table in cch_logs Database"
#sqlite3 output/db/cch_logs.db < output/load_CCH_det_log_archive.sql

#now this can update the order to mark the first record
echo "insert first CCH dets into cch_logs Database"
#sqlite3 output/db/cch_logs.db < output/load_first_det_log_cch.sql



#now this is a patch until I can get the det history log loaded on detail page
echo "insert first CCH dets into cch_main Database"
sqlite3 output/db/cch1.db < output/load_first_det_main_cch.sql


echo "insert 2018 det changes into cch_dets table"
#sqlite3 output/db/cch_logs.db < output/load_CCH2018_det_changes.sql

#now this can update the order to mark the last record
echo "insert last CCH dets into cch_logs Database"
#sqlite3 output/db/cch_logs.db < output/load_last_det_log_cch.sql

echo "insert most recent CCH2 dets into cch_dets table"
#sqlite3 output/db/cch_logs.db < output/load_recent_det_log_cch2.sql

echo "insert most recent CCH2 dets into cch_dets table"
#sqlite3 output/db/cch_logs.db < output/load_det_change_log_cch2.sql



#populate members table
echo "\n\nrefresh members table insert statements"
perl make_members_cch.pl

echo "\n\nparsing and normalizing CCH2 locality field"
perl process_CCH2_localities.pl

echo "insert first load of synonyms plus eflora status into cch_synonyms table in CCH Database"
sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_status.sql

echo "insert eflora endemic status into cch_synonyms table in CCH Database"
sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_endemicity.sql


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

echo "update NULL georef's with lat-longs from Baldwin 2017"
sqlite3 output/db/cch1.db < output/load_baldwin_georefs.sql

echo "insert CCH2 members data into members table in CCH Database"
sqlite3 output/db/cch_members.db < output/load_members.sql

echo "insert elevaton warnings into cch_flagged table in CCH Database"
sqlite3 output/db/cch1.db < output/load_elevation_flagging.sql

echo "insert CCH2 county corrections into cch_flagged table in CCH Database"
sqlite3 output/db/cch1.db < output/load_CCH2_county_corrections.sql

echo "insert CDL-DBM 2018 county corrections into cch_flagged table in CCH Database"
sqlite3 output/db/cch1.db < output/load_CDL_hash_county_corrections.sql

#the is loaded first, then the old hash file corrections are loaded
#these correspond to the county comments below, if the user suggested a revision
echo "insert CCH1 county comments into cch_flagged table in CCH Database"
sqlite3 output/db/cch1.db < output/load_CCH1_county_comment_flags.sql

echo "insert GEOREF county warnings into cch_flagged table in CCH Database"
sqlite3 output/db/cch1.db < output/load_GEOREF_county_flags.sql

echo "insert date flag warnings into cch_flagged table in CCH Database"
sqlite3 output/db/cch1.db < output/load_date_flag.sql

echo "insert taxa into main table, PART A"
sqlite3 output/db/cch1.db < output/load_mainA.sql

echo "insert taxa into main table, PART B"
sqlite3 output/db/cch1.db < output/load_mainB.sql


echo "insert taxa into main table, PART C"
sqlite3 output/db/cch1.db < output/load_mainC.sql

echo "insert taxa into main table, PART D"
sqlite3 output/db/cch1.db < output/load_mainD.sql


echo "insert taxa into main table, PART E"
sqlite3 output/db/cch1.db < output/load_mainE.sql

echo "insert taxa into main table, PART F"
sqlite3 output/db/cch1.db < output/load_mainF.sql

echo "insert taxa into main table, PART G"
sqlite3 output/db/cch1.db < output/load_mainG.sql

echo "insert taxa into main table, PART H"
sqlite3 output/db/cch1.db < output/load_mainH.sql

echo "insert taxa into main table, PART I"
sqlite3 output/db/cch1.db < output/load_mainI.sql

echo "insert taxa into main table, PART J"
sqlite3 output/db/cch1.db < output/load_mainJ.sql

echo "insert taxa into main table, PART K"
sqlite3 output/db/cch1.db < output/load_mainK.sql

echo "insert taxa into main table, PART L"
sqlite3 output/db/cch1.db < output/load_mainL.sql

echo "insert taxa into main table, PART M"
sqlite3 output/db/cch1.db < output/load_mainM.sql

echo "insert taxa into main table, PART N"
sqlite3 output/db/cch1.db < output/load_mainN.sql

echo "insert taxa into main table, PART O"
sqlite3 output/db/cch1.db < output/load_mainO.sql

echo "insert taxa into main table, PART P"
sqlite3 output/db/cch1.db < output/load_mainP.sql

echo "insert taxa into main table, PART Q"
sqlite3 output/db/cch1.db < output/load_mainQ.sql

#skipped, no longer added to CCH1
#echo "insert modified comments into comments table"
#sqlite3 cch1.db < output/load_mod_comments.sql

##habit

echo "insert eflora family-level habit into cch_synonyms table in CCH Database"
sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_fhabit.sql

echo "insert eflora genus-level habit into cch_synonyms table in CCH Database"
sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_ghabit.sql

echo "insert eflora species-level habit into cch_synonyms table in CCH Database"
sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_sphabit.sql

echo "insert eflora species with infra taxa-level habit into cch_synonyms table in CCH Database"
sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_shabit.sql

echo "insert eflora infra taxa-level habit into cch_synonyms table in CCH Database"
sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_ihabit.sql

##NATIVITY
echo "insert eflora genus-level nativity into cch_synonyms table in CCH Database"
sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_gNAT.sql

echo "insert eflora species-level nativity into cch_synonyms table in CCH Database"
sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_spNAT.sql

echo "insert eflora species with infra taxa-level nativity into cch_synonyms table in CCH Database"
sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_sNAT.sql

echo "insert eflora infra taxa-level nativity into cch_synonyms table in CCH Database"
sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_iNAT.sql

echo "insert the eFlora nativity into cch_synonyms table in CCH Database"
#this updaes the nativity for taxa that do not have an extracted life form character
sqlite3 output/db/cch1.db < /Users/Shared/Jepson-Master/Jepson-eFlora/eflora_condensed/output/load_eflora_nativity.sql


#echo "insert CDL datastamps into cch_timestamp table"
#sqlite3 cch1.db < output/load_CCH1_datestamps.sql

echo "insert CYAN flags into cch_flagged table in CCH Database"
sqlite3 output/db/cch1.db < output/load_CYAN_flags.sql


echo "insert PURPLE flags into cch_flagged table in CCH Database"
sqlite3 output/db/cch1.db < output/load_PURPLE_flags.sql

echo "insert BLACK CDL NOMAP flags into cch_flagged table in CCH Database"
sqlite3 output/db/cch1.db < output/load_BLACK_CDL_NOMAP_flags.sql

echo "insert BLACK flags into cch_flagged table in CCH Database"
sqlite3 output/db/cch1.db < output/load_BLACK_flags.sql

echo "insert PHENOLOGY traits into cch_flagged table in CCH Database"
sqlite3 output/db/cch1.db < output/load_CCH2_PHEN_traits.sql

echo "insert UCJEPS-CCH revised Georefs into cch_georef table in CCH Database"
sqlite3 output/db/cch1.db < output/load_revised_GEOREF_table.sql

echo "insert Comment Log Det Questioned in cch_flagged table in CCH Database"
sqlite3 output/db/cch1.db < output/load_flag_det_questioned.sql

echo "insert Comment Log Det Updates in cch_flagged table in CCH Database"
sqlite3 output/db/cch1.db < output/load_flag_det_update.sql

echo "update displayName with Comment Log Dets in main table in CCH Database"
sqlite3 output/db/cch1.db < output/load_suggs_main_det_update.sql

echo "insert stripped taxon names into cch_main"
sqlite3 output/db/cch1.db < output/load_stripped_names_for_SQL.sql

echo "insert first SUGGS dets into cch_logs Database"
#sqlite3 output/db/cch_logs.db < output/load_suggs_det_log_cch.sql


