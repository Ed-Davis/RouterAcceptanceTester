#!/usr/bin/perl -w -I /RAT/Tools/

BEGIN {
use lib "/RAT/Tools";
use lib "/RAT";
use v5.10;
}
use strict;

use Net::Ping;
use Time::HiRes qw(usleep);
use WWW::Mechanize;
use WWW::Mechanize::FormFiller;
use URI::URL;
use Net::FTP;
require LWP::UserAgent;
use RatLed;

my $router='192.168.0.1'; 
my $bbc='212.58.241.131'; 
my $cnt=(0);
my $var_sky_ssid = ('var sky_ssid = ');
my $varwpaPskKey = ('var wpaPskKey = ');
my $model=("_");  
my $pass_or_fail=('Pass');
my $wifitest=('WiFi Not Tested');
my $router_gui=("GUI Not Tested");
my $wantest=();
my $dnstest=("Skipped");
my $ssid=("_");
my $datechecked=(0);
my ($user,$password)=('admin','sky');
my $tablestart=('<td>');
my $tableend=('</td>');
my $manstart=('Manufacturer');
my $marker=(0);
my $ethernetInfo=('cat /sys/class/net/eth0/operstate');
my $wlanInfo=('cat /sys/class/net/wlan0/operstate');
my $deviceID=('RAT 1');
my $hashed_report;
my ($uptime, $pid, $lastpid, $passkey, $rspage, $response, $nextstuff, 
	$manufacturer, $router_fw, $adsl_fw, $mac_lan, $filename, $eth0state, 
	$wlan0state, $heading, $timeout, @pids, @content);
my $agent = WWW::Mechanize->new( autocheck => 1 );
my $formfiller = WWW::Mechanize::FormFiller->new();
my $p = Net::Ping->new();

package RAT;
print "my PID is $$\n";
sub Start	{
RatLed->StartupSeq(); 
system('netctl start netctl-static');
}

sub waitForRouter	{ 
				RatLed->Clear();
				killer();
				$pid=(RatLed->Breathe());
			if ($marker==0)	{  			
				$marker++;
				open RESOLV, ">/etc/resolv.conf";
my $resolve=<<RESOLV;
domain Home
search Home
nameserver 192.168.0.1
RESOLV
print RESOLV $resolve;
}	
	
	if ($p->ping($router, 2))  {   
			$p->close();
			$marker=("0");
	 		system ("kill $pid");
			RatLed->Clear();
			return "connected";

  		}		else		{
    	
    		$p->close();
			sleep (1);
			waitForRouter();  
	}
}

sub wanCheck { 
		if ($p->ping($router, 2))	{	
			$pid=(RatLed->TestInProg());
			push (@pids, "$pid ");
			$pid=(RatLed->LocalPass());
			push (@pids, "$pid ");
    if ($p->ping($bbc, 3))  { 
    	sleep (1);
    	$p->close(); 
	return "wanconnected";
			}	else	{    
    	$p->close();
		$marker=(0);
		return "no wanavailable";
	}
}	else 	{
return "FAIL";
	}
}

