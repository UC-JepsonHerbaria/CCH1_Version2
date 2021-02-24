
#use strict;
#use warnings;
#use diagnostics;
use lib '/Users/Shared/Jepson-Master/Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

my $today_JD;

#$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.
$herb="NY";
#$filedate="11072019";
$filedate="01302013";

open(IN,"/Users/Shared/Jepson-Master/Jepson-eFlora/synonymy/input/smasch_taxon_ids.txt") || die;
while(<IN>){
	chomp;
	#s/× /&times;/;
	($code,$name)=split(/\t/);
	$NAME_TO_CODE{$name}=$code;
	$CODE_TO_NAME{$code}=$name;
}
close(IN);

#CCH2_catalogNumber	CCH2_otherCatalogNumbers	CCH2_ID	OLD_CCH_AID	ALT_CCH_ID	ALT_CCH_AID_SPACE	Status	GUID-occurrenceID

open(IN, "/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_".$herb."_list.txt") || die;
local($/)="\n";
while(<IN>){
	chomp;
	($CN,$OCN,$ID,$acc,$alt,@residue)=split(/\t/);

	if (length ($acc) >= 1){
		$DUP{$acc}++;
	}
}

close(IN);

$today_JD = &get_today_julian_day;
my %month_hash = &month_hash;

#this herb is first on the list, so it opens a new file for these two, while all others append
open(OUT3, ">>/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_excluded.txt") || die;
open(OUT2, ">>/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/output/AID_to_ADD.txt") || die;

#print OUT2 "CCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";
print OUT3 "CCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\tSciName\tCounty\n";



my $mainFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/NY/CDL_Main_NY_'.$filedate.'.txt';
open (IN, $mainFile) or die $!;
Record: while(<IN>){
	chomp;

	

#fix some data quality and formatting problems that make import of fields of certain records problematic
	
#    if ($. == 1){#activate if need to skip header lines
#			next Record;
#		}



		my @fields=split(/\t/,$_,100);
		
			foreach(@fields){
		s/^"//;
		s/"$//;
		s/""/"/g;
	}

    unless( $#fields == 17){ #if the number of values in the columns array is exactly 18

	&CCH::log_skip("$#fields bad field number $_\n");
	next Record;
	}
#key = id
#name = fields[0] = scientificName
#fields[1] = collectors
#fields[2] = CNUM_prefix
#fields[3] = CNUM
#fields[4] = CNUM_suffix
#fields[5] = EJD
#fields[6] = LJD
#fields[7] = verbatimDate
#fields[8] = county
#fields[9] = elevation
#fields[10] = locality
#fields[11] = latitude
#fields[12] = longitude
#fields[13] = datum
#fields[14] = georefSource
#fields[15] = townshipRangeSection
#fields[16] = errorRadius
#fields[17] = ERunits
#fields[18] = Yellow flag (1 if YF)


	($key,
$collectors,
$CNUM_prefix,
$CNUM,
$CNUM_suffix,
$EJD,
$LJD,
$verbatimDate,
$county,
$elevation,
$locality,
$latitude,
$longitude,
$datum,
$georefSource,
$townshipRangeSection,
$errorRadius,
$ERunits)=@fields;

	$taxon_id=$key;
	$taxon_id =~ s/^NY\d+[A-Za-z]? (\d+)$/$1/;
	$acc=$key;
	$acc =~ s/^(NY\d+[A-Za-z]?) \d+$/$1/;
	$collectioncode=$key;
	$collectioncode =~ s/^(NY)(\d+[A-Za-z]?) \d+$/$1/;
#NY1154119 21287	M. K. Brandegee				2419769	2420133	1913	Inyo		Silver Canon	37.4049778	-118.2648417					


#filter by herbarium code
if ($collectioncode =~ m/^NY$/){

$oldA = "";
$ALT_CCH_BARCODE = "NULL";

#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;



########ACCESSION NUMBER
#check for nulls
	if ($acc=~/^ *$/){
		$acc = "NULL";
	}


#extract old herbarium and aid numbers
#NY numbers are only barcodes, they never had accessions stamped except from the herbaria from which certain specimens were bought
#those purchased specimens accessions are not entered in NY database
#the data loaded here are from CCH1 and not the original file given in 2013 
#this will need changed when an actual NY file is obtained with new data
if (length ($acc) >= 1){

	if ($acc =~ m/^(NY)(\d+)$/){
		$old_AID=$1.$2;
		$oldA=$1."-BC".$2;
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($acc =~ m/NULL/){
		$old_AID="";
	}
	else{
		&CCH::log_change("BAD CatalogNumber==>$acc==>\t$_");
		print "BAD CatalogNumber==>$acc\n";
		$old_AID="";
	}
}
else{
		$old_AID="";
}
#Add prefix to unique identifier field, two format, choose one and add to the code above
#$ALT_CCH_BARCODE=$aidcode.$aid;
#$ALT_CCH_BARCODE=$herb.$catalogNumber;
#$ALT_CCH_BARCODE=$catalogNumber; #use this format if the old CCH herbarium code is correctly added in the catalog number field


$otherCatalogNumbers = "";
$CCH2id = "NULL";
$occurrenceID = "NULL";

$name=$CODE_TO_NAME{$taxon_id};


if ($acc =~ m/^ *$/){
		&log_skip("$herb ALL AIDs NULL: $CCH2id==>$acc\t$_");	#run the &log_skip function, printing the following message to the error log
		++$null;
		next Record;
}
else{
#Remove duplicates
	if($DUP{$old_AID}){
		print OUT3 "$acc\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\t$name\t$county\n";
#print "EXCL $old_AID\n";
++$dups;
	}
	else{
		print OUT2 "$acc\t$otherCatalogNumbers\t$CCH2id\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tNONDUP\t$occurrenceID\t$name\t$county\n";
#print "INCL $old_AID\n";
++$included;
	}
}

}



}
print <<EOP;
$herb INCL: $included
$herb EXCL: $dups
$herb NULL: $null

$herb TOTAL: $count_record

EOP


close(IN);
close(OUT2);
close(OUT3);
