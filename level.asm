travel:	.macro
	pha
	mov \1,tx
	sta	debug_num
	mov \2,ty
	sta	debug_num
	mov \3,td
	sta	debug_num

	jsr	travel_func

	mov newx,\4
	sta	debug_num
	mov newy,\5
	sta	debug_num

	pla
	.endm
	
	
travel_func:
	cmp	#dir_up
	beq	.up

	cmp	#dir_down
	beq	.down

	cmp	#dir_left
	beq	.left

	cmp	#dir_right
	beq	.right

	jmp	.no


	
.up:	lda	ty		; top of map
	beq	.no

	tax
	dex
	stx	newy
	mov	tx,newx
	jmp	.yes

	
.down:	lda	ty
	cmp	#9
	beq	.no

	tax
	inx
	stx	newy
	mov	tx,newx
	jmp	.yes

	
.left:  lda	tx
	beq	.no

	tax
	dex
	stx	newx
	mov	ty,newy
	jmp	.yes

	
.right: lda	tx
	cmp	#17
	beq	.no

	tax
	inx
	stx	newx
	mov	ty,newy
	jmp	.yes



	
.no:	mov tx,newx
	mov ty,newy
	lda	#0
	rts
.yes:	lda	#1
	rts


tileat:	.macro
	ldx	\1
	ldy	\2
	jsr	tileat_func
	.endm

tileat_func:
	jsr	xy_to_index
	tay
	mov16	#tiles,tile
	lda	[tile], Y
	debug_p ds_tileat
	sta	debug_num
	rts


xy_to_index:
	debug_p	ds_xy_to_index
	clc
	txa

.yloop:	dey
	bmi	.done
	adc	#18
	jmp	.yloop
.done:
	sta	debug_num
	rts