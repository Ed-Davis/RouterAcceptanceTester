#!/usr/bin/perl -w -I /RAT/Tools/

BEGIN {
use lib "/RAT/Tools";
use lib "/RAT";
}

use strict;
use 5.10.0;
use Net::Ping;
use Time::HiRes qw(usleep);
use WWW::Mechanize;
use WWW::Mechanize::FormFiller;
use URI::URL;
use Net::FTP;
use Tools::RatLed; 
use Time::Out qw(timeout);
require LWP::UserAgent;

INITIALIZE:
my $test_device="RAT 1";
my $router='192.168.0.1'; 
my $bbc='212.58.241.131'; 
my $cnt='0';
my $var_sky_ssid = ('var sky_ssid = ');
my $varwpaPskKey = ('var wpaPskKey = ');
my $model=("_");  
my $pass_or_fail=('pass');
my $router_gui=("not done");
my $wantest=("not done");
my $dnstest=("DNS Proxy Test: Skipped");
my $wifitest=("WiFi Test: Not done");
my $ssid=("_");
my ($user,$password)=('admin','sky');
my $tablestart=('<td>');
my $tableend=('</td>');
my $manstart=('>Manufacturer<');
my $marker=(0);
my $identifier='5 GHz';
my ($uptime, $pid, $lastpid, $passkey, $rspage, $response, $nextstuff, $ftp,
	$manufacturer, $router_fw, $adsl_fw, $mac_lan, $key, $filename, $eth0state, $device_status, $landing_page, $doc_w,
	@wifikeyinfo, $dbCredentials2g, $dbCredentials5g, $scan_freq, $wlan0state, $heading, $timeout, @pids, @content,
	$fwstart, $modstart, $rfw, $lanport, $macstart, @lines, $line, $file, @files, $p, $host) = ();
	
my $return_state=(0);
my $agent = WWW::Mechanize->new( autocheck => 1 );
my $formfiller = WWW::Mechanize::FormFiller->new();
my $wifiinprog=(0);

$p = Net::Ping->new();
$ftp = Net::FTP->new('cheesywotsit.dyndns.org:41102', Passive => 1);
my $twogig='scan_freq=2412 2417 2422 2427 2432 2437 2442 2447 2452 2457 2462 2467 2472';
my $fivegig='scan_freq=5825 5805 5785 5765 5745 5700 5680 5660 5640 5620 5600 5580 5560 5540 5520 5500 5320 5300 5280 5260 5240 5220 5200 5180';

my %wifi_band = 	(	'2.4 GHz' 	=> 	$twogig,
						'5 GHz'		=>	$fivegig,
					);
my %wifi_pages = 	(	'2.4 GHz' 	=> 	'http://192.168.0.1/sky_wireless_band.cgi?band=2.4GHz',
						'5 GHz'		=>	'http://192.168.0.1/sky_wireless_band.cgi?band=5GHz',
					);

my $supplicant_file; 
my @wifiresults;
my $routername;

killer();
$pid=RatLed->Breathe();
push(@pids, "$pid ");
first_test();
sub first_test	{
$pass_or_fail = ('pass');
$return_state = waitforrouter();

if ($return_state == 1)	{
			$return_state=(0);
			second_test();
			}	else	{
sleep(2);
	first_test();
	}
}

sub second_test	{
timeout 40 => sub {
$return_state =	wancheck();
};
if ($@)	{
	first_test();
}
if ($return_state == 1) {
			$return_state=(0);
		timeout 5 => sub	{	
			checkdns();	
		};
		if ($@)	{
		first_test();
		}
			third_test();
			}	else	{
if ($return_state == 0)	{
			first_test();
		}
	}
}

sub third_test	{
timeout 40 => sub {
$return_state = checkrouter();
};
if ($@)	{
	first_test();
}

if ($return_state == 1)	{ 
			$return_state=(0);
			fourth_test();
} 

if ($return_state == 0)	{
			goto INITIALIZE;
		}
}

