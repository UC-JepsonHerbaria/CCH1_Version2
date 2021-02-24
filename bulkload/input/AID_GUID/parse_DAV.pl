
#use strict;
#use warnings;
#use diagnostics;
use lib '/Users/Shared/Jepson-Master/Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

my $today_JD;

$herb="DAV";
#$filedate="11072019";
#$filedate="12052019";
$filedate="01292020";


open(IN, "/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_".$herb."_list.txt") || die;
local($/)="\n";
while(<IN>){
	chomp;
	($CN,$OCN,$ID,$acc,$alt,@residue)=split(/\t/);

	$DUP{$alt}++;
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

print OUT2 "CCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";
print OUT3 "CCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";



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
#taxonRemarks	identificationQualifier	typeStatus	recordedBy	associatedCollectors	recordNumber	
$dateIdentified,
$identificationReferences,	#added 2015, not processed
$identificationRemarks,	#added 2015, not processed
$taxonRemarks,	#added 2015
$identificationQualifier,
$typeStatus,
$recordedBy,
#$recordedByID,			#added 2016, not in 2017 download
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
)=@fields;	#The array @columns is made up on these 85 scalars, in this order


#filter by herbarium code
if ($institutionCode =~ m/^DAV$/){


#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;



########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped{one};
		next Record;
	}

my $oldA ="";
	$catalogNumber =~ s/^DAV307257DAV307257/DAV307257/; #there is one bad record here that needed fixed
	$catalogNumber =~ s/^(03533599101294|004805021602)$//; #there two more records here that needed fixed

	
#extract old herbarium and aid numbers
if (length ($otherCatalogNumbers) >= 1){
	if ($otherCatalogNumbers =~ m/^(DAV|AHUC)([0-9]+[A-Z]*); *(UCD[0-9]+)$/){ #DAV is unique as it has a combined otherCatalogNumber field
														#it has to be split into two components, one is the old CCH AID; DAV122395; UCD125896
		$oldA= $1.$2;
		$old_AID = $3;
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(JOTR|PORE|YOSE|OSE)([0-9]+); *(UCD[0-9]+)$/){ #DAV some other accessioned entered in the otherCatalogNumber field
														#it has to be split into two components, one is the old CCH AID; DAV122395; UCD125896
														#YOSE is Yousemite, PORE is Point Reyes
		$oldA= $1.$2;
		$old_AID = $3;
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(AV|DV|DA|DAAV|DAC|DAVA|DFAV)([0-9]+)[AB]?; *(UCD[0-9]+)$/){ #DAV has typo herbarium codes in the otherCatalogNumber field
														#it has to be split into two components, one is the old CCH AID; DAV122395; UCD125896
		$oldA= "DAV".$2;
		$old_AID = $3;
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(HUC|AHUCL|AUHC|AUHC|AHUCA|AUC|AHUV)([0-9]+); *(UCD[0-9]+)$/){ #DAV has typo herbarium codes in the otherCatalogNumber field
														#it has to be split into two components, one is the old CCH AID; DAV122395; UCD125896
		$oldA= "AHUC".$2;
		$old_AID = $3;
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(UCD[0-9]+); *$/){ #DAV is unique as with this variant
		$old_AID = $1;
		$oldA= "";
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(DAV|AHUC)([0-9]+)[AB]?$/){ #DAV has some records without old Access record ID in otherCatalogNumber field
		$old_AID = "";
		$oldA= $1.$2;
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($otherCatalogNumbers =~ m/NULL/){
		$otherCatalogNumbers = "";
		$oldA="";
		$old_AID="";
	}
	else{
		&CCH::log_change("BAD Accession==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$otherCatalogNumbers = "";
		$oldA="";
		$old_AID="";
	}
}
else{
		$otherCatalogNumbers = "";
		$oldA="";
		$old_AID="";
}

#construct catalog numbers
#daV has some anomalies that are not barcodes added to catalogNumber; examples of the many records below
#BAD catalogNumber==>3699265==>AHUC100618==>AHUC37713
#BAD catalogNumber==>1354161==>AHUC101868==>AHUC24153; UCD100910
#BAD catalogNumber==>1354195==>YOSE230658==>YOSE230658; UCD100945
#BAD otherCatalogNumbers==>1354643==>NULL==>UCD101408;
#BAD otherCatalogNumbers==>1354660==>NULL==>UCD101425;


if (length ($catalogNumber) >= 1){
	
	if ($catalogNumber =~ m/^(DAV)(\d+)$/){ #DAV is adding barcodes incrementally, so not all old CCH numbers have them

		$ALT_CCH_BARCODE = $1."-BC".$2;
		#$ALT_CCH_BARCODE=$catalogNumber; DAV has 3 different barcodes, so catalog number cannot be assigned here
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/^(AHUC)(\d+)$/){ #AHUC is part of DAV and it appears they are not adding DAV to these barcodes

		$ALT_CCH_BARCODE = $1."-BC".$2;
		#$ALT_CCH_BARCODE=$catalogNumber; DAV has 3 different barcodes, so catalog number cannot be assigned here
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/^(YOSE)(\d+)$/){ #YOSE is NOT is part of DAV; they do not appear to eb re-assinging DAV barcodes to these
												#these will conflict with YOSE, so make the catalogNumber for these NULL
		$ALT_CCH_BARCODE = "";
		$catalogNumber = "";
		#$ALT_CCH_BARCODE=$catalogNumber; DAV has 3 different barcodes, so catalog number cannot be assigned here
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/NULL/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE ="";
	}
	else{
		&CCH::log_change("BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$catalogNumber = "";
		$ALT_CCH_BARCODE ="";
	}
}
else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE ="";
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
	if($DUP{$old_AID}){#these should not have duplicates, but some are
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
