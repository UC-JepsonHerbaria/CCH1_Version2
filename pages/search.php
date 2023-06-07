<?php
date_default_timezone_set('America/Los_Angeles');



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
<p>If you are looking for non-California or non-vascular collections from CCH members, use CCH2 - <a href="https://cch2.org/portal/">cch2.org/portal/</a></p>

<!--<p>The 2003-2018 version of the CCH1 website is no longer updated and can be found here - <a href="https://ucjeps.berkeley.edu/cch_archive/">ucjeps.berkeley.edu/cch_archive/</a></p>
-->
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

 <tr>
	<td style="vertical-align: top;background-color:#FFFFFF;">
<p>Please send questions or comments to Jason Alexander (<a href="mailto:jason_alexander@berkeley.edu">jason_alexander@berkeley.edu</a>).<br />
</p>
	</td>
 </tr>


</table>
<hr>

<!--<table>
<tr>
	<td style="vertical-align: top;background-color:#FFFFFF;">
		<table><tr>
			<td style="vertical-align: top;background-color:#FFFFFF;"><img alt="" height="" src="construct.bmp"></td>
			<td style="vertical-align: top;background-color:#FFFFFF;"><br /><br /><font color="red"> This site is under re-development.  
Results of searches may occasionally not work as expected. A CCH2-compatible data structure is being implemented 
in stages and the website is being constantly upgraded as a result.</font></td>
		</tr></table></p><br /><br />-->	
		
	<!--BEGIN Left Side Content-->	

<center>
  <table style="width: 95%;vertical-align: top; background-color:#9090AA;">
	<tr>
		<td style="width: 95%;vertical-align: top;background-color:#FFFFFF;"><center><span class="pageName"><a name="TOP" id="TOP">CCH1: Vascular Plants of California Search Page</a></span></center>
		</td>
	</tr>
  </table>
</center>

  <table>
  	<tr>
	<td style="width: 60%;vertical-align: top;background-color:#FFFFFF;">

<form method="GET" action="/consortium/list.php">

		<table style="width: 95%;vertical-align: top;background-color:#FFFFFF;">
  			<tr>
				<td style="width: 95%;vertical-align: top;background-color:#FFFFFF;">

	<p class="pageSubheading"><b>Scientific Name Search</b><a href="/consortium/search_help.html#name"><sup>&nbsp;?&nbsp;&nbsp;</sup></a>
	<br />
 	<input id="query_text" type="text" name="taxon_name" size = 50 MAXLENGTH = 50></input><br />
	<input type ="checkbox" name="syncheck" value="1">Select to search for only the entered name <br />(leave unchecked to search all synonyms)
 	<br />
		<span class="bodySmallerText">e.g.:&nbsp;<a href="/consortium/list.php?taxon_name=Dudleya blochmaniae">Dudleya blochmaniae</a><br />
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="/consortium/list.php?taxon_name=Dudleya blochmaniae insul">Dudleya blochmaniae insul</a><br />
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="/consortium/list.php?taxon_name=Quercus X alvordiana">Quercus&nbsp;X&nbsp;alvordiana</a><br />
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="/consortium/list.php?taxon_name=Art% cal">Art+ cal</a> 'Artemisia californica' using wildcards<br />
		</span>
	</p>
				</td>
			</tr>
