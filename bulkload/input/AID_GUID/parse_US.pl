
use strict;
#use warnings;
#use diagnostics;
use lib '../../../Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev
my $today_JD = &get_today_julian_day;

open(BULKLOG, ">>../../output/CCH2_bulkload_log_".$today_JD.".txt") || die; 


$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.

my $herb="US";

my $dirdate="2022_APR28";

my $filedate="04282022";


my %month_hash = &month_hash;


#declare variables

#counts
my ($skipped, $included, %seen, %duplicate_FOUND_CAT, %duplicate_FOUND_OTH) = "";
my ($dups,$dups_B,$ALTER, $ORTH, %DUP_FOUND,%duplicate_OTH,%duplicate_CAT) = "";
my ($count_record,@fields,$null) = "";

#out file variables for CCH2 compatibility
my ($ALT_CCH_BARCODE,$oldA,$old_AID) = "";

#HUH occid infile
my ($OC,$IC,$CO,$OCC,$CA,$OCA,%OCCID) = "";

#HUH dup infile
my ($HN,$CN,$OCN,$GID,$old,$bar,$alt,$stat,$GUID,$SCN,$VC,%DUP) = "";

#HUH IN file
my ($institutionCode, $CCH2id, $collectionCode, $ownerInstitutionCode, $basisOfRecord) = ""; #5
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
my ($collId, $recordId, $references,$dateflag,$eventDate_parse) = "";#83
my ($accessRights,$subgenus,$higherClassification,$collectionID,$verbatimTaxonRank) = "";
my ($rightsHolder,$rights,$associatedOccurrences,$eventID,$associatedSequences,$origDetName) = "";
my ($elevationInFeet,$CCH_elevationWarning,$elevationInMeters,$county,$decimalLatitude) = "";
my ($decimalLongitude,$EJD,$LJD,$verbatimDate,$origDet,$displayName) = "";#
my ($oldCCHID,$hybrid_formula,$id,$hybrid_formula,$qualifier,$CCHbarcode) = "";


#herb	CCH2_catalogNumber	CCH2_otherCatalogNumbers	GBIF_ID	OLD_CCH_AID	ALT_CCH_ID	ALT_CCH_AID_SPACE	Status	GUID-occurrenceID	scientificName	county
#CAS	616749	CAS 800069	2239722878	CAS800069	CAS-BOT616749 BARCODE		DUP	urn:catalog:CAS:BOT-BC:616749	Marah oregana (Torr. & A.Gray) Howell	Mendocino


open(IN, "DUPS/DUPS_".$herb.$filedate.".txt") || die;
#open(IN, "DUPS/DUPS_CAS-BOT.txt") || die;

local($/)="\n";
while(<IN>){
	chomp;
	($HN,$CN,$OCN,$GID,$old,$bar,$alt,$stat,$GUID,$SCN,$VC)=split(/\t/);
		#GID is not the GBIF ID, it is the guid for all GBIF downloads
		$DUP{$GID}++;
}

close(IN);



#InstitutionCode	occid	occurrenceID	catalogNumber	otherCatalogNumbers	Sciname	tidinterpreted	taxonRemarks	identificationQualifier	identifiedBy	dateIdentified	identificationRemarks	typeStatus	recordedBy	associatedCollectors	recordNumber	year	month	day	verbatimEventDate	country	stateProvince	county	locality	locationRemarks	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	verbatimCoordinates	verbatimEventDate	georeferencedBy	georeferenceSources	georeferenceRemarks	minimumElevationInMeters	maximumElevationInMeters	verbatimElevation	habitat	occurrenceRemarks	associatedTaxa	verbatimAttributes	reproductiveCondition	cultivationStatus	dateLastModified

open(OUT3, ">>DUPS/DUPS_to_be_excluded_".$today_JD.".txt") || die;
open(OUT2, ">>output/AID_to_ADD_".$today_JD.".txt") || die;

