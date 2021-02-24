
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
$herb="SEINET";

#$filedate="06272017";
$filedate="11072019";

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






open(OUT, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/DUPS/DUPS_".$herb."_list.txt") || die; #this only needs to be active once to generate a list of duplicated accessions

	print OUT "institutionCode\tcollectionCode\townerInstitutionCode\tCCH2_catalogNumber\tCCH2_catalogNumber\tCCH2_ID\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tGUID-occurrenceID\n";


my $records_file="/Users/Shared/Jepson-Master/CCHV2/bulkload/input/SEINET_".$filedate."/occurrences.tab";
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


#id	institutionCode	collectionCode	ownerInstitutionCode	basisOfRecord	occurrenceID	catalogNumber	otherCatalogNumbers	
#kingdom	phylum	
($id,
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
#class	order	family	scientificName	taxonID	scientificNameAuthorship	genus	specificEpithet	taxonRank	infraspecificEpithet	
#identifiedBy	
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
#dateIdentified	identificationReferences	identificationRemarks	taxonRemarks	identificationQualifier	typeStatus	
#recordedBy	associatedCollectors	recordNumber	eventDate
$dateIdentified,
$identificationReferences,	#added 2015, not processed
$identificationRemarks,	#added 2015, not processed
$taxonRemarks,	#added 2015
$identificationQualifier,
$typeStatus,
$recordedBy,
#$recordedByID,			#added 2016, not in 2017 download
$associatedCollectors,	#added 2016, not in 2017 download, combined within recorded by with a ";"
$recordNumber,
$eventDate,
#30
#year	month	day	startDayOfYear	endDayOfYear	verbatimEventDate	occurrenceRemarks	habitat	substrate	\
#verbatimAttributes	
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
#fieldNumber	informationWithheld	dataGeneralizations	dynamicProperties	associatedTaxa	reproductiveCondition	
#establishmentMeans	cultivationStatus	lifeStage	sex	
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
#individualCount	preparations	country	stateProvince	county	municipality	locality	
#locationRemarks	localitySecurity	localitySecurityReason	
$individualCount,	#added 2015, not processed
#$samplingProtocol,	#added 2015, not processed, not in 2019 download
#$samplingEffort,	#added 2015, not processed, not in 2019 download
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
#decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	verbatimCoordinates	
#georeferencedBy	georeferenceProtocol	georeferenceSources	georeferenceVerificationStatus	georeferenceRemarks	
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
#minimumElevationInMeters	maximumElevationInMeters	minimumDepthInMeters	maximumDepthInMeters	verbatimDepth	
#verbatimElevation	disposition	language	recordEnteredBy	
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


my $oldA = "";

#do not filter by herbarium code for SEINET
#read all records
#if ($institutionCode !~ m/^ */){

#filter by the old CCH loading script

##################Exclude known problematic specimens by id numbers, most from outside California and Baja California
 if ($id =~/^(10389892|11163156|11165203|7755856|947875|3239055|12651038|6786882|903063|5542516|5553080|5559939|5560204|5564409|5571451|5578463|5578464|5579706|881193|881194|946792|946795|958356|13936935|13951195|13184339|8482435|3145188|3165281|8551641|2063694|6010380|3143301|6010483|3288631|5999431|6009962|3828429|3128756|891892|947111|6901995|3236890|3349408|5556965|3920225|3920384|7358734|949278|947283|953299|1910899|960031|7887537|901900|950642|885247|2139875|3236890|7880474|7880475|3349409|3156500|955884|5578801|5578802|8111276|901887|10964957|10899737|10612927|523075|2139878|947426|949080|952106|3840903|10450011|7878637|3350112|5574540|2140016|206575|8094686|6919312|10587155|6059833|6053609|6078071|6084883|6038783|6080815|6092926|6077290|6084618|6090271|6067228|6078439|6062798|6061904|6053009|6048333|6081870|3831133|5578807|957986|948347|7987520|3156332|5585640|5585641|3828429|780313|947147|932794|4090498|5556964|10492513|756181|8892781|10476365|2030103|3131301|5554619|3127702|5578808|5547519|5556946|954279|10789840|892491|952443|4557750|4557751|4134703|8071906|7067885|10791260|8099704|10546522|1004641|7293869|3130961|3158166|8100447|10905080|4041567|7096710|7096711|10789688|7880493|7880446|5556963|10484529|8696461|7096697|7096696|7572142|7579661|6900851|5585639|10731649|5519952|10848658|8215883)$/){
	#print ("excluded problem record or record known to be not from California\t$locality\t--\t$id");
		++$temp_skipped;
		next Record;
	}
	
	
##################Exclude known problematic from Baja California and other States in Mexico with "California" as state
 if ($id =~/^(10613729|932922|10615070|8720137|3132405|1939552|1939555|9372982|3157806|4182802|982039|982186|986591|10570608|10929212|3150102|3269779|904990|10571329|1940962|957093|4962440|5001448|10593214|10572572|10678657|3129513|903956|10932808|8735151|7718784|10796230|3148362|10678725|10743352|10500255|5501463|3132653|1912776|7247972|3145054|10550870|10546591|10531453|10755578|10794450|10794455|10969903|6165250|10870828|178669|4177487|10846560|1939654|10727925|1939566|3132654|6165302|3132655|5501705|5501448|5501418|5501427|6165662|5500734|6165216|1939553|6165097)$/){
	#print  ("Baja California record with California as state\t$id\t--\t$locality");
		++$temp_skipped;
		next Record;
	}
	
##################Exclude known problematic localities from other States in Mexico with "California" as state	
 if ($locality =~ m/(Cedros Island|Cerros Island|Campeche|Tuxpe.*a, Camp\.|Clarion Island|Isla del Carmen|Esc.?rcega|HopelchTn|Cd\. del C.?rmen|Mamantel|Xpujil|Ciudad del Carmen|Tuxpe.?a, Camp\.)/){
	#print  ("Mexico record with California as state\t$id");
		++$temp_skipped;
		next Record;
	}	
	
##################Exclude certain institutions,
 if ($institutionCode =~ m/^(UNLV|MUR|NHI|NBYC|KE|GAS|SCIR|KNFY|GMDRC|SEINet|GEO|UNCA|iNaturalist|Nicotiana - RSA|RHNM|MABA-Plants|MABA|GreaterGood|Sonoran Atlas|NCZP|BUT-IPA|SENEY|SWANER|SIM|TAWES|OBI|UCSC|DAV|SDSU|UCR|SCFS|ALA|HUNT|SAU|HNT)$/){
	#print  ("excluding records from certain Portal institutions\t$institutionCode");
#GAS,KE,BRIT,CLEMS,ISTC    all have county repeated in location and are skipped
#excluding CA herbaria that are downloaded separately as CCH participants
#NY,GH downloaded in CCH as participants, skipped here

#UNLV excluded for now due to request by the UNLV herbarium collections manager

#BCMEX has a rediculously high error rare including labellling all Baja California Records as just the state "California" and mistyping hundreds of coordinates as degrees and minutes when the format on the label was decimal degrees
#eliminating this collection elimiates many yellow flag records, besudes most of the California material are duplicates from Rebman that are already mapped in SD and SDSU

		++$temp_skipped;
		next Record;
	}
	

 	if ($institutionCode =~ m/^Harvard$/){
 		$herb = $collectionCode;
 	}

##################Exclude non-vascular plants
	if($family =~ m/(Psoraceae|Bryaceae|Wrangeliaceae|Sargassaceae|Ralfsiaceae|Chordariaceae|Porrelaceae|Mielichhoferiaceae Schimp.|Mielichhoferiaceae|Lessoniaceae|Laminariaceae|Dictyotaceae)/){	#if $family is equal to one of the values in this block
	#print  ("Non-vascular herbarium specimen (1) $_\t$id");	#skip it, printing this error message
		++$temp_skipped;
		next Record;
	}
	
	if($phylum =~ m/^(Anthocero|Ascomycota|Bryophyta|Chlorophyta|Rhodophyta|Marchant)/){	#if $class is equal to one of the values in this block
	#print  ("Non-vascular herbarium specimen (2) $_\t$id");	#skip it, printing this error message
		++$temp_skipped;
		next Record;
	}
	
	if($class =~ /^(Anthocero|Ascomycota|Bryophyta|Chlorophyta|Rhodophyta|Marchant)/){	#if $class is equal to one of the values in this block
	#print  ("Non-vascular herbarium specimen (2) $_\t$id");	#skip it, printing this error message
		++$temp_skipped;
		next Record;
	}
	
# if collection code contains the word "NONVASC", "OSCB" [OSC Bryophyte Herbarium], etc., skip the record
	if($collectionCode=~/(NONVASC|OSCB)/){
	#print  ("Non-vascular herbarium specimen (4) $_\t$id");	#&log_skip is a function that skips a record and writes to the error log
		++$temp_skipped;
		next Record;
	}


#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;



########ACCESSION NUMBER
#check for nulls
	if ($id=~/^ *$/){
		&CCH::log_skip("Record with no CCH2 ID $_");
		++$temp_skipped;
		next Record;
	}
	else{
	#old AID in SEINET is unique as it has always been the SEINET ID plus "SEINET" as the herbarium code
	#not been based on and actual accession number from other fields
		$old_AID=$herb.$id;
		++$total;
		#print "$old_AID\n";
	}

#extract old herbarium and aid numbers
 if ($institutionCode =~ m/^Harvard$/){
 	$catalogNumber =~ s/^barcode-//i;
 	$old_AID = $collectionCode.$catalogNumber;
 	$old_AID =~ s/^([A-Z]+)0+(\d+)/$1$2/;
 	$oldA="HUH-BC".$catalogNumber;
 	
 }
 else{
	if (length ($otherCatalogNumbers) >= 1){
	
		$otherCatalogNumbers =~ s/^(Sheet .+|UC Herb.+|California Academy.+|Herbarium.+|Plantae.+|Ewan (Number|Her?barium).+|collector number.+|Accession Number \d+ or \d+|31549\.|Baker.+|unreadable|NESH 11.+642|NESH ?\d* ?\d*|RENO|\d+\.\d+|\d+; *\d+|illeg|s\.n\.|LASCA .+|Walker.+|JEPS\d.+|CAGR \d+.+|GRCA-\d\d\d.+|should have been.+|\d+UCR.+|\d+GKH.+|CA930A.+)$/NULL/i; #make some bad or incompatible accessions NULL
		$otherCatalogNumbers =~ s/^(\d+,\d+|\d+ \d+)$/NULL/g;
		#$otherCatalogNumbers =~ s/^(Barcode: +)//g;
		$otherCatalogNumbers =~ s/^\[none\]$/NULL/i;
		$otherCatalogNumbers =~ s/^Mesa /MESA /g;
		$otherCatalogNumbers =~ s/[`';.]$//g;
		$otherCatalogNumbers =~ s/( +Accession No\. +|Acces+ion Number *|Specimen Number *)//;
		$otherCatalogNumbers =~ s/^nesh/NESH/i;
		$otherCatalogNumbers =~ s/^reno/NESH/i;
		$otherCatalogNumbers =~ s/^(\d+); .+/$1/g;

			if ($otherCatalogNumbers =~ m/^(NULL| *)$/){
				$otherID="";
				$herbcode="";
				$otherCatalogNumbers = "NULL";
				$oldA="NULL";
			}
			elsif ($otherCatalogNumbers =~ m/^(\d+)[abA]?$/){
				$otherID="";
				$herbcode="";
				$oldA=$institutionCode.$otherCatalogNumbers;
			}
			else{
					&CCH::log_change("BAD otherCatalogNumbers==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
					#print "BAD otherCatalogNumbers($institutionCode)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
					$otherID="";
					$herbcode="";
					$old_A="NULL";
			}
	}
	else{
		$otherID="";
		$herbcode="";
		$otherCatalogNumbers = "NULL";
		$old_A="NULL";
	}
}
#construct catalog numbers
#catalog numbers are RSA barcodes and these have leading zeros
#skip removing leading zeros, as this is new and I think we can skip any linked resources that use the barcodes without leading zeros
#they probably were not added to CCH1 without zeros anyway,  If they were, it was by mistake
if (length ($catalogNumber) >= 1){
	$catalogNumber =~ s/\+//g;
	$catalogNumber =~ s/[`']//g;
	$catalogNumber =~ s/^large lea//g;
	$catalogNumber =~ s/^(UT|UTC00F26794|\d+; ?\d+;?|\d+; ?\d+; ?\d+;?|\d+; ?\d+; ?\d+;\d+;?)$/NULL/i; #make some odd typos in accessions NULL
	$catalogNumber =~ s/^des(\d+)$/DES$1/i; #fix some odd typos in barcodes, must have been hand-typed
	$catalogNumber =~ s/^asu(\d+)$/ASU$1/i;
	$catalogNumber =~ s/^utc(\d+)$/UTC$1/i;
	$catalogNumber =~ s/^ill(\d+)$/ILL$1/i;
	$catalogNumber =~ s/^ephr *(\d+)$/EPHR$1/i;
	$catalogNumber =~ s/^but *(\d+)$/BUT$1/i;
	$catalogNumber =~ s/^BRYV/BRY/i;

 if ($institutionCode =~ m/^Harvard$/){
 	$catalogNumber =~ s/^barcode-//i;
 	$ALT_CCH_BARCODE = $collectionCode.$catalogNumber;
 }
 else{
	
	if ($catalogNumber =~ m/^(NULL| *)$/){
		$aidcode = $aid = "NULL";
		$catalogNumber = "NULL";
		$ALT_CCH_BARCODE="NULL";
	}
	elsif ($catalogNumber =~ m/^(\d+)[AaBb]?$/){
		$aidcode = $aid = "NULL";
		$ALT_CCH_BARCODE = $institutionCode.$catalogNumber
	}
	elsif ($catalogNumber =~ m/^v(\d+)([A-Z][A-Z]+)$/){
		$old_A = $2."-BC".$1;
		$ALT_CCH_BARCODE=$2.$1;
		$aidcode = $aid = "NULL";
	}
	elsif ($catalogNumber =~ m/^(\d+)([A-Z][[A-Z][A-Z]+)$/){
		$old_A = $2."-BC".$1;
		$ALT_CCH_BARCODE=$2.$1;
		$aidcode = $aid = "NULL";
	}
	elsif ($catalogNumber =~ m/^B\.(\d+)[A]?$/){
		$aidcode = $aid = "NULL";
		$old_A = $herb."-BC".$1;
		$ALT_CCH_BARCODE="B".$1;
	}
	elsif ($catalogNumber =~ m/^(benn)[_\- ](.+)$/i){
		$old_A = "BENN-BC".$2;
		$ALT_CCH_BARCODEA="BENN".$2;
		$aidcode = $aid = "NULL";
	}
	elsif ($catalogNumber =~ m/^(tenn-v)[_\- ](.+)$/i){
		$old_A = "TENN-BC".$2;
		$ALT_CCH_BARCODE="TENN".$2;
		$aidcode = $aid = "NULL";
	}
	elsif ($catalogNumber =~ m/^(bho-v)[_\- ](.+)$/i){
		$old_A = "BHO-BC".$2;
		$ALT_CCH_BARCODE="BHO".$2;
		$aidcode = $aid = "NULL";
	}
	elsif ($catalogNumber =~ m/^(USAM|UNCC|USMS)[_\- ](.+)$/){
		$old_A = $1."-BC".$2;
		$ALT_CCH_BARCODE=$1.$2;
		$aidcode = $aid = "NULL";
	}
	elsif ($catalogNumber =~ m/^(USCH)(\d+)_?[0-9]?$/){
		$old_A = $1."-BC".$2;
		$ALT_CCH_BARCODE=$1.$2;
		$aidcode = $aid = "NULL";
	}
	elsif ($catalogNumber =~ m/^(UTEP):Herb:(.+)$/){
		$old_A = $1."-BC".$2;
		$ALT_CCH_BARCODE=$1.$2;
		$aidcode = $aid = "NULL";
	}
	elsif ($catalogNumber =~ m/^([A-Z-]+) +(\d+)[abPB]?$/){
		$old_A = $1."-BC".$2;
		$ALT_CCH_BARCODE=$1.$2;
		$aidcode = $aid = "NULL";
	}
	elsif ($catalogNumber =~ m/^([A-Z-]+) +(\d+)_.*$/){
		$old_A = $1."-BC".$2;
		$ALT_CCH_BARCODE=$1.$2;
		$aidcode = $aid = "NULL";
	}
	elsif ($catalogNumber =~ m/^([A-Z-]+)[_\- ](\d+)_.*$/){
		$ALT_CCH_BARCODE = $1.$2;
		$aidcode = $aid = "NULL";
	}
	elsif ($catalogNumber =~ m/^([A-Z-]+-?) *(\d+)[^\d]+$/){
		$ALT_CCH_BARCODE = $1.$2;
		$aidcode = $aid = "NULL";
	}
	elsif ($catalogNumber =~ m/^([A-Z-]+-?)(\d+)$/){
		$ALT_CCH_BARCODE = $1.$2;
		$aidcode = $aid = "NULL";
	}
	else{
		&CCH::log_change("BAD catalogNumber($institutionCode)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\t$_");
		print "BAD catalogNumber($institutionCode)==>$CCH2id==>$catalogNumber==>$otherCatalogNumbers\n";
		$aidcode = $aid = "NULL";
		$ALT_CCH_BARCODE="NULL";
	}
 }
}
else{
		$aidcode = $aid = "NULL";
		$ALT_CCH_BARCODE="NULL";
}
#Add prefix to unique identifier field, two format, choose one and add to the code above
#$ALT_CCH_BARCODE=$aidcode.$aid;
#$ALT_CCH_BARCODE=$herb.$catalogNumber;
#$ALT_CCH_BARCODE=$catalogNumber; #use this format if the old CCH herbarium code is correctly added in the catalog number field


#find duplicates
#dont search in othercat number field as the seinet ID makes each record unique and does not present a problem with conflicts with
#the original CCH

if ($oldA !~ m/^( *|NULL)$/){
	if($duplicate{$oldA}++){
		++$dups;
	#warn "Duplicate number: $old_AID\n";
	#&log_change("ACC: Old duplicate accession number found==>OLD:$old_AID NEW:$id GUID:$occurrenceID");
	#dont log this here as it will only print one of the two dups, this log should happen in the next step
	#prints a file of all of the known duplicate numbers, the next step will to exclude all records with those numbers
	print OUT "$institutionCode\t$collectionCode\t$ownerInstitutionCode\t$catalogNumber\t$otherCatalogNumbers\tNULL\t$old_AID\t$ALT_CCH_BARCODE\t$oldA\tDUP\t$occurrenceID\n"; 

	}
}
#}

}


print <<EOP;
UNIQUE DUPS FOUND: $dups

SKIPPED BAD RECORDS: $temp_skipped
FOUND: $total

EOP

close(IN);
close(OUT);












