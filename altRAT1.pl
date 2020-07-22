#!/usr/bin/perl -w -I /RAT/Tools/

BEGIN {
use lib "/RAT/Tools";
use lib "/RAT";
}
use strict;
use Net::Ping;
use Time::HiRes qw(usleep);
use WWW::Mechanize;
use WWW::Mechanize::FormFiller;
use URI::URL;
use Net::FTP;
use Tools::RatLed; 
use Time::Out qw(timeout);
require LWP::UserAgent;
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
my $supplicant_file=('/etc/wpa_supplicant.conf');
my $identifier='5 GHz';
my $twogig='scan_freq=2412 2417 2422 2427 2432 2437 2442 2447 2452 2457 2462 2467 2472';
my $fivegig='scan_freq=5825 5805 5785 5765 5745 5700 5680 5660 5640 5620 5600 5580 5560 5540 5520 5500 5320 5300 5280 5260 5240 5220 5200 5180';
my $scan_freq=$twogig;
my $ethernetInfo=('cat /sys/class/net/eth0/operstate');
my $wlanInfo=('cat /sys/class/net/wlan0/operstate');
my $ftp = Net::FTP->new('cheesywotsit.dyndns.org:41102', Passive => 1);
my ($uptime, $pid, $lastpid, $passkey, $rspage, $response, $nextstuff, 
	$manufacturer, $router_fw, $adsl_fw, $mac_lan, $filename, $eth0state, $device_status, $landing_page,
	$wlan0state, $heading, $timeout, @pids, @content);
my $return_state=(0);
my $agent = WWW::Mechanize->new( autocheck => 1 );
my $formfiller = WWW::Mechanize::FormFiller->new();
my $wifiinprog=(0);
my $p = Net::Ping->new();
my $masterpid=$$;


first_test();
interface_return();
sub first_test	{
$pass_or_fail = ('pass');
$return_state = waitforrouter();
if ($return_state == 1)	{
			$return_state=(0);
			second_test();
			}	else	{
sleep(1);
redo();
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
			checkdns();	
			third_test();
			}	else	{
if ($return_state == 0)	{
			first_test();
		}
	}
}
sub third_test	{
timeout 30 => sub {
$return_state = checkrouter();
};
if ($@)	{
first_test();
}
if ($return_state == 1)	{
			$return_state=(0);
			fourth_test();
} else	{
if ($return_state == 0)	{
			first_test();
		}
	}		
}
sub fourth_test	{
$wifiinprog=(1);
timeout 120 => sub	{
$return_state = wpasupp();
};
if ($@)	{
$return_state = (0);
interface_return();
$pass_or_fail=('fail');
fifth_test();
$wifiinprog=(0);
}
if ($return_state == 1)	{
			$return_state=(0);
			$pass_or_fail = ('pass');
			$wifiinprog=(0);
			fifth_test();
}	else {
if ($return_state == 0)	{
			$return_state=(0);
			$pass_or_fail = ('fail');
			$wifiinprog=(0);
			fifth_test();
		}
	}
}

sub fifth_test	{
report ();
timeout 20 =>	sub {
FTP_Results();
	};
if ($@)	{
complete();
	}
complete();
}


sub complete	{
		if ($pass_or_fail =~ /pass/i)	{
		$pass_or_fail = 'Pass';
		Pass();
		} 
		if	($pass_or_fail =~ /fail/i)	{
		$pass_or_fail = 'Fail';
		Fail();
		}
}


