travel:	.macro
	pha
	mov \1,tx
	debug_num
	mov \2,ty
	debug_num
	mov \3,td
	debug_num

	jsr	travel_func

	mov newx,\4
	debug_num
	mov newy,\5
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
	stx	newy
	mov	tx,newx
	jmp	.yes

	
.down:	lda	ty
	cmp	#9
	beq	.no

	tax
	inx
	stx	newy
	mov	tx,newx
	jmp	.yes

	
.left:  lda	tx
	beq	.no

	tax
	dex
	stx	newx
	mov	ty,newy
	jmp	.yes

	
.right: lda	tx
	cmp	#17
	beq	.no

	tax
	inx
	stx	newx
	mov	ty,newy
	jmp	.yes



	
.no:	mov tx,newx
	mov ty,newy
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


do_move:
step_table_target .equ tmp16
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
	mov	newx,gx
	debug_num
	mov	newy,gy
	debug_num
	jsr	update_scroll_from_guy
	rts
	
push_block:
	lda	target
	cmp	#T_LR
	beq	.lr
	cmp	#T_UD
	beq	.ud

	jmp	.normal

.lr:
	lda	newd
	cmp	#dir_up
	beq	.no_move
	cmp	#dir_down
	beq	.no_move

	jmp	.normal

.ud:
	lda	newd
	cmp	#dir_left
	beq	.no_move
	cmp	#dir_right
	beq	.no_move

.normal:

.no_move:	
	rts

push_green:
	rts

electric_off:
	rts
	
no_move:
	debug_p	ds_no_move
	rts

slide_push:
	rts

transport_guy:
	rts

break_block:
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

