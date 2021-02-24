
#use strict;
#use warnings;
#use diagnostics;
use lib '/Users/Shared/Jepson-Master/Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev
my $today_JD;
$today_JD = &get_today_julian_day;

#$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.
$herb="UCSC";
#$filedate="11072019";
#$filedate="12052019";
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


#special UCSC file for linking old accession numbers with leading zeros
#these are removed in otherCatalogNumbers in CCH2 and cannot be accurately reconstructed
#this file is the last AID conversion file created for the old CCH1 that was used to create the DWC file for the IPT
open(IN,'/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/UCSC_AID.txt') || die;
while(<IN>){
	chomp;
next if (m/^#/);
#catalogNumber	otherCatalogNumbers	NANSH_ID

	($CN,$OCN,$NID)=split(/\t/);
	$acc_found{$CN}=$OCN;

}


open(OUT, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_".$herb."_list.txt") || die; #this only needs to be active once to generate a list of duplicated accessions

	print OUT "CCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\n";



#id	type	modified	language	institutionCode	collectionCode	basisOfRecord	occurrenceID	catalogNumber	occurrenceRemarks	recordNumber	recordedBy	otherCatalogNumbers	eventDate	startDayOfYear	year	month	day	verbatimEventDate	habitat	higherGeography	continent	country	stateProvince	county	municipality	locality	verbatimElevation	minimumElevationInMeters	maximumElevationInMeters	verbatimLatitude	verbatimLongitude	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	georeferenceProtocol	georeferenceVerificationStatus	identifiedBy	dateIdentified	typeStatus	scientificName	higherClassification	kingdom	phylum	class	order	family	genus	specificEpithet	infraspecificEpithet	verbatimTaxonRank	scientificNameAuthorship	nomenclaturalCode
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
if ($institutionCode =~ m/^UCSC$/){


#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;



########ACCESSION NUMBER
#check for nulls
	if ($CCH2id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		next Record;
	}


my $oldA = "";
	$otherCatalogNumbers =~ s/^(\? *\(.+|2006-498|2008-96|1111-589|2010-177|1234-420|2008-89|1991-1087|1987-205|1985-229)$/NULL/i; #make some bad UCSC accessions NULL
	$otherCatalogNumbers =~ s/^(\d+);.+$/$1/; #remove the extra numbers after the semicolon in some records
	$catalogNumber =~ s/^(UCSC100002219, .+|UCSC100002217, .+|)$/NULL/;#NULL these problem accessions


#extract old herbarium and aid numbers
#UCSC stripped all of the herbarium codes and leading zeros from its original catalogNumbers
if (length ($otherCatalogNumbers) >= 1){

	if ($otherCatalogNumbers =~ m/NULL/){
		$otherCatalogNumbers = "";
		$old_AID="";
	}
	elsif ($otherCatalogNumbers =~ m/^(\d+)[abc]?$/){ 
		$otherID = $1;
		$old_AID = $herb.$otherID;#add the herbarium code

	#add leading zeros for the alternate old CCH AID, CCH2 removed those zeros when loaded
		if ($otherID =~ m/^(\d\d\d\d\d)$/){
			$oldA = $herb."0".$otherID;
			++$found;
		#print "HERB(1a)\t$old_AID==>$otherCatalogNumbers==>$oldA\n";
		}
		elsif ($otherID =~ m/^(\d\d\d\d)$/){
			$oldA = $herb."00".$otherID;
			++$found;
		#print "HERB(1b)\t$old_AID==>$otherCatalogNumbers==>$oldA\n";
		}
		elsif ($otherID =~ m/^(\d\d\d)$/){
			$oldA = $herb."000".$otherID;
			++$found;
		#print "HERB(1c)\t$old_AID==>$otherCatalogNumbers==>$oldA\n";
		}
		elsif ($otherID =~ m/^(\d\d)$/){
			$oldA = $herb."0000".$otherID;
			++$found;
		#print "HERB(1d)\t$old_AID==>$otherCatalogNumbers==>$oldA\n";
		}
		elsif ($otherID =~ m/^(\d)$/){
			$oldA = $herb."00000".$otherID;
			++$found;
		#print "HERB(1e)\t$old_AID==>$otherCatalogNumbers==>$oldA\n";
		}
		else{
			$oldA = "";
		}

	}
	else{
		&CCH::log_change("BAD Accession==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$otherCatalogNumbers = "";
		$oldA = $old_AID="";
	}
}
else{
		$otherCatalogNumbers = "";
		$old_AID="";
}

#construct catalog numbers
if (length ($catalogNumber) >= 1){

	if ($catalogNumber =~ m/^(UCSC)(\d+)$/){
		$ALT_CCH_BARCODE = $1."-BC".$2;
		#the new barcodes have leading zeros but these have never been used in CCH1, so no need to remove them here.
		#print "HERB(3)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/98/g;
	}
	elsif ($catalogNumber =~ m/NULL/){
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";	
	}
	else{
		&CCH::log_change("BAD catalogNumber(2)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD catalogNumber(2)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$catalogNumber = "";
		$ALT_CCH_BARCODE = "";
	}
}
else{
	$catalogNumber = "";
	$ALT_CCH_BARCODE = "";	
}
#Add prefix to unique identifier field, two format, choose one and add to the code above
#$ALT_CCH_BARCODE=$aidcode.$aid;
#$ALT_CCH_BARCODE=$herb.$catalogNumber;
#$ALT_CCH_BARCODE=$catalogNumber; #use this format if the old CCH herbarium code is correctly added in the catalog number field


#find duplicates
if ($old_AID !~ m/^ *$/){
	if ($duplicate{$old_AID}++){
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
Leading Zero variants FOUND: $found

EOP

close(IN);
close(OUT);
