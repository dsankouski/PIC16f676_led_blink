	; ----------------------------------------------------------------------------
	; "THE BEER-WARE LICENSE" (Revision 42):
	; dsankouski@gmail.com wrote this file. As long as you retain this notice you
	; can do whatever you want with this stuff. If we meet some day, and you think
	; this stuff is worth it, you can buy me a beer in return. Dzmitry Sankouski
	; ----------------------------------------------------------------------------
	
	; This is a sample blinking LED project. It uses on chip 8 bit timer with 
	; 8 bit prescaler to create blinking period. All controller pins
	; (both portA and PortC) configured as outputs. When timer fires, all pins
	; invert state. Blinking period will be approx. 1sec.
	
	include "p16f676.inc"	;include the defaults for the chip
	__config 0x3D14			;sets the configuration settings (oscillator type etc.)
							; HERE SET TO INTERNAL OSCILLATOR 4MHZ

	cblock 	0x20			;start of general purpose registers
	    light_state
	endc
	
	org	0x0004				;interrupt vector
		goto	InterruptHandler
	
	org	0x0050				;org sets the origin, 0x0000 for the 16F628,
							;this is where the program starts running	

	bcf 	STATUS,RP0		;Bank 0
	clrf 	PORTA			;Init PORTA
	bsf 	STATUS,RP0		;Bank 1
	clrf	ANSEL			;digital I/O
   	clrf 	TRISC			;set PortC all outputs to 0
	clrf	TRISA		
	bcf		STATUS,	RP0		;select bank 0
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;; Timer setup. Registers TMR0 , INTCON, OPTION_REG
	clrf	INTCON
	bsf		INTCON,GIE		;enabling global interrupt flag
	bsf		INTCON,T0IE		;enabling interrupt for timer 0
	clrf	TMR0
	bsf		STATUS,RP0		;Bank 1
	;Prescaler setup
	;configuring prescaler, and assigning prescaler to timer0
	;scaling is 256. Timer frequency is Fosc/(4*2*65536)
	movlw   b'0000111'
	movwf	OPTION_REG
	;;;;;;End of scaling setup
	bcf		STATUS,	RP0		;select bank 0
	;;;;;;End of timer setup
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Loop	
	nop				
	nop				
	goto	Loop			

InterruptHandler
    incf    light_state		;increment light state
    btfsc   light_state,3	;additional scaling by 8.
    movlw   0x3f			;if light state 3 bit is 0, turn on leds
    btfss   light_state,3
    movlw   0x00			;if light state 3 bit is 1, turn off leds	
    movwf   PORTA
    movwf   PORTC
    clrf	TMR0			;resetting timer
	bcf		INTCON,T0IF		;clearing timer0 overflow bit
    retfie
	
end
