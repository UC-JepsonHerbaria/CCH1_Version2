
#use strict;
#use warnings;
#use diagnostics;
use lib '/Users/Shared/Jepson-Master/Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev
my $today_JD;
$today_JD = &get_today_julian_day;

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


my %month_hash = &month_hash;



open(OUT, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_".$herb."_list.txt") || die; #this only needs to be active once to generate a list of duplicated accessions

print OUT "CCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\n";

#log.txt is used by logging subroutines in CCH.pm
#unlink $log_file or warn "making new error log file $log_file";


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
		$ALT_CCH_BARCODE=$1."-BC".$2;
		#print "HERB(1)\t$herbcode$aid\t$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n" if $otherCatalogNumbers =~ m/DS 98/g;
	}
	elsif ($acc =~ m/NULL/){
		$old_AID="";
		$ALT_CCH_BARCODE="";
	}
	else{
		&CCH::log_change("BAD CatalogNumber==>$acc==>\t$_");
		print "BAD CatalogNumber==>$acc\n";
		$old_AID="";
		$ALT_CCH_BARCODE="";
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

#find duplicates
if ($old_AID !~ m/^ *$/){
	if ($duplicate{$old_AID}++){
	++$dups;
	#warn "Duplicate number: $old_AID\n";
	#&log_change("ACC: Old duplicate accession number found==>OLD:$old_AID NEW:$id GUID:$occurrenceID");
	#dont log this here as it will only print one of the two dups, this log should happen in the next step
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	#for example, the worst case is CAS520791, which has 17 specimens that were labeled with this number over the years.
	print OUT "$acc\tNULL\tNULL\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\tNULL\n"; 
	}
}



}

}


print <<EOP;
UNIQUE DUPS FOUND: $dups


EOP

close(IN);
close(OUT);












