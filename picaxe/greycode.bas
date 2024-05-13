init: 
    	clrf   PORTB        ; clear PORTB output latches
    	bsf    STATUS,RP0   ; memory page 1
    	movlw  b'11111111'  ; set portA pins to input 
    	movwf  TRISA        ; write to TRIS register 
    	movlw  b'00000000'  ; set portB pins to output 
    	movwf  TRISB        ; write to TRIS register 
    	bcf    STATUS,RP0   ; memory page 0
	
	i      EQU B10      ;Our main counter variable
	tmp    EQU B11      ;temp holding thing
main: 
	incf   i,F          ;increment our counter
	rrf    i,W          ;Shift to the right and store in w
	xorwf  i,W          ;xor w with our original one
	
	movwf  tmp          ;We need to temporarily store our value to shift it
	rlf    tmp,F        ;Shift it to the left
	rlf    i,W		  ;Chuck our MSB into the carry
	rrf    tmp,W        ;Chuck it back into the thing
	
	movwf PORTB         ;Display it
	
	goto   main