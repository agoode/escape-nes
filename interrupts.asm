	;; MMC3 interrupt to set scroll value
	
intr:	pha

	lda	x_scroll
	clc
	sta	$2005
	
	lda	#1
	sta	$E000		; ack irq
	pla
	rti

nmi:	
	pha
	txa
	pha
	tya
	pha

	lda	ppu_safe
	beq	.only_mmc3_irq
	
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
	
	
.only_mmc3_irq:		
.done:
	ldx	#0
	stx	$2006
	stx	$2006
; 	lda	x_scroll
; 	sta	$2005
	stx	$2005
	stx	$2005

 	;; activate ppu after scroll
 	lda	#%00011110		
 	sta	$2001

	
; 	lda	#1
; 	sta	nmi_finished


	;; setup MMC3 IRQ for mid-frame scrolling
	ldx	#1
	stx	$E000
	lda	#60		; in scanlines
	sta	$C000
	sta	$C001
	stx	$E000
	stx	$E001
	

	pla
	tay
	pla
	tax
	pla
	rti
