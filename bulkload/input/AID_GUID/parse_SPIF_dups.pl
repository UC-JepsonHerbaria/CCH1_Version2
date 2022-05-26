
use strict;
#use warnings;
#use diagnostics;
use lib '../../../Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev
my $today_JD = &get_today_julian_day;

open(DUPLOG, ">>DUPS/dup_log_".$today_JD.".txt") || die; 


$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.
my $herb = "SPIF";
#my $dirdate = "2020_JAN29";
my $dirdate = "2021_APR16";
#$filedate = "11072019";
#my$filedate = "12052019";
#my $filedate = "01292020";
my $filedate = "04162021";

my %month_hash = &month_hash;


#declare variables
my (%DUP_FOUND,%duplicate_OTH,%duplicate_CAT,%skipped,%duplicate_FOUND_CAT,%duplicate_FOUND_OTH,%code_found) = "";
my ($IC,$OC,$CN,$CC,$OCN,$G,$ITS,$DE,$DM,$UUID,$cchUUID,$CCH2ID, $BAD) = "";

my ($dups, $old_AID, $ALT_CCH_BARCODE, $CCH2id, $oldA, $dups_B, $newherbCode) = "";

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
my ($accessRights,$subgenus,$higherClassification,$collectionID,$verbatimTaxonRank) = "";
my ($rightsHolder,$rights,$associatedOccurrences) = "";

open(OUT, ">DUPS/DUPS_".$herb.$today_JD.".txt") || die; #this only needs to be active once to generate a list of duplicated accessions

	print OUT "herb\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tCCH_BARCODE_ID\tALT_CCH_AID\tStatus\tGUID-occurrenceID\tscientificName\tcounty\n";

#id	type	modified	language	institutionCode	collectionCode	basisOfRecord	occurrenceID	catalogNumber	occurrenceRemarks	recordNumber	recordedBy	otherCatalogNumbers	eventDate	startDayOfYear	year	month	day	verbatimEventDate	habitat	higherGeography	continent	country	stateProvince	county	municipality	locality	verbatimElevation	minimumElevationInMeters	maximumElevationInMeters	verbatimLatitude	verbatimLongitude	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	georeferenceProtocol	georeferenceVerificationStatus	identifiedBy	dateIdentified	typeStatus	scientificName	higherClassification	kingdom	phylum	class	order	family	genus	specificEpithet	infraspecificEpithet	verbatimTaxonRank	scientificNameAuthorship	nomenclaturalCode


