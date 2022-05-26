use strict;
#use warnings;
#use diagnostics;
use lib '../../Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

my $today_JD = &CCH::get_today;
#my $today_JD = &get_today_julian_day;

open(DUPLOG, ">>input/AID_GUID/DUPS/dup_log_".$today_JD.".txt") || die; 


$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.
my $herb = "PPWD";


#my $dirdate = "2021_APR16";
#my $dirdate="2021_AUG28";
#my $dirdate="2022_JAN26";
my $dirdate="2022_MAR02";
#$filedate="11072019";
#my $filedate="12052019";
#my $filedate = "01292020";
#my $filedate = "04162021";
#my $filedate="08282021";
#my $filedate="01262022";
my $filedate="03022022";


my %month_hash = &CCH::month_hash;

#counts
my ($skipped, $included, %seen, %duplicate_FOUND_CAT, %duplicate_FOUND_OTH) = "";
my ($dups,$dups_B,$ALTER, $ORTH, %DUP_FOUND,%duplicate_OTH,%duplicate_CAT,$count_record) = "";


#out file variables for CCH2 compatibility
my ($ALT_CCH_BARCODE,$oldA,$old_AID,$CCH2id) = "";


#IN TABLE
#CCH2 symbiota table
my ($institutionCode, $id, $collectionCode, $ownerInstitutionCode, $basisOfRecord) = ""; #5
my ($occurrenceID, $catalogNumber, $otherCatalogNumbers, $kingdom, $phylum) = "";#10
my ($class, $order, $family, $scientificName, $taxonID) = "";#15
my ($scientificNameAuthorship, $genus, $specificEpithet, $taxonRank, $infraspecificEpithet) = "";#20
my ($identifiedBy, $dateIdentified, $identificationReferences, $identificationRemarks, $taxonRemarks) = "";#25
my ($identificationQualifier, $typeStatus, $recordedBy, $associatedCollectors, $recordNumber) = "";#30
my ($eventDate, $year, $month, $day, $startDayOfYear) = "";#35
my ($endDayOfYear, $verbatimEventDate, $occurrenceRemarks, $habitat, $substrate, $verbatimAttributes, $fieldNumber) = "";#40
my ($informationWithheld, $dataGeneralizations, $dynamicProperties, $associatedTaxa, $reproductiveCondition) = "";#45
my ($establishmentMeans, $cultivationStatus, $lifeStage, $sex, $individualCount) = "";#50
my ($preparations, $country, $stateProvince, $verbatimCounty, $municipality) = "";#55
my ($locality, $locationRemarks, $localitySecurity, $localitySecurityReason, $latitude) = "";#60
my ($longitude, $geodeticDatum, $coordinateUncertaintyInMeters, $verbatimCoordinates, $georeferencedBy) = "";#65
my ($georeferenceProtocol, $georeferenceSources, $georeferenceVerificationStatus, $georeferenceRemarks, $minimumElevationInMeters) = "";#70
my ($maximumElevationInMeters, $minimumDepthInMeters, $maximumDepthInMeters, $verbatimDepth, $verbatimElevation) = "";#75
my ($disposition, $language, $recordEnteredBy, $modified, $sourcePrimaryKey) = "";#80
my ($collId, $recordId, $references) = "";#83
my ($accessRights,$subgenus,$higherClassification,$collectionID,$verbatimTaxonRank) = "";
my ($rightsHolder,$rights,$associatedOccurrences,$eventID,$associatedSequences) = "";


open(OUT, ">input/AID_GUID/DUPS/DUPS_".$herb.$today_JD.".txt") || die; #this only needs to be active once to generate a list of duplicated accessions

	print OUT "herb\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tCCH_BARCODE_ID\tALT_CCH_AID\tStatus\tGUID-occurrenceID\tscientificName\tcounty\n";

#my $mainFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/CCH2-exports/'.$dirdate.'/CCH2_export_'.$filedate.'-utf8.txt';
my $mainFile='output/CCH2_CONVERTED_'.$filedate.'-utf8.txt';

