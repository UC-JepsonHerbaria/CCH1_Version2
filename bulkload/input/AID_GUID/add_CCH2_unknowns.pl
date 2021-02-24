
#use strict;
#use warnings;
#use diagnostics;
use lib '/Users/Shared/Jepson-Master/Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

my $today_JD;

$herb="CCH2";

$filedate="01292020";

$today_JD = &get_today_julian_day;
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

open(IN, "/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_excluded.txt") || die;
local($/)="\n";
while(<IN>){
	chomp;
	($CN,$OCN,$ID,$acc,$alt,$old,@residue)=split(/\t/);
#CCH2_catalogNumber	CCH2_catalogNumber	CCH2_ID	OLD_CCH_AID	ALT_CCH_ID	ALT_CCH_AID_SPACE	Status	GUID-occurrenceID

		$FOUND{$ID}++;
		

	if ($acc=~m/^SEINET\d/){
		$SEI{$acc}++;
	}

}

close(IN);




#print records with problem geography so they can be added to CCH2 and corrected
#InstitutionCode	occid	occurrenceID	catalogNumber	otherCatalogNumbers	Sciname	tidinterpreted	taxonRemarks	identificationQualifier	identifiedBy	dateIdentified	identificationRemarks	typeStatus	recordedBy	associatedCollectors	recordNumber	year	month	day	verbatimEventDate	country	stateProvince	county	locality	locationRemarks	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	verbatimCoordinates	verbatimEventDate	georeferencedBy	georeferenceSources	georeferenceRemarks	minimumElevationInMeters	maximumElevationInMeters	verbatimElevation	habitat	occurrenceRemarks	associatedTaxa	verbatimAttributes	reproductiveCondition	cultivationStatus	dateLastModified
open(OUT, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/input/CCH2-exports/CCH2_export_unknowns_".$filedate.".txt") || die;

print OUT "InstitutionCode	occid	occurrenceID	catalogNumber	otherCatalogNumbers	Sciname	tidinterpreted	taxonRemarks	identificationQualifier	identifiedBy	dateIdentified	identificationRemarks	typeStatus	recordedBy	associatedCollectors	recordNumber	year	month	day	verbatimEventDate	country	stateProvince	county	locality	locationRemarks	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	verbatimCoordinates	verbatimEventDate	georeferencedBy	georeferenceSources	georeferenceRemarks	minimumElevationInMeters	maximumElevationInMeters	verbatimElevation	habitat	occurrenceRemarks	associatedTaxa	verbatimAttributes	reproductiveCondition	cultivationStatus	dateLastModified\n";

#CCH2 records with messy geographic data are being skipped by the export directly using SQL, it has to be treated seperately then merged later
open(OUT2, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/output/AID_to_ADD_CCH2_unknowns.txt") || die;

	print OUT2 "institutionCode\tcollectionCode\townerInstitutionCode\tCCH2_catalogNumber\tCCH2_catalogNumber\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tscientificName\tcounty\n";


my $records_file="/Users/Shared/Jepson-Master/CCHV2/bulkload/input/CCH2-exports/CCH2_backup_".$filedate.".tab";
open (IN, $records_file) or die $!;
Record: while(<IN>){
	chomp;

#fix some data quality and formatting problems that make import of fields of certain records problematic
	
    if ($. == 1){#activate if need to skip header lines
			next Record;
		}



		my @fields=split(/\t/,$_,100);

    unless( $#fields == 84){ #if the number of values in the columns array is exactly 85

	&CCH::log_skip("$#fields bad field number $_\n");
	++$skipped{one};
	next Record;
	}
#id	institutionCode	collectionCode	ownerInstitutionCode	basisOfRecord	occurrenceID	catalogNumber	
#otherCatalogNumbers	kingdom	phylum	class	order	family	scientificName	taxonID	scientificNameAuthorship	
#genus	specificEpithet	taxonRank	infraspecificEpithet	identifiedBy	dateIdentified	identificationReferences	
#identificationRemarks	taxonRemarks	identificationQualifier	typeStatus	recordedBy	associatedCollectors	
#recordNumber	eventDate	year	month	day	startDayOfYear	endDayOfYear	verbatimEventDate	occurrenceRemarks	
#habitat	substrate	verbatimAttributes	fieldNumber	informationWithheld	dataGeneralizations	dynamicProperties	associatedTaxa	reproductiveCondition	establishmentMeans	cultivationStatus	lifeStage	sex	individualCount	preparations	country	stateProvince	county	municipality	locality	locationRemarks	localitySecurity	localitySecurityReason	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	verbatimCoordinates	georeferencedBy	georeferenceProtocol	georeferenceSources	georeferenceVerificationStatus	georeferenceRemarks	minimumElevationInMeters	maximumElevationInMeters	minimumDepthInMeters	maximumDepthInMeters	verbatimDepth	verbatimElevation	disposition	language	recordEnteredBy	modified	sourcePrimaryKey-dbpk	collId	recordId	references

($CCH2id,
$institutionCode,
$collectionCode,
$ownerInstitutionCode,	#added 2016
$basisOfRecord,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$kingdom,
$phylum,
#10
$class,
$order,
$family,
$scientificName,
$taxonID,
$scientificNameAuthorship,
$genus,
$specificEpithet,
$taxonRank,
$infraspecificEpithet,
#20
$identifiedBy,
$dateIdentified,
$identificationReferences,	#added 2015, not processed
$identificationRemarks,	#added 2015, not processed
$taxonRemarks,	#added 2015
$identificationQualifier,
$typeStatus,
$recordedBy,
$associatedCollectors,	#added 2016, not in 2017 download, combined within recorded by with a ";"
$recordNumber,
#30
$eventDate,
$year,
$month,
$day,
$startDayOfYear,
$endDayOfYear,
$verbatimEventDate,
$occurrenceRemarks,
$habitat,
$substrate,			#added 2016
#40
$verbatimAttributes, #added 2016
$fieldNumber,
$informationWithheld,
$dataGeneralizations,	#added 2015, not processed, field empty as of 2016
$dynamicProperties,	#added 2015, not processed
$associatedTaxa,
$reproductiveCondition,
$establishmentMeans,	#added 2015, not processed
$cultivationStatus,	#added 2016
$lifeStage,
#50
$sex,	#added 2015, not processed
$individualCount,	#added 2015, not processed
$preparations,	#added 2015, not processed
$country,
$stateProvince,
$county,
$municipality,
$locality,
$locationRemarks, #newly added 2015-10, not processed
$localitySecurity,		#added 2016, not processed
#60
$localitySecurityReason,	#added 2016, not processed
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,	#added 2015, not processed
$georeferenceProtocol,	#added 2015, not processed
$georeferenceSource,
$georeferenceVerificationStatus,	#added 2015, not processed
#70
$georeferenceRemarks,	#added 2015, not processed
$minimumElevationInMeters,
$maximumElevationInMeters, #not processed for now
$minimumDepthInMeters, #newly added 2015-10, not processed
$maximumDepthInMeters, #newly added 2015-10, not processed
$verbatimDepth, #newly added 2015-10, not processed
$verbatimElevation,
$disposition,	#added 2015, not processed
$language,	#added 2015, not processed
$recordEnteredBy, #newly added 2015-10, not processed
#80
$modified,	#added 2015, not processed
$sourcePrimaryKey,  #added 2016, not processed
$collID,	#added 2016, not processed
$recordId,	#added 2015, not processed
$references	#added 2016, not processed
)=@fields;	#The array @columns is made up on these 87 scalars, in this order

#do not filter by herbarium code for SEINET
#read all records
#if ($institutionCode !~ m/^ */){




##################Exclude non-vascular plants
	if($family =~ /(Psoraceae|Bryaceae|Wrangeliaceae|Sargassaceae|Ralfsiaceae|Chordariaceae|Porrelaceae|Mielichhoferiaceae Schimp.|Mielichhoferiaceae|Lessoniaceae|Laminariaceae|Dictyotaceae)/){	#if $family is equal to one of the values in this block
	#print  ("Non-vascular herbarium specimen (1) $institutionCode==>$family==>$scientificName\t$CCH2id\n");	#skip it, printing this error message
		++$temp_skipped;
		next Record;
	}
	
	if($phylum =~ /^(Anthocero|Ascomycota|Bryophyta|Chlorophyta|Rhodophyta|Marchant)/){	#if $class is equal to one of the values in this block
	#print  ("Non-vascular herbarium specimen (2) $institutionCode==>$family==>$scientificName\t$CCH2id\n");	#skip it, printing this error message
		++$temp_skipped;
		next Record;
	}
	
	if($class =~ /^(Anthocero|Ascomycota|Bryophyta|Chlorophyta|Rhodophyta|Marchant)/){	#if $class is equal to one of the values in this block
	#print  ("Non-vascular herbarium specimen (3) $institutionCode==>$family==>$scientificName\t$CCH2id\n");	#skip it, printing this error message
		++$temp_skipped;
		next Record;
	}
	
# if collection code contains the word "NONVASC", "OSCB" [OSC Bryophyte Herbarium], etc., skip the record
	if($collectionCode=~/(NONVASC|OSCB)/){
	#print  ("Non-vascular herbarium specimen (4) $institutionCode==>$family==>$scientificName\t$id\n");	
		++$temp_skipped;
		next Record;
	}


#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;

++$found;


########PROCESSING
$countyB = $county;
$countryB = $country;
$stateProvinceB = $stateProvince;

$countyB =~ s/\*//g;
$countryB =~ s/\*//g;
$stateProvinceB =~ s/\*//g;
$countyB =~ s/^( *county|[0-9]+ *[A-Z].+|:Los Angeles|\?|AZ|CRJ|Ca\. 3\.0 air miles E of Castella|California|[A-Z]\.[A-Z]\.[A-Z]\.|[A-Z]\.[A-Z]\.|Do|GMA|L\.|MEN|MAR|MNJT|N\/A|no data|pon|Pma|San|The last of the large.+|USA|United States|\[?not stated\]?|[0-9]+|county unknown\.?|-|unk[now]*|null|plantae)$//ig;
$countryB =~ s/^(-|unknown|null|plantae)$//ig;
$stateProvinceB =~ s/^(ca|Calfiornia|Califonia|Calilfornia|Califronia|Califor|Inyo|Lower Colorado Desert|Napa|-|unknown|null|no data|USA)$//ig;

if ($stateProvince =~ m/^(ca|Calfiornia|Califonia|Calilfornia|Califronia|Califor)$/ig){
	$stateProvince = "California";
++$badST;
}

if ($stateProvince =~ m/^(Inyo|Napa)$/ig){
	$county = $1;
	$stateProvince = "California";
++$badCO;
}


#$stateProvince =~ s/^(\*|-|unknown|null|no data|USA)$//ig;
#$country =~ s/^(\*|-|unknown|null|plantae)$//ig;
#$county =~ s/^( *county|[0-9]+ *[A-Z].+|:Los Angeles|\?|AZ|CRJ|Ca\. 3\.0 air miles E of Castella|California|[A-Z]\.[A-Z]\.[A-Z]\.|[A-Z]\.[A-Z]\.|Do|GMA|L\.|MAR|MNJT|N\/A|no data|pon|Pma|San|The last of the large.+|USA|United States|\[?not stated\]?|[0-9]+|county unknown\.?|-|unk[now]*|null|plantae)$//ig;
#$county =~ s/^:Los Angeles$/Los Angeles/ig;
#$county =~ s/^MEN$/Mendocino/ig;

#find null values and extract them only
if ((length ($countryB) >= 1) && (length ($stateProvinceB) >= 1) && (length ($countyB) >= 1)){
	++$SKIP;
	#print $countryB."                   \n" unless $seen{$countryB}++;
	#print $stateProvinceB"                   \n" unless $seen{$stateProvinceB}++;
	#print $countyB."                   \n" unless $seen{$countyB}++;
}
elsif ((length ($countryB) == 0) && (length ($stateProvinceB) == 0) && (length ($countyB) == 0)){
	++$NULLA;
	

#print records to output file
print OUT join("\t",
$institutionCode,
$CCH2id,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$scientificName,
$taxonID,
$taxonRemarks,
$identificationQualifier,
$identifiedBy,
$dateIdentified,
$identificationRemarks,
$typeStatus,
$recordedBy,
$associatedCollectors,
$recordNumber,
$year,
$month,
$day,
$verbatimEventDate,
$country,
$stateProvince,
$county,
$locality,
$locationRemarks,
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,
$georeferenceSource,
$georeferenceRemarks,
$minimumElevationInMeters,
$maximumElevationInMeters,
$verbatimElevation,
$habitat,
$occurrenceRemarks,
$associatedTaxa,
$verbatimAttributes,
$reproductiveCondition,
$cultivationStatus,
$modified
),"\n";

}
elsif ((length ($countryB) >= 1) && (length ($stateProvinceB) == 0) && (length ($countyB) == 0)){
	++$NULLB;

#print records to output file
print OUT join("\t",
$institutionCode,
$CCH2id,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$scientificName,
$taxonID,
$taxonRemarks,
$identificationQualifier,
$identifiedBy,
$dateIdentified,
$identificationRemarks,
$typeStatus,
$recordedBy,
$associatedCollectors,
$recordNumber,
$year,
$month,
$day,
$verbatimEventDate,
$country,
$stateProvince,
$county,
$locality,
$locationRemarks,
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,
$georeferenceSource,
$georeferenceRemarks,
$minimumElevationInMeters,
$maximumElevationInMeters,
$verbatimElevation,
$habitat,
$occurrenceRemarks,
$associatedTaxa,
$verbatimAttributes,
$reproductiveCondition,
$cultivationStatus,
$modified
),"\n";
	
}
elsif ((length ($countryB) >= 1) && (length ($stateProvinceB) >= 1) && (length ($countyB) == 0)){
	++$NULLC;

#print records to output file
print OUT join("\t",
$institutionCode,
$CCH2id,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$scientificName,
$taxonID,
$taxonRemarks,
$identificationQualifier,
$identifiedBy,
$dateIdentified,
$identificationRemarks,
$typeStatus,
$recordedBy,
$associatedCollectors,
$recordNumber,
$year,
$month,
$day,
$verbatimEventDate,
$country,
$stateProvince,
$county,
$locality,
$locationRemarks,
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,
$georeferenceSource,
$georeferenceRemarks,
$minimumElevationInMeters,
$maximumElevationInMeters,
$verbatimElevation,
$habitat,
$occurrenceRemarks,
$associatedTaxa,
$verbatimAttributes,
$reproductiveCondition,
$cultivationStatus,
$modified
),"\n";
	
}
elsif ((length ($countryB) >= 1) && (length ($stateProvinceB) == 0) && (length ($countyB) >= 1)){
	++$NULLD;

#print records to output file
print OUT join("\t",
$institutionCode,
$CCH2id,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$scientificName,
$taxonID,
$taxonRemarks,
$identificationQualifier,
$identifiedBy,
$dateIdentified,
$identificationRemarks,
$typeStatus,
$recordedBy,
$associatedCollectors,
$recordNumber,
$year,
$month,
$day,
$verbatimEventDate,
$country,
$stateProvince,
$county,
$locality,
$locationRemarks,
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,
$georeferenceSource,
$georeferenceRemarks,
$minimumElevationInMeters,
$maximumElevationInMeters,
$verbatimElevation,
$habitat,
$occurrenceRemarks,
$associatedTaxa,
$verbatimAttributes,
$reproductiveCondition,
$cultivationStatus,
$modified
),"\n";
	
}
elsif ((length ($countryB) == 0) && (length ($stateProvinceB) >= 1) && (length ($countyB) == 0)){
	++$NULLE;

#print records to output file
print OUT join("\t",
$institutionCode,
$CCH2id,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$scientificName,
$taxonID,
$taxonRemarks,
$identificationQualifier,
$identifiedBy,
$dateIdentified,
$identificationRemarks,
$typeStatus,
$recordedBy,
$associatedCollectors,
$recordNumber,
$year,
$month,
$day,
$verbatimEventDate,
$country,
$stateProvince,
$county,
$locality,
$locationRemarks,
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,
$georeferenceSource,
$georeferenceRemarks,
$minimumElevationInMeters,
$maximumElevationInMeters,
$verbatimElevation,
$habitat,
$occurrenceRemarks,
$associatedTaxa,
$verbatimAttributes,
$reproductiveCondition,
$cultivationStatus,
$modified
),"\n";
	
}
elsif ((length ($countryB) == 0) && (length ($stateProvinceB) >= 1) && (length ($countyB) >= 1)){
	++$NULLF;

#print records to output file
print OUT join("\t",
$institutionCode,
$CCH2id,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$scientificName,
$taxonID,
$taxonRemarks,
$identificationQualifier,
$identifiedBy,
$dateIdentified,
$identificationRemarks,
$typeStatus,
$recordedBy,
$associatedCollectors,
$recordNumber,
$year,
$month,
$day,
$verbatimEventDate,
$country,
$stateProvince,
$county,
$locality,
$locationRemarks,
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,
$georeferenceSource,
$georeferenceRemarks,
$minimumElevationInMeters,
$maximumElevationInMeters,
$verbatimElevation,
$habitat,
$occurrenceRemarks,
$associatedTaxa,
$verbatimAttributes,
$reproductiveCondition,
$cultivationStatus,
$modified
),"\n";
	
}
elsif ((length ($countryB) == 0) && (length ($stateProvinceB) ==0) && (length ($countyB) >= 1)){
	++$NULLH;
#print records to output file
print OUT join("\t",
$institutionCode,
$CCH2id,
$occurrenceID,
$catalogNumber,
$otherCatalogNumbers,
$scientificName,
$taxonID,
$taxonRemarks,
$identificationQualifier,
$identifiedBy,
$dateIdentified,
$identificationRemarks,
$typeStatus,
$recordedBy,
$associatedCollectors,
$recordNumber,
$year,
$month,
$day,
$verbatimEventDate,
$country,
$stateProvince,
$county,
$locality,
$locationRemarks,
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,
$georeferenceSource,
$georeferenceRemarks,
$minimumElevationInMeters,
$maximumElevationInMeters,
$verbatimElevation,
$habitat,
$occurrenceRemarks,
$associatedTaxa,
$verbatimAttributes,
$reproductiveCondition,
$cultivationStatus,
$modified
),"\n";
	
}
else{
	++$NULLG;
	print "BAD RECORDS: ($countryB==>$stateProvinceB==>$countyB)\n";
	
}


#find null values and extract them only
if ((length ($countryB) >= 1) && (length ($stateProvinceB) >= 1) && (length ($countyB) >= 1)){
#exclude the records with non-NULL geography
}
else{
my $oldA = "";

# filter out herbarium code YM-YOSE
#read all records
if ($institutionCode !~ m/^YM-YOSE$/){

#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;

########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$temp_skipped;
		next Record;
	}


#extract old herbarium and aid numbers

if (length ($otherCatalogNumbers) >= 1){

	$otherCatalogNumbers=~ s/^(LAbREEZ|LAB)(\d+)/LA$2/i; #fix some lack of problem accessions with erroneous prefixes
	$otherCatalogNumbers =~ s/(smith|frenk|\\+|\]+|`)//i; #fix some odd typos in CAS,OBI accessions
	$otherCatalogNumbers =~ s/^(Bartle.+|[A-Z]+[;:-]?|q|[A-Za-z]\.[A-Za-z]\.)$//; #make other cat num that are all caps NULL
	$otherCatalogNumbers =~ s/^\d\d\d+ *[;,] +\d\d\d+$//;
	$otherCatalogNumbers =~ s/^\d\d\d+ ?[;,] \d\d\d+ ?[;,] \d*N?O?N?E?$//; #make some odd other cat numbers NULL; cannot map these
	$otherCatalogNumbers =~ s/^(\d\d?),(\d\d\d)$/$1$2/; #remove thousands comma from some all digit other cat numbers
	$otherCatalogNumbers =~ s/[;,] (NONE|CHIS[:;-]?|937\.|\d+)$//i;
	$otherCatalogNumbers =~ s/^C?A?\d+-\d+$//; #make some odd other cat numbers NULL; cannot map these
	$otherCatalogNumbers =~ s/^(UC1755388.+|EPLA.+|TRPA.+|CUSU.+|EPLA.+|SARE.+|JUCO.+|PICO30.+|UC1755\d+, ?permit.+|UCx.+|No do Exem.+|No\. Reg.+|17 PNV.+|HBR.+|BHCB.+|CETEC.+|Photo.+|Bryophyte.+|NON[Ee]|Colom.+|USFs.+|SHEET.+|PLOT.+|HERB.+|Field.+|NO\.: ?\d+.+)$//i; #make some other cat numbers NULL; cannot map these
	$otherCatalogNumbers =~ s/^(EPHO.+|PSSI.+|SCCL.+|No\. [SU].+|No\. ?[:;]? ?[SU].+|No\. ?[:;]? \d+.+|L\.U\..+|Knapp.+|Study.+|Object.+|[O0] 326.+|old cat.+|\#.+|ERLI.+|PHCH.+|ASKE.+|CACO.+|ERVA.+|POPU.+|STAC.+|ALBI.+)$//i; #make some other cat numbers NULL; cannot map these
	$otherCatalogNumbers =~ s/^csusb/CSUSB/i; #fix some lack of capitalizations in CSUSB, MACF accessions
	$otherCatalogNumbers =~ s/^(macf|M17 miles ACF)/MACF/i;
	$otherCatalogNumbers =~ s/^(IRVC173F4|1111c|o55811|777c|urn:catalog:CAS:DS:592648|335; 14,710|122273SBBG170709|2 Apr 1992|4622-|63003q|y\.?\d+|\d+ of.+|frag.+|Peirson.+|acc \d+|\? \(.+)$//i;#problem number with blank CatNumber record
	$otherCatalogNumbers =~ s/^irvc/IRVC/i;
	$otherCatalogNumbers =~ s/^['`]$/NULL/;#
	$otherCatalogNumbers =~ s/['`]//g;#
	$otherCatalogNumbers =~ s/(\d+)[,;] (Lemmon.+|UC Herbarium.+|CHIS-?00375.*|CABR-.+)$/$1/;
	$otherCatalogNumbers =~ s/(\d+)[; ]CHIS-00375.*$/$1/;
	$otherCatalogNumbers =~ s/^(\d+); [6A].+$/$1/;
	$otherCatalogNumbers =~ s/^67[89]\d\d[^\d]+//;#odd accessions with unconvertible characters in UCSB specimens
	$otherCatalogNumbers =~ s/^\d+[^[^\dA-Za-z]\d+$//; #skip missing digits in RSA numbers
	$otherCatalogNumbers =~ s/^\d+[^\dA-Za-z]$//; #skip missing digits in RSA numbers
	$otherCatalogNumbers =~ s/^\d+ +d+$//; #skip missing digits in RSA numbers
	$otherCatalogNumbers =~ s/^\d+\.\d+$//i; #skip decimal
	$otherCatalogNumbers =~ s/ +$//g;


	if ($otherCatalogNumbers =~ m/^(NULL| *)$/){
		$otherID="";
		$herbcode="";
		$otherCatalogNumbers = "";
		$old_AID="";
		$oldA="";
	}
	elsif ($otherCatalogNumbers =~ m/\| (CAS|DS) (\d+)([a-zA-z]*)$/){ #unique to CAS
		$otherID=$2;
		$herbcode=$1;
		$old_AID=$herbcode.$otherID;
		$old_AID=~ s/ //g; #remove spaces that are popping up
		$oldA=$herbcode.$otherID;;
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(CAS|DS) (\d+)[ABCD]?$/){ #unique to CAS
		$otherID=$2;
		$herbcode=$1;
		$old_AID=$herbcode.$otherID;
		$old_AID=~ s/ //g; #remove spaces that are popping up
		$oldA=$herbcode.$otherID;
		#print "HERB(2)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(A[0-9-]+)[AB]?$/){#unique to CLARK, example: A1528-1001B
		$otherID=$1;
		$old_AID="CLARK-".$otherID;
		$oldA = "";
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(CSUSB)-([0-9]+)-?[ABCDEFGHI]?$/){ #CSUSB has dashes, like several others: CSUSB-54
														#remove dashes for CCH1 accessions
		$otherID=$2;
		$old_AID=$1.$otherID;
		$oldA = $1."-".$otherID;;
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(DAV|AHUC)([0-9]+)[A-Z]*; *(UCD[0-9]+)$/){ #DAV is unique as it has a combined otherCatalogNumber field
														#it has to be split into two components, one is the old CCH AID; DAV122395; UCD125896
		$otherID = $2;
		$herbcode = $1;
		$old_AID = $3;
		$oldA = $herbcode.$otherID;
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(AV|DV|DA|DAAV|DAC|DAVA|DFAV)([0-9]+); *(UCD[0-9]+)$/){ #DAV has typo herbarium codes in the otherCatalogNumber field
														#it has to be split into two components, one is the old CCH AID; DAV122395; UCD125896
		$otherID = $2;
		$herbcode = "DAV";
		$old_AID = $3;
		$oldA = $herbcode.$otherID;
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(HUC|AHUCL|AUHC|AUHC|AHUCA|AUC|AHUV)([0-9]+); *(UCD[0-9]+)$/){ #DAV has typo herbarium codes in the otherCatalogNumber field
														#it has to be split into two components, one is the old CCH AID; DAV122395; UCD125896
		$otherID = $2;
		$herbcode = "AHUC";
		$old_AID = $3;
		$oldA = $herbcode.$otherID;
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(JOTR|PORE|YOSE|OSE)([0-9]+); *(UCD[0-9]+)$/){ #DAV some other accessioned entered in the otherCatalogNumber field
														#it has to be split into two components, one is the old CCH AID; DAV122395; UCD125896
														#YOSE is Yousemite, PORE is Point Reyes
		$old_AID = $3;
		$oldA = "";
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^LA(\d+)\.[12]$/){ 
	#Dicks 2012 script seemed to strip off the letters or number suffix's and only added one of the duplicate
	#who knows which one was loaded, so strip these off so they are added to the duplicate list
		$otherID=$1;
		$old_AID="LA".$otherID;
		$oldA="";
		#print "HERB(2)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(\d+)[,;] (CHIS|CABR)-\d+[:;] ?(\d+)$/){ 
		$otherID=$1;
		$old_AID=$institutionCode.$otherID;
		$oldA="";
		#remove leading zeros for the old CCH AID
			if ($old_AID =~ m/^(SBBG)0+([1-9][0-9])[A-Z]?$/){
				$oldA=$1.$2;
			#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
			}

		#print "HERB(2)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(\d+)[,;] (CHIS)-\d+[:;] ?(\d+)[:;] JSTOR.+$/){ 
		$otherID=$1;
		$old_AID=$institutionCode.$otherID;
		$oldA="";
		#remove leading zeros for the old CCH AID
			if ($old_AID =~ m/^(SBBG)0+([1-9][0-9])[A-Z]?$/){
				$oldA=$1.$2;
			#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
			}

		#print "HERB(2)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(CABR|CHIS)-\d+: ?(\d+)$/){ 
		$otherID = "";
		$old_AID = "";
		$oldA = "";
		#print "HERB(2)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(\d+)[,;] JSTOR.+$/){ 
		$otherID=$1;
		$old_AID=$institutionCode.$otherID;
		$oldA = "";
		#remove leading zeros for the old CCH AID
			if ($old_AID =~ m/^(SBBG)0+([1-9][0-9])[A-Z]?$/){
				$oldA=$1.$2;
			#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
			}

		#print "HERB(2)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(UCR)-?(\d+)$/){ 
		$otherID=$2;
		$herbcode=$1;
		$old_AID=$herbcode.$otherID;
		$oldA=$herbcode.$otherID;
		
	#remove leading zeros for the old CCH AID
			if ($oldA =~ m/^(UCR)0+([1-9][0-9])?$/){
				$old_AID=$1.$2;
			#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
			}


		#print "HERB(2)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(UCR)-?(\d+)\.[1-9][1]?$/){ 
		$otherID=$2;
		$herbcode=$1;
		$old_AID=$herbcode.$otherID;
		$oldA=$herbcode.$otherID;
		
			if ($oldA =~ m/^(UCR)0+([1-9][0-9])?$/){
				$old_AID=$1.$2;
			#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
			}

		#print "HERB(2)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($otherCatalogNumbers =~ m/^(\d+)[AaBbCDEFGHIJK]?$/){#SPIF has CDEFGHIJK at the end of its othercat nums
		$otherID=$1;
		$herbcode="";
		
		if ($collectionCode =~ m/^(RSA|POM)$/){ #unique to RSA
			$herbcode=$collectionCode;#assign herbcode to collection code
			$old_AID=$herbcode.$otherID;
			$oldA="";
			#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
		}
		elsif ($collectionCode =~ m/^(NULL| *)$/){
			$herbcode="";
			$old_AID=$institutionCode.$otherID;
			$oldA="";
			#print "HERB(2)\t$herbcode$aid==>$_\n";
		}
		else{
		$herbcode="";
			$old_AID=$institutionCode.$otherID;
			$oldA="";
		}
		
		if ($institutionCode =~ m/^(UCSC)$/){
		
			$old_AID = $oldA = $institutionCode.$otherID;#add the herbarium code
		
	#add leading zeros for the alternate old CCH AID, CCH2 removed those zeros when loaded

		if ($otherID =~ m/^(\d\d\d\d\d)$/){
			$oldA = $herb."0".$otherID;
			++$found;
		print "HERB(1a)\t$old_AID==>$otherCatalogNumbers==>$oldA\n";
		}
		elsif ($otherID =~ m/^(\d\d\d\d)$/){
			$oldA = $herb."00".$otherID;
			++$found;
		print "HERB(1b)\t$old_AID==>$otherCatalogNumbers==>$oldA\n";
		}
		elsif ($otherID =~ m/^(\d\d\d)$/){
			$oldA = $herb."000".$otherID;
			++$found;
		print "HERB(1c)\t$old_AID==>$otherCatalogNumbers==>$oldA\n";
		}
		elsif ($otherID =~ m/^(\d\d)$/){
			$oldA = $herb."0000".$otherID;
			++$found;
		print "HERB(1d)\t$old_AID==>$otherCatalogNumbers==>$oldA\n";
		}
		elsif ($otherID =~ m/^(\d)$/){
			$oldA = $herb."00000".$otherID;
			++$found;
		print "HERB(1e)\t$old_AID==>$otherCatalogNumbers==>$oldA\n";
		}
		else{
			$oldA = "";
		}
	}
	elsif ($otherCatalogNumbers =~ m/^([A-Z]+)(\d+)$/){
		$oldA=$1.$2;
		$old_AID=$oldA;
		  	#remove leading zeros for the old CCH AID
			if ($oldA =~ m/^([A-Z]+)0+([1-9][0-9]*)$/){
				$old_AID=$1.$2;
			}
	}
	elsif ($otherCatalogNumbers =~ m/^([A-Z]+)-? *(\d+)[abBA]?_?.?$/){
		$oldA=$1.$2;
		$old_AID=$oldA;
		  	#remove leading zeros for the old CCH AID
			if ($oldA =~ m/^([A-Z]+)0+([1-9][0-9]*)$/){
				$old_AID=$1.$2;
			}
	}
	else{
			&CCH::log_change("BAD otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
			#print "BAD otherCatalogNumbers($institutionCode)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
			$otherID="";
			$herbcode="";
			$otherCatalogNumbers = "";
			$oldA="";
			$old_AID="";
			
	}
}
else{
		$otherID="";
		$herbcode="";
		$otherCatalogNumbers = "";
		$oldA="";
		$old_AID="";
}
#construct catalog numbers
#catalog numbers are RSA barcodes and these have leading zeros
#skip removing leading zeros, as this is new and I think we can skip any linked resources that use the barcodes without leading zeros
#they probably were not added to CCH1 without zeros anyway,  If they were, it was by mistake
if (length ($catalogNumber) >= 1){

	$catalogNumber =~ s/^csusb/CSUSB/i; #fix some lack of capitalizations in CSUSB,FSC, CHSC, IRVC, UCSB accessions
	$catalogNumber =~ s/^fsc/FSC/i;
	$catalogNumber =~ s/^rsa/RSA/i;
	$catalogNumber =~ s/^ucsb/UCSB/i;
	$catalogNumber =~ s/^ucr/UCR/i;
	$catalogNumber =~ s/^irvc/IRVC/i;
	$catalogNumber =~ s/^sbbg/SBBG/i;
	$catalogNumber =~ s/^(SFSU)-VP-/SFSU/i;
	$catalogNumber =~ s/^chsc/CHSC/i;
	$catalogNumber =~ s/^(DAV\d+)DAV\d+$/$1/;
	$catalogNumber =~ s/[\+'`]//g;#
	$catalogNumber =~ s/[-\.]$//g;#
	$catalogNumber =~ s/ +[abcdef]$//g;
	$catalogNumber =~ s/^[A-Z]+$//g;#delete catalog numbers with only letters
	$catalogNumber =~ s/^(UC1194379UC1621689|UC1958246UC1958206|UC59D944|UC1182095UC1181095|UC998129UC750902|UCLA56172[^0-9]|UCR0078070 291187|UCR0065896 44197|UCR0082912 UCR0082911|UCR0083UCR0084836 901|420943UCSB010829|15860.+í|c|4RSA0080482|2RSA0130536|RSA0038W|RSA00M\/O|RSA00\.Y|RSA0126952mentzelia longiloba|iRSA0038593|RSA0004668f)$//; #make some odd other cat numbers NULL; cannot map these
	$catalogNumber =~ s/^([A-Z]+) (\d+)$/$1$2/;
	$catalogNumber =~ s/^(SCFS\d+) & SCFS5072/$1/;
	$catalogNumber =~ s/^(UCSC\d+), UCSC\d+$/$1/;
	$catalogNumber =~ s/^\d+ +d+$//; #skip missing digits in RSA numbers
	$catalogNumber =~ s/ +$//g;
	
	
	if ($catalogNumber =~ m/CAS:BOT-BC:(\d+)$/){
		$aid=$1;
		$aidcode="CAS-BOT-BC";
		$ALT_CCH_BARCODE=$aidcode.$aid;
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/^(CLARK-A)([0-9-]+)[AB]?$/){#unique to CLARK, it has multiple dashes in some accessions
		$aid=$2;
		$aidcode=$1;
		$ALT_CCH_BARCODE=$aidcode.$aid;
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/^(PASA)_?0+(\d+)$/){#eliminate leading zeros and the prefix variants
		$aid=$2;
		$aidcode=$1;
		$old_AID=$aidcode.$aid;
		$ALT_CCH_BARCODE = $catalogNumber; #this is needed and will have leading zeros included
		$ALT_CCH_BARCODE =~ s/_//g; #remove underscore in prefix
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/^(PASA)_?(\d+)$/){#variants without leading zeros
		$aid=$2;
		$aidcode=$1;
		$old_AID=$aidcode.$aid;
		$ALT_CCH_BARCODE = $catalogNumber; #this is needed and will have leading zeros included
		$ALT_CCH_BARCODE =~ s/_//g; #remove underscore in prefix
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/^H-(0+)([1-9][0-9]*)-?[AaBbCcDdEeFf\+]*\&?B?$/){
		$aid=$2;
		$old_AID="PGM".$aid;
		$ALT_CCH_BARCODE = $institutionCode.$1.$2;
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/^H-([1-9][0-9]*)-?[AaBbCcDdEeFf\+]*\&?B?$/){
		$aid=$1;
		$old_AID=$institutionCode.$aid;
		$ALT_CCH_BARCODE = $institutionCode.$1;
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/^H(0+)([1-9][0-9]*)-?[AaBbCcDdEeFf\+]*\&?B?$/){
		$old_AID=$ALT_CCH_BARCODE = "";
	#skip the accidental second load of PGM
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/^H([1-9][0-9]*)-?[AaBbCcDdEeFf\+]*\&?B?$/){
		$old_AID=$ALT_CCH_BARCODE = "";
	#skip the accidental second load of PGM
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/^(UCSB_SCIRH)(\d+)[A]?$/){
		$aid=$2;
		$aidcode=$1;
		$old_AID = $aidcode.$aid;
		$ALT_CCH_BARCODE = "";
		#print "HERB(3)\t$aidcode.$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n"
	}

	elsif ($catalogNumber =~ m/^(UCSB_SCIRH)(\d+[SANIBSCU]+\d+)[AB]?$/){
		$aid=$2;
		$aidcode=$1;
		$old_AID = $aidcode.$aid;
		$ALT_CCH_BARCODE = "";
		#print "HERB(4)\t$aidcode.$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n"
	}
	elsif ($catalogNumber =~ m/^(\d+)[AaBbCDd]?[r]?$/){
		$aid=$1;
		$aidcode=$institutionCode;
		$ALT_CCH_BARCODE = $aidcode.$aid;
		
		if ($institutionCode =~ m/^(SACT|JROH)$/){
			$old_AID = $ALT_CCH_BARCODE;
			if ($old_AID =~ m/^([A-Z]+)0+([1-9][0-9]*)$/){
				$old_AID=$1.$2;
			#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
			}
		}
		
	}
	elsif ($catalogNumber =~ m/^(\d+)\.[12]$/){
		$aid=$1;
		$aidcode="";
		$ALT_CCH_BARCODE = $institutionCode.$aid;
	}
	elsif ($catalogNumber =~ m/^([A-Z]+)(\d+)$/){
		$ALT_CCH_BARCODE = $1.$2;

		if ($institutionCode =~ m/^(CSLA|CHSC|JOTR|SFSU)$/){
			$old_AID = $ALT_CCH_BARCODE;
			if ($old_AID =~ m/^([A-Z]+)0+([1-9][0-9]*)$/){
				$old_AID=$1.$2;
			#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
			}
		}


	}
	elsif ($catalogNumber =~ m/^([A-Z]+)-?(\d+)[AaBbJCrR]?$/){
		$ALT_CCH_BARCODE = $1.$2;
	}
	elsif ($catalogNumber =~ m/^(NULL| *)$/){
		$otherID="";
		$herbcode="";
		$ALT_CCH_BARCODE = "";
		$catalogNumber = "";
		if ($institutionCode =~ m/^UCR$/){
			$oldA="";
		}

	}
	else{
		&CCH::log_change("BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD catalogNumber==>$CCH2id==>$catalogNumber\n";
		$aid="";
		$aidcode="";
		$catalogNumber = "";
		$ALT_CCH_BARCODE="NULL";
	}

}
else{
		$aid="";
		$aidcode="";
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
}
#Add prefix to unique identifier field, two format, choose one and add to the code above
#$ALT_CCH_BARCODE=$aidcode.$aid;
#$ALT_CCH_BARCODE=$herb.$catalogNumber;
#$ALT_CCH_BARCODE=$catalogNumber; #use this format if the old CCH herbarium code is correctly added in the catalog number field

$name=&strip_name($scientificName);

if ($countyB =~ m/^( *|NULL)$/){
	$countyB = "NULL";
}

	if (($catalogNumber =~ m/^( *|NULL)$/) && ($otherCatalogNumbers =~ m/^( *|NULL)$/)){
				&log_skip("$herb ALL AIDs NULL: $CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");	#run the &log_skip function, printing the following message to the error log
				++$null;

	}
	elsif ($SEI{$ALT_CCH_BARCODE}){
			++$skip;
	
	}
	
	elsif ($FOUND{$CCH2id}){
			++$dups;
	
	}
	else{
			print OUT2 "$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tNONDUP\t$occurrenceID\t$name\t$countyB\n";
#print "INCL $old_AID\n";
			++$included;
	}	
	
	
}

}

}
print <<EOP;
INCL: $found

Country State County Not NULL: $SKIP
Country State County NULL: $NULLA
Country State County NULL: $NULLB
Country State County NULL: $NULLC
Country State County NULL: $NULLD
Country State County NULL: $NULLE
Country State County NULL: $NULLF
Country State County NULL: $NULLH

Remainder: $NULLG

BAD Records: $temp_skipped

BAD State: $badST
BAD County: $badCO

CCH2 problem GEO added: $included
NULL: $null
DUPS: $dups

EOP


close(IN);
close(OUT2);
close(OUT3);
