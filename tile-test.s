	.list

	.include "arg.mac"
	.include "common.mac"
	.include "tile-test.mac"
		
;;; items
	.inesprg 2
	.ineschr 1
	.inesmir 2
	.inesmap 4

	
	.zp
tile_pos: .ds	1
tile_offset: .ds	1
tile:	.ds	2

gx:	.ds	1
gy:	.ds	1
tiles:	.ds	180


tmp:	.ds	1
tmp16:	.ds	2
tmp16_2: .ds	2

	
		
	.bss

sprite:	.ds	256
otiles: .ds	180
dests:	.ds	180
flags:	.ds	180
title:	.ds	36
author:	.ds	20
		

	
;;; initialize
	.code
	.bank	2
	.org	$C000

start:	lda	#0
	sta	$2000
	sta	$2001
	sei
	
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
	
	
		
	jsr	vwait
	jsr	vwait




	jsr	vwait
        set_tile tile_brick, #0, #0
        set_tile tile_red, #1, #0
        set_tile tile_blue, #2, #0
        set_tile tile_gray, #3, #0
        set_tile tile_green, #4, #0
        set_tile tile_exit, #5, #0
        set_tile tile_hole, #6, #0
        set_tile tile_yellow, #7, #0
        set_tile tile_laser, #8, #0
        set_tile tile_spot, #9, #0
        set_tile tile_stop, #10, #0
        set_tile tile_right, #11, #0
        set_tile tile_left, #12, #0
        set_tile tile_up, #13, #0
        set_tile tile_down, #14, #0
        set_tile tile_rough, #15, #0
        set_tile tile_elec, #16, #1
        set_tile tile_on, #17, #1
        set_tile tile_off, #18, #1
        set_tile tile_tele, #19, #1
        set_tile tile_break, #20, #1
        set_tile tile_lr, #21, #1
        set_tile tile_ud, #22, #1
        set_tile tile_0, #23, #1
        set_tile tile_1, #24, #1
        set_tile tile_w1, #25, #1
        set_tile tile_w2, #26, #1
        set_tile tile_w3, #27, #1
        set_tile tile_w4, #28, #1
        set_tile tile_w5, #29, #1
        set_tile tile_w6, #30, #1
        set_tile tile_ws, #31, #1
        set_tile tile_wb, #32, #2
        set_tile tile_wr, #33, #2
        set_tile tile_wg, #34, #2
        set_tile tile_blueup, #35, #2
        set_tile tile_bluedown, #36, #2
        set_tile tile_redup, #37, #2
        set_tile tile_reddown, #38, #2
        set_tile tile_greenup, #39, #2
        set_tile tile_greendown, #40, #2
        set_tile tile_blues, #41, #2
        set_tile tile_reds, #42, #2
        set_tile tile_greens, #43, #2
        set_tile tile_grays, #44, #2
        set_tile tile_bluehole, #45, #2
        set_tile tile_redhole, #46, #2
        set_tile tile_greenhole, #47, #2
        set_tile tile_blank, #48, #3
	
ppu_on:		
	jsr	vwait
	lda	#%00100000
 	sta	$2000
	lda	#%00011010
 	sta	$2001

	ldx	#0
end:
	jmp	end
	jsr	vwait
	lda	#0
	stx	$2005
	sta	$2005
	inx
	

	

	
vwait:	
	lda	$2002
	bpl	vwait

	lda	#0
	sta	$2005
	sta	$2005
	sta	$2006
	sta	$2006

	rts



draw_tile:
	mov	#0, tmp16+1
	mov	tile_pos, tmp16
	asl16	tmp16
	add16	tmp16, #$20C0
	mov	#0, tmp16_2+1
	mov	tile_offset, tmp16_2
	asl16	tmp16_2
	asl16	tmp16_2
	asl16	tmp16_2
	asl16	tmp16_2
	asl16	tmp16_2
	add16	tmp16, tmp16_2
		
	lda	tmp16
	asl	a
	lda	tmp16+1
	rol	a
	and	#%00000111
	asl	a
	asl	a
	asl	a
	sta	tmp16_2+1
	lda	tmp16
	and	#%00011100
	lsr	a
	lsr	a
	ora	tmp16_2+1
	adc	#$C0	

	ldx	#$23
	stx	$2006		; set address of thing
	sta	$2006	
	ldx	$2007		; invalid data
	ldx	$2007		; correct data
	ldy	#$23
	sty	$2006		; reset address
	sta	$2006

	lda	tmp16		; find the bit
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


;;; some data
	.data
	.bank	2
	.org	$C800
	.include "tile-test.inc"
		
	
;;; vectors
	.bank	3
	.org	$FFFA
	.dw	start,start,start


	.bank	4
	.incbin "escape.chr"
	.incbin "debug.chr"
