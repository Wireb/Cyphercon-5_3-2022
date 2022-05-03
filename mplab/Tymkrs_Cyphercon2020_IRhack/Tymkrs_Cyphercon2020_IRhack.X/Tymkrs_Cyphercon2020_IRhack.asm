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
; 07JAN2020 V0 PJS New 

	
#define	CODE_VER_STRING "Peter Shabino 11Jan2020 code for tymkrs Cyphercon 2020 IRhack V0 www.wire2wire.org!" ;Just in ROM !!! update vars below with true level!!
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
; RA0(13)	[ICSPDAT]
; RA1(12)	[ISPCLK]
; RA2(11)	
; RA3(4)	[MCLR] 
; RA4(3)	IR_IN
; RA5(2)	IR_OUT
; RC0(10)	TX
; RC1(9)	RX
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
temp			equ	0x20
						
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
irq_temp		equ	0x71
head			equ	0x72
tail			equ	0x73
 
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
	; check if RX1 IRQ
	;******************************************************************
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	btfss	PIR3, RC1IF			; check if IRQ is currently set
	goto	IRQ_not_RX1
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	btfsc	RC1STA, FERR		; read the reg to pop the bad byte off the stack
	goto	IRQ_RX1_buff_full
	btfss	RC1STA, OERR
	goto	IRQ_RX1_no_OERR
	bcf		RC1STA, CREN		; disable and enable CREN to clear OERR 
	bsf		RC1STA, CREN		
	goto	IRQ_not_RX1
IRQ_RX1_no_OERR		
	; add one to head and check if head = tail if so buffer is full
	incf	head, W
	xorwf	tail, W
	btfsc	STATUS, Z
	goto	IRQ_RX1_buff_full
	; Buffer was not full so inc the head and put the data in the buffer
	movlw	0x21
	movwf	FSR1H
	movf	head, W				
	movwf	FSR1L
	movf	RC1REG, W
	movwf	INDF1
	incf	head, F
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------		
	bsf		PIE3, TX2IE			; enable TX IRQ
	goto	IRQ_not_RX1
IRQ_RX1_buff_full	
	; read the RX reg and discard to prevent errors and clear the IRQ
	movf	RC1REG, W
IRQ_not_RX1	
	
	
	;******************************************************************
	; check if RX2 IRQ
	;******************************************************************
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	btfss	PIR3, RC2IF			; check if IRQ is currently set
	goto	IRQ_not_RX2
	;------------------
	movlw	d'20'
	movwf	BSR		
	;------------------
	btfss	RC2STA, FERR
	goto	IRQ_RX2_no_FERR
	movf	RC2REG, W			; read the reg to pop the bad byte off the stack
	goto	IRQ_not_RX2
IRQ_RX2_no_FERR
	btfss	RC2STA, OERR
	goto	IRQ_RX2_no_OERR
	bcf		RC2STA, CREN		; disable and enable CREN to clear OERR 
	bsf		RC2STA, CREN		
	goto	IRQ_not_RX2
IRQ_RX2_no_OERR		
	movf	RC2REG, W
	movwf	irq_temp
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	movf	irq_temp, W
	movwf	TX1REG				; this link is much faster than RX2 so no worries about overflow. 
IRQ_not_RX2	
	
	;******************************************************************
	; check if TX2 IRQ
	;******************************************************************
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	btfss	PIE3, TX2IE			; if the IRQ is not enabled ignore this check
	goto	IRQ_not_TX2
	btfss	PIR3, TX2IF			; check if IRQ is currently set
	goto	IRQ_not_TX2
	;------------------
	movlw	d'20'
	movwf	BSR		
	;------------------
	movlw	0x21
	movwf	FSR1H
	movf	tail, W				; grab oldest byte in buffer
	movwf	FSR1L
	movf	INDF1, W
	movwf	TX2REG				; send it
	incf	tail, F				; move the tail pointer up one
	; check if this makes head == tail in which case the buffer is empty so disable the TX IRQ until we get more bytes. 
	movf	tail, W
	xorwf	head, W
	btfss	STATUS, Z
	goto	IRQ_not_TX2			; head != tail so still bytes in buffer
	;------------------
	movlw	d'14'
	movwf	BSR		
	;------------------	
	bcf	PIE3, TX2IE				; buffer empty disable Uart2 transmit IRQ	
IRQ_not_TX2
	
	
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
	movlw	0x20				; set RA5 high to turn off IR LED. Rest low
	movwf	LATA			    ; Set4, Set3 to low to turn off leds
	movlw	0x20				
	movwf	LATC			    ; Turn RC5 high to turn off green led, RC4 low to turn on red led. Rest low

	movlw	0x10				; IR_IN is a input, rest outputs (keep unused lines from flotating by driving low)
	movwf	TRISA			    ; 0 = output 
	movlw	0x02				; Set RC1 (RX) as a input, rest outputs (same reason)
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
	
	clrf	head
	clrf	tail

	
	;------------------
	movlw	d'2'
	movwf	BSR		
	;------------------
	; set up uart 2
	movlw	0x20
	movwf	TX1STA					; tx on, 8 bit tx, low baud 
	movlw	0x08
	movwf	BAUD1CON				; Pol normal, 16 bit baud, 
	movlw	0x01
	movwf	SP1BRGH
	movlw	0xA0
	movwf	SP1BRGL					; baud rate for 4800 baud -0.08% off
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
	movlw	d'14'
	movwf	BSR		
	;------------------	
	; set up interupts
;	movlw	0x00
;	iorlw	0x80					; RC2IE (uart)
;	iorlw	0x40					; TX2IE (uart)
;	iorlw	0x20					; RC1IE (uart)
;	iorlw	0x10					; TX1IE (uart)
	movlw	0xA0
	movwf	PIE3
	clrf	PIR3

	
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
	movlw	0x90
	movwf	RC2STA					; UART on, 8 bit rx, CREN on
	
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
	
	;movlw	0x01				; enable weak pull up on portA 0
	;movwf	WPUA				

	; output PPS signals
	movlw	0x03				; CLC3OUT (IR TX)
	movwf	RA5PPS				; IR led
	movlw	0x11				; TX2/CK2 (IR TX)
	movwf	RC4PPS				; RED led (poor mans tx indicator)
	movlw	0x0F				; TX1/CK1 (host TX)
	movwf	RC0PPS				; to host
	movlw	0x0F				; TX1/CK1 (host TX)
	movwf	RC5PPS				; Green led (poor mans rx indicator)
		
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
	goto	MAINLOOP
	
	de	CODE_VER_STRING
			
	;### end of program ###
	end	





