intr:	sei
	rti

nmi:	
	pha
	lda	vwait_expected
	bne	.ok
	debug_p ds_late_vwait
.ok:
	lda	#0
	sta	$2006
	sta	$2006
	lda	x_scroll
	sta	$2005
	lda	#0
	sta	$2005

	lda	sprite_dma_ok	; it's not always right to do DMA
	beq	.no_dma

	lda	#sprite/$100	; sprite
	sta	$4014

.no_dma:
.done:	
	
	lda	#1
	sta	nmi_finished
	pla
	rti
