travel:	.macro
	pha
	mov \1,tx
	debug_num
	mov \2,ty
	debug_num
	mov \3,td
	debug_num

	jsr	travel_func

	mov ttx,\4
	debug_num
	mov tty,\5
	debug_num

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
	tay
	mov16	#tiles,tile
	lda	[tile], Y
	debug_p ds_tileat
	debug_num
	rts

flagat:	.macro
	ldx	\1
	ldy	\2
	jsr	flagat_func
	.endm

flagat_func:
	jsr	xy_to_index
	tay
	mov16	#flags,tile
	lda	[tile], Y
	rts
	
destat:	.macro
	ldx	\1
	ldy	\2
	jsr	destat_func
	.endm

destat_func:
	jsr	xy_to_index
	tay
	mov16	#dests,tile
	lda	[tile], Y
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
	debug_num
	rts

settile: .macro
	ldx	\1
	ldy	\2
	mov	\3,new_tile
	jsr	settile_func
;	jsr	draw_level
	.endm

settile_func:	
	jsr	xy_to_index
	sta	tile_pos
	tay
	mov16	#tiles,tile
	lda	new_tile
	sta	[tile], Y
	jsr	update_tile_buffer
	rts

checkstepoff:	.macro
	ldx	\1
	ldy	\2
	jsr	checkstepoff_func
	.endm

checkstepoff_func:
	jsr	checkleavepanel_func
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


checkleavepanel_func:
	jsr	tileat_func
	cmp	#T_PANEL
	beq	.swap
	rts
.swap:
	jmp	swapo
	
	
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
	
	rts


do_move:
step_table_target .equ tmp16
	mov	#0,doswap
	lda	newd
	sta	gd
	travel  gx,gy,newd,newx,newy
	tileat  newx,newy
	sta	target
	asl	A
	tay
	debug_num
	mov16	#step_table,step_table_target
	lda	[step_table_target],Y
	tax
	iny
	lda	[step_table_target],Y
	sta	step_table_target+1
	txa
	sta	step_table_target
	jmp	[step_table_target]


panel_step:	
plain_move:
	debug_p	ds_plain_move
	checkstepoff	gx,gy	
	lda	doswap
	beq	.noswap
	jsr	swapo

.noswap:	
	mov	newx,gx
	debug_num
	mov	newy,gy
	debug_num

	jsr	make_step_noise
	
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
	jmp	plain_move

.next5:
	tileat	destx,desty
	cmp	#T_HOLE
	bne	.next6
	lda	target
	cmp	#T_GREY
	beq	.next5_1
	jmp	no_move

.next5_1:	
	settile	destx,desty, #T_FLOOR
	settile	newx,newy,replacement
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
	mov	#1,doswap
	settile	destx,desty,target
	settile	newx,newy,replacement
	jmp	plain_move
	



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
	rts
	
no_move:
	debug_p	ds_no_move
	jmp	make_no_move_sound

slide_push:
	rts

transport_guy:
	rts

break_block:
	settile newx,newy,#T_FLOOR
	rts

t_0_t_1_hit:
	rts

send_pulse:
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
	.dw	t_0_t_1_hit	; T_0		
	.dw	t_0_t_1_hit	; T_1		
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

