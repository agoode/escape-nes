travel:	.macro
	mov \1,tx
; 	debug_num
	mov \2,ty
; 	debug_num
	mov \3,td
; 	debug_num

	jsr	travel_func

	pha
	mov ttx,\4
; 	debug_num
	mov tty,\5
; 	debug_num
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
	stx	tty
	mov	tx,ttx
	jmp	.yes

	
.down:	lda	ty
	cmp	#9
	beq	.no

	tax
	inx
	stx	tty
	mov	tx,ttx
	jmp	.yes

	
.left:  lda	tx
	beq	.no

	tax
	dex
	stx	ttx
	mov	ty,tty
	jmp	.yes

	
.right: lda	tx
	cmp	#17
	beq	.no

	tax
	inx
	stx	ttx
	mov	ty,tty
	jmp	.yes



	
.no:	mov tx,ttx
	mov ty,tty
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
	tax
	lda	tiles, X
; 	debug_p ds_tileat
; 	debug_num
	rts

flagat:	.macro
	ldx	\1
	ldy	\2
	jsr	flagat_func
	.endm

flagat_func:
	jsr	xy_to_index
	tax
	lda	flags, X
	rts
	
destat:	.macro
	ldx	\1
	ldy	\2
	jsr	destat_func
	.endm

destat_func:
	jsr	xy_to_index
	tax
	lda	dests, X
	rts
	

xy_to_index:
; 	debug_p	ds_xy_to_index
	clc
	txa

.yloop:	dey
	bmi	.done
	adc	#18
	jmp	.yloop
.done:
; 	debug_num
	rts


where:	;; index is in A, put x and y in X and Y
	debug_p	ds_where
	tax
	ldy	#0
	sec
	debug_num

.loop:	sbc	#18
	bcc	.done

	iny
	tax
	jmp	.loop
	
.done:
; 	stx	debug_port
; 	sty	debug_port
	rts

	
settile: .macro
	ldx	\1
	ldy	\2
	mov	\3,new_tile
	jsr	settile_func
	.endm

settile_func:	
	jsr	xy_to_index
	sta	tile_pos
	tax
	lda	new_tile
	sta	tiles, X
	jmp	update_tile_buffer
	
swaptiles:	.macro
	mov	\1,swap_tile_1
	mov	\2,swap_tile_2
	jsr	swaptiles_func
	.endm

swaptiles_func:
	debug_p	ds_swaptiles
	ldx	#180
.loop:
	dex
	beq	.done

	lda	tiles, X

	cmp	swap_tile_1
	beq	.update1

	cmp	swap_tile_2
	beq	.update2

	jmp	.loop

.update1:
	lda	swap_tile_2
	jmp	.update
.update2:
	lda	swap_tile_1
.update:	
	sta	tiles, X
	stx	tile_pos
	jsr	update_tile_buffer
	ldx	tile_pos
	jmp	.loop

.done:
	rts
	

	
checkstepoff:
	ldx	gx
	ldy	gy
	jsr	tileat_func
	cmp	#T_TRAP1
	beq	.t_hole
	cmp	#T_TRAP2
	beq	.t_trap1

	rts

.t_hole:	
	mov	#T_HOLE,new_tile
	jmp	settile_func
.t_trap1
	mov	#T_TRAP1,new_tile
	jmp	settile_func


checkleavepanel:
	ldx	gx
	ldy	gy
	jsr	tileat_func
	cmp	#T_PANEL
	beq	.swap
	rts

.swap:	
	destat	gx,gy
	jmp	swapo

issphere:	.macro
	ldx	\1
	ldy	\2
	jsr	issphere_func
	.endm

issphere_func:
	jsr	tileat_func
	cmp	#T_SPHERE
	beq	.yes
	cmp	#T_BSPHERE
	beq	.yes
	cmp	#T_GSPHERE
	beq	.yes
	cmp	#T_RSPHERE
	beq	.yes

	;; no
	lda	#0
	rts
.yes:	lda	#1
	rts

	
