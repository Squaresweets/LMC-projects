init: 
    	clrf   PORTB        ; clear PORTB output latches
    	bsf    STATUS,RP0   ; memory page 1
    	movlw  b'11111111'  ; set portA pins to input 
    	movwf  TRISA        ; write to TRIS register 
    	movlw  b'00000000'  ; set portB pins to output 
    	movwf  TRISB        ; write to TRIS register 
    	bcf    STATUS,RP0   ; memory page 0

	i      EQU B10      ;Our main counter variable
	div    EQU B11      ;the number we are attempting to divide by
	tmp    EQU B12      ;temp holding thing
	B69    EQU h'2A'    ;temp holding thing
main:
	movfw  B10