my $mainFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/CCH2-exports/'.$dirdate.'/CCH2_export_'.$filedate.'.txt';
open (IN, $mainFile) or die $!;
Record: while(<IN>){
	chomp;

#fix some data quality and formatting problems that make import of fields of certain records problematic
	
    if ($. == 1){#activate if need to skip header lines
			next Record;
	}

	my @fields = split(/\t/,$_,100);

    unless( $#fields == 84){ #if the number of values in the columns array is exactly 85

	&CCH::log_skip("$#fields bad field number $_\n");
	++$skipped;
	next Record;
	}
#id	institutionCode	collectionCode	ownerInstitutionCode	collectionID	basisOfRecord	occurrenceID	
#catalogNumber	otherCatalogNumbers	higherClassification	
($CCH2id,
$institutionCode,
$collectionCode,
$ownerInstitutionCode,
$collectionID,
$basisOfRecord,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$higherClassification,
#10
#kingdom	phylum	class	order	family	scientificName	taxonID	scientificNameAuthorship	genus	subgenus	
$kingdom,
$phylum,
$class,
$order,
$family,
$scientificName,
$taxonID,
$scientificNameAuthorship,
$genus,
$subgenus,
#20
#specificEpithet	verbatimTaxonRank	infraspecificEpithet	taxonRank	identifiedBy	dateIdentified	
#identificationReferences	identificationRemarks	taxonRemarks	identificationQualifier	
$specificEpithet,
$verbatimTaxonRank,
$infraspecificEpithet,
$taxonRank,
$identifiedBy,
$dateIdentified,
$identificationReferences,
$identificationRemarks,
$taxonRemarks,
$identificationQualifier,
#30
#typeStatus	recordedBy	recordNumber	eventDate	year	month	day	startDayOfYear	endDayOfYear	
#verbatimEventDate	
$typeStatus,
$recordedBy,
$recordNumber,
$eventDate,
$year,
$month,
$day,
$startDayOfYear,
$endDayOfYear,
$verbatimEventDate,
#40
#occurrenceRemarks	habitat	fieldNumber	informationWithheld	dataGeneralizations	dynamicProperties	
#associatedOccurrences	associatedTaxa	reproductiveCondition	establishmentMeans	
$occurrenceRemarks,
$habitat,
$fieldNumber,
$informationWithheld,
$dataGeneralizations,
$dynamicProperties,
$associatedOccurrences,
$associatedTaxa,
$reproductiveCondition,
$establishmentMeans,
#50
#lifeStage	sex	individualCount	preparations	country	stateProvince	county	municipality	
#locality	locationRemarks	
$lifeStage,
$sex,
$individualCount,
$preparations,
$country,
$stateProvince,
$county,
$municipality,
$locality,
$locationRemarks,
#60
#decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	verbatimCoordinates	
#georeferencedBy	georeferenceProtocol	georeferenceSources	georeferenceVerificationStatus	georeferenceRemarks	
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,
$georeferenceProtocol,
$georeferenceSource,
$georeferenceVerificationStatus,
$georeferenceRemarks,
#70
#minimumElevationInMeters	maximumElevationInMeters	minimumDepthInMeters	maximumDepthInMeters	
#verbatimDepth	verbatimElevation	disposition	language	recordEnteredBy	modified	
$minimumElevationInMeters,
$maximumElevationInMeters,
$minimumDepthInMeters,
$maximumDepthInMeters,
$verbatimDepth,
$verbatimElevation,
$disposition,
$language,
$recordEnteredBy,
$modified,
#80
#rights	rightsHolder	accessRights	recordId	references
$rights,
$rightsHolder,
$accessRights,
$recordId,
$references	
) = @fields;	#The array @columns is made up on these 85 scalars, in this order


#filter by herbarium code
if ($institutionCode =~ m/^SPIF$/){


#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;



########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped{one};
		next Record;
	}

my $oldA="";

#extract old herbarium and aid numbers
if (length ($otherCatalogNumbers) >= 1){

	if ($otherCatalogNumbers =~ m/NULL/){
		$otherCatalogNumbers = "";
		$old_AID="";
	}
	elsif ($otherCatalogNumbers =~ m/^(\d+)[ABCDEFGHIJK]?$/){
		$old_AID=$herb.$1;
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

	if ($catalogNumber =~ m/^(SPIF)(\d+)$/){
		$ALT_CCH_BARCODE = $1.$2."-BARCODE";
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/NULL/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";	
	}
	else{
		&CCH::log_change("BAD catalogNumber(2)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD catalogNumber(2)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
	}
}
else{
	$catalogNumber = "";
	$ALT_CCH_BARCODE = "";	
}


   if (length ($catalogNumber) >= 1){
	if ($duplicate_CAT{$ALT_CCH_BARCODE} >= 2){
		$duplicate_FOUND_CAT{$ALT_CCH_BARCODE}++;
		++$dups;
	}
   }
  
   #if (length ($otherCatalogNumbers) >= 1){
	#if ($duplicate_OTH{$old_AID} >= 2){
	#	$duplicate_FOUND_OTH{$old_AID}++;
	#	++$dups;
	#}
   #}

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
my ($dups, $old_AID, $ALT_CCH_BARCODE, $CCH2id, $oldA, $dups_B, $newherbCode) = "";

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
my ($accessRights,$subgenus,$higherClassification,$collectionID,$verbatimTaxonRank) = "";
my ($rightsHolder,$rights,$associatedOccurrences) = "";

my $mainFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/CCH2-exports/'.$dirdate.'/CCH2_export_'.$filedate.'.txt';
open (IN, $mainFile) or die $!;
Record: while(<IN>){
	chomp;

#fix some data quality and formatting problems that make import of fields of certain records problematic
	
    if ($. == 1){#activate if need to skip header lines
			next Record;
	}

	my @fields = split(/\t/,$_,100);

    unless( $#fields == 84){ #if the number of values in the columns array is exactly 85

	&CCH::log_skip("$#fields bad field number $_\n");
	++$skipped;
	next Record;
	}
#id	institutionCode	collectionCode	ownerInstitutionCode	collectionID	basisOfRecord	occurrenceID	
#catalogNumber	otherCatalogNumbers	higherClassification	
($CCH2id,
$institutionCode,
$collectionCode,
$ownerInstitutionCode,
$collectionID,
$basisOfRecord,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$higherClassification,
#10
#kingdom	phylum	class	order	family	scientificName	taxonID	scientificNameAuthorship	genus	subgenus	
$kingdom,
$phylum,
$class,
$order,
$family,
$scientificName,
$taxonID,
$scientificNameAuthorship,
$genus,
$subgenus,
#20
#specificEpithet	verbatimTaxonRank	infraspecificEpithet	taxonRank	identifiedBy	dateIdentified	
#identificationReferences	identificationRemarks	taxonRemarks	identificationQualifier	
$specificEpithet,
$verbatimTaxonRank,
$infraspecificEpithet,
$taxonRank,
$identifiedBy,
$dateIdentified,
$identificationReferences,
$identificationRemarks,
$taxonRemarks,
$identificationQualifier,
#30
#typeStatus	recordedBy	recordNumber	eventDate	year	month	day	startDayOfYear	endDayOfYear	
#verbatimEventDate	
$typeStatus,
$recordedBy,
$recordNumber,
$eventDate,
$year,
$month,
$day,
$startDayOfYear,
$endDayOfYear,
$verbatimEventDate,
#40
#occurrenceRemarks	habitat	fieldNumber	informationWithheld	dataGeneralizations	dynamicProperties	
#associatedOccurrences	associatedTaxa	reproductiveCondition	establishmentMeans	
$occurrenceRemarks,
$habitat,
$fieldNumber,
$informationWithheld,
$dataGeneralizations,
$dynamicProperties,
$associatedOccurrences,
$associatedTaxa,
$reproductiveCondition,
$establishmentMeans,
#50
#lifeStage	sex	individualCount	preparations	country	stateProvince	county	municipality	
#locality	locationRemarks	
$lifeStage,
$sex,
$individualCount,
$preparations,
$country,
$stateProvince,
$county,
$municipality,
$locality,
$locationRemarks,
#60
#decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	verbatimCoordinates	
#georeferencedBy	georeferenceProtocol	georeferenceSources	georeferenceVerificationStatus	georeferenceRemarks	
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,
$georeferenceProtocol,
$georeferenceSource,
$georeferenceVerificationStatus,
$georeferenceRemarks,
#70
#minimumElevationInMeters	maximumElevationInMeters	minimumDepthInMeters	maximumDepthInMeters	
#verbatimDepth	verbatimElevation	disposition	language	recordEnteredBy	modified	
$minimumElevationInMeters,
$maximumElevationInMeters,
$minimumDepthInMeters,
$maximumDepthInMeters,
$verbatimDepth,
$verbatimElevation,
$disposition,
$language,
$recordEnteredBy,
$modified,
#80
#rights	rightsHolder	accessRights	recordId	references
$rights,
$rightsHolder,
$accessRights,
$recordId,
$references	
) = @fields;	#The array @columns is made up on these 85 scalars, in this order


#filter by herbarium code
if ($institutionCode =~ m/^SPIF$/){


#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;



########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped{one};
		next Record;
	}

#extract old herbarium and aid numbers
if (length ($otherCatalogNumbers) >= 1){

	if ($otherCatalogNumbers =~ m/NULL/){
		$otherCatalogNumbers = "";
		$old_AID="";
	}
	elsif ($otherCatalogNumbers =~ m/^(\d+)[ABCDEFGHIJK]?$/){
		$old_AID=$herb.$1;
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

	if ($catalogNumber =~ m/^(SPIF)(\d+)$/){
		$ALT_CCH_BARCODE = $1.$2."-BARCODE";
	}
	elsif ($catalogNumber =~ m/NULL/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";	
	}
	else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
	}
}
else{
	$catalogNumber = "";
	$ALT_CCH_BARCODE = "";	
}

#exclude ALL duplicates 
	#if ($duplicate_FOUND_OTH{$old_AID}) {
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	#for example, the worst case is CAS520791, which has 17 specimens that were labeled with this number over the years.
	#	print OUT "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\t$scientificName\t$county\n";
	#	++$dups_B;
	#}
	
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