realpanel:
	tax			; save the flag
	and	#TF_RPANELH
	beq	.not_rpanelh

	txa
	and	#TF_RPANELL
	beq	.is_gpanel

	lda	#T_RPANEL
	rts

.is_gpanel:
	lda	#T_GPANEL
	rts

		
.not_rpanelh:
	txa
	and	#TF_RPANELL
	beq	.is_panel

	lda	#T_BPANEL
	rts

.is_panel:	
	lda	#T_PANEL
	rts


swapo:
	;; index in A
	tax
	lda	tiles,X
	tay
	lda	otiles,X
	sta	tiles,X
	sta	new_tile
	tya
	sta	otiles,X

	stx	tile_pos
	jsr	update_tile_buffer

	;; crazy stuff
	ldx	tile_pos
	lda	flags,X
	tay			; save

	;; erase old flags
	and	#~(TF_HASPANEL | TF_OPANEL | TF_RPANELL  | TF_RPANELH |  TF_ROPANELL | TF_ROPANELH)
	sta	tmp

	;; swap panel bits
	tya
	and	#TF_HASPANEL	; if haspanel, set opanel (in parallel!)
	beq	.next1
	lda	tmp
	ora	#TF_OPANEL
	sta	tmp

.next1:
	tya
	and	#TF_OPANEL	; if opanel, set haspanel
	beq	.next2
	lda	tmp
	ora	#TF_HASPANEL
	sta	tmp

.next2:	
	tya
	and	#TF_RPANELL
	beq	.next3
	lda	tmp
	ora	#TF_ROPANELL
	sta	tmp

.next3:	
	tya
	and	#TF_RPANELH
	beq	.next4
	lda	tmp
	ora	#TF_ROPANELH
	sta	tmp
	
.next4:	
	tya
	and	#TF_ROPANELL
	beq	.next5
	lda	tmp
	ora	#TF_RPANELL
	sta	tmp
	
.next5:	
	tya
	and	#TF_ROPANELH
	beq	.next6
	lda	tmp
	ora	#TF_RPANELH
	sta	tmp
	
.next6:	
	;; finally, set!
	lda	tmp
	sta	flags,X
	rts




do_move:
step_table_target .equ tmp16
	mov	#0,doswap
	lda	newd
	sta	gd
	travel  gx,gy,newd,newx,newy
	bne	.continue	; check for actual movement

	;; no movement!
	jmp	no_move

.continue:
	debug_p	ds_step_table
	tileat  newx,newy
	sta	target
	asl	A

	tax
	debug_num
	lda	step_table, X
	sta	step_table_target
	inx
	lda	step_table, X
	sta	step_table_target+1

	jmp	[step_table_target]


panel_step:
	destat	newx,newy
	jsr	swapo	
plain_move:
	debug_p	ds_plain_move

	jsr	checkleavepanel
	jsr	checkstepoff
	
	
	mov	newx,gx
	debug_num
	mov	newy,gy
	debug_num

	jsr	make_step_sound
	
	jmp	update_scroll_from_guy

	
push_block:
	;; directional blocks can only go the correct way
	lda	target
	cmp	#T_LR
	beq	.lr
	cmp	#T_UD
	beq	.ud

	jmp	.next1

.lr:
	lda	newd
	cmp	#dir_up
	bne	.lr1
	jmp	no_move
.lr1:	cmp	#dir_down
	bne	.next1
	jmp	no_move

.ud:
	lda	newd
	cmp	#dir_left
	bne	.ud1
	jmp	no_move
.ud1:	cmp	#dir_right
	bne	.next1
	jmp	no_move

	
.next1:
	;; check to make sure the block can move
	travel	newx,newy,newd,destx,desty
	bne	.next1_1
	jmp	no_move

.next1_1:	
	;; check the TF_HASPANEL flag
	flagat	newx,newy
	and	#TF_HASPANEL
	beq	.replace_with_floor
	
	;; if it has it, then set the replacement to be the panel
	flagat	newx,newy
	jsr	realpanel
	sta	replacement
	jmp	.next2
	
	;; otherwise, T_FLOOR
