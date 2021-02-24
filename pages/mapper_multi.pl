#!/usr/bin/perl
use CGI;
$query = CGI->new;                       # create new CGI object
my $coords = $query->param('coords');
my $addfile = $query->param('addfile');
my $tab_map_file = $query->param('tabfile');
my $mapit = $query->param('mapit');
my $multi = $query->param('multi');
my =~s/[^A-Za-z ]//g; = $query->param('cumul');
%INST=(
0,RED,
1,CYA,
2,WHT,
3,BLK,
4,ORG,
);
$inst=$INST{$multi};

$start_time=time;

#Security mods to prevent 
$mapit=~s/[^A-Za-z ]//g;
$multi=~s/[^A-Z0-9 ]//g;
#$tab_map_file=~s/[^A-Za-z0-9 .]//g;
#$config_file=~s/[^A-Za-z0-9 .]//g;
$sourcename=~s/[^A-Za-z ]//g;
$map_file_URL=~s/[^A-Za-z0-9 \/:.]//g;


	#Where you tell Berkeley Mapper the configuration file is
	$config_file='https://ucjeps.berkeley.edu/ucjeps_multi.xml'; #old file?
  $red_config_file='https://ucjeps.berkeley.edu/test_red.xml';
$black_config_file='https://ucjeps.berkeley.edu/test_black.xml';



$tab_file_name="CHC_" . substr($start_time,6,4) . $$ . ".txt";

#single mapper mode

