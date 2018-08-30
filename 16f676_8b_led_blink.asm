;Tutorial 1.2 - Nigel Goodwin 2002  ; MODIFIED FOR PIC16F676

	include "p16f676.inc"	;include the defaults for the chip
	__config 0x3D14			;sets the configuration settings (oscillator type etc.)
							; HERE SET TO INTERNAL OSCILLATOR 4MHZ
							
	cblock 	0x20 			;start of general purpose registers
		count1 			;used in delay routine
		counta 			;used in delay routine 
		countb 			;used in delay routine
	endc

	org	0x004
		goto	Interrupt
	
	org	0x0050			;org sets the origin, 0x0000 for the 16F628,
					;this is where the program starts running	

	bcf 	STATUS,RP0 	;Bank 0
	clrf 	PORTA 		;Init PORTA
	clrf	PORTC
	movlw	0xd8
	movwf	INTCON		;interrupts enable
	movlw	0x3f 		;Set RA<5:0> to 
	movwf	CMCON 		;digital I/O
	movlw	0x10
	movwf	IOCA		;enable interrupt on change
	bsf 	STATUS,RP0 	;Bank 1
	clrf	ANSEL 		;digital I/O
	movlw 	0x3f 		; 
	movwf 	TRISA 		;as inputs

	movlw	b'00000000'
	movwf	TRISC   	
	
	bcf		STATUS,	RP0	;select bank 0
	
	
	;bcf	STATUS,T0CS	;setting timer operation mode as timer

Loop	
	nop				;the nop's make up the time taken by the goto
	nop				;giving a square wave output
	;movlw	0xff
	;xorwf	PORTC,1
	call	Delay
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

Interrupt
	movlw	0xff
	xorwf	PORTC,1
	movlw	0xd8
	movwf	INTCON
	return
	
	end