#! /usr/bin/env perl
use strict;
use warnings;

### xwj change 2020-11-15###
my $geneid=shift or die "perl $0 gene_name\n";

my @group1=("hadal01","hadal02","hadal03","hadal04","hadal05","hadal06","hadal07");
my @group2=("tanaka01","tanaka02","tanaka03","tanaka04","tanaka05");
my $depth_file="$geneid.out";

if(-z "$geneid.gff"){
    die "$geneid is empty\n";
}

if(!-e $depth_file){
    die "run 01.prepare.pl <gene id> first!\n";
}
my $out="$geneid.status.04";

my %group;
foreach my $ind(@group1){
    $group{$ind}=1;
}
foreach my $ind(@group2){
    $group{$ind}=2;
}

my %sum;
open I,"< $depth_file";
<I>;
my %sta;
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    my ($pos,$ind,$depth)=@a;
    next unless(exists $group{$ind});
    my $group=$group{$ind};
    my $sta="mid";
    if($depth>10){
        $sta="high";
    }
    elsif($depth==0){
        $sta="low";
    }
    $sta{$pos}{$group}{$sta}++;
	$sum{$pos}{$group}+=$depth;
}
close I;

my %ave;
foreach my $pos(sort {$a<=>$b} keys %sum){
	foreach my $group(sort keys %{$sum{$pos}}){
		my $num=@group2;
		if($group == 1){
			$num=@group1;
		}
		my $mean=$sum{$pos}{$group}/$num;
		$mean=int($mean);
		$ave{$pos}{$group}=$mean;
	}
}

my $len=keys %sta;
my $lost_in_group1=0;
my $lost_in_group2=0;
foreach my $pos(sort {$a<=>$b} keys %sta){
    my @state1=keys %{$sta{$pos}{1}};
    my @state2=keys %{$sta{$pos}{2}};
    
	my $ave1=$ave{$pos}{1};
	my $ave2=$ave{$pos}{2};
	if($ave1 > 15){
		@state1=("high");
	}
	if($ave2 > 15){
                @state2=("high");
        }

    my $state1=$state1[0];
    my $state2=$state2[0];
    next if(@state1 > 1 || @state2 > 1);
    next if($state1 eq "mid" || $state2 eq "mid");
    next if($state1 eq $state2);
    if($state1 eq "low"){
        $lost_in_group1++;
    }
    elsif($state2 eq "low"){
        $lost_in_group2++;
    }
}

my $status="NA";
if($lost_in_group1/$len>=0.4){
    $status = "lost_in_group1";
}
if($lost_in_group2/$len>=0.4){
    $status = "lost_in_group2";
}
open O,"> $out";
print O "# geneid cds_len\tnum_lost_in_1\tnum_lost_in_2\tstatus\n";
print O "$geneid\t$len\t$lost_in_group1\t$lost_in_group2\t$status\n";
close O;
