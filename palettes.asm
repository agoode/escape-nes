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

	
;;; sprite palette 1
	lda	#$3f
	sta	$2006
	lda	#$11
	sta	$2006
	lda	#$18		; brown
	sta	$2007
	lda	#$36		; pink
	sta	$2007
	lda	#$2C		; blue
	sta	$2007
