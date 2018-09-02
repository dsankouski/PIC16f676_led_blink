;Tutorial 1.2 - Nigel Goodwin 2002  ; MODIFIED FOR PIC16F676

	include "p16f676.inc"	;include the defaults for the chip
	__config 0x3D14			;sets the configuration settings (oscillator type etc.)
							; HERE SET TO INTERNAL OSCILLATOR 4MHZ
							
	cblock 	0x20 			;start of general purpose registers
		count1 			;used in delay routine
		counta 			;used in delay routine 
		countb 			;used in delay routine
		number
		oneA
		oneC
		twoA
		twoC
	endc

	;org	0x004
	;	goto	Interrupt
	
	org	0x0050			;org sets the origin, 0x0000 for the 16F628,
					;this is where the program starts running	

	bcf 	STATUS,RP0 	;Bank 0
	clrf 	PORTA 		;Init PORTA
	MOVLW	0x3f
	movwf	CMCON
	clrf	PORTC
	movlw	0x3f 		;Set RA<5:0> to 
	movwf	CMCON 		;digital I/O
	bsf 	STATUS,RP0 	;Bank 1
	clrf	ANSEL 		;digital I/O
	movlw 	0x00 		; 
	movwf 	TRISA 		;as outputs
	movwf 	TRISC 		;as outputs
	
	bcf		STATUS,	RP0	;select bank 0
	
	;Initialize number constants
	movlw	0x3f	;0
	movwf	0x30
	movlw	0x00
	movwf	0x40	
	movlw	0x21	;1
	movwf	0x31	
	movlw	0x00
	movwf	0x41	
	movlw	0x1B	;2
	movwf	0x32
	movlw	0x01
	movwf	0x42	
	movlw	0x33	;3
	movwf	0x33
	movlw	0x01
	movwf	0x43	
	movlw	0x29	;4
	movwf	0x34
	movlw	0x01
	movwf	0x44	
	movlw	0x3f	;8
	movwf	0x38
	movlw	0x01
	movwf	0x48	
	
	movlw	0x00
	movwf	number
	;bcf	STATUS,T0CS	;setting timer operation mode as timer

Loop	
	nop				;the nop's make up the time taken by the goto
	nop				;giving a square wave output
	movlw	0x00
	movwf	PORTC
	movwf	PORTA
	call	Delay
	
	call	RenderNumber

	call	Delay
	
	movfw	number
	sublw	d'4'
	btfsc	STATUS,Z
	movwf	number
	
	incf	number,1
	
	goto	Loop			;go back and do it again

Delay	movlw	d'250'			;delay 250 ms (4 MHz clock)
	movwf	count1
d1	movlw	0xC7
	movwf	counta
	movlw	0x01
	movwf	countb
Delay_0
	decfsz	counta, f
	goto	$+2
	decfsz	countb, f
	goto	Delay_0
	decfsz	count1	,f
	goto	d1
	retlw	0x00
	
RenderNumber
	movlw	0x30
	addwf	number,0
	movwf	FSR
	movfw	INDF
	movwf	PORTC
	movlw	0x40
	addwf	number,0
	movwf	FSR
	btfsc	INDF,0
	bsf	PORTA,0
	btfss	INDF,0
	bcf	PORTA,0
	bcf	PORTA,5
	retlw	0x00
	end