<?php

date_default_timezone_set('America/Los_Angeles');

//georef not in databade yet, comment out for now
//$TaxonID = htmlspecialchars($_GET["tid"]);

//require 'config/config.php';
//$db = new SQLite3($database_location);


//$results = $db->query('SELECT ID, ScientificName, TaxonAuthor, FormattedDisplayName, CommonName, NativeStatus, TJM2Author, ScientificEditor, Habit, PlantBody, Stem, SterileStem, FertileStem, Leaf, Spines, Inflorescence, StaminateHead, RayOrPistillateFlower, PistillateHead, StaminateInflorescence, PistillateOrBisexualInflorescence, PistillateInflorescence, Spikelet, FertileSpikelet, SterileSpikelet, DistalSpikelet, CentralSpikelet, LateralSpikelet, StaminateSpikelet, PistillateSpikelet, Flower, StaminateFlower, PistillateFlower, RayFlower, DiskFlower, Cone, PollenCone, SeedCone, BisexualFlower, Fruit, Seed, Sporangia, SporangiumCase, MaleSporangiumCase, FemaleSporangiumCase, Spores, Chromosomes, Ecology, RarityStatus, Elevation, BioregionalDistribution, OutsideCA, SpeciesInGenus, GeneraInFamily, Etymology, Toxicity, Synonyms, UnabridgedSynonyms, Reference, UnabridgedReference, Note, UnabridgedNote, FLFRTimeCode, FloweringTime, FruitingTime, SporConeTime, Weediness, IsTerminalTaxon, HasKey, RevisionNumber, RevisionDate, DistCode 
//						FROM eflora_taxa
//						WHERE TaxonID='.$TaxonID.''); //16711 is the TaxonID for Calochortus amabilis, for example

//while ($row = $results->fetchArray()) {

//add database schema and search code here


//change this to a CCH relevant version below, this is from eflora_display.php
//Before doing anything, if the TID isn't recognized, give a plain error screen
//if (!$ID){ //if TaxonID (pulled from URL) did not match a line in the database...
//  echo "Taxon not recognized TID=".$TaxonID;


//header("Location: /cgi-bin/get_cpn.pl?".$TaxonID, true, 301);
//exit();

//}
?>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<?php 
//add note or other code here for variables
?>

<head>
<title>CCH1: Coordinate Search Tool</title> 
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

<!-- jquery functions -->

</head>
<body>

<table id="normaltable" style="vertical-align: top;">
  <tr>
   <td><img src="/common/images/common_spacer.gif" alt="" style="height:1px;width:25px;"></td>
	<td>
	 <table id="cchpageback">
	  <tr>
	   <td>
 <div class="cch-top-image-xy002crop">
<!-- COMMON HEADER -->
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch1v2img_header.php'); ?>
<!-- COMMON HEADER ENDS -->
</div>

<div>
<table id = "sideTable">
	<tr>
	<td style="vertical-align: top;width: 175px;">
		<table id = "sideLinks">
		<tr>
			<td style="background-color: #9090AA;width: 175px;"> <!--background test -->
<!-- Start of sidebar menu-->
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/localnav_cch_home.php'); ?>
<!-- End of sidebar --> 
			</td>
		</tr>
		</table>
	</td>
	<td><img src="/common/images/common_spacer.gif" alt="" style="height:1px;width:25px;"></td>
	<td style="vertical-align: top;">
	
<p><span class="pageNameB">&nbsp;CCH1 Coordinate Search Tool</span></p>


<div >
 <ol id = "menu" type="A">
  <li> <a name="coords"></a><span class="generalText"><b> Search georeferenced specimens based on a free-hand polygon in Berkeley Mapper</b></span><br />
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
   <td style="width: 50px;">
   </td>
    <td class="bodyFull">
	 <div class="shadow-color">
	  <span class="generalText">
	   <div class="color-box" style="background-color: #eeeeee;">
		<ol>
		<li>&nbsp;&nbsp;&nbsp;The default is to not show any specimens on map.</li>
		<li>&nbsp;&nbsp;&nbsp;The specimens inside the polygon will show at the bottom of the window.</li>
		<li>&nbsp;&nbsp;&nbsp;The results can be downloaded using the links on the left.</li>
		<li>&nbsp;&nbsp;&nbsp;The downloads are a limited subset fields in CCH1.</li>
		<li>&nbsp;&nbsp;&nbsp;Full datasets are a custom request.  Please submit your results file by email to Jason Alexander:
		<a href="mailto:jason_alexander@berkeley.edu">jason_alexander@berkeley.edu</a></li>
		</ol>

			<p><b>&nbsp;&nbsp;&nbsp;&nbsp;To begin, search CCH1 by using polygon tool on the map in <b />
			<a href="http://berkeleymapper.berkeley.edu/index.html?ViewResults=tab&tabfile=https://ucjeps.berkeley.edu/consortium/CCH_all.txt&configfile=https%3A%2F%2Fucjeps.berkeley.edu%2Fucjeps_GR_new.xml&sourcename=Consortium+of+California+Herbaria+result+set&&maptype=Terrain&pointDisplay=none">BerkeleyMapper (without showing point locations to load faster)</a> 
			</b></p>
 <p>&nbsp;&nbsp;&nbsp;&nbsp;
 Warning: Use only with the default None or MarkerCluster Display. Activating the display of individual 
 specimens may cause lag, since over 2.5 million icons will need to loaded.
 </p>
	   </div>
	  </span>
	 </div>
   </td>
  </tr>
 </table>

