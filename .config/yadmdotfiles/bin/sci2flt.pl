#!/usr/bin/perl
# Converts scientific notation to floating point number in file or stdin

use Scalar::Util qw(looks_like_number);

while(<>) {
  chomp;
  my @fields=split(/[,\s]+/);
  foreach my $f (0..scalar @fields-1) {
    if (looks_like_number($fields[$f]) > 0) {
      $fields[$f] = sprintf("%.2f",$fields[$f]);
    }
  }
  print join("    ",@fields),"\n";
}

