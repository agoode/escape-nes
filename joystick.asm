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

