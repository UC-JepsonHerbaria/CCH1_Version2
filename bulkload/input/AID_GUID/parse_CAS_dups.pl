
use strict;
#use warnings;
#use diagnostics;
use lib '../../Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev


my $today_JD = &CCH::get_today;
#my $today_JD = &get_today_julian_day;
$today_JD =~ s/ *PDT//;
warn "Today is $today_JD\n";

$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.

my $herb="CAS";

#my $dirdate = "2021_APR16";
my $dirdate="2021_AUG28";
#$filedate="11072019";
#my $filedate="12052019";
#my $filedate = "01292020";
#my $filedate = "04162021";
my $filedate="08282021";


my %month_hash = &CCH::month_hash;

#my $records_file='input/CAS/'.$dirdate.'/DWC-0006446-210819072339941.txt';
my $records_file='output/CAS_CONVERTED_'.$filedate.'-utf8.txt';
#only harvesting the CCH2 ID's and CCH1 ids from this file here


open(DUPLOG, ">input/AID_GUID/DUPS/dup_log_".$today_JD.".txt") || die; 
open(OUT, ">input/AID_GUID/DUPS/DUPS_".$herb.$today_JD.".txt") || die; #this only needs to be active once to generate a list of duplicated accessions

	print OUT "herb\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tGBIF_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tscientificName\tcounty\n";

#declare variables

#counts
my ($skipped, $included, %seen, %duplicate_FOUND_CAT, %duplicate_FOUND_OTH,@fields) = "";
my ($dups,$dups_B,$ALTER, $ORTH, %DUP_FOUND,%duplicate_OTH,%duplicate_CAT,$count_record) = "";


#out file variables for CCH2 compatibility
my ($CCHbarcode,$oldCCHID,$oldA,$old_AID) = "";

#CAS occid infile
my ($OC,$IC,$CO,$OCC,$CA,$OCA,%OCCID) = "";

####GBIF variables
my ($institutionCode, $id, $collectionCode, $ownerInstitutionCode, $basisOfRecord) = ""; #5
my ($rights,$informationWithheld,$dataGeneralizations,$dynamicProperties) = "";
my ($occurrenceID,$catalogNumber,$recordNumber,$recordedBy,$establishmentMeans) = "";
my ($occurrenceStatus,$associatedTaxa,$otherCatalogNumbers,$occurrenceRemarks) = "";
my ($eventDate,$year,$month,$day,$verbatimEventDate,$habitat,$eventRemarks) = "";
my ($country,$stateProvince,$verbatimCounty,$municipality,$locality,$verbatimLocality) = "";
my ($verbatimElevation,$elevation,$locationRemarks,$decimalLatitude,$decimalLongitude) = "";
my ($coordinateUncertaintyInMeters,$coordinatePrecision,$georeferencedBy) = "";
my ($georeferencedDate,$georeferenceSources,$georeferenceRemarks,$modified) = "";
my ($verbatimCoordinateSystem,$identificationQualifier,$typeStatus,$identifiedBy) = "";
my ($dateIdentified,$origdet,$elevation,$acceptedScientificName,$genus) = "";
my ($verbatimScientificName,$reproductiveCondition,$higherClassification) = "";

