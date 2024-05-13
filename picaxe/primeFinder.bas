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
	
	
main: incf   i,F          ;increment our counter
	
	movlw  1
	
	movwf  div          ;reset div to one
	
lop:  incf   div,F        ;increment div
	
	movfw  div          ;grab the div
	addwf  div,W        ;add it twice, so we only test half
	subwf  i,W          ;subtract double div from the value we are testing
	;If it is positive (carry=0), we have more numbers to test
	btfsc  STATUS,C    ;Number is prime as we have no more values to test for
	goto   prm
	
	;if we got here we have to test another value of div
	movfw  i
	movwf  tmp          ;get a copy of i
	
dv:   movfw  div          ;get the number we are trying to divide by
	subwf  tmp,F        ;Subtract div from temp
	
	btfsc  STATUS,Z
	goto   main         ;it perfectly divides, so we go to main
	btfss  STATUS,C
	goto   dv
	goto   lop          ;This value does not go in, as it is now negative
	
prm:  movfw  i
	movwf  PORTB        ;output it
	goto   main
	
	
;Helper function to output the value in W to a seven segment display
;B7:g B6:f B5:a B4:b
;B0:e B1:d B2:c 
svnseg:
	movlw b'00000000' ;0
	goto ots
	movlw b'00000001' ;1
	goto ots
	movlw b'00000010' ;2
	goto ots
	movlw b'00000011' ;3
	goto ots
	movlw b'00000100' ;4
	goto ots
	movlw b'00000101' ;5
	goto ots
	movlw b'00000110' ;6
	goto ots
	movlw b'00000111' ;7
	goto ots
	movlw b'00000000' ;8
	goto ots
	movlw b'00000000' ;9
	goto ots
	movlw b'00000000' ;A
	goto ots
	movlw b'00000000' ;B
	goto ots
	movlw b'00000000' ;C
	goto ots
	movlw b'00000000' ;D
	goto ots
	movlw b'00000000' ;E
	goto ots
	movlw b'00000000' ;F
	goto ots
	
	
ots:	movwf PORTB
	return
