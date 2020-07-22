<!-- hide script from old browsers

var $dvr='multi';
var oldReturned;
var element;

window.onload = function ()	{
var $returned = rownum();
var Row =('ROW ' + $returned);
matrixUpdate(Row); 
rowChanger($returned);
listeners();
}

function matrixButton ()	{
var $returned = rownum();
var Row =('ROW ' + $returned);
matrixUpdate(Row); 
rowChanger($returned);
}

function listeners()	{
var targets = ['row_sel', '#Matrix.tr.selected']; 
for (var index = 0; index < targets.length; index++)	{
	var trs = document.querySelectorAll(targets[index]);
		for(var i = 0; i < trs.length; i++){
    		trs[i].addEventListener("click", function(){this.className += " selected";});
			}	
		}
}

function rownum()	{
					var oRequest = new XMLHttpRequest();
						oRequest.open("GET","resources/currentRow.txt", false);
						oRequest.setRequestHeader("User-Agent",navigator.userAgent);
						oRequest.send(null);
					$returned = (oRequest.responseText);
					return ($returned);
}

setInterval(function()	{perlWebDo("cgi-bin/Scripts/infoCaller.pl?call=chChange", "ch_change_status", true, "GET")},3000);
setInterval(function()	{perlWebDo("cgi-bin/Scripts/infoCaller.pl?call=autoStat", "automation_status", true, "GET")},4000);
setInterval(function() {perlWebDo("cgi-bin/Scripts/infoCaller.pl?call=scrollBox", "scroller", true, "GET")},5000);
setInterval(function() {perlWebDo("cgi-bin/Scripts/infoCaller.pl?call=sheduled", "scheduled_events", true, "GET")},6000);

function perlWebDo(script, element, async, chooseMethod, option)		{    //// Generic XMLHttpRequest
	var xmlhttp;
if (window.XMLHttpRequest)
  {
  xmlhttp=new XMLHttpRequest();
  }
else
  {
  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp.onreadystatechange=function()
  {
  if (xmlhttp.readyState==4 && xmlhttp.status==200)
    {
    document.getElementById(element).innerHTML=xmlhttp.responseText;
    }
}
xmlhttp.open(chooseMethod,script,async);
xmlhttp.send();
}

function adminpage()
{
	var xmlhttp;
if (window.XMLHttpRequest)
  {
  xmlhttp=new XMLHttpRequest();
  }
else
  {
  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp.onreadystatechange=function()
  {
  if (xmlhttp.readyState==4)   // Doesnt check return code ? seperate version
    {
    document.getElementById("content").innerHTML=xmlhttp.responseText;
    }
}
xmlhttp.open("GET","admin.html");
xmlhttp.send();
}

//function adminpage()
//{
//	perlWedDo ("admin.html", "content", true, "GET");
//}

function sdVid()
{
	var xmlhttp;
if (window.XMLHttpRequest)
  {
  xmlhttp=new XMLHttpRequest();
  }
else
  {
  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp.onreadystatechange=function()
  {
  if (xmlhttp.readyState==4)
    {
    document.getElementById("myDiv").innerHTML=xmlhttp.responseText;  // Same as admin page
    }
}
xmlhttp.open("GET","cgi-bin/Scripts/E2E_Cycle_SD_Video.pl",true);
xmlhttp.send();
}

//function sdVid()				{
//	perlWebDo ("cgi-bin/Scripts/E2E_Cycle_SD_Video.pl", "myDiv", true, "GET");
//}

function matrixUpdate($matrix)	{
	perlWebDo ("cgi-bin/Scripts/E2E_Master.pl?matrix=" + $matrix, "content", false, "GET");
}

function channelChange()
 {
	perlWebDo ("cgi-bin/Scripts/E2E_Channel_Change.pl", "myDiv", true, "GET");
}
 
function perlCall (script, $param, $value)	{
	var myScript = ("cgi-bin/Scripts/" + script + "?" + $param + "=" + $value);
 	perlWebDo(myScript, "MyDiv", true, "GET");
}
 
function perlXML($action, $command)
{
	var xmlhttp;
if (window.XMLHttpRequest)
 {// code for IE7+, Firefox, Chrome, Opera, Safari
  xmlhttp=new XMLHttpRequest();
  }
else
 {// code for IE6, IE5
 xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp.onreadystatechange=function()
  {
  if (xmlhttp.readyState==4 && xmlhttp.status==200)
   {
  document.getElementById("myDiv").innerHTML=xmlhttp.responseText;
   }
}
xmlhttp.open("GET","cgi-bin/Scripts/E2E_Master.pl?action="+ $action + "&command=" + $command + "&info=REAL TIME",true);
xmlhttp.send();
}
  
 
//function perlXML($action, $command)	{
	//var script =("cgi-bin/Scripts/E2E_Controller_Main.pl?action="+ $action + "&command=" + $command + "&info=REAL TIME", true);
	//perlWebDo(script, "myDiv", true, "GET");
//}

function perlDeepSleep($action, $command)	{
var script = ("GET","cgi-bin/Scripts/E2E_Master.pl?action="+ $action + "&command=" + $command + "&info=REAL TIME");
	var r=confirm("Deep sleep event will be logged, continue?");
			if (r==true)	{		
				alert("Deep sleep event logged!");
				perlWebDo(script, "myDiv", true, "GET");
				}  		else		{
				alert("Cancelled...");
		}
}

function haltauto()		{
	var r=confirm("All automation will be halted, continue?");
			if (r==true)	{
				alert("Halting automation...");
				perlCall('E2E_Master.pl', 'action', 'killall');
				}	  	else		{
				alert("Cancelled...");
		}
}
 	
function pauseauto()	{
	var r=confirm("Automated events will be paused, continue?");
			if (r==true)	{
				alert("Pausing automation...");
				perlCall('E2E_Master.pl', 'action', 'pauseall');
				}		else		{
			alert("Cancelled...");
		}
}
 
function resumeauto()		{
alert("Resuming automation!");
perlCall('E2E_Master.pl', 'action', 'resumeall');
}
 
function masterautoenable()		{
alert("Master Automation Enable");
perlCall('E2E_Master.pl', 'action', 'enable');
xmlhttp.send();
}
 
function masterautodisable()	{
alert("Master Automation Disable");
perlCall('E2E_Master.pl', 'action', 'disable');
xmlhttp.send();
}
 

function arrowDir($direction)	{									
rownum();
if ($returned!=null)	{
if ($direction=='INC')	{
		if ($returned==36)	{
								$returned=1;
								rowChanger($returned);
			}	else	{
								$returned++;
								rowChanger($returned);
	}
}

if ($direction=='DEC')	{
		if ($returned==1)	{
								$returned=36;
								rowChanger($returned);
			}	else	{
$returned--;
rowChanger($returned);
			}
		}
	}
}

function rowChanger($returned)	{		oldReturned=$returned;	
										var Row = "ROW " + $returned;
										matrixUpdate(Row);
										perlCall('E2E_Master.pl','stbs',Row);
}
 // end hiding script from old browsers  -->
