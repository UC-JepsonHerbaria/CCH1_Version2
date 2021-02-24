
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
#open(OUT2, ">/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/output/AID_to_ADD_cumul_SEINET.txt") || die;


#print OUT2 "institutionCode\tSEINET_occid\tnew_CCH1_ID\tCCH2_catalogNumber\tCCH2_otherCatalogNumbers\tOLD_CCH_AID\tALT_CCH_ID\tALT_CCH_AID_SPACE\tStatus\tSciName\tCounty\tCCH2_initialtimestamp\tCCH2_dateLastModified\tGUID\n";



#id	type	modified	language	institutionCode	collectionCode	basisOfRecord	occurrenceID	catalogNumber	occurrenceRemarks	recordNumber	recordedBy	otherCatalogNumbers	eventDate	startDayOfYear	year	month	day	verbatimEventDate	habitat	higherGeography	continent	country	stateProvince	county	municipality	locality	verbatimElevation	minimumElevationInMeters	maximumElevationInMeters	verbatimLatitude	verbatimLongitude	decimalLatitude	decimalLongitude	geodeticDatum	coordinateUncertaintyInMeters	georeferenceProtocol	georeferenceVerificationStatus	identifiedBy	dateIdentified	typeStatus	scientificName	higherClassification	kingdom	phylum	class	order	family	genus	specificEpithet	infraspecificEpithet	verbatimTaxonRank	scientificNameAuthorship	nomenclaturalCode
#urn:catalog:CAS:BOT-BC:522744	PhysicalObject	2016-10-19 09:19:30.0	en	CAS	BOT-BC	PreservedSpecimen	urn:catalog:CAS:BOT-BC:522744	522744	Shrub 10 feet tall	41804	Breedlove, D E	urn:catalog:CAS:DS:702772 | DS 702772	1976-11		1976	11		22 November 1976	Steep slopes and dry ravines	North America; Mexico; Chiapas; Amatenango de la Frontera Municipio	North America	Mexico	Chiapas	Amatenango de la Frontera Municipio		along Río Cuilco between Nuevo Amatenango and Frontera Comalapa	1100 m	1100	1100												Croton guatemalensis  Lotsy	Plantae; Magnoliophyta; Magnoliopsida; Euphorbiales; Euphorbiaceae	Plantae	Magnoliophyta	Magnoliopsida	Euphorbiales	Euphorbiaceae	Croton	guatemalensis			Lotsy	ICBN


