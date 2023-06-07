
use strict;
#use warnings;
#use diagnostics;
use lib '../../Jepson-eFlora/Modules';
use CCH; #load non-vascular hash %exclude, alter_names hash %alter, and max county elevation hash %max_elev

#my $prevfiledate = "2022-05-05"; #changed to a date string
my $prevfiledate = "2022JUL11";


#my $file = "2459325"; #LJD of the date AID file was processed
#my $file = "2459518";
#my $file = "2459522";
#my $file = "2459648";

my $dupfiledate = "2023APR28"; #changed to a date string



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



my $today_JD = &CCH::get_today;
#my $today_JD = &get_today_julian_day;
$today_JD =~ s/ *PDT//;

my %ACC_HERB;
my %ACC_MOD;
my %ACC_FOUND;
my %UNQ_ID;
my %skipped;
my $changed;
my $MOD_DATE;

#AID table variables
my ($aidherb,$aidcat,$aidocat,$aidcch2id,$old_cchid,$cch_barcode,$cch_alt_aid,$aidStatus) = "";
my ($aidGUID,$aidName,$aidCounty,$aidMod,$linkID) = "";
my (%CONV_OLD,%CONV_BAR,%CONV_ALT,%ADD_OC,%ADD_CAT,%ADD_CCH,%ADD_BAR,%ADD_BAR_STRIPPED) = "";
my (%ADD_ALT,%ADD_TSMOD,%ADD_IC,%ADD_SN,%ADD_CO,%ACC_EX,%ADD_LINK,%MOD_DATE) = "";

#DUP variables
my ($hc,$cat,$ocat,$CCH2ID,$cchid,$cchbarcode,$altcchid,$n,$r,$l,$d) = ""; 
my (%DUP_CCH, %DUP_BAR, %DUP_ALT, %DUP_FOUND) = ""; 

my ($aid,$gid,$CCH1_LINK_ID,$cch1id,%LINKID_FOUND,%GID_A,%GID_B,%CCH1_A,%CCH1_B) = "";

#mosses
my (%exclude,$gg) = "";

#counts
my ($skipped, $NULL, $non, $included, $c, $PM, $GC) = "";
my ($count_record,$CCH1_LINK_ID,$UNIQUE_GEO_ID,$CCH1acc,$value,$key,$ID,$parseLat,$parseLong) = "";


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


$| = 1; #forces a flush after every write or print, so the output appears as soon as it's generated rather than being buffered.

open(LOAD, ">output/CCH1_convert_log_".$dupfiledate.".txt") || die;

open(BAD, ">input/AID_GUID/output/AID_to_ADD_CCH2_missing.txt") || die;

open(OUT, '>input/AID_GUID/output/AID_to_ADD_CCH2_mod_'.$dupfiledate.'.txt') || die;
open(DATE, '>input/AID_GUID/output/AID_CCH2_NEW_'.$dupfiledate.'.txt') || die;

open(PROB, '>input/AID_GUID/output/AID_changed_'.$dupfiledate.'.txt') || die;
open(NON, ">output/bulkload_nonvasc_excluded.txt") || die;

	print OUT "herbcode\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tCCH_ID_BARCODE\tALT_CCH_AID\tStatus\tGUID-occurrenceID\tSciName\tCounty\tCCH2_dateLastModified\tLINK_ID\n";
	print BAD "herbcode\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tCCH2_ID\tOLD_CCH_AID\tCCH_ID_BARCODE\tALT_CCH_AID\tStatus\tGUID-occurrenceID\tSciName\tCounty\tCCH2_dateLastModified\tLINK_ID\n";
	print DATE "herbcode\tLINK_ID\tDATEMOD_VALUE\tCCH2_dateLastModified\n";

	print LOAD "\n\nconverting CCH1 AID file....  'perl add_to_cumulative.pl'\n";
	

open(IN, "../../Jepson-eFlora/synonymy/input/mosses.txt") || die "CCH.pm couldnt open mosses for non-vascular exclusion $!\n";
while(<IN>){
	chomp;
	($gg)=split(/\n/);
	$exclude{$gg}++;

}
close(IN);


