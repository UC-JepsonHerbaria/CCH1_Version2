<?php
date_default_timezone_set('America/Los_Angeles');


//if(isset($_POST['taxon_name']) || isset($_POST['loc']) || isset($_POST['county']) || isset($_POST['source']) 
// || isset($_POST['local']) || isset($_POST['elevlow']) || isset($_POST['elevhigh']) || isset($_POST['upperlat']) 
// || isset($_POST['pointlat']) || isset($_POST['collector']) || isset($_POST['collnum']) || isset($_POST['eventdate1']) 
// || isset($_POST['eventdate2']) || isset($_POST['catnum']) || isset($_POST['typestatus']) || isset($_POST['hasimages'])){
//    $stArr = $collManager->getSearchTerms();
//    $stArrSearchJson = json_encode($stArr);
//}



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
<title>CCH1: Search Page</title> 
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



<table id = "sideTable">
	<tr>
	<td style="vertical-align: top;width:200px;background-color:#C6C6E1;border-right-style: solid;border-right-color: #9090AA;border-left-style: solid;border-left-color: #9090AA;">
		<table id = "sideLinks" style="width:100%;">
		<tr>
			<td> <!-- <<background test>> -->
		<div style="border-bottom-style: solid;border-bottom-color: #9090AA;">
<!-- Start of sidebar menu-->
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/localnav_cch_home.php'); ?>
<!-- End of sidebar --> 
		</div>
			</td>
		</tr>
		</table>
	</td>
	<td style="vertical-align: top;background-color:#FFFFFF;"><img src="/common/images/common_spacer.gif" alt="" style="height:1px;width:15px;"></td>
	<td style="padding-top: 5px;vertical-align: top;width=80vw;">

<!-- Begin body section-->

	<span class="generalText">

<span class="pageName"><a href="/consortium/">CCH1:</a> Search page</span>

<br />
<p>If you are looking for non-California or non-vascular collections from CCH members, use CCH2 - <a href="https://cch2.org/portal/">cch2.org/portal/</a></p>

<p>The 2003-2018 version of the CCH1 website is no longer updated and can be found here - <a href="https://ucjeps.berkeley.edu/cch_archive/">ucjeps.berkeley.edu/cch_archive/</a></p>


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

<center>

<table>
<tr>
	<td style="vertical-align: top;background-color:#FFFFFF;">
		<table><tr>
			<td style="vertical-align: top;background-color:#FFFFFF;"><img alt="" height="" src="construct.bmp"></td>
			<td style="vertical-align: top;background-color:#FFFFFF;"><br /><br /><font color="red"> This site is under re-development.  
Results of searches may occasionally not work as expected. A CCH2-compatible data structure is being implemented 
in stages and the website is being constantly upgraded as a result.</font></td>
		</tr></table>
		</p><br /><br />
		<p class="pageSubheading">Vascular Plants of California<a name="TOP" id="TOP"></a></span>
	</td>
</tr>
	<!--BEGIN Left Side Content-->	
  <table>
  <tr>
	<td style="width: 60%;vertical-align: top;background-color:#FFFFFF;">
<form method="POST" action="/consortium/cchlist.php" >
	<p class="pageSubheading"><b>Scientific Name Search</b><br />
 	<input id="query_text" type="text" name="taxon_name" size = 50 MAXLENGTH = 50></input><br />
	<input type ="checkbox" name="SYNCHECK" value="1">Select to search all synonyms (leave unchecked for a keyword name search)
 	<br />
		<span class="bodySmallerText">e.g.:<a href="/consortium/cchlist.php?taxon_name=Bromus">Bromus</a>;
		</span>
	</p>

		<table style="width: 95%;vertical-align: top;background-color:#FFFFFF;">
		<tr>
			<td style="width: 45%;">
	<p><span class="pageSubheading"><font color="red">(NEW FEATURE, not activated)</font><br />
	<label for="nativity">Nativity:<br /></label></span>
	<select id="query_text" name="nativity" >
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch_eflora_nativity_options.php'); ?>
	</select>
	<br />
		<span class="bodySmallerText"><b>
		Return only names with a nativity <br />
		status sensu the Jepson eFlora<br />