.replace_with_floor:	
	mov	#T_FLOOR,replacement	

.next2:
	tileat	destx,desty
	cmp	#T_FLOOR
	bne	.next3
	;; floor
	settile	destx,desty,target
	settile	newx,newy,replacement
	jmp	plain_move

.next3:				; colored panels
	tileat	destx,desty
	cmp	#T_BPANEL
	beq	.colored_panel
	cmp	#T_RPANEL
	beq	.colored_panel
	cmp	#T_GPANEL
	beq	.colored_panel
	jmp	.next4

.colored_panel:
	lda	target
	cmp	#T_LR
	bne	.colored_panel1
	jmp	no_move
.colored_panel1:
	cmp	#T_UD
	bne	.colored_panel2
	jmp	no_move

.colored_panel2:	
	settile	destx,desty,target
	settile	newx,newy,replacement
	jmp	plain_move
	
.next4:				; electric
	tileat	destx,desty
	cmp	#T_ELECTRIC
	bne	.next5

	lda	target
	cmp	#T_LR
	bne	.next4_1
	jmp	no_move
.next4_1:	
	cmp	#T_UD
	bne	.next4_2
	jmp	no_move

.next4_2:	
	settile	newx,newy,replacement
	jsr	make_zap_sound	; block is zapped!
	jmp	plain_move

.next5:
	tileat	destx,desty	; grey into hole
	cmp	#T_HOLE
	bne	.next6
	lda	target
	cmp	#T_GREY
	beq	.next5_1
	jmp	no_move

.next5_1:	
	settile	destx,desty, #T_FLOOR
	settile	newx,newy,replacement
	jsr	make_hole_plug_sound
	jmp	plain_move

.next6:				; regular panel
	tileat	destx,desty
	cmp	#T_PANEL
	beq	.next6_1
	jmp	no_move

.next6_1:	
	
	lda	target
	cmp	#T_LR
	bne	.next6_2
	jmp	no_move
.next6_2:	
	cmp	#T_UD
	bne	.next6_3
	jmp	no_move
.next6_3:	
	settile	destx,desty,target
	settile	newx,newy,replacement
	jsr	plain_move
	
	;; special thing for panel (doswap in the C++ version)
	destat	destx,desty
	jmp	swapo



push_green:
	;; check to make sure the block can move
	travel	newx,newy,newd,destx,desty
	bne	.next1
	jmp	no_move

.next1:
	tileat	destx,desty
	cmp	#T_FLOOR
	bne	no_move

	;; set stuff
	settile	destx,desty, #T_BLUE
	settile newx,newy, #T_FLOOR


	jmp	plain_move


electric_off:
	settile	newx,newy, #T_OFF
	
	;; iterate over all
	debug_p	ds_electric_off
	ldx	#180
.e_loop:
	dex
	beq	.done
	lda	tiles, X
	cmp	#T_ELECTRIC
	beq	.update
	jmp	.e_loop
.update:
	lda	#T_FLOOR
	sta	tiles, X
	stx	tile_pos
	jsr	update_tile_buffer
	ldx	tile_pos
	jmp	.e_loop
.done:
	jmp	make_electric_off_sound
	

no_move:
	debug_p	ds_no_move
	jmp	make_no_move_sound


slide_push:
	debug_p ds_slide_push
.while:	
	issphere newx,newy
	beq	.wend
	travel	newx,newy,newd,tnx,tny
	beq	.wend
	issphere tnx,tny
	beq	.wend

	debug_p	ds_sphere_sliding
	mov	tnx,newx
	mov	tny,newy
	tileat	tnx,tny
	sta	target
	debug_num
	jmp	.while
		
.wend:	
	mov	newx,goldx
	mov	newy,goldy

	;; remove gold block
	flagat	goldx,goldy
	and	#TF_HASPANEL
	beq	.not_panel

	;; set replacement to be panel
	flagat	goldx,goldy
	jsr	realpanel
	sta	new_tile
	ldx	goldx
	ldy	goldy
	jsr	settile_func
	jmp	.next1

.not_panel:
	;; replace with floor
	settile goldx,goldy,#T_FLOOR

