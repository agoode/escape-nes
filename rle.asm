rledecode:
run	.equ tmp
size	.equ tmp_2
bytes	.equ tmp_3
char	.equ tmp_4

	debug_p	ds1
; 	debug_p ds_tmpaddr
	lda	tmp_addr
; 	debug_num
	lda	tmp_addr+1
; 	debug_num
	;; take idx16, read from it and advance it, and store
	;; result in place pointed by tmp_addr
	mov	#180, size	; size of map
	ldx	#0
	ldy	#0
	mov	[idx16], Y, bytes

	inc16	idx16

.loop:	
	;; read a byte to determine run
	mov	[idx16], Y, run
	inc16	idx16
	lda	run
	bne	.run
	jmp	.anti_run	; if 0, anti-run
.run:	
	;; run
; 	debug_p	ds_run
	mov	#0, char	; set char to 0
	lda	bytes		; check if bytes == 0
	beq	.in_run_loop	; skip and write zeros if bytes == 0

	mov	[idx16], Y, char ; read a char, since bytes != 0
	inc16	idx16
.in_run_loop:
; 	debug_p	ds_x
; 	stx	debug_num
	txa
	tay
	mov	char, [tmp_addr], Y ; write the content of the run
	ldy	#0
	inx
	dec	size
	dec	run
	bne	.in_run_loop

	;; done?
	lda	size
	bne	.loop_trampoline
	jmp	.done
.loop_trampoline:
	jmp	.loop
	
.anti_run:
; 	debug_p	ds_antirun
	mov	[idx16], Y, run ; length of this anti-run
	inc16	idx16
.in_anti_run_loop:
	lda	[idx16], Y
; 	debug_num
	sta	char
	txa
	tay
	lda	char
	sta	[tmp_addr], Y ; write the content of the run
	ldy	#0
			
	inc16	idx16
	inx
	dec	size
	dec	run
	bne	.in_anti_run_loop

	;; done?
	lda	size
	beq	.done
	jmp	.loop
	
	
.done:		
	rts