e.g.:<a href="/consortium/cchlist.php?nativity=Waif">Waif</a></b>
		</span>
	</p>
			</td>

			<td style="width: 45%;padding-left: 10px;padding-right 10px;">
	<p><span class="pageSubheading"><font color="red">(NEW FEATURE, not activated)</font><br />
	<label for="life">Life Form:<br /></label></span>
	<select id="query_text" name="life">
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch_eflora_life_form_options.php'); ?>
	</select>
	<br />
		<span class="bodySmallerText"><b>
		Return only names with a life 
		<br />
		form status sensu the Jepson eFlora<br />
		e.g.:<a href="/consortium/cchlist.php?life=tree">tree</a></b>
		</span>
	</p>
			</td>
		</tr>

		<tr>
			<td style="width: 45%;">
			
	<p><span class="pageSubheading">
	<label for="county">County:<br /></label></span>
	<select id="query_text" name="county" size=12>
	<!--<select id="query_text" name="county" size=12 multiple>-->
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch_county_options.php'); ?>
	</select>
	<br />
		<span class="bodySmallerText">(default is all counties)<br />
		<font color="red">(selecting multiple values not re-activated)</font>
		</span>
	</p>
			</td>

			<td style="width: 45%;padding-left: 10px;padding-right 10px;">

	<p class="pageSubheading"><b>Geographic Locality</b>
	<br />
 	<input id="query_text" type="text" name = "loc" size = 40 MAXLENGTH = 50></input>
 	<br />
		<span class="bodySmallerText">e.g.:
		<a href="/consortium/cchlist.php?loc=French%20Meadow">French Meadow</a>;
		</span>
	</p>
	<br />
	<p class="pageSubheading"><font color="red">(NEW FEATURE, not activated)</font><br />
	<input type ="checkbox" name="ELEVCHECK" value="1">Select to display only specimens with an elevation
	<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OR<br />
	<b>Search Elevation</b> <br />
        <input name = "minelev" size = 6>&nbsp;&nbsp;&nbsp;TO&nbsp;&nbsp;&nbsp;<input name = "maxelev" size = 6> (meters)
	</p>
