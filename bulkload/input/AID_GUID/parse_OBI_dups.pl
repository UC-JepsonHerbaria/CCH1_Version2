
use strict;
#use warnings;
#use diagnostics;
use lib '/Users/Shared/Jepson-Master/Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev
my $today_JD = &get_today_julian_day;

open(DUPLOG, ">>/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/dup_log_".$today_JD.".txt") || die; 


$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.
my $herb="OBI";
my $dirdate = "2020_JAN29";
#$filedate="11072019";
#my$filedate="12052019";
my $filedate="01292020";

my %month_hash = &month_hash;


#declare variables
my %DUP_FOUND;
my %duplicate_OTH;
my %duplicate_CAT;
my %skipped;
my %duplicate_FOUND_CAT;
my %duplicate_FOUND_OTH;

my ($dups, $old_AID, $ALT_CCH_BARCODE, $CCH2id, $oldA, $dups_B) = "";

my ($BAD_REM, $CCH1_CAT, $excluded, $bad2, $bad1, $non, $skipped, $ocatb, $catb, $cchidb, $cch2idb, $occid, $count_record) = "";
my ($aidStatus, $altcchidb, $aidSpace, $aidName, $uniqueID, $aidCounty, $aidGUID, $included) = "";

my ($modified, $catalogNumber, $otherCatalogNumbers, $scientificName, $key, $value, $collID) = "";
my ($phylum, $kingdom, $occurrenceID, $basisOfRecord, $ownerInstitutionCode, $collectionCode) = "";
my ($infraspecificEpithet, $taxonRank, $specificEpithet, $genus, $scientificNameAuthorship, $class, $order, $family) = "";
my ($minimumDepthInMeters, $maximumDepthInMeters, $verbatimDepth, $verbatimElevation, $disposition, $language, $recordId, $sourcePrimaryKey, $institutionCode) = "";
my ($verbatimCoordinates, $georeferencedBy, $georeferenceProtocol, $georeferenceSource, $maximumElevationInMeters, $minimumElevationInMeters, $georeferenceRemarks, $georeferenceVerificationStatus) = "";
my ($localitySecurity, $localitySecurityReason, $verbatimLatitude, $verbatimLongitude, $geodeticDatum, $coordinateUncertaintyInMeters, $recordEnteredBy, $references) = "";
my ($individualCount, $preparations, $county, $country, $stateProvince, $municipality, $locality, $locationRemarks) = "";
my ($substrate, $habitat, $associatedTaxa, $reproductiveCondition, $establishmentMeans, $cultivationStatus, $lifeStage, $sex) = "";
my ($occurrenceRemarks, $endDayOfYear, $startDayOfYear, $dynamicProperties, $dataGeneralizations, $informationWithheld, $fieldNumber, $verbatimAttributes) = "";
my ($recordedBy, $associatedCollectors, $recordNumber, $eventDate, $year, $month, $day, $verbatimEventDate) = "";
my ($taxonID, $identifiedBy, $dateIdentified, $identificationReferences, $identificationRemarks, $taxonRemarks, $identificationQualifier, $typeStatus) = "";