open (IN, "<", $records_file) or die $!;
Record: while(<IN>){
	chomp;

        if ($. == 1){#activate if need to skip header lines
			next Record;
		}
		

		my @fields=split(/\t/,$_,300);

		unless( $#fields == 50){  #if the number of values in the columns array is exactly 51

			warn "$#fields bad field number $_\n";

			next Record;
		}



($id,
$rights,
$institutionCode,
$informationWithheld,
$dataGeneralizations,
$dynamicProperties,
$occurrenceID,
$catalogNumber,
$recordNumber,
$recordedBy,
#10
$establishmentMeans,
$occurrenceStatus,
$associatedTaxa,
$otherCatalogNumbers,
$occurrenceRemarks,
$eventDate,
$year,
$month,
$day,
$verbatimEventDate,
#20
$habitat,
$eventRemarks,
$country, #countryCode in CAS
$stateProvince,
$verbatimCounty,
$municipality,
$locality,
$verbatimLocality,
$verbatimElevation,
$locationRemarks,
#30
$decimalLatitude,
$decimalLongitude,
$coordinateUncertaintyInMeters,
$coordinatePrecision,
$georeferencedBy,
$georeferencedDate,
$georeferenceSources,
$georeferenceRemarks,
$verbatimCoordinateSystem,
$identificationQualifier,
#40
$typeStatus,
$identifiedBy,
$dateIdentified,
$origdet,
$elevation,
$acceptedScientificName,
$verbatimScientificName,
$reproductiveCondition,
$higherClassification,
$genus,
#50
$modified
) = @fields;	#The array @fields is made up on these 51 scalars, in this order
#for GBIF Native


#filter by herbarium code
  if ($institutionCode =~ m/^CASC?$/){

	$institutionCode = "CAS";

printf {*STDERR} "%d\r", ++$count_record;


########ACCESSION NUMBER
#check for nulls
	if ($id=~/^ *$/){
		&CCH::log_skip("Record with no GBIF ID $_");
		++$skipped;
		next Record;
	}

#extract old herbarium and aid numbers

#urn:catalog:CAS:DS:418652 | DS 418652

	if ($otherCatalogNumbers =~ m/^(CAS|DS) *0*([1-9][0-9]*)$/){
		$oldCCHID = $1.$2;
		$oldA = "";
		$duplicate_OTH{$oldCCHID}++;
		#print "HERB(2)\t$oldCCHID\t$id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($otherCatalogNumbers =~ m/^(CAS|DS) *0*([1-9][0-9]*)([a-zA-Z]+)$/){
		$oldCCHID = $1.$2;
		$oldA = $1.$2.$3;
		$duplicate_OTH{$oldCCHID}++;
		#print "HERB(2)\t$oldCCHID\t$id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($otherCatalogNumbers =~ m/^urn:catalog:CAS:[BOTDS]+:\d+ *\| *(CAS|DS) *0*([1-9][0-9]*)$/){
		$oldCCHID = $1.$2;
		$oldA = "";
		$duplicate_OTH{$oldCCHID}++;
		#print "HERB(2)\t$oldCCHID\t$id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($otherCatalogNumbers =~ m/^urn:catalog:CAS:[BOTDS]+:\d+[a-zA-Z]+ *\| *(CAS|DS) *0*([1-9][0-9]*)([a-zA-Z]*)$/){
		$oldCCHID = $1.$2;
		$oldA = $1.$2.$3;
		$duplicate_OTH{$oldCCHID}++;
		#print "HERB(2)\t$oldCCHID\t$id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($otherCatalogNumbers =~ m/^(NULL| *)$/){
		$otherCatalogNumbers = "";
		$oldA = $oldCCHID="";
	}
	else{
		&CCH::log_change("BAD Accession==>$id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD otherCatalogNumbers==>$id==>$catalogNumber==>$otherCatalogNumbers\n";
		print DUPLOG "BAD otherCatalogNumbers==>$id==>$catalogNumber==>$otherCatalogNumbers\n";
		$otherCatalogNumbers = "";
		$oldA = $oldCCHID="";
	}


#construct catalog numbers
	if ($catalogNumber =~ m/^urn:catalog:CAS:BOT-BC:(\d+)$/){
		$CCHbarcode = $herb."-BOT".$1."-BARCODE";
		$duplicate_CAT{$CCHbarcode}++;#count to find duplicates
		#print "HERB(3)\t$CCHbarcode\t$id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($catalogNumber =~ m/^(\d+)$/){
		$CCHbarcode = $herb."-BOT".$1."-BARCODE";
		$duplicate_CAT{$CCHbarcode}++;#count to find duplicates
		#print "HERB(3)\t$CCHbarcode\t$id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$catalogNumber = "";
		$CCHbarcode="";
	}
	else{
		&CCH::log_change("BAD catalogNumber==>$id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD catalogNumber==>$id==>$catalogNumber==>$otherCatalogNumbers\n";
		print DUPLOG "BAD catalogNumber==>$id==>$catalogNumber==>$otherCatalogNumbers\n";
		$catalogNumber = "";
		$CCHbarcode="";
	}

   if (length ($catalogNumber) >= 1){
	if ($duplicate_CAT{$CCHbarcode} >= 2){
		$duplicate_FOUND_CAT{$CCHbarcode}++;
		++$dups;
	}
   }
  
   if (length ($otherCatalogNumbers) >= 1){
	if ($duplicate_OTH{$oldCCHID} >= 2){
		$duplicate_FOUND_OTH{$oldCCHID}++;
		++$dups;
	}
   }

  }
}
#for testing
	#foreach $ALT_CCH_BARCODE (sort keys %duplicate_CAT) {
    #printf "%-31s %s\n", $ALT_CCH_BARCODE, $duplicate_CAT{$ALT_CCH_BARCODE} if ($duplicate_CAT{$ALT_CCH_BARCODE} >= 2);
	#}

  #foreach $oldCCHID (sort keys %duplicate_OTH) {
  #  printf "%-31s %s\n", $oldCCHID, $duplicate_OTH{$oldCCHID} if ($duplicate_OTH{$oldCCHID} >= 2);
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

#declare variables

#counts
my ($skipped, $included, %seen) = "";
my ($dups,$dups_B,$ALTER, $ORTH, $count_record) = "";

#out file variables for CCH2 compatibility
my ($CCHbarcode,$oldCCHID,$oldA,$old_AID) = "";

####GBIF variables
my ($institutionCode, $id, $collectionCode, $ownerInstitutionCode, $basisOfRecord) = ""; #5
my ($rights,$informationWithheld,$dataGeneralizations,$dynamicProperties) = "";
my ($occurrenceID,$catalogNumber,$recordNumber,$recordedBy,$establishmentMeans) = "";
my ($occurrenceStatus,$associatedTaxa,$otherCatalogNumbers,$occurrenceRemarks) = "";
my ($eventDate,$year,$month,$day,$verbatimEventDate,$habitat,$eventRemarks) = "";
my ($country,$stateProvince,$verbatimCounty,$municipality,$locality,$verbatimLocality) = "";
my ($verbatimElevation,$elevation,$locationRemarks,$decimalLatitude,$decimalLongitude) = "";
my ($coordinateUncertaintyInMeters,$coordinatePrecision,$georeferencedBy) = "";
my ($georeferencedDate,$georeferenceSources,$georeferenceRemarks,$modified) = "";
my ($verbatimCoordinateSystem,$identificationQualifier,$typeStatus,$identifiedBy) = "";
my ($dateIdentified,$origdet,$elevation,$acceptedScientificName,$genus) = "";
my ($verbatimScientificName,$reproductiveCondition,$higherClassification) = "";

open (IN, "<", $records_file) or die $!;
Record: while(<IN>){
	chomp;

        if ($. == 1){#activate if need to skip header lines
			next Record;
		}
		

		my @fields=split(/\t/,$_,300);

		unless( $#fields == 50){  #if the number of values in the columns array is exactly 51

			warn "$#fields bad field number $_\n";

			next Record;
		}


		++$count_record;


($id,
$rights,
$institutionCode,
$informationWithheld,
$dataGeneralizations,
$dynamicProperties,
$occurrenceID,
$catalogNumber,
$recordNumber,
$recordedBy,
#10
$establishmentMeans,
$occurrenceStatus,
$associatedTaxa,
$otherCatalogNumbers,
$occurrenceRemarks,
$eventDate,
$year,
$month,
$day,
$verbatimEventDate,
#20
$habitat,
$eventRemarks,
$country, #countryCode in CAS
$stateProvince,
$verbatimCounty,
$municipality,
$locality,
$verbatimLocality,
$verbatimElevation,
$locationRemarks,
#30
$decimalLatitude,
$decimalLongitude,
$coordinateUncertaintyInMeters,
$coordinatePrecision,
$georeferencedBy,
$georeferencedDate,
$georeferenceSources,
$georeferenceRemarks,
$verbatimCoordinateSystem,
$identificationQualifier,
#40
$typeStatus,
$identifiedBy,
$dateIdentified,
$origdet,
$elevation,
$acceptedScientificName,
$verbatimScientificName,
$reproductiveCondition,
$higherClassification,
$genus,
#50
$modified
) = @fields;	#The array @fields is made up on these 51 scalars, in this order
#for GBIF Native


#filter by herbarium code
  if ($institutionCode =~ m/^CASC?$/){

	$institutionCode = "CAS";


printf {*STDERR} "%d\r", ++$count_record;


########ACCESSION NUMBER
#check for nulls
	if ($id=~/^ *$/){
		&CCH::log_skip("Record with no GBIF ID $_");
		++$skipped;
		next Record;
	}

#extract old herbarium and aid numbers

#urn:catalog:CAS:DS:418652 | DS 418652

	if ($otherCatalogNumbers =~ m/^(CAS|DS) *0*([1-9][0-9]*)$/){
		$oldCCHID = $1.$2;
		$oldA = "";
	}
	elsif ($otherCatalogNumbers =~ m/^(CAS|DS) *0*([1-9][0-9]*)([a-zA-Z]+)$/){
		$oldCCHID = $1.$2;
		$oldA = $1.$2.$3;
	}
	elsif ($otherCatalogNumbers =~ m/^urn:catalog:CAS:[BOTDS]+:\d+ *\| *(CAS|DS) *0*([1-9][0-9]*)$/){
		$oldCCHID = $1.$2;
		$oldA = "";
	}
	elsif ($otherCatalogNumbers =~ m/^urn:catalog:CAS:[BOTDS]+:\d+[a-zA-Z]+ *\| *(CAS|DS) *0*([1-9][0-9]*)([a-zA-Z]*)$/){
		$oldCCHID = $1.$2;
		$oldA = $1.$2.$3;
	}
	elsif ($otherCatalogNumbers =~ m/^(NULL| *)$/){
		$otherCatalogNumbers = "";
		$oldA = $oldCCHID="";
	}
	else{
		$otherCatalogNumbers = "";
		$oldA = $oldCCHID="";
	}


#construct catalog numbers
	if ($catalogNumber =~ m/^urn:catalog:CAS:BOT-BC:(\d+)$/){
		$CCHbarcode = $herb."-BOT".$1."-BARCODE";
	}
	elsif ($catalogNumber =~ m/^(\d+)$/){
		$CCHbarcode = $herb."-BOT".$1."-BARCODE";
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$catalogNumber = "";
		$CCHbarcode="";
	}
	else{
		$catalogNumber = "";
		$CCHbarcode="";
	}


#exclude ALL duplicates 
	if ($duplicate_FOUND_OTH{$oldCCHID}) {
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	#for example, the worst case is CAS520791, which has 17 specimens that were labeled with this number over the years.
		print OUT "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$id\t$oldCCHID\t$CCHbarcode\t$oldA\tDUP\t$occurrenceID\t$verbatimScientificName\t$verbatimCounty\n";
		++$dups_B;
	}
	
	if ($duplicate_FOUND_CAT{$CCHbarcode}) {
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	#for example, the worst case is CAS520791, which has 17 specimens that were labeled with this number over the years.
		print OUT "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$id\t$oldCCHID\t$CCHbarcode\t$oldA\tDUP\t$occurrenceID\t$verbatimScientificName\t$verbatimCounty\n";
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