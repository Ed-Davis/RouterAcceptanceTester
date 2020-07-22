#!/usr/bin/perl -w -I /RAT/Tools/

package Test;


sub hello	{
my $self=shift;
my $world=shift;
chomp $world;
return "You wanted to say \"$world\"\n(dumbass)\n";
}

1;