print OUT2 "herbcode\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tCCH_BARCODE_ID\tALT_CCH_AID\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";
print OUT3 "herbcode\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tCCH_BARCODE_ID\tALT_CCH_AID\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";

my $mainFile='../../output/US-CCH2_out_'.$filedate.'.txt';
#only harvesting the CCH2 ID's and CCH1 ids from this file here
open (IN, "<", $mainFile) or die $!;
Record: while(<IN>){
	chomp;

        if ($. == 1){#activate if need to skip header lines
			next Record;
		}
		

		my @fields=split(/\t/,$_,100);

		unless($#fields == 46){  #if the number of values in the columns array is exactly 47, this is for Darwin Core

			warn "$#fields bad field number $_\n";

			next Record;
		}

		($CCH2id,
		$institutionCode,
		$catalogNumber,
		$otherCatalogNumbers,
		$CCHbarcode,
		$oldCCHID,
		$occurrenceID,
		$scientificName,
		$displayName,
		$origDet,
		$hybrid_formula,
		$qualifier,
		$identifiedBy,
		$dateIdentified,
		$identificationRemarks,
		$typeStatus,
		$recordedBy,
		$recordNumber,
		$verbatimDate,
		$eventDate_parse,
		$EJD,
		$LJD,
		$country,
		$stateProvince,
		$verbatimCounty,
		$locality,
		$occurrenceRemarks,
		$habitat,
		$associatedTaxa,
		$verbatimAttributes,
		$reproductiveCondition,
		$cultivationStatus,
		$CCH_elevationWarning,
		$elevationInMeters,
		$elevationInFeet,
		$verbatimElevation,
		$verbatimCoordinates,
		$decimalLatitude,
		$decimalLongitude,
		$geodeticDatum,
		$coordinateUncertaintyInMeters,
		$georeferencedBy,
		$georeferenceSources,
		$georeferenceRemarks,
		$modified,
		$dateflag,
		$county
		) = @fields;	
#The array @fields is made up on these 47 scalars, in this order, GBIF modified export

#The array @fields is made up on these 85 scalars, in this order, for Darwin Core
#The array @fields is made up on these 91 scalars, in this order, for Symbiota Native


#filter by herbarium code
  if ($institutionCode =~ m/^(US)$/){


printf {*STDERR} "%d\r", ++$count_record;


########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped;
		next Record;
	}

#extract old herbarium and aid numbers

	if ($oldCCHID =~ m/^(US) *([0-9]+)[a-zA-Z]*$/){
		$oldCCHID = $1.$2;
		$duplicate_OTH{$oldCCHID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^(NULL| *)$/){
		$otherCatalogNumbers = "";
		$oldCCHID="";
	}
	else{
		$otherCatalogNumbers = "";
		$oldCCHID="";
	}


#construct catalog numbers
	if ($CCHbarcode =~ m/^(US)([0-9]+)[a-zA-Z]*(-BARCODE)$/){
		$CCHbarcode = $1.$2.$3;
	}
	elsif ($CCHbarcode =~ m/^(NULL| *)$/){
		$catalogNumber = "";
		$CCHbarcode="";
	}
	else{
		$catalogNumber = "";
		$CCHbarcode="";
	}
   
   if (($catalogNumber =~ m/^ *$/) && ($otherCatalogNumbers =~ m/^ *$/)){
		&log_skip("$herb ALL AIDs NULL: $CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");	#run the &log_skip function, printing the following message to the error log
		++$null;
		next Record;
   }
   else{
#Remove duplicate
	if($DUP{$CCH2id}){
		print OUT3 "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$oldCCHID\t$CCHbarcode\t\tDUP\t$occurrenceID\t$scientificName\t$verbatimCounty\n";
#print "EXCL $old_AID\n";
++$dups;
	}
	else{
		print OUT2 "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$oldCCHID\t$CCHbarcode\t\tNONDUP\t$occurrenceID\t$scientificName\t$verbatimCounty\n";
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