#!/usr/bin/perl

while (<>) {
  chomp;
  s/#.*//;
  /\S/ and push @w, split;
  last if @w >= 4;
}
#print STDERR $w[0], "\n";
#print STDERR $w[1], "\n";
#print STDERR $w[2], "\n";
#print STDERR $w[3], "\n";
my ($P, $w, $h, $m) = @w;
die unless $P eq "P5" and $w == 128;
$d = $w[3] / 3 - 3; # fudge factor
{local $/; $file = <>}
@img = unpack "C*", $file;


for $y (0..($h / 8) - 1) {
  for $x (0..15) {
    my @b = (0) x 16;
    for $Y (0..7) {
      for $X (0..7) {
	$bit1 = !!((2 << (7 - $X)) & $b[$Y]);
	$pix = int( @img[($y * 8 + $Y) * 128 + $x * 8 + $X] / $d);
	if ($pix & 1) {  $b[$Y] += (1 << (7 - $X)) }
	if ($pix & 2) {  $b[8 + $Y] += (1 << (7 - $X)) }
      }
    }
    push @f, @b;
  }
}

print pack "C*", @f;

