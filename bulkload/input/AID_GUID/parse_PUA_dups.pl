
#use strict;
#use warnings;
#use diagnostics;
use lib '/Users/Shared/Jepson-Master/Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev
my $today_JD;
$today_JD = &get_today_julian_day;

#$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.
$herb="PUA";
#$filedate="11072019";
#$filedate="12052019";
$filedate="01292020";



&load_noauth_name; #loads taxon id master list into an array

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


open(OUT, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_".$herb."_list.txt") || die; #this only needs to be active once to generate a list of duplicated accessions

	print OUT "CCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\n";



#id	type	modified	language	institutionCode	collectionCode	basisOfRecord	occurrenceID	catalogNumber	occurrenceRemarks	recordNumber	recordedBy	otherCatalogNumbers	eventDate	startDayOfYear	year	month	day	verbatimEventDate	habitat	higherGeography	continent	country	stateProvince	county	municipality	locality	verbatimElevation	minimumElevationInMeters	maximumElevationInMeters	verbatimLatitude	verbatimLongitude	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	georeferenceProtocol	georeferenceVerificationStatus	identifiedBy	dateIdentified	typeStatus	scientificName	higherClassification	kingdom	phylum	class	order	family	genus	specificEpithet	infraspecificEpithet	verbatimTaxonRank	scientificNameAuthorship	nomenclaturalCode
my $mainFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/CCH2-exports/CCH2_export_'.$filedate.'.txt';
open (IN, $mainFile) or die $!;
Record: while(<IN>){
	chomp;

	
#fix some data quality and formatting problems that make import of fields of certain records problematic
	
    if ($. == 1){#activate if need to skip header lines
			next Record;
		}



		my @fields=split(/\t/,$_,100);

    unless( $#fields == 42){ #if the number of values in the columns array is exactly 43
	#skip these in this and all future files, but do not log them again.
	#&CCH::log_skip("$#fields bad field number $_\n"); 
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

	($institutionCode,
	$CCH2id,
	$occurrenceID,
	$catalogNumber,
	$otherCatalogNumbers,
	$scientificName,
	$symTID,
	$taxonRemarks,
	$identificationQualifier,
	$identifiedBy, #10
	$dateIdentified,
	$identificationRemarks,
	$typeStatus,
	$recordedBy,
	$associatedCollectors,
	$recordNumber,
	$year, 	
	$month, 
	$day, 
	$verbatimEventDate,#20
	$country,
	$stateProvince,
	$county,
	$locality,
	$locationRemarks,
	$decimalLatitude, 
	$decimalLongitude, 
	$datum,
	$coordinateUncertaintyInMeters,
	$verbatimCoordinates,#30
	$georeferencedBy,
	$georeferenceSources,
	$georeferenceRemarks,
	$minimumElevationInMeters,
	$maximumElevationInMeters,
	$verbatimElevation,
	$habitat,
	$occurrenceRemarks, 
	$associatedTaxa,#40
#maximumElevationInMeters	verbatimElevation	habitat	occurrenceRemarks	associatedTaxa	40
	$verbatimAttributes,
	$reproductiveCondition,
	$cultivationStatus,
	$dateLastModified
#verbatimAttributes	reproductiveCondition	cultivationStatus	dateLastModified	43
	)=@fields;

#parse only selected specimens
if ($institutionCode =~ m/^PUA$/){


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
#MCCC has nothing in othercatalogNumbers, they also never had records in CCH1
#no records will be found using the old_AID
if (length ($otherCatalogNumbers) >= 1){
	if ($otherCatalogNumbers =~ m/NULL/){
		$otherID="";
		$herbcode="";
		$otherCatalogNumbers = "";
		$old_AID="";
	}
	else{
		&CCH::log_change("BAD Accession==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$otherID="";
		$herbcode="";
		$otherCatalogNumbers = "";
		$old_AID="";
	}
}
else{
		$otherID="";
		$herbcode="";
		$otherCatalogNumbers = "";
		$old_AID="";
}

#construct catalog numbers
if (length ($catalogNumber) >= 1){
	if ($catalogNumber =~ m/^PUA(\d+)$/){
		$aid=$1;
		$aidcode=$herb;
		$ALT_CCH_BARCODE = $aidcode.$aid;
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/^(\d+)$/){
		$aid=$1;
		$aidcode=$herb;
		$ALT_CCH_BARCODE = $aidcode.$aid;
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/NULL/){
		if (($catalogNumber =~ m/NULL/) && ($otherCatalogNumbers =~ m/^ *$/)){
			$aid = $CCH2id;
			$aidcode = $herb;
			$ALT_CCH_BARCODE = $aidcode.$aid;
		}
		else{
			$aid="";
			$aidcode="";
			$catalogNumber = "";
			$ALT_CCH_BARCODE = "";	
		}	
	}
	else{
		&CCH::log_change("BAD catalogNumber(2)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD catalogNumber(2)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$aid="";
		$aidcode="";
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
	}
}
else{
	$aid="";
	$aidcode="";
	$catalogNumber = "";
	$ALT_CCH_BARCODE = "";	
}
#Add prefix to unique identifier field, two format, choose one and add to the code above
#$ALT_CCH_BARCODE=$aidcode.$aid;
#$ALT_CCH_BARCODE=$herb.$catalogNumber;
#$ALT_CCH_BARCODE=$catalogNumber; #use this format if the old CCH herbarium code is correctly added in the catalog number field


if ($old_AID =~ m/^ *$/){
	$old_AID = $ALT_CCH_BARCODE;
}

my $/oldA="";

#find duplicates
if ($ALT_CCH_BARCODE !~ m/^ *$/){
	if($duplicate{$ALT_CCH_BARCODE}++){#check for dups here as othercatnum is empty
	++$dups;
	#warn "Duplicate number: $old_AID\n";
	#&log_change("ACC: Old duplicate accession number found==>OLD:$old_AID NEW:$id GUID:$occurrenceID");
	#dont log this here as it will only print one of the two dups, this log should happen in the next step
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	#for example, the worst case is CAS520791, which has 17 specimens that were labeled with this number over the years.
	print OUT "$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\n";
	}
}



}

}


print <<EOP;
UNIQUE DUPS FOUND: $dups


EOP

close(IN);
close(OUT);
