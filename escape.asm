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
	.bank	0
	.org	$8000
		
	.include "rle.asm"			
	.include "joystick.asm"	
	.include "guy.asm"	
	.include "load-draw-level.asm"
	

	.bank	1
	.org	$A000

		
	.bank	2
	.org	$C000
		
	.include "interrupts.asm"

		
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

	.include "palettes.asm"	
		
	jsr	vwait
	jsr	vwait


	jsr	choose_level
	
	jsr	vwait
	
ppu_on:	
	debug_p ds_ppu
	jsr	vwait
	lda	#%10000000
 	sta	$2000	
	jsr	vwait
	lda	#%00011110
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
	

	
vwait:	
	lda	$2002
	bpl	vwait

	rts



init_sprite_memory:
	ldx	#$FF
.loop:	beq	.end	
	mov	#$FF, sprite, X
	dex
.end:	rts


	
		
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
ds_nmi:	.db	"nmi",0
ds_x:	.db	"x",0
ds_y:	.db	"y",0
ds_i:	.db	"i",0
ds_tmpaddr:	.db	"tmp_addr",0
ds_tiles:	.db	"tiles",0
ds_draw_guy	.db	"draw_guy",0

			
;;; vectors
	.bank	3
	.org	$FFFA
	.dw	nmi,start,intr


	.bank	4

	.incbin "escape.chr"
	.incbin "debug.chr"
