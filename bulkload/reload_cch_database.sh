
echo "drop and recreate tables"
sqlite3 cch1.db < create_statements_cch.sql





echo "\n\n'process_CCH2_main table'....  processing the exported CCH2 main table file 'CCH2_export_[date].txt'"
echo "creates text file of the California records that pass all data checks.... 'CCH2_out.txt'"
echo "creates text file of problem Mexico records labeld as California specimens.... 'CCH2_mex_problem_LOG.txt'"
echo "prints all county corrections to the file 'CCH2_BAD_CA_COUNTY_LOG.txt', which is used for creating the county corrections table"
#perl process_CCH2_main_table.pl


echo "\n\nrefresh main table insert statements"
perl make_main_table_cch.pl


echo "\n\n'process_CCH2_county_log'....  processing the converted CCH1 county log file 'CCH1_county_converted.txt'"
echo "includes the county records from CCH2 that need converted that were not found in CCH1 'CCH2_BAD_CA_COUNTY_LOG.txt' \n\n"
echo "creates text file of the processed county records.... 'CCH2_county_converted.txt'"
echo "excludes county corrections already made in CCH1 and prints them to 'CCH2_CORRECTIONS_PROBLEMS'"
#perl process_CCH2_county_log.pl


echo "\n\nrefresh county corrections table insert statements"
#perl make_county_cch.pl


echo "\n\nrefresh first determinations & accession log table insert statements"
#CCH1_detnames_first_converted.txt
#perl make_main_table_cch.pl

echo "\n\nrefresh full determinations table insert statements"
#CCH1_full_detlog_converted.txt
#perl make_main_table_cch.pl


echo "\n\nrefresh suggestions log table insert statements"
#perl make_main_table_cch.pl


echo "\n\nrefresh members table insert statements"
#perl make_members_cch.pl


echo "\n\nrefresh eFlora synonymy table insert statements"
perl make_synonymy_table_cch.pl


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

echo "insert taxa into main table, PART C"
sqlite3 cch1.db < output/load_mainC.sql

echo "insert modified comments into comments table"
#sqlite3 cch1.db < output/load_mod_comments.sql

echo "insert CCH2 members data into members table"
sqlite3 cch1.db < output/load_members.sql

echo "insert elevaton warnings into cch_flagged table"
sqlite3 cch1.db < output/load_elevation_flagging.sql

echo "insert determinations into cch_dets table"
#sqlite3 cch1.db < output/load_current_det_changes.sql
#sqlite3 cch1.db < output/load_CCH_orig_det_log_archive.sql
#sqlite3 cch1.db < output/load_CCH_2018_det_log_archive.sql
#sqlite3 cch1.db < output/load_CCH_det_log_archive.sql


echo "insert determinations into synonymy table"
sqlite3 cch1.db < output/load_synonymy.sql