.next1:
.while2:	
	travel	goldx,goldy,newd,tgoldx,tgoldy
	bne	.slide_block
	jmp	.wend2

.slide_block:	
	debug_p	ds_block_sliding
	tileat	tgoldx,tgoldy
	cmp	#T_ELECTRIC
	beq	.no_while2_break

	cmp	#T_PANEL
	beq	.no_while2_break

	cmp	#T_BPANEL
	beq	.no_while2_break

	cmp	#T_RPANEL
	beq	.no_while2_break

	cmp	#T_GPANEL
	beq	.no_while2_break

	cmp	#T_FLOOR
	beq	.no_while2_break

	jmp	.wend2

.no_while2_break:	
	
	ldx	tgoldx
	stx	goldx
	ldy	tgoldy
	sty	goldy

	cmp	#T_ELECTRIC
	beq	.wend2

	jmp	.while2

.wend2:
	;; goldx is dest, newx is source
	lda	goldx
	cmp	newx
	bne	.next2
	lda	goldy
	cmp	newy
	bne	.next2

	;; else, didn't move, put it back
 	settile	newx,newy,target
	jmp	no_move


.next2:
	tileat	goldx,goldy
	sta	landon
	lda	#0
	sta	doswap

	;; untrigger from source
	flagat	newx,newy
	tax
	and	#TF_HASPANEL
	bne	.next3
	txa
	jsr	realpanel
	cmp	#T_PANEL	; if panel, do swap, or if the sphere matches
	beq	.set_doswap

	tax
	lda	target
	cmp	#T_GSPHERE
	beq	.gsphere

	cmp	#T_RSPHERE
	beq	.rsphere

	cmp	#T_BSPHERE
	beq	.bsphere

	jmp	.next3

.gsphere:
	txa
	cmp	#T_GPANEL
	beq	.set_doswap
	jmp	.next3

.rsphere:	
	txa
	cmp	#T_RPANEL
	beq	.set_doswap
	jmp	.next3

.bsphere:	
	txa
	cmp	#T_BPANEL
	beq	.set_doswap
	jmp	.next3
	

.set_doswap:
	mov	#1,doswap

.next3:
	lda	landon

	;; only the correct color sphere can trigger the colored panels
	cmp	#T_GPANEL
	beq	.gsphere2

	cmp	#T_BPANEL
	beq	.bsphere2

	cmp	#T_RPANEL
	beq	.rsphere2

	cmp	#T_PANEL
	beq	.do_gold_swapo

	jmp	.next4

.gsphere2:
	lda	target
	cmp	#T_GSPHERE
	beq	.do_gold_swapo

	jmp	.next4

.bsphere2:
	lda	target
	cmp	#T_BSPHERE
	beq	.do_gold_swapo

	jmp	.next4

.rsphere2:
	lda	target
	cmp	#T_RSPHERE
	beq	.do_gold_swapo

	jmp	.next4
	
	
.do_gold_swapo:
	destat	goldx,goldy
	jsr	swapo

.next4:
	settile	goldx,goldy,target

	lda	landon
	cmp	#T_ELECTRIC
	bne	.next5

	;; gold is zapped, cover some corner case too
	settile	goldx,goldy,#T_ELECTRIC
	jsr	make_zap_sound
	

.next5:	
	lda	doswap
	bne	.no_swap

	;; swap
	destat	newx,newy
	jsr	swapo
	
.no_swap:	
	jmp	make_slide_sound




	
transport_guy:
	destat	newx,newy
	jsr	where
	stx	newx
	sty	newy

	jsr	plain_move

	tileat	newx,newy
	cmp	#T_PANEL
	bne	.no_swap
	;; swap
	destat	newx,newy
	jsr	swapo

.no_swap:		
	jmp	make_transport_sound


	
break_block:
	settile newx,newy,#T_FLOOR
	jmp	make_break_sound

t_0_hit:
	swaptiles #T_UD,#T_LR
	settile	newx,newy,#T_1
	jmp	make_swap_sound

