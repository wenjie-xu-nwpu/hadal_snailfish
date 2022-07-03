#! /usr/bin/env perl
use strict;
use warnings;

my $input_lst="gene.lst";

my $outdir="genes";
`mkdir $outdir` if(!-e $outdir);
my $now=$ENV{'PWD'};
my $step1="$now/prepare.pl";
my $step2="$now/lostOrNot.pl";
my $step3="$now/check_gene_copy.pl";

open I,"< $input_lst";
open O,"> prepare.sh";
open W,"> lostOrNot.sh";
open N,"> check_gene_copy.sh";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my $geneid=$a[0];
	print O "cd $now/$outdir; mkdir -p $geneid; cd $geneid; perl $step1 $geneid; cd $now\n";
	print W "cd $now/$outdir/$geneid; perl $step2 $geneid; cd $now\n";
	print N "cd $now/$outdir/$geneid; perl $step3 $geneid; cd $now\n";
}
close I;
close O;
close W;
close N;
