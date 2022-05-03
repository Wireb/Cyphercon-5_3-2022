;#########################################################################################################################################################
;Copyright (c) 2022 Peter Shabino
;
;Permission is hereby granted, free of charge, to any person obtaining a copy of this hardware, software, and associated documentation files 
;(the "Product"), to deal in the Product without restriction, including without limitation the rights to use, copy, modify, merge, publish, 
;distribute, sublicense, and/or sell copies of the Product, and to permit persons to whom the Product is furnished to do so, subject to the 
;following conditions:
;
;The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Product.
;
;THE PRODUCT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
;MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
;FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
;WITH THE PRODUCT OR THE USE OR OTHER DEALINGS IN THE PRODUCT.
;#########################################################################################################################################################
; 07JAN2020 V0 PJS New 

	
#define	CODE_VER_STRING "Peter Shabino 23Jan2022 code for tymkrs Cyphercon 2020 IRblaster V0 www.wire2wire.org!" ;Just in ROM !!! update vars below with true level!!
ver		equ	0x00

; enable debug code 
;#define debug
		
; NOTES
; SAF is high endurance flash (128 words) at the end of flash. Not usable as program space when enabled in config words 
; http://ww1.microchip.com/downloads/en/DeviceDoc/PIC16(L)F15354_55%20Data%20Sheet%2040001853C.pdf	

;****************************************************************************************
; port list [SOIC14]
; Vss(14)
; Vdd(1)
; RA0(13)	[ICSPDAT] - key switch 
; RA1(12)	[ISPCLK] - endstop
; RA2(11)	
; RA3(4)	[MCLR] 
; RA4(3)	IR_IN - start button
; RA5(2)	IR_OUT
; RC0(10)	TX - motor
; RC1(9)	RX - button LED	
; RC2(8)	
; RC3(7)	
; RC4(6)	Red LED
; RC5(5)	Green LED
;****************************************************************************************


; PIC16F15324 Configuration Bit Settings
#include "p16f15324.inc"
; CONFIG1
; __config 0xFF8C
 __CONFIG _CONFIG1, _FEXTOSC_OFF & _RSTOSC_HFINT32 & _CLKOUTEN_OFF & _CSWEN_ON & _FCMEN_ON
; CONFIG2
; __config 0xF7DC
 __CONFIG _CONFIG2, _MCLRE_OFF & _PWRTE_ON & _LPBOREN_ON & _BOREN_ON & _BORV_LO & _ZCD_OFF & _PPS1WAY_OFF & _STVREN_ON
; CONFIG3
; __config 0xFF9F
 __CONFIG _CONFIG3, _WDTCPS_WDTCPS_31 & _WDTE_OFF & _WDTCWS_WDTCWS_7 & _WDTCCS_SC
; CONFIG4
; __config 0xDFFF
 __CONFIG _CONFIG4, _BBSIZE_BB512 & _BBEN_OFF & _SAFEN_OFF & _WRTAPP_OFF & _WRTB_OFF & _WRTC_OFF & _WRTSAF_OFF & _LVP_OFF
; CONFIG5
; __config 0xFFFE
 __CONFIG _CONFIG5, _CP_ON
 
 
 
;------------------
; constants
;------------------	
IR_PULSE_WIDTH	equ 0x15		; pulse width set to 10% (0x69 = 50%, 0x35 = 25%, 0x15 = 10%, 0x0A = 5%)

;------------------
; vars (0x20 - 0x6f) bank 0
;------------------
delay			equ	0x20
delay0			equ	0x21
delay1			equ	0x22
						
;------------------
; vars (0xA0 - 0xef) bank 1
;------------------

;------------------
; vars (0x120 - 0x16f) bank 2
;------------------
			
;------------------
; vars (0x1A0 - 0x1ef) bank 3
;------------------

;------------------
; vars (0x220 - 0x26f) bank 4
;------------------

;------------------
; vars (0x2A0 - 02xef) bank 5
;------------------

;------------------
; vars (0x320 - 0x32F) bank 6 
;------------------
		
;------------------
; vars (0x70 - 0x7F) global regs
;------------------
gtemp			equ	0x70
 
;put the following at address 0000h
	org     0000h
	goto    START			    ;vector to initialization sequence

;###########################################################################################################################
; intrupt routine
;###########################################################################################################################
	;put the following at address 0004h
	org     0004h	
	; following regs are autosaved
	; W
	; STATUS (except TO and PD)
	; BSR
	; FSR
	; PCLATH
	
	
	retfie
