j_a:		.equ	%00000001
j_b:		.equ	%00000010
j_select:	.equ	%00000100
j_start:	.equ	%00001000
j_up:		.equ	%00010000
j_down:		.equ	%00100000
j_left:		.equ	%01000000
j_right:	.equ	%10000000

	
		
handle_joy:
	;; don't do it if drawing
	lda	num_tiles_changed
	beq	.ok
	rts

.ok:
	;; clear
	lda	#0
	sta	cur_joy_state

	;; strobe joystick 1
	lda	#1
	sta	$4016
	lda	#0
	sta	$4016

	;; buttons...
.a:	
	lda	$4016
	and	#%1
	beq	.b
	lda	#j_a
 	ora	cur_joy_state
	sta	cur_joy_state
		
.b:	
	lda	$4016
	and	#%1
	beq	.select
	lda	#j_b
	ora	cur_joy_state
	sta	cur_joy_state
	
.select:
	lda	$4016
	and	#%1
	beq	.start
	lda	#j_select
	ora	cur_joy_state
	sta	cur_joy_state

.start:	
	lda	$4016
	and	#%1
	beq	.up
	lda	#j_start
	ora	cur_joy_state
	sta	cur_joy_state

.up:	
	lda	$4016
	and	#%1
	beq	.down
	lda	#j_up
	ora	cur_joy_state
	sta	cur_joy_state

.down:	
	lda	$4016
	and	#%1
	beq	.left
	lda	#j_down
	ora	cur_joy_state
	sta	cur_joy_state

.left:	
	lda	$4016
	and	#%1
	beq	.right
	lda	#j_left
	ora	cur_joy_state
	sta	cur_joy_state

.right:
	lda	$4016
	and	#%1
	beq	.action
	lda	#j_right
	ora	cur_joy_state
	sta	cur_joy_state

.action:	
	lda	#$FF
	eor	last_joy_state
	and	cur_joy_state
	;; now, only new buttons are active
	sta	last_joy_state

	;; perform actions
	and	#j_right
	beq	.act1
	mov	#dir_right,newd
	jsr	handle_direction
	jmp	.done

.act1:	lda	last_joy_state
	and	#j_left
	beq	.act2
	mov	#dir_left,newd
	jsr	handle_direction
	jmp	.done

.act2:	lda	last_joy_state
	and	#j_down
	beq	.act3
	mov	#dir_down,newd
	jsr	handle_direction
	jmp	.done

.act3:	lda	last_joy_state
	and	#j_up
	beq	.act4
	mov	#dir_up,newd
	jsr	handle_direction
	jmp	.done

.act4:	lda	last_joy_state
	and	#j_start
	beq	.act5
	jsr	handle_start
	jmp	.done
	
.act5:	lda	last_joy_state
	and	#j_select
	beq	.act6
	jsr	handle_select
	jmp	.done

.act6:
	lda	last_joy_state
	and	#j_a
	beq	.act7
	jsr	handle_a
	jmp	.done
.act7:	
.done:
	lda	cur_joy_state
	sta	last_joy_state
	rts


go_to_next_level:
	lda	level_num
	clc
	adc	#1
	cmp	#29
	bne	.level_set
	lda	#0		; reset
.level_set:	
	sta	level_num

	rts


handle_start:			; restart
	jsr	choose_level

	rts
	
handle_select:
	jsr	go_to_next_level
	jsr	choose_level

	rts

handle_a:
	lda	is_won		; only advance if won
	beq	.not_won
	jsr	go_to_next_level
	jsr	choose_level
	
.not_won:
	lda	is_dead
	beq	.not_dead
	jsr	choose_level	; reset if dead

.not_dead:
	rts



handle_direction:
	lda	is_dead
	bne	.do_nothing
	lda	is_won
	bne	.do_nothing
	
	jsr	mask_nmi

	jsr	do_move
	jsr	draw_guy
	jsr	set_end_states
	
	jsr	ppu_on

.do_nothing:	
	rts