my $mainFile = '/Users/Shared/Jepson-Master/CCHV2/bulkload/input/AID_GUID/output/AID_to_ADD_SEINET.txt';
open (IN, $mainFile) or die $!;
Record: while(<IN>){
	chomp;

	
#fix some data quality and formatting problems that make import of fields of certain records problematic
	
	
    if ($. == 1){#activate if need to skip header lines
			next Record;
		}

#CCH2_catalogNumber	CCH2_otherCatalogNumbers	CCH2_ID	OLD_CCH_AID	ALT_CCH_ID	ALT_CCH_AID_SPACE	Status	GUID-occurrenceID	SciName	County


		my @fields=split(/\t/,$_,100);

#institutionCode	catalogNumber	otherCatalogNumbers	CCH2_ID	OLD_CCH_AID	ALT_CCH_ID	ALT_CCH_AID_SPACE	Status	GUID-occurrenceID	scientificName	county
#NMC	39710	NULL	NULL	SEINET149338	NMC39710		NONDUP		Astragalus trichopodus var. phoxus	Los Angeles
#ASU		71	NULL	SEINET155912	NULL	ASU71	NONDUP	92172013-2715-4e7d-8cf1-f4dd090decf5	Atriplex semibaccata	ORANGE

	($institutionCode,
	$catalogNumber,
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

#parse SEINET record first, which have a SEINET occid plus leading 9's
if ($OLD_CCH_AID =~ m/^(SEINET)([0-9-]+)$/){
		if ($catalogNumber =~ m/^([A-Z]+)([0-9-]+)$/){
			$herb = $1;
			#print "(1)$institutionCode==>$herb\n" unless $seen{$institutionCode.$herb}++;
			$newCCH1_ID = $1.$2;
			++$CCH1_CAT;
		}
		elsif ($catalogNumber =~ m/^([A-Z-]+)[\-\_ ]+V?([0-9-]+)$/){
			$code = $1;
			$herb = $institutionCode;
			$newCCH1_ID = $institutionCode.$2;
			#print "(1a)$institutionCode==>$code\n" unless $seenb{$institutionCode.$code}++;
			#print "BAD ACC FOUND(1a)==>$catalogNumber==>$otherCatalogNumbers==>$OLD_CCH_AID\n";
			++$CCH1_CAT;
		}
		elsif ($catalogNumber =~ m/^v([0-9-]+)([A-Z][A-Z]+)$/){
			$code = $2;
			$herb = $institutionCode;
			$newCCH1_ID = $herb.$1;
			print "(1b) $institutionCode==>$code\n" unless $seenbb{$institutionCode.$code}++;
			#print "BAD ACC FOUND(1b)==>$catalogNumber==>$otherCatalogNumbers==>$OLD_CCH_AID\n";
			++$CCH1_CAT;
		}
		elsif ($catalogNumber =~ m/^([0-9-]+)$/){
			$herb = $institutionCode;
			$newCCH1_ID = $institutionCode.$1;
			#print "$institutionCode                  \n" unless $seenc{$institutionCode}++;
			#print "BAD ACC FOUND(1c-$institutionCode)==>$catalogNumber==>$otherCatalogNumbers==>$OLD_CCH_AID==>$ALT_CCH_ID\n";
			++$CCH1CAT_num;
		}
		elsif ($catalogNumber =~ m/^ *$/){
			if ($otherCatalogNumbers =~ m/^([0-9-]+)$/){
				$newCCH1_ID = $institutionCode.$1;
				$herb = $institutionCode;
				#print "$institutionCode                  \n" unless $seend{$institutionCode}++;
				#print "BAD ACC FOUND(1d-$institutionCode)==>$catalogNumber==>$otherCatalogNumbers==>$OLD_CCH_AID==>$ALT_CCH_ID\n";
				++$CCH1CAT_num;
			}
			elsif ($otherCatalogNumbers =~ m/^([A-Z-]+)([0-9-]+)x?$/){
				$newCCH1_ID = $1.$2;
				$herb = $institutionCode;
				#print "$institutionCode                  \n" unless $seend{$institutionCode}++;
				#print "BAD ACC FOUND(1e-$institutionCode)==>$catalogNumber==>$otherCatalogNumbers==>$OLD_CCH_AID==>$ALT_CCH_ID\n";
				++$CCH1_CAT;
			}
			else{
				print "BAD ACC FOUND(1f-$institutionCode)==>$catalogNumber==>$otherCatalogNumbers==>$OLD_CCH_AID==>$ALT_CCH_ID\n";
				#lines added above when new records appear her after each load
				#ones that are kept here are mostly problems that I dont want to take the time to solve, some may not even be from CA
				$herb = $institutionCode;
				$newCCH1_ID = "SKIP";
				++$BAD_CAT;
			}
		}
		else{
				#print "BAD ACC FOUND(1g-$institutionCode)==>$catalogNumber==>$otherCatalogNumbers==>$OLD_CCH_AID==>$ALT_CCH_ID\n";
				#lines added above when new records appear her after each load
				#ones that are kept here are mostly problems and dup records, some may not even be from CA
				$herb = $institutionCode;
				$newCCH1_ID = "SKIP";
		}
}
else{
	#ones that fall out here are ones that never made it into CCH1 before Sept 2018, therefore there is no SEINET CCH1 Number
	#some of these are Mexico specimens
		if ($catalogNumber =~ m/^([0-9-]+)$/){
			$newCCH1_ID = $institutionCode.$1;
			$herb = $institutionCode;
			#print "$institutionCode\n" unless $seenj{$institutionCode}++;
			#print "BAD ACC FOUND(1c-$institutionCode)==>$catalogNumber==>$otherCatalogNumbers==>$OLD_CCH_AID==>$ALT_CCH_ID\n";
			++$CCH1CAT_num;
		}
		elsif ($catalogNumber =~ m/^([A-Z-]+)[\-\_ ]+V?([0-9-]+)$/){
		#fix some problem institutionCode's that are not index herbariorum codes:
			$code = $1;
			
				if ($code =~ m/^-?(UTC|MICH|FLFO|E|EHR|MU|TENN)-?V?$/){
					$herb = $1;
					$newCCH1_ID = $herb.$2;
					#print "$institutionCode==>$code==>$herb\n" unless $seenb{$institutionCode.$herb}++;
					#print "BAD ACC FOUND(1a)==>$catalogNumber==>$otherCatalogNumbers==>$OLD_CCH_AID\n";
					++$CCH1_CAT;
				}
				else{
					$herb = $institutionCode;
					$newCCH1_ID = $institutionCode.$2;
					#print "$institutionCode==>$code\n" unless $seenb{$institutionCode.$code}++;
					#print "BAD ACC FOUND(1a)==>$catalogNumber==>$otherCatalogNumbers==>$OLD_CCH_AID\n";
					++$CCH1_CAT;
				}
		}
		elsif ($catalogNumber =~ m/^([A-Z]+)([0-9-]+)$/){
			$herb = $1;
			#print "$institutionCode==>$herb\n" unless $seen{$institutionCode.$herb}++;
			$newCCH1_ID = $1.$2;
			++$CCH1_CAT;
		}
		elsif ($catalogNumber =~ m/^B\.([0-9-]+)$/){
			$herb = $institutionCode;#I have no idea what the "B." means for this herbarium
			#print "$institutionCode==>$herb\n" unless $seen{$institutionCode.$herb}++;
			$newCCH1_ID = $herb.$2;
			++$CCH1_CAT;
		}
		elsif ($catalogNumber =~ m/^v?([0-9-]+)([A-Z][A-Z]+)$/){
			$herb = $institutionCode;
			$newCCH1_ID = $institutionCode.$1;
			print "$institutionCode==>$code\n" unless $seenbb{$institutionCode.$code}++;
			#print "BAD ACC FOUND(1a)==>$catalogNumber==>$otherCatalogNumbers==>$OLD_CCH_AID\n";
			++$CCH1_CAT;
		}
		else{
			print "MISSING CCH1 AID($institutionCode)==>$OLD_CCH_AID==>$occid==>$catalogNumber\n";
				#lines added above when new records appear her after each load
				#ones that are kept here are mostly problems and dup records, some may not even be from CA
			$herb = $newCCH1_ID = "SKIP";
			++$BAD_REM;
		}
}



	if ($newCCH1_ID !~ m/^( *|SKIP)$/){

#warn "$count_record\n" unless $count_record % 1009;
printf {*STDERR} "%d\r", ++$count_record;

		print OUT "$herb\tNULL\tNULL\t$Status\t$OLD_CCH_AID\t$ALT_CCH_ID\tNULL\t$SciName\t$County\t$catalogNumber\t$otherCatalogNumbers\t$GUID\n";
		print OUT "$herb\tNULL\tNULL\t$Status\t$OLD_CCH_AID\t$ALT_CCH_ID\tNULL\t$SciName\t$County\t$catalogNumber\t$otherCatalogNumbers\t$GUID\n";

#institutionCode	CCH2_ID	CCH2_dateLastModified	status	CCH1_AID	ALT_CCH1_AID	ALT_CCH1_AID_B	SciName	County	CCH2_catalogNumber	CCH2_otherCatalogNumbers	GUID-occurrenceID



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

