$a = 0x20C0; for $i (0..9) { for $j (0..17) { $r = $a + ($i * 64) + ($j * 2); if ($j > 15) {$r += 0x400; $r -= 0x20} push @low, ($r & 0xFF); push @high, ($r & 0xFF00) >> 8;}} foreach (@low) {printf "\$%.2X,", $_;} print "\n"; foreach (@high) {printf "\$%.2X,", $_;}
