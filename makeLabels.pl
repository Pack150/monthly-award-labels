#!/usr/local/bin/perl -w

#        This shows the capabilities of the program...
use strict;
use warnings;
use PostScript::MailLabels 2.0;
use PostScript::Convert;
use Data::Dumper qw(Dumper);
use Text::CSV;
my $labels = PostScript::MailLabels->new;

#####################################################################`
#    Dumping information from the modules
#####################################################################`


#    Here is how to list the available fonts
#print "\n****** fonts ******\n";
#my @fonts = $labels->ListFonts;
#foreach (@fonts) {
#    print "$_\n";
#}

#    Simple setup using predefined Avery label
$labels -> labelsetup(
    Avery       => $labels->averycode(8253)
    );

#    What address components are available?
#print "components : ",join(' : ',@{$labels->editcomponent()}),"\n";

#    Lets create a new component
$labels->editcomponent('den_name', 'name', 'no', 0, 'Helvetica');
$labels->editcomponent('cub_name', 'name', 'no', 1, 'Helvetica-Bold');
$labels->editcomponent('award1', 'name', 'no', 2, 'Courier');
$labels->editcomponent('award2', 'name', 'no', 3, 'Courier');
$labels->editcomponent('award3', 'name', 'no', 4, 'Courier');
$labels->editcomponent('award4', 'name', 'no', 5, 'Courier');
$labels->editcomponent('award5', 'name', 'no', 6, 'Courier');
$labels->editcomponent('award6', 'name', 'no', 7, 'Courier');
$labels->editcomponent('award7', 'name', 'no', 8, 'Courier');
$labels->editcomponent('award8', 'name', 'no', 9, 'Courier');
$labels->editcomponent('blank', 'name', 'no', 10, 'Courier');

#    first clear the old (default) definition
$labels->definelabel('clear');
#                   line number, component list
$labels->definelabel(0,'den_name');
$labels->definelabel(1,'blank');
$labels->definelabel(2,'cub_name');
$labels->definelabel(3,'award1');
$labels->definelabel(4,'award2');
$labels->definelabel(5,'award3');
$labels->definelabel(6,'award4');
$labels->definelabel(7,'award5');
$labels->definelabel(8,'award6');
$labels->definelabel(9,'award7');
$labels->definelabel(10,'award8');


#    What is the current label layout?
#print "\n****** layout ******\n";
#my @layout = @{$labels->definelabel()};
#foreach (@layout) {
#    print join(' : ',@{$_}),"\n";
#}


#        adjust printable area and draw test boxes

my $output = $labels->labeltest;
#open (FILE,"> boxes.ps") || warn "Can't open boxes.ps, $!\n";
#print FILE $output;
#close FILE;

my %awards;
my $csv = Text::CSV->new ();
#open my $io, "<", 'JuneAwards.csv' or die "JuneAwards.csv: $!";
$csv->getline (*STDIN); # ignore the headers
while (my $row = $csv->getline (*STDIN)) {
    my @fields = @$row;
    if ($fields[6] eq 'Badges of Rank') {
      print "Ignoring Rank Badge\n";
    } else {
      $awards{$fields[2]}{"$fields[0] $fields[1]"}{$fields[8]} =1;
    }
}

#print Dumper \%awards;
my @awardsList;

foreach my $den (sort keys %awards) {
  foreach my $scout (sort keys %{$awards{$den}}) {
    my @scoutRecord;

    foreach my $award (sort keys %{$awards{$den}{$scout}}) {
      $award =~ s/cub scout[s]//i;
      $award =~ s/^\s+|\s+$//g; # trim
      if ($award =~ / Adventure$/i) {
        $award =~ s/ Adventure//i;
        $award = "  - $award";
        push @scoutRecord, $award;
        next;
      }
      $award =~ s/ emblem$//i;
      $award =~ s/ award patch$//i;
      $award = "  * $award";
      unshift @scoutRecord, $award;
    }
    unshift @scoutRecord, $scout;
    unshift @scoutRecord, "$den";

    my $len = scalar @scoutRecord;
    if ( $len > 10 ){
      print "$scout HAS EARNED TOO MANY AWARDS FOR THESE LABELS\n"
    }
    for (;$len <= 10;$len++) {
      push @scoutRecord, ' ';
    }
    push @awardsList,[@scoutRecord];
  }
}

#print Dumper \@awardsList;

$output = $labels->makelabels([@awardsList]);
psconvert(\$output, 'awardLabels.pdf');
print "\n******* label output in  awardLabels.pdf *******\n";
