ppu_on:
	debug_p	ds_ppu_on
	jsr	vwait
	lda	#%10000000
 	sta	$2000	
	jsr	vwait
	lda	#%00011110
 	sta	$2001

	rts

ppu_off:
	debug_p ds_ppu_off
	jsr	vwait
	lda	#0
	sta	$2000
	sta	$2001

	rts