open(OUT, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_".$herb.$today_JD.".txt") || die; #this only needs to be active once to generate a list of duplicated accessions

	print OUT "herb\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tscientificName\tcounty\n";

#id	type	modified	language	institutionCode	collectionCode	basisOfRecord	occurrenceID	catalogNumber	occurrenceRemarks	recordNumber	recordedBy	otherCatalogNumbers	eventDate	startDayOfYear	year	month	day	verbatimEventDate	habitat	higherGeography	continent	country	stateProvince	county	municipality	locality	verbatimElevation	minimumElevationInMeters	maximumElevationInMeters	verbatimLatitude	verbatimLongitude	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	georeferenceProtocol	georeferenceVerificationStatus	identifiedBy	dateIdentified	typeStatus	scientificName	higherClassification	kingdom	phylum	class	order	family	genus	specificEpithet	infraspecificEpithet	verbatimTaxonRank	scientificNameAuthorship	nomenclaturalCode


my $mainFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/CCH2-exports/'.$dirdate.'/CCH2_export_'.$filedate.'.txt';
open (IN, $mainFile) or die $!;
Record: while(<IN>){
	chomp;

#fix some data quality and formatting problems that make import of fields of certain records problematic
	
    if ($. == 1){#activate if need to skip header lines
			next Record;
	}

	my @fields=split(/\t/,$_,100);

    unless( $#fields == 84){ #if the number of values in the columns array is exactly 85

	&CCH::log_skip("$#fields bad field number $_\n");
	++$skipped;
	next Record;
	}

#id	institutionCode	collectionCode	ownerInstitutionCode	basisOfRecord	occurrenceID	catalogNumber	otherCatalogNumbers
($CCH2id,
$institutionCode,
$collectionCode,
$ownerInstitutionCode,	#added 2016
$basisOfRecord,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$kingdom,
$phylum,
#10
#kingdom	phylum	class	order	family	scientificName	taxonID	scientificNameAuthorship	genus	specificEpithet	
$class,
$order,
$family,
$scientificName,
$taxonID,
$scientificNameAuthorship,
$genus,
$specificEpithet,
$taxonRank,
$infraspecificEpithet,
$identifiedBy,
#20
#taxonRank	infraspecificEpithet	identifiedBy	dateIdentified	identificationReferences	identificationRemarks	
#taxonRemarks	identificationQualifier	typeStatus	recordedBy	associatedCollectors	recordNumber	eventDate	
$dateIdentified,
$identificationReferences,	#added 2015, not processed
$identificationRemarks,	#added 2015, not processed
$taxonRemarks,	#added 2015
$identificationQualifier,
$typeStatus,
$recordedBy,
##$recordedByID,			#added 2016, not in 2017 download
$associatedCollectors,	#added 2016, not in 2017 download, combined within recorded by with a ";"
$recordNumber,
$eventDate,
#30
#year	month	day	startDayOfYear	endDayOfYear	verbatimEventDate	occurrenceRemarks	habitat	substrate	
$year,
$month,
$day,
$startDayOfYear,
$endDayOfYear,
$verbatimEventDate,
$occurrenceRemarks,
$habitat,
$substrate,			#added 2016
$verbatimAttributes, #added 2016
#40
#verbatimAttributes	fieldNumber	informationWithheld	dataGeneralizations	dynamicProperties	associatedTaxa	
#reproductiveCondition	establishmentMeans	cultivationStatus	lifeStage	
$fieldNumber,
$informationWithheld,
$dataGeneralizations,	#added 2015, not processed, field empty as of 2016
$dynamicProperties,	#added 2015, not processed
$associatedTaxa,
$reproductiveCondition,
$establishmentMeans,	#added 2015, not processed
$cultivationStatus,	#added 2016
$lifeStage,
$sex,	#added 2015, not processed
#50
#sex	individualCount	preparations	country	stateProvince	county	municipality	locality	
#locationRemarks	localitySecurity
$individualCount,	#added 2015, not processed
$preparations,	#added 2015, not processed
$country,
$stateProvince,
$county,
$municipality,
$locality,
$locationRemarks, #newly added 2015-10, not processed
$localitySecurity,		#added 2016, not processed
$localitySecurityReason,	#added 2016, not processed
#60
#localitySecurityReason	decimalLatitude	decimalLongitude	geodeticDatum	
#coordinateUncertaintyInMeters	verbatimCoordinates	georeferencedBy	georeferenceProtocol	
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,	#added 2015, not processed
$georeferenceProtocol,	#added 2015, not processed
$georeferenceSource,
$georeferenceVerificationStatus,	#added 2015, not processed
$georeferenceRemarks,	#added 2015, not processed
#70
#georeferenceRemarks	minimumElevationInMeters	
#maximumElevationInMeters	minimumDepthInMeters	maximumDepthInMeters	verbatimDepth	verbatimElevation	disposition	
#language	recordEnteredBy
$minimumElevationInMeters,
$maximumElevationInMeters, #not processed for now
$minimumDepthInMeters, #newly added 2015-10, not processed
$maximumDepthInMeters, #newly added 2015-10, not processed
$verbatimDepth, #newly added 2015-10, not processed
$verbatimElevation,
$disposition,	#added 2015, not processed
$language,	#added 2015, not processed
$recordEnteredBy, #newly added 2015-10, not processed
$modified,	#added 2015, not processed
#80
#modified	sourcePrimaryKey-dbpk	collId	recordId	references
$sourcePrimaryKey,  #added 2016, not processed
$collID,	#added 2016, not processed
$recordId,	#added 2015, not processed
$references	#added 2016, not processed
)=@fields;	#The array @columns is made up on these 85 scalars, in this order


#filter by herbarium code
  if ($institutionCode =~ m/^OBI$/){


#warn "$count_record\n" unless $count_record % 1009;
  printf {*STDERR} "%d\r", ++$count_record;


########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped;
		next Record;
	}

	$catalogNumber =~ s/^OBF/OBI/;
	$catalogNumber =~ s/(`|-)//g;
	$otherCatalogNumbers =~ s/\\+//g;
	$otherCatalogNumbers =~ s/(`|-)//g;

#extract old herbarium and aid numbers
   if (length ($otherCatalogNumbers) >= 1){

#construct the 3rd variant for OBI, which is form without leading zeros
	if ($otherCatalogNumbers =~ m/^(OBI)0+(\d+)[A-Za-z]*$/){
		$old_AID=$otherCatalogNumbers;
		$oldA = $1.$2;
		$duplicate_OTH{$old_AID}++;
		#print "HERB(2a)\t$oldA\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n"";
		#print "HERB(2b)\t$old_AID\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n"";
	}
	elsif ($otherCatalogNumbers =~ m/^(OBI)([0-9]+)[A-Za-z]*$/){ 
		$old_AID=$1.$2;
		$duplicate_OTH{$old_AID}++;
		#print "HERB(2)\t$old_AID\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^([0-9]+)\]?[A-Za-z]*$/){ 
		$old_AID=$herb.$1;
		$duplicate_OTH{$old_AID}++;
		#print "HERB(2)\t$old_AID\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^\d\d\d\d+[;,] *\d\d\d+/){
		$otherCatalogNumbers = "";
		$old_AID="";
	}
	elsif ($otherCatalogNumbers =~ m/^(NULL| *)$/){
		$otherCatalogNumbers = "";
		$old_AID="";
	}
	else{
		&CCH::log_change("BAD Accession==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$otherCatalogNumbers = "";
		$old_AID="";
	}
   }
   else{
		$otherCatalogNumbers = "";
		$old_AID="";
   }


#construct catalog numbers
   if (length ($catalogNumber) >= 1){

	if ($catalogNumber =~ m/^(OBI)(\d+)$/){
		$ALT_CCH_BARCODE=$1.$2." BARCODE";
		$duplicate_CAT{$ALT_CCH_BARCODE}++;#count to find duplicates
		#print "HERB(3)\t$ALT_CCH_BARCODE\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/^(\d+)$/){#fix records without an herbarium code
		$ALT_CCH_BARCODE=$herb.$1." BARCODE";
		$duplicate_CAT{$ALT_CCH_BARCODE}++;#count to find duplicates
		print "HERB(3)\t$ALT_CCH_BARCODE\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
	}
	else{
		&CCH::log_change("BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
	}
   }
   else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
   }

   if (length ($catalogNumber) >= 1){
	if ($duplicate_CAT{$ALT_CCH_BARCODE} >= 2){
		$duplicate_FOUND_CAT{$ALT_CCH_BARCODE}++;
		++$dups;
	}
   }
  
   if (length ($otherCatalogNumbers) >= 1){
	if ($duplicate_OTH{$old_AID} >= 2){
		$duplicate_FOUND_OTH{$old_AID}++;
		++$dups;
	}
   }

  }
}
#for testing
	#foreach $ALT_CCH_BARCODE (sort keys %duplicate_CAT) {
    #printf "%-31s %s\n", $ALT_CCH_BARCODE, $duplicate_CAT{$ALT_CCH_BARCODE} if ($duplicate_CAT{$ALT_CCH_BARCODE} >= 2);
	#}

  #foreach $old_AID (sort keys %duplicate_OTH) {
    #printf "%-31s %s\n", $old_AID, $duplicate_OTH{$old_AID} if ($duplicate_OTH{$old_AID} >= 2);
  #}

print <<EOP;


$herb DUP COUNT
TOTAL: $count_record
UNIQUE DUPS FOUND: $dups

BEGIN DUPICATE UPLOAD
EOP

print DUPLOG <<EOP;


$herb DUP COUNT
TOTAL: $count_record
UNIQUE DUPS FOUND: $dups
EOP

close(IN);

#now reload and extract all of the duplicates based on the values found above
#declare variables
my ($dups, $old_AID, $ALT_CCH_BARCODE, $CCH2id, $oldA, $dups_B) = "";

my ($BAD_REM, $CCH1_CAT, $excluded, $bad2, $bad1, $non, $skipped, $ocatb, $catb, $cchidb, $cch2idb, $occid, $count_record) = "";
my ($aidStatus, $altcchidb, $aidSpace, $aidName, $uniqueID, $aidCounty, $aidGUID, $included) = "";

my ($modified, $catalogNumber, $otherCatalogNumbers, $scientificName, $key, $value, $collID) = "";
my ($phylum, $kingdom, $occurrenceID, $basisOfRecord, $ownerInstitutionCode, $collectionCode) = "";
my ($infraspecificEpithet, $taxonRank, $specificEpithet, $genus, $scientificNameAuthorship, $class, $order, $family) = "";
my ($minimumDepthInMeters, $maximumDepthInMeters, $verbatimDepth, $verbatimElevation, $disposition, $language, $recordId, $sourcePrimaryKey, $institutionCode) = "";
my ($verbatimCoordinates, $georeferencedBy, $georeferenceProtocol, $georeferenceSource, $maximumElevationInMeters, $minimumElevationInMeters, $georeferenceRemarks, $georeferenceVerificationStatus) = "";
my ($localitySecurity, $localitySecurityReason, $verbatimLatitude, $verbatimLongitude, $geodeticDatum, $coordinateUncertaintyInMeters, $recordEnteredBy, $references) = "";
my ($individualCount, $preparations, $county, $country, $stateProvince, $municipality, $locality, $locationRemarks) = "";
my ($substrate, $habitat, $associatedTaxa, $reproductiveCondition, $establishmentMeans, $cultivationStatus, $lifeStage, $sex) = "";
my ($occurrenceRemarks, $endDayOfYear, $startDayOfYear, $dynamicProperties, $dataGeneralizations, $informationWithheld, $fieldNumber, $verbatimAttributes) = "";
my ($recordedBy, $associatedCollectors, $recordNumber, $eventDate, $year, $month, $day, $verbatimEventDate) = "";
my ($taxonID, $identifiedBy, $dateIdentified, $identificationReferences, $identificationRemarks, $taxonRemarks, $identificationQualifier, $typeStatus) = "";

my $mainFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/CCH2-exports/2020_JAN29/CCH2_export_'.$filedate.'.txt';
open (IN, $mainFile) or die $!;
Record: while(<IN>){
	chomp;

#fix some data quality and formatting problems that make import of fields of certain records problematic
	
    if ($. == 1){#activate if need to skip header lines
			next Record;
	}

	my @fields=split(/\t/,$_,100);

    unless( $#fields == 84){ #if the number of values in the columns array is exactly 85

	&CCH::log_skip("$#fields bad field number $_\n");
	++$skipped;
	next Record;
	}

#id	institutionCode	collectionCode	ownerInstitutionCode	basisOfRecord	occurrenceID	catalogNumber	otherCatalogNumbers
($CCH2id,
$institutionCode,
$collectionCode,
$ownerInstitutionCode,	#added 2016
$basisOfRecord,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$kingdom,
$phylum,
#10
#kingdom	phylum	class	order	family	scientificName	taxonID	scientificNameAuthorship	genus	specificEpithet	
$class,
$order,
$family,
$scientificName,
$taxonID,
$scientificNameAuthorship,
$genus,
$specificEpithet,
$taxonRank,
$infraspecificEpithet,
$identifiedBy,
#20
#taxonRank	infraspecificEpithet	identifiedBy	dateIdentified	identificationReferences	identificationRemarks	
#taxonRemarks	identificationQualifier	typeStatus	recordedBy	associatedCollectors	recordNumber	eventDate	
$dateIdentified,
$identificationReferences,	#added 2015, not processed
$identificationRemarks,	#added 2015, not processed
$taxonRemarks,	#added 2015
$identificationQualifier,
$typeStatus,
$recordedBy,
##$recordedByID,			#added 2016, not in 2017 download
$associatedCollectors,	#added 2016, not in 2017 download, combined within recorded by with a ";"
$recordNumber,
$eventDate,
#30
#year	month	day	startDayOfYear	endDayOfYear	verbatimEventDate	occurrenceRemarks	habitat	substrate	
$year,
$month,
$day,
$startDayOfYear,
$endDayOfYear,
$verbatimEventDate,
$occurrenceRemarks,
$habitat,
$substrate,			#added 2016
$verbatimAttributes, #added 2016
#40
#verbatimAttributes	fieldNumber	informationWithheld	dataGeneralizations	dynamicProperties	associatedTaxa	
#reproductiveCondition	establishmentMeans	cultivationStatus	lifeStage	
$fieldNumber,
$informationWithheld,
$dataGeneralizations,	#added 2015, not processed, field empty as of 2016
$dynamicProperties,	#added 2015, not processed
$associatedTaxa,
$reproductiveCondition,
$establishmentMeans,	#added 2015, not processed
$cultivationStatus,	#added 2016
$lifeStage,
$sex,	#added 2015, not processed
#50
#sex	individualCount	preparations	country	stateProvince	county	municipality	locality	
#locationRemarks	localitySecurity
$individualCount,	#added 2015, not processed
$preparations,	#added 2015, not processed
$country,
$stateProvince,
$county,
$municipality,
$locality,
$locationRemarks, #newly added 2015-10, not processed
$localitySecurity,		#added 2016, not processed
$localitySecurityReason,	#added 2016, not processed
#60
#localitySecurityReason	decimalLatitude	decimalLongitude	geodeticDatum	
#coordinateUncertaintyInMeters	verbatimCoordinates	georeferencedBy	georeferenceProtocol	
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,	#added 2015, not processed
$georeferenceProtocol,	#added 2015, not processed
$georeferenceSource,
$georeferenceVerificationStatus,	#added 2015, not processed
$georeferenceRemarks,	#added 2015, not processed
#70
#georeferenceRemarks	minimumElevationInMeters	
#maximumElevationInMeters	minimumDepthInMeters	maximumDepthInMeters	verbatimDepth	verbatimElevation	disposition	
#language	recordEnteredBy
$minimumElevationInMeters,
$maximumElevationInMeters, #not processed for now
$minimumDepthInMeters, #newly added 2015-10, not processed
$maximumDepthInMeters, #newly added 2015-10, not processed
$verbatimDepth, #newly added 2015-10, not processed
$verbatimElevation,
$disposition,	#added 2015, not processed
$language,	#added 2015, not processed
$recordEnteredBy, #newly added 2015-10, not processed
$modified,	#added 2015, not processed
#80
#modified	sourcePrimaryKey-dbpk	collId	recordId	references
$sourcePrimaryKey,  #added 2016, not processed
$collID,	#added 2016, not processed
$recordId,	#added 2015, not processed
$references	#added 2016, not processed
)=@fields;	#The array @fields is made up on these 85 scalars, in this order


#filter by herbarium code
  if ($institutionCode =~ m/^OBI$/){

#warn "$count_record\n" unless $count_record % 1009;
  printf {*STDERR} "%d\r", ++$count_record;


	$catalogNumber =~ s/^OBF/OBI/;
	$catalogNumber =~ s/(`|-)//g;
	$otherCatalogNumbers =~ s/\\+//g;
	$otherCatalogNumbers =~ s/(`|-)//g;

   if (length ($otherCatalogNumbers) >= 1){
#construct the 3rd variant for OBI, which is form without leading zeros
	if ($otherCatalogNumbers =~ m/^(OBI)0+([^0]\d+)[A-Za-z]*$/){
		$old_AID = $1.$2;;
		$oldA = $otherCatalogNumbers;
	}
#construct the 1st variant for OBI
	elsif ($otherCatalogNumbers =~ m/^(OBI)([1-9][0-9]*)[A-Za-z]*$/){ 
		$old_AID = $1.$2;
	}
	elsif ($otherCatalogNumbers =~ m/^([1-9][0-9]*)\]?[A-Za-z]*$/){ 
		$old_AID=$herb.$1;
	}
	elsif ($otherCatalogNumbers =~ m/^\d\d\d\d+[;,] *\d\d\d+/){
		$otherCatalogNumbers = "";
		$old_AID="";
	}
	elsif ($otherCatalogNumbers =~ m/^(NULL| *)$/){
		$otherCatalogNumbers = "";
		$old_AID="";
	}
	else{
		$otherCatalogNumbers = "";
		$old_AID="";
	}
   }
   else{
		$otherCatalogNumbers = "";
		$old_AID="";
   }


#construct catalog numbers
   if (length ($catalogNumber) >= 1){

	if ($catalogNumber =~ m/^(OBI)(\d+)$/){
		$ALT_CCH_BARCODE=$1.$2." BARCODE";
	}
	elsif ($catalogNumber =~ m/^(\d+)$/){#fix records without an herbarium code
		$ALT_CCH_BARCODE=$herb.$1." BARCODE";
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
	}
	else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
	}
   }
   else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
   }


#exclude ALL duplicates 
	if ($duplicate_FOUND_OTH{$old_AID}) {
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	#for example, the worst case is CAS520791, which has 17 specimens that were labeled with this number over the years.
		print OUT "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\t$scientificName\t$county\n";
		++$dups_B;
	}
	
	if ($duplicate_FOUND_CAT{$ALT_CCH_BARCODE}) {
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	#for example, the worst case is CAS520791, which has 17 specimens that were labeled with this number over the years.
		print OUT "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\t$scientificName\t$county\n";
		++$dups_B;
	}

  }
}

print <<EOP;
TOTAL DUPS ADDED TO FILE: $dups_B


EOP

print DUPLOG <<EOP;
TOTAL DUPS ADDED TO FILE: $dups_B


EOP

close(IN);
close(OUT);
close(DUPLOG);