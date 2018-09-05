;Tutorial 1.2 - Nigel Goodwin 2002  ; MODIFIED FOR PIC16F676

	include "p16f676.inc"	;include the defaults for the chip
	__config 0x3D14			;sets the configuration settings (oscillator type etc.)
							; HERE SET TO INTERNAL OSCILLATOR 4MHZ
							
	cblock 	0x20 			;start of general purpose registers
		count1 			;used in delay routine
		counta 			;used in delay routine 
		countb 			;used in delay routine
		number
	endc
	
	org	0x0050			;org sets the origin, 0x0000 for the 16F628,
					;this is where the program starts running	

	bcf 	STATUS,RP0 	;Bank 0
	clrf 	PORTA 		;Init PORTA
	movlw	0x21
	movwf	CMCON
	clrf	PORTC
	movlw	0x3f 		;Set RA<5:0> to 
	movwf	CMCON 		;digital I/O
	bsf 	STATUS,RP0 	;Bank 1
	movlw	0x02
	movwf	ANSEL
	movwf 	TRISA
	movlw   0x03
	movwf   ADCON1      ; using internal ADC oscillator
	movlw   0x00
	movwf 	TRISC 		;as outputs
	
	bcf		STATUS,	RP0	;select bank 0
	
	movlw   0x05
	movwf   ADCON0
	
	;Initialize segment display number representation constants
	movlw	0x3f	;0
	movwf	0x30
	movlw	0x00
	movwf	0x40	
	movlw	0x21	;1
	movwf	0x31	
	movlw	0x00
	movwf	0x41	
	movlw	0x1b	;2
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
	movlw   0x66    ;5
    movwf   0x35
    movlw	0x01
	movwf	0x45
	movlw   0x67    ;6
    movwf   0x36
    movlw	0x01
	movwf	0x46
	movlw   0x1c    ;7
    movwf   0x37
    movlw	0x00
	movwf	0x47
	movlw	0x3f	;8
	movwf	0x38
	movlw	0x01
	movwf	0x48	
	movlw	0x3e	;9
	movwf	0x39
	movlw	0x01
	movwf	0x49	
    movlw	0x3d	;A
	movwf	0x3a
	movlw	0x01
	movwf	0x4a	
	movlw	0x17	;B
	movwf	0x3b
	movlw	0x01
	movwf	0x4b	
	movlw	0x33	;C
	movwf	0x3c
	movlw	0x00
	movwf	0x4c	
	movlw	0x0f	;D
	movwf	0x3d
	movlw	0x01
	movwf	0x4d	
	movlw	0x33	;E
	movwf	0x3e
	movlw	0x01
	movwf	0x4e	
    movlw	0x31	;F
	movwf	0x3f
	movlw	0x01
	movwf	0x4f		
	
	movlw	0x00
	movwf	number

Loop	
	nop				;the nop's make up the time taken by the goto
	nop				;giving a square wave output
	movlw	0x00
	movwf	PORTC
	movwf	PORTA
	incf    ADCON0     ;start conversion
	call	Delay
	
	movfw   ADRESH
	
	call	RenderNumber

	call	Delay
	
	movfw	number
	sublw	0x0f
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
