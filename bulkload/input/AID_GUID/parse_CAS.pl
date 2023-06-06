
use strict;
#use warnings;
#use diagnostics;
use lib '../../Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

my $today_JD = &CCH::get_today;
#my $today_JD = &get_today_julian_day;
$today_JD =~ s/ *PDT//;

open(BULKLOG, ">>output/CCH2_bulkload_log_".$today_JD.".txt") || die; 


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

#declare variables

#counts
my ($skipped, $included, %seen, %duplicate_FOUND_CAT, %duplicate_FOUND_OTH) = "";
my ($dups,$dups_B,$ALTER, $ORTH, %DUP_FOUND,%duplicate_OTH,%duplicate_CAT) = "";
my ($count_record,@fields,$null) = "";

#out file variables for CCH2 compatibility
my ($CCHbarcode,$oldCCHID,$oldA,$old_AID) = "";

#CAS occid infile
my ($OC,$IC,$CO,$OCC,$CA,$OCA,%OCCID) = "";

#CAS dup infile
my ($HN,$CN,$OCN,$GID,$old,$bar,$alt,$stat,$GUID,$SCN,$VC,%DUP) = "";

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


#herb	CCH2_catalogNumber	CCH2_otherCatalogNumbers	GBIF_ID	OLD_CCH_AID	ALT_CCH_ID	ALT_CCH_AID_SPACE	Status	GUID-occurrenceID	scientificName	county
#CAS	616749	CAS 800069	2239722878	CAS800069	CAS-BOT616749 BARCODE		DUP	urn:catalog:CAS:BOT-BC:616749	Marah oregana (Torr. & A.Gray) Howell	Mendocino


#CAS is first on the list, so it opens a new file for these two, while all others append
open(OUT3, ">input/AID_GUID/DUPS/DUPS_to_be_excluded_".$today_JD.".txt") || die;
open(OUT2, ">input/AID_GUID/output/AID_to_ADD_".$today_JD.".txt") || die;

print OUT2 "herbcode\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tCCH_BARCODE_ID\tALT_CCH_AID\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";
print OUT3 "herbcode\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tCCH_BARCODE_ID\tALT_CCH_AID\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";


open(IN, "input/AID_GUID/DUPS/DUPS_".$herb.$today_JD.".txt") || die;
 
local($/)="\n";
while(<IN>){
	chomp;
	($HN,$CN,$OCN,$GID,$old,$bar,$alt,$stat,$GUID,$SCN,$VC)=split(/\t/);

		$DUP{$GID}++;
}

close(IN);


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

   
   if (($catalogNumber =~ m/^ *$/) && ($otherCatalogNumbers =~ m/^ *$/)){
		&log_skip("$herb ALL AIDs NULL: $id==>$catalogNumber==>$otherCatalogNumbers\t$_");	#run the &log_skip function, printing the following message to the error log
		++$null;
		next Record;
   }
   else{
#Remove duplicate
	if($DUP{$id}){#excludes based on the CAS GUID 
		print OUT3 "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$occurrenceID\t$oldCCHID\t$CCHbarcode\t$oldA\tDUP\t$occurrenceID\t$verbatimScientificName\t$verbatimCounty\n";
#print "EXCL $old_AID\n";
++$dups;
	}
	else{
#do not use CCH2ID or GBIFID for GBIF harvested records, 
#replace CCH2id with occurrenceID
		print OUT2 "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$occurrenceID\t$oldCCHID\t$CCHbarcode\t$oldA\tNONDUP\t$occurrenceID\t$verbatimScientificName\t$verbatimCounty\t$modified\n";
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

print BULKLOG <<EOP;
$herb INCL: $included
$herb DUPS: $dups
$herb NULL: $null

$herb TOTAL: $count_record

EOP


close(IN);
close(OUT2);
close(OUT3);
close(BULKLOG);