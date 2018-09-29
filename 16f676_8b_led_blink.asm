	include "p16f676.inc"	;include the defaults for the chip
	__config 0x3D14		;sets the configuration settings (oscillator type etc.)
				; HERE SET TO INTERNAL OSCILLATOR 4MHZ

	cblock 	0x20 		;start of general purpose registers
	    light_state
	    milliseconds_L	;milliseconds amount low order 8 bit
	    milliseconds_H	;milliseconds amount high order 8 bit
	    is_measurement_in_process	
	    ;max milliseconds amount is 2^16 - 1 = 65535
	endc
	
	org	0x0004		;interrupt vector
		goto	InterruptController
	
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
	;;;;; Input pins setup
	movlw	0x03		;
	movwf	TRISA		;setting PORTA<0,1> as inputs
	movwf	IOCA		;enabling PORTA<0,1> interrupts-on-change
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;; Timer setup. Registers TMR0 , INTCON, OPTION_REG
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
	
	;;;;; Interrupts setup
	movlw   b'10001000'
	movwf	INTCON      ;setting interrupt for timer 0

Loop	
	nop				
	nop				
	goto	Loop			

InterruptController
	btfsc	INTCON,RAIF	    ;PORTA interrupt case
	goto	PinInterruptHandler
	btfsc	INTCON,T0IE	    ;Timer0 interrupt case
	goto	TimerInterruptHandler
	
    incf    light_state		;increment light state
    btfsc   light_state,3	;additional scaling by 8. If Fosc=4Mhz, blinking period will be 1sec.
    movlw   0x3f		;if light state 3 bit is 0, turn on leds
    btfss   light_state,3
    movlw   0x00		;if light state 3 bit is 1, turn off leds	
    movwf   PORTA
    movwf   PORTC
    clrf    TMR0			;resetting timer
    movlw   b'10100000' 
    movwf   INTCON		;setting interrupt for timer 0
    return
	
    
    PinInterruptHandler
    btfsc   is_measurement_in_process,0
    goto    StartMeasure
    btfss   is_measurement_in_process,0
    goto    EndMeasure
    
    
    TimerInterruptHandler
	end
