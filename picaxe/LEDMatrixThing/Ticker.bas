init:
	bsf	 STATUS,RP0
	movlw  b'11111111'
	movwf  TRISA
	movlw  b'00000000'
	movwf  TRISB
	bcf    STATUS,RP0
	
	;incf   b0,F
	bsf    STATUS,C
	
waitForOn:
	btfss  PORTA,0
	goto   waitForOn
	
	movlw  1
	;bcf    STATUS,C
	rlf    b0,F
	btfsc  b0,7
	movwf  b0
	movfw  b0
	movwf  PORTB
waitForOff:
	btfss  PORTA,0
	goto   waitForOn
	goto   waitForOff