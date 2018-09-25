	include "p16f676.inc"	;include the defaults for the chip
	__config 0x3D14		;sets the configuration settings (oscillator type etc.)
				; HERE SET TO INTERNAL OSCILLATOR 4MHZ

	cblock 	0x20 		;start of general purpose registers
	    light_state
	endc
	
	org	0x0004		;interrupt vector
		goto	InterruptHandler
	
	org	0x0050		;org sets the origin, 0x0000 for the 16F628,
				;this is where the program starts running	

	bcf 	STATUS,RP0 	;Bank 0
	clrf 	PORTA 		;Init PORTA
	bsf 	STATUS,RP0 	;Bank 1
	clrf	ANSEL 		;digital I/O
   	clrf 	TRISC
	clrf	TRISA		;set PortA all outputs to 0
	bcf	STATUS,	RP0	;select bank 0
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;; Timer setup. Registers TMR0 , INTCON, OPTION_REG
	movlw   b'10100000'
	movwf	INTCON      ;setting interrupt for timer 0
	clrf	TMR0        ;setting timer0 duration
	bsf	STATUS,RP0  ;Bank 1
	;Prescaler setup
	;setting timer0 prescaler, and assigning prescaler to timer0
	;scaling is 256. Timer frequency is Fosc/(4*2*65536)
	movlw   b'0000111'
	movwf	OPTION_REG
	;;;;;;End of scaling setup
	bcf	STATUS,	RP0 ;select bank 0
	;;;;;;End of timer setup
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Loop	
	nop				
	nop				
	goto	Loop			

InterruptHandler
    incf    light_state		;increment light state
    btfsc   light_state,3	;additional scaling by 8. If Fosc=4Mhz, blinking period will be 1sec.
    movlw   0x3f		;if light state 3 bit is 0, turn on leds
    btfss   light_state,3
    movlw   0x00		;if light state 3 bit is 1, turn off leds	
    movwf   PORTA
    movwf   PORTC
    clrf  TMR0			;resetting timer
    movlw   b'10100000' 
    movwf  INTCON		;setting interrupt for timer 0
    return
	
	end
