;*-------------------------------------------------------------------
;* Name:    	lab_4_program.s 
;* Purpose: 	A sample style for lab-4
;* Term:	Winter 2018
;
; updated Dec 2017
;*-------------------------------------------------------------------
				THUMB 					; Declare THUMB instruction set 
				AREA 	My_code, CODE, READONLY 	; 
				EXPORT 		__MAIN 			; Label __MAIN is used externally 
				EXPORT 		EINT3_IRQHandler 	; without this export the interupt routine will not be found

				ENTRY 

__MAIN

; The following lines are similar to previous labs.
; Turn off all LEDs by turning them to output pins
				LDR		R10, =LED_BASE_ADR	; R10 is a  pointer to the base address for the LEDs
				MOV 		R3, #0xB0000000		; Turn LED pins to output and turn off three LEDs on port 1  
				STR 		R3, [r10, #0x20]
				MOV 		R3, #0x0000007C
				STR 		R3, [R10, #0x40] 	; Turn LED pins to output and turn off five LEDs on port 2 

	; Enable Interrupts
  MOV R6, #0  ;initializes R6 to 0 so it starts looping Flash
  
  
  
  
	; Enable the EINT3 channel (External INTerrupt 3) which is shared with GPIO interrupts with ISER0 (Interrupt Set Enable 0
	;	Table 52 of the LPC17xx User manual)
	;ISER0			EQU		0xE000E100		; Interrupt Set-Enable Register 0 
  MOV R11, #0x200000 ; from table 52, setting bit 21 to 1
  LDR R10, =ISER0    
  STR R11, [R10]

	; Enable the GPIO interrupt on pin P2.10 for falling edge with IO2IntEnF (IO 2 INTerupt Enable Falling) using Table 117
	;	of the LPC17xx User manual. P2.10 is high when the INT0 button is not pressed.
	;IO2IntEnf		EQU		0x400280B4		; GPIO Interrupt Enable for port 2 Falling Edge 
  MOV R11, #0x400 ; from table 117, setting bit 10 to 1
  LDR R10, =IO2IntEnf 
  STR R11, [R10]

; This line is very important in your main program
; Initialize R11 to a 16-bit non-zero value and NEVER WRITE TO R11 AGAIN !!
				MOV			R11, #0xABCD		; Init the random number generator with a large 16-bit non-zero number
				MOV			R6, #0x0		; initialize R6 to 0, when it is non-zero the button has been pressed

  LDR		R10, =LED_BASE_ADR

  MOV R6, #0      ; initializes R6 as 0 so that FLASH keeps flashing until the INTO button is pressed and R6 value changes.

LOOP 			BL 			RNG 				; keep calling this, and flash the LEDs until the button is pressed to randomize the RNG

	; flash all 8 LEDs between 1 and 10Hz
FLASH  
       BL RNG         ;generates a different value for R11 everytime so that R6 becomes psuedorandom when button is pressed
       MOV R3, #0     ;initializes R6 and R3
       MOV R6, #0
       MOV R3, #0xFF  ;flashes all 8 leds when R6 is 0
       BL DISPLAY_NUM
  
       MOV R0, #1000 ;alternates between all leds on and all leds off to flash 
       BL DELAY
       
       MOV R3, #0x00  
       BL DISPLAY_NUM
        
       MOV R0, #1000 
       BL DELAY

       TEQ R6, #0

       BEQ FLASH
	; When R6 is non-zero stop flashing and display R6 on the 8-LEDs
      
      
       
COUNT_DOWN  
            BL RNG            ;when button is pressed in the middle of displaying R6, it will give a new R6 value and start displaying that instead
            MOV R3, R6        ;when R6 is not 0, display R6 and decrement and display by 10 and display them all.
            BL DISPLAY_NUM

            MOV R0, #10000
            BL DELAY
            
            SUBS R6, R6, #10   
            
            
            
            BMI FLASH ;when R6 is negative, go to flash 
            BEQ FLASH   ;when R6 is 0, go to flash
            B COUNT_DOWN    ; when R6 is positive keep displaying and decrementing 
	; count down R6 by 10 every second and update the display
         
  
  


	; be sure to have BL RNG in your timing loop to keep generating new random numbers

	; when R6 would go to 0 or negative, set R6 to 0 and branch back up to start flashing the LEDs
  
  
			B 			LOOP
				
;*------------------------------------------------------------------- 
; Interrupt Service Routine (ISR) for EINT3_IRQHandler 
;*------------------------------------------------------------------- 
; This ISR handles the interrupt triggered when the INT0 push-button is pressed 
; with the assumption that the interrupt activation is done in the main program
;
; Register R0 to R3 are automatically saved on the stack during an interrupt
;
; This is an interrupt routine - do not call it like a subroutine
;
EINT3_IRQHandler 	
			;		STMFD 		R13!,{,R14}		; Use this command if you need it  
		;
		; Code that handles the interrupt 
		;
   ; MOV R6, #0        ;not sure if needed
    MOV R5, #0x400    ;10th bit
    LDR R7, =IO2INTCLR  ;clears the interrupt for p2.10 by writing 1 to 10th bit 
    STR R5, [R7]
   
   
  
     
      
    
	; generate a new random number between 50 and 250 in R6 from the random number in R11
  ;max is 65355
    MOV R6, #0
    MOV R9, R11       ;Make 16 bit number between 0 and 65355 into a number between 50 and 250 into R6   
    MOV R8, #327      
    SDIV R6, R9,R8
    ADD R6, R6, #50
    
  
	; clear/acknowledge the interrupt using IO2INTCLR
    BX LR
		;			LDMFD 		 		R13!,{,R15}; Use this command if you used STMFD (otherwise use BX LR to return) 
		

;*------------------------------------------------------------------- 
; Subroutine DELAY ... Causes a delay of 100ms * R0 times
;
; re-use your Lab #3 code and scale it for 100ms when R0 = 1
;*------------------------------------------------------------------- 
;
DELAY			STMFD		R13!,{R2, R14}
		;
		; Code to generate a delay of 100mS * R0 times
MULTIPLE_DELAY		TEQ R0, #0		;multiple delays
		BEQ exitDelay
		
		MOV R5, #130 ;delays 0.1mS		;130 gives a delay of 0.1mS
loop1				;loops through 130 times
		SUBS R5, #1
		BNE loop1
		
		SUBS R0, #1		;does the loop1 R0 times
		BEQ exitDelay
		BNE MULTIPLE_DELAY	
exitDelay		LDMFD		R13!,{R2, R15}

;------------------------------------------------------
;DISPLAYS THE NUMBER ON THE LEDS

DISPLAY_NUM		STMFD		R13!,{R1, R2,R3,R7,R5,R6,R9, R14}
;last 5 bits of the number in R3
		MOV R4, #0x0			;initialize R4 to 0
		BFI R4, R3, #0, #5		;stores the last 5 bits in R4
		RBIT R4, R4				;since the bits control the leds in reverse, reverse the bits
		LSR R4, #27				;shift them to the first 5 bits again 
		EOR R4, #0x0000001F		;make the 1's 0's and 0's 1's for only the 5 bits
;		EOR	R4, #0xFFFFFFFF		;invert the bits because 1 is off and 0 is on
		LSL R4, #2				;shift left by 2 because bits 2-6 control the leds
		STR R4, [R10, #0x40]	;store into R10 with offset to control the led
		
;first 3 bits of the number in R3
		LSR R3, #5				;shift right 5 to get the left 3 bits
		MOV R4, #0x0		
		BFI R4, R3, #0, #3		;put the 3 bits into R4
		EOR R4, #0x00000007 ; inverse the rightmost 3 bits.
;		EOR	R4, #0xFFFFFFFF		;inverse the bits
		RBIT R4, R4				;reverse the bits
		
		MOV R5, #0x80000000		;since bit 31, 29 ,28 control the leds, want to move two bits to the right and keep the left one on the left
		AND R5, R5, R4			;gets the 31st bit 
		LSR R4, #1				;shifts the 30th and 29th to 29th and 28th bits
		ADD R4, R4, R5			;puts the 31st bit back into the 31st position
		STR R4, [R10, #0x20]	;store into R10 with offset to control led

          LDMFD		R13!,{R1, R2,R3,R7,R5,R6,R9, R15}
;-------------------------------------------------------          
;-------------------------------------------------------          
;-------------------------------------------------------          


;*------------------------------------------------------------------- 
; Subroutine RNG ... Generates a 16-bit pseudo-Random Number in R11 
;*------------------------------------------------------------------- 
; R11 holds a random number as per the Linear feedback shift register (Fibonacci) on WikiPedia
; R11 MUST be initialized to a large, non-zero 16-bit value at the start of the program
; R11 can be read anywhere in the code but must only be written to by this subroutine
RNG 			STMFD		R13!,{R1-R3, R14} 	; Random Number Generator 
				AND			R1, R11, #0x8000
				AND			R2, R11, #0x2000
				LSL			R2, #2
				EOR			R3, R1, R2
				AND			R1, R11, #0x1000
				LSL			R1, #3
				EOR			R3, R3, R1
				AND			R1, R11, #0x0400
				LSL			R1, #5
				EOR			R3, R3, R1			; The new bit to go into the LSB is present
				LSR			R3, #15
				LSL			R11, #1
				ORR			R11, R11, R3
				MOV			R3, #0xFFFF			; clear the upper 16 bits of R11 as it's garbage
				AND			R11, R3
				LDMFD		R13!,{R1-R3, R15}


				ALIGN 

;*-------------------------------------------------------------------
; Below is a list of useful registers with their respective memory addresses.
;*------------------------------------------------------------------- 
LED_BASE_ADR	EQU 	0x2009c000 		; Base address of the memory that controls the LEDs 
PINSEL3			EQU 	0x4002C00C 		; Pin Select Register 3 for P1[31:16]
PINSEL4			EQU 	0x4002C010 		; Pin Select Register 4 for P2[15:0]
FIO1DIR			EQU		0x2009C020 		; Fast Input Output Direction Register for Port 1 
FIO2DIR			EQU		0x2009C040 		; Fast Input Output Direction Register for Port 2 
FIO1SET			EQU		0x2009C038 		; Fast Input Output Set Register for Port 1 
FIO2SET			EQU		0x2009C058 		; Fast Input Output Set Register for Port 2 
FIO1CLR			EQU		0x2009C03C 		; Fast Input Output Clear Register for Port 1 
FIO2CLR			EQU		0x2009C05C 		; Fast Input Output Clear Register for Port 2 
IO2IntEnf		EQU		0x400280B4		; GPIO Interrupt Enable for port 2 Falling Edge 
ISER0			EQU		0xE000E100		; Interrupt Set-Enable Register 0 
IO2INTCLR			EQU		0x400280AC 		; Interrupt Port 2 Clear Register - find this in the processor manual

				END 