<!--$current_request= ?taxon_name=$lookfor&nativity=$req_source&county=$county&collector=$collector&aid=$aid&collyear=$year&collmonth=$month&collday=$day&loc=$quote_loc&coll_num=$coll_num&max_rec=$max_return&make_tax_list=$make_tax_list&before_after=$before_after&last_comments=$last_comments&VV=$v_restrict&non_native=$include_nn&geo_only=$geo_only&geo_no=$geo_no&CNPS_listed=$include_CNPS&weed=$include_weed&sugg_loc=$sugg_loc$q_coords&tns=$tns&lo_e=$lo_e&hi_e=$hi_e&YF=$YF&VTM=$include_vtm&baja=$include_baja&cultivated=$include_cult};
-->
			<tr>
				<td style="width: 95%;vertical-align: top;background-color:#FFFFFF;">
	</p>
	<p class="pageSubheading"><b>Geographic Locality</b><a href="/consortium/search_help.html#locality"><sup>&nbsp;?&nbsp;&nbsp;</sup></a>
	<br />
 	<input id="query_text" type="text" name = "loc" size = 40 MAXLENGTH = 50></input>
 	<br />
		<span class="bodySmallerText">e.g.:
		<a href="/consortium/list.php?loc=Round Meadow">Round Meadow</a><br />
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="/consortium/list.php?loc=Forester">Forester</a><br />
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="/consortium/list.php?loc=M% Dana">M+ Dana</a> 'Mount Dana' & 'Mt. Dana' mostly, using wildcards<br />
		</span>
	<!--</p>
	<p class="pageSubheading"><b>Phenology</b>
	<br />
 	<input id="query_text" type="text" name = "phen" size = 40 MAXLENGTH = 50></input>
 	<br />
		<span class="bodySmallerText">e.g.:
		<a href="/consortium/list.php?phen=FRUIT">Fruit</a>;
		</span>
	</p>
	-->
				</td>
			</tr>
		</table>

		<table style="width: 95%;vertical-align: top;background-color:#FFFFFF;">
		<tr>
			<td style="width: 45%;">
	<p><span class="pageSubheading"><font color="red">(NEW FEATURE)</font><br />
	<label for="nativity">Nativity <a href="/consortium/search_help.html#nativity"><sup>&nbsp;?&nbsp;&nbsp;</sup></a><br /></label></span>
	<select id="query_text" name="nativity" >
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch_eflora_nativity_options.php'); ?>
	</select>
	<br />
		<span class="bodySmallerText"><b>
		Returns only records with <br />
		accepted names or recognized synonyms <br />
		included in the Jepson eFlora<br />
		e.g.:<a href="/consortium/list.php?nativity=Waif&loc=Yosemite">Waifs in Yosemite</a>
		</span>
	</p>
			</td>

			<td style="width: 45%;padding-left: 10px;padding-right 10px;">
	<p><span class="pageSubheading"><font color="red">(NEW FEATURE)</font><br />
	<label for="life">Life Form <a href="/consortium/search_help.html#life"><sup>&nbsp;?&nbsp;&nbsp;</sup></a><br /></label></span>
	<select id="query_text" name="life">
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch_eflora_life_form_options.php'); ?>
	</select>
	<br />
		<span class="bodySmallerText"><b>
		Returns only records with <br />
		accepted names or recognized synonyms<br />
		included in the Jepson eFlora<br />
		<a href="/consortium/list.php?life=TREE&county=ALAMEDA">trees of Alameda County</a>
		</b></span>
	</p>
			</td>
		</tr>

		<tr>
			<td style="width: 45%;">
			
	<p><span class="pageSubheading"><label for="county">County<a href="/consortium/search_help.html#county"><sup>&nbsp;?&nbsp;&nbsp;</sup></a><br /></label></span>
	<select id="query_text" name="county" size=12>
	<!--<select id="query_text" name="county" size=12 multiple>-->
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch_county_options.php'); ?>
	</select>
	<br />
		<span class="bodySmallerText"><b>(default is all counties)</b><br />
		<font color="firebrick"><b>(selecting multiple values not re-activated)</b></font>
		</span>
	</p>


			</td>

			<td style="width: 45%;padding-left: 10px;padding-right 10px;">

		<p><span class="pageSubheading">
		<!-- County Mismatch checkbox-->
		<label for="mismatch">County Mismatch<a href="/consortium/search_help.html#mis"><sup>&nbsp;?&nbsp;&nbsp;</sup></a><br /><font color="red">(NEW FEATURE)</font><br /></label></span>
		<input type="checkbox" name="mismatch" value="1"><span class="bodySmallerText">
 		<b>Include specimens with the selected county listed on the label but for which georeferenced coordinates map outside the county.<br />
 		</b></span>
 		</p>
	<br />
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

	<p class="pageSubheading"><font color="red">(NEW FEATURE)</font><br />
	<input type ="checkbox" name="elevcheck" value="1">Select to display only specimens with an elevation
	<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OR<br />
	<b>Search Elevation</b> <a href="/consortium/search_help.html#elev"><sup>&nbsp;?&nbsp;&nbsp;</sup></a> <br />
        <input name = "minELEV" size = 6>&nbsp;&nbsp;&nbsp;TO&nbsp;&nbsp;&nbsp;<input name = "maxELEV" size = 6> (meters)
	</p>
	<br />
	

			</td>
		</tr>
		</table>

		<p>
		<table style="width: 95%;vertical-align: top;">
		<tr>
			<td class="tagList" style="padding: 5px; background-color:#9090AA;">
				<span class="pageSubheading">Refine or Expand Search</span>
				<br /><hr>
				<!-- YF checkbox-->
				<input type="checkbox" name="YF" value="1">
				Enable yellow flags <a href="/consortium/search_help.html#yf"><sup>&nbsp;?&nbsp;&nbsp;</sup></a><br />
				&nbsp;&nbsp;&nbsp;&nbsp;(displays possible range discrepancies with yellow icons)
				<br /><br />
				<!-- CNPS checkbox-->
				<input type ="checkbox" name="endem" value="1">
				Endemic <a href="/consortium/search_help.html#endemic"><sup>&nbsp;?&nbsp;&nbsp;</sup></a><font color="firebrick">(NEW FEATURE)</font><br />
				&nbsp;&nbsp;&nbsp;&nbsp;(return only accepted names or recognized synonyms for endemics found in the Jepson eFlora)
				<br /><br />
				<!-- CNPS checkbox-->
				<input type ="checkbox" name="CNPS" value="1">
				CNPS Inventory <a href="/consortium/search_help.html#cnps"><sup>&nbsp;?&nbsp;&nbsp;</sup></a><font color="firebrick">(not re-activated)</font><br />
				&nbsp;&nbsp;&nbsp;&nbsp;(return only names in the California Native Plant Society Inventory)
				<br /><br />
				<!-- CAL-IPC - CDFA checkbox-->
				<input type ="checkbox" name="IPC" value="1">  
				Weeds <a href="/consortium/search_help.html#weeds"><sup>&nbsp;?&nbsp;&nbsp;</sup></a><font color="firebrick">(not re-activated)</font><br />
				&nbsp;&nbsp;&nbsp;&nbsp;(return only records of CAL-IPC or CDFA listed weeds)
				<br /><br />
				<!-- CULT checkbox-->
				<input type ="checkbox" name="cult" value="1">
				Cultivated specimens <a href="/consortium/search_help.html#cult"><sup>&nbsp;?&nbsp;&nbsp;</sup></a><font color="firebrick">(NEW FEATURE)</font><br />
				&nbsp;&nbsp;&nbsp;&nbsp;(enable purple flags and include specimens labeled as cultivated)
				<br /><br />
				<!-- GEO checkbox-->
				<input type="checkbox" name="geo_only" value="1">
 				Limit to specimens with coordinates <a href="/consortium/search_help.html#geo"><sup>&nbsp;?&nbsp;&nbsp;</sup></a>
				<br /><br />
				<!-- NO GEO checkbox-->
				<input type="checkbox" name="geo_no" value="1">
 				Limit to specimens without coordinates<a href="/consortium/search_help.html#nogeo"><sup>&nbsp;?&nbsp;&nbsp;</sup></a>
 				<br ><br />
				<!-- TAX LIST checkbox-->
				<input type ="checkbox" name="LIST" value="1">
 				Name list <a href="/consortium/search_help.html#list"><sup>&nbsp;?&nbsp;&nbsp;</sup></a><font color="firebrick">(not re-activated)</font><br />
				&nbsp;&nbsp;&nbsp;&nbsp;(returns only one record for each name)
				<br /><br />
 				<!-- VTM checkbox-->
 				<input type="checkbox" name="VTM" value="1">
 				Vegetation Type Map specimens <a href="/consortium/search_help.html#vtm"><sup>&nbsp;?&nbsp;&nbsp;</sup></a><font color="firebrick">(not re-activated)</font>
				<br><br />
			</td>
		</tr>
		</table>
		
	</td>
	<!--END LEFT Side UPPER Content-->	


	<!--BEGIN RIGHT Side UPPER Content-->	
	<td style="padding-left: 10px;padding-right: 10px;width: 40%;vertical-align: top;background-color:#FFFFFF;">
	
	<p class="pageSubheading"><b>Source</b> <a href="/consortium/search_help.html#source"><sup>&nbsp;?&nbsp;&nbsp;</sup></a>
	<br />
	<select name="source" size=20>
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch_participants_options_CCH2.php'); ?>
	</select>
	<br />
		<span class="bodySmallerText">(default is all sources)<br />
		<b><font color="firebrick">(selecting multiple values not re-activated)</font></b></span>
	</p>
	<br />
	

	<p class="pageSubheading"><b>Collector</b> <a href="/consortium/search_help.html#coll"><sup>&nbsp;?&nbsp;&nbsp;</sup></a><br />
        <input name = "coll" size = 50 MAXLENGTH = 100><br />
    	<span class="bodySmallerText">(last name only; e.g.:
			<a href="/consortium/list.php?coll=Muir">Muir</a>;
  			<a href="/consortium/list.php?coll=Moref">Moref</a>)
		</span>
	</p>

	<p class="pageSubheading"><b>Collector Number</b> <a href="/consortium/search_help.html#collnum"><sup>&nbsp;?&nbsp;&nbsp;</sup></a>
        <input name = "collnum" size = 50 MAXLENGTH = 50><br />
    	<span class="bodySmallerText">(any type, including strictly numerical or alpha-numeric <br />e.g.:
			<a href="/consortium/list.php?collnum=2334">2334</a>)
		</span>
	</p>
	<br /><br />
	<p class="pageSubheading"><input type ="checkbox" name="typecheck" value="1">Select to display only specimens with a type status
	<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OR<br />
	<b>Search Type Status</b> <a href="/consortium/search_help.html#type"><sup>&nbsp;?&nbsp;&nbsp;</sup></a><font color="red">(NEW FEATURE)</font>
        <input name = "type" size = 50 MAXLENGTH = 100><br />
    	<span class="bodySmallerText">(search for a specific or more general type phrase <br />e.g.:
			<a href="/consortium/list.php?type=holotype">holotype</a>;
  			<a href="/consortium/list.php??type=type">type</a>)
		</span>
	</p>
	</td>
	<!--END RIGHT Side UPPER Content-->	
	</tr>

	<tr>
