
use strict;
#use warnings;
#use diagnostics;
use lib '/Users/Shared/Jepson-Master/Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

my $today_JD;

my %ACC_HERB;
my %ACC_MOD;
my %ACC_FOUND;
my %UNQ_ID;
my %skipped;
my ($BAD_REM, $CCH1_CAT, $excluded, $bad2, $bad1, $non, $skipped, $ocatb, $catb, $cchidb, $cch2idb, $occid, $count_record) = "";
my ($aidStatus, $altcchidb, $aidSpace, $aidName, $uniqueID, $aidCounty, $aidGUID, $herb, $included) = "";
my ($ss, $HERB, $NULL, $gg, $filedate, $aidCounty, $aidGUID, $herb, $included) = "";

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


#$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.

#$filedate="12052019";
$filedate="01292020";

open(BAD, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/output/AID_to_ADD_CCH2_missing.txt") || die;

open(OUT, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/output/AID_to_ADD_cumulative.txt") || die;
open(NON, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/output/bulkload_nonvasc_excluded.txt") || die;

		print OUT "institutionCode\tCCH2_ID\tCCH2_dateLastModified\tstatus\tCCH1_AID\tALT_CCH1_AID\tALT_CCH1_AID_B\tSciName\tCounty\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tGUID-occurrenceID\n";
		print BAD "institutionCode\tCCH2_ID\tCCH2_dateLastModified\tstatus\tCCH1_AID\tALT_CCH1_AID\tALT_CCH1_AID_B\tSciName\tCounty\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tGUID-occurrenceID\n";


open(IN, "/Users/Shared/Jepson-Master/Jepson-eFlora/synonymy/input/mosses.txt") || die "CCH.pm couldnt open mosses for non-vascular exclusion $!\n";
while(<IN>){
	chomp;
	($gg)=split(/\n/);
	$exclude{$gg}++;

}
close(IN);


#CCH2_catalogNumber	CCH2_otherCatalogNumbers	CCH2_ID	OLD_CCH_AID	ALT_CCH_ID	ALT_CCH_AID_SPACE	Status	GUID-occurrenceID	SciName	County
#BFRS407		2960780	BFRS407	BFRS407	BFRS 407	NONDUP	01611011-703c-4c46-a0d8	Viola glabella	El Dorado
#BFRS90		2960815	BFRS90	BFRS90	BFRS 90	NONDUP	0399d2a4-bcf9-47ec-ac83	Juncus tenuis	El Dorado
#CCH2_catalogNumber	CCH2_otherCatalogNumbers	CCH2_ID	OLD_CCH_AID	ALT_CCH_ID	ALT_CCH_AID_SPACE	Status	GUID-occurrenceID	SciName	County
#522744	urn:catalog:CAS:DS:702772 | DS 702772	2270135	DS702772	CAS-BOT-BC522744		NONDUP	urn:catalog:CAS:BOT-BC:522744	Croton guatemalensis	
#319960	urn:catalog:CAS:BOT:1060568 | CAS 1060568	2270137	CAS1060568	CAS-BOT-BC319960		NONDUP	urn:catalog:CAS:BOT-BC:319960	Skimmia arborescens	Dulongjiang Xiang
#504936	urn:catalog:CAS:BOT:674815 | CAS 674815	2270138	CAS674815	CAS-BOT-BC504936		NONDUP	urn:catalog:CAS:BOT-BC:504936	Ficus petenensis	
#65174	urn:catalog:CAS:BOT:1118164 | CAS 1118164	2270140	CAS1118164	CAS-BOT-BC65174		NONDUP	urn:catalog:CAS:BOT-BC:65174	Pholistoma membranaceum	



my $mainFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/CCH2-exports/CCH2_export_'.$filedate.'.txt';
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
	++$skipped{one};
	next Record;
	}

#id	institutionCode	collectionCode	ownerInstitutionCode	basisOfRecord	occurrenceID	catalogNumber	otherCatalogNumbers
($occid,
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
$associatedCollectors,	#added 2016, not in 2017 download, combined within recorded by with a ";"
$recordNumber,
$eventDate,
#30
#eventDate	year	month	day	startDayOfYear	endDayOfYear	verbatimEventDate	occurrenceRemarks	habitat	substrate	
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
$sourcePrimaryKey,  #added 2016, not processed
$collID,	#added 2016, not processed
$recordId,	#added 2015, not processed
$references	#added 2016, not processed, 84
)=@fields;	#The array @columns is made up on these 84 scalars, in this order

++$included;

$herb = $institutionCode;
$herb =~ s/^YM-YOSE$/YM/;


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

	if($occid =~ m/^ *$/) {	
			++$NULL;
			next Record;
	}
	else{
			$ACC_FOUND{$occid}++;
			$ACC_HERB{$occid} = $herb;
			$ACC_MOD{$occid} = $modified;

		if(($catalogNumber =~ m/^ *$/) && ($otherCatalogNumbers =~ m/^ *$/)){	
			++$skipped;
			next Record;
		}

	}


 	}
close(IN);
close(NON);





my $addFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/output/AID_to_ADD.txt';
open (IN, $addFile) or die $!;
	while(<IN>){
		chomp;
		($catb,$ocatb,$cch2idb,$cchidb,$altcchidb,$aidSpace,$aidStatus,$aidGUID,$aidName,$aidCounty)=split(/\t/);

		$altcchidb =~ s/^UCLA(\d)/UC-LA$1/g;#fix an error that needs to be fixed in a later update

#delete leading zeros that are still creeping in where not wanted
			if ($altcchidb =~ m/^(SCFS|PASA)0+([1-9][0-9]+)$/){
				$altcchidb = $1.$2;
			}
			
#delete spaces zeros that are still creeping in where not wanted
			if ($altcchidb =~ m/^(CAS|DS) *([0-9]+)$/){
				$altcchidb = $1.$2;
			}
			
			if ($cchidb =~ m/^(CAS|DS) *([0-9]+)$/){
				$cchidb = $1.$2;
			}

			if ($aidSpace =~ m/^(CAS|DS) *([0-9]+)$/){
				$aidSpace = $1.$2;
			}

#cchidb is the old CCH1 accession number
#altcchid is a variant that some herbaria have changed from (or to), sometimes this is the same
#$ss is a variant without leading zeros in some collections
		
		if ($ss =~ m/^([A-Z]+ +|UCJEPS \d+)$/){#there are some bad Alt2 cat numbers generated that will be fixed in later loads
			++$bad1;
		}
		
		if ($catb =~ m/^([A-Z]+ +|UCLA\d+)$/){#there are some bad cat numbers generated that will be fixed in later loads
			++$bad2;
		}

	if ($cchidb !~ m/^(SEINET|A|NY|GH|ECON|AMES)\d+/){
		if ($ACC_FOUND{$cch2idb}){

			++$CCH1_CAT;
#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;

print OUT join("\t",$ACC_HERB{$cch2idb},$cch2idb,$ACC_MOD{$cch2idb},$aidStatus,$cchidb,$altcchidb,$aidSpace,$aidName,$aidCounty,$catb,$ocatb,$aidGUID),"\n";

		}
		else{
print  BAD join("\t",$ACC_HERB{$cch2idb},$cch2idb,$ACC_MOD{$cch2idb},$aidStatus,$cchidb,$altcchidb,$aidSpace,$aidName,$aidCounty,$catb,$ocatb,$aidGUID),"\n";

			print "MISSING CCH2_ID==>$cch2idb==>$ACC_HERB{$cch2idb}-->$cchidb($catb==>$ocatb)\n";
			#most of the ones kicked out here are missing accessions and barcodes in CCH2
			#they should be added to CCH1 as these fields are populated
			#however this count will grow and contract as as specimens are added
			++$BAD_REM;
		}
	}

}
print <<EOP;
CCH2 Main TOTAL RECORDS: $included

CCH2 NULL Barcodes and CatNumbers: $skipped

CCH2 NONVASC EXCL: $non

BAD ACCESSION format 1: $bad1
BAD ACCESSION format 2: $bad2

MAIN RECORD EXCL: $excluded

CCH1 accession WITH CCH2 ID: $CCH1_CAT

CCH1 Numbers NOT FOUND IN CCH2: $BAD_REM

EOP


close(IN);
close(OUT);