t_1_hit:
	swaptiles #T_UD,#T_LR
	settile	newx,newy,#T_0
	jmp	make_swap_sound

send_pulse:
	mov	#dir_up, pulsed
	jsr	.send_pulse_helper
	mov	#dir_down, pulsed
	jsr	.send_pulse_helper
	mov	#dir_left, pulsed
	jsr	.send_pulse_helper
	mov	#dir_right, pulsed
	jsr	.send_pulse_helper
	
	jmp	make_pulse_sound


.send_pulse_helper:
	mov	newx,pulsex
	mov	newy,pulsey

.while:	travel	pulsex,pulsey,pulsed,pulsex,pulsey
	bne	.continue
	jmp	.wend

.continue:	
	tileat	pulsex,pulsey
	cmp	#T_BLIGHT
	beq	.t_blight
	cmp	#T_RLIGHT
	beq	.t_rlight
	cmp	#T_GLIGHT
	beq	.t_glight
	cmp	#T_NS
	beq	.t_ns
	cmp	#T_WE
	beq	.t_we
	cmp	#T_NW
	beq	.t_nw
	cmp	#T_SW
	beq	.t_sw
	cmp	#T_NE
	beq	.t_ne
	cmp	#T_SE
	bne	.not_se
	jmp	.t_se
.not_se:	
	jmp	.wend

.t_blight:
	swaptiles #T_BUP, #T_BDOWN
	jmp	.wend
.t_rlight:
	swaptiles #T_RUP, #T_RDOWN
	jmp	.wend
.t_glight:
	swaptiles #T_GUP, #T_GDOWN
	jmp	.wend

.t_ns:
	lda	pulsed
	cmp	#dir_up
	bne	.t_ns1
	jmp	.while
.t_ns1:		
	cmp	#dir_down
	bne	.t_ns2
	jmp	.while
.t_ns2:	
	jmp	.wend

	
.t_we:
	lda	pulsed
	cmp	#dir_left
	bne	.t_we1
	jmp	.while
.t_we1:	
	cmp	#dir_right
	bne	.t_we2
	jmp	.while
.t_we2:	
	jmp	.wend
	
.t_nw:
	lda	pulsed
	cmp	#dir_down
	beq	.dir_left
	
	cmp	#dir_right
	beq	.dir_up
	
	jmp	.wend
	
.t_sw:
	lda	pulsed
	cmp	#dir_up
	beq	.dir_left
	
	cmp	#dir_right
	beq	.dir_down
	
	jmp	.wend
	
.t_ne:
	lda	pulsed
	cmp	#dir_down
	beq	.dir_right
	
	cmp	#dir_left
	beq	.dir_up
	
	jmp	.wend
	
.t_se:
	lda	pulsed
	cmp	#dir_up
	beq	.dir_right
	
	cmp	#dir_left
	beq	.dir_down
	
	jmp	.wend
	
.dir_left:
	mov	#dir_left,pulsed
	jmp	.while

.dir_right:
	mov	#dir_right,pulsed
	jmp	.while

.dir_up:
	mov	#dir_up,pulsed
	jmp	.while

.dir_down:
	mov	#dir_down,pulsed
	jmp	.while

	
.wend:	

	rts

	
set_end_states:
	;; dead or won?
	lda	#0
	sta	is_dead
	sta	is_won

	;; check lasers
	mov	#dir_up, ld
	jsr	.laser_helper
	lda	is_dead
	bne	.dead
	
	mov	#dir_down, ld
	jsr	.laser_helper
	lda	is_dead
	bne	.dead

	mov	#dir_left, ld
	jsr	.laser_helper
	lda	is_dead
	bne	.dead

	mov	#dir_right, ld
	jsr	.laser_helper
	lda	is_dead
	bne	.dead

	;; check for win
	tileat	gx,gy
	cmp	#T_EXIT
	beq	.won

	rts
	
.won:
	lda	#1
	sta	is_won
	rts

.dead:	
	rts


.laser_helper:	
	lda	gx
	sta	lx
	lda	gy
	sta	ly

