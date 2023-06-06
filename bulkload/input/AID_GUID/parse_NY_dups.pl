
use strict;
#use warnings;
#use diagnostics;
use lib '../../Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

my $today_JD = &CCH::get_today;
#my $today_JD = &get_today_julian_day;

$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.

my $herb="NY";

my $dirdate="2022_APR28";

my $filedate="04282022";


my %month_hash = &CCH::month_hash;

my $records_file='output/NY-CCH2_out_'.$filedate.'.txt';
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

#NY occid infile
my ($OC,$IC,$CO,$OCC,$CA,$OCA,%OCCID) = "";

#NY IN file
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

#4db1f34f-a300-49d5-b261-465b128d5771	NY	00044685		4db1f34f-a300-49d5-b261-465b128d5771	Datisca glomerata (C.Presl) Baill.	Datisca glomerata	Datisca glomerata	NULL	NULL	J. B. Walker	1996-01-01T00:00:00			J. B. Walker	1922	12 Jul 1996	1996-07-12	1996-07-12	19960712	19960712	USA	California	San Diego Co.	Cleveland National Forest, Palomar district at jct. of USFS Rd. 12S07& 12S05		Growing in rocky creekbed in chaparral				NULL		449	1476	1476 ft		33.120000	-116.820000	33.120000	-116.820000	WGS84							San Diego
#1240f38c-ef26-45e8-83a6-b8f7da0248cf	NY	01393092		1240f38c-ef26-45e8-83a6-b8f7da0248cf	Chlorogalum pomeridianum (DC.) Kunth	Chlorogalum pomeridianum	Chlorogalum pomeridianum	NULL	NULL					M. C. Pace	707	23 May 2014	2014-05-23	2014-05-23	20140523	20140523	USA	California	Napa Co.	Property of Erik Martella, Butts Canyon Road, Pope Valley. South-southeast of the intersection of Butts Canyon Road and Snell Valley Road. 7 miles north of Pope Valley town center.		Central California Foothills and Coastal Mountains, North Coast Range Eastern Slopes ecoregion. Manzanita, Oak, and Pine &lpar;Arctostaphylos, Quercus, and Pinus&rpar; chaparral woodland interspersed w				NULL						38.688754	-122.439087	38.688754	-122.439087	WGS84			GPS				Napa
#8160600a-86a3-4737-8b5b-05ba0cfe7c72	NY	01393052		8160600a-86a3-4737-8b5b-05ba0cfe7c72	Plantago erecta Morris	Plantago erecta	Plantago erecta	NULL	NULL					M. C. Pace	731	23 May 2014	2014-05-23	2014-05-23	20140523	20140523	USA	California	Napa Co.	Property of Erik Martella, Butts Canyon Road, Pope Valley. South-southeast of the intersection of Butts Canyon Road and Snell Valley Road. 7 miles north of Pope Valley town center.		Central California Foothills and Coastal Mountains, North Coast Range Eastern Slopes ecoregion. Manzanita, Oak, and Pine &lpar;Arctostaphylos, Quercus, and Pinus&rpar; chaparral woodland interspersed w				NULL						38.688754	-122.439087	38.688754	-122.439087	WGS84			GPS				Napa
#748e67cb-127f-461d-a08d-3f28a9cf6c3a	NY	01393064		748e67cb-127f-461d-a08d-3f28a9cf6c3a	Delphinium hesperium subsp. hesperium	Delphinium hesperium subsp. hesperium	Delphinium hesperium subsp. hesperium	NULL	NULL					M. C. Pace	725	23 May 2014	2014-05-23	2014-05-23	20140523	20140523	USA	California	Napa Co.	Property of Erik Martella, Butts Canyon Road, Pope Valley. South-southeast of the intersection of Butts Canyon Road and Snell Valley Road. 7 miles north of Pope Valley town center.		Central California Foothills and Coastal Mountains, North Coast Range Eastern Slopes ecoregion. Manzanita, Oak, and Pine &lpar;Arctostaphylos, Quercus, and Pinus&rpar; chaparral woodland interspersed w				NULL						38.688754	-122.439087	38.688754	-122.439087	WGS84			GPS				Napa


#filter by herbarium code
  if ($institutionCode =~ m/^(NY)$/){


printf {*STDERR} "%d\r", ++$count_record;


########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped;
		next Record;
	}

#extract old herbarium and aid numbers

	if ($otherCatalogNumbers =~ m/^(NY) *([0-9]+)[a-zA-Z]*$/){
		$oldCCHID = $1.$2;
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
	if ($catalogNumber =~ m/^(0*)([1-9][0-9]+)[a-zA-Z]*$/){
		$CCHbarcode = $institutionCode.$1.$2."-BARCODE";
		$ALT_CCH_BARCODE = $institutionCode.$2; #this is the reconstructed old CCH1 accession from 2012
		$duplicate_CAT{$CCHbarcode}++;#count to find duplicates
		#print "HERB(3)\t$ALT_CCH_BARCODE\t$id==>$catalogNumber==>$otherCatalogNumbers\n";
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$catalogNumber = "";
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

#NY IN file
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
  if ($institutionCode =~ m/^(NY)$/){


printf {*STDERR} "%d\r", ++$count_record;


########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped;
		next Record;
	}

#extract old herbarium and aid numbers

	if ($otherCatalogNumbers =~ m/^(NY) *([0-9]+)[a-zA-Z]*$/){
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
	if ($catalogNumber =~ m/^(0*)([1-9][0-9]+)[a-zA-Z]*$/){
		$CCHbarcode = $institutionCode.$1.$2."-BARCODE";
		$ALT_CCH_BARCODE = $institutionCode.$2; #this is the reconstructed old CCH1 accession from 2012
	}
	elsif ($CCHbarcode =~ m/^(NULL| *)$/){
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