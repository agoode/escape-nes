intr:	sei
	rti

nmi:	
;;; 	debug_p ds_nmi
	lda	#0
	sta	$2006
	sta	$2006
	lda	x_scroll
	sta	$2005
	lda	#0
	sta	$2005

	lda	#sprite/$100	; sprite
	sta	$4014
	rti
