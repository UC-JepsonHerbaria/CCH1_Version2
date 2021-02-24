
#use strict;
#use warnings;
#use diagnostics;
use lib '/Users/Shared/Jepson-Master/Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

my $today_JD;

#$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.
$/="\n";
#$filedate="12052019";
$filedate="01292020";


open(IN, "/Users/Shared/Jepson-Master/Jepson-eFlora/synonymy/input/mosses.txt") || die "CCH.pm couldnt open mosses for non-vascular exclusion $!\n";
while(<IN>){
	chomp;
	($gg)=split(/\n/);
	$exclude{$gg}++;

}
close(IN);



#append to this file
open(OUT, ">>/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/output/AID_to_ADD_cumulative.txt") || die;


#id	type	modified	language	institutionCode	collectionCode	basisOfRecord	occurrenceID	catalogNumber	occurrenceRemarks	recordNumber	recordedBy	otherCatalogNumbers	eventDate	startDayOfYear	year	month	day	verbatimEventDate	habitat	higherGeography	continent	country	stateProvince	county	municipality	locality	verbatimElevation	minimumElevationInMeters	maximumElevationInMeters	verbatimLatitude	verbatimLongitude	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	georeferenceProtocol	georeferenceVerificationStatus	identifiedBy	dateIdentified	typeStatus	scientificName	higherClassification	kingdom	phylum	class	order	family	genus	specificEpithet	infraspecificEpithet	verbatimTaxonRank	scientificNameAuthorship	nomenclaturalCode
#urn:catalog:CAS:BOT-BC:522744	PhysicalObject	2016-10-19 09:19:30.0	en	CAS	BOT-BC	PreservedSpecimen	urn:catalog:CAS:BOT-BC:522744	522744	Shrub 10 feet tall	41804	Breedlove, D E	urn:catalog:CAS:DS:702772 | DS 702772	1976-11		1976	11		22 November 1976	Steep slopes and dry ravines	North America; Mexico; Chiapas; Amatenango de la Frontera Municipio	North America	Mexico	Chiapas	Amatenango de la Frontera Municipio		along Río Cuilco between Nuevo Amatenango and Frontera Comalapa	1100 m	1100	1100												Croton guatemalensis  Lotsy	Plantae; Magnoliophyta; Magnoliopsida; Euphorbiales; Euphorbiaceae	Plantae	Magnoliophyta	Magnoliopsida	Euphorbiales	Euphorbiaceae	Croton	guatemalensis			Lotsy	ICBN


my $mainFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/output/AID_to_ADD.txt';
open (IN, $mainFile) or die $!;
Record: while(<IN>){
	chomp;

	
#fix some data quality and formatting problems that make import of fields of certain records problematic
	
	
    if ($. == 1){#activate if need to skip header lines
			next Record;
		}

#CCH2_catalogNumber	CCH2_otherCatalogNumbers	CCH2_ID	OLD_CCH_AID	ALT_CCH_ID	ALT_CCH_AID_SPACE	Status	GUID-occurrenceID	SciName	County


		my @fields=split(/\t/,$_,100);

#InstitutionCode	occid	guid	initialtimestamp	dateEntered	dateLastModified

	($catalogNumber,
	$otherCatalogNumbers,
	$occid,
	$OLD_CCH_AID,
	$ALT_CCH_ID,
	$ALT_CCH_AID_SPACE,
	$Status,
	$GUID,
	$SciName,
	$County
	)=@fields;



my $institutionCode;


#parse each nonCCH1 institution based on the old CCH1 ID
		if ($OLD_CCH_AID =~ m/^(NY)([0-9-]+)$/){
			$herb = $1;
			$newCCH1_ID = $1.$2;
			++$CCH1_CAT;
		}
		#elsif ($OLD_CCH_AID =~ m/^(ECON|GH|A)([0-9-]+)$/){
		#	$herb = $1;
		#	$newCCH1_ID = $1.$2;
		#	++$CCH1_CAT;
		#}
		else{
			#print "MISSING CCH2_ID==>$OLD_CCH_AID==>$occid==>$catalogNumber\n";
			#most of the ones kicked out here CCH1 member records
			
			$newCCH1_ID = "SKIP";
			++$BAD_REM;
		}



	if ($newCCH1_ID !~ m/^SKIP$/){

#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;

#CCH2_catalogNumber	CCH2_otherCatalogNumbers	OLD_CCH_AID	ALT_CCH_ID	ALT_CCH_AID_SPACE	Status	GUID-occurrenceID	SciName	County
		print OUT "$herb\tNULL\t$newCCH1_ID\t$catalogNumber\t$otherCatalogNumbers\t$OLD_CCH_AID\t$ALT_CCH_ID\t$ALT_CCH_AID_SPACE\t$Status\t$GUID\t$SciName\t$County\tNULL\n";
		print OUT2 "$herb\tNULL\t$newCCH1_ID\t$catalogNumber\t$otherCatalogNumbers\t$OLD_CCH_AID\t$ALT_CCH_ID\t$ALT_CCH_AID_SPACE\t$Status\t$GUID\t$SciName\t$County\tNULL\n";



#print "INCL $occid\n";
++$included;
	}
	elsif ($newCCH1_ID =~ m/^SKIP$/){
	++$skipped;
	}
	else{
	++$excluded;
	}
}
print <<EOP;
MAIN RECORD INCL: $included
MAIN RECORD EXCL: $excluded
SKIPPED (other CCH2 records): $skipped

CCH1 accession created from numeric CatalogNumber: $CCH1CAT_num
CCH1 accession created from alpha-numeric CatalogNumber: $CCH1_CAT

BAD Catalog Numbers remaining: $BAD_CAT
BAD Numbers remaining: $BAD_REM

NULL Barcodes and CatNumbers: $NULL_REM
EOP


close(IN);
close(OUT);

