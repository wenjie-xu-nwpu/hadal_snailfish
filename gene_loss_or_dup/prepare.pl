#! /usr/bin/env perl
use strict;
use warnings;

my $geneid=shift or die "perl $0 geneid\n";
my $gff_file="/public/home/xuwenjie/project/hadalfish/02.gene_loose/03.work/stickleback.gff3.new.2";
my $bamlst="/public/home/xuwenjie/project/hadalfish/02.gene_loose/03.work/bam.lst";
my @ind=("hadal01","hadal02","hadal03","hadal04","hadal05","hadal06","hadal07","tanaka01","tanaka02","tanaka03","tanaka04","tanaka05"); # must be the individual in the bamlst

###########################################################

`grep $geneid $gff_file | grep CDS > $geneid.gff`;

if(-z "$geneid.gff"){
    die "$geneid is empty\n";
}

my $mRNA=`grep $geneid $gff_file | grep mRNA`;
my @a=split(/\s+/,$mRNA);
my ($chr,$start,$end)=($a[0],$a[3],$a[4]);
my $command="samtools depth -a -r $chr:$start-$end -f $bamlst > $geneid.depth";
`$command`;

my $depth="$geneid.depth";
my $gff="$geneid.gff";
my $out="$geneid.out";
my %pos;
open I,"< $gff";
my $strand="+";
while (<I>) {
    my @a=split(/\s+/);
    my ($start,$end,$strand2)=($a[3],$a[4],$a[6]);
    if($strand2 eq "-"){
        $strand="-";
    }
    for(my $i=$start;$i<=$end;$i++){
        $pos{$i}=1;
    }
}
close I;
my %hash;
my $cds_pos=0;
if($strand eq "+"){
    foreach my $i(sort {$a<=>$b} keys %pos){
        $cds_pos++;
        $hash{$i}=$cds_pos;
    }
}
elsif($strand eq "-"){
    foreach my $i(sort {$b<=>$a} keys %pos){
        $cds_pos++;
        $hash{$i}=$cds_pos;
    }
}

open O,"> $out";
open I,"< $depth";
print O "pos\tind\tdepth\n";
while (<I>) {
    chomp;
    my @a=split(/\s+/);
    shift @a;
    my $i=shift @a;
    next unless(exists $hash{$i});
    my $cds_pos=$hash{$i};
    for(my $j=0;$j<@a;$j++){
        my $ind=$ind[$j];
        my $depth_ind=$a[$j];
        print O "$cds_pos\t$ind\t$depth_ind\n";
    }
}
close I;
close O;

open R,"> $geneid.plot.R";
print R '
library("ggplot2")
a=read.table("'.$out.'",header=T)
pdf("'.$geneid.'.pdf",width=5,height=3);
ggplot(a,aes(pos,depth,color=ind))+geom_line()+scale_color_manual(values=c("#c6dbef","#9ecae1","#6baed6","#4292c6","#2171b5","#08519c","#084594","#b2e2e2","#a1d99b","#66c2a4","#2ca25f","#006d2c"))+labs(x="'.$geneid.'")
dev.off();
';
close R;
`Rscript $geneid.plot.R`;