sub deviceReport	{

				my ($date)=`date`;
				chomp $date;
				$hashed_report -> {'Date: '} = $date;
				$hashed_report -> {'RAT\'s Name: '} = $deviceID;
				my $uptime_result=Uptime();
				$hashed_report -> {'RAT\'s Age: '} = $uptime_result;				
				my $lanport=('LAN Port');
				my $macstart=('MAC Address');
				my $doc_w=('document.write');
				my $modstart=('>Model</'); 
				my $rfw='Firmware Version';	
				$agent->env_proxy();	
				$agent->credentials($user, $password);
				$agent->get('http://192.168.0.1/sky_index.html');
				$agent->form_number(1) if $agent->forms and scalar @{$agent->forms};
				$agent->get('http://192.168.0.1/sky_router_status.html');
				$agent->form_number(1) if $agent->forms and scalar @{$agent->forms};
				if ($p->ping($router, 2))	{
					$rspage=($agent->content);
					@content=($rspage);
					$router_gui=('Responding and credentials correct');		
					$hashed_report -> {'Router GUI:'} = $router_gui;
				if ($rspage=~(m/$manstart\s|\S/g))	{
					my $nextstuff=$';
				if ($nextstuff=~m/\>(\w{1,5})/) {
					($manufacturer)=$1;
					$hashed_report -> {'Manufacturer: '} = $manufacturer;
				}
			}
				
			if ($rspage=~(m/$modstart\s|\S/g))	{
					my $nextstuff=$';
			if ($nextstuff=~m/(SR[0-9]{3})/) {
				($model)=$1;
				$hashed_report -> {'Model: '} = $model;
				}
			}
			 
			if ($rspage=~(m/$rfw<\/\w{1,}>\s{0,}<\w{1,}>/))	{
					my $nextstuff=$';
			if ($nextstuff=~m/^\s{0,}(.{1,})\s|\n$/g) {	
				($router_fw)=$1;
				$router_fw=~(s/<\/td>//sg);
				$hashed_report -> {'Firmware Version: '} = $router_fw;
				}
			}
				$agent->get('http://192.168.0.1/sky_wireless_settings.html');
				$agent->form_number(1) if $agent->forms and scalar @{$agent->forms};	
		my @lines=($agent->content);
				foreach my $line(@lines)	{
				if ($line=~(/$var_sky_ssid['](\S{1,})[']/))  {
					($ssid)=$1;
					$hashed_report -> {'Router Name (SSID): '} = $ssid;	
						}
						if ($line=~(/$varwpaPskKey['](\S{1,})[']/))  {
						($passkey)=$1;
				}
			}
			
if ($router_gui)	{

open WPA, "+>/etc/wpa_supplicant.conf";			
my $supplicant_file=<<WPASUPPLICANT;
ctrl_interface=/run/wpa_supplicant/
network={
	ssid="$ssid"
	psk="$passkey"
}
WPASUPPLICANT

	print WPA $supplicant_file;
	close WPA;
	$wifitest='Gathered successfully';
	$hashed_report -> {'Wireless credentials: '} = $wifitest;
		}		
	return $hashed_report;
	}	else	{
return "FAIL";
	}
}

sub checkWLAN	{
			RatLed->Clear();
			killer();
			$pid=(RatLed->TestInProg());
			push (@pids, "$pid ");
			$pid=(RatLed->LocalPass());
			push (@pids, "$pid ");
			$pid=(RatLed->WirelessTestInProg());
			push (@pids, "$pid ");
			$pid=(RatLed->RemotePass());		
			push (@pids, "$pid ");
			system ("netctl stop netctl-static");
			sleep (1);			
			system ("netctl start netctl-wireless-auto");	

use Time::Out qw(timeout);
timeout 120 => sub {
	if ($p->ping($router, 5))  {   
					killer();	
    				$pid=(RatLed->WirelessPass());
    				push (@pids, "$pid ");
    				$pid=(RatLed->TestInProg());
					push (@pids, "$pid ");    				
					$p->close();
					$pass_or_fail=('Pass');
					$hashed_report -> {'Test pass/fail?: '} = $pass_or_fail;
					$wifitest="Successful";
					DNSCheck();
					interface_return();
					} 	else	{
					return "FAIL";
					$wifitest=('Unsuccessful');
    				$pass_or_fail=('Fail');
					interface_return();
				$hashed_report -> {'Test pass/fail?: '} = $pass_or_fail;
				$hashed_report -> {'Wifi Connection Check (using DHCP): '} = $wifitest;
				return $hashed_report;
		}
};
if ($@){				
		$wifitest=('Failed');
    	$pass_or_fail=('Fail');
    	$hashed_report -> {'Test pass/fail?: '} = $pass_or_fail;	
    	interface_return();
    	
	}
	$hashed_report -> {'Test pass/fail?: '} = $pass_or_fail;
	$hashed_report -> {'Wifi Connection Check (using DHCP): '} = $wifitest;
	return $hashed_report;
}

sub interface_return	{
		$eth0state = `$ethernetInfo`;
		$wlan0state = `$wlanInfo`; 
		chomp $eth0state;
		chomp $wlan0state;
		system('netctl stop netctl-wireless-auto');
		system('pkill wpa_supplicant');
		my $wpafile="/run/wpa_supplicant/*";
		if (-e $wpafile)	{
		system("rm $wpafile");
		}
		if ($eth0state eq 'down')	{
		system('netctl start netctl-static');
		}
		if ($p->ping($router, 2)) 	{
		FTP_Results();
		}	else	{
		return "FAIL";
		}
}

sub killer	{
				if (@pids)	{
					for my $process(@pids)	{
					system("kill $process");
				}
					@pids=();
					$pid=();
				} elsif	($pid)	{
					system("kill $pid");
					$pid=();
			}
}

sub Uptime	{  
				open UPTIME, "</RAT/Tools/Uptime/Uptime_in_min.txt";
				$uptime=<UPTIME>;
				close UPTIME;
				chomp $uptime;
				my $hours;
				my $minutes;
				$hours = $uptime / 60 ;
				$minutes =  $uptime % 60 ;
					if ($minutes<10)	{
							$minutes="0$minutes";
				}
					if ($hours =~/([0-9]{0,})\../)	{
							$hours = $1;
				}
						$uptime = "$hours hrs $minutes min";
						return $uptime;
}

sub FTP_Results	{
				my ($date)=`date`;
				chomp $date;
timeout 30 => sub {
			my $ftp = Net::FTP->new('cheesywotsit.dyndns.org:41102', Passive => 1);
			$ftp->login('beaglerat','RT41102Beagle');
			$ftp->cwd("RAT_Results");
			my @files=</RAT/Reports/*>;
				for my $file(@files)	{
				$ftp->put($file);
				system("rm $file");	
				}
			$ftp->quit;
			return "$date Successful upload to ftp server\n";

	};
	
if ($@){
#return "$date Failed to upload to ftp server\n";
	}
}


sub CheckIfConnected	{
			#		sleep (1);
					if (!$p->ping($router))	{
				return "Disconnected";
			}	else	{
sleeper();
	}
}

sub sleeper	{
sleep(1);
CheckIfConnected();
}

sub Pass	{
		killer();
		RatLed->Clear();
		$pid=(RatLed->Pass());
		push (@pids, "$pid ");
		interface_return();
	
}

sub Fail	{
		killer();
		RatLed->Clear();
    	$pid=(RatLed->Fail());
		push (@pids, "$pid ");
		interface_return();

}	

sub DNSCheck	{
				my ($date)=`date`;
				chomp $date;
	$cnt='0';
	my @hosts=(	'bbc.co.uk', 
				'cpan.com',
				'google.com');	
	for my $host(@hosts)	{
	my $p = Net::Ping->new("icmp", 2);
	if ($p->ping($host)) {
	$cnt++;
		}
	$p->close();
		}
	if ($cnt!="0")	{
	$wifitest = "$cnt of 3 DNS Resolves Passed";
	$hashed_report -> {"DNS Proxy Test: "} = $wifitest;
		}	else	{ 	
	$wifitest = "Failed";
	$hashed_report -> {"DNS Proxy Test: "} = $wifitest;			
	$dnstest= ("DNS Proxy Test: ");
	$pass_or_fail=('Fail');
	$hashed_report -> {'Test pass/fail?: '} = $pass_or_fail;
		}
}
