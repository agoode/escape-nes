	.list

	.inesprg 2
	.ineschr 1
	.inesmir 1
	.inesmap 4


	
	.code
	.bank 0
	.org	$8000

	.include "sound.asm"

start:	;; 2A03!
	lda	#%00001111	; sound enable
	sta	$4015

	jsr	delay
	jsr	delay
	
	jsr	make_step_sound
	jsr	delay	

	jsr	make_step_sound
	jsr	delay	

	jsr	make_step_sound
	jsr	delay	

	jsr	make_step_sound
	jsr	delay	

	jsr	make_step_sound
	jsr	delay	
	jsr	delay	


	jsr	make_no_move_sound
	jsr	delay	
	jsr	make_no_move_sound
	jsr	delay	
	jsr	make_no_move_sound
	jsr	delay	
	jsr	make_no_move_sound
	jsr	delay	
	jsr	make_no_move_sound
	jsr	delay	
	jsr	delay


	jsr	make_break_sound
	jsr	delay
	jsr	delay
	jsr	delay
	
	jsr	make_break_sound
	jsr	delay
	jsr	delay
	jsr	delay
	
	jsr	make_break_sound
	jsr	delay
	jsr	delay
	jsr	delay
	
	jsr	make_break_sound
	jsr	delay
	jsr	delay
	jsr	delay
	
	jsr	make_break_sound
	jsr	delay
	jsr	delay
	jsr	delay
	

	jsr	make_electric_off_sound
	jsr	delay
	jsr	delay
	
	jsr	make_electric_off_sound
	jsr	delay
	jsr	delay
	
	jsr	make_electric_off_sound
	jsr	delay
	jsr	delay


	jsr	make_hole_plug_sound
	jsr	delay
	jsr	delay

	jsr	make_hole_plug_sound
	jsr	delay
	jsr	delay

	jsr	make_hole_plug_sound
	jsr	delay
	jsr	delay

	
	jsr	make_zap_sound
	jsr	delay
	jsr	delay
	jsr	make_zap_sound
	jsr	delay
	jsr	delay
	jsr	make_zap_sound
	jsr	delay
	jsr	delay


	jsr	make_swap_sound
	jsr	delay
	jsr	delay
	jsr	make_swap_sound
	jsr	delay
	jsr	delay
	jsr	make_swap_sound
	jsr	delay
	jsr	delay

	
	jsr	make_slide_sound
	jsr	delay
	jsr	delay
	jsr	make_slide_sound
	jsr	delay
	jsr	delay
	jsr	make_slide_sound
	jsr	delay
	jsr	delay

	
	jsr	make_transport_sound
	jsr	delay
	jsr	delay
	jsr	make_transport_sound
	jsr	delay
	jsr	delay
	jsr	make_transport_sound
	jsr	delay
	jsr	delay


	jsr	make_pulse_sound
	jsr	delay
	jsr	delay
	jsr	make_pulse_sound
	jsr	delay
	jsr	delay
	jsr	make_pulse_sound
	jsr	delay
	jsr	delay

	
	jsr	make_laser_sound
	jsr	delay
	jsr	delay
	jsr	delay
	jsr	make_laser_sound
	jsr	delay
	jsr	delay
	jsr	delay
	jsr	make_laser_sound
	jsr	delay
	jsr	delay
	jsr	delay
	jsr	make_laser_sound
	jsr	delay
	jsr	delay
	jsr	delay


	jsr	make_exit_sound
	jsr	delay
	jsr	delay
	jsr	delay
	jsr	make_exit_sound
	jsr	delay
	jsr	delay
	jsr	delay
	jsr	make_exit_sound
	jsr	delay
	jsr	delay
	jsr	delay

	
done:	jmp	done



intr:
nmi:
	rti


delay:
	ldx	#$FF
	ldy	#$FF

.loop:	txa
	beq	.dec_y
	jmp	.dec_x

.dec_y:	dey
	
.dec_x:	dex

	tya
	beq	.y_zero
	jmp	.loop

.y_zero:
	txa
	beq	.done
	jmp	.loop
.done:	
	rts
	

;;; vectors
	.bank	3
	.org	$FFFA
	.dw	nmi,start,intr