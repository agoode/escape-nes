ppu_on:
	debug_p	ds_ppu_on
	jsr	vwait
	lda	#%10000000
 	sta	$2000	
	jsr	vwait
	lda	#%00011110
 	sta	$2001
	jsr	vwait

	rts

ppu_off:
	debug_p ds_ppu_off
	jsr	vwait
	lda	#0
	sta	$2000
	sta	$2001
	jsr	vwait

	rts


;;; try to make sure ppu is off, first
zero_ppu_memory:
	debug_p ds_zero_ppu_memory
	;; zeroing only attribute tables for now
;  	mov	#$23, $2006
;  	mov	#$C0, $2006
;  	lda	#$0

;  	ldx	#$40
; .zero1:	sta	$2007
;  	dex
;  	bne	.zero1

;  	mov	#$27, $2006
;  	mov	#$C0, $2006
;  	lda	#$0
	
;  	ldx	#$40
; .zero2:	sta	$2007
;  	dex
;  	bne	.zero2

	
	lda	#0
	ldx	#44
.zero_buffer:
 	sta	attr_buffer, X
	dex
	bpl	.zero_buffer
	
	rts
	