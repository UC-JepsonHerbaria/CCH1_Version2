<?php
date_default_timezone_set('America/Los_Angeles');


//get user input from POST
if (isset($_POST['taxon_name'])){
	$SearchTAX = $_POST['taxon_name'];
}

	
if (isset($_GET['taxon_name'])){
	$SearchTAX = $_GET['taxon_name'];
}

if (isset($_POST['loc'])){
	$SearchLOC = $_POST['loc'];
}

if (isset($_GET['loc'])){
	$SearchLOC = $_GET['loc'];
}

if (isset($_POST['county'])){
	$SearchCOUNTY = $_POST['county'];
}

if (isset($_GET['county'])){
	$SearchCOUNTY = $_GET['county'];
}

if (isset($_POST['source'])){
	$SearchSOURCE = $_POST['source'];
}

if (isset($_GET['source'])){
	$SearchSOURCE = $_GET['source'];
}

//connect to the database
require '../../ucjeps_data/ucjeps_data/config/config_cch.php';
$db = new SQLite3($database_location);
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<?php 
//add note or other code here for variables
?>

<head>
<title>CCH1: Search Results Page</title> 
<meta charset="UTF-8">
<meta name="description" content="The Consortium of California Herbaria is the organization that supports all herbaria in California.">
  <meta name="keywords" content="Consortium of California Herbaria, CCH1, georeferencing, coordinates, biogeography, California Flora, Flora of California, Vascular Plants of California, Jepson Flora Project, Jepson eFlora">
  <meta name="viewport" content="width=device-width, initial-scale=1">
<link href="/common/css/style_consortium.css" rel="stylesheet" type="text/css">
	<link rel="shortcut icon" href="/common/images/cch/CCH_logo_02_80.png" type="image/x-icon" />


<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-43909100-3"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-43909100-3');

</script>

</head>
<body>

<table id="normaltable">
  <tr>
   <td class="spacer1"><img src="/common/images/common_spacer.gif" alt="" style="height:1px;width:15px;"></td>
	<td>
	 <table id="cchpageback">
	  <tr>
	   <td>
<div class="cch-top-image-xy002crop">
<!-- COMMON HEADER -->
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch1v2img_header.php'); ?>
<!-- COMMON HEADER ENDS -->
</div>
<div >



<table id = "sideTable">
	<tr>
	<td style="vertical-align: top;background-color:#FFFFFF;"><img src="/common/images/common_spacer.gif" alt="" style="height:1px;width:15px;"></td>
	<td style="padding-top: 5px;vertical-align: top;width=80vw;">

<!-- Begin body section-->

	<span class="generalText">

<span class="pageName"><a href="/consortium/">CCH1:</a> Search Results</span>

<br />

<center>

<table>

<tr>
	<!--BEGIN Left Side UPPER Content-->	
	<td style="vertical-align: top;background-color:#FFFFFF;">
<p><img alt="" height="" src="construct.bmp"><font color="red"> This site is under re-development.  
Results of searches may occasionally not work as expected. A CCH2-compatible data structure is being implemented 
in stages and the website is being constantly upgraded as a result.</font>
	</p>