<br />
<br />
  </li>
  
  
  <li> <a name="coords"></a><span class="generalText"><b> Search by rectangular polygons on the CCH1 georeference map</b></span><br />
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
   <td style="width: 50px;">
   </td>
    <td class="bodyFull">
	 <div class="shadow-color">
	  <span class="generalText">
	   <div class="color-box" style="background-color: #eeeeee;">
		<ol>
		<li>&nbsp;&nbsp;&nbsp;This is a simplified map of all of the georeferences specimens in CCH1.</li>
		<li>&nbsp;&nbsp;&nbsp;The dots show the density of collections within that area.</li>
		<li>&nbsp;&nbsp;&nbsp;Clicking on the rectangle will query CCH1 and bring up all specimens within that area.</li>
		</ol>
			<p><b>&nbsp;&nbsp;&nbsp;&nbsp;To begin, search CCH1 by selecting a rectangle on the map displayed on this page: <b />
			<a href="/consortium/load_hartman.html">https://ucjeps.berkeley.edu/consortium/load_hartman.html</a>.
			</b></p>
	   </div>
	  </span>
	 </div>
   </td>
  </tr>
 </table>

<br />
<br />
  </li>  
  
  
  <li id = "menu"><span class="generalText"><b>Search CCH1 by user-provided coordinates for the centroid of a circle and a radius</b>
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
   <td style="width: 50px;">
   </td>
    <td class="bodyFull">
	<div class="shadow-color">
	  <span class="generalText">
	   <div class="color-box" style="background-color: #eeeeee;">
		<p>
	<form method = "POST" action="/cgi-bin/get_consort.pl">
		<ol>
		<li>&nbsp;&nbsp;&nbsp;Paste the coordinates and error radius using the circle-drawing tool at the top of the Berkeley </b>
			<a href="http://berkeleymapper.berkeley.edu/index.html?ViewResults=tab&tabfile=https://ucjeps.berkeley.edu/consortium/basemap.txt&configfile=https%3A%2F%2Fucjeps.berkeley.edu%2Fucjeps_GR.xml&sourcename=Consortium+of+California+Herbaria+result+set&">
			<b>BerkeleyMapper</b> (click to get map).</a>
		</li>
		<p>&nbsp;OR</p>
		<li>&nbsp;&nbsp;&nbsp;Paste user-defined point coordinate and radius information into the box below<br />
			<b>&nbsp;&nbsp;&nbsp;Example of information to be copied from tool and pasted into form:</b>
		</li>
		<p>&nbsp;&nbsp;&nbsp;<b>Coordinate: 37.87654 / -121.93076 (3077 meters radius)</b></p>
	<div style = "align: left;"><textarea name="sugg_loc" cols="50" rows="6"></textarea>
				<br /></div>
		</p>
	<p>&nbsp;&nbsp;&nbsp;If you only want a list of names, not all the records:<br />
	&nbsp;&nbsp;&nbsp;<input type ="checkbox" name="make_tax_list" value=1 ><b class="pageSubheading">Taxon List</b>
		</p>

		<p>&nbsp;&nbsp;&nbsp;
		<b>Submit Search Button</b> <br />&nbsp;&nbsp;&nbsp;<input TYPE="submit" VALUE="Submit coordinates, return records, and generate map">
		</p>
	</form>
	   </div>
	  </span>
	 </div>
   </td>
  </tr>
 </table>
<br />
<br />
  </li>
  <li><span class="generalText"><b>Map records of all specimens with coordinate data for a county. Select source and county</b>
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
   <td style="width: 50px;">
   </td>
    <td class="bodyFull">
	<div class="shadow-color">
	  <span class="generalText">
	   <div class="color-box" style="background-color: #eeeeee;">
		<p>
	<form method = "POST" action="/cgi-bin/map_county_stripped.pl">
			<span class="pageSubheading2"><b>Source</b> </span><span class="bodySmallerText">(1 or more; default is all sources)</span>
			<br />
			<select NAME="source" size=27 multiple>
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch_participants_options.php'); ?>
			</select>	
			</p>	
			<p>
			<span class="pageSubheading">County </span><br />
			<select name="county" size = 12 multiple>
<?php include($_SERVER['DOCUMENT_ROOT'].'/common/php/cch_county_options.php'); ?>
			</select>
			<br />
			(1 or more; default is all counties)&nbsp;
			</p>
			<p>	<span class="pageSubheading2">Note: Not all counties have been uniformly georeferenced!</span><br />
			</p>

			<p class="bodysmallerText">
				<b class="pageSubheading">
					If you want only the yellow-flagged records ...
				</b>
				<input type ="checkbox" name="marginal" value=1 >
				<br />
			</p>
			<p>
				<input TYPE="submit" VALUE="Submit Query">
				<br />
				<input TYPE="reset" VALUE="Reset Form">
			</p>
	</form>
	   </div>
	  </span>
	 </div>
   </td>
  </tr>
 </table>
<br />
<br />
  </li>
</ol>
   <h3>Links</h3>
	<ul>
		<li><a href="http://publications.newberry.org/ahcbp/map/map.html#CA">Historical boundaries of California counties</a></LI>
		<li><a href="https://getlatlong.net/">Get coordinates if you have an address using getLatLong.net on iTouchmap.com</a></LI>
		<li><a href="https://california.hometownlocator.com/"> California Home Town Locator</a></LI>
	</ul>

</div>

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