sub fourth_test	{
$wifiinprog=(1);

timeout 90 => sub	{
system ("netctl stop netctl-static");
$return_state = wireless_admin();
};
if ($@)	{
$return_state = (0);
$wifiinprog=(0);
$pass_or_fail=('fail');
system ("netctl stop netctl-wireless-auto");
system ("netctl start netctl-static");
fifth_test();
}

if ($return_state == 1)	{
			$return_state=(0);
			$pass_or_fail = ('pass');
			$wifiinprog=(0);
			fifth_test();
}	

if ($return_state == 0)	{
			$pass_or_fail = ('fail');
			$wifiinprog=(0);
			fifth_test();
		}
fifth_test();
}

sub fifth_test	{
system ("netctl start netctl-static");
timeout 30 => sub	{
report ();
};
if ($@)	{
$pass_or_fail=('fail');
complete();
}
timeout 30 =>	sub {
FTP_Results();
};
if ($@)	{
complete();
}
complete();
}


sub complete	{
		if ($pass_or_fail =~m/pass/gi)	{
		$pass_or_fail = 'Pass';
		Pass();
		} 
		if	($pass_or_fail =~m/fail/gi)	{
		$pass_or_fail = 'Fail';
		Fail();
		}
Fail();
}


sub waitforrouter	{ 
$pass_or_fail=('pass');
			if ($marker == 0)	{
			killer();
			$marker++;	
			}
			
			
	if ($p->ping($router))  {   
			$p->close();
			$marker=("0");
			killer();
			$pid=(RatLed->RouterDetected());
			push(@pids, "$pid ");	 
			$return_state=(1);
			return ($return_state);
			
  		}		else		{
    	
    		$p->close();
			first_test();
			$return_state=(1);
			return ($return_state);
		}
}

sub wancheck { 
$marker=(0);
			killer();
			$pid=(RatLed->TestInProg());
			push (@pids, "$pid ");
			$pid=(RatLed->LocalPass());
			push (@pids, "$pid ");
				
    if ($p->ping($bbc, 3))  { 
    $p->close(); 
    $wantest=("WAN: Connected");
	killer();		
	$pid=(RatLed->RemotePass());		
	push (@pids, "$pid ");
	$pid=(RatLed->TestInProg());
	push (@pids, "$pid ");
	system('ntpd -s');
			$return_state=(1);
			return $return_state;
			}	else	{    
    	$p->close();
		$marker=(0);
			$return_state=(0);
			return ($return_state);
	}
}

