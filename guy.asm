draw_guy:
	; debug_p	ds_draw_guy
	mov	#0,sprite_dma_ok
	lda	gx
	asl	a
	asl	a
	asl	a
	asl	a
	sec
 	sbc	x_scroll
	tax
	
	lda	gy
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	#$2F
	tay	

	lda	gd
; 	sta	debug_num
	cmp	#dir_up
	beq	.up

.compare2:	
	cmp	#dir_down
	beq	.down_trampoline
	cmp	#dir_right
	beq	.right_trampoline
	cmp	#dir_left
	beq	.left_trampoline

.left_trampoline:
	jmp	.left	
.down_trampoline:
	jmp	.down
.right_trampoline:
	jmp	.right

.up:
	sty	sprite
	lda	guy_u_tile
	sta	sprite+1
	lda	#0
	sta	sprite+2
	stx	sprite+3

	sty	sprite+4
	lda	guy_u_tile+1
	sta	sprite+5
	lda	#0
	sta	sprite+6
	txa
	clc
	adc	#$8
	sta	sprite+7

	tya
	clc
	adc	#$8
	sta	sprite+8
	lda	guy_u_tile+2
	sta	sprite+9
	lda	#0
	sta	sprite+10
	stx	sprite+11

	tya
	clc
	adc	#$8
	sta	sprite+12
	lda	guy_u_tile+3
	sta	sprite+13
	lda	#0
	sta	sprite+14
	txa
	clc
	adc	#$8
	sta	sprite+15

	jmp	.done
.down:	
	sty	sprite
	lda	guy_d_tile
	sta	sprite+1
	lda	#0
	sta	sprite+2
	stx	sprite+3

	sty	sprite+4
	lda	guy_d_tile+1
	sta	sprite+5
	lda	#0
	sta	sprite+6
	txa
	clc
	adc	#$8
	sta	sprite+7

	tya
	clc
	adc	#$8
	sta	sprite+8
	lda	guy_d_tile+2
	sta	sprite+9
	lda	#0
	sta	sprite+10
	stx	sprite+11

	tya
	clc
	adc	#$8
	sta	sprite+12
	lda	guy_d_tile+3
	sta	sprite+13
	lda	#0
	sta	sprite+14
	txa
	clc
	adc	#$8
	sta	sprite+15

	jmp	.done

.left:	
	sty	sprite
	lda	guy_l_tile
	sta	sprite+1
	lda	#0
	sta	sprite+2
	stx	sprite+3

	sty	sprite+4
	lda	guy_l_tile+1
	sta	sprite+5
	lda	#0
	sta	sprite+6
	txa
	clc
	adc	#$8
	sta	sprite+7

	tya
	clc
	adc	#$8
	sta	sprite+8
	lda	guy_l_tile+2
	sta	sprite+9
	lda	#0
	sta	sprite+10
	stx	sprite+11

	tya
	clc
	adc	#$8
	sta	sprite+12
	lda	guy_l_tile+3
	sta	sprite+13
	lda	#0
	sta	sprite+14
	txa
	clc
	adc	#$8
	sta	sprite+15

	jmp	.done
	
.right:
	sty	sprite
	lda	guy_l_tile+1
	sta	sprite+1
	lda	#%01000000
	sta	sprite+2
	stx	sprite+3

	sty	sprite+4
	lda	guy_l_tile
	sta	sprite+5
	lda	#%01000000
	sta	sprite+6
	txa
	clc
	adc	#$8
	sta	sprite+7

	tya
	clc
	adc	#$8
	sta	sprite+8
	lda	guy_l_tile+3
	sta	sprite+9
	lda	#%01000000
	sta	sprite+10
	stx	sprite+11

	tya
	clc
	adc	#$8
	sta	sprite+12
	lda	guy_l_tile+2
	sta	sprite+13
	lda	#%01000000
	sta	sprite+14
	txa
	clc
	adc	#$8
	sta	sprite+15

	jmp	.done

.done:
	mov #1,sprite_dma_ok
	rts