;###########################################################################################################################
; end of IRQ code
;###########################################################################################################################	
	
START
	; init crap
	;------------------
	clrf    BSR					; bank 0
	;------------------
	clrf	INTCON			    ; disable interupts
	movlw	0x00				; set RA5 low to turn off IR LED. Rest low
	movwf	LATA			    ; Set4, Set3 to low to turn off leds
	movlw	0x20				
	movwf	LATC			    ; Turn RC5 high to turn off green led, RC4 low to turn on red led. Rest low

	movlw	0x13				; Button_in, key_in, and endstop_in are inputs, rest outputs (keep unused lines from flotating by driving low)
	movwf	TRISA			    ; 0 = output 
	movlw	0x00				; all as outputs 
	movwf	TRISC			    ; 0 = output	

		
	; clear vars first 80 bytes (control structures) 
	movlw	0x20			; start of bank 0 vars
	movwf	FSR0L
	clrf	FSR0H
	movlw	0x50			; clear all of bank other than globals
	movwf	gtemp
init_bank0_loop
	clrf	INDF0
	incf	FSR0L, F
	decfsz	gtemp, F
	goto	init_bank0_loop
	
	
	;------------------
	movlw	d'5'
	movwf	BSR		
	;------------------
	; set up timer 2 to roll over on a 38kHz period (37.9 something)
	clrf	TMR2
	movlw	0xD3			    ; period reg 
	movwf	PR2
	movlw	0x01			    ; select Fosc/4 as the input clock
	movwf	T2CLKCON
	clrf	T2HLT			    ; mode 0 (free run standard) 
	clrf	T2RST			    ; not used
	movlw	0x80			    ; timer 2 on, 1:1 pre, 1:1 post
	movwf	T2CON

	;------------------
	movlw	d'6'
	movwf	BSR		
	;------------------	
	; set up PWM engine
	movlw	IR_PULSE_WIDTH
	movwf	PWM5DCH
	movlw	0xC0
	movwf	PWM5DCL
	movlw	0x80			    ; engine on, active high
	movwf	PWM5CON

	;------------------
	movlw	d'11'
	movwf	BSR		
	;------------------	
	; Set up TMR0
	movlw	0xF2					; ~0.5s delay
	movwf	TMR0H
	clrf	TMR0L	
	movlw	0x96					; LFINTOSC 31kHz, no sync, 1:64 prescaler
	movwf	T0CON1
	movlw	0x80					; timer on, 8 bit, 1:1 postscaler
	movwf	T0CON0	
	
	;------------------
	movlw	d'20'
	movwf	BSR		
	;------------------
	; set up uart 2
	movlw	0x20
	movwf	TX2STA					; tx on, 8 bit tx, low baud 
	clrf	BAUD2CON				; Pol normal, 8 bit baud, 
	movlw	0xA6
	movwf	SP2BRGL					; baud rate for 3000 baud -0.2% off
	clrf	SP2BRGH
	movlw	0x80
	movwf	RC2STA					; UART on, 8 bit rx, CREN off (rx off)
	
	;------------------
	movlw	d'60'
	movwf	BSR		
	;------------------
	; configure CLC for IRDA output	
	movlw	0x13
	movwf	CLC3SEL0				; data 1 PWM5
	movlw	0x21
	movwf	CLC3SEL1				; data 2 TX2
	movlw	0x13
	movwf	CLC3SEL2				; data 3 PWM5
	movlw	0x13
	movwf	CLC3SEL3				; data 4 PWM5	
	movlw	0x02
	movwf	CLC3GLS0				; data 1 connected to input 1 normal
	movlw	0x08
	movwf	CLC3GLS1				; data 2 connected to input 2 normal
	movlw	0x00
	movwf	CLC3GLS2				; nothing connected to input 3
	movlw	0x00
	movwf	CLC3GLS3				; nothing connected to input 4
