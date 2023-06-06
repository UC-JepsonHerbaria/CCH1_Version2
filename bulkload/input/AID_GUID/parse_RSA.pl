
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
my $herb = "RSA";

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


my %month_hash = &CCH::month_hash;


#declare variables
#counts
my ($skipped, $included, %seen, %DUP,$count_record,$dups,$null) = "";

#out file variables for CCH2 compatibility
my ($CCH2id,$ALT_CCH_BARCODE,$oldA,$old_AID) = "";

#DUPs IN file
my ($HN,$CN,$OCN,$GID,$old,$bar,$alt,$stat,$GUID,$SCN,$VC) = "";

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
my ($locationID,$continent,$waterBody,$islandGroup,$island,$eventDate2) = "";


open(IN, "input/AID_GUID/DUPS/DUPS_".$herb.$today_JD.".txt") || die;
 
local($/)="\n";
while(<IN>){
	chomp;
	($HN,$CN,$OCN,$GID,$old,$bar,$alt,$stat,$GUID,$SCN,$VC)=split(/\t/);

		$DUP{$GID}++;
}

close(IN);


#CAS is first on the list, so it opens a new file for these two, while all others append
open(OUT3, ">>input/AID_GUID/DUPS/DUPS_to_be_excluded_".$today_JD.".txt") || die;
open(OUT2, ">>input/AID_GUID/output/AID_to_ADD_".$today_JD.".txt") || die;

#print OUT2 "herbcode\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tCCH_BARCODE_ID\tALT_CCH_AID\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";
#print OUT3 "herbcode\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tCCH_BARCODE_ID\tALT_CCH_AID\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";

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
		#unless( $#fields == 90){  #if the number of values in the columns array is exactly 91, this is for Darwin Core
		unless( $#fields == 96){  #if the number of values in the columns array is exactly 97, this is for Darwin Core

			#warn "$#fields bad field number $_\n";

			next Record;
		}

#id	institutionCode	collectionCode	ownerInstitutionCode	basisOfRecord	
#occurrenceID	catalogNumber	otherCatalogNumbers	higherClassification	kingdom	
($CCH2id,
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
#phylum	class	order	family	scientificName	taxonID	scientificNameAuthorship	
#genus	subgenus	specificEpithet	
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
#verbatimTaxonRank	infraspecificEpithet	taxonRank	identifiedBy	dateIdentified	
#identificationReferences	identificationRemarks	taxonRemarks	identificationQualifier	
#typeStatus	
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
#recordedBy	associatedCollectors	recordNumber	eventDate	eventDate2	
#year	month	day	startDayOfYear	endDayOfYear	
$recordedBy,
$associatedCollectors, #This is in Symbiota Native and not Darwin Core
$recordNumber,
$eventDate,
$eventDate2,
$year,
$month,
$day,
$startDayOfYear,
$endDayOfYear,
#40
#verbatimEventDate	occurrenceRemarks	habitat	substrate	verbatimAttributes	
#fieldNumber	eventID	informationWithheld	dataGeneralizations	dynamicProperties	
$verbatimEventDate,
$occurrenceRemarks,
$habitat,
$substrate, #This is in Symbiota Native and not Darwin Core
$verbatimAttributes, #This is in Symbiota Native and not Darwin Core
$fieldNumber,
$eventID, #This is in Symbiota Native and not Darwin Core
$informationWithheld,
$dataGeneralizations,
$dynamicProperties,
#50
#associatedOccurrences	associatedSequences	associatedTaxa	reproductiveCondition	
#establishmentMeans	cultivationStatus	lifeStage	sex	individualCount	preparations	
$associatedOccurrences,
$associatedSequences, #This is in Symbiota Native and not Darwin Core
$associatedTaxa,
$reproductiveCondition,
$establishmentMeans,
$cultivationStatus, #This is in Symbiota Native and not Darwin Core
$lifeStage,
$sex,
$individualCount,
$preparations,
#60
#locationID	continent	waterBody	islandGroup	island	country
#stateProvince	county	municipality	locality	
$locationID,
$continent,
$waterBody,
$islandGroup,
$island,
$country,
$stateProvince,
$verbatimCounty,
$municipality,
$locality,
#70
#locationRemarks	localitySecurity	localitySecurityReason	
#decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	
#verbatimCoordinates	georeferencedBy	georeferenceProtocol	
$locationRemarks,
$localitySecurity, #This is in Symbiota Native and not Darwin Core
$localitySecurityReason, #This is in Symbiota Native and not Darwin Core
$latitude,
$longitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,
$georeferenceProtocol,
#80
#georeferenceSources	georeferenceVerificationStatus	georeferenceRemarks
#minimumElevationInMeters	maximumElevationInMeters	minimumDepthInMeters	
#maximumDepthInMeters	verbatimDepth	verbatimElevation	disposition	
$georeferenceSources,
$georeferenceVerificationStatus,
$georeferenceRemarks,
$minimumElevationInMeters,
$maximumElevationInMeters,
$minimumDepthInMeters,
$maximumDepthInMeters,
$verbatimDepth,
$verbatimElevation,
$disposition,
#90
#language	recordEnteredBy	modified	sourcePrimaryKey-dbpk	collID	recordID	
#references
$language,
$recordEnteredBy,
$modified,
$sourcePrimaryKey, #This is in Symbiota Native and not Darwin Core
$collId, #This is in Symbiota Native and not Darwin Core
$recordId,
$references	
) = @fields;	
#The array @fields is made up on these 85 scalars, in this order, for Darwin Core
#The array @fields is made up on these 91 scalars, in this order, for Symbiota Native
#The array @fields is made up on these 97 scalars, in this order, for Symbiota Native


