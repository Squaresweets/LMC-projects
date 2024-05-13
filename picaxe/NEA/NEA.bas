init:
	bsf	 STATUS,RP0
	movlw  b'10111011'
	movwf  TRISA
	movlw  b'00000000'
	movwf  TRISB
	bcf    STATUS,RP0
	
	;Enable interupts
	bsf    INTCON,INT0IE
	bsf    INTCON,GIE
	
	INDF   EQU @bptr ;Indirect file
	FSR    EQU bptr ;File set register

	inp    EQU b0 ;To store the input
	i      EQU b27 ;To keep track of how many bits we have checked through
	tmp    EQU b26 ;To make it so that the last shift is non destructive
	sum    EQU b25 ;Keep track of the variable we are going to output
	lubs   EQU b24 ;Last unit button state, for checking if the unit button has changed state
	
	;Load the data
	;1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19
	;2A 94 A9 49 4A 52 92 94 A5 29 4A 95 4A AA AA D6 B6 EE FF FF 
	movlw  h'2A'
	movwf  b1
	movlw  h'94'
	movwf  b2
	movwf  b8
	movlw  h'A9'
	movwf  b3
	movlw  h'49'
	movwf  b4
	movlw  h'4A'
	movwf  b5
	movwf  b11
	movwf  b13
	movlw  h'52'
	movwf  b6
	movlw  h'92'
	movwf  b7
	movlw  h'A5'
	movwf  b9
	movlw  h'29'
	movwf  b10
	movlw  h'95'
	movwf  b12
	movlw  h'AA'
	movwf  b14
	movwf  b15
	movlw  h'D6'
	movwf  b16
	movlw  h'B6'
	movwf  b17
	movlw  h'EE'
	movwf  b18
	movlw  h'FF'
	movwf  b19
	movwf  b20
	
	;The offset for the input, because most of the start is 0
	firstNonZ EQU 71

main:
	call   loadTemperature ;Load the temperature
	
	call   unitChange ;Sort out if the unit button is pressed
	btfsc  PORTA,6 ;Check if we need to convert to celcius
	call   celciusToFahrenheit
	call   sumToBCD ;Conver the sum to BCD
	swapf  SUM, W ;To make wiring a bit easier
	movwf  PORTB ;Output it
	
	goto   main ;Repeat!
	
	
	
;Grabs the ADC, then convert to a temp and store it to the "sum" variable
loadTemperature:
	call   readadc0 ;Put the adc value into input
	;movlw  128
	;movwf  b0
	
	;Reset sum, i and FSR to what they should be
	clrf   sum 
	clrf   i
	movlw  1
	movwf  FSR
	
	movfw  INDF ;Make a backup, so the shifts are non destructive
	movwf  tmp
	
	;Subtrack offset so we start from first non 0
	movlw  firstNonZ
	subwf  inp,F
	btfss  STATUS,C
	goto   lp
	;It is going to be 0, so no point in going through all the hastle of checking
	clrf   sum
	return
	
lp:	;rotate around the byte we are on, checking each bit and summing it as we go
	call rtli
	
	btfsc  STATUS,C
	incf   sum,F ;If the carry is 1, we add one to status
	
	;Check if we have got to the end (leaving the carry bit free)
	movfw  i
	xorwf  inp,W
	btfsc  STATUS,Z ;If the zero bit is set, they are the same, and we are done
	goto   out
	
	incf   i,F
	
	;Check if we need to move onto the next byte
	movfw  i
	andlw  b'111' ;If the first 3 bits are 0 we need to move onto the enxt one
	btfss  STATUS,Z
	goto   lp
	call   rtli
	clrf   b23
	incf   FSR,F ;We move onto the next byte
	movfw  INDF
	movwf  tmp
	goto   lp
out:  
	movfw  tmp ;Restore the backup
	movwf  INDF
	return
	
celciusToFahrenheit:
	;The formula i found to decrease loss as much as possible is:
	;((x*2+2)/5*9)/2 + 32
	;It is fiddly cause I have to stay within the byte
	clrf   tmp
	comf   tmp,F ;Make it start at -1
	
	clrf   STATUS
	rlf    sum,W ;*2
	addlw  2 ;+2
	
	;/5
div:  incf   tmp,F
	addlw  b'11111011' ;-5 (in 2's comp)
	btfsc  STATUS,C
	goto   div
	
	;This is probably the best way to * by 9, it's fiddly but fast 
	movfw  tmp
	addwf  tmp,W ;Add it to itself, we now have double
	addwf  tmp,W ;Add it to itself, we now have *3 in sum
	movwf  sum
	addwf  sum,F
	addwf  sum,F
	
	rrf    sum,W ;/2
	addlw  32
	movwf  sum
	
	movlw  100
	subwf  sum,W
	btfsc  STATUS,C
	return
	nop    ;picaxe is fidly with returns after bit tests
	movlw  99
	movwf  sum
	return

sumToBCD:
	clrf   tmp ;reset variables
	comf   tmp,F
	movfw  sum
div2: incf   tmp,F ;Divide it by 10
	addlw  b'11110110' ;-10
	btfsc  STATUS,C
	goto   div2
	
	addlw  10 ;Return back to get the remainder
	swapf  tmp,F ;Shuffle the nibbles
	addwf  tmp,W
	movwf  sum ;Return it
	return

unitChange:
	btfss  PORTA,1
	goto   ubck
	btfsc  lubs,1
	goto   ubck
	;we gotta change the unit
	movlw  b'01000000'
	xorwf  PORTA,W
	movwf  PORTA
	
ubck: movfw  PORTA
	movwf  lubs
	return
	
rtli: ;Rotates INDF left, but keeps the status bit elsewhere because the chip works differnetly
	btfsc  b23,C
	bsf    STATUS,C
	rlf    INDF,F ;Rotate so we test the next bit
	
	btfsc  STATUS,C
	bsf    b23,C
	btfss  STATUS,C
	bcf    b23,C
	return

interrupt:
	bcf    INTCON,INT0IF
	retfie