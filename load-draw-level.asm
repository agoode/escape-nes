load_level:
	debug_p ds_load_level
	mov	#0, tmp_size+1
	mov	#dir_right, gd
	mov	#0, x_scroll
			
	mov16	level_addr, idx16
	ldy	#0
	mov	[idx16], Y, tmp
	iny
	mov	[idx16], Y, tmp
	iny
	mov	[idx16], Y, tmp
	iny
	mov	[idx16], Y, tmp
	ldy	#15		; ESXL + width + height + MSB of size of title
	mov	[idx16], Y, tmp_size	; size of title string
	add16	idx16, #16		; move to start of title

	;; copy the title string
	strcpyp2c	idx16, title, tmp_size

	add16	idx16, tmp_size	; move past the title string
	ldy	#3		; MSB of size of author
	mov	[idx16], Y, tmp_size ; size of author string
	add16	idx16, #4	; move to start of author

	;; copy the author string
	strcpyp2c	idx16, author, tmp_size

	add16	idx16, tmp_size	; move past the author string

	ldy	#3		; MSB of guy x
	mov	[idx16], Y, gx
	add16	idx16, #4
	ldy	#3		; MSB of guy y
	mov	[idx16], Y, gy
	add16	idx16, #4

		
	;; start rledecoding
 	mov16	#tiles, tmp_addr
	jsr	rledecode


	debug_p	ds_tiles
; 	mov	#tiles, debug_num
; 	mov	(#tiles)+1, debug_num
	ldx	#0
.tile_print:	
; 	mov	tiles, X, debug_num
	inx
	txa
	cmp	#180
	bne	.tile_print
	
	mov16	#otiles, tmp_addr
  	jsr	rledecode
	mov16	#dests, tmp_addr
 	jsr	rledecode
	mov16	#flags, tmp_addr
 	jsr	rledecode

	rts
		
	
draw_level:
	jsr	ppu_off
	debug_p ds_draw_level
	;; assumes load_level just called
		
	mov	#0, tile_pos
.loop:	lda	tile_pos
	cmp	#180
	beq	.done
	bit	#%00000100
	bne	.continue
.continue:	
	ldx	tile_pos

	;; get the tile
	lda	tiles, X
	tax
	lda	tile_name_table, X
	sta	tile
	lda	tile_attr_table, X
	sta	tile+1	

	jsr	draw_tile
	inc	tile_pos
	jmp	.loop

.done:	jsr	ppu_on		
	rts


draw_tile:
screen_pos .equ	tmp16
	ldx	tile_pos
	mov	tile_pos_table_2, X, screen_pos+1
	mov	tile_pos_table_1, X, screen_pos

	add16	screen_pos, #$20C0

	lda	screen_pos
	asl	a
	lda	screen_pos+1
	rol	a
	and	#%00000111
	asl	a
	asl	a
	asl	a
	sta	tmp16_2+1
	lda	screen_pos
	and	#%00011100
	lsr	a
	lsr	a
	ora	tmp16_2+1
	adc	#$C0	

	sta	tmp
	lda	screen_pos+1
	and	#%11111100
	clc
	adc	#$3	
	sta	$2006		; set address of thing
	tay
	lda	tmp
	sta	$2006	
	ldx	$2007		; invalid data
	ldx	$2007		; correct data
	sty	$2006		; reset address
	sta	$2006

	lda	screen_pos	; find the bit
	and	#%01000010
	bne	.test1
	lda	tile+1
	and	#%00000011
	sta	tmp
	txa
	ora	tmp
	sta	$2007		; set the color
	jmp	.update_tile

.test1:	cmp	#%00000010
	bne	.test2
	lda	tile+1
	and	#%00001100
	sta	tmp
	txa
	ora	tmp
	sta	$2007
	jmp	.update_tile

.test2:	cmp	#%01000000
	bne	.test3
	lda	tile+1
	and	#%00110000
	sta	tmp
	txa
	ora	tmp
	sta	$2007
	jmp	.update_tile

.test3:	lda	tile+1
	and	#%11000000
	sta	tmp
	txa
	ora	tmp
	sta	$2007
	

.update_tile:						
	lda	tmp16+1
	sta	$2006
	lda	tmp16
	sta	$2006
	lda	tile
	sta	$2007		; update the tile

	add16	tmp16, #1	; next part (right)
	lda	tmp16+1
	sta	$2006
	lda	tmp16
	sta	$2006
	inc	tile
	lda	tile
	sta	$2007		; update the tile

	add16	tmp16, #$20	; next part (down)
	lda	tmp16+1
	sta	$2006
	lda	tmp16
	sta	$2006
	lda	tile
	clc
	adc	#$10
	sta	tile
	sta	$2007		; update the tile

	add16	tmp16, #$FFFF	; last part (left)
	lda	tmp16+1
	sta	$2006
	lda	tmp16
	sta	$2006
	dec	tile
	lda	tile
	sta	$2007		; update the tile

	rts

