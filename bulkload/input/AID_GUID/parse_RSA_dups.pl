
#use strict;
#use warnings;
#use diagnostics;
use lib '/Users/Shared/Jepson-Master/Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev
my $today_JD;
$today_JD = &get_today_julian_day;

#for this lead, RSA has a unique file as the herbarium code is in the collection code field
#no other herbaria uses this field for catalog number or barcode data
#$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.
$herb="RSA_POM";
#$filedate="11072019";
$filedate2="12052019";
$filedate="01292020";

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

#special RSA file for linking collection code
open(IN,'/Users/Shared/Jepson-Master/CCHV2/bulkload/input/CCH2-exports/CCH2_RSA_export_'.$filedate2.'.txt') || die;
while(<IN>){
	chomp;
next if (m/^#/);
#InstitutionCode	occid	catalogNumber	collectionCode	otherCatalogNumbers	guid	initialtimestamp	dateEntered	dateLastModified

	($IC,$OC,$CN,$CC,$OCN,$G,$ITS,$DE,$DM)=split(/\t/);
	$UUID = $OC.$OCN;
	$code_found{$UUID}=$CC;

}
close(IN);



open(OUT, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_".$herb."_list.txt") || die; #this only needs to be active once to generate a list of duplicated accessions

	print OUT "CCH2_catalogNumber\tCCH2_catalogNumber\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\n";

#log.txt is used by logging subroutines in CCH.pm
#unlink $log_file or warn "making new error log file $log_file";


#id	type	modified	language	institutionCode	collectionCode	basisOfRecord	occurrenceID	catalogNumber	occurrenceRemarks	recordNumber	recordedBy	otherCatalogNumbers	eventDate	startDayOfYear	year	month	day	verbatimEventDate	habitat	higherGeography	continent	country	stateProvince	county	municipality	locality	verbatimElevation	minimumElevationInMeters	maximumElevationInMeters	verbatimLatitude	verbatimLongitude	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	georeferenceProtocol	georeferenceVerificationStatus	identifiedBy	dateIdentified	typeStatus	scientificName	higherClassification	kingdom	phylum	class	order	family	genus	specificEpithet	infraspecificEpithet	verbatimTaxonRank	scientificNameAuthorship	nomenclaturalCode
#urn:catalog:CAS:BOT-BC:522744	PhysicalObject	2016-10-19 09:19:30.0	en	CAS	BOT-BC	PreservedSpecimen	urn:catalog:CAS:BOT-BC:522744	522744	Shrub 10 feet tall	41804	Breedlove, D E	urn:catalog:CAS:DS:702772 | DS 702772	1976-11		1976	11		22 November 1976	Steep slopes and dry ravines	North America; Mexico; Chiapas; Amatenango de la Frontera Municipio	North America	Mexico	Chiapas	Amatenango de la Frontera Municipio		along Río Cuilco between Nuevo Amatenango and Frontera Comalapa	1100 m	1100	1100												Croton guatemalensis  Lotsy	Plantae; Magnoliophyta; Magnoliopsida; Euphorbiales; Euphorbiaceae	Plantae	Magnoliophyta	Magnoliopsida	Euphorbiales	Euphorbiaceae	Croton	guatemalensis			Lotsy	ICBN

my $mainFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/CCH2-exports/CCH2_export_'.$filedate.'.txt';
open (IN, $mainFile) or die $!;
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

#id	institutionCode	collectionCode	ownerInstitutionCode	basisOfRecord	occurrenceID	catalogNumber	otherCatalogNumbers
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
#kingdom	phylum	class	order	family	scientificName	taxonID	scientificNameAuthorship	genus	specificEpithet	
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
$identifiedBy,
#20
#taxonRank	infraspecificEpithet	identifiedBy	dateIdentified	identificationReferences	identificationRemarks	
#taxonRemarks	identificationQualifier	typeStatus	recordedBy	associatedCollectors	recordNumber	eventDate	
$dateIdentified,
$identificationReferences,	#added 2015, not processed
$identificationRemarks,	#added 2015, not processed
$taxonRemarks,	#added 2015
$identificationQualifier,
$typeStatus,
$recordedBy,
##$recordedByID,			#added 2016, not in 2017 download
$associatedCollectors,	#added 2016, not in 2017 download, combined within recorded by with a ";"
$recordNumber,
$eventDate,
#30
#year	month	day	startDayOfYear	endDayOfYear	verbatimEventDate	occurrenceRemarks	habitat	substrate	
$year,
$month,
$day,
$startDayOfYear,
$endDayOfYear,
$verbatimEventDate,
$occurrenceRemarks,
$habitat,
$substrate,			#added 2016
$verbatimAttributes, #added 2016
#40
#verbatimAttributes	fieldNumber	informationWithheld	dataGeneralizations	dynamicProperties	associatedTaxa	
#reproductiveCondition	establishmentMeans	cultivationStatus	lifeStage	
$fieldNumber,
$informationWithheld,
$dataGeneralizations,	#added 2015, not processed, field empty as of 2016
$dynamicProperties,	#added 2015, not processed
$associatedTaxa,
$reproductiveCondition,
$establishmentMeans,	#added 2015, not processed
$cultivationStatus,	#added 2016
$lifeStage,
$sex,	#added 2015, not processed
#50
#sex	individualCount	preparations	country	stateProvince	county	municipality	locality	
#locationRemarks	localitySecurity
$individualCount,	#added 2015, not processed
$preparations,	#added 2015, not processed
$country,
$stateProvince,
$county,
$municipality,
$locality,
$locationRemarks, #newly added 2015-10, not processed
$localitySecurity,		#added 2016, not processed
$localitySecurityReason,	#added 2016, not processed
#60
#localitySecurityReason	decimalLatitude	decimalLongitude	geodeticDatum	
#coordinateUncertaintyInMeters	verbatimCoordinates	georeferencedBy	georeferenceProtocol	
$verbatimLatitude,
$verbatimLongitude,
$geodeticDatum,
$coordinateUncertaintyInMeters,
$verbatimCoordinates,
$georeferencedBy,	#added 2015, not processed
$georeferenceProtocol,	#added 2015, not processed
$georeferenceSource,
$georeferenceVerificationStatus,	#added 2015, not processed
$georeferenceRemarks,	#added 2015, not processed
#70
#georeferenceRemarks	minimumElevationInMeters	
#maximumElevationInMeters	minimumDepthInMeters	maximumDepthInMeters	verbatimDepth	verbatimElevation	disposition	
#language	recordEnteredBy
$minimumElevationInMeters,
$maximumElevationInMeters, #not processed for now
$minimumDepthInMeters, #newly added 2015-10, not processed
$maximumDepthInMeters, #newly added 2015-10, not processed
$verbatimDepth, #newly added 2015-10, not processed
$verbatimElevation,
$disposition,	#added 2015, not processed
$language,	#added 2015, not processed
$recordEnteredBy, #newly added 2015-10, not processed
$modified,	#added 2015, not processed
#80
#modified	sourcePrimaryKey-dbpk	collId	recordId	references
$sourcePrimaryKey,  #added 2016, not processed
$collID,	#added 2016, not processed
$recordId,	#added 2015, not processed
$references	#added 2016, not processed
)=@fields;	#The array @columns is made up on these 85 scalars, in this order


#filter by herbarium code
if ($institutionCode =~ m/^RSA/){

#special variable for linking collectionCode
	$cchUUID = $CCH2id.$otherCatalogNumbers;

#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;



########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$skipped{one};
		next Record;
	}

my $oldA="";
	$catalogNumber =~ s/(mentzelia longiloba|-)//i; #fix some odd typos in RSA accessions
	$catalogNumber =~ s/^(RSA0038W|c|RSA00\.Y|4|RSA00M\/O|272638|103693|140480)$/NULL/i; #make some odd typos in RSA accessions NULL
	$catalogNumber =~ s/[`'.f]$//; #delete some odd typos in RSA accessions

			#272638 are the old RSA accessions added to the barcode field, when barcoded these all will disappear
	$catalogNumber =~ s/^(4RSA|JA|TA|rsa|iRSA|TSA|2RSA)(\d+)$/RSA$2/; #fix some odd typos in RSA barcodes, must have been hand-typed
	$otherCatalogNumbers =~ s/^(S3395|25286\?|1616\?5|226\?71)$/NULL/i; #make some bad RSA accessions NULL
	$otherCatalogNumbers =~ s/[`'.f]$//; #delete some odd typos in RSA accessions
	$otherCatalogNumbers =~ s/^708 21/70821/; 
	$otherCatalogNumbers =~ s/^535-43/53543/; 
	$otherCatalogNumbers =~ s/^593478.+/593478/;


#extract old herbarium and aid numbers
if (length ($otherCatalogNumbers) >= 1){

	if ($code_found{$cchUUID}){
		$collectionCode = $code_found{$cchUUID};
	#print "$collectionCode\n";
	}
	else{

		if ($CCH2id =~ m/^(1088045|793322|1189952|687312)$/){
			$collectionCode = "RSA"; #fix some vascular plants without collection codes that are being skipped
		}
		else{
			$collectionCode = "NONVASC";
		}
	}


	if ($otherCatalogNumbers =~ m/^(\d+)[AaBb]?$/){ #RSA has original accessions without herbarium codes
		$otherID=$1;
		
		if ($collectionCode =~ m/^(RSA|POM)$/){ #unique to RSA
			$old_AID=$collectionCode.$otherID;#assign herbcode to collection code
			
			#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
		}
		elsif ($collectionCode =~ m/^(NULL| *)$/){
			&CCH::log_change("WARNING collectionCode NULL, RSA used instead ($collectionCode)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
			#assign RSA to collection code
			$old_AID="RSA".$otherID;
			print "HERB(2)\t$old_AID==>$_\n";
		}
		elsif ($collectionCode =~ m/^NONVASC$/){
			&CCH::log_change("SKIPPING POSSIBLE NONVASCULAR==>$_");
			$collectionCode = "";
			$otherID="";
			$otherCatalogNumbers = "";
			$old_AID="";
			#mostly not found taxa due to being non-vasculars, print to log file only so that any errors might be located
		}
		else{
			&CCH::log_change("BAD collectionCode ($collectionCode)s==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
			print "BAD collectionCode ($collectionCode)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
			$collectionCode = "";
			$otherID="";
			$otherCatalogNumbers = "";
			$old_AID="";
		}
	}
	elsif ($otherCatalogNumbers =~ m/NULL/){
		$otherID="";
		$otherCatalogNumbers = "";
		$old_AID="";
	}
	else{
			&CCH::log_change("BAD otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
			print "BAD otherCatalogNumbers($collectionCode)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
			$otherID="";
			$otherCatalogNumbers = "";
			$old_AID="";
	}
}
else{
		$otherCatalogNumbers = "";
		$old_AID="";
}

#convert to form without leading zeros
	if ($old_AID =~ m/^(RSA|POM)0+(\d+)$/){
		$oldA = $old_AID;
		$old_AID=$1.$2;
		#print "HERB(2)\t$oldA\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n"";
	}
	
#construct catalog numbers
#catalog numbers are RSA barcodes and these have leading zeros
#skip removing leading zeros, as this is new and I think we can skip any linked resources that use the barcodes without leading zeros
#they probably were not added to CCH1 without zeros anyway,  If they were, it was by mistake
if (length ($catalogNumber) >= 1){

	if ($catalogNumber =~ m/^(RSA)(\d+)$/){
		$ALT_CCH_BARCODE=$1."-BC".$2;
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/NULL/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
	}
	else{
		&CCH::log_change("BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD catalogNumber==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
	}
}
else{
		$catalogNumber = "";
		$ALT_CCH_BARCODE="";
}
#Add prefix to unique identifier field, two format, choose one and add to the code above
#$ALT_CCH_BARCODE=$aidcode.$aid;
#$ALT_CCH_BARCODE=$herb.$catalogNumber;
#$ALT_CCH_BARCODE=$catalogNumber; #use this format if the old CCH herbarium code is correctly added in the catalog number field


#find duplicates
if ($old_AID !~ m/^ *$/){
	if($duplicate{$old_AID}++){
		++$dups;
	#warn "Duplicate number: $old_AID\n";
	#&log_change("ACC: Old duplicate accession number found==>OLD:$old_AID NEW:$id GUID:$occurrenceID");
	#dont log this here as it will only print one of the two dups, this log should happen in the next step
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	print OUT "$catalogNumber\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\n"; 

	}
}


}

}


print <<EOP;
UNIQUE DUPS FOUND: $dups


EOP

close(IN);
close(OUT);












