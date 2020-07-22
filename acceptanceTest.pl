#!/usr/bin/perl -w 

use v5.10;

BEGIN {
use lib "/RAT/Tools";
use lib "/RAT";
}
use strict;
use RAT;
RAT->Start();
say $$;
my $connectionTest;
my $datechecked=(0);
my ($router_details, %router_output, %wifi_output, %output);
my $wifi=(0while ("/bin/true")	{
sleep(1);
}

sub sigHandler	{

if ($eth==0)	{
system ("ifup eth0");
$eth++;
\&waiting();
		} 	else	{
#ignore
	}
}
sub sigHandler2	{

if ($wifi==0)	{
system ("ifup eth0");
$wifi++;
\&waiting();

		}	else	{
#ignore
	}
}
sub inactive	{

\&waiting();

}

sub main {
my $eth=(0);
my $wifi=(0);

main_test();
Result();

}
			
sub waiting	{
system('>/var/lib/dhcp/dhclient.eth0.leases');

	undef (%router_output);
	undef (%wifi_output);
	undef (%output);
	$connectionTest=RAT->waitForRouter();
if ($connectionTest=~m/connected/i)	{   
				($connectionTest)=RAT->wanCheck();
				\&main_test();
}			else		{
if ($connectionTest=~m/FAIL/i)	{
waiting();
		}
	}
}

sub main_test	{
if ($connectionTest=~/\bwanconnected\b/)	{   
		if ($datechecked==0)	{
    				system('ntpdate -s ntp1.isp.sky.com');
    				$datechecked++;
	}	
		$router_details=RAT->deviceReport(); 
		%router_output=%$router_details; 
unless ($router_details=~/FAIL/i)	{
			$wifi=(1);
			my $wlan_test=RAT->checkWLAN();  
			%wifi_output=%$wlan_test; 
			$wifi=(0); 
			%output=(%router_output, %wifi_output);
			my $report_filename=($output{'Model: '} . "_" . $output{'Router Name (SSID): '} . '.txt'); 
print $report_filename, "\n";  ### Comment this out!!!
for ('Date: ',
'Manufacturer: ',
'Model: ',
'Router Name (SSID): ',
'Firmware Version: ',
'Wireless credentials: ',
'Wifi Connection Check (using DHCP): ',
'DNS Proxy Test: ',
"RAT\'s Name: ",
"RAT\'s Age: ")		{	print $_ . $output{$_} . "\n";	### Return this

			}
			
		}
	}
}

sub Result	{

if ($output{'Test pass/fail?: '}=~/fail/i)	{
RAT->Fail();
connected();
		}				else			{
RAT->Pass();
#my $checker=RAT->CheckIfConnected();
#if ($checker=~/Disconnected/i)	{
#connected();	
		#}	
	}
}

sub connected	{
		my $checker=RAT->CheckIfConnected();
				if ($checker=~/Disconnected/i)	{
				sleep (1);
	\&waiting();
	}	else	{
	sleep (1);
	connected();
	}
}

