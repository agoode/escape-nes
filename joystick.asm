j_a:		.equ	%00000001
j_b:		.equ	%00000010
j_select:	.equ	%00000100
j_start:	.equ	%00001000
j_up:		.equ	%00010000
j_down:		.equ	%00100000
j_left:		.equ	%01000000
j_right:	.equ	%10000000
	
handle_joy:
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
	;lda	#j_a
 	;ora	cur_joy_state
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
	jsr	move_guy_right
	jsr	draw_guy

.act1:	lda	last_joy_state
	and	#j_left
	beq	.act2
	jsr	move_guy_left
	jsr	draw_guy

.act2:	lda	last_joy_state
	and	#j_down
	beq	.act3
	jsr	move_guy_down
	jsr	draw_guy

.act3:	lda	last_joy_state
	and	#j_up
	beq	.act4
	jsr	move_guy_up
	jsr	draw_guy

.act4:	lda	last_joy_state
	and	#j_start
	beq	.act5
	lda	level_num
	clc
	adc	#1
	cmp	#13
	bne	.level_set
	lda	#1		; reset
.level_set:	
	sta	level_num
	jsr	choose_level
	
.act5:	
.done:
	lda	cur_joy_state
	sta	last_joy_state
	rts

