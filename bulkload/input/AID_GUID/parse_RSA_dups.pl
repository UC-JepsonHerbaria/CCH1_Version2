
use strict;
#use warnings;
#use diagnostics;
use lib '../../Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

my $today_JD = &CCH::get_today;
#my $today_JD = &get_today_julian_day;
$today_JD =~ s/ *PDT//;

open(DUPLOG, ">>input/AID_GUID/DUPS/dup_log_".$today_JD.".txt") || die; 


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

#counts
my ($skipped, $included, %seen, %duplicate_FOUND_CAT, %duplicate_FOUND_OTH) = "";
my ($dups,$dups_B,$ALTER, $ORTH, %DUP_FOUND,%duplicate_OTH,%duplicate_CAT,$count_record) = "";


#out file variables for CCH2 compatibility
my ($ALT_CCH_BARCODE,$oldA,$old_AID,$CCH2id) = "";


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


open(OUT, ">input/AID_GUID/DUPS/DUPS_".$herb.$today_JD.".txt") || die; #this only needs to be active once to generate a list of duplicated accessions

	print OUT "herb\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tCCH_BARCODE_ID\tALT_CCH_AID\tStatus\tGUID-occurrenceID\tscientificName\tcounty\n";

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
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^(POM) *[acesion]+ *: *([1-9][0-9]*)([A-Za-z]*); .*$/){
		$old_AID = $1.$2;
		$oldA = $1.$2.$3;
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^(POM) *[acesion]+ *: *([1-9][0-9]*)([A-Za-z]*)$/){
		$old_AID = $1.$2;
		$oldA = $1.$2.$3;
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^(RSA) *[acesion]+ *: *(0+)([1-9][0-9]*)([A-Za-z]*); .*$/){
		$old_AID = $1.$3;
		$oldA = $1.$2.$3.$4;
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^(RSA) *[acesion]+ *: *([1-9][0-9]*)([A-Za-z]*); .*$/){
		$old_AID = $1.$2;
		$oldA = $1.$2.$3;
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^(RSA) *[acesion]+ *: *([1-9][0-9]*)([A-Za-z]*)$/){
		$old_AID = $1.$2;
		$oldA = $1.$2.$3;
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^living.+; *(RSA|POM) *[acesion]+ *: *([1-9][0-9]*)([A-Za-z]*)$/){
		$old_AID = $1.$2;
		$oldA = $1.$2.$3;
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^[Pp]rop.+; *(RSA|POM) *[acesion]+ *: *([1-9][0-9]*)$/){
		$old_AID = $1.$2;
		$oldA = "";
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^(RSA|POM) *[acesion]+ *: *(0+)([1-9][0-9]+)$/){
		$old_AID = $1.$3;
		$oldA = $1.$2.$3;
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^([1-9][0-9]*)[A-Za-z]*; .*$/){
		$old_AID = $collectionCode.$1;
		$oldA = "";
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^([1-9][0-9]*)[A-Za-z]*$/){
		$old_AID = $collectionCode.$1;
		$oldA = "";
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^ *$/){
		$otherCatalogNumbers = "";
		$oldA = $old_AID = "";
	}
	else{
		&CCH::log_change("BAD Accession==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
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
		$duplicate_CAT{$ALT_CCH_BARCODE}++;#count to find duplicates
		#print "HERB(3)\t$ALT_CCH_BARCODE\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
	}
	else{
		#RSA has some special cases where as long as the barcode has errors, 
		#then we use the old RSA accession number
		if ($CCH2id =~ m/^(1007683|1007683|1108773|1138576|3831359|3894242|4129414)$/){
#BAD catalogNumber==>1007683==>RSA00.Y==>RSA accession #: 226913
#BAD catalogNumber==>1014497==>47120==>RSA accession #: 47120
#BAD catalogNumber==>1108773==>103693==>RSA accession #: 853430
#BAD catalogNumber==>1138576==>TA0069642==>RSA accession #: 835400
#BAD catalogNumber==>3831359==>RSAP154959==>RSA accession #: 874904
			if ($otherCatalogNumbers =~ m/^(RSA|POM) *accession *: *([1-9][0-9]*)$/){
				$old_AID = $1.$2;
				$ALT_CCH_BARCODE = "";
				$oldA = "";
				$duplicate_OTH{$old_AID}++;
			}
			else{
				print "BAD otherCatalogNumbers(1)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
				$ALT_CCH_BARCODE = "";
				$oldA = $old_AID = "";
			}
		}
		elsif ($CCH2id =~ m/^(666328|725329|795125|908414|917353|939018)$/){
#BAD catalogNumber==>666328==>RSA0038W==>RSA accession #: 575119
#BAD catalogNumber==>725329==>TA0318410==>RSA accession #: 619072
#BAD catalogNumber==>795125==>RSA0016192-==>POM accession #: 6763
#BAD catalogNumber==>908414==>JA0067718==>RSA accession #: 834352
#BAD catalogNumber==>917353==>RSA0124439`==>POM accession #: 320164
#BAD catalogNumber==>939018==>c==>RSA accession #: 124712
			if ($otherCatalogNumbers =~ m/^(POM|RSA) *accession *: *([1-9][0-9]*)$/){
				$old_AID = $1.$2;
				$ALT_CCH_BARCODE = "";
				$oldA = "";
				$duplicate_OTH{$old_AID}++;
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



   if (length ($catalogNumber) >= 1){
	if ($duplicate_CAT{$ALT_CCH_BARCODE} >= 2){
		$duplicate_FOUND_CAT{$ALT_CCH_BARCODE}++;
		++$dups;
	}
   }
  
   if (length ($otherCatalogNumbers) >= 1){
	if ($duplicate_OTH{$old_AID} >= 2){
		$duplicate_FOUND_OTH{$old_AID}++;
		++$dups;
	}
   }

  }
}
#for testing
	#foreach $ALT_CCH_BARCODE (sort keys %duplicate_CAT) {
    #printf "%-31s %s\n", $ALT_CCH_BARCODE, $duplicate_CAT{$ALT_CCH_BARCODE} if ($duplicate_CAT{$ALT_CCH_BARCODE} >= 2);
	#}

  #foreach $old_AID (sort keys %duplicate_OTH) {
    #printf "%-31s %s\n", $old_AID, $duplicate_OTH{$old_AID} if ($duplicate_OTH{$old_AID} >= 2);
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
#counts
my ($skipped, $included, %seen) = "";
my ($dups,$dups_B,$ALTER, $ORTH, $count_record) = "";

#out file variables for CCH2 compatibility
my ($ALT_CCH_BARCODE,$oldA,$old_AID) = "";

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
			if ($otherCatalogNumbers =~ m/^(RSA|POM) *[accesion]+ *: *([1-9][0-9]*)$/){
				$old_AID = $1.$2;
				$ALT_CCH_BARCODE = "";
				$oldA = "";
			}
			else{
				$ALT_CCH_BARCODE = "";
				$oldA = $old_AID = "";
			}
		}
		elsif ($CCH2id =~ m/^(666328|725329|795125|908414|917353|939018)$/){
			if ($otherCatalogNumbers =~ m/^(POM|RSA) *[accesion]+ *: *([1-9][0-9]*)$/){
				$old_AID = $1.$2;
				$ALT_CCH_BARCODE = "";
				$oldA = "";
			}
			else{
				$ALT_CCH_BARCODE = "";
				$oldA = $old_AID = "";
			}
		}
		else{
			$catalogNumber = "";
			$ALT_CCH_BARCODE = "";
		}
	}
   }
   else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
   }


#exclude ALL duplicates 
	if ($duplicate_FOUND_OTH{$old_AID}) {
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	#for example, the worst case is CAS520791, which has 17 specimens that were labeled with this number over the years.
		print OUT "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\t$scientificName\t$verbatimCounty\n";
		++$dups_B;
	}
	
	if ($duplicate_FOUND_CAT{$ALT_CCH_BARCODE}) {
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	#for example, the worst case is CAS520791, which has 17 specimens that were labeled with this number over the years.
		print OUT "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\t$scientificName\t$verbatimCounty\n";
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
