update_scroll_from_guy:
	;; depending on which x tile Guy is on, set the scroll
	;; (between 0-32)
	debug_p	ds_update_scroll
	
	lda	gx
	debug_num
	cmp	#2
	bmi	.scroll0

	cmp	#9
	bmi	.scroll1

	cmp	#16
 	bmi	.scroll2

	jmp	.scroll3


.scroll1_if_scroll0:
	debug_p	ds_s1_s0
	lda	x_scroll
	debug_num
	;cmp	#0
	beq	.scroll1
	rts

.scroll1_if_scroll2:
	debug_p ds_s1_s2
	lda	x_scroll
	cmp	#32
	beq	.scroll1
	rts

	
.scroll0:	
	mov	#0,x_scroll
	rts	
.scroll1:
	mov	#8,x_scroll
	rts
.scroll2:
	mov	#24,x_scroll	
	rts
.scroll3:
	mov	#32,x_scroll	
	rts
	
	
draw_guy:
	debug_p	ds_draw_guy
	tileat	gx,gy
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
	adc	#$3F
	tay	

	lda	gd
; 	debug_num
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
	rts



draw_laser_beam:
	debug_p	ds_laser_beam
	draw_text_as_sprites	ds_laser_beam
	;; draw text at top
	

	
	;; read guy sprite position
	lda	sprite
	sta	ly
	lda	sprite+3
	sta	lx
	
	;; choose direction
	lda	ld
	cmp	#dir_up
	beq	.up
	cmp	#dir_down
	bne	.not_down
	jmp	.down
.not_down:	
	cmp	#dir_right
	beq	.right
	cmp	#dir_left
	beq	.left

.right:	
	;; write 2 sprites
	lda	laser_tile
	sta	sprite+17
	sta	sprite+21

	lda	lx
	sec
	sbc	#3
	sta	sprite+19
	sta	sprite+23
	
	clc
	lda	ly
	adc	#1
	sta	sprite+16
	adc	#7
	sta	sprite+20
	
	lda	#%11000001
	sta	sprite+18
	lda	#%01000001
	sta	sprite+22


	rts

.left:
	lda	laser_tile
	sta	sprite+17
	sta	sprite+21

	lda	lx
	clc
	adc	#11
	sta	sprite+19
	sta	sprite+23
	
	clc
	lda	ly
	adc	#1
	sta	sprite+16
	adc	#7
	sta	sprite+20
	
	lda	#%10000001
	sta	sprite+18
	lda	#%00000001
	sta	sprite+22


	rts

.up:
	lda	laser_tile+1
	sta	sprite+17
	sta	sprite+21

	lda	ly
	clc
	adc	#15
	sta	sprite+16
	sta	sprite+20
	
	clc
	lda	lx
	adc	#1
	sta	sprite+23
	adc	#7
	sta	sprite+19
	
	lda	#%01000001
	sta	sprite+18
	lda	#%00000001
	sta	sprite+22


	rts

.down:

	lda	laser_tile+1
	sta	sprite+17
	sta	sprite+21

	lda	ly
	sec
	sbc	#6
	sta	sprite+16
	sta	sprite+20
	
	clc
	lda	lx
	adc	#1
	sta	sprite+23
	adc	#7
	sta	sprite+19
	
	lda	#%11000001
	sta	sprite+18
	lda	#%10000001
	sta	sprite+22


	rts