sub waitforrouter	{ 

$pass_or_fail=('pass');

	if ($marker==0)	{  			
			killer();
			interface_return();
			RatLed->Clear();
			$pid=(RatLed->Breathe());
			push(@pids, "$pid ");	
			$marker++;			
		}
			
	if ($p->ping($router, 2))  {   
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
		my $landing_page=$agent->content;
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
					my ($nextstuff)=$';
			if ($nextstuff=~m/([A-Z]{1,5})\s+/i) {
					($manufacturer)=$1;
		}
}
			my $modstart=('Model'); 
			if ($rspage=~(m/$modstart\s{0,}/g))	{
					my $nextstuff=$';		
			if ($nextstuff=~m/([A-Z]{1,3}[0-9]{3})/i) {
					($model)=$1;
		}
}
			my $rfw='Firmware Version'; 
			if ($rspage=~(m/$rfw<\/\w{1,}>\s{0,}<\w{1,}>/))	{
					my $nextstuff=$';
			if ($nextstuff=~m/^\s{0,}(.{1,})\s|\n$/g) {	
				($router_fw)=$1;
				$router_fw=~(s/<\/td>//sg);
		}
}
				my $fwstart='DSL Firmware Version'; 
				if ($rspage=~(m/([A]{0,1}$fwstart)/))	{
					my $nextstuff=$';
				if ($nextstuff=~m/\(\'(.)\'\)/g) {
					($adsl_fw)=$1;
		}
}

				my $lanport=('LAN Port');
				my $macstart=('MAC Address');
				my $doc_w=('document.write');
				if ($rspage=~(m/($lanport[.]{1,}$macstart)[.]{1,}$doc_w[.]{1,}/sg))	{
					my $nextstuff=$';
					if ($nextstuff=~m/(\S{2}:\S{2}:\S{2}:\S{2}:\S{2}:\S{2})/si) {
					($mac_lan)=$1;
		}
}
				
				$agent->get('http://192.168.0.1/sky_wireless_settings.html');
				$agent->form_number(1) if $agent->forms and scalar @{$agent->forms};	
				my @lines=($agent->content);
					foreach my $line(@lines)	{
					if ($line=~(/$var_sky_ssid['](\S{1,})[']/))  {
								($ssid)=$1;
			}
					if ($line=~(/$varwpaPskKey['](\S{1,})[']/))  {
								($passkey)=$1;
		}
}

$filename=("/RAT/Reports/$model-$ssid.txt");
open WPA, "+>$supplicant_file";
print WPA $supplicant_file;
close WPA;
my $date=`date`;
chomp $date;
open ROUTERINFO, "+>$filename";

my $reportstuff= <<REPORTSTUFF;
Date: $date
Manufacturer: $manufacturer
Model: $model
Firmware Version: $router_fw
Router Name (SSID): $ssid
Wifi Type: $device_status band
REPORTSTUFF

print ROUTERINFO $reportstuff;
close ROUTERINFO;
$return_state=(1);
return ($return_state);
}


sub wpasupp	{

####  Band should be a hash so I can use the key as the identifier and the value as the scan_freq

open WPA, "+>/etc/wpa_supplicant.conf";

my $supplicant_file=<<WPASUPPLICANT;

ctrl_interface=/run/wpa_supplicant/
network={
	ssid="$ssid"
	psk="$passkey"
	
}
WPASUPPLICANT

my $return_state=checkwlan();  ####  Need to add in an identifier to show that the test for 2 or 5 ghz passed/failed ?@ISA?
return $return_state;
}

sub checkdns	{
	$cnt='0';
	my @hosts=(	'bbc.co.uk', 
				'cpan.com',
				'perlmonks.org');	
	foreach my $host(@hosts)	{
	my $p = Net::Ping->new("icmp", 5);
	if ($p->ping($host)) {
	$cnt++;
		}
	$p->close();
		}
	if ($cnt!="0")	{
			$dnstest= ("Wifi DNS Proxy Test: $cnt of 3 DNS Resolves Passed");
			$pass_or_fail=('pass');
			return (1);
		}	else	{ 			
	$dnstest= ("DNS Proxy Test: Failed");
	$pass_or_fail=('fail');
	return(0);
	}
}

sub checkwlan	{
			system ("netctl stop netctl-static");
			system ("netctl start netctl-wireless-auto");
			killer();	
			RatLed->Clear();
			$pid=(RatLed->WirelessTestInProg());
			push (@pids, "$pid ");
			$pid=(RatLed->RemotePass());		
			push (@pids, "$pid ");
			sleep (1);
	if ($p->ping($router, 15))  {   
					killer();	
    				$pid=(RatLed->WirelessPass());
    				push (@pids, "$pid ");
    				$pid=(RatLed->TestInProg());
					push (@pids, "$pid ");    				
					$p->close();
					$wifitest=("Wifi Connection Check (using DHCP): Passed");
			interface_return();
			$pass_or_fail = ('pass');
			$return_state = (1);
			return ($return_state);
			

		}			else			{						
		$wifitest=("Wifi Connection Check (using DHCP): Failed");
    	$pass_or_fail=('fail');	
    	interface_return();
		$return_state = (0);
		return ($return_state);
    		}
}

sub report	{

my $uptime_hrs=Uptime();

my $test_results=<<RESULTS;
$router_gui
$dnstest
$wifitest
Test Summary: $pass_or_fail
Test Device: $test_device
RAT Unit Total Uptime: $uptime_hrs hrs
RESULTS

		open REPORT, "+>>$filename";
		print REPORT $test_results;
		close REPORT;
		$return_state=(1);
		return ($return_state);
}

sub Pass	{
		killer();
		RatLed->Clear();
		$pid=(RatLed->Pass());
		push (@pids, "$pid ");
		$marker=(0);
		ckisalive();
				
}

sub Fail	{
		killer();
		RatLed->Clear();
 	   	$pid=(RatLed->Fail());
		push (@pids, "$pid ");
		interface_return();
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
			my @files=</RAT/Reports/*>;
				foreach my $file(@files)	{
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
sub interface_return	{
		$eth0state = `$ethernetInfo`;
		$wlan0state = `$wlanInfo`; 
		chomp $eth0state;
		chomp $wlan0state;
		system('netctl stop netctl-wireless-auto');
		if ($eth0state eq 'down')	{
		system('netctl start netctl-static');
		}
}

sub ckisalive	{
sleep (1);
if (!$p->ping($router))	{
$return_state=(0);
first_test();

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
			foreach my $process(@pids)	{
			system("kill $process");
			}
			@pids=();
			$pid=();
			} elsif	($pid)	{
			system("kill $pid");
			sleep(1);
		}
}

sub destructor	{
if ($wifiinprog==0)	{
			system ("kill @pids");
			system ("clear-led");
			callbackHandler->endofdays();
			exit;
			}
}
			

