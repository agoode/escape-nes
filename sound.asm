make_step_noise:
	lda	#$0
	sta	$400C
	sta	$400F
	
	lda	#%00000100
	sta	$400E
	

	rts


make_no_move_sound:
	lda	#$0
	sta	$4000
	sta	$4001

	lda	#%11111111
	sta	$4002

	lda	#%00000011
	sta	$4003

	rts
	