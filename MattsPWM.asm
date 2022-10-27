$NOMOD51
$NOSYMBOLS
;******************************************************************************
;******************************************************************************
;  Copyright (C) 2007 Silicon Laboratories, Inc.
;  All rights reserved.
;
;  FILE NAME   :  Fundamental_IO.asm 
;  NAME        :  Logan Isler, Matt Davis, Rahu Bannister - Group 4
;  DATE        :  10/06/2014
;  TARGET MCU  :  C8051F340
;  DESCRIPTION :    
;==============================================================================
$NOLIST
$include (c8051f340.inc)                  ; Include register definition file.
$LIST
;******************************************************************************
;******************************************************************************
; EQUATES
;==============================================================================

Setbit bit P2.0
Data3  bit P2.3
Data2  bit P2.2
Data1  bit P2.1

;******************************************************************************
;******************************************************************************
; RESET and INTERRUPT VECTORS
;==============================================================================
            org   0000h               ; Reset Vector
            ljmp  Main                ; Locate a jump to the start of
                                      ; code at the reset vector.

            org   002Bh
						;jmp   SPI0ISR

						org   005Bh
						jmp   PCAISR

						org   0060h

;******************************************************************************
;******************************************************************************
; Main
;
;==============================================================================
Main:       


     anl   PCA0MD,    #0BFh     ;Disables the WDT
     mov   SP,        #7Fh      ;Gets the stack pointer out of the way of 
                                ;RAM addresses
           
     mov  PCA0CN,    #40h     ;enable the PCA counter
     mov  PCA0CPM0,  #42h     ;setup mode0 8-bit PWM
		 mov  XBR1,      #41h     ;set p0.0 as CEX0 for PWM
     mov  PCA0CPL0,  #00h 


;P2 used for serial comm
;4 bit line
;1 bit is setbit
;other 3 bits are data

PWMLoop:
     jnb Setbit, PWMLoop
     call CheckData

CommandStop:
		 cjne R0, #08H, CommandSlow
		 ;stop
     mov PCA0CPH0,  #00h       ;0% duty cycle
CommandSlow:
		 cjne R0, #09H, CommandMed
		 ;slow
     mov  PCA0CPH0,  #99h      ;40% duty cycle
CommandMed:
		 cjne R0, #0AH, CommandFast
		 ;med
		 mov  PCA0CPH0,  #66h      ;60% duty cycle
CommandFast:
		 cjne R0, #0CH, PWMLoop
     ;fast
		 mov  PCA0CPH0,  #33h      ;80% duty cycle
     jmp PWMLoop




;******************************************************************************
;CheckData- Collects the serial data from P2 
;           and saves command to R0
;
;Input Parameters:  P2.1, P2.2, P2.3
;Output Parameters: R0 with hex command
;==============================================================================
CheckData:

mov R0, #08H
push Acc
mov A, R0

CheckBit3:
     mov R3, #00H
		 jnb Data3, CheckBit2
		 mov R3, #01H

CheckBit2:
     mov R2, #00H
		 jnb Data2, CheckBit1
		 mov R2, #01H

CheckBit1:
     mov R1, #00H
		 jnb Data1, CheckBit1
		 mov R1, #01H 
		  

CommandCheck:
     cjne R3, #01H, NoBit3
		 orl  A, #04H

NoBit3:
		 cjne R2, #01H, NoBit2
		 orl A, #02H

NoBit2:
		 cjne R1, #01H, NoBit1
		 orl A, #01H

NoBit1:
pop Acc
ret	

; END OF CHECKDATA SUBROUTINE----------------------------------------------------





 


     








PCAISR:

				reti

;*****************************************************************************
;*****************************************************************************
;END OF THE FILE
;=============================================================================
            end