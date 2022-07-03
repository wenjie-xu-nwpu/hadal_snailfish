#!/usr/bin/perl
use strict;
use warnings;

### xwj 2021-1-19###
my $geneid=shift or die "perl $0 gene_name\n";

my @group1=("hadal01","hadal02","hadal03","hadal04","hadal05","hadal06","hadal07");
my @group2=("tanaka01","tanaka02","tanaka03","tanaka04","tanaka05");
my $depth_file="$geneid.out";

if(!-e $depth_file){
    die "$depth_file don't exists!!!\n";
}

my %group;
foreach my $ind(@group1){
    $group{$ind}=1;
}
foreach my $ind(@group2){
    $group{$ind}=2;
}

my %hash;
open I,"< $depth_file";
<I>;
while(<I>){
	chomp;
	my @a=split(/\s+/);
	my $ty=$group{$a[1]};
	$hash{$a[0]}{$ty}{$a[1]}=$a[2];
}
close I;

my $ha_sum=0;
my $ha_num=0;
my ($all,$more,$less,$no,$sa)=(0,0,0,0,0);
foreach my $site(sort {$a<=>$b} keys %hash){
	$all++;

	my $sum1=0;
	my $num1=0;
	my $sum2=0;
	my $num2=0;
	my %new;
	foreach my $ty(sort {$a<=>$b} keys %{$hash{$site}}){
		foreach my $na(sort keys %{$hash{$site}{$ty}}){
			my $dep=$hash{$site}{$ty}{$na};
			if($ty==1){
				$num1++;
				$sum1+=$dep;
				$ha_sum+=$dep;
				$ha_num++;
			}
			else{
				$num2++;
				$sum2+=$dep;
			}
			$new{$ty}{$dep}{$na}=1;
		}
	}
	
	my $mid_ta=0;
	my $mid_ha=0;
	foreach my $ty(sort {$a<=>$b} keys %new){
		my @tmp;
		foreach my $dep(sort {$a<=>$b} keys %{$new{$ty}}){
			foreach my $na(sort keys %{$new{$ty}{$dep}}){
					push @tmp,$dep;
			}
		}
		if($ty==1){
			$mid_ha=$tmp[3];
		}
		else{
			$mid_ta=$tmp[2];
		}
	}
	
	my $ave1=$sum1/$num1;
	if($ave1 > $mid_ha){
		$ave1=$mid_ha;
	}
	my $ave2=$sum2/$num2;
	if($ave2 < $mid_ta){
		$ave2=$mid_ta;
	}
	if($ave2 == 0){
		$ave2=1;
	}
		
	my $per=$ave1/$ave2;
	if($ave1 < 3 && $ave2 < 3 ){
		$no++;
	}
	else{
		if($per > 1.5){
			$more++;
		}
		elsif($per < 0.4){
			$less++;
		}
		else{
			$sa++;
		}
	}
}

my $ha_ave=$ha_sum/$ha_num;
$ha_ave=sprintf "%.2f",$ha_ave;
my $per1=$more/$all;
my $per2=$less/$all;
my $per3=$no/$all;
my $per4=$sa/$all;
my $new="same";
if($per1 > 0.5){
	$new="more";
}
if($per2  > 0.7){
	$new="less";
}
if($per3  > 0.7){
        $new="loss";
}
open O,"> $geneid.inf";
print O"$geneid\t$new\t$all\t$more\t$per1\t$less\t$per2\t$no\t$per3\t$sa\t$per4\t$ha_ave\n";
close O;
