levels:	
	.dw title_level, \
	    sample_level01, \
	    sample_level02, \
	    sample_level03, \
	    sample_level04, \
	    sample_level05, \
	    sample_level06, \
	    sample_level07, \
	    sample_level08, \
	    sample_level09, \
	    sample_level10, \
	    sample_level11, \
	    sample_level12, \
	    sample_level13, \
	    lev138, \
	    lev129, \
	    lev141, \
	    lev121, \
	    lev70, \
	    lev60, \
	    lev69, \
	    lev112, \
	    lev107, \
	    lev108, \
	    lev109, \
	    lev113, \
	    lev135, \
	    lev37, \
	    lev85, \
	    lev140

title_level:
	.incbin "levels/title.esx"
sample_level01:	
   	.incbin "levels/tutor01.esx"		
sample_level02:	
 	.incbin "levels/tutor02.esx"		
sample_level03:	
 	.incbin "levels/tutor03.esx"		
sample_level04:	
  	.incbin "levels/tutor04.esx"		
sample_level05:	
 	.incbin "levels/tutor05.esx"		
sample_level06:	
 	.incbin "levels/tutor06.esx"		
sample_level07:	
 	.incbin "levels/tutor07.esx"		
sample_level08:	
	.incbin "levels/tutor08.esx"		
sample_level09:	
	.incbin "levels/tutor09.esx"		
sample_level10:	
	.incbin "levels/tutor10.esx"		
sample_level11:	
	.incbin "levels/tutor11.esx"		
sample_level12:	
	.incbin "levels/tutor12.esx"
sample_level13:	
	.incbin "levels/tutor13.esx"

	.bank 1
	.org  $A000

lev138:	
	.incbin	"levels/lev138.esx"
lev129:	
	.incbin	"levels/lev129.esx"
lev141:	
	.incbin	"levels/lev141.esx"
lev121:	
	.incbin	"levels/lev121.esx"
lev70:	
	.incbin	"levels/lev70.esx"
lev60:	
	.incbin	"levels/lev60.esx"
lev69:	
	.incbin	"levels/lev69.esx"
lev112:
	.incbin	"levels/lev112.esx"
lev107:
	.incbin	"levels/lev107.esx"
lev108:
	.incbin	"levels/lev108.esx"
lev109:
	.incbin	"levels/lev109.esx"
lev113:
	.incbin	"levels/lev113.esx"
lev135:
	.incbin	"levels/lev135.esx"
lev37:
	.incbin	"levels/lev37.esx"
lev85:
	.incbin	"levels/lev85.esx"
lev140:
	.incbin	"levels/lev140.esx"
