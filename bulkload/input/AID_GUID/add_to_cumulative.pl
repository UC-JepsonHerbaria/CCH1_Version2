
use strict;
#use warnings;
#use diagnostics;
use lib '../../Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

#my $dirdate = "2021_APR16";
#my $dirdate="2021_AUG28";
#my $dirdate="2022_JAN26";
#my $dirdate = "2022_MAR02";
my $dirdate = "2022_JUL07";
#$filedate = "2022JUL07";
my $filedate = "2023MAR08";

#$filedate="11072019";
#my $filedate="12052019";
#my $filedate = "01292020";
#my $filedate = "04162021";
#my $filedate="08282021";
#my $filedate="01262022";
#my $filedate = "03022022";



my $today_JD = &CCH::get_today;
#my $today_JD = &get_today_julian_day;
$today_JD =~ s/ *PDT//;

my %ACC_HERB;
my %ACC_MOD;
my %ACC_FOUND;
my %UNQ_ID;
my %skipped;

#IN files
my ($BAD_REM, $CCH1_CAT, $excluded, $bad2, $bad1, $non, $skipped, $ocatb, $catb, $cch2idb, $occid) = "";
my ($aidStatus, $aidName, $uniqueID, $aidCounty, $aidGUID, $herb, $included, $count_record) = "";
my ($HERB, $gg, $NULL, $aidCounty, $aidGUID, $herb, $included, $herbcode) = "";

my ($dups, $old_cchid,$cch_barcode,$cch_alt_aid, $null, $barcode) = "";

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


$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.

open(BAD, ">output/AID_to_ADD_CCH2_missing.txt") || die;

open(OUT, ">output/AID_to_ADD_CCH2_mod.txt") || die;
open(NON, ">output/bulkload_nonvasc_excluded.txt") || die;

	print OUT "herbcode\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tCCH_ID_BARCODE\tALT_CCH_AID\tStatus\tGUID-occurrenceID\tSciName\tCounty\tCCH2_dateLastModified\n";
	print BAD "herbcode\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tCCH_ID_BARCODE\tALT_CCH_AID\tStatus\tGUID-occurrenceID\tSciName\tCounty\tCCH2_dateLastModified\n";

		

open(IN, "../../Jepson-eFlora/synonymy/input/mosses.txt") || die "CCH.pm couldnt open mosses for non-vascular exclusion $!\n";
while(<IN>){
	chomp;
	($gg)=split(/\n/);
	$exclude{$gg}++;

}
close(IN);


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
($id,
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


++$included;

$herb = $institutionCode;


	if (length ($genus) > 1){
		if($exclude{$genus}){	
			print NON "$HERB ERR TAXON $genus(1): Non-vascular plant ($scientificName)\t$occid==>$_\n";
			++$non;
			next Record;
		}
	}
	else{
	$genus = $scientificName;
	$genus =~ s/^([A-Z][a-z-]+) *.*$/$1/;	
		if($exclude{$genus}){	
			print NON "$HERB ERR TAXON $genus(2): Non-vascular plant ($scientificName)\t$occid==>$_\n";
			++$non;
			next Record;
		}

	}

	if($id =~ m/^ *$/) {	
			++$NULL;
			next Record;
	}
	else{
			$ACC_FOUND{$id}++;
			$ACC_MOD{$id} = $modified;

		if(($catalogNumber =~ m/^ *$/) && ($otherCatalogNumbers =~ m/^ *$/)){	
			++$skipped;
			next Record;
		}

	}


 }

print <<EOP;
CCH2 TOTAL RECORDS: $included

CCH2 NULL Barcodes and CatNumbers: $skipped

CCH2 records without OCCID: $NULL

CCH2 NONVASC EXCL: $non

EOP


close(IN);
close(NON);




my $included;
#my $file = "2459325"; #LJD of the date AID file was processed
#my $file = "2459518";
#my $file = "2459522";
#my $file = "2459648";
my $file = "2022-07-11"; #changed to a date string


my $addFile = 'input/AID_GUID/output/AID_to_ADD_'.$file.'.txt';
open (IN, $addFile) or die $!;
	while(<IN>){
		chomp;
		($herbcode,$catb,$ocatb,$cch2idb,$old_cchid,$cch_barcode,$cch_alt_aid,$aidStatus,$aidGUID,$aidName,$aidCounty)=split(/\t/);

#herbcode	CCH2_catalogNumber	CCH2_otherCatalogNumbers	CCH2_ID	OLD_CCH_AID	CCH_BARCODE_ID	ALT_CCH_AID	Status	GUID-occurrenceID	SciName	County
#RSA	RSA0192510	RSA accession #: 108712	3875886	RSA108712	RSA0192510 BARCODE		NONDUP	1dd12db8-a87b-4901-ab1f-a47fff2e7058	Astragalus calycosus	Mono
#RSA	RSA0193859	RSA accession #: 646835	3881743	RSA646835	RSA0193859 BARCODE		NONDUP	8e957584-4ea6-402d-a68b-5df418067c37	Astragalus cottonii	Clallam
#RSA	RSA0196312	POM accession #: 452	3883920	POM452	RSA0196312 BARCODE		NONDUP	4291dd75-d3a6-4068-b295-d109038cb918	Tropidocarpum gracile var. dubium	Los Angeles
#RSA	RSA0205106	RSA accession #: 678528	3912466	RSA678528	RSA0205106 BARCODE		NONDUP	142fa477-637a-4d7e-9933-e7eb166ea76e	Verbena tenuisecta	Ventura


$barcode = $cch_barcode;
$barcode =~ s/ +BARCODE$/-BARCODE/;


++$included;
#old_cchid is the old CCH accession number, before barcodes were introduced
#cch_barcode is a the barcode accession in the format: herbarium+barcode+space 'BARCODE' appended at the end
  #blank if the barcode does not exist
  #same as cchidb for herbaria that do not create a new barcode number		
#cch_alt_aid is a variant that some herbaria have changed from (or to), sometimes this is the same
  #mostly this is a variant with leading zeros

#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;


   if (($catb =~ m/^ *$/) && ($ocatb =~ m/^ *$/)){
		++$null;
		next;
   }
   else{
   
print OUT join("\t",$herbcode,$catb,$ocatb,$cch2idb,$old_cchid,$barcode,$cch_alt_aid,$aidStatus,$aidGUID,$aidName,$aidCounty,$ACC_MOD{$cch2idb}),"\n";
	++$CCH1_CAT;
   }

}
print <<EOP;

AID PROCESSED REPORT:
CCH MAIN TOTAL RECORDS: $included

CCH MAIN null Barcodes and CatNumbers: $null (this should be null, if not something is wrong)

processed CCH1 accessions linked to CCH2 ID: $CCH1_CAT

EOP


close(IN);
close(OUT);

