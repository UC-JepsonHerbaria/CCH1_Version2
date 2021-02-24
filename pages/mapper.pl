#!/usr/bin/perl
use CGI;
$query = new CGI;                        # create new CGI object
my $coords = $query->param('coords');

#Output file to store data for Berkeley Mapper
$tab_file_name="CHC_" . substr($start_time,6,4) . $$ . ".txt";
$map_file_path="BerkeleyMapper/";
$map_file_out="$map_file_path$tab_file_name";
$map_file_URL="https://ucjeps.berkeley.edu/$map_file_out";


#Where you tell Berkeley Mapper the configuration file is
      $config_file='https://ucjeps.berkeley.edu/test_mapper.xml';
  $red_config_file='https://ucjeps.berkeley.edu/test_red.xml';
$black_config_file='https://ucjeps.berkeley.edu/test_black.xml';

$sourcename="Consortium Coordinate Loader";
$coords=~s/\cM/\n/g;
@coords=split(/\n/,$coords);
print $query->header;                    # create the HTTP header
foreach(@coords){
#print  "$_<br>";
	chomp;
	s/^ *//;
	s/ *$//;
	#s/\cM//;
	s/"//g;
	next if m/^species_ID/;
	if(m/^(([A-Z]+)\d+) *,([A-Za-z ]+), *([0-9.-]+) *, *([0-9.-]+) *$/){
		$inst=$2;$lat=$4; $long=$5; $datum=$6;$accession_id=$1;
		$sci_name=$3; $county="";
		push(@map_results, "$inst\t$accession_id\t$sci_name\t$county\t$lat\t$long\t$datum");
	}
	elsif(m/([A-Z]+),(\d),([A-Za-z0-9]+),([0-9.-]+),([0-9.-]+),([A-Z]+.*)/){
		$inst="MVZ";$lat=$4; $long=$5; $datum=$6;$accession_id=$2;
		$sci_name=$1; $county=$3;
		push(@map_results, "$inst\t$accession_id\t$sci_name\t$county\t$lat\t$long\t$datum");
$config_file='/mvz_data.xml';
	}
#GLAFUSC,0,sew00790,-16.55608937,145.2785117,WGS84

	elsif(m/^(([A-Z]+)\d[^\t]+)\t([\d.-]+)\t([\d.-]+)\t/){
		$inst=$2; $accession_id=$1; $lat=$3; $long=$4; $datum="NAD27";
		$sci_name="unknown";$county="unknown";
		push(@map_results, "$inst\t$accession_id\t$sci_name\t$county\t$lat\t$long\t$datum");
	}
	elsif(m/^(([A-Z]+)\d[^,]+), *([\d.-]+), *([\d.-]+)/){
		$inst=$2; $accession_id=$1; $lat=$3; $long=$4; $datum="NAD27";
		$sci_name="unknown";$county="unknown";
		push(@map_results, "$inst\t$accession_id\t$sci_name\t$county\t$lat\t$long\t$datum");
	}
	elsif(
		($lat,$long)=m/(-?\d+\.\d+), *(-?\d+\.\d+)/){
#s/^[^,]*,//;
#($lat,$long)=split(/,\s*/,$_);
		$inst="CCH"; $accession_id="XX"; $datum="NAD27";
		$sci_name="unknown";$county="unknown";
		push(@map_results, "$inst\t$accession_id\t$sci_name\t$county\t$lat\t$long\t$datum");
	}
	else{
}
#$long=~s/\cM//;
}

if(@map_results){
open(MAPFILE, ">/data/tmp/$map_file_out") || print "cant open map file /data/tmp/$map_file_out $!";

print MAPFILE join("\n",@map_results),"\n";
close(MAPFILE);
$report=<<EOR;

O.K., the coordinates have been sent to BerkeleyMapper.
<br />
FILE:/data/tmp/$map_file_out<br />
<b>
<h3>
Click on this
<a href="http://berkeleymapper.berkeley.edu/index.html?ViewResults=tab&tabfile=$map_file_URL&configfile=$config_file&sourcename=$sourcename&">link</a>
to draw the map.
<a href="http://berkeleymapper.berkeley.edu/index.html?ViewResults=tab&tabfile=$map_file_URL&configfile=$black_config_file&sourcename=$sourcename&"><img src="/images/black_square.gif"</a> 
<a href="http://berkeleymapper.berkeley.edu/index.html?ViewResults=tab&tabfile=$map_file_URL&configfile=$red_config_file&sourcename=$sourcename&"><img src="/images/red_square.gif"</a>




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
<br>
Copy and paste out of another file or
type in coordinates in this form:
<br>
<pre>
38.3452, -122.456
38.556, -122.456O
</pre>
<br>
That is: decimal latitude [comma] [space] decimal longitude [newline]

EOR
}

$MR=join("<br>",@map_results);
$mappable=<<EOP;
<html>
<head>
<title>
Consortium of California Herbaria: Load Coords
</title>
<Meta Name="keywords" Content="California floristics, Consortium of California Herbaria">
<link href="/common/css/style_consortium.css" rel="stylesheet" type="text/css">
</head>

<body>

<table class="banner" width="100%" border="0">
  <tr>
    <td align="center">Consortium of California Herbaria</td>
  </tr>
</table>
<!-- Beginning of horizontal menu -->
<table class=horizMenu width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="21" width="640" align="right">
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <a href="/consortium/participants.html" class="horizMenuActive">
            Participants</a>
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <a href="/consortium/news.html" class="horizMenuActive">News</a>
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <a href="/consortium/" class="horizMenuActive">Search</a>
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <a href="/consortium/about.html" class="horizMenuActive">About</a>
    </td>
        <td />
  </tr>
 <tr>
    <td colspan="6" bgcolor="#9FBFFF"><img src="/images/common_spacer.gif" alt="" width="1" height="1" border="0" /></td>
  </tr>
</table>
<!-- End of horizontal menu -->

$report

EOP
print $mappable;
#Institution<tab>accession_id<tab>taxon<tab>county<tab>latitude<tab>longitude<tab>datum
