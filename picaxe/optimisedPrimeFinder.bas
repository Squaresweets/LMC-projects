init:
	clrf   PORTB        ; clear PORTB output latches
    	bsf    STATUS,RP0   ; memory page 1
    	movlw  b'11111111'  ; set portA pins to input 
    	movwf  TRISA        ; write to TRIS register 
    	movlw  b'00000000'  ; set portB pins to output 
    	movwf  TRISB        ; write to TRIS register 
    	bcf    STATUS,RP0   ; memory page 0
	
	INDF   EQU @bptr    ;the indf and fsr (used for indirect addressing)
	FSR    EQU bptr
	
	i	 EQU b0
	offset EQU b3
	tmp    EQU b1
	tmp2   EQU b2
	mx     EQU 100
	base   EQU 0x30
	incf   offset,F ;it's gotta start at 2
main:	
	incf   offset,F
	clrf   i
	comf   i,F
lop:
	movfw  offset ;Increment i by the current offset
	addwf  i,F
	
	btfsc  i,4
	goto   main ;we have done enough
	
	movfw  i
	movwf  tmp
	
	;first we have to get the byte
	RRF    tmp,F
	RRF    tmp,F
	RRF    tmp,F
	movlw  b'00011111'
	andwf  tmp,W
	addlw  base
	movwf  FSR
	
	movlw  b'00000111'
	andwf  i,W
	movwf  tmp2
	;we have got a decimal representation of the mask, now we need to make the mask
	bsf    STATUS,C
	
	clrf   tmp
msk:  RLF    tmp,F
	decfsz tmp2,F
	goto   msk
	
	;Actually set the bit
	RLF    tmp,W
	iorwf  INDF,F
	goto   lop