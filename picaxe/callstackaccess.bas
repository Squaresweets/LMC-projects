
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;init and variables;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init:
	clrf   PORTB        ; clear PORTB output latches
    	bsf    STATUS,RP0   ; memory page 1
    	movlw  b'11111111'  ; set portA pins to input 
    	movwf  TRISA        ; write to TRIS register 
    	movlw  b'00000000'  ; set portB pins to output 
    	movwf  TRISB        ; write to TRIS register 
    	bcf    STATUS,RP0   ; memory page 0
	
	INDF   EQU @bptr    ;the indf and fsr (used for indirect addressing) isn't normally accessable, this hack lets us use it
	FSR    EQU bptr
	call   test
test:
	call   wait1000ms
	call   test