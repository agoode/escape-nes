#!/usr/bin/perl -w

use strict;
use bytes;
$| = 1;

my $max_title = 0;
my $max_author = 0;
my $max_sw = 0;
my $max_sh = 0;
my %chars;
my $name;

while ($_ = shift) {
  open IN, $_ or die "Can't open $_: $!";
  $name = $_;

  my $buf;

  read IN, $buf, 4;

  # ESXL (4 bytes)
  die "Wrong magic: $buf\n" unless $buf eq "ESXL";

  read IN, $buf, 12;

  my ($sw, $sh, $size) = unpack "NNN", $buf;
  if ($sw > 18 || $sh > 10) {
    print "$name dimensions too big for NES version ($sw,$sh)\n";
    next;
  }
  if ($sw < 18 || $sh < 10) {
    print "$name needs padding to work on NES ($sw,$sh) < (18,10)\n";
  }
  $max_sw = $sw if $sw > $max_sw;
  $max_sh = $sh if $sh > $max_sh;

  my $title;
  my $author;
  read IN, $title, $size;
  $max_title = $size if $size > $max_title;

  read IN, $buf, 4;
  $size = unpack "N", $buf;

  read IN, $author, $size;
  $max_author = $size if $size > $max_author;

  for (split //, $title.$author) {
    $chars{uc $_} = 1;
  }

  print "\"$title\" by $author ($sw x $sh)";

  read IN, $buf, 8;
  my ($gx, $gy) = unpack "NN", $buf;
  print "  guy: ($gx, $gy)";

  my @tiles = rledecode($sw * $sh);
  print "\ntiles\n";
  printm($sw, @tiles);
  my @otiles = rledecode($sw * $sh);
  print "\notiles\n";
  printm($sw, @otiles);
  my @dests = rledecode($sw * $sh);
  print "\ndests\n";
  printm($sw, @dests);
  my @flags = rledecode($sw * $sh);
  print "\nflags\n";
  printm($sw, @flags);

  print "\n";
}

print "max_title: $max_title, max_author: $max_author, max_sw: $max_sw, max_sh: $max_sh\n";
print ("chars used: ", (sort(keys %chars)), "\n");

sub printm {
  my ($w, @m) = @_;
  my $l = 0;
  while (@m) {
    my $v = shift @m;
    print(chr($v+32));
    $l++;
    if ($l == $w) {
      $l = 0;
      print "\n";
    }
  }
}

sub rledecode {
  my $len = $_[0];

  my @out;
  my $buf;
  read IN, $buf, 1;
  my $bytes = unpack "C", $buf;
  if ($bytes > 1) {
    die "Bad file bytecount: $bytes in $name\n";
  }

  my $run;
  my $oi = 0;
  while ($oi < $len) {
    read IN, $buf, 1;
    $run = unpack "C", $buf;

    my $ch;
    if ($run == 0) {
      # anti-run
      read IN, $buf, 1;
      $run = unpack "C", $buf;
      print "\nskipping $run: ";
      for (0..$run-1) {
	read IN, $buf, 1;
	$ch = unpack "C", $buf;
#	print "$ch ";
	$out[$oi++] = $ch;
      }
    } else {
      # run
      if ($bytes) {
	read IN, $buf, 1;
	$ch = unpack "C", $buf;
      }
      else {
	$ch = 0;
      }
      print "\n$run $ch\'s: ";
      for (0..$run-1) {
#	print "$ch ";
	$out[$oi++] = $ch;
      }
    }
  }
  return @out;
}
