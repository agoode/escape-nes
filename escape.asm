	.list

	.include "arg.mac"
	.include "common.mac"
	.include "tiles.mac"
		
;;; items
	.inesprg 2
	.ineschr 1
	.inesmir 3
	.inesmap 4


	.zp
debug_str:	.ds 1
debug_num:	.ds 1
debug_tmp:	.ds 1
debug_tmp_2:	.ds 1
tile_pos: .ds	1
tile:	.ds	2
tiles:	.ds	180

level_num:	.ds	1
	
gx:	.ds	1
gy:	.ds	1
gd:	.ds	1

idx16:	.ds	2
tmp:	.ds	1
tmp_2:	.ds	1
tmp_3:	.ds	1
tmp_4:	.ds	1
tmp_5:	.ds	1
tmp16:	.ds	2
tmp16_2: .ds	2
tmp_size: .ds	2
tmp_addr: .ds	2

x_scroll: .ds	1
	
level_addr:	.ds	3

		
		
	.bss

sprite:	.ds	256
otiles: .ds	180
dests:	.ds	180
flags:	.ds	180
title:	.ds	36
author:	.ds	20
		

	
;;; initialize
	.code
	.bank	1
	.org	$8000
	

		
	.bank	2
	.org	$C000

intr:	sei
	rti
	
start:	sei
	mov	#0, level_num

start2:		
	lda	#0
	sta	$2000
	sta	$2001

	jsr	init_sprite_memory
	
	debug_p	ds_begin
	
	jsr	vwait	
	jsr	vwait
	jsr	vwait	
	jsr	vwait

	

;;; draw item
	jsr	vwait

	lda	#$3f
	sta	$2006
	lda	#$00
	sta	$2006
	sta	$2005
	sta	$2005

;;; palette 0
	lda	#$0e		; black
	sta	$2007
	lda	#$2d		; 50gray
	sta	$2007
	lda	#$3d		; 25gray
	sta	$2007
	lda	#$38		; orange
	sta	$2007

;;; palette 1
	lda	#$0e
	sta	$2007
	lda	#$16		; red
	sta	$2007
	lda	#$3d		; gray
	sta	$2007
	lda	#$28		; yellow
	sta	$2007
	
	
;;; palette 2
	lda	#$0e		; black
	sta	$2007
	lda	#$12		; blue
	sta	$2007
	lda	#$3D		; gray
	sta	$2007
	lda	#$17		; brownish
	sta	$2007
	
	
;;; palette 3
	lda	#$0e		; black
	sta	$2007
	lda	#$19		; green
	sta	$2007
	lda	#$3d		; gray
	sta	$2007
	lda	#$12		; blue
	sta	$2007

	
;;; sprite palette 1
	lda	#$3f
	sta	$2006
	lda	#$11
	sta	$2006
	lda	#$18		; brown
	sta	$2007
	lda	#$36		; pink
	sta	$2007
	lda	#$2C		; blue
	sta	$2007
	
		
	jsr	vwait
	jsr	vwait


	jsr	choose_level
	
	jsr	vwait
	
ppu_on:	
	debug_p ds_ppu
	jsr	vwait
	lda	#%00000000
 	sta	$2000
	lda	#%00011010
 	sta	$2001

main_loop:
	jsr	handle_joy
	jsr	vwait
	jmp	main_loop

	
choose_level:
	lda	level_num
	bne	.l1
	mov16	#sample_level01, level_addr
	jmp	.go
.l1:	lda	level_num
	cmp	#1
	bne	.l2
	mov16	#sample_level02, level_addr
	jmp	.go
.l2:	lda	level_num
	cmp	#2
	bne	.l3
	mov16	#sample_level02, level_addr
	jmp	.go
.l3:	lda	level_num
	cmp	#3
	bne	.l4
	mov16	#sample_level03, level_addr
	jmp	.go
.l4:	lda	level_num
	cmp	#4
	bne	.l5
	mov16	#sample_level04, level_addr
	jmp	.go
.l5:	lda	level_num
	cmp	#5
	bne	.l6
	mov16	#sample_level05, level_addr
	jmp	.go
.l6:	lda	level_num
	cmp	#6
	bne	.l7
	mov16	#sample_level06, level_addr
	jmp	.go
.l7:	lda	level_num
	cmp	#7
	bne	.l8
	mov16	#sample_level07, level_addr
	jmp	.go
.l8:	lda	level_num
	cmp	#8
	bne	.l9
	mov16	#sample_level08, level_addr
	jmp	.go
.l9:	lda	level_num
	cmp	#9
	bne	.l10
	mov16	#sample_level09, level_addr
	jmp	.go
.l10:	lda	level_num
	cmp	#10
	bne	.l11
	mov16	#sample_level10, level_addr
	jmp	.go
.l11:	mov16	#sample_level11, level_addr
		
.go:	
	jsr	load_level
	jsr	draw_guy

	jsr	vwait
	jsr	draw_level

	rts
	
	
handle_joy:
	;; joystick
	lda	#1
	sta	$4016
	lda	#0
	sta	$4016

	lda	$4016
	lda	$4016
	lda	$4016
	
	lda	$4016
	and	#%00000001	; start
	beq	.j_up
	inc	level_num
	lda	level_num
	cmp	#12
	bne	.continue
	lda	#0
	sta	level_num
	
.continue
	jmp	start2
	
