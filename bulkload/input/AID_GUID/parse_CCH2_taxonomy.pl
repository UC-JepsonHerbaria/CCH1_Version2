use strict;
#use warnings;
#use diagnostics;
use lib '../../../Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev
my $today_JD = &get_today_julian_day;


$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.

#my $dirdate = "2020_JAN29";
my $dirdate = "2021_APR16";
#$filedate="11072019";
#my$filedate="12052019";
#my $filedate = "01292020";
my $filedate = "04162021";

my %month_hash = &month_hash;


#declare variables
my %DUP;

my ($dups, $old_AID, $ALT_CCH_BARCODE, $CCH2id, $oldA, $null, $newherbCode) = "";

my ($HN,$CN,$OCN,$ID,$acc,$alt,$residue) = "";

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


#InstitutionCode	occid	occurrenceID	catalogNumber	otherCatalogNumbers	Sciname	tidinterpreted	taxonRemarks	identificationQualifier	identifiedBy	dateIdentified	identificationRemarks	typeStatus	recordedBy	associatedCollectors	recordNumber	year	month	day	verbatimEventDate	country	stateProvince	county	locality	locationRemarks	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	verbatimCoordinates	verbatimEventDate	georeferencedBy	georeferenceSources	georeferenceRemarks	minimumElevationInMeters	maximumElevationInMeters	verbatimElevation	habitat	occurrenceRemarks	associatedTaxa	verbatimAttributes	reproductiveCondition	cultivationStatus	dateLastModified


#CAS is first on the list, so it opens a new file for these two, while all others append
open(OUT3, ">>/Users/Shared/Jepson-Master/CCH/SYMBIOTA/taxonomy_extract_".$today_JD.".txt") || die;


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



#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;




#construct catalog numbers
   if (length ($higherClassification) >= 1){

	if ($higherClassification =~ m/^Organism\|Plantae\|/){
		my $temp = $class.$order.$family;
		print OUT3 "$class\t$order\t$family\n" unless $seen{$temp}++;
		++$dups;
	}
	else{

	}
   }
   else{

   }

}
print <<EOP;

TOTAL: $count_record

TAX LINES FOUND: $dups

EOP


close(IN);
close(OUT2);
close(OUT3);
