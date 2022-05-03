;#########################################################################################################################################################
;Copyright (c) 2020 Peter Shabino
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
; 11JAN2020 V0 PJS New 
; 06May2022 V1 PJS Added support for bicolor led for outhouse

	
#define	CODE_VER_STRING "Peter Shabino 06Mar2022 code for tymkrs Cyphercon 2020 IRbutton V1 www.wire2wire.org!" ;Just in ROM !!! update vars below with true level!!
ver		equ	0x00

; enable debug code 
;#define debug
		
; NOTES
; SAF is high endurance flash (128 words) at the end of flash. Not usable as program space when enabled in config words 
; http://ww1.microchip.com/downloads/en/DeviceDoc/PIC16(L)F15354_55%20Data%20Sheet%2040001853C.pdf	

;****************************************************************************************
; port list [SOIC8]
; Vss(8)
; Vdd(1)
; RA0(7)	[ICSPDAT]	bicolor green led
; RA1(6)	[ISPCLK]	bicolor red led
; RA2(5)	
; RA3(4)	[MCLR] button
; RA4(3)	Red LED
; RA5(2)	IR_OUT
;****************************************************************************************


; PIC16F15313 Configuration Bit Settings
#include "p16f15313.inc"
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
OUTHOUSE_DOOR_DELAY equ d'5'	; delay before code is sent
; Default USER ID to load (2 bytes)
UserID  code 0x8000
    dw 0x02C0

#define button_delay_time  d'15'   ; default = 15	
#define status_byte 0x00 ; 0x00 = normal no con start, 0x01 = con start    	
;#define outhouse    
    
;------------------
; vars (0x20 - 0x6f) bank 0
;------------------
temp			equ	0x20
badge_idL		equ	0x21
badge_idH		equ	0x22
ir_tx_seq		equ 0x23		
ir_chksum		equ 0x24		
						
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
delay_cnt		equ 0x71
		
		
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


	
	;******************************************************************
	; check if Interupt on change IRQ
	;******************************************************************
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	btfss	PIR0, IOCIF
	goto	IRQ_not_IOC
	;------------------
	movlw	d'62'
	movwf	BSR		
	;------------------	
	clrf	IOCAF
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	bcf		PIR0, IOCIF
IRQ_not_IOC	
	
	
	;******************************************************************
	; check if TMR0 IRQ
	;******************************************************************
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	btfss	PIR0, TMR0IF
	goto	IRQ_not_TMR0
	bcf		PIR0, TMR0IF

	; if the delay_cnt is not 0 subtract 1
	movf	delay_cnt, F
	btfss	STATUS, Z
	decf	delay_cnt, F
IRQ_not_TMR0	

	
	
	;******************************************************************
	; check if TX1 IRQ
	;******************************************************************
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	btfss	PIE3, TX1IE			; if the IRQ is not enabled ignore this check
	goto	IRQ_not_TX1
	btfss	PIR3, TX1IF			; check if IRQ is currently set
	goto	IRQ_not_TX1
	;------------------
	clrf	BSR		
	;------------------	
		
	; check if more bytes to send (loop should start with this var set to 0x0C)
	decfsz	ir_tx_seq, F
	goto	IRQ_TX1_send

IRQ_TX1_stop	
	; all bytes sent stop TX
	clrf	ir_tx_seq		; make sure this reg is cleared before exiting.
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	bcf	PIE3, TX1IE			; disable Uart2 transmit IRQ	
	goto	IRQ_not_TX1
	
IRQ_TX1_send	
	movf	ir_tx_seq, W
	xorlw	0x0B
	btfss	STATUS, Z
	goto	IRQ_TX1_send_m
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	movlw	0x53				; S
	movwf	TX1REG
	;------------------
	clrf	BSR		
	;------------------
	goto	IRQ_not_TX1		
IRQ_TX1_send_m
	movf	ir_tx_seq, W
	xorlw	0x0A
	btfss	STATUS, Z
	goto	IRQ_TX1_send_a
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	movlw	0x6D				; m
	movwf	TX1REG
	;------------------
	clrf	BSR		
	;------------------
	goto	IRQ_not_TX1		
IRQ_TX1_send_a
	movf	ir_tx_seq, W
	xorlw	0x09
	btfss	STATUS, Z
	goto	IRQ_TX1_send_s
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	movlw	0x61				; a
	movwf	TX1REG
	;------------------
	clrf	BSR		
	;------------------
	goto	IRQ_not_TX1		

IRQ_TX1_send_s
	movf	ir_tx_seq, W
	xorlw	0x08
	btfss	STATUS, Z
	goto	IRQ_TX1_send_h
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	movlw	0x73				; s
	movwf	TX1REG
	;------------------
	clrf	BSR		
	;------------------
	goto	IRQ_not_TX1		

IRQ_TX1_send_h
	movf	ir_tx_seq, W
	xorlw	0x07
	btfss	STATUS, Z
	goto	IRQ_TX1_send_q
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	movlw	0x68				; h
	movwf	TX1REG
	;------------------
	clrf	BSR		
	;------------------
	goto	IRQ_not_TX1		
	