<!--BEGIN LEFT Side LOWER Content A-->	
<!-- BEGIN ACCESSION NUMBER SEARCH-->
		<td style="height: 40px;padding: 10px;vertical-align: top;background-color:#FFFFFF;">
<hr>
			<p class="pageSubheading"><a href="/consortium/search_help.html">Search here using a specimen number<sup>&nbsp;?&nbsp;&nbsp;</sup></a>
			<input name = "accnum" size = 20 MAXLENGTH = "25" value="" >
			</p>
		</td>

<!--END LEFT Side LOWER Content A-->

	
<!--BEGIN RIGHT Side LOWER Content A-->	
<!-- EMPTY SPACE FOR NOW-->
		<td style="height: 40px;padding: 10px;vertical-align: top;background-color:#FFFFFF;">
<hr>
			<p class="pageSubheading"><!-- FILL-->
			</p>
		</td>
	</tr>



<!--END RIGHT Side LOWER Content A-->


<!--BEGIN LEFT Side LOWER Content B-->			
	<tr>
<!-- BEGIN USE TERMS LEFT-->
		<td style="height: 40px;padding: 10px;vertical-align: top;background-color:#FFFFFF;">
<hr>
			<p><input TYPE="submit" VALUE="Accept data-use terms, submit search" >&nbsp;&nbsp;&nbsp;&nbsp;</p>			
			<p><span class="pageSubheading"><b><a href="/consortium/data_use_terms.html">Read&nbsp;use&nbsp;terms</a></b></span>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<input TYPE="reset" VALUE="Reset Form"></p>
		</td>
<!-- END USE TERMS LEFT-->
<!--END LEFT Side LOWER Content B-->	
			
<!--BEGIN RIGHT Side LOWER Content B-->			

<!-- BEGIN USE TERMS RIGHT-->		
		<td style="padding: 10px;vertical-align: top;background-color:#FFFFFF;">
<hr>
			<span class="pageSubheading"><b>5000 records is the default maximum for all downloads. For custom data requests contact</b>
				<a href="mailto:jason_alexander@berkeley.edu">Jason Alexander (jason_alexander@berkeley.edu)</a>
			</span>
		</td>
	</tr>
<!-- END USE TERMS RIGHT-->
<!--END RIGHT Side LOWER Content B-->	



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