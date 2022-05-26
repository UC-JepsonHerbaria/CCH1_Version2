
#use strict;
#use warnings;
#use diagnostics;
use lib '../../../Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev
my $today_JD;
$today_JD = &get_today_julian_day;

$herb="HUH";
#$filedate="11072019";
$filedate="09272017";

my %month_hash = &month_hash;



open(OUT, ">DUPS/DUPS_".$herb."_list.txt") || die; #this only needs to be active once to generate a list of duplicated accessions

print OUT "CCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\n";

#id	type	modified	language	institutionCode	collectionCode	basisOfRecord	occurrenceID	catalogNumber	occurrenceRemarks	recordNumber	recordedBy	otherCatalogNumbers	eventDate	startDayOfYear	year	month	day	verbatimEventDate	habitat	higherGeography	continent	country	stateProvince	county	municipality	locality	verbatimElevation	minimumElevationInMeters	maximumElevationInMeters	verbatimLatitude	verbatimLongitude	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	georeferenceProtocol	georeferenceVerificationStatus	identifiedBy	dateIdentified	typeStatus	scientificName	higherClassification	kingdom	phylum	class	order	family	genus	specificEpithet	infraspecificEpithet	verbatimTaxonRank	scientificNameAuthorship	nomenclaturalCode
#urn:catalog:CAS:BOT-BC:522744	PhysicalObject	2016-10-19 09:19:30.0	en	CAS	BOT-BC	PreservedSpecimen	urn:catalog:CAS:BOT-BC:522744	522744	Shrub 10 feet tall	41804	Breedlove, D E	urn:catalog:CAS:DS:702772 | DS 702772	1976-11		1976	11		22 November 1976	Steep slopes and dry ravines	North America; Mexico; Chiapas; Amatenango de la Frontera Municipio	North America	Mexico	Chiapas	Amatenango de la Frontera Municipio		along Río Cuilco between Nuevo Amatenango and Frontera Comalapa	1100 m	1100	1100												Croton guatemalensis  Lotsy	Plantae; Magnoliophyta; Magnoliopsida; Euphorbiales; Euphorbiaceae	Plantae	Magnoliophyta	Magnoliopsida	Euphorbiales	Euphorbiaceae	Croton	guatemalensis			Lotsy	ICBN


my $mainFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/HUH/huh_'.$filedate.'_out.tab';
open (IN, $mainFile) or die $!;
Record: while(<IN>){
	chomp;

#fix some data quality and formatting problems that make import of fields of certain records problematic
	
    if ($. == 1){#activate if need to skip header lines
			next Record;
		}



		my @fields=split(/\t/,$_,100);
		
	foreach(@fields){
		s/^"//;
		s/"$//;
		s/""/"/g;
	}

    unless( $#fields == 49){ #if the number of values in the columns array is exactly 50

	&CCH::log_skip("$#fields bad field number $_\n");
	++$skipped{one};
	next Record;
	}
#InstitutionCode	occid	occurrenceID	catalogNumber	otherCatalogNumbers	5
#Sciname	tidinterpreted	taxonRemarks	identificationQualifier	identifiedBy	10
#dateIdentified	identificationRemarks	typeStatus	recordedBy	associatedCollectors	15
#recordNumber	year	month	day	verbatimEventDate	20
#country	stateProvince	county	locality	locationRemarks	25
#decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	verbatimCoordinates	30
#verbatimEventDate	georeferencedBy	georeferenceSources	georeferenceRemarks	minimumElevationInMeters	35
#maximumElevationInMeters	verbatimElevation	habitat	occurrenceRemarks	associatedTaxa	40
#verbatimAttributes	reproductiveCondition	cultivationStatus	dateLastModified	44

	($institution,
$collectioncode,
$collectionid,
$catalognumber,
$catalognumbernumeric,
$dc_type,
$basisofrecord,
$collectornumber,
$collector,
$sex,
$reproductiveStatus,
$preparations,
$verbatimdate,
$eventdate,
$year,
$month,
$day,
$startdayofyear,
$enddayofyear,
$startdatecollected,
$enddatecollected,
$habitat,
$highergeography,
$continent,
$country,
$stateprovince,
$islandgroup,
$county,
$island,
$municipality,
$locality,
$minimumelevationmeters,
$maximumelevationmeters,
$verbatimelevation,
$decimallatitude,
$decimallongitude,
$geodeticdatum,
$identifiedby,
$dateidentified,
$identificationqualifier,
$identificationremarks,
$identificationreferences,
$typestatus,
$scientificname,
$scientificnameauthorship,
$family,
$informationwitheld,
$datageneralizations,
$othercatalognumbers,
$update)=@fields;

#filter by herbarium code
if ($collectioncode =~ m/^(GH|A|ECON)$/){
	$code=$1;

#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;



########ACCESSION NUMBER
#check for nulls
	if ($catalognumbernumeric=~/^ *$/){
		$catalognumbernumeric = "NULL";
	}


#extract old herbarium and aid numbers
if (length ($catalognumbernumeric) >= 1){

	if ($catalognumbernumeric =~ m/^(\d+)$/){
		$otherID=$1;
		$old_AID=$code.$otherID;
		$oldA = "HUH".$otherID; #at one point HUH was added as the code for all of harvard, dont know how common this error is
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($catalognumbernumeric =~ m/NULL/){
		$otherID="";
		$oldA = $old_AID="";
	}
	else{
		&CCH::log_change("BAD CatalogNumber==>$catalognumbernumeric==>$catalognumber==>\t$_");
		print "BAD CatalogNumber==>$catalognumbernumeric==>$catalognumber\n";
		$otherID="";
		$oldA = $old_AID="";
	}
}
else{
		$otherID="";
		$otherCatalogNumbers = "";
		$oldA = $old_AID="";
}
#Add prefix to unique identifier field, two format, choose one and add to the code above
#$ALT_CCH_BARCODE=$aidcode.$aid;
#$ALT_CCH_BARCODE=$herb.$catalogNumber;
#$ALT_CCH_BARCODE=$catalogNumber; #use this format if the old CCH herbarium code is correctly added in the catalog number field

$otherCatalogNumbers = "NULL";
$CCH2id = "NULL";
$occurrenceID = "NULL";
$ALT_CCH_BARCODE = "";
#find duplicates
if ($old_AID !~ m/^ *$/){
	if ($duplicate{$old_AID}++){
	++$dups;
	#warn "Duplicate number: $old_AID\n";
	#&log_change("ACC: Old duplicate accession number found==>OLD:$old_AID NEW:$id GUID:$occurrenceID");
	#dont log this here as it will only print one of the two dups, this log should happen in the next step
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	#for example, the worst case is CAS520791, which has 17 specimens that were labeled with this number over the years.
	print OUT "$catalognumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\n"; 
	}
}



}

}


print <<EOP;
UNIQUE DUPS FOUND: $dups


EOP

close(IN);
close(OUT);