;	movlw	0x8E
;	movwf	CLC3POL					; inputs 1, 2 normal 3, 4 inverted, and output inverted (direct driving a LED from V+ vs fet driven)
	movlw	0x0E
	movwf	CLC3POL					; inputs 1, 2 normal 3, 4 inverted, and output not inverted (driving a control line)
	movlw	0x82					; CLC enabled, no IRQs, 4 input 
	movwf	CLC3CON
	
	;------------------
	movlw	d'61'
	movwf	BSR		
	;------------------
	; unlock bits
	movlw	0x55
	movwf	PPSLOCK
	movlw	0xAA
	movwf	PPSLOCK
	bcf		PPSLOCK, PPSLOCKED
	
	; input PPS signals
	movlw	0x04					; RA4
	movwf	RX2DTPPS	
	movlw	0x11					; RC1
	movwf	RX1DTPPS	
	
	;------------------
	movlw	d'62'
	movwf	BSR		
	;------------------	
	clrf	ANSELA				; 0 = digital, 1 = analog 
	clrf	ANSELC				; 0 = digital, 1 = analog 
	
	movlw	0x13				; 1 = enable weak pull up on portA 
	movwf	WPUA				
	;movlw	0x00				; 1 = enable weak pull up on portC
	;movwf	WPUC				

	; output PPS signals
	movlw	0x03				; CLC3OUT (IR TX)
	movwf	RA5PPS				; IR led
	movlw	0x11				; TX2/CK2 (IR TX)
	movwf	RC4PPS				; RED led (poor mans tx indicator)
		
	;------------------
	movlw	d'61'
	movwf	BSR		
	;------------------	
	; lock bits
	movlw	0x55
	movwf	PPSLOCK
	movlw	0xAA
	movwf	PPSLOCK
	bsf		PPSLOCK, PPSLOCKED	
	

	;------------------
	clrf    BSR					; bank 0
	;------------------
	movlw	0xC0
	movwf	INTCON			    ; enable interrupts


	
;--------------------------------------------------------------------------------------------------------------------------------------------------	
MAINLOOP
	btfss	PORTA, 0	; keyswitch
	goto	MOTOR_UP

MOTOR_DOWN	
	; key off lower motor and turn off LED
	bcf		LATC, 0		; motor control 1 = up
	bcf		LATC, 1		; button led control 1 = on	
	goto	MAINLOOP
	
MOTOR_UP	
	bsf		LATC, 0		; motor control 1 = up	
	btfsc	PORTA, 1	; motor end stop
	goto	MAINLOOP
	
MOTOR_END	
	; blink the LED
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	btfss	PIR0, TMR0IF
	goto	LED_NO_BLINK
	bcf		PIR0, TMR0IF
	;------------------
	clrf    BSR					; bank 0
	;------------------
	btfss	LATC, 1
	goto	LED_IS_OFF
	bcf		LATC, 1		; button led control 1 = on
	goto	LED_NO_BLINK	
LED_IS_OFF	
	bsf		LATC, 1		; button led control 1 = on
LED_NO_BLINK	
	;------------------
	clrf    BSR					; bank 0
	;------------------	
	
	btfsc	PORTA, 4	; big green button
	goto	MAINLOOP
	
	
TRANSMIT_CODE	
	bsf		LATC, 1		; button led control 1 = on
	; send ping with start bit from ID 0x02FE (start button) 
	movlw	0x53
	call	_send_ir
	movlw	0x6D
	call	_send_ir
	movlw	0x61
	call	_send_ir
	movlw	0x73
	call	_send_ir
	movlw	0x68
	call	_send_ir
	movlw	0x3F
	call	_send_ir
	movlw	0x01
	call	_send_ir
	movlw	0x00
	call	_send_ir
	movlw	0x02
	call	_send_ir
	movlw	0xFE
	call	_send_ir
	movlw	0xC4
	call	_send_ir
	
	call	_delay
	
	btfsc	PORTA, 0	; keyswitch
	goto	MAINLOOP	
	goto	TRANSMIT_CODE


	
;#########################################################
; Send a byte out the IR link and wait till complete
;#########################################################
_send_ir
	;------------------
	movlb	d'20'
	;------------------
	movwf	TX2REG				; send it
	;------------------
	movlb	d'14'
	;------------------	
TX2_buff_full	
	btfss	PIR3, TX2IF			; check if IRQ is currently set
	goto	TX2_buff_full

	;------------------
	clrf    BSR					; bank 0
	;------------------
	
	return
	
	
;#########################################################
; time delay on tx
;#########################################################
_delay
	call	_delay0
	decfsz	delay, F
	goto	_delay
	
	return	
	
;#########################################################
; time delay on tx
;#########################################################
_delay0
	call	_delay1
	decfsz	delay0, F
	goto	_delay0
	
	return	

;#########################################################
; time delay on tx
;#########################################################
_delay1
	movlw	0x20
	movwf	delay1
_delay1_loop	
	decfsz	delay1, F
	goto	_delay1_loop
	
	return		
	
	de	CODE_VER_STRING
			
	;### end of program ###
	end	








