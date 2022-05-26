
use strict;
#use warnings;
#use diagnostics;
use lib '../../Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

my $today_JD = &CCH::get_today;
#my $today_JD = &get_today_julian_day;

my $otherID; #unique to UCSC

open(BULKLOG, ">>output/CCH2_bulkload_log_".$today_JD.".txt") || die; 

#open(BULKLOG, ">>output/CCH2_bulkload_log_2459351.txt") || die; 


$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.
my $herb = "UCSC";



#my $dirdate = "2021_APR16";
#my $dirdate="2021_AUG28";
#my $dirdate="2022_JAN26";
my $dirdate="2022_MAR02";
#$filedate="11072019";
#my $filedate="12052019";
#my $filedate = "01292020";
#my $filedate = "04162021";
#my $filedate="08282021";
#my $filedate="01262022";
my $filedate="03022022";


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
		unless( $#fields == 90){  #if the number of values in the columns array is exactly 91, this is for Darwin Core

			warn "$#fields bad field number $_\n";

			next Record;
		}

#id	institutionCode	collectionCode	ownerInstitutionCode	basisOfRecord	occurrenceID	catalogNumber	otherCatalogNumbers	
#higherClassification	kingdom	
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
#phylum	class	order	family	scientificName	taxonID	scientificNameAuthorship	genus	subgenus	
#specificEpithet	
#$kingdom,
#phylum	class	order	family	scientificName	taxonID	scientificNameAuthorship	genus	subgenus	specificEpithet	
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
#verbatimTaxonRank	infraspecificEpithet	taxonRank	identifiedBy	dateIdentified	identificationReferences	
#identificationRemarks	taxonRemarks	identificationQualifier	typeStatus	
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
#recordedBy	associatedCollectors	recordNumber	eventDate	year	month	day	startDayOfYear	endDayOfYear	
#verbatimEventDate	
$recordedBy,
$associatedCollectors, #This is in Symbiota Native and not Darwin Core
$recordNumber,
$eventDate,
$year,
$month,
$day,
$startDayOfYear,
$endDayOfYear,
$verbatimEventDate,
#40
#occurrenceRemarks	habitat	substrate	verbatimAttributes	fieldNumber	eventID	informationWithheld	dataGeneralizations	
#dynamicProperties	associatedOccurrences	
$occurrenceRemarks,
$habitat,
$substrate, #This is in Symbiota Native and not Darwin Core
$verbatimAttributes, #This is in Symbiota Native and not Darwin Core
$fieldNumber,
$eventID, #This is in Symbiota Native and not Darwin Core
$informationWithheld,
$dataGeneralizations,
$dynamicProperties,
$associatedOccurrences,
#$associatedTaxa,
#$reproductiveCondition,
#$establishmentMeans,
#50
#associatedSequences	associatedTaxa	reproductiveCondition	establishmentMeans	cultivationStatus	lifeStage	sex	
#individualCount	preparations	country	
$associatedSequences, #This is in Symbiota Native and not Darwin Core
$associatedTaxa,
$reproductiveCondition,
$establishmentMeans,
$cultivationStatus, #This is in Symbiota Native and not Darwin Core
$lifeStage,
$sex,
$individualCount,
$preparations,
$country,
#$stateProvince,
#$verbatimCounty,
#$municipality,
#$locality,
#$locationRemarks,
#60
#stateProvince	county	municipality	locality	locationRemarks	localitySecurity	localitySecurityReason	
#decimalLatitude	decimalLongitude	geodeticDatum	
$stateProvince,
$verbatimCounty,
$municipality,
$locality,
$locationRemarks,
$localitySecurity, #This is in Symbiota Native and not Darwin Core
$localitySecurityReason, #This is in Symbiota Native and not Darwin Core
$latitude,
$longitude,
$geodeticDatum,
#$coordinateUncertaintyInMeters,
#$verbatimCoordinates,
#$georeferencedBy,
#$georeferenceProtocol,
#$georeferenceSources,
#$georeferenceVerificationStatus,
#$georeferenceRemarks,
#70
#coordinateUncertaintyInMeters	verbatimCoordinates	georeferencedBy	georeferenceProtocol	georeferenceSources	
#georeferenceVerificationStatus	georeferenceRemarks	minimumElevationInMeters	maximumElevationInMeters	minimumDepthInMeters
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,
$georeferenceProtocol,
$georeferenceSources,
$georeferenceVerificationStatus,
$georeferenceRemarks,
$minimumElevationInMeters,
$maximumElevationInMeters,
$minimumDepthInMeters,
#$verbatimDepth,
#$verbatimElevation,
#$disposition,
#$language,
#$recordEnteredBy,
#$modified,
#80
#maximumDepthInMeters	verbatimDepth	verbatimElevation	disposition	language	recordEnteredBy	modified	
#sourcePrimaryKey-dbpk	collId	recordId	references
$maximumDepthInMeters,
$verbatimDepth,
$verbatimElevation,
$disposition,
$language,
$recordEnteredBy,
$modified,
$sourcePrimaryKey, #This is in Symbiota Native and not Darwin Core
#$rights,  #This is in Darwin Core and not Symbiota Native
#$rightsHolder, #This is in Darwin Core and not Symbiota Native
#$accessRights, #This is in Darwin Core and not Symbiota Native
$collId, #This is in Symbiota Native and not Darwin Core
$recordId,
#90
$references	
) = @fields;	
#The array @fields is made up on these 85 scalars, in this order, for Darwin Core
#The array @fields is made up on these 91 scalars, in this order, for Symbiota Native


