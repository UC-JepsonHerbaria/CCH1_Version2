
use strict;
#use warnings;
#use diagnostics;
use lib '../../Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

my $today_JD = &CCH::get_today;
#my $today_JD = &get_today_julian_day;



$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.

my $herb="HUH";

my $dirdate="2022_FEB28";

my $filedate="02282022";


my %month_hash = &CCH::month_hash;

my $records_file='output/HUH-CCH2_out_'.$filedate.'.txt';
#only harvesting the CCH2 ID's and CCH1 ids from this file here
$today_JD =~ s/ *PDT//;

open(DUPLOG, ">>input/AID_GUID/DUPS/dup_log_".$today_JD.".txt") || die; 
open(OUT, ">input/AID_GUID/DUPS/DUPS_".$herb.$today_JD.".txt") || die; #this only needs to be active once to generate a list of duplicated accessions

	print OUT "herb\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tGBIF_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tscientificName\tcounty\n";


#declare variables

#counts
my ($skipped, $included, %seen, %duplicate_FOUND_CAT, %duplicate_FOUND_OTH,@fields) = "";
my ($dups,$dups_B,$ALTER, $ORTH, %DUP_FOUND,%duplicate_OTH,%duplicate_CAT,$count_record) = "";


#out file variables for CCH2 compatibility
my ($ALT_CCH_BARCODE,$oldA,$old_AID,$formatted_EJD,$formatted_LJD) = "";

#HUH occid infile
my ($OC,$IC,$CO,$OCC,$CA,$OCA,%OCCID) = "";

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