my $aidfile = 'input/AID_GUID/output/AID_to_ADD_CCH2_mod_'.$prevfiledate.'.txt';
open (IN, $aidfile) or die $!;
	while(<IN>){
		chomp;
	($aidherb,$aidcat,$aidocat,$aidcch2id,$old_cchid,$cch_barcode,$cch_alt_aid,$aidStatus,$aidGUID,$aidName,$aidCounty,$aidMod)=split(/\t/);
	#($aidherb,$aidcat,$aidocat,$aidcch2id,$old_cchid,$cch_barcode,$cch_alt_aid,$aidStatus,$aidGUID,$aidName,$aidCounty,$aidMod,$link_id)=split(/\t/);
	#($aidherb,$aidcat,$aidocat,$aidcch2id,$old_cchid,$cch_barcode,$cch_alt_aid,$aidStatus,$aidGUID,$aidName,$aidCounty)=split(/\t/);
	
#remove the barcode tag so it can match the CCH1 accession
my $nobarcode = $cch_barcode;
$nobarcode =~ s/[ -]+BARCODE$//;


my $OLD = $old_cchid;

my $BAR = $nobarcode;

my $ALT = $cch_alt_aid;

#find CCH1 link ID
	if ($BAR !~ m/^( *|NULL)$/){
		$cch1id = $BAR;
		$CCH1_LINK_ID = $BAR."->".$aidcch2id;
	}
	elsif ($OLD !~ m/^( *|NULL)$/){
		$cch1id = $OLD;
		$CCH1_LINK_ID = $OLD."->".$aidcch2id;
	}
	elsif ($ALT !~ m/^( *|NULL)$/){
		$cch1id = $ALT;
		$CCH1_LINK_ID = $ALT."->".$aidcch2id;
	}
	else{
		$CCH1_LINK_ID = "NULL";
	}

	if ($CCH1_LINK_ID !~ m/^( *|NULL)$/){
		if ($old_cchid !~ m/^(SEINET)\d+/){
			$LINKID_FOUND{$CCH1_LINK_ID}++;
			$CCH1_A{$cch1id}++;
			$CCH1_B{$cch1id}=$aidcch2id;
			$GID_A{$aidcch2id}++;
			$GID_B{$aidcch2id}=$cch1id;
		}
	}


}


close(IN);


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
($id,
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


++$included;

my $herb = $institutionCode;

printf {*STDERR} "%d\r", ++$count_record;

	if (length ($genus) > 1){
		if($exclude{$genus}){	
			print NON "$institutionCode ERR TAXON $genus(1): Non-vascular plant ($scientificName)==>$_\n";
			++$non;
			next Record;
		}
	}
	else{
	$genus = $scientificName;
	$genus =~ s/^([A-Z][a-z-]+) *.*$/$1/;	
		if($exclude{$genus}){	
			print NON "$institutionCode ERR TAXON $genus(2): Non-vascular plant ($scientificName)==>$_\n";
			++$non;
			next Record;
		}

	}

	if($id =~ m/^ *$/) {	
			++$NULL;
			next Record;
	}
	else{
			$ACC_FOUND{$id}++;
			$ACC_MOD{$id} = $modified;

		if(($catalogNumber =~ m/^ *$/) && ($otherCatalogNumbers =~ m/^ *$/)){	
			++$skipped;
			next Record;
		}

	}


 }

print <<EOP;
CCH2 TOTAL RECORDS: $included

CCH2 NULL Barcodes and CatNumbers: $skipped

CCH2 records without OCCID: $NULL

CCH2 NONVASC EXCL: $non

EOP

print LOAD <<EOP;
CCH2 TOTAL RECORDS: $included

CCH2 NULL Barcodes and CatNumbers: $skipped

CCH2 records without OCCID: $NULL

CCH2 NONVASC EXCL: $non

EOP