#filter by herbarium code
  if ($institutionCode =~ m/^UCSC$/){


#warn "$count_record\n" unless $count_record % 1009;
  printf {*STDERR} "%d\r", ++$count_record;


########ACCESSION NUMBER
#check for nulls
	if ($CCH2id =~ m/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped;
		next Record;
	}


	$otherCatalogNumbers =~ s/^(\? *\(.+|2006-498|2008-96|1111-589|2010-177|1234-420|2008-89|1991-1087|1987-205|1985-229)$/NULL/i; #make some bad UCSC accessions NULL
	$otherCatalogNumbers =~ s/^(\d+);.+$/$1/; #remove the extra numbers after the semicolon in some records
	$catalogNumber =~ s/^(UCSC100002219, .+|UCSC100002217, .+|)$/NULL/;#NULL these problem accessions


#extract old herbarium and aid numbers
   if (length ($otherCatalogNumbers) >= 1){


#construct the 3rd variant, which is a form without leading zeros
#construct the 3rd variant, which is a form without leading zeros
	if ($otherCatalogNumbers =~ m/^UCSC0+([1-9][0-9]*)([A-Za-z]*)$/){
		$old_AID = $herb.$1;
		$oldA = $otherCatalogNumbers;
	}
	elsif ($otherCatalogNumbers =~ m/^UCSC([1-9][0-9]*)([A-Za-z]*)$/){ 
		$otherID = $1.$2;
		$old_AID = $herb.$1;

	#add leading zeros for the alternate old CCH AID, CCH2 removed those zeros when loaded
		if ($otherID =~ m/^(\d\d\d\d\d[A-Za-z]*)$/){
			$oldA = $herb."0".$otherID;
		}
		elsif ($otherID =~ m/^(\d\d\d\d[A-Za-z]*)$/){
			$oldA = $herb."00".$otherID;
		}
		elsif ($otherID =~ m/^(\d\d\d[A-Za-z]*)$/){
			$oldA = $herb."000".$otherID;
		}
		elsif ($otherID =~ m/^(\d\d[A-Za-z]*)$/){
			$oldA = $herb."0000".$otherID;
		}
		elsif ($otherID =~ m/^(\d[A-Za-z]*)$/){
			$oldA = $herb."00000".$otherID;
		}
		else{
			$oldA = "";
		}
	}
	elsif ($otherCatalogNumbers =~ m/^0*([1-9][0-9]*)([A-Za-z]*)$/){
		$old_AID = $herb.$1;
		$otherID = $1.$2;

	#add leading zeros for the alternate old CCH AID, CCH2 removed those zeros when loaded
		if ($otherID =~ m/^(\d\d\d\d\d[A-Za-z]*)$/){
			$oldA = $herb."0".$otherID;
		}
		elsif ($otherID =~ m/^(\d\d\d\d[A-Za-z]*)$/){
			$oldA = $herb."00".$otherID;
		}
		elsif ($otherID =~ m/^(\d\d\d[A-Za-z]*)$/){
			$oldA = $herb."000".$otherID;
		}
		elsif ($otherID =~ m/^(\d\d[A-Za-z]*)$/){
			$oldA = $herb."0000".$otherID;
		}
		elsif ($otherID =~ m/^(\d[A-Za-z]*)$/){
			$oldA = $herb."00000".$otherID;
		}
		else{
			$oldA = "";
		}
	}
	elsif ($otherCatalogNumbers =~ m/^(NULL| *)$/){
		$otherCatalogNumbers = "";
		$old_AID = "";
	}
	else{
		$otherCatalogNumbers = "";
		$old_AID = "";
	}
   }
   else{
		$otherCatalogNumbers = "";
		$old_AID = "";
   }


#construct catalog numbers
   if (length ($catalogNumber) >= 1){

	if ($catalogNumber =~ m/^UCSC(0*[1-9][0-9]*)[A-Za-z]*$/){
		$ALT_CCH_BARCODE = $herb.$1."-BARCODE";
	}
	elsif ($catalogNumber =~ m/^(0*[1-9][0-9]*)[A-Za-z]$/){#fix records without an herbarium code
		$ALT_CCH_BARCODE = $herb.$1."-BARCODE";
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
	}
	else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
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