if($cumulFILE =~ m/^(0| *|[2-9])$/){
  if($mapit){

#Output file to store data for Berkeley Mapper
$map_file_path="BerkeleyMapper/";
$map_file_out="$map_file_path$tab_file_name";
$map_file_URL="https://ucjeps.berkeley.edu/$map_file_out";

print $query->header;                    # create the HTTP header
print NULL <<EOP;
USE
	map_file_out = $map_file_out
	map_file_URL= $map_file_URL
EOP

print <<EOP;
USE
	map_file_out = $map_file_out
	map_file_URL= $map_file_URL
EOP
  }

  if($mapit){

	$sourcename="Consortium Coordinate Loader";
	$coords=~s/\cM/\n/g;
	@coords=split(/\n/,$coords);
print $query->header;                    # create the HTTP header
	foreach(@coords){
		chomp;
		if(m/^ *(-?[0-9.]+), *(-?[0-9.]+)$/){
@fields=(
"specimen_id",
"name",
"collector",
"coll_number_prefix",
"coll_number",
"coll_number_suffix",
"early_jdate",
"late_jdate",
"date_string",
"county",
"elevation",
"locality",
"$1",
"$2",
"datum",
"source",
"error_distance",
"units",
);
		}
		elsif(m/^ *([A-Z]+\d+), *(-?[0-9.]+), *(-?[0-9.]+)$/){
@fields=(
"$1",
"name",
"collector",
"coll_number_prefix",
"coll_number",
"coll_number_suffix",
"early_jdate",
"late_jdate",
"date_string",
"county",
"elevation",
"locality",
"$2",
"$3",
"datum",
"source",
"error_distance",
"units",
);
		}
		else{
s/^ *//;
		@fields=split(/\t/,$_);
		}
			foreach $i (0 .. $#fields){
			print NULL "<br>$i $fields[$i]";
			}

		$sci_name="unknown";$county="unknown";
			if($fields[12] && $fields[13]){
#need to specify fields precisely!
#specimen_number	taxon name	collector	coll_number_prefix	coll_number	coll_number_suffix	early_jdate	late_jdate	date_string	county	elevation	locality	latitude	longitude	datum	source	error distance	units
#UCR105967	Phacelia campanularia subsp. campanularia	Valerie Soza		172		2450975	2450975	Jun 10 1998	San Bernardino	1463 m	  San Bernardino Mtns. East of Hwy 18, off road 3N36, 0.5 mi from entrance to road 3N36 from Hwy 18	34.3533333333333333	-116.84				
#UCR	UCR105967	Phacelia campanularia subsp. campanularia	Valerie Soza		172		2450975	2450975	Jun 10 1998	San Bernardino	1463 m	  San Bernardino Mtns. East of Hwy 18, off road 3N36, 0.5 mi from entrance to road 3N36 from Hwy 18	34.353	-116.84			03N01E11	NAD 27
		push(@map_results, "$inst\t$fields[0]\t$fields[1]\t$fields[9]\t$fields[12]\t$fields[13]\t$fields[14]");
			}
	}

	if(@map_results){

print "<br>NEW";
open(MAPFILE, ">/data/tmp/$map_file_out") || print "cant open map file /data/tmp/$map_file_out $!";
print MAPFILE join("\n",@map_results),"\n";

print join("\n",@map_results),"\n";

close(MAPFILE);
$report=<<EOR;

O.K., the coordinates have been sent to BerkeleyMapper.
<br>
<b>
<h3>
Click on this
<a href="http://berkeleymapper.berkeley.edu/index.html?ViewResults=tab&tabfile=$map_file_URL&configfile=$config_file&sourcename=$sourcename&">link</a>
to draw the map.
<a href="http://berkeleymapper.berkeley.edu/index.html?ViewResults=tab&tabfile=$map_file_URL&configfile=$black_config_file&sourcename=$sourcename&"><img src="/images/black_square.gif"></a> 
<a href="http://berkeleymapper.berkeley.edu/index.html?ViewResults=tab&tabfile=$map_file_URL&configfile=$red_config_file&sourcename=$sourcename&"><img src="/images/red_square.gif"></a>
</h3>
</b>
</H3>
<br>
EOR
	}
	else{
$report=<<EOR;
Sorry. Coordinates were not in a form that can be mapped.
<br>
I can't parse:
<br>
$coords

EOR
	}

$MR=join("<br>",@map_results);
$mappable=<<EOP;
<html>
<head>
<title> Consortium of California Herbaria: Load Additional Coords </title>
<Meta Name="keywords" Content="UC Berkeley Herbarium, California floristics, Consortium of California Herbaria, UC Santa Barbara, UC Irvine, UC Riverside, UC Davis, UC Santa Cruz, Santa Barbara Botanic Garden, Jepson Herbarium ">
<link href="/consortium/style_consortium.css" rel="stylesheet" type="text/css">
</head>

<body>
<table class="banner" width="100%" border="0">
  			<tr>
    			<td align="center">Consortium of California Herbaria</td>
  			</tr>
  			<tr>

$report

</tr>
</table>

EOP
print $mappable;
#Institution<tab>accession_id<tab>taxon<tab>county<tab>latitude<tab>longitude<tab>datum
  }
  elsif($addfile){
$mapper_form=<<EOP;
<html>
<head>
<title> Consortium of California Herbaria: Load Coords </title>
<Meta Name="keywords" Content="UC Berkeley Herbarium, California floristics, Consortium of California Herbaria, UC Santa Barbara, UC Irvine, UC Riverside, UC Davis, UC Santa Cruz, Santa Barbara Botanic Garden, Jepson Herbarium ">
<link href="/consortium/style_consortium.css" rel="stylesheet" type="text/css">
</head>
<body>
<table class="banner" width="100%" border="0">
  			<tr>
    			<td align="center">Consortium of California Herbaria</td>
  			</tr>
<h3>
Map multiple record sets with coordinates using BerkeleyMapper
</h3>
<table width="100%" align="left" cellpadding="10">
<tr>
<td colspan=2>
<OL> 
<LI>Run a search from the <a href="/consortium/" target="_blank">CCH</a> search interface; 
<LI>select some or all of the records with coordinates; 
<LI>display the results as tab-separated text.  <br> 
<LI>Paste CCH tab-separated output into the form below: (depending on browser/OS, you may have to "view source" of the results and copy that) 
<LI> Click on "Add it" <LI> Add additional record sets from the subsequent page </OL>
</td>
</tr>
<tr>
<td align="left">
<form action="/cgi-bin/mapper_multi.pl" method="POST">
<INPUT TYPE=hidden name=multi value=$multi>
<INPUT TYPE=hidden name=tabfile value=$map_file_out>
<INPUT TYPE=submit name="mapit" VALUE="Add it"> </P>
<textarea name="coords", rows="40", cols="150"></textarea>
</form>
</td>
<td align="bottom">
</td>
</tr>
</table>

EOP
print $query->header;                    # create the HTTP header
print $mapper_form;
}

}
else{


#multi-file cumulative mode
$file_name=$tab_file_name;
		if($multi =~ m/^[1-5]$/){

if ($tab_map_file){
$tab_file_name=$tab_map_file;
}
elsif ($cumu_map_file){
$tab_file_name=$cumu_map_file;
}
else{
$tab_file_name=$file_name;
}


$multi +=1;
$map_file_path="BerkeleyMapper/";
$map_file_URL= $tab_file_name;
$map_file_out = $tab_file_name;
#$map_file_out =~ s/^http.+berkeley\.+BerkeleyMapper\/(.+\.txt)/$1/;

print $query->header;                    # create the HTTP header
print "m=$multi";

print "\n\nvariables PASSED ON==>$map_file_out|$map_file_URL|$mapit|$multi\n\n";

print null <<EOP;
ADD
	map_file_out = $map_file_out
	map_file_URL= $map_file_URL
EOP

print <<EOP;
ADD
	map_file_out = $tab_map_file
	map_file_URL= $map_file_URL
EOP
		}
		elsif($multi =~ m/^(0| *)$/){
$multi +=1;
$map_file_path="BerkeleyMapper/";
$map_file_out="$map_file_path$tab_file_name";
$map_file_URL="https://ucjeps.berkeley.edu/$map_file_out";

print $query->header;                    # create the HTTP header
print "m=$multi";

print "\n\nvariables PASSED ON==>$tab_file_name|$map_file_URL|$mapit|$multi\n\n";

print null <<EOP;
ADD
	map_file_out = $map_file_out
	map_file_URL= $map_file_URL
EOP

print <<EOP;
ADD
	map_file_out = $tab_map_file
	map_file_URL= $map_file_URL
EOP
		}
		else{
print $query->header;                    # create the HTTP header

print "\n\nvariables PASSED ON==>$tab_file_name|$map_file_URL|$mapit|$multi\n\n";

print <<EOP;
USE
	BAD map_file_out = $tab_map_file
	BAD map_file_URL= $map_file_URL
EOP
	}

  if($mapit) {

	$sourcename="Consortium Coordinate Loader";
	$coords=~s/\cM/\n/g;
	@coords=split(/\n/,$coords);
print $query->header;                    # create the HTTP header
	foreach(@coords){
		chomp;
		if(m/^ *(-?[0-9.]+), *(-?[0-9.]+)$/){
@fields=(
"specimen_id",
"name",
"collector",
"coll_number_prefix",
"coll_number",
"coll_number_suffix",
"early_jdate",
"late_jdate",
"date_string",
"county",
"elevation",
"locality",
"$1",
"$2",
"datum",
"source",
"error_distance",
"units",
);
		}
		elsif(m/^ *([A-Z]+\d+), *(-?[0-9.]+), *(-?[0-9.]+)$/){
@fields=(
"$1",
"name",
"collector",
"coll_number_prefix",
"coll_number",
"coll_number_suffix",
"early_jdate",
"late_jdate",
"date_string",
"county",
"elevation",
"locality",
"$2",
"$3",
"datum",
"source",
"error_distance",
"units",
);
		}
		else{
s/^ *//;
		@fields=split(/\t/,$_);
		}
		
		foreach $i (0 .. $#fields){
			print NULL "<br>$i $fields[$i]";
		}

		$sci_name="unknown";$county="unknown";
		if($fields[12] && $fields[13]){
#need to specify fields precisely!
#specimen_number	taxon name	collector	coll_number_prefix	coll_number	coll_number_suffix	early_jdate	late_jdate	date_string	county	elevation	locality	latitude	longitude	datum	source	error distance	units
#UCR105967	Phacelia campanularia subsp. campanularia	Valerie Soza		172		2450975	2450975	Jun 10 1998	San Bernardino	1463 m	  San Bernardino Mtns. East of Hwy 18, off road 3N36, 0.5 mi from entrance to road 3N36 from Hwy 18	34.3533333333333333	-116.84				
#UCR	UCR105967	Phacelia campanularia subsp. campanularia	Valerie Soza		172		2450975	2450975	Jun 10 1998	San Bernardino	1463 m	  San Bernardino Mtns. East of Hwy 18, off road 3N36, 0.5 mi from entrance to road 3N36 from Hwy 18	34.353	-116.84			03N01E11	NAD 27
		push(@map_results, "$inst\t$fields[0]\t$fields[1]\t$fields[9]\t$fields[12]\t$fields[13]\t$fields[14]");
		}
	}

	if(@map_results){
#$multi -=1;
print "<br>CUMU";
open(MAPFILE, ">>/data/tmp/$map_file_out") || print "cant open map file /data/tmp/$map_file_out $!";
print MAPFILE join("\n",@map_results),"\n";

print join("\n",@map_results),"\n";

close(MAPFILE);
$report=<<EOR;

O.K., the coordinates have been sent to BerkeleyMapper.
<br>
<b>
<h3>
Click on this
<a href="http://berkeleymapper.berkeley.edu/index.html?ViewResults=tab&tabfile=$map_file_URL&configfile=$config_file&sourcename=$sourcename&">link</a>
to draw the map.
<a href="http://berkeleymapper.berkeley.edu/index.html?ViewResults=tab&tabfile=$map_file_URL&configfile=$black_config_file&sourcename=$sourcename&"><img src="/images/black_square.gif"></a> 
<a href="http://berkeleymapper.berkeley.edu/index.html?ViewResults=tab&tabfile=$map_file_URL&configfile=$red_config_file&sourcename=$sourcename&"><img src="/images/red_square.gif"></a>
</h3>
<h3>
Click on this
<a href="https://ucjeps.berkeley.edu/cgi-bin/mapper_multi.pl?tabfile=$map_file_URL&addfile=1&multi=$multi">link</a>
to add additional records.
</h3>
</b>
</H3>
<br>
EOR
	}
	else{
$report=<<EOR;
Sorry. Coordinates were not in a form that can be mapped.
<br>
I can't parse:
<br>
$coords

EOR
	}
	
$MR=join("<br>",@map_results);
$mappable=<<EOP;
<html>
<head>
<title> Consortium of California Herbaria: Load Additional Coords </title>
<Meta Name="keywords" Content="UC Berkeley Herbarium, California floristics, Consortium of California Herbaria, UC Santa Barbara, UC Irvine, UC Riverside, UC Davis, UC Santa Cruz, Santa Barbara Botanic Garden, Jepson Herbarium ">
<link href="/consortium/style_consortium.css" rel="stylesheet" type="text/css">
</head>

<body>
<table class="banner" width="100%" border="0">
  			<tr>
    			<td align="center">Consortium of California Herbaria</td>
  			</tr>
  			<tr>

$report

</tr>
</table>

EOP
print $mappable;
#Institution<tab>accession_id<tab>taxon<tab>county<tab>latitude<tab>longitude<tab>datum
  }
  elsif($addfile){
$mapper_form=<<EOP;
<html>
<head>
<title> Consortium of California Herbaria: Load Coords </title>
<Meta Name="keywords" Content="UC Berkeley Herbarium, California floristics, Consortium of California Herbaria, UC Santa Barbara, UC Irvine, UC Riverside, UC Davis, UC Santa Cruz, Santa Barbara Botanic Garden, Jepson Herbarium ">
<link href="/consortium/style_consortium.css" rel="stylesheet" type="text/css">
</head>
<body>
<table class="banner" width="100%" border="0">
  			<tr>
    			<td align="center">Consortium of California Herbaria</td>
  			</tr>
<h3>
Map multiple record sets with coordinates using BerkeleyMapper
</h3>
<table width="100%" align="left" cellpadding="10">
<tr>
<td colspan=2>
<OL> 
<LI>Run a search from the <a href="/consortium/" target="_blank">CCH</a> search interface; 
<LI>select some or all of the records with coordinates; 
<LI>display the results as tab-separated text.  <br> 
<LI>Paste CCH tab-separated output into the form below: (depending on browser/OS, you may have to "view source" of the results and copy that) 
<LI> Click on "Add it" <LI> Add additional record sets from the subsequent page </OL>
</td>
</tr>
<tr>
<td align="left">
<form action="/cgi-bin/mapper_multi.pl" method="POST">
<INPUT TYPE=hidden name="multi" value=$multi>
<INPUT TYPE=hidden name="tabfile" value=$map_file_out>
<INPUT TYPE=hidden name="cumul" value="1">
<INPUT TYPE=submit name="mapit" value="Add it"> </P>
<textarea name="coords", rows="40", cols="150"></textarea>
</form>
</td>
<td align="bottom">
</td>
</tr>
</table>

EOP
print $query->header;                    # create the HTTP header
print $mapper_form;
  }
}