<!-- Geographic Region Box, the code to implement this is very complicated in get_consort.pl.-->
<!-- I am not sure at this point if I can translate it to PHP, so it is commented out for now-->
<!-- In its place I have placed the locality box for now-->
<!--	<p><span class="pageSubheading"><font color="red">(not re-activated)</font><br />
	<label for="region">Geographic Region:<br /></label></span>
	<select id="query_text" name="region" size=12>
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch_region_options.php'); ?>
	</select><br />
	<span class="bodySmallerText">(Regions defined by bounding-box)<br />
	</span>
	</p>-->
			</td>
		</tr>
		</table>

		<p>
		<table style="width: 95%;vertical-align: top;background-color:#9090AA;">
		<tr>
			<td class="tagList" style="padding: 5px;">
				<span class="pageSubheading">Refine or Expand Search</span>
				<br /><hr>
				<!-- YF checkbox-->
				<input type="checkbox" name="YF" value="1">
				Enable yellow flags <font color="firebrick">(not re-activated)</font><br />
				&nbsp;&nbsp;&nbsp;&nbsp;(displays possible range discrepancies with yellow icons)
				<br /><br />
				<!-- CNPS checkbox-->
				<input type ="checkbox" name="ENDEM" value="1">
				Endemic <font color="firebrick">(NEW FEATURE, not activated)</font><br />
				&nbsp;&nbsp;&nbsp;&nbsp;(return only endemics to California, sensu the Jepson eFlora)
				<br /><br />
				<!-- CNPS checkbox-->
				<input type ="checkbox" name="CNPS" value="1">
				CNPS Inventory <font color="firebrick">(not re-activated)</font><br />
				&nbsp;&nbsp;&nbsp;&nbsp;(return only names in California Native Plant Society Inventory)
				<br /><br />
				<!-- CAL-IPC - CDFA checkbox-->
				<input type ="checkbox" name="CALIPC" value="1">  
				Noxious weeds <font color="firebrick">(not re-activated)</font><br />
				&nbsp;&nbsp;&nbsp;&nbsp;(return only records of CAL-IPC or CDFA listed weeds)
				<br /><br />
				<!-- CULT checkbox-->
				<input type ="checkbox" name="cultivated" value="1">
				Cultivated specimens <font color="firebrick">(NEW FEATURE, not activated)</font><br />
				&nbsp;&nbsp;&nbsp;&nbsp;(enable purple flags and include specimens labeled as cultivated)
				<br /><br />
				<!-- GEO checkbox-->
				<input type="checkbox" name="geo_only" value="1">
 				Specimens with coordinates <font color="firebrick">(not re-activated)</font>
				<br /><br />
				<!-- NO GEO checkbox-->
				<input type="checkbox" name="geo_no" value="1">
 				Specimens without coordinates <font color="firebrick">(not re-activated)</font>
 				<br ><br />
 				<!-- VTM checkbox-->
 				<input type="checkbox" name="VTM" value="1">
 				Vegetation Type Map specimens <font color="firebrick">(not re-activated)</font>
				<br><br />
				<!-- TAX LIST checkbox-->
				<input type ="checkbox" name="make_tax_list" value="1">
 				Name list <font color="firebrick">(not re-activated)</font><br />
				&nbsp;&nbsp;&nbsp;&nbsp;(return only one record for each name)
				<br /><br />
			</td>
		</tr>
		</table>
		
	</td>
	<!--END LEFT Side UPPER Content-->	


	<!--BEGIN RIGHT Side UPPER Content-->	
	<td style="padding-left: 10px;padding-right: 10px;width: 40%;vertical-align: top;background-color:#FFFFFF;">
	
	<p class="pageSubheading"><b>Source</b> 
	<br />
	<select name="source" size=20>
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch_participants_options_CCH2.php'); ?>
	</select>
	<br />
		<span class="bodySmallerText">(default is all sources)<br />
		<font color="red">(selecting multiple values not re-activated)</font></span>
	</p>
	<br /><br />
	<p class="pageSubheading"><b>Collector</b> <font color="red">(not re-activated)</font>
        <input name = "collector" size = 50 MAXLENGTH = 100><br />
    	<span class="bodySmallerText">(last name only; e.g.:
			<a href="/consortium/cchlist.php?collector=Muir">Muir</a>;
  			<a href="/consortium/cchlist.php??collector=Moref">Moref</a>)
		</span>
	</p>

	<p class="pageSubheading"><b>Collector Number</b> <font color="red">(not re-activated)</font>
        <input name = "collnum" size = 50 MAXLENGTH = 50><br />
    	<span class="bodySmallerText">(any type, including strictly numerical or alpha-numeric <br />e.g.:
			<a href="/consortium/cchlist.php?collnum=2334">2334</a>)
		</span>
	</p>
	<br /><br />
	<p class="pageSubheading"><input type ="checkbox" name="TYPECHECK" value="1">Select to display all specimens with a type status
	<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OR<br />
	<b>Search Type Status</b> <font color="red">(NEW FEATURE, not activated)</font>
        <input name = "type" size = 50 MAXLENGTH = 100><br />
    	<span class="bodySmallerText">(search for a specific or more general type phrase <br />e.g.:
			<a href="/consortium/cchlist.php?type=holotype">holotype</a>;
  			<a href="/consortium/cchlist.php??type=type">type</a>)
		</span>
	</p>
	</td>
	<!--END RIGHT Side UPPER Content-->	
	</tr>

	<tr>
<!--BEGIN LEFT Side LOWER Content-->	
<!-- BEGIN USE TERMS LEFT-->

		<td style="height: 40px;padding: 10px;vertical-align: top;background-color:#FFFFFF;">
<hr>
			<input TYPE="submit" VALUE="Accept data-use terms, submit search" >&nbsp;&nbsp;&nbsp;&nbsp;			
			<span class="pageSubheading"><b><a href="/consortium/data_use_terms.html">Read&nbsp;use&nbsp;terms</a></b></span>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<input TYPE="reset" VALUE="Reset Form">
		</td>
<!-- END USE TERMS LEFT-->
<!--END LEFT Side LOWER Content-->	
			
<!--BEGIN RIGHT Side LOWER Content-->			
<!-- BEGIN USE TERMS RIGHT-->		
		<td style="padding: 10px;vertical-align: top;background-color:#FFFFFF;">
<hr>
			<span class="pageSubheading"><b>2000 records is the default maximum. For larger data requests contact</b>
				<a href="mailto:jason_alexander@berkeley.edu">Jason Alexander (jason_alexander@berkeley.edu)</a>
			</span>
		</td>
	</tr>
<!-- END USE TERMS RIGHT-->
<!--END RIGHT Side LOWER Content-->	
</form>

	</table>
		<!--END Content Table-->	
	
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