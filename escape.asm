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
debug_port:	.ds 1

	
tile_pos: .ds	1
tile:	.ds	2
tiles:	.ds	180

new_tile:	.ds	1
	
target:	.ds	1
replacement:	.ds	1
	
level_num:	.ds	1
		
gx:	.ds	1
gy:	.ds	1
gd:	.ds	1
tx:	.ds	1
ty:	.ds	1
td:	.ds	1
ttx:	.ds	1
tty:	.ds	1
newx:	.ds	1
newy:	.ds	1
newd:	.ds	1
destx:	.ds	1
desty:	.ds	1
doswap:	.ds	1
	
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

sprite_dma_ok:	.ds	1		
cur_joy_state:	.ds	1
last_joy_state:	.ds	1
vwait_expected:	.ds	1
nmi_finished:	.ds	1
				
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
	.include "level.asm"
	.include "guy.asm"	
	.include "load-draw-level.asm"
	.include "ppu.asm"

	.bank	1
	.org	$A000

		
	.bank	2
	.org	$C000
		
	.include "interrupts.asm"

		
start:	sei

	jsr	vwait	
	jsr	ppu_off
	jsr	init_sprite_memory

	mov	#0,last_joy_state
		
	debug_p	ds_begin
	
	jsr	vwait	
	jsr	vwait

	jsr	zero_ppu_memory	

;;; draw item

	sta	$2005
	sta	$2005

	.include "palettes.asm"	
		
	mov	#1, level_num
	jsr	choose_level
	
;;; ppu on
	jsr	ppu_on
	
	
main_loop:
 	jsr	vwait
	jsr	handle_joy
	jmp	main_loop

	
choose_level:
	lda	level_num
	debug_num
	
	bne	.l1
	mov16	#sample_level01, level_addr
	jmp	.go
.l1:	lda	level_num
	cmp	#1
	bne	.l2
	mov16	#sample_level01, level_addr
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
	jsr	draw_level

	rts
	

	
vwait:
	mov	#1,vwait_expected
	mov	#0,nmi_finished
.vwait_in:
	lda	$2002
	bpl	.vwait_in
	mov	#0,vwait_expected

	lda	nmi_finished
	bne	.ok
	debug_p ds_nmi_not_fired	
.ok:	
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


	.if	debug
ds_begin .db	"begin",0
ds1:	.db	"rledecode",0
ds_ppu_off:	.db "ppu_off",0
ds_ppu_on:	.db	"ppu_on",0
ds_run:	.db	"run",0
ds_antirun:	.db	"arun",0
ds_nmi:	.db	"nmi",0
ds_x:	.db	"x",0
ds_y:	.db	"y",0
ds_i:	.db	"i",0
ds_tmpaddr:	.db	"tmp_addr",0
ds_tiles:	.db	"tiles",0
ds_draw_guy	.db	"draw_guy",0
ds_load_level	.db	"load level",0
ds_draw_level	.db	"draw level",0
ds_late_vwait	.db	"*** missed vwait deadline! ***",0
ds_nmi_not_fired .db	"*** NMI didn't fire after vwait! ***",0
ds_start_pressed .db	"START pressed",0
ds_zero_ppu_memory .db	"zeroing some PPU memory",0
ds_update_scroll .db	"update scroll from guy",0
ds_move_up	.db	"moving guy UP",0
ds_move_left	.db	"moving guy LEFT",0
ds_move_right	.db	"moving guy RIGHT",0
ds_move_down	.db	"moving guy DOWN",0
ds_s1_s0	.db	"s0->s1?",0
ds_s1_s2	.db	"s2->s1?",0
ds_tileat	.db	"tileat",0
ds_xy_to_index	.db	"xy_to_index",0
ds_plain_move	.db	"plain_move",0
ds_no_move:	.db	"no_move",0
	.endif
									
;;; vectors
	.bank	3
	.org	$FFFA
	.dw	nmi,start,intr


	.bank	4

	.incbin "escape.chr"
	.incbin "debug.chr"
