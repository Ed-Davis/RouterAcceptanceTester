#!/usr/bin/perl -w -I /PiRAT/Tools

BEGIN {
use lib "/PiRAT/Tools";
use lib "/PiRAT";
}
system('init-lights');
use strict;
package RatLed;
my $_='1';


my $on=('echo high > ');
my $off=('echo low > ');
my $sleep=($ARGV[0] ||"0.2");
my $state=('');
my $delay=('0.012');

my $red2=('/sys/class/gpio/gpio22/direction');
my $amber1=('/sys/class/gpio/gpio27/direction');
my $amber2=('/sys/class/gpio/gpio47/direction');
my $green1=('/sys/class/gpio/gpio23/direction');
my $green2=('/sys/class/gpio/gpio45/direction');
my $green3=('/sys/class/gpio/gpio69/direction');
my $green4=('/sys/class/gpio/gpio66/direction');

Clear ();

sub Clear				{
				
                system("$off $red2");
                system("$off $amber1");
		system("$off $amber2");
                system("$off $green1");
                system("$off $green2");
                system("$off $green3");
                system("$off $green4");	
}

sub StartupSeq	{

my $count='1';

while ($count<=3)	{
system("$on $red2");
select(undef, undef, undef, $sleep);
system("$on $amber1");
system("$off $red2");
sleep ('0.075');
system("$on $amber2");
system("$off $amber1");
sleep ('0.075');
system ("$on $green1");
system("$off $amber2");
select(undef, undef, undef, $sleep);
system("$off $green1");
system("$on $green2");
select(undef, undef, undef, $sleep);
system ("$on $green3");
system("$off $green2");
select(undef, undef, undef, $sleep);
system ("$on $green4");
system ("$off $green3");
select(undef, undef, undef, $sleep);
system ("$off $green4");

$count++;
	}
$count='0';	
while ($count<=4)	{
				system("$on $red2");
                system("$on $amber1");
				system("$on $amber2");
                system("$on $green1");
                system("$on $green2");
                system("$on $green3");
                system("$on $green4");	
                select(undef, undef, undef, $sleep);
                system("$off $red2");
                system("$off $amber1");
				system("$off $amber2");
                system("$off $green1");
                system("$off $green2");
                system("$off $green3");
                system("$off $green4");	
                select(undef, undef, undef, $sleep);			
		$count++;				
	}

}

sub Breathe             {

if (my $pid=fork) {
return "$pid";
} else {
while (1)       {

		while ($delay<=1)    {
				system("$on $red2");
				select(undef, undef, undef, $delay);
				system("$off $red2");
				select(undef, undef, undef, $delay);
				$delay=$delay*2;
		}
		until ($delay<=0.012)   {
				system("$on $red2");
				select(undef, undef, undef, $delay);
				system("$off $red2");
				select(undef, undef, undef, $delay);
				$delay=$delay/2		
			}	
		}
  	}  
}

sub RouterDetected	{
$sleep=("0.2");
if (my $pid=fork) {
return "$pid";
} else {
while (1)       {
						while (1)	{
				system("$on $red2");
                system("$on $amber1");
                select(undef, undef, undef, $sleep);
                system("$off $red2");
                select(undef, undef, undef, $sleep);
                system("$off $amber1");
            	system("$on $red2");
                select(undef, undef, undef, $sleep);
                system("$off $red2");
                select(undef, undef, undef, $sleep);
            }
		}
	}
}

sub LocalPass	{
Clear();
if (my $pid=fork) {
return "$pid";
} else {
while (1)	{

				system("$on $green1");
				select(undef, undef, undef, 0.8);
				system("$off $green1");
				select(undef, undef, undef, 0.4);

	}
}
}

sub RemoteTest		{
$sleep=("0.2");
if (my $pid=fork) {
return "$pid";
} else {
while (1)	{
				system("$on $amber1");  ####Amber on to make local test passed
				system("$on $red2");
                system("$on $amber2");
                select(undef, undef, undef, $sleep);
                system("$off $red2");
                system("$off $amber2");
                select(undef, undef, undef, $sleep);
                system("$off $amber2");
            	system("$on $red2");
                select(undef, undef, undef, $sleep);
                system("$off $red2");
                system("$off $amber1");
                select(undef, undef, undef, $sleep);
             	system("$on $amber2");
		}
	}				
}

sub RemotePass 	{
Clear();
if (my $pid=fork) {
return "$pid";
} else {
while (1)	{
				system("$off $green1");
				system("$off $green2");
				select(undef, undef, undef, 0.8);
				system("$on $green2");
				system("$on $green1");
				select(undef, undef, undef, 0.4);



	}
}
}

sub WirelessTestInProg	{
Clear();
if (my $pid=fork) {
return "$pid";
} else {
while (1)	{

				system("$on $amber1");
				system("$off $amber2");
				select(undef, undef, undef, 0.02);
				system("$on $amber2");
				system("$off $amber1");
				select(undef, undef, undef, 0.02);



	}
}
}

sub WirelessPass		{

Clear();

if (my $pid=fork) {
return "$pid";
} else {
while (1)	{

				system("$off $green1");
				system("$off $green2");
				system("$off $green3");
				select(undef, undef, undef, 0.8);
				system("$on $green3");
				system("$on $green2");
				system("$on $green1");
				select(undef, undef, undef, 0.4);



	}
}
}

sub TestInProg 	{

if (my $pid=fork) {
return "$pid";
} else {
while (1)	{

			system("$off $red2");
			system("$off $amber1");			
			system("$on $amber2");
			select(undef, undef, undef, 0.2);			
			system("$off $red2");
			system("$on $amber1");			
			system("$off $amber2");
			select(undef, undef, undef, 0.2);			
			system("$on $red2");
			system("$off $amber1");			
			system("$off $amber2");

	}
}

}

sub Fail	{

if (my $pid=fork) {
return "$pid";
} else {
while (1)	{

my $count='0';
until ($count==5)	{

				system("$off $red2");
				system("$off $amber1");
				system("$off $amber2");
				select(undef, undef, undef, 0.05);
				system("$on $red2");
				system("$on $amber1");
				system("$on $amber2");
				select(undef, undef, undef, 0.05);
				$count++;
				
				}
			sleep (3);
		}
	}
}

sub Pass 	{
Clear();

if (my $pid=fork) {
return "$pid";
} else {
while (1)	{

my $count='0';
until ($count==5)	{
				system("$off $green1");
				system("$off $green2");
				system("$off $green3");
				system("$off $green4");
				select(undef, undef, undef, 0.05);
				system("$on $green1");
				system("$on $green2");
				system("$on $green3");
				system("$on $green4");
				select(undef, undef, undef, 0.05);
				$count++;
	}
sleep (3);
		}
	}
}

sub SelfHeal	{
Clear();

if (my $pid=fork) {
return "$pid";
} else {
while (1)	{
		                system("$on $red2");
		                select(undef, undef, undef, 0.02);
		                system("$off $red2");
		                select(undef, undef, undef, 0.02);

			}
		}
	}

1;

