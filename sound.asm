make_step_noise:
	lda	#$0
	sta	$400C
	sta	$400F
	
;	lda	#%00000100
	lda	#%10001101
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


make_break_sound:
	lda	#%00001111
	sta	$400C

	lda	#%00001110
	sta	$400E
	
	lda	#%00001000
	sta	$400F

	
	rts