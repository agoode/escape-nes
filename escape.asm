	.list

	.include "arg.mac"
	.include "common.mac"
	.include "tiles.mac"
		
;;; items
	.inesprg 2
	.ineschr 1
	.inesmir 1
	.inesmap 4


	.zp
debug_str:	.ds 1
debug_port:	.ds 1

	
tile_pos: .ds	1
tile:	.ds	2
attr_buffer:	.ds	45
num_tiles_changed:	.ds	1

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
lx:	.ds	1
ly:	.ds	1
ld:	.ds	1
newx:	.ds	1
newy:	.ds	1
newd:	.ds	1
tnx:	.ds	1
tny:	.ds	1
goldx:	.ds	1
goldy:	.ds	1
tgoldx:	.ds	1
tgoldy:	.ds	1	
destx:	.ds	1
desty:	.ds	1
pulsex:	.ds	1
pulsey:	.ds	1
pulsed:	.ds	1
landon:	.ds	1
doswap:	.ds	1

ppu_safe: .ds	1

is_dead:.ds	1
is_won:	.ds	1
end_sound_made: .ds	1
		
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

screen_pos:	.ds	2

swap_tile_1:	.ds	1
swap_tile_2:	.ds	1

x_scroll: .ds	1
	
level_addr:	.ds	3

cur_joy_state:	.ds	1
last_joy_state:	.ds	1
tiles_drawn:	.ds	1
drawing_limit:	.ds	1
				
	.bss

sprite:	.ds	256
tiles:	.ds	180
otiles: .ds	180
dests:	.ds	180
flags:	.ds	180
title:	.ds	32
author:	.ds	32

tiles_changed:	.ds	180
dirty_tiles:	.ds	180

vwait_expected:	.ds	1
nmi_finished:	.ds	1

	
;;; initialize
	.code
	.bank	0
	.org	$8000
		
	.include "rle.asm"
	.include "joystick.asm"	
	.include "level.asm"
	.include "sound.asm"
	.include "guy.asm"	
	.include "load-draw-level.asm"
	.include "ppu.asm"

	.include "interrupts.asm"

		
start:	sei

	lda	#0
	sta	last_joy_state
	sta	num_tiles_changed
	
	jsr	ppu_off
	jsr	init_dirty_tiles

	debug_p	ds_begin
	
	jsr	vwait	
	jsr	vwait

	jsr	zero_ppu_memory

	;; 2A03!
	lda	#%00001111	; sound enable
	sta	$4015

	;; disable frame counter IRQ
	lda	#%01000000
	sta	$4017

;;; draw item

	sta	$2005
	sta	$2005

	.include "palettes.asm"	
		
	mov	#0, level_num
	jsr	choose_level

;;; ppu on
	cli
	jsr	ppu_on
	
	
main_loop:
 	jsr	vwait
	jsr	handle_joy
	lda	is_dead
	bne	.dead
	lda	is_won
	bne	.won
	jmp	main_loop

.dead:
	lda	end_sound_made
	bne	.no_laser_sound
	jsr	make_laser_sound
	jsr	draw_laser_beam
	lda	#1
	sta	end_sound_made
.no_laser_sound:	
	jmp	main_loop

.won:
	lda	end_sound_made
	bne	.no_exit_sound
	jsr	make_exit_sound
	draw_text_as_sprites	ds_winner
	lda	#1
	sta	end_sound_made
.no_exit_sound:	
	jmp	main_loop

	
	
choose_level:
	lda	level_num
	debug_num
	
	clc
	asl	A
	tax

	lda	levels,X
	sta	level_addr
	lda	levels+1,X
	sta	level_addr+1	
		
.go:	
	jsr	load_level
	jsr	draw_level

	rts
	

	
vwait:
; 	mov	#1,vwait_expected
; 	mov	#0,nmi_finished
.vwait_in:
	lda	$2002
	bpl	.vwait_in

; 	lda	nmi_finished
; 	bne	.ok
; 	debug_p ds_nmi_not_fired	
; .ok:	
	rts



init_sprite_memory:
	ldx	#0
	lda	#$FF
.loop:	dex
	beq	.end
	sta	sprite, X
	jmp	.loop
.end:
	sta	sprite
	rts


	
		
;;; some data
;;; data
	.data
	.bank	2
	.org	$C800

	.include "tiles.inc"
	.include "levels.asm"



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
ds_no_move	.db	"no_move",0
ds_tiles_changed .db	"tiles changed",0
ds_electric_off	.db	"turning electric off",0
ds_slide_push	.db	"slide push",0
ds_sphere_sliding .db	"sliding sphere...",0
ds_block_sliding .db	"sliding block...",0
ds_not_electric	.db	"not electric",0
ds_not_panel	.db	"not panel",0
ds_not_bpanel	.db	"not bpanel",0
ds_not_rpanel	.db	"not rpanel",0
ds_not_gpanel	.db	"not gpanel",0
ds_not_floor	.db	"not floor",0
ds_where	.db	"where?",0
ds_step_table	.db	"going into step table!",0
ds_swaptiles	.db	"swapping tiles",0
	.endif

	
ds_laser_beam	.db	"LASERED!",0
ds_winner	.db	"SUCCESS!",0
		

	.bank	1
	.org	$A000

		
	.bank	2
	.org	$C000
		
									
;;; vectors
	.bank	3
	.org	$FFFA
	.dw	nmi,start,intr


	.bank	4

	.incbin "escape.chr"
	.incbin "debug.chr"