sub checkrouter	{	
			$agent->env_proxy();	
			$agent->credentials($user, $password);
			$agent->get('http://192.168.0.1/sky_index.html');
			$landing_page=$agent->content;
			if ($landing_page=~m/$identifier/i)	{
				$device_status=('Dual');
						}	else	{
				$device_status=('Single');
}	
			$agent->form_number(1) if $agent->forms and scalar @{$agent->forms};
			$agent->get('http://192.168.0.1/sky_router_status.html');
			$agent->form_number(1) if $agent->forms and scalar @{$agent->forms};
			$rspage=($agent->content);
			@content=($rspage);
			$router_gui=("Router GUI: Responding and credentials correct");		
 
			if ($rspage=~(m/$manstart\s{0,}/g))	{
					 $nextstuff=$';
			if ($nextstuff=~m/([A-Z]{1,5})\s+/i) {
					($manufacturer)=$1;
		}
}
			$modstart=('Model'); 
			if ($rspage=~(m/$modstart\s{0,}/g))	{
					$nextstuff=$';		
			if ($nextstuff=~m/([A-Z]{1,3}[0-9]{3})/i) {
					($model)=$1;
		}
}
			$rfw='Firmware Version'; 
			if ($rspage=~(m/$rfw<\/\w{1,}>\s{0,}<\w{1,}>/))	{
					$nextstuff=$';
			if ($nextstuff=~m/^\s{0,}(.{1,})\s|\n$/g) {	
				($router_fw)=$1;
				$router_fw=~(s/<\/td>//sg);
		}
}
				$fwstart='DSL Firmware Version'; 
				if ($rspage=~(m/([A]{0,1}$fwstart)/))	{
					$nextstuff=$';
				if ($nextstuff=~m/\(\'(.)\'\)/g) {
					($adsl_fw)=$1;
		}
}

				$lanport=('LAN Port');
				$macstart=('MAC Address');
				$doc_w=('document.write');
				if ($rspage=~(m/($lanport[.]{1,}$macstart)[.]{1,}$doc_w[.]{1,}/sg))	{
						$nextstuff=$';
					if ($nextstuff=~m/(\S{2}:\S{2}:\S{2}:\S{2}:\S{2}:\S{2})/si) {
						($mac_lan)=$1;
		}
}

if ($device_status eq 'Single')		{				
				$agent->get('http://192.168.0.1/sky_wireless_settings.html');
				$agent->form_number(1) if $agent->forms and scalar @{$agent->forms};	
				@lines=($agent->content);
					foreach $line(@lines)	{
					if ($line=~(/$var_sky_ssid['](\S{1,})[']/))  {
								($ssid)=$1;
								$routername=($ssid);
			}
					if ($line=~(/$varwpaPskKey['](\S{1,})[']/))  {
								($passkey)=$1;
		}
	}
}
if	($device_status eq 'Dual')	{
	
for my $band(keys %wifi_pages)	{		
				$agent->get($wifi_pages{$band});
				$agent->form_number(1) if $agent->forms and scalar @{$agent->forms};	
				my @lines=($agent->content);
					foreach $line(@lines)	{
					if ($line=~(/$var_sky_ssid['](\S{1,})[']/))  {
								($ssid)=$1;
				}
					if ($line=~(/$varwpaPskKey['](\S{1,})[']/))  {
								($passkey)=$1;
				}
				if ($band eq '2.4 GHz')	{
				$routername=($ssid);
				$dbCredentials2g=("$ssid,$passkey");
				}		elsif	($band eq '5 GHz')	{
				$dbCredentials5g=("$ssid,$passkey");
				}
			}
		}
	}
$return_state=1;
return $return_state;
}

sub wireless_admin		{
			
			killer();	
			$pid=(RatLed->WirelessTestInProg());
			push(@pids, "$pid ");
			$pid=(RatLed->RemotePass());		
			push (@pids, "$pid ");
			
if ($device_status eq 'Dual')		{

for my $key(keys %wifi_band)	{

if ($key eq '2.4 GHz')	{

@wifikeyinfo=split(',',$dbCredentials2g);
$ssid=$wifikeyinfo[0];
$passkey=$wifikeyinfo[1];
$scan_freq=$twogig;
}	

if ($key eq '5 GHz')	{
@wifikeyinfo=split(',',$dbCredentials5g);
$ssid=$wifikeyinfo[0];
$passkey=$wifikeyinfo[1];
$scan_freq=$fivegig;
	}
open WPA, "+>/etc/wpa_supplicant.conf";

$supplicant_file=<<WPASUPPLICANT;

ctrl_interface=/run/wpa_supplicant/
update_config=1
network={
	ssid="$ssid"
	psk="$passkey"
	$scan_freq
}
WPASUPPLICANT

print WPA $supplicant_file;
close WPA;
checkwlan($key);
	}
$return_state=(1);
return $return_state;
			
}				else				{
open WPA, "+>/etc/wpa_supplicant.conf";				
$supplicant_file=<<WPASUPPLICANT;

ctrl_interface=/run/wpa_supplicant/
update_config=1
network={
	ssid="$ssid"
	psk="$passkey"
}
WPASUPPLICANT

print WPA $supplicant_file;
close WPA;
checkwlan();
				}
$return_state=(1);
system ('netctl start netctl-static');
return $return_state;
}

sub checkdns	{
	$cnt='0';
	my @hosts=(	'bbc.co.uk', 
				'grc.com',
				'perlmonks.org');	
	foreach $host(@hosts)	{
	$p = Net::Ping->new("icmp", 5);
	if ($p->ping($host)) {
	$cnt++;
		}
	$p->close();
		}
	if ($cnt!="0")	{
			$dnstest= ("DNS Proxy Test: $cnt of 3 DNS Resolves Passed");
			$pass_or_fail=('pass');
			return (1);
		}	else	{ 			
	$dnstest= ("DNS Proxy Test: Failed");
	$pass_or_fail=('fail');
	return(0);
	}
}

sub checkwlan	{
			$wifiinprog=(1);
			my $band=shift;
			system ("netctl start netctl-wireless-auto");
			sleep (1);
	if ($p->ping($router, 15))  {      				
					$p->close();
					if ($band)	{
					if ($band=~/2/)	{
					killer();
					$pid=RatLed->WirelessTestInProg();
					push (@pids, "$pid "); 
					$pid=RatLed->WirelessPass2();
    				push (@pids, "$pid "); 
    				}	elsif	($band=~/5/)	{
    				killer();
    				$pid=RatLed->WirelessTestInProg();
					push (@pids, "$pid "); 
    				$pid=RatLed->WirelessPass5();
    				push (@pids, "$pid "); 
    				}
					$wifitest=("$band band Wifi Connection Check (using DHCP): Passed");
					push @wifiresults, $wifitest;
					}	else	{
					killer();
    				$pid=RatLed->WirelessTestInProg();
					push (@pids, "$pid "); 
    				$pid=RatLed->WirelessPass();
    				push(@pids, "$pid ");
					$wifitest=("Wifi Connection Check (using DHCP): Passed");
					push @wifiresults, $wifitest;
					}
			system ('netctl stop netctl-wireless-auto');	
			$pass_or_fail = ('pass');
			$wifiinprog=('0');
		}			else			{						
		if (!$band)	{$band="Single";}
		$wifitest=("$band Wifi Connection Check (using DHCP): Failed");
    	$pass_or_fail=('fail');	
    	system ('netctl stop netctl-wireless-auto');
		$wifiinprog=('0');
    		}
}

sub report	{

$pass_or_fail=ucfirst $pass_or_fail;
$filename=("/RAT/Reports/$model-$routername.txt");
my $date=`date`;
chomp $date;
open REPORT, "+>$filename";

my $reportstuff= <<REPORTSTUFF;
Date: $date
Manufacturer: $manufacturer
Model: $model
Firmware Version: $router_fw
Router Name (SSID): $ssid
Wifi Type: $device_status band
$router_gui
$dnstest
$wifiresults[0]
REPORTSTUFF

print REPORT $reportstuff;

if ($wifiresults[1])	{
print REPORT $wifiresults[1];
}
@wifiresults=();
my $uptime_hrs=Uptime();
$reportstuff= <<REPORTSTUFF;

Test Summary: $pass_or_fail
Test Device: $test_device
RAT Unit Total Uptime: $uptime_hrs hrs
REPORTSTUFF

print REPORT $reportstuff;
close REPORT;
$return_state=(1);
return ($return_state);
}

sub Pass	{
		killer();
		RatLed->Clear();
		$pid=RatLed->Pass();
		push (@pids, "$pid ");
		$marker=(0);
		ckisalive();
				
}

sub Fail	{
		killer();
		RatLed->Clear();
 	   	$pid=(RatLed->Fail());
		push (@pids, "$pid ");
		$marker=(0);
		ckisalive();
}	

sub Uptime	{  
				open UPTIME, "</RAT/Tools/Uptime/Uptime_in_min.txt";
				$uptime=<UPTIME>;
				close UPTIME;
				chomp $uptime;
				$uptime = ( $uptime/ 60);
				$uptime = sprintf("%.2f", $uptime);
				return $uptime;
}

sub FTP_Results	{
			$ftp->login('beaglerat','RT41102Beagle');
			$ftp->cwd("RAT_Results");
				@files=</RAT/Reports/*>;
				foreach $file(@files)	{
				$ftp->put($file);
				system("rm $file");
				$ftp->quit;
				}
}


sub pass_or_fail	{
		if ($pass_or_fail eq 'pass')	{
		Pass();
		} elsif	($pass_or_fail eq 'fail')	{
		Fail();
	}
}

sub ckisalive	{
sleep (1);
if (!$p->ping($router))	{
killer();
system('clear-leds');

goto INITIALIZE;
}	else	{
sleeper();
	}
}

sub sleeper	{
				sleep (1);
				ckisalive ();
}

sub killer	{
			if (@pids)	{
			system("kill @pids");
			}
			if	($pid)	{
			system("kill $pid");
		}
	system ('clear-leds');	
	@pids=();
	$pid=();
}

goto INITIALIZE;
