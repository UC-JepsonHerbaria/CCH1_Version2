<?php

date_default_timezone_set('America/Los_Angeles');

#Output file to store data for Berkeley Mapper
$timestamp = time();
$tab_file_name="CHC_".$timestamp."_CCH1_GEOREF";
$map_file_path="/BerkeleyMapper/";
$map_file_out= $map_file_path.$tab_file_name;
$map_file_URL="https://ucjeps.berkeley.edu".$map_file_out.".txt";

?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<title>CCH1: Coordinate Search Tool</title> 
<meta charset="UTF-8">
<meta name="description" content="The Consortium of California Herbaria is the organization that supports all herbaria in California.">
  <meta name="keywords" content="Consortium of California Herbaria, CCH1, georeferencing, coordinates, biogeography, California Flora, Flora of California, Vascular Plants of California, Jepson Flora Project, Jepson eFlora">
  <meta name="viewport" content="width=device-width, initial-scale=1">
<link href="/common/css/style_consortium.css" rel="stylesheet" type="text/css">
	<link rel="shortcut icon" href="/common/images/cch/CCH_logo_02_80.png" type="image/x-icon" />


<!-- Global site tag (gtag.js) - Google Universal Analytics (OLD FORMAT, GOOGLE retires in July 2023)-->
<!--<script async src="https://www.googletagmanager.com/gtag/js?id=UA-43909100-3"></script>-->
<!--<script>-->
<!--  window.dataLayer = window.dataLayer || [];-->
<!--  function gtag(){dataLayer.push(arguments);}-->
<!--  gtag('js', new Date());-->
<!--  gtag('config', 'UA-43909100-3');-->
<!--</script>-->


<!-- Google G4 Global site tag (gtag.js) - Google Analytics, replaces old UA tag-->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-HWJ1N1S6S4"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'G-HWJ1N1S6S4');
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
<div>

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
	
<p><span class="pageNameB">&nbsp;CCH1 Coordinate Search Tool</span></p>


<div >
 <ul id = "menu">
  <li> <a name="coords"></a><span class="generalText"><b> Search georeferenced specimens based on a free-hand polygon in Berkeley Mapper</b></span><br />
 <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td class="bodyFull" style="vertical-align: top;background-color:#FFFFFF;">
	 <div class="shadow-color">
	  <span class="generalText">
	   <div class="color-box" style="background-color: #eeeeee;">
		<ol>
		<li>&nbsp;&nbsp;&nbsp;This will load all georeferenced CCH1 data with marker cluster Display or invisible point markers.</li>
		<li>&nbsp;&nbsp;&nbsp;After zooming in, the BerkeleyMapper custom shape tool (top-center control, right-most button) can be used to filter the database.</li>
		<li>&nbsp;&nbsp;&nbsp;The specimens inside the polygon will show at the bottom of the window.</li>
		<li>&nbsp;&nbsp;&nbsp;The results can be downloaded using the links on the left.</li>
		<li>&nbsp;&nbsp;&nbsp;The downloads are a limited subset fields in CCH1.</li>
		<li>&nbsp;&nbsp;&nbsp;Full datasets are a custom request.  Please submit your results file by email to Jason Alexander:
		<a href="mailto:jason_alexander@berkeley.edu">jason_alexander@berkeley.edu</a></li>
		</ol>

			<p><b>&nbsp;&nbsp;&nbsp;&nbsp;Search CCH1 by polygon with <a href="http://berkeleymapper.berkeley.edu/index.html?ViewResults=tab&tabfile=https://ucjeps.berkeley.edu/consortium/logs/CCH_GEOREF.txt&configfile=https%3A%2F%2Fucjeps.berkeley.edu%2Fucjeps_geo_search.xml&sourcename=Consortium+of+California+Herbaria+result+set&pointDisplay=markerclusteron">marker cluster enabled</a>.<b />
		
			</p>
			<p><b>&nbsp;&nbsp;&nbsp;&nbsp;Search CCH1 by polygon with <a href="http://berkeleymapper.berkeley.edu/index.html?ViewResults=tab&tabfile=https://ucjeps.berkeley.edu/consortium/logs/CCH_GEOREF.txt&configfile=https%3A%2F%2Fucjeps.berkeley.edu%2Fucjeps_geo_search.xml&sourcename=Consortium+of+California+Herbaria+result+set&pointDisplay=none">invisible point markers.</a><b />
			
			</p>
 <p>&nbsp;&nbsp;&nbsp;&nbsp;
 Warning: When viewing the entire state of California, do not select individual marker colors. Activating the display of individual 
 point locations will cause lag and may crash your browser.  Loading over 1.8 million icons takes a very long time.
 </p>


<!--
 <p>&nbsp;&nbsp;&nbsp;&nbsp;Create a new CCH1 georef file for Berkeley Mapper
 
 		<ol>
		<li>&nbsp;&nbsp;&nbsp;Uncomment the button below.</li>
		<li>&nbsp;&nbsp;&nbsp;Click the button to start the query.</li>
		<li>&nbsp;&nbsp;&nbsp;Look at results to see if the expected number of georeferene records were obtained</li>
		<li>&nbsp;&nbsp;&nbsp;Find the file from the tmp Berkeley Mapper directory.</li>
		<li>&nbsp;&nbsp;&nbsp;Copy it to the logs directory.</li>
		<li>&nbsp;&nbsp;&nbsp;Rename it CCH1_GEOREF.txt</li>
		</ol>
</p>
<form method="GET" action="/consortium/georef_create.php">
			<input type="hidden" name="geo_only" value="1">
			<p><input TYPE="submit" VALUE="Create CCH1_GEOREF" >&nbsp;&nbsp;&nbsp;&nbsp;</p>			

</form>
 
-->

	   </div>
	  </span>
	 </div>
   </td>
  </tr>
 </table>

<br />
<br />
  </li>
  

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