IRQ_TX1_send_q
	movf	ir_tx_seq, W
	xorlw	0x06
	btfss	STATUS, Z
	goto	IRQ_TX1_send_status
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	movlw	0x3f				; ?
	movwf	TX1REG
	;------------------
	clrf	BSR		
	;------------------
	goto	IRQ_not_TX1		
	
IRQ_TX1_send_status
	movf	ir_tx_seq, W
	xorlw	0x05
	btfss	STATUS, Z
	goto	IRQ_TX1_send_type
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	movlw	status_byte				; status byte
	movwf	TX1REG
	;------------------
	clrf	BSR		
	;------------------
	goto	IRQ_not_TX1		
	
IRQ_TX1_send_type
	movf	ir_tx_seq, W
	xorlw	0x04
	btfss	STATUS, Z
	goto	IRQ_TX1_send_idH
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	movlw	0x00				; standart social ping
	movwf	TX1REG
	;------------------
	clrf	BSR		
	;------------------
	goto	IRQ_not_TX1		
	
IRQ_TX1_send_idH	
	movf	ir_tx_seq, W
	xorlw	0x03
	btfss	STATUS, Z
	goto	IRQ_TX1_send_idL
	clrf	FSR1H
	movlw	badge_idH
	movwf	FSR1L
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	movf	INDF1, W
	movwf	TX1REG
	;------------------
	clrf	BSR		
	;------------------
	goto	IRQ_not_TX1	
	
IRQ_TX1_send_idL	
	movf	ir_tx_seq, W
	xorlw	0x02
	btfss	STATUS, Z
	goto	IRQ_TX1_send_chksum
	clrf	FSR1H
	movlw	badge_idL
	movwf	FSR1L
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	movf	INDF1, W
	movwf	TX1REG
	;------------------
	clrf	BSR		
	;------------------
	goto	IRQ_not_TX1	
	
IRQ_TX1_send_chksum
	movf	ir_tx_seq, W
	xorlw	0x01
	btfss	STATUS, Z
	goto	IRQ_TX1_stop		; if the value is not 1,2,3,4,5,6 then something really bad happened and it should stop now
	movlw	0x3B				; S,m,a,s,h,? chars
	movwf	ir_chksum
	movf	badge_idH, W
	addwf	ir_chksum, F
	movf	badge_idL, W
	addwf	ir_chksum, F
	movlw	status_byte
	addwf	ir_chksum, F
	comf	ir_chksum, F
	incf	ir_chksum, F
	clrf	FSR1H
	movlw	ir_chksum
	movwf	FSR1L
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	movf	INDF1, W
	movwf	TX1REG
	;------------------
	clrf	BSR		
	;------------------
IRQ_not_TX1	
	
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
	movlw	0x20				; set RA5 high to turn off IR LED, RA4 high to turn off the red LED, Rest low
	movwf	LATA			    

	movlw	0x08			; RA3 button is a input, rest outputs (keep unused lines from flotating by driving low)
	movwf	TRISA			    ; 0 = output 

		
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
	movlw	d'2'
	movwf	BSR		
	;------------------
	; set up uart 1
	movlw	0x20
	movwf	TX1STA					; tx on, 8 bit tx, low baud 
	clrf	BAUD1CON				; Pol normal, 8 bit baud, 
	movlw	0xA6
	movwf	SP1BRGL					; baud rate for 3000 baud -0.2% off
	clrf	SP1BRGH
	movlw	0x90
	movwf	RC1STA					; UART on, 8 bit rx, CREN on	
	
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
	movlw	0xF2					; ~1s delay
	movwf	TMR0H
	clrf	TMR0L	
	movlw	0x97					; LFINTOSC 31kHz, no sync, 1:128 prescaler
	movwf	T0CON1
	movlw	0x80					; timer on, 8 bit, 1:1 postscaler
	movwf	T0CON0
	
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	; set up interupts
	movlw	0x20					; TMR0
	movwf	PIE0
	clrf	PIR0
