#!/usr/bin/perl -w


print $$ . "\n";


$SIG{USR1} = \&sigHandler; 
$SIG{USR2} = \&sigHandler2; 

my $returned=`perl /RAT/RAT.pl &`;
print $returned;


##### conditional on the ethernet state to send signal


while (1)	{sleep(1);};

sub sigHandler	{ 

print "A signal came here...\n";

}
sub sigHandler2	{
print "Oooh a naughty little sig came here.. \n";

}




