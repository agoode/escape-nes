ppu_on:
; 	debug_p	ds_ppu_on
	lda	#%10000000
 	sta	$2000	
; 	lda	#%00011110           ; handled in nmi now
;  	sta	$2001

	lda	#1
	sta	ppu_safe
		
	jmp	vwait

ppu_off:
; 	debug_p ds_ppu_off
	lda	#0
	sta	$2000
	sta	$2001

	jsr	vwait
	rts

mask_nmi:
; 	lda	#0                   ; must keep nmi active for scroll
; 	sta	$2000
	lda	#0
	sta	ppu_safe
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

	
	lda	#%00011011
	ldx	#44
.zero_buffer:
 	sta	attr_buffer, X
	dex
	bpl	.zero_buffer
	
	rts
	