;	movlw	0x00
;	iorlw	0x20					; RC1IE (uart)
;	iorlw	0x10					; TX1IE (uart)
;	movwf	PIE3
;	clrf	PIR3
	
	;------------------
	movlw	d'16'
	movwf	BSR		
	;------------------	
	; get the user ID data (badge ID) 
	clrf	NVMADRH
	clrf	NVMADRL
	movlw	0x41
	movwf	NVMCON1					; read the config space selected
	nop								; instruction requires 1 cycle to complete. (may not be needed but just to be safe.)
	movf	NVMDATL, W
	;------------------
	clrf	BSR		
	;------------------	
	movwf	badge_idL
	;------------------
	movlw	d'16'
	movwf	BSR		
	;------------------	
	movf	NVMDATH, W
	;------------------
	clrf	BSR		
	;------------------	
	movwf	badge_idH
		
	;------------------
	movlw	d'60'
	movwf	BSR		
	;------------------
	; configure CLC for IRDA output	
	movlw	0x13
	movwf	CLC3SEL0				; data 1 PWM5
	movlw	0x1F
	movwf	CLC3SEL1				; data 2 TX1
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
	movlw	0x8E
	movwf	CLC3POL					; inputs 1, 2 normal 3, 4 inverted, and output inverted (direct driving a LED from V+ vs fet driven)
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
	
	;------------------
	movlw	d'62'
	movwf	BSR		
	;------------------	
	clrf	ANSELA				; 0 = digital, 1 = analog 
	
	;movlw	0x01				; enable weak pull up on portA 0
	;movwf	WPUA				

	; output PPS signals
	movlw	0x03				; CLC3OUT (IR TX)
	movwf	RA5PPS				; IR led
	;movlw	0x0F				; RX1/CK1
	;movwf	RA4PPS				; RED led
	
	movlw	0x08
	movwf	IOCAP
	clrf	IOCAN
	clrf	IOCAF
		
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


#ifndef	outhouse	
	; set delay on powerup (prevent short stroke by power reset)
	goto	WAIT_BUTTON_UP
#endif
	
;--------------------------------------------------------------------------------------------------------------------------------------------------	
MAINLOOP
	bsf		LATA, 4
	
#ifndef outhouse		
	;------------------
	movlw	d'62'
	movwf	BSR		
	;------------------	
	clrf	IOCAN
	clrf	IOCAF
	
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	; disable IRQs that should not be checked during sleep
	clrf	PIR0	
	movlw	0x10
	movwf	PIE0

	
	sleep
	
	; turn back on interupts
	movlw	0x20					; TMR0
	movwf	PIE0
	clrf	PIR0	
	
	;------------------
	clrf    BSR					; bank 0
	;------------------	
	
;	btfsc	PORTA, 3
;	goto	MAINLOOP	
	bcf		LATA, 4
	
	
	;Set up transmit seq counter
	movlw	0x0C
	movwf	ir_tx_seq
	; Start TX IRQ
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	bsf	PIE3, TX1IE				; buffer empty disable Uart2 transmit IRQ		
	;------------------
	clrf    BSR					; bank 0
	;------------------

WAIT_TX_DONE
	movf	ir_tx_seq, W
	btfss	STATUS, Z
	goto	WAIT_TX_DONE

	;Set up transmit seq counter
	movlw	0x0C
	movwf	ir_tx_seq
	; Start TX IRQ
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	bsf	PIE3, TX1IE				; buffer empty disable Uart2 transmit IRQ		
	;------------------
	clrf    BSR					; bank 0
	;------------------
	
	

WAIT_BUTTON_UP	
	btfss	PORTA, 3
	goto	WAIT_BUTTON_UP
	

	movlw	button_delay_time  ; d'15'
	movwf	delay_cnt
WAIT_ON_DELAY
	; if button is pressed during cooldown restart the timer
	movlw	button_delay_time  ; d'15'
	btfss	PORTA, 3
	movwf	delay_cnt
	
	movf	delay_cnt, W
	btfss	STATUS, Z
	goto	WAIT_ON_DELAY
	
	
#else
	bcf		LATA, 0	; bi color green (high = on)
	bcf		LATA, 1	; bi color red (high = on)
	
	btfsc	PORTA, 3
	goto	MAINLOOP	
	bcf		LATA, 0	; bi color green (high = on)
	bsf		LATA, 1	; bi color red (high = on)
	bcf		LATA, 4	; red led (low = on)
	
	movlw	OUTHOUSE_DOOR_DELAY
	movwf	delay_cnt
WAIT_DOOR_DELAY
	; if button is released start over
	btfsc	PORTA, 3	; button
	goto	MAINLOOP
	
	movf	delay_cnt, W
	btfss	STATUS, Z
	goto	WAIT_DOOR_DELAY


	bsf		LATA, 0	; bi color green (high = on)
	bcf		LATA, 1	; bi color red (high = on)
	
	
	;Set up transmit seq counter
	movlw	0x0C
	movwf	ir_tx_seq
	; Start TX IRQ
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	bsf	PIE3, TX1IE				; buffer empty disable Uart2 transmit IRQ		
	;------------------
	clrf    BSR					; bank 0
	;------------------

WAIT_TX_DONE2
	movf	ir_tx_seq, W
	btfss	STATUS, Z
	goto	WAIT_TX_DONE2

	;Set up transmit seq counter
	movlw	0x0C
	movwf	ir_tx_seq
	; Start TX IRQ
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	bsf	PIE3, TX1IE				; buffer empty disable Uart2 transmit IRQ		
	;------------------
	clrf    BSR					; bank 0
	;------------------
		
	bsf		LATA, 4
	
WAIT_DOOR_DELAY2
	; if button is released start over
	btfss	PORTA, 3
	goto	WAIT_DOOR_DELAY2	
	
#endif 
	
	goto	MAINLOOP	
	
	
	
	
	de	CODE_VER_STRING
			
	;### end of program ###
	end	