.while:	travel	lx,ly,ld,lx,ly
	beq	.not_dead
	tileat	lx,ly
	cmp	#T_LASER
	bne	.not_laser

	;; Zap.
	lda	ld
	jsr	dir_reverse
	sta	ld
	lda	#1
	sta	is_dead
	rts
	
.not_laser:
	;; tileat still in A
	cmp	#T_FLOOR
	beq	.while
	cmp	#T_ELECTRIC
	beq	.while
	cmp	#T_ROUGH
	beq	.while
	cmp	#T_RDOWN
	beq	.while
	cmp	#T_GDOWN
	beq	.while
	cmp	#T_BDOWN
	beq	.while
	cmp	#T_TRAP2
	beq	.while
	cmp	#T_TRAP1
	beq	.while
	cmp	#T_PANEL
	beq	.while
	cmp	#T_BPANEL
	beq	.while
	cmp	#T_GPANEL
	beq	.while
	cmp	#T_RPANEL
	beq	.while
	cmp	#T_BLACK
	bne	.not_black
	jmp	.while
.not_black:	
	cmp	#T_HOLE
	bne	.not_hole
	jmp	.while

.not_hole:	
.not_dead:
	lda	#0
	sta	is_dead
	rts
		


dir_reverse:
	cmp	#dir_up
	beq	.down
	cmp	#dir_down
	beq	.up
	cmp	#dir_left
	beq	.right

	;; must be left
.left:	
	lda	#dir_left
	rts

.right:	
	lda	#dir_right
	rts

.up:	
	lda	#dir_up
	rts

.down:	
	lda	#dir_down
	rts


step_table:
		;; 0-15
	.dw	plain_move	; T_FLOOR	
	.dw	push_block	; T_RED		
	.dw	no_move		; T_BLUE	
	.dw	push_block	; T_GREY	
	.dw	push_green	; T_GREEN	
	.dw	plain_move	; T_EXIT	
	.dw	no_move		; T_HOLE	
	.dw	slide_push	; T_GOLD	
	.dw	no_move		; T_LASER	
	.dw	panel_step	; T_PANEL	
	.dw	no_move		; T_STOP	
	.dw	no_move		; T_RIGHT	
	.dw	no_move		; T_LEFT	
	.dw	no_move		; T_UP		
	.dw	no_move		; T_DOWN	
	.dw	plain_move	; T_ROUGH	

; 	;; 16-31
	.dw	no_move		; T_ELECTRIC	
	.dw	electric_off	; T_ON		
	.dw	no_move		; T_OFF		
	.dw	transport_guy	; T_TRANSPORT	
	.dw	break_block	; T_BROKEN	
	.dw	push_block	; T_LR		
	.dw	push_block	; T_UD		
	.dw	t_0_hit		; T_0		
	.dw	t_1_hit		; T_1		
	.dw	push_block	; T_NS		
	.dw	push_block	; T_NE		
	.dw	push_block	; T_NW		
	.dw	push_block	; T_SE		
	.dw	push_block	; T_SW		
	.dw	push_block	; T_WE		
	.dw	send_pulse	; T_BUTTON	

; 	;; 32-47
	.dw	no_move		; T_BLIGHT	
	.dw	no_move		; T_RLIGHT	
	.dw	no_move		; T_GLIGHT	
	.dw	no_move		; T_BLACK	
	.dw	no_move		; T_BUP		
	.dw	plain_move	; T_BDOWN	
	.dw	no_move		; T_RUP		
	.dw	plain_move	; T_RDOWN	
	.dw	no_move		; T_GUP		
	.dw	plain_move	; T_GDOWN	
	.dw	slide_push	; T_BSPHERE	
	.dw	slide_push	; T_RSPHERE	
	.dw	slide_push	; T_GSPHERE	
	.dw	slide_push	; T_SPHERE	
	.dw	plain_move	; T_TRAP2	
	.dw	plain_move	; T_TRAP1	

; 	;; 48-50
	.dw	plain_move	; T_BPANEL	
	.dw	plain_move	; T_RPANEL	
	.dw	plain_move	; T_GPANEL	

