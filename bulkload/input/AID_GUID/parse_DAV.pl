
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
my $herb = "DAV";

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
my (%duplicate_FOUND_CAT, %duplicate_FOUND_OTH) = "";
my (%DUP_FOUND,%duplicate_OTH,%duplicate_CAT) = "";

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

#DAV conversion file
my ($herbcode,$cch2idb,$old_DAV,$barcode_DAV,$alt_DAV,%CONV_DAV,%NEW_DAV,$countDAV) = "";


local($/)="\n";

open(IN, "input/CCH1_hash_files/DAV_OLD_to_NEW_AID.txt") || die;

while(<IN>){#read in the DAV conversion file
#These are the old Access record ID, which were used as accessions in the old CCH1
		chomp;
		($herbcode,$cch2idb,$old_DAV,$barcode_DAV,$alt_DAV)=split(/\t/);

		$CONV_DAV{$old_DAV}=$cch2idb;
		$NEW_DAV{$cch2idb}=$old_DAV;

}
close(IN);

open(IN, "input/AID_GUID/DUPS/DUPS_".$herb.$today_JD.".txt") || die;
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
  if ($institutionCode =~ m/^DAV$/){


#warn "$count_record\n" unless $count_record % 1009;
  printf {*STDERR} "%d\r", ++$count_record;


########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped;
		next Record;
	}
	
#construct the old CCH1 aid, add it to the 3rd alt field
	my $temp = $NEW_DAV{$CCH2id};
   #print "$temp\n";
   if ($temp =~ m/^UCD\d+$/){
		$oldA = $temp;
		++$countDAV;
   }
   else{
   		$oldA = "";
   }
	
	
	$catalogNumber =~ s/^DAV307257DAV307257/DAV307257/; #there is one bad record here that needed fixed
	$catalogNumber =~ s/^(40533599107568|03533599101294|004805021602)$//; #there two more records here that needed fixed
	$otherCatalogNumbers =~ s/^[A-Z]+$//; #BAD otherCatalogNumbers==>3934182==>==>CORD
	$otherCatalogNumbers =~ s/^c;(.*)/$1/; #BAD otherCatalogNumbers==>1354957==>DAV329645==>c; UCD101726
	

#extract old herbarium and aid numbers
   if (length ($otherCatalogNumbers) >= 1){
   
   	#delete extraneous text
	$otherCatalogNumbers =~ s/^[Aacesion]+ *\#?: *//i;
   $otherCatalogNumbers =~ s/^NPS Catalog *\#: *([A-Z]+ *\d+); *Accession *\#: *(.*)$/$1|$2/i;
	if ($otherCatalogNumbers =~ m/^(JOTR|PORE|YOSE|OSE)([0-9]+)$/){ 
		#DAV some other accessioned entered in the otherCatalogNumber field
		#JOTR is Joshia Tree, YOSE & OSE is Yosemite, PORE is Point Reyes
		#skip these
		$old_AID = "";
	}
	elsif ($otherCatalogNumbers =~ m/^(DAV|AV|DV|DA|DAAV|DAC|DAVA|DFAV)([0-9]+)[A-Za-z]*$/i){ #DAV has typo herbarium codes in the otherCatalogNumber field
		#DAV and variants
		$old_AID = "DAV".$2;
	}
	elsif ($otherCatalogNumbers =~ m/^BIBE *\d+\|(DAV *\d+)$/i){ 
		#DAV and variants
		$old_AID = $2;
	}
	elsif ($otherCatalogNumbers =~ m/^(DAV|AV|DV|DA|DAAV|DAC|DAVA|DFAV) +([0-9]+)[A-Za-z]*$/i){ 
		$old_AID = "DAV".$2;
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^(DAV|AV|DV|DA|DAAV|DAC|DAVA|DFAV)([0-9]+)[A-Za-z]*[,;].*$/i){ 
		$old_AID = "DAV".$2;
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^(HUC|AHUCL|AUHC|AHUC|AHUCA|AUC|AHUV)([0-9]+)[A-Za-z]*$/i){ 
		$old_AID = "AHUC".$2;
		$duplicate_OTH{$old_AID}++;
	}
	elsif ($otherCatalogNumbers =~ m/^(UCD[0-9]+);? *.+$/){ #DAV unique variant
		$old_AID = "";
	}
	elsif ($otherCatalogNumbers =~ m/^(BIBE) *([0-9]+)[A-Za-z]*$/i){ 
		$old_AID = "";
		$oldA = "";
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
	if ($catalogNumber =~ m/^(DAV|AHUC)(0*[1-9][0-9]*)$/){ #DAV is adding barcodes incrementally, so not all old CCH numbers have them
		$ALT_CCH_BARCODE = $1.$2."-BARCODE";
		$duplicate_CAT{$ALT_CCH_BARCODE}++;#count to find duplicates
	}
	elsif ($catalogNumber =~ m/^(dav)(0*[1-9][0-9]*)$/){ #DAV is adding barcodes incrementally, so not all old CCH numbers have them
		$ALT_CCH_BARCODE = "DAV".$2."-BARCODE";
		$duplicate_CAT{$ALT_CCH_BARCODE}++;#count to find duplicates
	}
	elsif ($catalogNumber =~ m/^(YOSE)(\d+)$/){ #YOSE is NOT is part of DAV; they do not appear to eb re-assinging DAV barcodes to these
		$ALT_CCH_BARCODE = "";
		$catalogNumber = "";
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
	}
	else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
	}
   }
   else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
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
UCD alt accessions: $countDAV

$herb TOTAL: $count_record

EOP

print BULKLOG <<EOP;

$herb INCL: $included
$herb DUPS: $dups
$herb NULL: $null
UCD alt accessions: $countDAV

$herb TOTAL: $count_record

EOP

close(IN);
close(OUT2);
close(OUT3);
close(BULKLOG);