open (IN, $mainFile) or die $!;
Record: while(<IN>){
	chomp;

        if ($. == 1){#activate if need to skip header lines
			next Record;
		}
		

		my @fields=split(/\t/,$_,100);

		#unless( $#fields == 84){  #if the number of values in the columns array is exactly 85, this is for Darwin Core
		unless( $#fields == 90){  #if the number of values in the columns array is exactly 91, this is for Darwin Core

			warn "$#fields bad field number $_\n";

			next Record;
		}

#id	institutionCode	collectionCode	ownerInstitutionCode	basisOfRecord	
#occurrenceID	catalogNumber	otherCatalogNumbers	higherClassification	kingdom	
($CCH2id,
$institutionCode,
$collectionCode,
$ownerInstitutionCode,
#$collectionID,  #this keeps appearing and disappearing, I think it is in the Darwin Core export and not Symbiota Native
$basisOfRecord,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$higherClassification,
$kingdom,
#10
#$kingdom,
#phylum	class	order	family	scientificName	taxonID	scientificNameAuthorship	
#genus	subgenus	specificEpithet	
$phylum,
$class,
$order,
$family,
$scientificName,
$taxonID,
$scientificNameAuthorship,
$genus,
$subgenus,
$specificEpithet,
#20
#verbatimTaxonRank	infraspecificEpithet	taxonRank	identifiedBy	dateIdentified	
#identificationReferences	identificationRemarks	taxonRemarks	
#identificationQualifier	typeStatus	
$verbatimTaxonRank,
$infraspecificEpithet,
$taxonRank,
$identifiedBy,
$dateIdentified,
$identificationReferences,
$identificationRemarks,
$taxonRemarks,
$identificationQualifier,
$typeStatus,
#30
#recordedBy	associatedCollectors	recordNumber	eventDate	year	month	day	
#startDayOfYear	endDayOfYear	verbatimEventDate	
$recordedBy,
$associatedCollectors, #This is in Symbiota Native and not Darwin Core
$recordNumber,
$eventDate,
$year,
$month,
$day,
$startDayOfYear,
$endDayOfYear,
$verbatimEventDate,
#40
#occurrenceRemarks	habitat	substrate	verbatimAttributes	fieldNumber	eventID	
#informationWithheld	dataGeneralizations	dynamicProperties	associatedOccurrences	
$occurrenceRemarks,
$habitat,
$substrate, #This is in Symbiota Native and not Darwin Core
$verbatimAttributes, #This is in Symbiota Native and not Darwin Core
$fieldNumber,
$eventID, #This is in Symbiota Native and not Darwin Core
$informationWithheld,
$dataGeneralizations,
$dynamicProperties,
$associatedOccurrences,
#$associatedTaxa,
#$reproductiveCondition,
#$establishmentMeans,
#50
#associatedSequences	associatedTaxa	reproductiveCondition	establishmentMeans	
#cultivationStatus	lifeStage	sex	individualCount	preparations	country	
$associatedSequences, #This is in Symbiota Native and not Darwin Core
$associatedTaxa,
$reproductiveCondition,
$establishmentMeans,
$cultivationStatus, #This is in Symbiota Native and not Darwin Core
$lifeStage,
$sex,
$individualCount,
$preparations,
$country,
#$stateProvince,
#$verbatimCounty,
#$municipality,
#$locality,
#$locationRemarks,
#60
#stateProvince	county	municipality	locality	locationRemarks	localitySecurity	
#localitySecurityReason	decimalLatitude	decimalLongitude	geodeticDatum	
$stateProvince,
$verbatimCounty,
$municipality,
$locality,
$locationRemarks,
$localitySecurity, #This is in Symbiota Native and not Darwin Core
$localitySecurityReason, #This is in Symbiota Native and not Darwin Core
$latitude,
$longitude,
$geodeticDatum,
#$coordinateUncertaintyInMeters,
#$verbatimCoordinates,
#$georeferencedBy,
#$georeferenceProtocol,
#$georeferenceSources,
#$georeferenceVerificationStatus,
#$georeferenceRemarks,
#70
#coordinateUncertaintyInMeters	verbatimCoordinates	georeferencedBy	georeferenceProtocol
#georeferenceSources	georeferenceVerificationStatus	georeferenceRemarks	
#minimumElevationInMeters	maximumElevationInMeters	minimumDepthInMeters	
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,
$georeferenceProtocol,
$georeferenceSources,
$georeferenceVerificationStatus,
$georeferenceRemarks,
$minimumElevationInMeters,
$maximumElevationInMeters,
$minimumDepthInMeters,
#$verbatimDepth,
#$verbatimElevation,
#$disposition,
#$language,
#$recordEnteredBy,
#$modified,
#80
#maximumDepthInMeters	verbatimDepth	verbatimElevation	disposition	language	
#recordEnteredBy	modified	sourcePrimaryKey-dbpk	collID	recordID	
#references
$maximumDepthInMeters,
$verbatimDepth,
$verbatimElevation,
$disposition,
$language,
$recordEnteredBy,
$modified,
$sourcePrimaryKey, #This is in Symbiota Native and not Darwin Core
#$rights,  #This is in Darwin Core and not Symbiota Native
#$rightsHolder, #This is in Darwin Core and not Symbiota Native
#$accessRights, #This is in Darwin Core and not Symbiota Native
$collId, #This is in Symbiota Native and not Darwin Core
$recordId,
#90
$references	
) = @fields;	
#The array @fields is made up on these 85 scalars, in this order, for Darwin Core
#The array @fields is made up on these 91 scalars, in this order, for Symbiota Native


#filter by herbarium code
  if ($institutionCode =~ m/^PPWD$/){


#warn "$count_record\n" unless $count_record % 1009;
  printf {*STDERR} "%d\r", ++$count_record;


########ACCESSION NUMBER
#check for nulls
	if ($CCH2id =~ m/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped;
		next Record;
	}

#extract old herbarium and aid numbers
   if (length ($otherCatalogNumbers) >= 1){
#GDRC appears not to have anything in othercatalogNumbers
	if ($otherCatalogNumbers =~ m/^[A-Za-z-]+/){
		#$oldA="";
		&CCH::log_change("Problem otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "PROBLEM otherCatalogNumbers(1)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($otherCatalogNumbers =~ m/^[0-9]+/){
		#$oldA = $herb.$otherCatalogNumbers;
		&CCH::log_change("Problem otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		#print "PROBLEM otherCatalogNumbers(2)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($otherCatalogNumbers =~ m/^(NULL| *)$/){
		$otherCatalogNumbers = "";
		#$oldA="";
	}
	else{
		&CCH::log_change("BAD Accession==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$otherCatalogNumbers = "";
		#$oldA = "";
	}
   }
   else{
		$otherCatalogNumbers = "";
		#$oldA = "";
   }


#construct catalog numbers
   if (length ($catalogNumber) >= 1){

	if ($catalogNumber =~ m/^(0*[1-9][0-9]*)[A-Za-z-]+$/){#fix records without an herbarium code
		$ALT_CCH_BARCODE = $herb.$1."-BARCODE";
		$oldA = $old_AID = "";
		$duplicate_CAT{$ALT_CCH_BARCODE}++;#count to find duplicates
		#print "HERB(3)\t$ALT_CCH_BARCODE\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($catalogNumber =~ m/^(0*[1-9][0-9]*)$/){#fix records without an herbarium code
		$ALT_CCH_BARCODE = $herb.$1."-BARCODE";
		$oldA = $old_AID = "";
		$duplicate_CAT{$ALT_CCH_BARCODE}++;#count to find duplicates
		#print "HERB(4)\t$ALT_CCH_BARCODE\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
		$oldA = $old_AID = "";
	}
	else{
		&CCH::log_change("BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
		$oldA = $old_AID = "";
	}
   }
   else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
		$oldA = $old_AID = "";
   }

   if (length ($catalogNumber) >= 1){
	if ($duplicate_CAT{$old_AID} >= 2){
		$duplicate_FOUND_CAT{$old_AID}++;
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
#counts
my ($skipped, $included, %seen) = "";
my ($dups,$dups_B,$ALTER, $ORTH, $count_record) = "";

#out file variables for CCH2 compatibility
my ($ALT_CCH_BARCODE,$oldA,$old_AID) = "";

#IN TABLE
#CCH2 symbiota table
my ($institutionCode, $id, $collectionCode, $ownerInstitutionCode, $basisOfRecord) = ""; #5
my ($occurrenceID, $catalogNumber, $otherCatalogNumbers, $kingdom, $phylum) = "";#10
my ($class, $order, $family, $scientificName, $taxonID) = "";#15
my ($scientificNameAuthorship, $genus, $specificEpithet, $taxonRank, $infraspecificEpithet) = "";#20
my ($identifiedBy, $dateIdentified, $identificationReferences, $identificationRemarks, $taxonRemarks) = "";#25
my ($identificationQualifier, $typeStatus, $recordedBy, $associatedCollectors, $recordNumber) = "";#30
my ($eventDate, $year, $month, $day, $startDayOfYear) = "";#35
my ($endDayOfYear, $verbatimEventDate, $occurrenceRemarks, $habitat, $substrate, $verbatimAttributes, $fieldNumber) = "";#40
my ($informationWithheld, $dataGeneralizations, $dynamicProperties, $associatedTaxa, $reproductiveCondition) = "";#45
my ($establishmentMeans, $cultivationStatus, $lifeStage, $sex, $individualCount) = "";#50
my ($preparations, $country, $stateProvince, $verbatimCounty, $municipality) = "";#55
my ($locality, $locationRemarks, $localitySecurity, $localitySecurityReason, $latitude) = "";#60
my ($longitude, $geodeticDatum, $coordinateUncertaintyInMeters, $verbatimCoordinates, $georeferencedBy) = "";#65
my ($georeferenceProtocol, $georeferenceSources, $georeferenceVerificationStatus, $georeferenceRemarks, $minimumElevationInMeters) = "";#70
my ($maximumElevationInMeters, $minimumDepthInMeters, $maximumDepthInMeters, $verbatimDepth, $verbatimElevation) = "";#75
my ($disposition, $language, $recordEnteredBy, $modified, $sourcePrimaryKey) = "";#80
my ($collId, $recordId, $references) = "";#83
my ($accessRights,$subgenus,$higherClassification,$collectionID,$verbatimTaxonRank) = "";
my ($rightsHolder,$rights,$associatedOccurrences,$eventID,$associatedSequences) = "";


#my $mainFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/CCH2-exports/'.$dirdate.'/CCH2_export_'.$filedate.'-utf8.txt';
my $mainFile='output/CCH2_CONVERTED_'.$filedate.'-utf8.txt';

open (IN, $mainFile) or die $!;
Record: while(<IN>){
	chomp;

        if ($. == 1){#activate if need to skip header lines
			next Record;
		}
		

		my @fields=split(/\t/,$_,100);

		#unless( $#fields == 84){  #if the number of values in the columns array is exactly 85, this is for Darwin Core
		unless( $#fields == 90){  #if the number of values in the columns array is exactly 91, this is for Darwin Core

			warn "$#fields bad field number $_\n";

			next Record;
		}

#id	institutionCode	collectionCode	ownerInstitutionCode	basisOfRecord	occurrenceID	catalogNumber	otherCatalogNumbers	
#higherClassification	kingdom	
($CCH2id,
$institutionCode,
$collectionCode,
$ownerInstitutionCode,
#$collectionID,  #this keeps appearing and disappearing, I think it is in the Darwin Core export and not Symbiota Native
$basisOfRecord,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$higherClassification,
$kingdom,
#10
#phylum	class	order	family	scientificName	taxonID	scientificNameAuthorship	genus	subgenus	
#specificEpithet	
#$kingdom,
#phylum	class	order	family	scientificName	taxonID	scientificNameAuthorship	genus	subgenus	specificEpithet	
$phylum,
$class,
$order,
$family,
$scientificName,
$taxonID,
$scientificNameAuthorship,
$genus,
$subgenus,
$specificEpithet,
#20
#verbatimTaxonRank	infraspecificEpithet	taxonRank	identifiedBy	dateIdentified	identificationReferences	
#identificationRemarks	taxonRemarks	identificationQualifier	typeStatus	
$verbatimTaxonRank,
$infraspecificEpithet,
$taxonRank,
$identifiedBy,
$dateIdentified,
$identificationReferences,
$identificationRemarks,
$taxonRemarks,
$identificationQualifier,
$typeStatus,
#30
#recordedBy	associatedCollectors	recordNumber	eventDate	year	month	day	startDayOfYear	endDayOfYear	
#verbatimEventDate	
$recordedBy,
$associatedCollectors, #This is in Symbiota Native and not Darwin Core
$recordNumber,
$eventDate,
$year,
$month,
$day,
$startDayOfYear,
$endDayOfYear,
$verbatimEventDate,
#40
#occurrenceRemarks	habitat	substrate	verbatimAttributes	fieldNumber	eventID	informationWithheld	dataGeneralizations	
#dynamicProperties	associatedOccurrences	
$occurrenceRemarks,
$habitat,
$substrate, #This is in Symbiota Native and not Darwin Core
$verbatimAttributes, #This is in Symbiota Native and not Darwin Core
$fieldNumber,
$eventID, #This is in Symbiota Native and not Darwin Core
$informationWithheld,
$dataGeneralizations,
$dynamicProperties,
$associatedOccurrences,
#$associatedTaxa,
#$reproductiveCondition,
#$establishmentMeans,
#50
#associatedSequences	associatedTaxa	reproductiveCondition	establishmentMeans	cultivationStatus	lifeStage	sex	
#individualCount	preparations	country	
$associatedSequences, #This is in Symbiota Native and not Darwin Core
$associatedTaxa,
$reproductiveCondition,
$establishmentMeans,
$cultivationStatus, #This is in Symbiota Native and not Darwin Core
$lifeStage,
$sex,
$individualCount,
$preparations,
$country,
#$stateProvince,
#$verbatimCounty,
#$municipality,
#$locality,
#$locationRemarks,
#60
#stateProvince	county	municipality	locality	locationRemarks	localitySecurity	localitySecurityReason	
#decimalLatitude	decimalLongitude	geodeticDatum	
$stateProvince,
$verbatimCounty,
$municipality,
$locality,
$locationRemarks,
$localitySecurity, #This is in Symbiota Native and not Darwin Core
$localitySecurityReason, #This is in Symbiota Native and not Darwin Core
$latitude,
$longitude,
$geodeticDatum,
#$coordinateUncertaintyInMeters,
#$verbatimCoordinates,
#$georeferencedBy,
#$georeferenceProtocol,
#$georeferenceSources,
#$georeferenceVerificationStatus,
#$georeferenceRemarks,
#70
#coordinateUncertaintyInMeters	verbatimCoordinates	georeferencedBy	georeferenceProtocol	georeferenceSources	
#georeferenceVerificationStatus	georeferenceRemarks	minimumElevationInMeters	maximumElevationInMeters	minimumDepthInMeters
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,
$georeferenceProtocol,
$georeferenceSources,
$georeferenceVerificationStatus,
$georeferenceRemarks,
$minimumElevationInMeters,
$maximumElevationInMeters,
$minimumDepthInMeters,
#$verbatimDepth,
#$verbatimElevation,
#$disposition,
#$language,
#$recordEnteredBy,
#$modified,
#80
#maximumDepthInMeters	verbatimDepth	verbatimElevation	disposition	language	recordEnteredBy	modified	
#sourcePrimaryKey-dbpk	collId	recordId	references
$maximumDepthInMeters,
$verbatimDepth,
$verbatimElevation,
$disposition,
$language,
$recordEnteredBy,
$modified,
$sourcePrimaryKey, #This is in Symbiota Native and not Darwin Core
#$rights,  #This is in Darwin Core and not Symbiota Native
#$rightsHolder, #This is in Darwin Core and not Symbiota Native
#$accessRights, #This is in Darwin Core and not Symbiota Native
$collId, #This is in Symbiota Native and not Darwin Core
$recordId,
#90
$references	
) = @fields;	
#The array @fields is made up on these 85 scalars, in this order, for Darwin Core
#The array @fields is made up on these 91 scalars, in this order, for Symbiota Native


#filter by herbarium code
  if ($institutionCode =~ m/^PPWD$/){


#warn "$count_record\n" unless $count_record % 1009;
  printf {*STDERR} "%d\r", ++$count_record;


########ACCESSION NUMBER
#check for nulls
	if ($CCH2id =~ m/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped;
		next Record;
	}

#extract old herbarium and aid numbers
   if (length ($otherCatalogNumbers) >= 1){
#GDRC appears not to have anything in othercatalogNumbers
	if ($otherCatalogNumbers =~ m/^[A-Za-z-]+/){
		#$oldA="";
	}
	elsif ($otherCatalogNumbers =~ m/^[0-9]+/){
		#$oldA = $herb.$otherCatalogNumbers;
	}
	elsif ($otherCatalogNumbers =~ m/^(NULL| *)$/){
		$otherCatalogNumbers = "";
		#$oldA="";
	}
	else{
		$otherCatalogNumbers = "";
		#$oldA = "";
	}
   }
   else{
		$otherCatalogNumbers = "";
		#$oldA = "";
   }


#construct catalog numbers
   if (length ($catalogNumber) >= 1){

	if ($catalogNumber =~ m/^(0*[1-9][0-9]*)[A-Za-z-]+$/){#fix records without an herbarium code
		$ALT_CCH_BARCODE = $herb.$1."-BARCODE";
		$oldA = $old_AID = "";
	}
	elsif ($catalogNumber =~ m/^(0*[1-9][0-9]*)$/){#fix records without an herbarium code
		$ALT_CCH_BARCODE = $herb.$1."-BARCODE";
		$oldA = $old_AID = "";
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
		$oldA = $old_AID = "";
	}
	else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
		$oldA = $old_AID = "";
	}
   }
   else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
		$oldA = $old_AID = "";
   }

   if (length ($catalogNumber) >= 1){
	if ($duplicate_CAT{$ALT_CCH_BARCODE} >= 2){
		$duplicate_FOUND_CAT{$ALT_CCH_BARCODE}++;
		++$dups;
	}
   }


#exclude ALL duplicates 
	if ($duplicate_FOUND_CAT{$ALT_CCH_BARCODE}) {
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	#for example, the worst case is CAS520791, which has 17 specimens that were labeled with this number over the years.
		print OUT "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\t$scientificName\t$verbatimCounty\n";
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

