#!/usr/bin/perl

{local $/; $file = <>}
@f = unpack "C*", $file;
$img[256 * 256 - 1] = 0;

print "P5 64 256 3\n";
for $y (0..31) {
  for $x (0..7) {
    @b = splice @f, 0, 16;
    for $Y (0..7) {
      for $X (0..7) {
	$bit1 = !!((1 << (7 - $X)) & $b[$Y]);
	$bit2 = !!((1 << (7 - $X)) & $b[8 + $Y]);
	@img[($y * 8 + $Y) * 64 + $x * 8 + $X] = $bit2 * 2 + $bit1;
      }
    }
  }
}

print STDERR (scalar @img), "\n";

print pack "C*", @img;

