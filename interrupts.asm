intr:	sei
	rti

nmi:	
	pha
	txa
	pha
	tya
	pha
	
	lda	vwait_expected
	bne	.ok
	debug_p ds_late_vwait
.ok:	
	mov	#0,vwait_expected

	lda	sprite_dma_ok	; it's not always right to do DMA
	beq	.no_dma

	lda	#sprite/$100	; sprite
	sta	$4014

.no_dma:
	lda	safe_to_draw
	beq	.done
	lda	#6
	sta	drawing_limit
	jsr	copy_some_tiles_to_ppu
	
	
.done:	
	
	lda	#0
	sta	$2006
	sta	$2006
	lda	x_scroll
	sta	$2005
	lda	#0
	sta	$2005

	lda	#1
	sta	nmi_finished

	pla
	tay
	pla
	tax
	pla
	rti