.j_up:	
	lda	$4016
	and	#%00000001
	beq	.j_down		; up
 	mov	#dir_up, gd
	jsr	draw_guy

.j_down:
	lda	$4016
	and	#%00000001
	beq	.j_left		; down
 	mov	#dir_down, gd
	jsr	draw_guy

.j_left:
	lda	$4016
	and	#%00000001
	beq	.j_right
  	mov	#dir_left, gd
 	jsr	draw_guy

				; left
.j_right:
	lda	$4016
	and	#%00000001
	beq	.done
 	mov	#dir_right, gd
	jsr	draw_guy
				; right
.done:	
	rts

	
vwait:	
	lda	$2002
	bpl	vwait

	lda	#0
	sta	$2006
	sta	$2006
	lda	x_scroll
	sta	$2005
	lda	#0
	sta	$2005

	lda	#sprite/$100	; sprite
	sta	$4014
	rts


draw_level:
	;; assumes load_level just called
	mov	#0, tile_pos
.loop:	lda	tile_pos
	cmp	#180
	beq	.done
	bit	#%00000100
	bne	.continue
	jsr	vwait
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
		
.done:	rts


init_sprite_memory:
	ldx	#$FF
.loop:	beq	.end	
	mov	#$FF, sprite, X
	dex
.end:	rts


	
draw_guy:
	debug_p	ds_draw_guy
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
	sta	debug_num
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



load_level:
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
	mov	#tiles, debug_num
	mov	(#tiles)+1, debug_num
	ldx	#0
.tile_print:	
	mov	tiles, X, debug_num
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
		
	

rledecode:
run	.equ tmp
size	.equ tmp_2
bytes	.equ tmp_3
char	.equ tmp_4

	debug_p	ds1
	debug_p ds_tmpaddr
	lda	tmp_addr
	sta	debug_num
	lda	tmp_addr+1
	sta	debug_num
	;; take idx16, read from it and advance it, and store
	;; result in place pointed by tmp_addr
	mov	#180, size	; size of map
	ldx	#0
	ldy	#0
	mov	[idx16], Y, bytes

	inc16	idx16

.loop:	
	;; read a byte to determine run
	mov	[idx16], Y, run
	inc16	idx16
	lda	run
	bne	.run
	jmp	.anti_run	; if 0, anti-run
.run:	
	;; run
	debug_p	ds_run
	mov	#0, char	; set char to 0
	lda	bytes		; check if bytes == 0
	beq	.in_run_loop	; skip and write zeros if bytes == 0

	mov	[idx16], Y, char ; read a char, since bytes != 0
	inc16	idx16
.in_run_loop:
	debug_p	ds_x
	stx	debug_num
	txa
	tay
	mov	char, [tmp_addr], Y ; write the content of the run
	ldy	#0
	inx
	dec	size
	dec	run
	bne	.in_run_loop

	;; done?
	lda	size
	bne	.loop_trampoline
	jmp	.done
.loop_trampoline:
	jmp	.loop
	
.anti_run:
	debug_p	ds_antirun
	mov	[idx16], Y, run ; length of this anti-run
	inc16	idx16
.in_anti_run_loop:
	lda	[idx16], Y
	sta	debug_num
	sta	char
	txa
	tay
	lda	char
	sta	[tmp_addr], Y ; write the content of the run
	ldy	#0
			
	inc16	idx16
	inx
	dec	size
	dec	run
	bne	.in_anti_run_loop

	;; done?
	lda	size
	beq	.done
	jmp	.loop
	
	
.done:		
	rts
			
		
;;; some data
;;; data
	.data
	.bank	2
	.org	$C800
	.include "tiles.inc"


levels:	
	.dw sample_level01, \
	    sample_level02, \
	    sample_level03, \
	    sample_level04, \
	    sample_level05, \
	    sample_level06, \
	    sample_level07, \
	    sample_level08, \
	    sample_level09, \
	    sample_level10, \
	    sample_level11, \
	    sample_level12

sample_level01:	
	.incbin "levels/tutor01.esx"		
sample_level02:	
	.incbin "levels/tutor02.esx"		
sample_level03:	
	.incbin "levels/tutor03.esx"		
sample_level04:	
	.incbin "levels/tutor04.esx"		
sample_level05:	
	.incbin "levels/tutor05.esx"		
sample_level06:	
	.incbin "levels/tutor06.esx"		
sample_level07:	
	.incbin "levels/tutor07.esx"		
sample_level08:	
	.incbin "levels/tutor08.esx"		
sample_level09:	
	.incbin "levels/tutor09.esx"		
sample_level10:	
	.incbin "levels/tutor10.esx"		
sample_level11:	
	.incbin "levels/tutor11.esx"		
sample_level12:	
	.incbin "levels/tutor12.esx"		


ds_begin .db	"begin",0
ds1:	.db	"rledecode",0
ds_ppu:	.db	"ppu_on",0
ds_run:	.db	"run",0
ds_antirun:	.db	"arun",0
ds_x:	.db	"x",0
ds_y:	.db	"y",0
ds_i:	.db	"i",0
ds_tmpaddr:	.db	"tmp_addr",0
ds_tiles:	.db	"tiles",0
ds_draw_guy	.db	"draw_guy",0
			
;;; vectors
	.bank	3
	.org	$FFFA
	.dw	intr,start,intr


	.bank	4
	.incbin "escape.chr"
	.incbin "debug.chr"