<hr>
<table>
<tr><td style="vertical-align: top;background-color:#FFFFFF;"><p class="generalText">Please cite data retrieved from this page:<br />
Biodiversity data provided by the participants of the Consortium of California Herbaria (Accessed through CCH1 Data Portal, ucjeps.berkeley.edu/consortium/, <?php echo date ("Y F d") ?>.
<br /><br />
Literature Citation:<br />
CCH1 Portal. <?php echo date("Y") ?>. Biodiversity data provided by the participants of the Consortium of California Herbaria (https://ucjeps.berkeley.edu/consortium/ Accessed on <?php echo date ("F d") ?>).</p>
</td></tr>

<tr><td style="vertical-align: top;background-color:#FFFFFF;"><p class="generalTextg">Records are made available under the <a href="/consortium/data_use_terms.html">CCH Data Use Terms</a>.</p>
</td></tr>
</table>
<hr>
<p>Click on column header to sort data (* sorts by family); click in leftmost checkbox to select record. <a href="/consortium/detail_help.html">CCH Help Page</a>.


<form method="POST" action="//<?php echo $_SERVER['PHP_SELF'];?>">
</form>

<!--
if($CDL_fields[-1]=="1" && $YF){
$geo_warning="<td bgcolor=yellow>&nbsp;</td>";
}
else{
$geo_warning="<td bgcolor=#eeeeee>&nbsp;</td>";
}
	push(@result, <<EOP-->
<!-- $sort_string -->
<!--<tr>
<td $check_bgcolor><input type ="checkbox" name="checked_AID" value=$accession_id $checked></td>
$geo_warning
<td><a href="/cgi-bin/$detail?$accession_id&YF=$YF">$accession_id</a>&nbsp;$image_link</td>
<td>$tax_name</td>
<td>$CDL_fields[1]</td>
<td>$formattedDate</td>
<td>$collno_string</td>
<td>$CDL_fields[8]</td>
<td>$CDL_fields[10]</td>
<td>$elev</td>
<td valign="top"><a href="/cgi-bin/get_consort.pl?sugg=$accession_id">Comment</a> $seen_sugg</td>
</tr>

#old line with problem coll num fields that shoved everything into a single line without breaks
#12345 would be the same as 123 45 if 45 was in the suffix CNUM field 4, this is causes a discrepancy with the data display and data output (which has all 3 fields separate).
#<td>$CDL_fields[2]$CDL_fields[3]$CDL_fields[4]</td>
#this was placed below the data field above

	if($CDL_fields[11] && $CDL_fields[12]){
		($institution=$accession_id)=~s/\d.*//;
if($YF){
if($CDL_fields[-1]==1){
$institution="YF";
}
else{
$institution="BLUE";
}
		push(@map_results, join("\t", $institution, $accession_id, $TID_TO_NAME{$CDL_fields[0]}, @CDL_fields[1 .. $#CDL_fields]));
}
else{
		push(@map_results, join("\t", $institution, $accession_id, $TID_TO_NAME{$CDL_fields[0]}, @CDL_fields[1 .. $#CDL_fields]));
}
	}
	else{
	#print "no $accession_id";
	}
}
-->

<!--
###CNPS list file, which should be updated and/or integrated with the eFlora's CNPS taxon indication
if($query->param('CNPS_listed')){
	$include_CNPS=1;
	open(IN,"${data_path}cnps_taxon_ids.txt") || die $!;
	while(<IN>){
		chomp;
		$CNPS_tid{$_}++;
	}
	close(IN);
}
else{
	$include_CNPS=0;
}
-->

<!--
###Cal-IPC weed file. Same deal as CNPS list
if($query->param('weed')){
	$include_weed=1;
	open(IN,"${data_path}CDL_weed_tid") || die $!;
	while(<IN>){
		chomp;
		$weed_tid{$_}++;
	}
	close(IN);
}
else{
	$include_weed=0;
}
-->

<!--
#$pers = $query->param('personal') if $query->param('personal');
#$nonprofit = $query->param('nonprofit') if $query->param('nonprofit');
#$fed = $query->param('federal') if $query->param('federal');
#$state = $query->param('state') if $query->param('state');
#$consult = $query->param('consult') if $query->param('consult');
#$profit = $query->param('private') if $query->param('private');
if($query->param('personal')){
	$pers = $query->param('personal');
}
else{
	$pers = "";
}

if($query->param('nonprofit')){
	$nonprofit = $query->param('nonprofit');
}
else{
	$nonprofit = "";
}

if($query->param('federal')){
	$fed = $query->param('federal');
}
else{
	$fed = "";
}

if($query->param('state')){
	$state = $query->param('state');
}
else{
	$state = "";
}

if($query->param('consult')){
	$consult = $query->param('consult');
}
else{
	$consult = "";
}

if($query->param('private')){
	$profit = $query->param('private');
}
else{
	$profit = "";
}
-->

       <br /><span class="generalText"><a name="TOP" id="TOP"></a></span>

<?php

if((isset($SearchTAX)) || (isset($SearchLOC)) || (isset($SearchCOUNTY)) || (isset($SearchSOURCE))){

	$SearchTAX = trim($SearchTAX, $character_mask = " \t\n\r\0\x0B");
	$SearchLOC = trim($SearchLOC, $character_mask = " \t\n\r\0\x0B");
	$SearchCOUNTY = trim($SearchCOUNTY, $character_mask = " \t\n\r\0\x0B");
	$SearchSOURCE = trim($SearchSOURCE, $character_mask = " \t\n\r\0\x0B");

//Security mod to prevent cross-site scripting attacks
	$SearchTAX = preg_replace("/[^a-zA-Z-\s.]/", "", $SearchTAX);
	$SearchLOC = preg_replace("/[^a-zA-Z\s.]/", "", $SearchLOC);
	$SearchCOUNTY = preg_replace("/[^a-zA-Z\s.]/", "", $SearchCOUNTY);
	$SearchSOURCE = preg_replace("/[^a-zA-Z-\s.]/", "", $SearchSOURCE);


//print to screen the search terms used
	echo '<p class="bodyText">You searched for: ';
	//if (isset($SearchTAX){
		echo $SearchTAX;
	//}
	//if (isset($SearchLOC){
		echo " ".$SearchLOC;
	//}
	
	//if (isset($SearchLOC){
		echo " ".$SearchSOURCE;
	//}
	echo '</p>';

//modify search terms to CCH1 data formats
	if (strpos($SearchTAX, " ssp. ") !== false) { //in case someone uses ssp.
		$SearchTAX = str_replace(" ssp. ", " subsp. ", $SearchTAX);
	}

	$SearchTAX = str_replace(" ", "%", $SearchTAX); //replace space with wildcard, so e.g. "Art cal" returns "Artemisia californica"
	$SearchTAX = str_replace("+", "%", $SearchTAX); //replace '+' with wildcard, so e.g. "Artemisia+californica" returns "Artemisia californica"

#fix some searches by family that have issues
	$SearchTAX = str_replace("Umbelliferae", "Apiaceae", $SearchTAX); //replace 'Umbelliferae' with accepted family name, returns "Apiaceae"
	$SearchTAX = str_replace("Palmae", "Arecaceae", $SearchTAX); //replace 'Palmae' with accepted family name, returns "Arecaceae"
	$SearchTAX = str_replace("Compositae", "Asteraceae", $SearchTAX); //replace 'Compositae' with accepted family name, returns "Asteraceae"
	$SearchTAX = str_replace("Cruciferae", "Brassicaceae", $SearchTAX); //replace 'Cruciferae' with accepted family name, returns "Brassicaceae"
	$SearchTAX = str_replace("Guttiferae", "Clusiaceae", $SearchTAX); //replace 'Guttiferae' with accepted family name, returns "Clusiaceae"
	$SearchTAX = str_replace("Leguminosae", "Fabaceae", $SearchTAX); //replace 'Leguminosae' with accepted family name, returns "Fabaceae"
	$SearchTAX = str_replace("Labiatae", "Lamiaceae", $SearchTAX); //replace 'Labiatae' with accepted family name, returns "Lamiaceae"
	$SearchTAX = str_replace("Gramineae", "Poaceae", $SearchTAX); //replace 'Gramineae' with accepted family name, returns "Poaceae"




//     $SearchTAX = $SearchTAX."%";
//     $SearchLOC = "%" . $SearchLOC . "%";


//Status for accepted names is 'ACCEPTED', so you have to self-join the accepted NameTID 
//to the SYNNameTID to get the full ICPN status from ICPN_StatusSYN
//"SELECT e.ICPN_StatusSYN  AS 'ICPN_statusACC',
//FROM cch_synonyms e
//INNER JOIN cch_synonyms m ON m.ACCName = e.SYNName 
//WHERE ACCName = $SearchTAX"
//only instances where the TID between ACC and SYN are equal should the synonym name and accepted name be equal and have an accepted status


//the following sql code segment based on that written by users galhad2 and andrewsmd
//dated october 2009, titled 'PHP search form with multiple inputs'
//found in an archive within the url: https://www.webmasterworld.com/php/4005747.htm
	$sql = "SELECT * FROM cch_main INNER JOIN cch_synonyms on cch_synonyms.SYNNameTID = cch_main.TaxonID WHERE ";
	$and = "0";

//cch_synonyms(SYNNameTID, ICPN_StatusSYN, ACCNameTID, ICPN_StatusACC, EF_Nativity)

//$acc_query = $db->prepare('SELECT ACCNameTID FROM cch_synonyms WHERE ACCName = '.$SearchTAX);
//$acc_result = $acc_query->execute();
//var_dump($acc_result->fetchArray());
//then use the implode array feature in an "displayName IN ('value1,value2')" statement
	if(trim($result)!= '') {

	
	}
	else{

//$synquery = $db->prepare('SELECT SYNNameTID FROM cch_synonyms WHERE SYNName = '.$SearchTAX);
//$synresult = $synquery->execute();
//var_dump($synresult->fetchArray());

	}




		if(trim($SearchTAX)!= '') {
			$and = "1";
			//if(trim($and)!= '') {$SQL .= " OR ";}
			$sql .= "(displayName LIKE '".$SearchTAX."%' OR currentDetermination LIKE '".$SearchTAX."%' OR hybrid_formula LIKE '".$SearchTAX."%')";
		}

		if(trim($SearchLOC)!= '') {
			$and = "1";
			if(trim($and)!= '') {$sql .= " AND ";}
			$sql .= "locality LIKE '%".$SearchLOC."%'";
		}
		
		if(trim($SearchCOUNTY)!= '') {
			$and = "1";
			if(trim($and)!= '') {$sql .= " AND ";}
			$sql .= "verbatimCounty LIKE '".$SearchCOUNTY."%'";
		}
		
		if(trim($SearchSOURCE)!= '') {
			$and = "1";
			if(trim($and)!= '') {$sql .= " AND ";}
			$sql .= "institutionCode LIKE '".$SearchSOURCE."'";
		}

		//$sql = "SELECT * FROM cch_main WHERE (displayName LIKE '".$SearchTAX."' AND locality LIKE '".$SearchLOC."' ";


		$sql .=  " ORDER BY displayName LIMIT 2000";

     //$stmt = $db->prepare("SELECT * FROM cch_main WHERE displayName LIKE '".$SearchTAX."' ORDER BY displayName LIMIT 2000");
     $stmt = $db->prepare($sql);
     
     //$stmt->bindValue(':DN', $SearchTAX);
     //$stmt->bindValue(':LC', $SearchLOC);
     $query = $stmt->execute();

echo '<p>'.$sql.'</p>';

// Fetch the first row
$row = $query->fetchArray();

// If no results are found, echo a message and stop
	if ($row == false){
		echo '<b>'.$SearchTAX.'</b> was not found in CCH1.<br />Try another search.<br />';
    	exit;
	}
	//count rows
        $numRows = 0;
        while($row = $query->fetchArray()){
            ++$numRows;
        }
	echo '<p class="bodyText">Your search returned '.$numRows.' rows.<p>';

//display results in a table
		echo '<div><table border="1">';
		echo '<tr><td>HerbCode</td><td>CCH1_AID</td><td>current name</td><td>county</td><td>locality</td></tr>';

			while ($row = $query->fetchArray()) {
			echo '<tr><td style "width">'.$row['institutionCode'].'</td>';
			echo '<td>'.$row['CCH1_AID'].'</td>';
			echo '<td>'.$row['displayName'].'</td>';
			echo '<td>'.$row['verbatimCounty'].'</td>';
			echo '<td>'.$row['locality'].'</td></tr>';
			}
		echo '</table></div>';

}
else {
	echo 'No search term entered. Please enter a search term above<br />';
}


?>

		</td>
	</tr>
	
	<tr>
		<td>
<p class="bodyText">You searched for: <br />
	<pre>
<?php var_dump($_POST); ?>
	</pre>
</p>
		</td>
	</tr>
	</table> <!--close sideNav table-->
<!--begin footer-->
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch_footer.php'); ?>
<!--end footer-->

	</div>
   </td>
  </tr>
</table> <!--close box outline table-->
  

 
 	</td>
   <td class="spacer1"><img src="/common/images/common_spacer.gif" alt="" style="height:1px;width:15px;"></td>
  </tr>
 </table> <!--close outside normal table-->


</body>
</html>