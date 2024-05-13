init:
	clrf   PORTB        ; clear PORTB output latches
    	bsf    STATUS,RP0   ; memory page 1
    	movlw  b'11111111'  ; set portA pins to input 
    	movwf  TRISA        ; write to TRIS register 
    	movlw  b'00000000'  ; set portB pins to output 
    	movwf  TRISB        ; write to TRIS register 
    	bcf    STATUS,RP0   ; memory page 0
	
	INDF   EQU @bptr    ;this is where the magic happens
	FSR    EQU bptr
	
	xm	 EQU b0       ;most significant bit of x
	xl     EQU b1       ;least significant bit of x
	
	PC     EQU b2       ;program counter
	
	accm   EQU b3
	accl   EQU b4
	
	tmpm	 EQU b19      ;Preserved
	tmp	 EQU b20      ;multipurpose temp register
	dab    EQU b21      ;destination address backup
	sab    EQU b23      ;source address backup
	ctmp2  EQU b24      ;temp register coroutines use
	ctmp   EQU b25      ;temp register coroutines use
	SA	 EQU b26      ;source address
	DA	 EQU b27      ;destination address
	
	;Constants
	base   EQU 0x30     ;The base address for where the data is stored in ram
	acc    EQU 0x3     ;The accumulator
	
main:
	movfw  PC
	movwf  SA
	call   wmovsx
	
	
HLT:  ;Sub 100 from x
	btfsc  STATUS,C     ;if it 0, the number was between 0 and 100
	goto   ADD
	END
	
ADD:  ;Sub 100 from x
	btfsc  STATUS,C     ;if it 0, the number was between 100 and 200
	goto   SUB
	call   xaddhun
	
	movlw  acc
	movwf  sa
	movfw  xl
	addlw  base
	movwf  da
	call   waddsd       ;add together the accumulator and whatever is left in x
	;Move x to the accumulator
	movlw  acc
	movwf  da           ;the destination is the accumulator
	call   wmovxd 
	goto next
	
SUB:  ;Sub 100 from x
	btfsc  STATUS,C     ;if it 0, the number was between 200 and 300
	goto   STA
	call   xaddhun
	goto next
	
STA:  ;Sub 100 from x
	btfsc  STATUS,C     ;if it 0, the number was between 300 and 400
	goto   LDA
	call   xaddhun
	
	movlw  acc
	movwf  sa
	
	movfw  xl
	addwf  xl           ;add it twice to get the actual location
	movwf  da
	call   movsd        ;move accumulator to x
	goto next
	
LDA:  ;Sub 100 from x
	btfsc  STATUS,C     ;if it 0, the number was between 400 and 500
	goto   BRA
	call   xaddhun
	
	movlw  xl
	addwf  xl           ;add it twice to get the actual location
	movwf  sa
	movfw  acc
	movwf  da
	call   movsd        ;move x to accumulator
	goto next
	
BRA:  ;Sub 100 from x
	btfsc  STATUS,C     ;if it 0, the number was between 500 and 600
	goto   BRZ
	call   xaddhun
	
br:   movfw  xl           ;Can be gone to  by BRZ or BRP
	addwf  xl           ;add it twice to get the actual location
	movwf  PC
	goto   main         ;skip the adding stuff to pc
	
	
BRZ:  ;Sub 100 from x
	btfsc  STATUS,C     ;if it 0, the number was between 600 and 700
	goto   BRP
	call   xaddhun
	
	;Now we check if accm and accl are zero
	movf   accm,F             
	btfss  STATUS,Z
	goto   next         ;in this case,  it is not zero
	movf   accl,F             
	btfss  STATUS,Z
	goto   next         ;in this case,  it is not zero
	
	goto   br
	
BRP:  ;Sub 100 from x
	btfsc  STATUS,C     ;if it 0, the number was between 700 and 800
	goto   INP
	call   xaddhun
	
INP:  ;Sub 100 from x
	btfsc  STATUS,C     ;if it 0, the number was between 800 and 900
	goto   OUT
	movfw  PORTA
	movwf  accl
	clrf   accm
	goto   next
	
OUT:  ;Sub 100 from x
	btfsc  STATUS,C     ;if it 0, the number was between 900 and 1000
	END
	movfw  accl
	movwf  PORTB
	
next: 
	incf   PC
	incf   PC
	goto   main          ;Go back and do it all again lol

endlp:goto endlp           ;get it stuck in a loop so we can inspect stuff

	
	
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Helper functions;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movsd: ;move sa to da
	movfw  SA
	movwf  FSR
	movfw  INDF
	movwf  ctmp          ;we've got the goods
	
	movfw  DA
	movwf  FSR
	
	movfw  ctmp
	movwf  INDF          ;send it of o7
	return
movsw: ;move sa to w
	movlw  0x19          ;our destination is w
	movwf  DA
	call   movsd
	return
movwd: ;move w to sa
	movlw  0x19          ;our source is w
	movwf  SA
	call  movsd
	return
wmovxd: ;move x to da
	clrf   SA            ;our source is 0 (where x is)
	call   wmovsd
	return
wmovsx: ;move sa to x
	clrf   DA            ;our destination is 0 (where x is)
	call   wmovsd
	return
wmovsd: ;move word from source address to destination address
	call   movsd         ;grab the msb
	incf   SA,F          ;increment source address
	incf   DA,F          ;increment destination address
	call   movsd         ;grab the lsb
	decf   SA,F          ;return them to how they were
	decf   DA,F
	return
addsd: ;add s and d and store in w
	movfw  sa            ;backup our variables
	movwf  sab
	movfw  da
	movwf  dab
	
	call   movsw         ;grab the source into ctmp2
	movwf  ctmp2
	movfw  dab
	movwf  sa
	call   movsw         ;grab the dest and add to ctmp2
	addwf  ctmp2,F
	movfw  sab           ;reset it back
	movwf  sa
	movfw  dab
	movwf  da
	movfw  ctmp2
	return
waddsd: ;add source and destination, and store in x
	call   addsd
	movwf  xm            ;store the msb in xm
	
	incf   SA,F          ;increment source address
	incf   DA,F          ;increment destination address
	
	call   addsd
	movwf  xl
	
	btfsc  STATUS,C      ;if we had a carry, we need to add one to the msb
	incf   xm,F 
	
	decf   SA,F          ;return them to how they were
	decf   DA,F
	
	return
xsubhun: ;Subtract 100 from x
	return
xaddhun: ;add 100 to x
	movlw  100
	movwf  tmp           ;100 in temp
	clrf   sa            ;our source is x
	movlw  19
	movwf  da            ;our destination is 21(tmp)
	
	call waddsd
	
	
	return