; ECE-222 Lab ... Winter 2018 term 
; Lab 3 sample code 
;
; updated Dec 2017
				THUMB 		; Thumb instruction set 
                AREA 		My_code, CODE, READONLY
                EXPORT 		__MAIN
				ENTRY  
__MAIN

; The following lines are similar to Lab-1 but use a defined address to make it easier.
; They just turn off all LEDs 
				LDR			R10, =LED_BASE_ADR		; R10 is a permenant pointer to the base address for the LEDs, offset of 0x20 and 0x40 for the ports

				MOV 		R3, #0xB0000000		; Turn LED pins to outputs and turn off three LEDs on port 1  
				STR 		R3, [r10, #0x20]
				MOV 		R3, #0x0000007C
				STR 		R3, [R10, #0x40] 	; Turn LED pins to outputs and turn off five LEDs on port 2 

; This line is very important in your main program
; Initializes R11 to a 16-bit non-zero value and NOTHING else can write to R11 !!
				MOV			R11, #0xABCD		; Init the random number generator with a non-zero number
		; NEVER WRITE TO R11 again!!!! or you will break the RandomNum routine from working properly
				
			

;simplecounter
;   			MOV R3, #0
;loop2		ADD R3, R3, #1
;				MOV R0, #1500
;				BL DELAY
				
				
;				BL DISPLAY_NUM
			
;				B loop2




        MOV R9, #0
        MOV R4, #0
        


loop 			BL 			RandomNum 
				MOV R9, #3					; makes R4 around a number between 0 to 100000, 0 to 10 seconds
				MUL R4, R11, R9;
				LSR R4, #1
        MOV R8, #0
				MOV R8, #20000    ;if the value is less than 20000 it tries again with a new random number
				CMP R4,R8
				BLT loop

				MOV R0, R4			; put R4 into R0 for delay

				
				BL DELAY
	
				
				
				MOV R8, #0x90000000	;turning on LED p1.29		; turns on the second left LED 
				STR R8, [R10,#0x20]
				

				MOV R9, #0x0 ;initializing counter to 0		;starts counting time
				MOV R6, #0x00			;initializing pushbutton to off
                STRB R6, [R10, #0x41] 
POLLING			
				MOV R0, #1			; delays for 0.1mS
				BL DELAY
				


				


				LDR R6, =FIO2PIN              
                LDR R6, [R6]    
				
				LSR R6, #10				;checks if the 10th bit of R6 is 1
				BFI R5, R6, #0, #1
				
				MOV R2, R9
				TEQ R5, #0		;if the 10th bit of R6 is 1, pushbutton is pressed
        ADD R9, #1	;increment by 1
				BNE POLLING
				
				
RESET_DISPLAY				
				MOV R9, R2 ;puts the counter back into R2, since R2 is messed up and shifted
				
				MOV R7, #4 ;resets R7 to 4 from 0
				
			

				


DISPLAY_TIME	

				
				MOV R3, #0				;restore R3 to 0
				BFI R3, R9, #0, #8		;put the first 8 bits of R9 into R3 and then display them
				LSR R9, #8 ;shifts 8 bits to the right to display next bits in next loop
				BL DISPLAY_NUM
				
		
				
				MOV R0, #20000	;delay 2s
				BL DELAY
				
				SUBS R7, #1		;go through the next 8 bits
				BNE DISPLAY_TIME
				
				MOV R0, #30000
				BL DELAY ;wait additional 3 seconds after all 32 bits displayed
				
				TEQ R7, #0		;after last 8 bits reset R7 and R9 to start showing from beginning again
				BEQ RESET_DISPLAY	








				B loop

;
; Display the number in R3 onto the 8 LEDs
;
; Useful commands:  RBIT (reverse bits), BFC (bit field clear), LSR & LSL to shift bits left and right, ORR & AND and EOR for bitwise operations
;
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

;
;		Delay 0.1ms (100us) * R0 times
; 		aim for better than 10% accuracy by timing this once, or having done it in Lab 1
;
DELAY			STMFD		R13!,{R2, R14}
		;
		; code to generate a delay of 0.1mS * R0 times
		;
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
				

LED_BASE_ADR	EQU 	0x2009c000 		; Base address of the memory that controls the LEDs 
FIO2PIN         EQU     0x2009c054
PINSEL3			EQU 	0x4002c00c 		; Address of Pin Select Register 3 for P1[31:16]
PINSEL4			EQU 	0x4002c010 		; Address of Pin Select Register 4 for P2[15:0]
;	Usefull GPIO Registers
;	FIODIR  - register to set individual pins as input or output
;	FIOPIN  - register to read and write pins
;	FIOSET  - register to set I/O pins to 1 by writing a 1
;	FIOCLR  - register to clr I/O pins to 0 by writing a 1

;
;  Pseudo Random Number Routine
;
; R11 holds a 16-bit random number via a pseudo-random sequence as per the Linear feedback shift register (Fibonacci) on WikiPedia
; R11 holds a non-zero 16-bit number.  If a zero is fed in the pseudo-random sequence will stay stuck at 0
; Take as many bits of R11 as you need.  If you take the lowest 4 bits then you get a number between 0 and 15 but 16 bits gives you a number between 1 and 0xffff.
;
; R11 MUST be initialized to a non-zero 16-bit value at the start of the program OR ELSE IT WILL STAY at zero
;
; R11 can be read anywhere in the code but must only be written to by this subroutine
;
RandomNum		STMFD		R13!,{R1, R2, R3, R14}

				AND			R1, R11, #0x8000
				AND			R2, R11, #0x2000
				LSL			R2, #2
				EOR			R3, R1, R2
				AND			R1, R11, #0x1000
				LSL			R1, #3
				EOR			R3, R3, R1
				AND			R1, R11, #0x0400
				LSL			R1, #5
				EOR			R3, R3, R1		; the new bit to go into the LSB is present
				LSR			R3, #15
				LSL			R11, #1
				ORR			R11, R11, R3
				MOV			R3, #0xffff		; erase the garbage in the upper 16 bits of R11
				AND			R11, R3
				LDMFD		R13!,{R1, R2, R3, R15}

				ALIGN 

				END 

;-------------POST LAB QUESTIONS---------------------
;1.If a 32-bit register is counting user reaction time in 0.1 milliseconds increments, what is the
;maximum amount of time which can be stored in 8 bits, 16-bits, 24-bits and 32-bits?
;8 bits - 0.0255 seconds
;16 bits - 6.5535 seconds
;24 bits - 1677 seconds
;32 bits - 4294967 seconds
;
;2.- Considering typical human reaction time, which size would be the best for this task (8, 16,
;24, or 32 bits)? 
;human reaction speed is around half a second at the slowest, so 16 bits would be best
;
;