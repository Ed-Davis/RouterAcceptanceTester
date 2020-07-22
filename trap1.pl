#!/usr/bin/perl -w

use strict;

system("perl /RAT/RAT.pl &");

my $pid =`ps -ef | grep /RAT/RAT.pl`;
my $script='RAT.pl';
if ($pid=~g/$script/)	{

my $line=$`;

print $line;

print "The RATS pid is $pid\n\n";

sleep 100;


my $eth_state =`cat /sys/class/net/eth0/operstate`;
my $new_state;

while (1)	{

$new_state =`cat /sys/class/net/eth0/operstate`;

if ($new_state ne $eth_state)	{
$eth_state=$new_state;

								#system("kill -10 $mainpid");
								sleep (2);
			}
}

}