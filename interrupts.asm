intr:	sei
	rti

nmi:	
	pha
	txa
	pha
	tya
	pha
	
; 	lda	vwait_expected
; 	bne	.ok
; 	debug_p ds_late_vwait
.ok:	
; 	mov	#0,vwait_expected

	lda	#sprite/$100	; sprite
	sta	$4014

; 	lda	#8
; 	sta	drawing_limit
	jsr	copy_some_tiles_to_ppu
	
	
.done:	
	
	ldx	#0
	stx	$2006
	stx	$2006
	lda	x_scroll
	sta	$2005
	stx	$2005

	;; activate ppu after scroll
	lda	#%00011110		
	sta	$2001

	
; 	lda	#1
; 	sta	nmi_finished

	pla
	tay
	pla
	tax
	pla
	rti
