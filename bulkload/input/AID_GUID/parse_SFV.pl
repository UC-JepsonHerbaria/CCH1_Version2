
#use strict;
#use warnings;
#use diagnostics;
use lib '/Users/Shared/Jepson-Master/Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

my $today_JD;

#$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.
$herb="SFV";
#$filedate="11072019";
#$filedate="12052019";
$filedate="01292020";

open(IN, "/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_".$herb."_list.txt") || die;
local($/)="\n";
while(<IN>){
	chomp;
	($CN,$OCN,$ID,$acc,$alt,@residue)=split(/\t/);

	if (length ($acc) >= 1){
		$DUP{$acc}++;
	}
}

close(IN);


$today_JD = &get_today_julian_day;
my %month_hash = &month_hash;

my %DUP_FOUND;
my %duplicate;
my $included;
my %temp_skipped;
my $countNoteTemp;
my $countFail;
my %ICPN_ENTRY;
my %skipped;
my $line_store;
my $count;
my $seen;
my %seen;
my $det_string;
my $count_record;
my $GUID;
my %GUID_old;
my %GUID;
my $old_AID;
my $barcode;
my %TYPE;


#InstitutionCode	occid	occurrenceID	catalogNumber	otherCatalogNumbers	Sciname	tidinterpreted	taxonRemarks	identificationQualifier	identifiedBy	dateIdentified	identificationRemarks	typeStatus	recordedBy	associatedCollectors	recordNumber	year	month	day	verbatimEventDate	country	stateProvince	county	locality	locationRemarks	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	verbatimCoordinates	verbatimEventDate	georeferencedBy	georeferenceSources	georeferenceRemarks	minimumElevationInMeters	maximumElevationInMeters	verbatimElevation	habitat	occurrenceRemarks	associatedTaxa	verbatimAttributes	reproductiveCondition	cultivationStatus	dateLastModified


#CAS is first on the list, so it opens a new file for these two, while all others append
open(OUT3, ">>/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_excluded.txt") || die;
open(OUT2, ">>/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/output/AID_to_ADD.txt") || die;

#print OUT2 "CCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";
#print OUT3 "CCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";



#id	type	modified	language	institutionCode	collectionCode	basisOfRecord	occurrenceID	catalogNumber	occurrenceRemarks	recordNumber	recordedBy	otherCatalogNumbers	eventDate	startDayOfYear	year	month	day	verbatimEventDate	habitat	higherGeography	continent	country	stateProvince	county	municipality	locality	verbatimElevation	minimumElevationInMeters	maximumElevationInMeters	verbatimLatitude	verbatimLongitude	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	georeferenceProtocol	georeferenceVerificationStatus	identifiedBy	dateIdentified	typeStatus	scientificName	higherClassification	kingdom	phylum	class	order	family	genus	specificEpithet	infraspecificEpithet	verbatimTaxonRank	scientificNameAuthorship	nomenclaturalCode
#urn:catalog:CAS:BOT-BC:522744	PhysicalObject	2016-10-19 09:19:30.0	en	CAS	BOT-BC	PreservedSpecimen	urn:catalog:CAS:BOT-BC:522744	522744	Shrub 10 feet tall	41804	Breedlove, D E	urn:catalog:CAS:DS:702772 | DS 702772	1976-11		1976	11		22 November 1976	Steep slopes and dry ravines	North America; Mexico; Chiapas; Amatenango de la Frontera Municipio	North America	Mexico	Chiapas	Amatenango de la Frontera Municipio		along Río Cuilco between Nuevo Amatenango and Frontera Comalapa	1100 m	1100	1100												Croton guatemalensis  Lotsy	Plantae; Magnoliophyta; Magnoliopsida; Euphorbiales; Euphorbiaceae	Plantae	Magnoliophyta	Magnoliopsida	Euphorbiales	Euphorbiaceae	Croton	guatemalensis			Lotsy	ICBN


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
if ($institutionCode =~ m/^SFV$/){


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
	elsif ($otherCatalogNumbers =~ m/^(SFV)-(\d+)[ABC]?$/){
		$old_AID=$1.$2;
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

#convert to form without leading zeros
	if ($old_AID =~ m/^(SFV)0+(\d+)$/){
		$oldA = $old_AID;
		$old_AID=$1.$2;
		#print "HERB(2)\t$oldA\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n"";
	}


#construct catalog numbers
if (length ($catalogNumber) >= 1){
	if ($catalogNumber =~ m/^(SFV)(\d+)$/){
		$ALT_CCH_BARCODE = $1."-BC".$2;
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
#Add prefix to unique identifier field, two format, choose one and add to the code above
#$ALT_CCH_BARCODE=$aidcode.$aid;
#$ALT_CCH_BARCODE=$herb.$catalogNumber;
#$ALT_CCH_BARCODE=$catalogNumber; #use this format if the old CCH herbarium code is correctly added in the catalog number field



if (($catalogNumber =~ m/^ *$/) && ($otherCatalogNumbers =~ m/^ *$/)){
		&log_skip("$herb ALL AIDs NULL: $CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");	#run the &log_skip function, printing the following message to the error log
		++$null;
		next Record;
}
else{
#Remove duplicates
	if($DUP{$old_AID}){
		print OUT3 "$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\t$scientificName\t$county\n";
#print "EXCL $old_AID\n";
++$dups;
	}
	else{
		print OUT2 "$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tNONDUP\t$occurrenceID\t$scientificName\t$county\n";
#print "INCL $old_AID\n";
++$included;
	}
}

}





}
print <<EOP;
$herb INCL: $included
$herb EXCL: $dups
$herb NULL: $null

$herb TOTAL: $count_record

EOP


close(IN);
close(OUT2);
close(OUT3);