#filter by herbarium code
  if ($institutionCode =~ m/^RSA$/){


#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;


########ACCESSION NUMBER
#check for nulls
	if ($CCH2id =~ m/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped;
		next Record;
	}
	
	$collectionCode=~ s/^Vascular *Plants$/RSA/i;
	
	$otherCatalogNumbers =~ s/ +[acesion]+ *\#: */ accession: /i;
	$otherCatalogNumbers =~ s/ +[acesion]+ *: */ accession: /i;

	$otherCatalogNumbers =~ s/(POM|RSA) accession +/$1 accession: /i;
	$otherCatalogNumbers =~ s/(POM|RSA) accession: +/$1 accession: /i;
	$otherCatalogNumbers =~ s/(POM|RSA) Accession: +/$1 accession: /;
	$otherCatalogNumbers =~ s/(POM|RSA) accession: +/$1 accession: /i;
	$otherCatalogNumbers =~ s/(POM|RSA) accession (\d)/$1 accession: $2/i;
	$otherCatalogNumbers =~ s/(POM|RSA) accession (\d)/$1 accession: $2/i;
#RSA accession #: RSA2722
	$otherCatalogNumbers =~ s/(POM|RSA) accession *: *(POM|RSA)(\d)/$1 accession: $3/i;
	
#extract old herbarium and aid numbers
if (length ($otherCatalogNumbers) >= 1){


		$otherCatalogNumbers =~ s/`+//;
		$otherCatalogNumbers =~ s/\.$//;


	if ($otherCatalogNumbers =~ m/^(POM) *[acesion]+ *: *(0+)([1-9][0-9]*)([A-Za-z]*); .*$/){
		$old_AID = $1.$3;
		$oldA = $1.$2.$3.$4;
	}
	elsif ($otherCatalogNumbers =~ m/^(POM) *[acesion]+ *: *([1-9][0-9]*)([A-Za-z]*); .*$/){
		$old_AID = $1.$2;
		$oldA = $1.$2.$3;
	}
	elsif ($otherCatalogNumbers =~ m/^(POM) *[acesion]+ *: *([1-9][0-9]*)([A-Za-z]*)$/){
		$old_AID = $1.$2;
		$oldA = $1.$2.$3;
	}
	elsif ($otherCatalogNumbers =~ m/^(RSA) *[acesion]+ *: *(0+)([1-9][0-9]*)([A-Za-z]*); .*$/){
		$old_AID = $1.$3;
		$oldA = $1.$2.$3.$4;
	}
	elsif ($otherCatalogNumbers =~ m/^(RSA) *[acesion]+ *: *([1-9][0-9]*)([A-Za-z]*); .*$/){
		$old_AID = $1.$2;
		$oldA = $1.$2.$3;
	}
	elsif ($otherCatalogNumbers =~ m/^(RSA) *[acesion]+ *: *([1-9][0-9]*)([A-Za-z]*)$/){
		$old_AID = $1.$2;
		$oldA = $1.$2.$3;
	}
	elsif ($otherCatalogNumbers =~ m/^living.+; *(RSA|POM) *[acesion]+ *: *([1-9][0-9]*)([A-Za-z]*)$/){
		$old_AID = $1.$2;
		$oldA = $1.$2.$3;
	}
	elsif ($otherCatalogNumbers =~ m/^[Pp]rop.+; *(RSA|POM) *[acesion]+ *: *([1-9][0-9]*)$/){
		$old_AID = $1.$2;
		$oldA = "";
	}
	elsif ($otherCatalogNumbers =~ m/^(RSA|POM) *[acesion]+ *: *(0+)([1-9][0-9]+)$/){
		$old_AID = $1.$3;
		$oldA = $1.$2.$3;
	}
	elsif ($otherCatalogNumbers =~ m/^([1-9][0-9]*)[A-Za-z]*; .*$/){
		$old_AID = $collectionCode.$1;
		$oldA = "";
	}
	elsif ($otherCatalogNumbers =~ m/^([1-9][0-9]*)[A-Za-z]*$/){
		$old_AID = $collectionCode.$1;
		$oldA = "";
	}
	elsif ($otherCatalogNumbers =~ m/^ *$/){
		$otherCatalogNumbers = "";
		$oldA = $old_AID = "";
	}
	else{
		$otherCatalogNumbers = "";
		$oldA = $old_AID = "";
	}
   }
   else{
		$otherCatalogNumbers = "";
		$oldA = $old_AID = "";
   }

	
#construct catalog numbers
#catalog numbers are RSA barcodes and these have leading zeros
#skip removing leading zeros, as this is new and I think we can skip any linked resources that use the barcodes without leading zeros
#they probably were not added to CCH1 without zeros anyway,  If they were, it was by mistake
#construct catalog numbers
   if (length ($catalogNumber) >= 1){

		if ($catalogNumber =~ m/^(rsa)(\d+)$/){
			&CCH::log_change("BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
			$catalogNumber = "RSA".$2; #fix some lack of capitalizations in IRVC accessions
		}

	if ($catalogNumber =~ m/^(RSA)(0*[1-9][0-9]*)$/){
		$ALT_CCH_BARCODE = $1.$2."-BARCODE";
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
	}
	else{
		#RSA has some special cases where as long as the barcode has errors, 
		#then we use the old RSA accession number
		if ($CCH2id =~ m/^(1007683|1007683|1108773|1138576|3831359|3894242|4129414)$/){
			if ($otherCatalogNumbers =~ m/^(RSA|POM) *accession *\#: *([1-9][0-9]*)$/){
				$old_AID = $1.$2;
				$ALT_CCH_BARCODE = "";
				$oldA = "";
			}
			else{
				print "BAD otherCatalogNumbers(1)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
				$ALT_CCH_BARCODE = "";
				$oldA = $old_AID = "";
			}
		}
		elsif ($CCH2id =~ m/^(666328|725329|795125|908414|917353|939018)$/){
			if ($otherCatalogNumbers =~ m/^(POM|RSA) *accession *\#: *([1-9][0-9]*)$/){
				$old_AID = $1.$2;
				$ALT_CCH_BARCODE = "";
				$oldA = "";
			}
			else{
				print "BAD otherCatalogNumbers(2)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
				$ALT_CCH_BARCODE = "";
				$oldA = $old_AID = "";
			}
		}
		else{
			&CCH::log_change("BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
			print "BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
			$catalogNumber = "";
			$ALT_CCH_BARCODE = "";
		}
	}
   }
   else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
   }
   
   
   if (($catalogNumber =~ m/^ *$/) && ($otherCatalogNumbers =~ m/^ *$/)){
		&log_skip("$herb ALL AIDs NULL: $CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");	#run the &log_skip function, printing the following message to the error log
		++$null;
		next Record;
   }
   else{
#Remove duplicates
	if($DUP{$CCH2id}){
		print OUT3 "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\t$scientificName\t$verbatimCounty\n";
#print "EXCL $old_AID\n";
++$dups;
	}
	else{
		print OUT2 "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tNONDUP\t$occurrenceID\t$scientificName\t$verbatimCounty\n";
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