copy_string_to_ppu:	.macro
	;; address
	lda	#$20
	sta	$2006
	lda	\2
	sta	$2006

	ldx	#0
	stx	tmp
	clc
.loop\@:
	txa
	cmp	#31
	beq	.done\@

	lda	#' '
	ldy	tmp
	bne	.print\@	; padding
		
	lda	\1, X		; check for NUL
	bne	.print\@
	ldy	#1		; NUL
	sty	tmp
	lda	#' '

.print\@:
	adc	#$80
	sta	$2007

	inx
	jmp	.loop\@

.done\@:
	lda	#0
	.endm


	
	
load_level:
	debug_p ds_load_level
	jsr	mask_nmi

	lda	#0
	sta	is_dead
	sta	is_won
	sta	end_sound_made
	
	mov	#0, tmp_size+1
	mov	#dir_down, gd

	mov16	level_addr, idx16
	ldy	#0
; 	mov	[idx16], Y, debug_str
	iny
; 	mov	[idx16], Y, debug_str
	iny
; 	mov	[idx16], Y, debug_str
	iny
; 	mov	[idx16], Y, debug_str
; 	mov	#0, debug_str
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

	rts
		
	
draw_level:
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
    	jsr	ppu_off

	copy_string_to_ppu title, #$41
	copy_string_to_ppu author, #$81
	
	jsr	update_scroll_from_guy
	jsr	init_sprite_memory
	jsr	draw_guy

   	lda	#180
   	sta	drawing_limit
 	jsr	copy_some_tiles_to_ppu
	lda	#8
	sta	drawing_limit
  	jsr	ppu_on
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


	;; check if dirty already
	ldx	tile_pos
	lda	dirty_tiles, X
	bne	.skip_update

	lda	#1
	sta	dirty_tiles, X
		
	;; set update flag
; 	debug_p	ds_tiles_changed
	lda	tile_pos
	ldx	num_tiles_changed
	sta	tiles_changed, X
	inx
	stx	num_tiles_changed
; 	debug_num
; 	stx	debug_port

.skip_update:	
	
	;; load attribute table buffer entry
	ldx	tile_pos
	lda	tile_index_to_attr_buffer, X
	tay
	lda	attr_buffer, Y
	tax


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
;	lda	#%00011011
; 	sta	attr_buffer, Y
	rts



copy_some_tiles_to_ppu:
	lda	#0
	sta	tiles_drawn

.check_if_work:	
	ldx	num_tiles_changed
	bne	.draw_loop
	rts

.draw_loop:
	lda	tiles_drawn
	cmp	drawing_limit
	bne	.continue
	rts
	
.continue:
	;; figure out the tile
; 	ldx	num_tiles_changed
;	stx	debug_port
	dex			; already contains num_tiles_changed
	stx	num_tiles_changed ; store decremented value
	lda	tiles_changed, X
	sta	tile_pos
	tax
;	stx	debug_port
	mov	tile_pos_table_2, X, screen_pos+1
	mov	tile_pos_table_1, X, screen_pos

	;; clear dirty field
	mov	#0, dirty_tiles, X

	;; get the tile
	lda	tiles, X
	tax
	lda	tile_name_table, X
	sta	tile

	;; load attribute table buffer entry
	ldx	tile_pos
	lda	tile_index_to_attr_buffer, X
	tax
	lda	attr_buffer, X
	tay

	mov	attr_pos_table_2, X, $2006
	mov	attr_pos_table_1, X, $2006
	sty	$2007

	
.update_tile:
	;; actually write into the nametable (2x2 tiles)
	lda	screen_pos+1
	sta	$2006
	lda	screen_pos
	sta	$2006
	lda	tile
	sta	$2007		; update the tile

;	add16	screen_pos, #1	; next part (right)
;	lda	screen_pos+1
; 	sta	$2006
; 	lda	screen_pos
; 	sta	$2006
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
	adc	#$0F
	sta	tile
	sta	$2007		; update the tile

; 	add16	screen_pos, #$FFFF	; last part (left)
; 	lda	screen_pos+1
; 	sta	$2006
; 	lda	screen_pos
; 	sta	$2006
	inc	tile
	lda	tile
	sta	$2007		; update the tile


	


; 	dec	num_tiles_changed
	inc	tiles_drawn
	jmp	.check_if_work
.done:
	
	rts


init_dirty_tiles:
	lda	#0
	ldx	#180
.loop:	dex
	beq	.zero
	sta	dirty_tiles,X
	jmp	.loop
	
.zero:	sta	dirty_tiles	; X=0
	
	rts