open (IN, "<", $records_file) or die $!;
Record: while(<IN>){
	chomp;

        if ($. == 1){#activate if need to skip header lines
			next Record;
		}
		

		my @fields=split(/\t/,$_,100);

		unless($#fields == 47){  #if the number of values in the columns array is exactly 48, this is for Darwin Core

			warn "$#fields bad field number $_\n";

			next Record;
		}


#0036fff8-fa5f-49b3-bbad-8ab97c436984	GH	barcode-01709620		0036fff8-fa5f-49b3-bbad-8ab97c436984	Aquilegia formosa Fischer	Aquilegia formosa	Aquilegia formosa	NULL	NULL					G. B. Rossbach ; A. R. Hodgdon			1934-07-20	1934-07-20	19340720	19340720	USA	California	Tuolumne County	on ledges by cascade on tributary to Leevining Creek, 5 miles east of Tioga Lake		Wet turf			NotDetermined	NULL										NULL					2020-06-25T15:48:08Z		Tuolumne
#ea7874e7-4c52-4057-8a6a-1d9b497aff2e	GH	barcode-02001711		ea7874e7-4c52-4057-8a6a-1d9b497aff2e	Nuttallanthus texanus (Scheele) D. A. Sutton	Nuttallanthus texanus	Nuttallanthus texanus	NULL	NULL					M. M. Miles			1886-02-01	1886-02-28	18860201	18860228	USA	California	San Luis Obispo County	&lsqb;data not captured&rsqb;					NotDetermined	NULL										NULL					2022-01-13T20:43:07Z		San Luis Obispo
#00c55a04-e201-455b-8455-5519424d35f6	GH	barcode-02023616		00c55a04-e201-455b-8455-5519424d35f6	Cryptantha flaccida (Douglas ex Lehmann) Greene	Cryptantha flaccida	Cryptantha flaccida	NULL	NULL					;lsqb;data not captured;rsqb;			1886-02-01	1886-02-28	18860201	18860228	USA	California	Fresno County	&lsqb;data not captured&rsqb;					NotDetermined	NULL										NULL					2019-07-23T18:17:17Z		Fresno
#eaeb69fd-fcaa-45ae-b1f7-03665ee77dbf	GH	barcode-00379397		eaeb69fd-fcaa-45ae-b1f7-03665ee77dbf	Erysimum capitatum (Douglas ex Hooker) Greene	Erysimum capitatum	Erysimum capitatum	NULL	NULL					L. E. Smith	196		1913-05-09	1913-05-09	19130509	19130509	USA	California	Siskiyou County	Weed					NotDetermined	NULL										NULL					2012-08-30T10:57:56Z		Siskiyou


		($CCH2id,
		$institutionCode,
		$catalogNumber,
		$otherCatalogNumbers,
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
		$formatted_EJD,
		$formatted_LJD,
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
		$latitude,
		$longitude,
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
#The array @fields is made up on these 48 scalars, in this order, GBIF modified export


#filter by herbarium code
  if ($institutionCode =~ m/^(GH|A|AMES|ECON)$/){


printf {*STDERR} "%d\r", ++$count_record;


########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped;
		next Record;
	}

#BAD otherCatalogNumbers==>422e0127-1942-499d-b177-27ee815ed413==>barcode-02045005==>AMES-accession-80342

#extract old herbarium and aid numbers

	if ($otherCatalogNumbers =~ m/^(GH|A|AMES|ECON) *- *[acesion]+ *- *0*([1-9][0-9]*)[a-zA-Z]*$/){
		$oldCCHID = $1.$2;
		$duplicate_OTH{$oldCCHID}++;
		#print "HERB(2)\t$old_AID\t$id==>$catalogNumber==>$otherCatalogNumbers\n"";
	}
	elsif ($otherCatalogNumbers =~ m/^(GH|A|AMES|ECON)[- ]*0*([1-9][0-9]*)[a-zA-Z]*$/){
		$oldCCHID = $1.$2;
		$duplicate_OTH{$oldCCHID}++;
		#print "HERB(2)\t$old_AID\t$id==>$catalogNumber==>$otherCatalogNumbers\n"";
	}
	elsif ($otherCatalogNumbers =~ m/^0*([1-9][0-9]*)[a-zA-Z]*$/){
		$oldCCHID = $institutionCode.$1;
		$duplicate_OTH{$oldCCHID}++;
		#print "HERB(2)\t$old_AID\t$id==>$catalogNumber==>$otherCatalogNumbers\n"";
	}
	elsif ($otherCatalogNumbers =~ m/^(NULL| *)$/){
		$otherCatalogNumbers = "";
		$oldCCHID="";
	}
	else{
		&CCH::log_change("BAD Accession==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		print DUPLOG "BAD otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$otherCatalogNumbers = "";
		$oldCCHID="";
	}


#construct catalog numbers
	if ($catalogNumber =~ m/^(GH|A|AMES|ECON)([0-9]+)-BARCODE$/){
		$CCHbarcode = $catalogNumber;
		$ALT_CCH_BARCODE = $1.$2;
		$duplicate_CAT{$CCHbarcode}++;#count to find duplicates
		#print "HERB(3)\t$ALT_CCH_BARCODE\t$id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($catalogNumber =~ m/^barcode-(0*)([1-9][0-9]+)$/){
		$CCHbarcode = $institutionCode.$1.$2."-BARCODE";
		$ALT_CCH_BARCODE = $institutionCode.$2;
		$duplicate_CAT{$CCHbarcode}++;#count to find duplicates
		#print "HERB(3)\t$ALT_CCH_BARCODE\t$id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$CCHbarcode="";
	}
	else{
		&CCH::log_change("BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		print DUPLOG "BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
	}

   if (length ($catalogNumber) >= 1){
	if ($duplicate_CAT{$catalogNumber} >= 2){
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

#declare variables

#counts
my ($skipped, $included, %seen) = "";
my ($dups,$dups_B,$ALTER, $ORTH, $count_record) = "";

#out file variables for CCH2 compatibility
my ($ALT_CCH_BARCODE,$oldA,$old_AID,$formatted_EJD,$formatted_LJD) = "";

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


open (IN, "<", $records_file) or die $!;
Record: while(<IN>){
	chomp;

        if ($. == 1){#activate if need to skip header lines
			next Record;
		}
		

		my @fields=split(/\t/,$_,100);

		unless($#fields == 47){  #if the number of values in the columns array is exactly 48, this is for Darwin Core

			warn "$#fields bad field number $_\n";

			next Record;
		}

		($CCH2id,
		$institutionCode,
		$catalogNumber,
		$otherCatalogNumbers,
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
		$formatted_EJD,
		$formatted_LJD,
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
		$latitude,
		$longitude,
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
#The array @fields is made up on these 48 scalars, in this order, GBIF modified export


#filter by herbarium code
  if ($institutionCode =~ m/^(GH|A|AMES|ECON)$/){


printf {*STDERR} "%d\r", ++$count_record;


########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped;
		next Record;
	}

#BAD otherCatalogNumbers==>422e0127-1942-499d-b177-27ee815ed413==>barcode-02045005==>AMES-accession-80342

#extract old herbarium and aid numbers

	if ($otherCatalogNumbers =~ m/^(GH|A|AMES|ECON) *- *[acesion]+ *- *0*([1-9][0-9]*)[a-zA-Z]*$/){
		$oldCCHID = $1.$2;
	}
	elsif ($otherCatalogNumbers =~ m/^(GH|A|AMES|ECON)[- ]*0*([1-9][0-9]*)[a-zA-Z]*$/){
		$oldCCHID = $1.$2;
	}
	elsif ($otherCatalogNumbers =~ m/^0*([1-9][0-9]*)[a-zA-Z]*$/){
		$oldCCHID = $institutionCode.$1;
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
	if ($catalogNumber =~ m/^(GH|A|AMES|ECON)([0-9]+)-BARCODE$/){
		$CCHbarcode = $catalogNumber;
		$ALT_CCH_BARCODE = $1.$2;
	}
	elsif ($catalogNumber =~ m/^barcode-(0*)([1-9][0-9]+)$/){
		$CCHbarcode = $institutionCode.$1.$2."-BARCODE";
		$ALT_CCH_BARCODE = $institutionCode.$2;
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$CCHbarcode="";
	}
	else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
	}

#exclude ALL duplicates 
	if ($duplicate_FOUND_OTH{$oldCCHID}) {
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	#for example, the worst case is CAS520791, which has 17 specimens that were labeled with this number over the years.
		print OUT "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$oldCCHID\t$CCHbarcode\t\tDUP\t$occurrenceID\t$scientificName\t$verbatimCounty\n";
		++$dups_B;
	}
	
	if ($duplicate_FOUND_CAT{$CCHbarcode}) {
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	#for example, the worst case is CAS520791, which has 17 specimens that were labeled with this number over the years.
		print OUT "$institutionCode\t$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$oldCCHID\t$CCHbarcode\t\tDUP\t$occurrenceID\t$scientificName\t$verbatimCounty\n";
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