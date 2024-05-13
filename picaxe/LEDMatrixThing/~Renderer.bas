init:
	bsf	 STATUS,RP0
	movlw  b'11111111'
	movwf  TRISA
	movlw  b'00000000'
	movwf  TRISB
	bcf    STATUS,RP0
	
	
	INDF   EQU @bptr
	FSR    EQU bptr
	;b0 contains column 1, with the lsb being the top one
	;b1 contains column 2 etc
	
	movlw  b'00000'
	movwf  b0
	movlw  b'01010'
	movwf  b1
	movlw  b'10000'
	movwf  b2
	movlw  b'10000'
	movwf  b3
	movlw  b'10000'
	movwf  b4
	movlw  b'01010'
	movwf  b5
	movlw  b'00000'
	movwf  b6
	
	
	
render:
	bsf    PORTA,0     
	clrf   FSR
;lp:   movfw  INDF
lp:   
	bsf    PORTB,7
	;nop    ;Just make sure it has enough time to register
	;call   wait100ms
	comf   INDF,W
	andlw  b'00011111' ;Just make sure we only get the right bits
	movwf  PORTB
	;call   wait100ms
	
	incf   FSR,W
	movwf  FSR
	addlw  b'11111001'
	btfss  STATUS,Z
	goto   lp
	goto   render