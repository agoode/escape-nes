load_level:
	debug_p ds_load_level
	mov	#0,safe_to_draw
	mov	#0, tmp_size+1
	mov	#dir_down, gd

	mov16	level_addr, idx16
	ldy	#0
	mov	[idx16], Y, debug_str
	iny
	mov	[idx16], Y, debug_str
	iny
	mov	[idx16], Y, debug_str
	iny
	mov	[idx16], Y, debug_str
	mov	#0, debug_str
	ldy	#15		; ESXL + width + height + MSB of size of title
	mov	[idx16], Y, tmp_size	; size of title string
	debug_num
	add16	idx16, #16		; move to start of title

	;; copy the title string
	strcpyp2c	idx16, title, tmp_size
	debug_p	title

	add16	idx16, tmp_size	; move past the title string
	ldy	#3		; MSB of size of author
	mov	[idx16], Y, tmp_size ; size of author string
	add16	idx16, #4	; move to start of author

	;; copy the author string
	strcpyp2c	idx16, author, tmp_size
	debug_p	author

	add16	idx16, tmp_size	; move past the author string

	ldy	#3		; MSB of guy x
	mov	[idx16], Y, gx
	add16	idx16, #4
	ldy	#3		; MSB of guy y
	mov	[idx16], Y, gy
	add16	idx16, #4

	jsr	update_scroll_from_guy
		
	;; start rledecoding
 	mov16	#tiles, tmp_addr
	jsr	rledecode


	debug_p	ds_tiles
; 	mov	#tiles, debug_num
; 	mov	(#tiles)+1, debug_num
	ldx	#0
	ldy	#0
.tile_print:	
	lda	tiles, X
	adc	#32
	sta	debug_str
	iny
	tya
	cmp	#18
	bne	.no_newline
	mov	#10, debug_str
	ldy	#0
.no_newline:
	inx
	txa
	cmp	#180
	bne	.tile_print
	mov	#0, debug_str
	
	mov16	#otiles, tmp_addr
  	jsr	rledecode
	mov16	#dests, tmp_addr
 	jsr	rledecode
	mov16	#flags, tmp_addr
 	jsr	rledecode

	mov	#1,safe_to_draw
	rts
		
	
draw_level:
; 	jsr	ppu_off
; 	jsr	zero_ppu_memory
;	debug_p ds_draw_level
	;; assumes load_level just called

	lda	#0
	sta	tile_pos

.loop:	lda	tile_pos
	cmp	#180
	beq	.done

	jsr	update_tile_buffer
.next:	
	inc	tile_pos
	jmp	.loop

.done:
;	jsr	ppu_on
	rts





update_tile_buffer:	
	;; figure out the tile
	ldx	tile_pos
	mov	tile_pos_table_2, X, screen_pos+1
	mov	tile_pos_table_1, X, screen_pos

	;; get the tile
	lda	tiles, X
	tax
	lda	tile_name_table, X
	sta	tile
	lda	tile_attr_table, X
	sta	tile+1	


	;; set update flag
	debug_p	ds_tiles_changed
	lda	tile_pos
	ldx	num_tiles_changed
	sta	tiles_changed, X
	inx
	stx	num_tiles_changed
	debug_num
	stx	debug_port

	;; load attribute table buffer entry
	tax
	lda	tile_index_to_attr_buffer, X
	tay
	lda	attr_buffer, Y
	tax

	;; get the PPU address for nametable spot
	add16	screen_pos, #$20C0

	;; x now has the existing attribute table entry
	;; and y has the offset into the attr_buffer
	;; so that we can update the bits we need
	lda	screen_pos	; find the bit
	and	#%01000010
	bne	.test1

	;; case 1
	lda	tile+1
	and	#%00000011
	sta	tmp
	txa
	and	#%11111100
	ora	tmp
	sta	attr_buffer, Y		; set the color
	jmp	.done


.test1:	cmp	#%00000010
	bne	.test2

	;; case 2
	lda	tile+1
	and	#%00001100
	sta	tmp
	txa
	and	#%11110011
	ora	tmp
	sta	attr_buffer, Y
	jmp	.done

.test2:	cmp	#%01000000
	bne	.test3

	;; case 3
	lda	tile+1
	and	#%00110000
	sta	tmp
	txa
	and	#%11001111
	ora	tmp
	sta	attr_buffer, Y
	jmp	.done

.test3:	lda	tile+1

	;; case 4
	and	#%11000000
	sta	tmp
	txa
	and	#%00111111
	ora	tmp
	sta	attr_buffer, Y
	

.done:	
	rts



copy_some_tiles_to_ppu:
	lda	#0
	sta	tiles_drawn

.check_if_work:	
	lda	num_tiles_changed
	bne	.draw_loop
	rts

.draw_loop:
	lda	tiles_drawn
	cmp	#4
	bne	.continue
	rts
	
.continue:
	;; figure out the tile
	ldx	num_tiles_changed
	stx	debug_port
	dex
	lda	tiles_changed, X
	tax
	stx	debug_port
	mov	tile_pos_table_2, X, screen_pos+1
	mov	tile_pos_table_1, X, screen_pos

	;; get the tile
	lda	tiles, X
	tax
	lda	tile_name_table, X
	sta	tile

	
	;; load attribute table buffer entry
	tax
	lda	tile_index_to_attr_buffer, X
	tay
	lda	attr_buffer, Y
	tax
	
.update_tile:
	;; actually write into the nametable (2x2 tiles)
	lda	screen_pos+1
	sta	$2006
	lda	screen_pos
	sta	$2006
	lda	tile
	sta	$2007		; update the tile

	add16	screen_pos, #1	; next part (right)
	lda	screen_pos+1
	sta	$2006
	lda	screen_pos
	sta	$2006
	inc	tile
	lda	tile
	sta	$2007		; update the tile

	add16	screen_pos, #$20	; next part (down)
	lda	screen_pos+1
	sta	$2006
	lda	screen_pos
	sta	$2006
	lda	tile
	clc
	adc	#$10
	sta	tile
	sta	$2007		; update the tile

	add16	screen_pos, #$FFFF	; last part (left)
	lda	screen_pos+1
	sta	$2006
	lda	screen_pos
	sta	$2006
	dec	tile
	lda	tile
	sta	$2007		; update the tile



	dec	num_tiles_changed
	inc	tiles_drawn
	jmp	.check_if_work
.done:
	
	rts