close(IN);
close(NON);



my $included;
my ($count_record, $link_found,$aid,$gid,$cch1id,$null) = "";
my ($GIDCHANGE,$AIDCHANGE,$CCH1_CAT,$CCH1_LINK_ID) = "";
#AID table variables reset
my ($herbcode,$catb,$ocatb,$cch2idb,$old_cchid,$cch_barcode,$cch_alt_aid,$aidStatus,$aidGUID,$aidName,$aidCounty) = "";
my (%CONV_OLD,%CONV_BAR,%CONV_ALT,%ADD_OC,%ADD_CAT,%ADD_CCH,%ADD_BAR,%ADD_BAR_STRIPPED) = "";
my (%ADD_ALT,%ADD_TSMOD,%ADD_IC,%ADD_SN,%ADD_CO,%ACC_EX,%ADD_LINK) = "";


my $addFile = 'input/AID_GUID/output/AID_to_ADD_'.$dupfiledate.'.txt';
open (IN, $addFile) or die $!;
	while(<IN>){
		chomp;
		($herbcode,$catb,$ocatb,$cch2idb,$old_cchid,$cch_barcode,$cch_alt_aid,$aidStatus,$aidGUID,$aidName,$aidCounty)=split(/\t/);

#herbcode	CCH2_catalogNumber	CCH2_otherCatalogNumbers	CCH2_ID	OLD_CCH_AID	CCH_BARCODE_ID	ALT_CCH_AID	Status	GUID-occurrenceID	SciName	County
#RSA	RSA0192510	RSA accession #: 108712	3875886	RSA108712	RSA0192510 BARCODE		NONDUP	1dd12db8-a87b-4901-ab1f-a47fff2e7058	Astragalus calycosus	Mono
#RSA	RSA0193859	RSA accession #: 646835	3881743	RSA646835	RSA0193859 BARCODE		NONDUP	8e957584-4ea6-402d-a68b-5df418067c37	Astragalus cottonii	Clallam
#RSA	RSA0196312	POM accession #: 452	3883920	POM452	RSA0196312 BARCODE		NONDUP	4291dd75-d3a6-4068-b295-d109038cb918	Tropidocarpum gracile var. dubium	Los Angeles
#RSA	RSA0205106	RSA accession #: 678528	3912466	RSA678528	RSA0205106 BARCODE		NONDUP	142fa477-637a-4d7e-9933-e7eb166ea76e	Verbena tenuisecta	Ventura

next if (m/^herbcode/i);

my $nobarcode = $cch_barcode;
$nobarcode =~ s/[ -]+BARCODE$//; #remove this for comparisons below

my $barcode = $cch_barcode;
$barcode =~ s/[ -]+BARCODE$/-BARCODE/; 


++$included;
#old_cchid is the old CCH accession number, before barcodes were introduced
#cch_barcode is a the barcode accession in the format: herbarium+barcode+space 'BARCODE' appended at the end
  #blank if the barcode does not exist
  #same as cchidb for herbaria that do not create a new barcode number		
#cch_alt_aid is a variant that some herbaria have changed from (or to), sometimes this is the same
  #mostly this is a variant with leading zeros

#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;

my $OLD = $old_cchid;

my $BAR = $nobarcode;

my $ALT = $cch_alt_aid;

#find CCH1 link ID
	if ($BAR !~ m/^( *|NULL)$/){
		$cch1id = $BAR;
		$CCH1_LINK_ID = $BAR."->".$cch2idb;
	}
	elsif ($OLD !~ m/^( *|NULL)$/){
		$cch1id = $OLD;
		$CCH1_LINK_ID = $OLD."->".$cch2idb;
	}
	elsif ($ALT !~ m/^( *|NULL)$/){
		$cch1id = $ALT;
		$CCH1_LINK_ID = $ALT."->".$cch2idb;
	}
	else{
		$cch1id = $CCH1_LINK_ID = "NULL";
	}


#find problem records
	if ($CCH1_LINK_ID !~ m/^( *|NULL)$/){
		if ($LINKID_FOUND{$CCH1_LINK_ID}){
			++$link_found;
		}
		else{
			$aid = $CCH1_LINK_ID;
			$aid =~ s/^(.+)->(.+)$/$1/;
			#print "$aid\n";
			$gid = $CCH1_LINK_ID;
			$gid =~ s/^(.+)->(.+)$/$2/;

			if ($GID_A{$cch2idb}){#DOES THE CCH2 ID MATCH IN A LINK ID, but the AID changed
				my $temp = $GID_B{$cch2idb};
				if ($aid ne $temp){
					++$AIDCHANGE;
					print PROB "GID EQUAL BUT AID CHANGED==>$CCH1_LINK_ID-->OLD:$temp-->NEW:$aid\n";
				}
				
			
			}
			
			if ($CCH1_B{$cch1id}){
			#THE CCH2 ID DOES NOT MATCH IN A LINK ID
				my $temp = $CCH1_B{$cch1id};
				if ($gid ne $temp){
					++$GIDCHANGE;
					print PROB "AID EQUAL BUT GID CHANGED==>$CCH1_LINK_ID-->OLDGID:$temp-->NEWGID:$gid NEWID:($cch1id)\n";
				}
				
			}





		}
	}
#2023-03-06 02:38:29
	my $MOD = $ACC_MOD{$cch2idb};
		$MOD =~ s/[-:]+//g;
		$MOD =~ s/ +//g;
#20230306023829

	if (($catb =~ m/^ *$/) && ($ocatb =~ m/^ *$/)){
		++$null;
		my $STATUS = "NULL CAT SKIPPED==>".$herbcode;
		print PROB join("\t",$STATUS,$catb,$ocatb,$cch2idb,$old_cchid,$barcode,$cch_alt_aid,$aidStatus,$aidGUID,$aidName,$aidCounty,$ACC_MOD{$cch2idb},$CCH1_LINK_ID),"\n";
		next;
	}
	else{
		if ($CCH1_LINK_ID =~ m/^(NULL| *)$/){
			my $STATUS = "NULL LINK ID SKIPPED==>".$herbcode;
			print PROB join("\t",$STATUS,$catb,$ocatb,$cch2idb,$old_cchid,$barcode,$cch_alt_aid,$aidStatus,$aidGUID,$aidName,$aidCounty,$ACC_MOD{$cch2idb},$CCH1_LINK_ID),"\n";
		++$null;
		next;
   		}
   		else{
   			print OUT join("\t",$herbcode,$catb,$ocatb,$cch2idb,$old_cchid,$barcode,$cch_alt_aid,$aidStatus,$aidGUID,$aidName,$aidCounty,$ACC_MOD{$cch2idb},$CCH1_LINK_ID),"\n";
			++$CCH1_CAT;

#change this to previous load date for each new load date
			if ($MOD >= 20220708000000){
   				print DATE join("\t",$herbcode,$CCH1_LINK_ID,$MOD,$ACC_MOD{$cch2idb}),"\n";
				++$changed;
			}
		}
	}

}
print <<EOP;

AID PROCESSED REPORT:
CCH MAIN TOTAL RECORDS: $included

CCH MAIN null Barcodes and CatNumbers: $null (this should be null, if not something is wrong)

processed CCH1 accessions linked to CCH2 ID: $CCH1_CAT

AID CHANGED:$AIDCHANGE
GID CHANGED:$GIDCHANGE

Records changed or added since $prevfiledate: $changed


EOP

print LOAD <<EOP;

AID PROCESSED REPORT:
CCH MAIN TOTAL RECORDS: $included

CCH MAIN null Barcodes and CatNumbers: $null (this should be null, if not something is wrong)

processed CCH1 accessions linked to CCH2 ID: $CCH1_CAT

AID CHANGED:$AIDCHANGE
GID CHANGED:$GIDCHANGE

Records changed or added since $prevfiledate: $changed


EOP

close(IN);
close(OUT);

