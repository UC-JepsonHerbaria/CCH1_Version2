
use strict;
#use warnings;
#use diagnostics;
use lib '/Users/Shared/Jepson-Master/Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev
my $today_JD = &get_today_julian_day;

open(BULKLOG, ">>/Users/Shared/Jepson-Master/CCHV2/bulkload/output/CCH2_bulkload_log_".$today_JD.".txt") || die; 


$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.
my $herb="CAS-BOT";
my $dirdate = "2020_JAN29";
#$filedate="11072019";
#my$filedate="12052019";
my $filedate = "01292020";

my %month_hash = &month_hash;


#declare variables
my %skipped;
my %DUP;

my ($dups, $old_AID, $ALT_CCH_BARCODE, $CCH2id, $oldA, $null) = "";

my ($HN,$CN,$OCN,$ID,$acc,$alt,$residue) = "";

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


open(IN, "/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_".$herb.$today_JD.".txt") || die;
local($/)="\n";
while(<IN>){
	chomp;
	($HN,$CN,$OCN,$ID,$acc,$alt,$residue)=split(/\t/);

	if (length ($ID) >= 1){
		$DUP{$ID}++;
	}
}

close(IN);


#InstitutionCode	occid	occurrenceID	catalogNumber	otherCatalogNumbers	Sciname	tidinterpreted	taxonRemarks	identificationQualifier	identifiedBy	dateIdentified	identificationRemarks	typeStatus	recordedBy	associatedCollectors	recordNumber	year	month	day	verbatimEventDate	country	stateProvince	county	locality	locationRemarks	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	verbatimCoordinates	verbatimEventDate	georeferencedBy	georeferenceSources	georeferenceRemarks	minimumElevationInMeters	maximumElevationInMeters	verbatimElevation	habitat	occurrenceRemarks	associatedTaxa	verbatimAttributes	reproductiveCondition	cultivationStatus	dateLastModified

