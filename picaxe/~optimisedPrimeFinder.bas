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
	tmp    EQU b1
	max    EQU 100
	base   EQU 0x30
main:
	incf   i,F
	movfw  i
	movwf  tmp
	
	;first we have to get the byte
	RRF    tmp,F
	RRF    tmp,F
	RRF    tmp,F
	movlw  b'00011111'
	addwf  base,W
	movwf  FSR
	
	movlw  b'00000111'
	andwf  i,W
	;we have got a decimal representation of the mask, now we need to make the mask
	clrf   tmp,F
	incf   tmp,F
	decf
	RLF    tmp,F
	
	