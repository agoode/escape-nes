make_step_sound:
	;; sq2
	lda	#%00010111
	sta	$4004
	
	lda	#%10000010
	sta	$4005
	
	lda	#%11111000
	sta	$4006
	
	lda	#%00001001
	sta	$4007
	
; 	;; noise
; 	lda	#$0
; 	sta	$400C
; 	sta	$400F
	
; 	lda	#%10001101
; 	sta	$400E
	

	rts


make_no_move_sound:
	;; sq2
	lda	#$0
	sta	$4004
	sta	$4005

	lda	#%11111111
	sta	$4006

	lda	#%00000011
	sta	$4007

	rts


make_break_sound:
	;; noise
	lda	#%00001111
	sta	$400C

	lda	#%00001110
	sta	$400E
	
	lda	#%00001000
	sta	$400F

	
	rts


make_electric_off_sound:
	;; sq1
	lda	#%10000110
	sta	$4000

	lda	#%10110101
	sta	$4001

	lda	#%00011110
	sta	$4002

	lda	#%00001100
	sta	$4003
	
	rts


make_hole_plug_sound:
	;; sq1
	lda	#%10000101
	sta	$4000

	lda	#%11110010
	sta	$4001

	lda	#%01001000
	sta	$4002

	lda	#%00001000
	sta	$4003
	
	rts

make_zap_sound:
	;; sq1
	lda	#%11001101
	sta	$4000

	lda	#%00011010
	sta	$4001

	lda	#%11100111
	sta	$4002

	lda	#%00000101
	sta	$4003

	rts


make_swap_sound:
	;; sq1
	lda	#%00011111
	sta	$4000

	lda	#%11001011
	sta	$4001

	lda	#%00000010
	sta	$4002

	lda	#%00010001
	sta	$4003
	
	rts


make_slide_sound:
	;; noise
	lda	#%00000011
	sta	$400C

	lda	#%00000011
	sta	$400E

	lda	#%00001000
	sta	$400F
	
	rts


make_transport_sound:
	;; sq1
	lda	#%10001000
	sta	$4000

	lda	#%10100010
	sta	$4001

	lda	#%00100011
	sta	$4002

	lda	#%00001000
	sta	$4003
	
	rts


make_pulse_sound:
	;; sq1
	lda	#%10000001
	sta	$4000

	lda	#%11001010
	sta	$4001

	lda	#%10000010
	sta	$4002

	lda	#%00010001
	sta	$4003
	rts


make_laser_sound:
	;; sq1
	lda	#%01011111
	sta	$4000
	
	lda	#%10000100
	sta	$4001

	lda	#%01000000
	sta	$4002

	lda	#%00001000
	sta	$4003

	;; noise
	lda	#%00001111
	sta	$400C
	lda	#%10001111
	sta	$400E
	lda	#%00001000
	sta	$400F
	
	rts


make_exit_sound:
	;; sq1
	lda	#%10001111
	sta	$4000

	lda	#%11111010
	sta	$4001

	lda	#%11111110
	sta	$4002

	lda	#%00001111
	sta	$4003

	rts