#CAS is first on the list, so it opens a new file for these two, while all others append
open(OUT3, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_to_be_excluded_CCH2.txt") || die;
open(OUT2, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/output/AID_to_ADD_CCH2.txt") || die;

print OUT2 "herbcode\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";
print OUT3 "herbcode\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";



#id	type	modified	language	institutionCode	collectionCode	basisOfRecord	occurrenceID	catalogNumber	occurrenceRemarks	recordNumber	recordedBy	otherCatalogNumbers	eventDate	startDayOfYear	year	month	day	verbatimEventDate	habitat	higherGeography	continent	country	stateProvince	county	municipality	locality	verbatimElevation	minimumElevationInMeters	maximumElevationInMeters	verbatimLatitude	verbatimLongitude	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	georeferenceProtocol	georeferenceVerificationStatus	identifiedBy	dateIdentified	typeStatus	scientificName	higherClassification	kingdom	phylum	class	order	family	genus	specificEpithet	infraspecificEpithet	verbatimTaxonRank	scientificNameAuthorship	nomenclaturalCode
#urn:catalog:CAS:BOT-BC:522744	PhysicalObject	2016-10-19 09:19:30.0	en	CAS	BOT-BC	PreservedSpecimen	urn:catalog:CAS:BOT-BC:522744	522744	Shrub 10 feet tall	41804	Breedlove, D E	urn:catalog:CAS:DS:702772 | DS 702772	1976-11		1976	11		22 November 1976	Steep slopes and dry ravines	North America; Mexico; Chiapas; Amatenango de la Frontera Municipio	North America	Mexico	Chiapas	Amatenango de la Frontera Municipio		along Río Cuilco between Nuevo Amatenango and Frontera Comalapa	1100 m	1100	1100												Croton guatemalensis  Lotsy	Plantae; Magnoliophyta; Magnoliopsida; Euphorbiales; Euphorbiaceae	Plantae	Magnoliophyta	Magnoliopsida	Euphorbiales	Euphorbiaceae	Croton	guatemalensis			Lotsy	ICBN


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
#taxonRemarks	identificationQualifier	typeStatus	recordedBy	associatedCollectors	recordNumber	
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
#30
#eventDate	year	month	day	startDayOfYear	endDayOfYear	verbatimEventDate	occurrenceRemarks	habitat	substrate	
$eventDate,
$year,
$month,
$day,
$startDayOfYear,
$endDayOfYear,
$verbatimEventDate,
$occurrenceRemarks,
$habitat,
$substrate,			#added 2016
#40
#verbatimAttributes	fieldNumber	informationWithheld	dataGeneralizations	dynamicProperties	associatedTaxa	
#reproductiveCondition	establishmentMeans	cultivationStatus	lifeStage	
$verbatimAttributes, #added 2016
$fieldNumber,
$informationWithheld,
$dataGeneralizations,	#added 2015, not processed, field empty as of 2016
$dynamicProperties,	#added 2015, not processed
$associatedTaxa,
$reproductiveCondition,
$establishmentMeans,	#added 2015, not processed
$cultivationStatus,	#added 2016
$lifeStage,
#50
#sex	individualCount	preparations	country	stateProvince	county	municipality	locality	
#locationRemarks	localitySecurity
$sex,	#added 2015, not processed
$individualCount,	#added 2015, not processed
$preparations,	#added 2015, not processed
$country,
$stateProvince,
$county,
$municipality,
$locality,
$locationRemarks, #newly added 2015-10, not processed
$localitySecurity,		#added 2016, not processed
#60
#localitySecurityReason	decimalLatitude	decimalLongitude	geodeticDatum	
#coordinateUncertaintyInMeters	verbatimCoordinates	georeferencedBy	georeferenceProtocol	
$localitySecurityReason,	#added 2016, not processed
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,	#added 2015, not processed
$georeferenceProtocol,	#added 2015, not processed
$georeferenceSource,
$georeferenceVerificationStatus,	#added 2015, not processed
#70
#georeferenceRemarks	minimumElevationInMeters	
#maximumElevationInMeters	minimumDepthInMeters	maximumDepthInMeters	verbatimDepth	verbatimElevation	disposition	
#language	recordEnteredBy
$georeferenceRemarks,	#added 2015, not processed
$minimumElevationInMeters,
$maximumElevationInMeters, #not processed for now
$minimumDepthInMeters, #newly added 2015-10, not processed
$maximumDepthInMeters, #newly added 2015-10, not processed
$verbatimDepth, #newly added 2015-10, not processed
$verbatimElevation,
$disposition,	#added 2015, not processed
$language,	#added 2015, not processed
$recordEnteredBy, #newly added 2015-10, not processed
#80
#modified	sourcePrimaryKey-dbpk	collId	recordId	references
$modified,	#added 2015, not processed
$sourcePrimaryKey,  #added 2016, not processed
$collID,	#added 2016, not processed
$recordId,	#added 2015, not processed
$references	#added 2016, not processed
)=@fields;	#The array @fields is made up on these 85 scalars, in this order


#filter by herbarium code
  if ($institutionCode =~ m/^CAS/){


#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;



########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped;
		next Record;
	}

#fix some odd typos in CAS accessions
	$otherCatalogNumbers =~ s/(smith|frenk)//i; 

#extract old herbarium and aid numbers
   if (length ($otherCatalogNumbers) >= 1){

	if ($otherCatalogNumbers =~ m/\| *(CAS|DS) *(\d+)[a-zA-Z]*$/){ #unique to CAS
		$old_AID = $1.$2;;
		$old_AID=~ s/ //g; #remove spaces that are popping up
		#print "HERB(2)\t$old_AID\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n"";
	}
	elsif ($otherCatalogNumbers =~ m/^(CAS|DS) *(\d+)[a-zA-Z]*$/){ #unique to CAS
		$old_AID = $1.$2;;
		$old_AID=~ s/ //g; #remove spaces that are popping up
		#print "HERB(2)\t$old_AID\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(NULL| *)$/){
		$otherCatalogNumbers = "";
		$old_AID="";
	}
	else{
		&CCH::log_change("BAD Accession==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		#print "BAD otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
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

	if ($catalogNumber =~ m/^(\d+)$/){#fix records without an herbarium code
		$ALT_CCH_BARCODE=$herb.$1." BARCODE";
		#print "HERB(3)\t$ALT_CCH_BARCODE\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
	}
	else{
		&CCH::log_change("BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		#print "BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
	}
   }
   else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
   }
   
   if (($catalogNumber =~ m/^ *$/) && ($otherCatalogNumbers =~ m/^ *$/)){
		&log_skip("$herb ALL AIDs NULL: $CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");	#run the &log_skip function, printing the following message to the error log
		++$null;
		next Record;
   }
   else{
#Remove duplicates
	if($DUP{$CCH2id}){
		print OUT3 "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\t$scientificName\t$county\n";
#print "EXCL $old_AID\n";
++$dups;
	}
	else{
		print OUT2 "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tNONDUP\t$occurrenceID\t$scientificName\t$county\n";
#print "INCL $old_AID\n";
++$included;
	}
   }

}





}
print <<EOP;
$herb INCL: $included
$herb DUPS: $dups
$herb NULL: $null

$herb TOTAL: $count_record

EOP


close(IN);
close(OUT2);
close(OUT3);
close(BULKLOG);