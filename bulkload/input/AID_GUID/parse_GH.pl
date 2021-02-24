
#use strict;
#use warnings;
#use diagnostics;
use lib '/Users/Shared/Jepson-Master/Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

my $today_JD;

$herb="HUH";
#$filedate="11072019";
$filedate="09272017";

#CCH2_catalogNumber	CCH2_otherCatalogNumbers	CCH2_ID	OLD_CCH_AID	ALT_CCH_ID	ALT_CCH_AID_SPACE	Status	GUID-occurrenceID

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


#this herb is first on the list, so it opens a new file for these two, while all others append
open(OUT3, ">>/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_excluded.txt") || die;
open(OUT2, ">>/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/output/AID_to_ADD.txt") || die;

print OUT2 "CCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";
print OUT3 "CCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";



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

$name=&strip_name($scientificname);

$otherCatalogNumbers = "NULL";
$CCH2id = "NULL";
$occurrenceID = "NULL";
$ALT_CCH_BARCODE = "";

if (($catalognumber =~ m/^ *$/) && ($catalognumbernumeric =~ m/^ *$/)){
		&log_skip("$herb ALL AIDs NULL: $CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");	#run the &log_skip function, printing the following message to the error log
		++$null;
		next Record;
}
else{
#Remove duplicates
	if($DUP{$old_AID}){
		print OUT3 "$catalognumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\t$name\t$county\n";
#print "EXCL $old_AID\n";
++$dups;
	}
	else{
		print OUT2 "$catalognumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tNONDUP\t$occurrenceID\t$name\t$county\n";
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
