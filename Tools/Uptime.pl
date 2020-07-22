#!/usr/bin/env perl -w

use strict;

my $file='/RAT/Tools/Uptime/Uptime_in_min.txt';

open FH1, "<$file";
my $uptime=<FH1>;
close FH1;
$uptime++;
open FH1, ">$file";
print FH1 $uptime;
close FH1;

