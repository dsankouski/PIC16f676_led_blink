;Tutorial 1.2 - Nigel Goodwin 2002  ; MODIFIED FOR PIC16F676

	include "p16f676.inc"	;include the defaults for the chip
	__config 0x3D14			;sets the configuration settings (oscillator type etc.)
							; HERE SET TO INTERNAL OSCILLATOR 4MHZ

	cblock 	0x20 			;start of general purpose registers
		count1 			;used in delay routine
		counta 			;used in delay routine 
		countb 			;used in delay routine
	endc
	
	org	0x0000			;org sets the origin, 0x0000 for the 16F628,
					;this is where the program starts running	

	bcf 	STATUS,RP0 	;Bank 0
	clrf 	PORTA 		;Init PORTA
	movlw	05h 		;Set RA<2:0> to 
	movwf	CMCON 		;digital I/O
	bsf 	STATUS,RP0 	;Bank 1
	clrf	ANSEL 		;digital I/O
	movlw 	00h 		; 
	movwf 	TRISA 		;as outputs

   	movlw 	b'00000000'	;set PortC all outputs
   	movwf 	TRISC
	movwf	TRISA		;set PortA all outputs
	bcf		STATUS,	RP0	;select bank 0

Loop	
	movlw	0xff
	movwf	PORTA			;set all bits on
	movwf	PORTC
	nop				;the nop's make up the time taken by the goto
	nop				;giving a square wave output
	call	Delay			;this waits for a while!
	movlw	0x00
	movwf	PORTA
	movwf	PORTC			;set all bits off
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

	end