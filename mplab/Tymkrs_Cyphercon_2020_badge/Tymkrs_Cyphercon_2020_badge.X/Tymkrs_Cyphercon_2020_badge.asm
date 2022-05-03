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
; 12JAN2020 V0 PJS New 
; 09Mar2020 V1 PJS power draw too high swap over to alternate Logo LED patterns	
; 28Mar2021 V2 PJS swapped the oLED init and EEPROM check so we can selfcheck oLED with blank EEPROMs
; 25Jun2021 V3 PJS split the oled init and eeprom check so can init oled before led self test
; 14Mar2022 V4 PJS added code to disable the SPI corrupt led blink when RA0 is shorted to ground (pins 2 and 3 on pickit connector) This resolves the SPI programming corruption I was seeing programing on board. 
; 29Mar2022 V5 PJS changed code to allow llamas/founders to rez badges as well as necrollamacons 
	
	; use all language settings.... 4 space per indent, tab size 4, right margine 80, no expand spaces

	
#define	CODE_VER_STRING "Peter Shabino 29Mar2022 code for tymkrs Cyphercon 2020 badge V5 www.wire2wire.org!" ;Just in ROM !!! update vars below with true level!!
ver		equ	0x00

; enable debug code TODO comment out all before final build
;#define debug
;#define proto
;#define SKIP_EEPROM_TEST
		
; NOTES
; SAF is high endurance flash (128 words) at the end of flash. Not usable as program space when enabled in config words 
; http://ww1.microchip.com/downloads/en/DeviceDoc/PIC16(L)F15354_55%20Data%20Sheet%2040001853C.pdf	

;****************************************************************************************
; port list [SOIC20]
; Vss(20)
; Vdd(1)
; RA0(19)	[ICSPDAT]
; RA1(18)	[ISPCLK]
; RA2(17)	Board ID 0	
; RA3(4)	[MCLR]		button in
; RA4(3)	Board ID 1
; RA5(2)	Board ID 2
; RB4(13)	SCL
; RB5(12)	SDA
; RB6(11)	IR_IN
; RB7(10)	IR_OUT
; RC0(16)	MISO
; RC1(15)	MOSI
; RC2(14)	Sclk
; RC3(7)	oLED_Reset
; RC4(6)	oLED_DC
; RC5(5)	EEPROM_CS
; RC6(8)	oLED_CS
; RC7(9)	Post_CON
;****************************************************************************************


; PIC16F15345 Configuration Bit Settings 
#include "p16f15345.inc"
; CONFIG1
; __config 0xFF8C
 __CONFIG _CONFIG1, _FEXTOSC_OFF & _RSTOSC_HFINT32 & _CLKOUTEN_OFF & _CSWEN_ON & _FCMEN_ON
; CONFIG2
; __config 0xF7DC
; __CONFIG _CONFIG2, _MCLRE_OFF & _PWRTE_ON & _LPBOREN_ON & _BOREN_ON & _BORV_LO & _ZCD_OFF & _PPS1WAY_OFF & _STVREN_ON
 __CONFIG _CONFIG2, _MCLRE_OFF & _PWRTE_OFF & _LPBOREN_ON & _BOREN_ON & _BORV_LO & _ZCD_OFF & _PPS1WAY_OFF & _STVREN_ON
; CONFIG3
; __config 0xFF9F
 __CONFIG _CONFIG3, _WDTCPS_WDTCPS_31 & _WDTE_OFF & _WDTCWS_WDTCWS_7 & _WDTCCS_SC
; CONFIG4
; __config 0xDFEF
 __CONFIG _CONFIG4, _BBSIZE_BB512 & _BBEN_OFF & _SAFEN_ON & _WRTAPP_OFF & _WRTB_OFF & _WRTC_OFF & _WRTSAF_OFF & _LVP_OFF
; CONFIG5
; __config 0xFFFE
#ifdef debug
 __CONFIG _CONFIG5, _CP_OFF
#else
 __CONFIG _CONFIG5, _CP_ON
#endif 
 errorlevel 0	   ; all messages
 errorlevel -302    ; Hide the useless bank switch warnings as every non bank 0 register will generate one even if you use banksel or movlb properly beofore it or not. 
 
 
;------------------
; constants
;------------------	
IR_PULSE_WIDTH	equ 0x15		; pulse width set to 10% (0x69 = 50%, 0x35 = 25%, 0x15 = 10%, 0x0A = 5%)
; Default USER ID to load (2 bytes)
UserID  code 0x8000
    dw 0x0000

; key storage 
start_key	equ 0x9F70	; address of logical (INDF) flash start (note flash address + 0x8000)    
    org 0x1F70 ; 32 bytes to store counters and flags
	de 0x01,0x02,0x03,0x04,0x05,0xF0,0xE0,0xD0, 0xC0,0xA0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF    
    
    
; test code for load from flash storage	/ test modes
start_eeprom	equ 0x9F80	; address of logical (INDF) flash start (note flash address + 0x8000)	
start_eeprom_p	equ 0x1F80	; address of physical flash start 	
    org 0x1F80 ; 32 bytes to store counters and flags
#ifdef debug
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	; 96 bytes to store found objects (max 768 badges)
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF	
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
#else
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	; 96 bytes to store found objects (max 768 badges)
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF	
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	de 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF, 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF	
#endif 
start_buffer		equ 0x2370	; address of start of ram buffer in the linear address map. (INDF)
buffer_length		equ d'128'	; size of buffer
ram_status		equ 0x2370
ram_spent		equ 0x2371
ram_sickID		equ 0x2373
ram_eggID		equ 0x2375
ram_button		equ 0x2377
ram_sleep		equ 0x237A
ram_active		equ 0x237D
ram_hyper		equ 0x2380
ram_prego		equ 0x2383
ram_died		equ 0x2386
ram_food		equ 0x2388
ram_poops		equ 0x238A
ram_knocked		equ 0x238C
ram_questID		equ 0x238E
start_buffer_objs	equ 0x2390	; address of start of ram buffer in the linear address map. (INDF)
objs_length		equ d'96'	; number of bytes in opject buffer
			
start_rx_buffer		equ 0x2320	; address of start of ram buffer in the linear address map. (INDF)

start_spi_buffer	equ 0x22D0	; address of start of ram buffer in the linear address map. (INDF)
		
pink_eye_limit		equ d'50'	; if flags is greater than this value trigger pink eye		

; start of badge ID ranges
standard_badge		equ 0x0000
speaker_badge		equ 0x0200
founder_badge		equ 0x0240
vendor_badge		equ 0x0280
outhouse			equ 0x02A0
snake_oil			equ 0x02C0
necrollamacon		equ 0x02E0
start_button		equ 0x02EF
vendo				equ 0x02FF
				
crypto_rounds		equ d'26'
crypto_wbytes		equ d'5'
crypto_bbytes		equ d'10'
				
; game mech
hyper_to_active		equ d'300'	; seconds
active_to_sleep		equ d'600'	; seconds
game_tick_time		equ d'45'	; seconds
food_hyper			equ d'4'	; food per tick
food_active			equ d'1'	; food per tick
food_hyper_sick		equ d'6'	; food per tick
food_active_sick	equ d'2'	; food per tick
food_startup		equ d'255'	; food units
poo_startup			equ d'0'	; poo units
food_warn			equ d'81'	; food units
poo_warn			equ d'128'	; poo units
food2poop			equ d'3'	; how many food units needed to create a poop 
		
; LED settings
icon_pwms			equ 0xff	; pwm setting for 3 icon leds
heart_led_sleep		equ 0x1F	; off time (in TMR0 tics minus ~4)
heart_led_active	equ 0x0F	; off time (in TMR0 tics minus ~4)
heart_led_hyper		equ 0x04	; off time (in TMR0 tics minus ~4)
LOGO_SPEED			equ 0x2FF	; how many mainloops before update in non uber mode	
POSTCON_MODE_TIME	equ 0xFF	; how many 1/4s to wait before changing postcon display
	
; animation vars
Hyr0n_animation		    equ	d'13'		    ; last in the set
LAST_PRE_Hyr0n_animation    equ	(Hyr0n_animation - 1)
    
	
;------------------
; vars (0x20 - 0x6f) bank 0
;------------------
temp			equ	0x20		; use set or variable instead?
temp1			equ 0x21
i2c_off			equ 0x22
i2c_dat0		equ 0x23
seq_cnt			equ	0x24
offset			equ 0x25	
countL			equ	0x26
countH			equ 0x27
time_phase		equ	0x28
delay_downH		equ	0x29
delay_downL		equ 0x2A
time_passed		equ 0x2B
badge_status	equ	0x2C		; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
heart_seq		equ 0x2D
logo_r			equ 0x2E
logo_g			equ 0x2F
logo_b			equ	0x30
logo_a			equ 0x31
LFSR_0			equ	0x32		
LFSR_1			equ	0x33		
LFSR_2			equ	0x34		
LFSR_3			equ	0x35
LFSR_count		equ	0x36	
sparkle_last	equ 0x37	
sparkle_skip	equ 0x38
badge_ctrl		equ 0x39		; bit 0 = logo tick , bit 1 = poo led, bit 2 = postcon mode, bit 3 = egg up/down
button_up		equ 0x3A
food_cnt		equ	0x3B
poo_cnt			equ	0x3C
game_tick		equ	0x3D	
logo_cntL		equ 0x3E
logo_cntH		equ 0x3F
poo_temp		equ 0x40
oLED_phase		equ	0x41
oLED_delay		equ	0x42
oLED_set		equ	0x43
oLED_dt			equ 0x44		; delay temp
oLED_seq_cnt	equ	0x45
oLED_seq_addr0	equ	0x46
oLED_seq_addr1	equ	0x47
oLED_seq_addr2	equ	0x48
oLED_ctrl		equ	0x49		; bit 0 = one shot start, 1 = one shot done
oLED_last		equ	0x4A
egg_breath		equ 0x4B		
egg_delay		equ 0x4C	
logo_seq		equ	0x4D		
	
	
;------------------
; vars (0xA0 - 0xef) bank 1
;------------------

;------------------
; vars (0x120 - 0x16f) bank 2
;------------------
ir_rx_seq		equ 0x120
ir_rx_chksum	equ 0x121		
rx_status		equ 0x122	
rx_type			equ 0x123
rx_data_seq		equ 0x124			
rx_idH			equ 0x125
rx_idL			equ 0x126
ir_tx_seq		equ 0x127		
ir_tx_chksum	equ 0x128		
tx_status		equ 0x129
tx_type			equ 0x12A
badge_idL		equ 0x12B
badge_idH		equ 0x12C	
ir_offset		equ 0x12D
ir_temp			equ 0x12E
ir_temp1		equ 0x12F
tx_data			equ 0x130		
tx_delay		equ 0x131
tx_delay2		equ 0x132	
loop_i			equ 0x133
k0				equ 0x134
loop_j			equ 0x135
crypt_cnt		equ 0x136		
c0				equ 0x137
ak				equ 0x138
ak1				equ 0x139
ak2				equ 0x13A
ak3				equ 0x13B
ac				equ 0x13C
ac1				equ 0x13D
ac2				equ 0x13E
ac3				equ 0x13F						
temp_key0		set 0x140		
temp_key1		equ 0x141		
temp_key2		equ 0x142		
temp_key3		equ 0x143		
temp_key4		equ 0x144		
temp_key5		equ 0x145		
temp_key6		equ 0x146		
temp_key7		equ 0x147		
temp_key8		equ 0x148		
temp_key9		equ 0x149
onceH			equ	0x14A		
onceL			equ	0x14B	
Hyr0nH			equ	0x14C
Hyr0nL			equ	0x14D
			
temp_crypt0		set 0x150		
temp_crypt1		equ 0x151		
temp_crypt2		equ 0x152		
temp_crypt3		equ 0x153		
temp_crypt4		equ 0x154		
temp_crypt5		equ 0x155		
temp_crypt6		equ 0x156		
temp_crypt7		equ 0x157		
temp_crypt8		equ 0x158		
temp_crypt9		equ 0x159
		
		
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
g_temp			equ 0x70
g_flags			equ 0x71		; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off, bit 3 = enable TX delay, bit 4 = Hyron badge ID set, bit 5 = undead
current_bsr		equ 0x72			
delay_cnt		equ 0x73
		
		


		
		
			
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

	
	movlp	0x00				; clear out the PCLATH so jumps in the IRQ do not go to la la land... 
	
	;******************************************************************
	; check if TMR0 IRQ
	;******************************************************************
	;------------------
	movlb	d'14'
	;------------------	
	btfss	PIR0, TMR0IF
	goto	IRQ_not_TMR0
	bcf		PIR0, TMR0IF

	; if the delay_cnt is not 0 subtract 1
	movf	delay_cnt, F
	btfss	STATUS, Z
	decf	delay_cnt, F
	
	;------------------
	movlb	d'0'
	;------------------	
	bsf	badge_ctrl, 0			; set the badge tick bit (used for logo timeing) 
	; break down the sub time tics into slower units of S
	movlw	0x01
	subwf	time_phase, F			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, Z
	goto	IRQ_not_TMR0
	; reset this counter for the next cycle
	movlw	0x04
	movwf	time_phase
	
	; update reg used for running counter updates
	incf	time_passed, F
	
	; dec game timer
	movf	game_tick, W
	btfsc	STATUS,Z
	goto	IRQ_TMR0_skip_game_tick
	decf	game_tick, F
IRQ_TMR0_skip_game_tick
	
	; dec the downshift counter if running. 
	; if already zero do nothing
	movf	delay_downH, W
	btfss	STATUS,Z
	goto	IRQ_TMR0_sub_down
	movf	delay_downL, W
	btfsc	STATUS,Z
	goto	IRQ_not_TMR0
IRQ_TMR0_sub_down	
	; maths 
	movlw	0x01
	subwf	delay_downL, F			; f - W, C = 0 if W > f, C = 1 if W <= f	
	btfss	STATUS, C
	decf	delay_downH, F
IRQ_not_TMR0	

	;******************************************************************
	; check if TMR1 IRQ
	;******************************************************************
	;------------------
	movlb	d'14'
	;------------------	
	btfss	PIR4, TMR1IF
	goto	IRQ_not_TMR1
	bcf		PIR4, TMR1IF
	;------------------
	movlb	d'0'
	;------------------	
	; if oLED_delay is zero do nothing. 
	movf	oLED_delay, W
	btfsc	STATUS, Z
	goto	IRQ_not_TMR1_oLED
	; if timer is running and oLED_phase = 0 set it back to the roll over value 
	movf	oLED_phase, W
	movlw	0x03				; movw does not affect status
	btfsc	STATUS, Z
	movwf	oLED_phase
	decfsz	oLED_phase, F
	goto	IRQ_not_TMR1_oLED
	decf	oLED_delay, F	
IRQ_not_TMR1_oLED
	
	movf	egg_delay, W
	btfsc	STATUS, Z
	goto	IRQ_not_TMR1_egg
	decf	egg_delay, F
IRQ_not_TMR1_egg	
IRQ_not_TMR1		

	;******************************************************************
	; check if RX1 IRQ
	;******************************************************************
	;------------------
	movlb	d'14'
	;------------------	
	btfss	PIR3, RC1IF			; check if IRQ is currently set
	goto	IRQ_not_RX1
	;------------------
	movlb	d'2'
	;------------------
	btfss	RC1STA, FERR
	goto	IRQ_RX1_no_FERR
	movf	RC1REG, W			; read the reg to pop the bad byte off the stack
	goto	IRQ_not_RX1
IRQ_RX1_no_FERR
	btfss	RC1STA, OERR
	goto	IRQ_RX1_no_OERR
	bcf		RC1STA, CREN		; disable and enable CREN to clear OERR 
	bsf		RC1STA, CREN		
	goto	IRQ_not_RX1
IRQ_RX1_no_OERR		
	; header check
	movf	ir_rx_seq, W
	btfss	STATUS, Z
	goto	IRQ_RX1_sq1
	movf	RC1REG, W
	xorlw	0x53				; S
	btfss	STATUS, Z
	goto	IRQ_RX1_bad
	incf	ir_rx_seq, F
	goto	IRQ_not_RX1
IRQ_RX1_sq1		
	movf	ir_rx_seq, W
	xorlw	0x01
	btfss	STATUS, Z
	goto	IRQ_RX1_sq2
	movf	RC1REG, W
	xorlw	0x6D				; m
	btfss	STATUS, Z
	goto	IRQ_RX1_bad
	incf	ir_rx_seq, F
	goto	IRQ_not_RX1
IRQ_RX1_sq2	
	movf	ir_rx_seq, W
	xorlw	0x02
	btfss	STATUS, Z
	goto	IRQ_RX1_sq3
	movf	RC1REG, W
	xorlw	0x61				; a
	btfss	STATUS, Z
	goto	IRQ_RX1_bad
	incf	ir_rx_seq, F
	goto	IRQ_not_RX1
IRQ_RX1_sq3
	movf	ir_rx_seq, W
	xorlw	0x03
	btfss	STATUS, Z
	goto	IRQ_RX1_sq4
	movf	RC1REG, W
	xorlw	0x73				; s
	btfss	STATUS, Z
	goto	IRQ_RX1_bad
	incf	ir_rx_seq, F
	goto	IRQ_not_RX1
IRQ_RX1_sq4
	movf	ir_rx_seq, W
	xorlw	0x04
	btfss	STATUS, Z
	goto	IRQ_RX1_sq5
	movf	RC1REG, W
	xorlw	0x68				; h
	btfss	STATUS, Z
	goto	IRQ_RX1_bad
	incf	ir_rx_seq, F
	goto	IRQ_not_RX1
IRQ_RX1_sq5
	movf	ir_rx_seq, W
	xorlw	0x05
	btfss	STATUS, Z
	goto	IRQ_RX1_sq6
	movf	RC1REG, W
	xorlw	0x3f				; ?
	btfss	STATUS, Z
	goto	IRQ_RX1_bad
	incf	ir_rx_seq, F
	movlw	0x3B				; S,m,a,s,h,? chars
	movwf	ir_rx_chksum	
	goto	IRQ_not_RX1
IRQ_RX1_sq6
	; status byte
	movf	ir_rx_seq, W
	xorlw	0x06
	btfss	STATUS, Z
	goto	IRQ_RX1_sq7
	movf	RC1REG, W
	movwf	rx_status
	addwf	ir_rx_chksum, F
	incf	ir_rx_seq, F
	goto	IRQ_not_RX1
IRQ_RX1_sq7	
	; type byte
	movf	ir_rx_seq, W
	xorlw	0x07
	btfss	STATUS, Z
	goto	IRQ_RX1_sq8
	movf	RC1REG, W
	movwf	rx_type
	addwf	ir_rx_chksum, F
	incf	ir_rx_seq, F
	movf	rx_type, W
	btfss	STATUS, Z
	goto	IRQ_RX1_type0_len
	clrf	rx_data_seq			; type 0 has no data
	goto	IRQ_not_RX1
IRQ_RX1_type0_len
	movf	rx_type, W
	xorlw	0x01
	btfss	STATUS, Z
	goto	IRQ_RX1_type1_len
	clrf	rx_data_seq			; type 1 has no data
	goto	IRQ_not_RX1
IRQ_RX1_type1_len	
;	movf	rx_type, W
;	xorlw	0x02
;	btfss	STATUS, Z
;	goto	IRQ_RX1_type2_len
;	movlw	d'134'
;	movwf	rx_data_seq			; type 2 has 134 bytes of data
;	goto	IRQ_RX1_inc_seq
;IRQ_RX1_type2_len	
	movf	rx_type, W
	xorlw	0x03
	btfss	STATUS, Z
	goto	IRQ_RX1_type3_len
	movlw	0x0A
	movwf	rx_data_seq			; type 3 has 10 bytes of data
	goto	IRQ_not_RX1
IRQ_RX1_type3_len	
;	movf	rx_type, W
;	xorlw	0x04
;	btfss	STATUS, Z
;	goto	IRQ_RX1_type4_len
;	movlw	0x0A
;	movwf	rx_data_seq			; type 4 has 10 bytes of data
;	goto	IRQ_not_RX1
;IRQ_RX1_type4_len		
	movf	rx_type, W
	xorlw	0x05
	btfss	STATUS, Z
	goto	IRQ_RX1_type5_len
	movlw	0x02
	movwf	rx_data_seq			; type 5 has 2 bytes of data
	goto	IRQ_not_RX1
IRQ_RX1_type5_len	
	movf	rx_type, W
	xorlw	0x06
	btfss	STATUS, Z
	goto	IRQ_RX1_type6_len
	movlw	0x02
	movwf	rx_data_seq			; type 6 has 2 bytes of data
	goto	IRQ_not_RX1
IRQ_RX1_type6_len	
	movf	rx_type, W
	xorlw	0x07
	btfss	STATUS, Z
	goto	IRQ_RX1_type7_len
	movlw	0x03
	movwf	rx_data_seq			; type 7 has 3 bytes of data
	goto	IRQ_not_RX1
IRQ_RX1_type7_len	
;	movf	rx_type, W
;	xorlw	0x08
;	btfss	STATUS, Z
;	goto	IRQ_RX1_type8_len
;	movlw	0x03
;	movwf	rx_data_seq			; type 8 has 1 bytes of data
;	goto	IRQ_not_RX1
;IRQ_RX1_type8_len		
	movf	rx_type, W
	xorlw	0x09
	btfss	STATUS, Z
	goto	IRQ_RX1_type9_len
	movlw	0x04
	movwf	rx_data_seq			; type 9 has 4 bytes of data
	goto	IRQ_not_RX1
IRQ_RX1_type9_len	
	movf	rx_type, W
	xorlw	0x0A
	btfss	STATUS, Z
	goto	IRQ_RX1_typeA_len
	movlw	0x02
	movwf	rx_data_seq			; type A has 2 bytes of data
	goto	IRQ_not_RX1
IRQ_RX1_typeA_len	
	movf	rx_type, W
	xorlw	0x0B
	btfss	STATUS, Z
	goto	IRQ_RX1_typeB_len
	movlw	0x02
	movwf	rx_data_seq			; type B has 2 bytes of data
	goto	IRQ_not_RX1
IRQ_RX1_typeB_len	
	movf	rx_type, W
	xorlw	0x0C
	btfss	STATUS, Z
	goto	IRQ_RX1_typeC_len
	clrf	rx_data_seq			; type C has no data
	goto	IRQ_not_RX1
IRQ_RX1_typeC_len	
	
	movf	rx_type, W
	xorlw	0xde
	btfss	STATUS, Z
	goto	IRQ_RX1_typeDE_len
	movlw	0x04
	movwf	rx_data_seq			; type de has 4 bytes of data
	goto	IRQ_not_RX1
IRQ_RX1_typeDE_len	
	
	goto	IRQ_RX1_bad			; all other values are invalid 
	
IRQ_RX1_sq8	
	; ID bytes
	movf	ir_rx_seq, W
	xorlw	0x08
	btfss	STATUS, Z
	goto	IRQ_RX1_sq9
	movf	RC1REG, W
	movwf	rx_idH
	addwf	ir_rx_chksum, F
	incf	ir_rx_seq, F
	goto	IRQ_not_RX1
IRQ_RX1_sq9
	movf	ir_rx_seq, W
	xorlw	0x09
	btfss	STATUS, Z
	goto	IRQ_RX1_sq10
	movf	RC1REG, W
	movwf	rx_idL
	addwf	ir_rx_chksum, F
	incf	ir_rx_seq, F
	; check if this is a echo from this badge if so drop it like it is hot. 
	movf	rx_idH, W
	xorwf	badge_idH, W
	btfss	STATUS, Z
	goto	IRQ_not_RX1
	movf	rx_idL, W
	xorwf	badge_idL, W
	btfss	STATUS, Z
	goto	IRQ_not_RX1
	goto	IRQ_RX1_bad
IRQ_RX1_sq10
	; read in data bytes based on type
	movf	ir_rx_seq, W
	xorlw	0x0A
	btfss	STATUS, Z
	goto	IRQ_RX1_sq11
	movf	rx_data_seq, W
	btfsc	STATUS, Z
	goto	IRQ_RX1_sq10_skip
	movlw	high(start_rx_buffer)	
	movwf	FSR1H
	movlw	low(start_rx_buffer)
	addwf	rx_data_seq, W
	movwf	FSR1L	
	decf	FSR1L, F
	; NOTE register alignment is such that it should never roll the upper byte
	movf	RC1REG, W
	movwf	INDF1
	addwf	ir_rx_chksum, F
	decfsz	rx_data_seq, F
	goto	IRQ_not_RX1
	incf	ir_rx_seq, F	
	goto	IRQ_not_RX1
IRQ_RX1_sq10_skip
	incf	ir_rx_seq, F
IRQ_RX1_sq11
	; validate checksum
	movf	ir_rx_seq, W
	xorlw	0x0B
	btfss	STATUS, Z
	goto	IRQ_RX1_bad			; packet out of seq somehow
	movf	RC1REG, W
	addwf	ir_rx_chksum, F
	movf	ir_rx_chksum, W
	btfss	STATUS, Z			; if the checksum result is 0 all is good. 
	goto	IRQ_RX1_bad
	
	
	
	;------------------------------------------------------------------------
	; Weird packets (id out of range like badge reset) 
	;------------------------------------------------------------------------
	; clear badge ram
	movf	rx_type, W
	xorlw	0xDE
	btfss	STATUS, Z
	goto	IRQ_RX1_no_clear
	movf	rx_idH, W
	xorlw	0xAD
	btfss	STATUS, Z
	goto	IRQ_RX1_no_clear
	movf	rx_idL, W
	xorlw	0xBE
	btfss	STATUS, Z
	goto	IRQ_RX1_no_clear
	movlw	high(start_rx_buffer)	
	movwf	FSR1H
	movlw	low(start_rx_buffer)
	movwf	FSR1L
	moviw	FSR1++
	xorlw	0xA2
	btfss	STATUS, Z
	goto	IRQ_RX1_no_clear
	moviw	FSR1++
	xorlw	0xD6
	btfss	STATUS, Z
	goto	IRQ_RX1_no_clear
	moviw	FSR1++
	xorlw	0x29
	btfss	STATUS, Z
	goto	IRQ_RX1_no_clear
	moviw	FSR1++
	xorlw	0xEF
	btfss	STATUS, Z
	goto	IRQ_RX1_no_clear
	
	movlw	high(start_buffer)
	movwf	FSR0H				; address of first ram reg
	movlw	low(start_buffer)
	movwf	FSR0L	
	movlw	buffer_length
	movwf	ir_temp
IRQ_RX1_clear_loop
	movlw	0xFF
	movwi	FSR0++
	decfsz	ir_temp, F
	goto	IRQ_RX1_clear_loop
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0		
	;------------------
	movlb	d'0'
	;------------------
	clrf	badge_status
	clrf	food_cnt
	clrf	poo_cnt
	clrf	poo_temp
	; CFG add other state / game counter updates here for badge clear
	;------------------
	movlb	d'2'
	;------------------	
	
	
IRQ_RX1_no_clear	
	
	
	; verify if badge ID is in range (breaks many things otherwise
	movf	rx_idH, W
	sublw	0x03			; k - W, C = 0 if W > k, C = 1 if W <= k	
	btfss	STATUS, C
	goto	IRQ_RX1_bad
	btfsc	STATUS, Z
	goto	IRQ_RX1_bad
	;------------------------------------------------------------------------
	; stuff always valid (con start packet)
	;------------------------------------------------------------------------
	
	; HBDH set packet
	movf	rx_type, W
	xorlw	0x05
	btfss	STATUS, Z
	goto	IRQ_RX1_not_HBDH		
	movlw	high(start_rx_buffer)	
	movwf	FSR1H
	movlw	low(start_rx_buffer)
	movwf	FSR1L
	moviw	FSR1++
	movwf	Hyr0nL	
	moviw	FSR1++
	movwf	Hyr0nH
	bsf		g_flags, 4			; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off, bit 3 = enable TX delay; bit 4 = Hyron badge ID set	
IRQ_RX1_not_HBDH	
	
	
	; check if Hyr0n
	btfss	g_flags, 4			; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off, bit 3 = enable TX delay; bit 4 = Hyron badge ID set	
	goto	IRQ_RX1_not_Hyr0n
	movf	rx_idH, W
	xorwf	Hyr0nH, W
	btfss	STATUS, Z
	goto	IRQ_RX1_not_Hyr0n
	movf	rx_idL, W
	xorwf	Hyr0nL, W
	btfss	STATUS, Z
	goto	IRQ_RX1_not_Hyr0n
	; set animation 
	;------------------
	movlb	d'0'
	;------------------	
	movf	oLED_ctrl, W
	andlw	0x03
	btfss	STATUS, Z
	goto	IRQ_RX1_not_Hyr0n_norm
	movf	oLED_set, W
	movwf	oLED_last	
IRQ_RX1_not_Hyr0n_norm	
	bsf		oLED_ctrl, 0			; bit 0 = one shot start, 1 = one shot done
	movlw	Hyr0n_animation
	movwf	oLED_set				; new set to move to 
	clrf	oLED_delay				; stop the counter update first then clear the internal phase
	clrf	oLED_phase
	clrf	oLED_seq_cnt	
	;------------------
	movlb	d'2'
	;------------------	

	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfsc	INDF1, 7
	goto	IRQ_RX1_not_Hyr0n
	bsf		INDF1, 7			; set badge back to alive
	;------------------
	movlb	d'0'
	;------------------
	; set animation 
	movlw	0x06
	movwf	oLED_last				; new set to move to 
	movf	INDF1, W				;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	andlw	0x06
	xorlw	0x04					; check if badge has pink eye but has not been cured yet. 
	btfsc	STATUS, Z
	incf	oLED_last, F
	
	movlw	0x02				; Set initial condition of the badge on con start to active as it will instantly pop to sleeping since delay counters are cleared. 
	movwf	badge_status
	clrf	delay_downH
	clrf	delay_downL
	movlw	food_startup
	movwf	food_cnt
	movlw	poo_startup
	movwf	poo_cnt
	movwf	poo_temp
	; CFG add other state / game counter updates here on res
	;------------------
	movlb	d'2'
	;------------------		
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off
	bsf		g_flags, 1	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off
	bsf		g_flags, 2	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off
	
IRQ_RX1_not_Hyr0n
	
	
	
	; con start check
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfss	rx_status, 0		; con start bit
	goto	IRQ_RX1_no_con_start
	btfss	INDF1, 0			; check if con has already started if so skip (saves eeprom writes)
	goto	IRQ_RX1_no_con_start	
	bcf		INDF1, 0
	;------------------
	movlb	d'0'
	;------------------
	movlw	0x02				; Set initial condition of the badge on con start to active as it will instantly pop to sleeping since delay counters are cleared. 
	movwf	badge_status
	clrf	delay_downH
	clrf	delay_downL
	movlw	food_startup
	movwf	food_cnt
	movlw	poo_startup
	movwf	poo_cnt
	movwf	poo_temp
	; CFG add other state / game counter updates here for start of con. 
	;------------------
	movlb	d'2'
	;------------------	
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0	
IRQ_RX1_no_con_start	

	
	; check packet is from Vendo else ignore
	movf	rx_idH, W
	xorlw	0x02
	btfss	STATUS, Z
	goto	IRQ_RX1_not_vendo
	movf	rx_idL, W
	xorlw	0xFF
	btfss	STATUS, Z
	goto	IRQ_RX1_not_vendo
	
	
	; check if this is a dump request 
	movf	rx_type, W
	xorlw	0x01
	btfss	STATUS, Z
	goto	IRQ_RX1_not_type1	
	;------------------
	movlb	d'14'
	;------------------	
	btfsc	PIE3, TX1IE				; make sure TX routine is NOT already running. 
	goto	IRQ_RX1_not_type1
	;------------------
	movlb	d'2'
	;------------------	
	clrf	ir_tx_seq
	clrf	ir_tx_chksum
	; status updated other places just flow it here
	movlw	0x02
	movwf	tx_type		
	bsf		g_flags, 3				; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off, bit 3 = enable TX delay
	;------------------
	movlb	d'14'
	;------------------	
	bsf	PIE3, TX1IE				; enable Uart2 transmit IRQ			
IRQ_RX1_not_type1
	;------------------
	movlb	d'2'
	;------------------	
	
	; check if this is a credit request
	movf	rx_type, W
	xorlw	0x03
	btfss	STATUS, Z
	goto	IRQ_RX1_not_type3
	movlp	0x10
	goto	DECRYPT_PACKET			; jump to lower page as this one is full....
IRQ_RX1_not_type3
	
	
	; check if this is a quest start
	movf	rx_type, W
	xorlw	0x06
	btfss	STATUS, Z
	goto	IRQ_RX1_not_type6
	movlw	high(start_rx_buffer)	
	movwf	FSR1H
	movlw	low(start_rx_buffer)
	movwf	FSR1L
	moviw	FSR1++
	xorwf	badge_idL, W	
	btfss	STATUS, Z
	goto	IRQ_RX1_not_type6
	moviw	FSR1++
	xorwf	badge_idH, W	
	btfss	STATUS, Z
	goto	IRQ_RX1_not_type6
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfss	INDF1, 4
	goto	IRQ_RX1_not_type6
	bcf		INDF1, 4			; Set quest start
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0			
IRQ_RX1_not_type6
	
	
	; check if this is a egg drop request
	movf	rx_type, W
	xorlw	0x09
	btfss	STATUS, Z
	goto	IRQ_RX1_not_type9
	movlw	high(start_rx_buffer)	
	movwf	FSR1H
	movlw	low(start_rx_buffer)
	movwf	FSR1L
	movlw	high(ram_eggID)	
	movwf	FSR0H
	movlw	low(ram_eggID)
	movwf	FSR0L	
	incf	FSR0L, F
	comf	INDF0, W			; invert value from flash
	xorwf	INDF1, W
	btfss	STATUS, Z
	goto	IRQ_RX1_not_type9
	decf	FSR0L, F
	incf	FSR1L, F
	comf	INDF0, W			; invert value from flash
	xorwf	INDF1, W
	btfss	STATUS, Z
	goto	IRQ_RX1_not_type9
	moviw	++FSR1
	xorwf	badge_idL, W	
	btfss	STATUS, Z
	goto	IRQ_RX1_not_type9
	moviw	++FSR1
	xorwf	badge_idH, W	
	btfss	STATUS, Z
	goto	IRQ_RX1_not_type9
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfsc	INDF1, 3
	goto	IRQ_RX1_not_type9
	bsf		INDF1, 3			; Set don't have egg
	; save the ID of who you got an egg from
	movlw	high(ram_eggID)	
	movwf	FSR1H
	movlw	low(ram_eggID)
	movwf	FSR1L	
	movlw	0xFD				; comp id of vendo
	movwi	FSR1++
	movlw	0x00				; comp id of vendo
	movwf	INDF1		
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0		
IRQ_RX1_not_type9

	
	; check if this is a uber request
	movf	rx_type, W
	xorlw	0x0A
	btfss	STATUS, Z
	goto	IRQ_RX1_not_typeA
	movlw	high(start_rx_buffer)	
	movwf	FSR1H
	movlw	low(start_rx_buffer)
	movwf	FSR1L
	moviw	FSR1++
	xorwf	badge_idL, W	
	btfss	STATUS, Z
	goto	IRQ_RX1_not_typeA
	moviw	FSR1++
	xorwf	badge_idH, W	
	btfss	STATUS, Z
	goto	IRQ_RX1_not_typeA
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfss	INDF1, 6
	goto	IRQ_RX1_not_type9
	bcf		INDF1, 6			; Set uber mode
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0			
IRQ_RX1_not_typeA

	
	; check if this is a quest end
	movf	rx_type, W
	xorlw	0x0B
	btfss	STATUS, Z
	goto	IRQ_RX1_not_typeB
	movlw	high(start_rx_buffer)	
	movwf	FSR1H
	movlw	low(start_rx_buffer)
	movwf	FSR1L
	moviw	FSR1++
	xorwf	badge_idL, W	
	btfss	STATUS, Z
	goto	IRQ_RX1_not_typeB
	moviw	FSR1++
	xorwf	badge_idH, W	
	btfss	STATUS, Z
	goto	IRQ_RX1_not_typeB
	; make sure they have done the quest
	movlw	high(ram_questID)	
	movwf	FSR1H
	movlw	low(ram_questID)
	movwf	FSR1L	
	moviw	FSR1++
	xorlw	0xFD
	btfss	STATUS, Z
	goto	IRQ_RX1_not_typeB
	comf	INDF1, W
	btfsc	STATUS, Z			; not the exact range check but close enough to make sure it is not 0x0000
	goto	IRQ_RX1_not_typeB
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfss	INDF1, 5
	goto	IRQ_RX1_not_typeB
	bcf		INDF1, 5			; Set quest start
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0			
IRQ_RX1_not_typeB
	
	
IRQ_RX1_not_vendo	
		
	
	; check for rez when badge is dead
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfsc	INDF1, 7
	goto	IRQ_RX1_ignore_alive

	
	; check if badge is dead, on the quest and gets a llama badge
	; check if badge number is less than this range
	movlw	high(founder_badge)
	subwf	rx_idH, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_ignore_founder
	btfss	STATUS, Z			; if greater than limit skip to next check
	goto	IRQ_RX1_FOUNDER_QUEST1
	movlw	low(founder_badge)
	subwf	rx_idL, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_ignore_founder
IRQ_RX1_FOUNDER_QUEST1
	; check if badge number is less than this range
	movlw	high(vendor_badge)
	subwf	rx_idH, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_FOUNDER_QUEST2
	btfss	STATUS, Z			; if greater than limit skip to next check
	goto	IRQ_RX1_ignore_founder
	movlw	low(vendor_badge)
	subwf	rx_idL, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfsc	STATUS, C
	goto	IRQ_RX1_ignore_founder
IRQ_RX1_FOUNDER_QUEST2	
	
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfsc	INDF1, 4
	goto	IRQ_RX1_ignore_quest
	btfss	INDF1, 5
	goto	IRQ_RX1_ignore_quest
	bsf	INDF1, 5		; Set Quest
	; save the ID of who you got the quest token from
	movlw	high(ram_questID)	
	movwf	FSR1H
	movlw	low(ram_questID)
	movwf	FSR1L	
	comf	rx_idH, W		; Badge ID to save
	movwi	FSR1++
	comf	rx_idL, W		; Badge ID to save
	movwf	INDF1		
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0	
IRQ_RX1_ignore_quest
	goto	IRQ_RX1_NECROLLAMACON
IRQ_RX1_ignore_founder
	
	
	; check if badge number is less than this range
	movlw	high(necrollamacon)
	subwf	rx_idH, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_ignore_necro
	btfss	STATUS, Z			; if greater than limit skip to next check
	goto	IRQ_RX1_NECRO_CHK
	movlw	low(necrollamacon)
	subwf	rx_idL, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_ignore_necro
IRQ_RX1_NECRO_CHK
	; check if badge number is less than this range
	movlw	high(vendo)
	subwf	rx_idH, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_NECROLLAMACON
	btfss	STATUS, Z			; if greater than limit skip to next check
	goto	IRQ_RX1_ignore_necro
	movlw	low(vendo)
	subwf	rx_idL, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfsc	STATUS, C
	goto	IRQ_RX1_ignore_necro
IRQ_RX1_NECROLLAMACON	
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L		
	bsf		INDF1, 7			; set badge back to alive
	;------------------
	movlb	d'0'
	;------------------
	; set animation 
	movlw	0x06
	movwf	oLED_set				; new set to move to 
	movf	INDF1, W				;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	andlw	0x06
	xorlw	0x04					; check if badge has pink eye but has not been cured yet. 
	btfsc	STATUS, Z
	incf	oLED_set, F
	clrf	oLED_delay				; stop the counter update first then clear the internal phase
	clrf	oLED_phase
	clrf	oLED_seq_cnt	
	
	movlw	0x02				; Set initial condition of the badge on con start to active as it will instantly pop to sleeping since delay counters are cleared. 
	movwf	badge_status
	clrf	delay_downH
	clrf	delay_downL
	movlw	food_startup
	movwf	food_cnt
	movlw	poo_startup
	movwf	poo_cnt
	movwf	poo_temp
	; CFG add other state / game counter updates here on res
	;------------------
	movlb	d'2'
	;------------------		
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off
	bsf		g_flags, 1	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off
	bsf		g_flags, 2	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off
	;goto	IRQ_RX1_ignore_necro
	
IRQ_RX1_ignore_necro	
IRQ_RX1_ignore_alive	
	
		
	; check if con is started, badge is not dead, and not sleeping
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	movf	INDF1, W
	andlw	0x01				; con started?
	btfss	STATUS, Z
	goto	IRQ_RX1_ignore_ns_dead_asleep
	; check if badge is dead	
	movf	INDF1, W
	andlw	0x80				; is badge dead
	btfsc	STATUS, Z
	goto	IRQ_RX1_ignore_ns_dead_asleep
	
	; trigger mine?
	movf	rx_type, W
	xorlw	0x0C
	btfss	STATUS, Z
	goto	IRQ_RX1_not_mine
	; set animation 
	;------------------
	movlb	d'0'
	;------------------	
	movf	oLED_ctrl, W
	andlw	0x03
	btfss	STATUS, Z
	goto	IRQ_RX1_not_mine_norm
	movf	oLED_set, W
	movwf	oLED_last	
IRQ_RX1_not_mine_norm	
	bsf	oLED_ctrl, 0				; bit 0 = one shot start, 1 = one shot done
	movlw	0x0C					; mine?
	movwf	oLED_set				; new set to move to 
	clrf	oLED_delay				; stop the counter update first then clear the internal phase
	clrf	oLED_phase
	clrf	oLED_seq_cnt	
	;------------------
	movlb	d'2'
	;------------------	
IRQ_RX1_not_mine	
	
	; check if badge is sleeping
	;------------------
	movlb	d'0'
	;------------------
	movf	badge_status, W
	;------------------
	movlb	d'2'
	;------------------	
	andlw	0x03
	xorlw	0x01
	btfsc	STATUS, Z
	goto	IRQ_RX1_ignore_ns_dead_asleep
		
	;------------------------------------------------------------------------
	; stuff here that is only valid when not dead, or sleeping, and con start (most things)
	;------------------------------------------------------------------------
	
	; see if this is a new badge ID
	movf	rx_idL, W
	movwf	ir_offset
	movf	rx_idH, W
	movwf	ir_temp
	rrf		ir_temp, F
	rrf		ir_offset, F
	rrf		ir_temp, F
	rrf		ir_offset, F
	bcf		STATUS, C
	rrf		ir_offset, F
	movlw	high(start_buffer_objs)
	movwf	FSR1H
	movf	ir_offset, W
	addlw	low(start_buffer_objs)
	movwf	FSR1L
	movf	INDF1,W
	movwf	ir_temp1
	movf	rx_idL, W
	andlw	0x07
	addlw	0x01
	movwf	ir_temp
IRQ_RX1_SHIFT_TEMP
	rrf		ir_temp1, F
	decfsz	ir_temp, F
	goto	IRQ_RX1_SHIFT_TEMP
	btfss	STATUS, C
	goto	IRQ_RX1_OLD_ID
	; new badge found!!
	; increment the counts 
	;------------------
	movlb	d'0'
	;------------------
	incf	countL, F
	btfsc	STATUS,Z
	incf	countH, F
	; check count for pink eye
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	movf	INDF1, W
	andlw	0x02				; check if badge already got pink eye if so skip this check
	btfsc	STATUS, Z
	goto	IRQ_RX1_NOT_PINK_EYE
	;movf	countH, W			; should not matter at all since above check will skip this if already triggered once. 
	;btfss	STATUS, Z
	;goto	IRQ_RX1_NOT_PINK_EYE	
	movf	countL, W
	sublw	pink_eye_limit		; k - W, C = 0 if W > k, C = 1 if W <= k	
	btfsc	STATUS, C
	goto	IRQ_RX1_NOT_PINK_EYE
	bcf	INDF1, 1			; trigger pink eye
	; save this badge id to reg since badge made its self sick
	movlw	high(ram_sickID)	
	movwf	FSR1H
	movlw	low(ram_sickID)
	movwf	FSR1L	
	;------------------
	movlb	d'2'
	;------------------
	comf	badge_idH, W			; invert value for flash save (will be inverted again before sending out)
	movwi	FSR1++
	comf	badge_idL, W			; invert value for flash save (will be inverted again before sending out)
	movwf	INDF1	
IRQ_RX1_NOT_PINK_EYE
	;------------------
	movlb	d'2'
	;------------------
	; set badge as found in ram
	movf	rx_idL, W
	movwf	ir_offset
	movf	rx_idH, W
	movwf	ir_temp
	rrf		ir_temp, F
	rrf		ir_offset, F
	rrf		ir_temp, F
	rrf		ir_offset, F
	bcf		STATUS, C
	rrf		ir_offset, F
	movlw	high(start_buffer_objs)
	movwf	FSR1H
	movf	ir_offset, W
	addlw	low(start_buffer_objs)
	movwf	FSR1L
	; take the low 3 bits rotate 1 left (jump 2 for each) then branch
	rlf		rx_idL, W
	andlw	0x0E
	brw
	bcf		INDF1, 0
	goto	IRQ_RX1_ID_UPDATE_DONE	
	bcf		INDF1, 1
	goto	IRQ_RX1_ID_UPDATE_DONE	
	bcf		INDF1, 2
	goto	IRQ_RX1_ID_UPDATE_DONE	
	bcf		INDF1, 3
	goto	IRQ_RX1_ID_UPDATE_DONE	
	bcf		INDF1, 4
	goto	IRQ_RX1_ID_UPDATE_DONE	
	bcf		INDF1, 5
	goto	IRQ_RX1_ID_UPDATE_DONE	
	bcf		INDF1, 6
	goto	IRQ_RX1_ID_UPDATE_DONE	
	bcf		INDF1, 7
;	goto	IRQ_RX1_ID_UPDATE_DONE		
IRQ_RX1_ID_UPDATE_DONE	
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0
IRQ_RX1_OLD_ID
	
	; update things here based on status bits
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfss	rx_status, 1		; sick bit
	goto	IRQ_RX1_NOT_SICK
	; this check is not needed as next will only let this path set sick once (save some code space)
	;btfss	INDF1, 2			; check if badge has been cured if so don't get sick again
	;goto	IRQ_RX1_NOT_SICK
	btfss	INDF1, 1			; check if badge is currenly sick (reduce eeprom writes)
	goto	IRQ_RX1_NOT_SICK
	bcf		INDF1, 1			; if already sick this will result in no change so don't care
	; save the ID of who you got sick from
	movlw	high(ram_sickID)	
	movwf	FSR1H
	movlw	low(ram_sickID)
	movwf	FSR1L	
	comf	rx_idH, W			; invert value for flash save (will be inverted again before sending out)
	movwi	FSR1++
	comf	rx_idL, W			; invert value for flash save (will be inverted again before sending out)
	movwf	INDF1	
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0
IRQ_RX1_NOT_SICK	
	
	; check if badge number is less than this range
	movlw	high(speaker_badge)
	subwf	rx_idH, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_BADGE_CHK_DONE		; normal badge...
	btfss	STATUS, Z			; if greater than limit skip to next check
	goto	IRQ_RX1_FOUNDER_CHK
	movlw	low(speaker_badge)
	subwf	rx_idL, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_BADGE_CHK_DONE		; normal badge...
IRQ_RX1_FOUNDER_CHK
	; check if badge number is less than this range
	movlw	high(founder_badge)
	subwf	rx_idH, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_SPEAKER
	btfss	STATUS, Z			; if greater than limit skip to next check
	goto	IRQ_RX1_VENDOR_CHK
	movlw	low(founder_badge)
	subwf	rx_idL, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_SPEAKER
IRQ_RX1_VENDOR_CHK
	; check if badge number is less than this range
	movlw	high(vendor_badge)
	subwf	rx_idH, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_FOUNDER
	btfss	STATUS, Z			; if greater than limit skip to next check
	goto	IRQ_RX1_OUTHOUSE_CHK
	movlw	low(vendor_badge)
	subwf	rx_idL, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_FOUNDER
IRQ_RX1_OUTHOUSE_CHK
	; check if badge number is less than this range
	movlw	high(outhouse)
	subwf	rx_idH, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_VENDOR
	btfss	STATUS, Z			; if greater than limit skip to next check
	goto	IRQ_RX1_SNAKE_CHK
	movlw	low(outhouse)
	subwf	rx_idL, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_VENDOR
IRQ_RX1_SNAKE_CHK
	; check if badge number is less than this range
	movlw	high(snake_oil)
	subwf	rx_idH, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_OUTHOUSE
	btfss	STATUS, Z			; if greater than limit skip to next check
	goto	IRQ_RX1_NECROLLAMACON_CHK
	movlw	low(snake_oil)
	subwf	rx_idL, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_OUTHOUSE
IRQ_RX1_NECROLLAMACON_CHK
	; check if badge number is less than this range
	movlw	high(necrollamacon)
	subwf	rx_idH, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_SNAKE
	btfss	STATUS, Z			; if greater than limit skip to next check
	goto	IRQ_RX1_VENDO_CHK
	movlw	low(necrollamacon)
	subwf	rx_idL, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	IRQ_RX1_SNAKE
IRQ_RX1_VENDO_CHK
	movlw	high(vendo)
	xorwf	rx_idH, W
	btfss	STATUS, C
	goto	IRQ_RX1_BADGE_CHK_DONE
	movlw	low(vendo)
	xorwf	rx_idL, W
	btfss	STATUS, C
	goto	IRQ_RX1_BADGE_CHK_DONE	
	
IRQ_RX1_VENDO
	movf	rx_type, W
	xorlw	0x07				; request food
	btfss	STATUS, Z
	goto	IRQ_RX1_BADGE_CHK_DONE
	movlw	high(start_rx_buffer)	
	movwf	FSR1H
	movlw	low(start_rx_buffer)
	movwf	FSR1L
	; first byte in buffer = last sent so in this case # of food 
	movlw	food_warn			; check if badge already starving and calculate excess food. 
	;------------------
	movlb	d'0'
	;------------------	
	subwf	food_cnt, W			; f - W, C = 0 if W > f, C = 1 if W <= f	
	;------------------
	movlb	d'2'
	;------------------	
	btfss	STATUS, C			; if less than 0 badge already starving abort feeding
	goto	IRQ_RX1_BADGE_CHK_DONE	
	subwf	INDF1, W			; f - W, C = 0 if W > f, C = 1 if W <= f		
	btfsc	STATUS, C			; if less than 0 badge already starving abort feeding
	goto	IRQ_RX1_BADGE_CHK_DONE	
	moviw	++FSR1
	xorwf	badge_idL, W	
	btfss	STATUS, Z
	goto	IRQ_RX1_BADGE_CHK_DONE
	moviw	++FSR1
	xorwf	badge_idH, W	
	btfss	STATUS, Z
	goto	IRQ_RX1_BADGE_CHK_DONE
	; subtract off the current poop counter from max and save as new food value. 
	;------------------
	movlb	d'14'
	;------------------	
	btfsc	PIE3, TX1IE				; make sure TX routine is NOT already running. 
	goto	IRQ_RX1_VENDO_tx_busy
	;------------------
	movlb	d'0'
	;------------------	
	moviw	--FSR1
	moviw	--FSR1
	subwf	food_cnt, F			; f - W, C = 0 if W > f, C = 1 if W <= f	
	;------------------
	movlb	d'2'
	;------------------	
	clrf	ir_tx_seq
	clrf	ir_tx_chksum
	; status updated other places just flow it here
	movlw	0x08
	movwf	tx_type		
	bsf		g_flags, 3				; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off, bit 3 = enable TX delay
	;------------------
	movlb	d'14'
	;------------------	
	bsf	PIE3, TX1IE				; enable Uart2 transmit IRQ			
IRQ_RX1_VENDO_tx_busy
	;------------------
	movlb	d'2'
	;------------------	
	goto	IRQ_RX1_BADGE_CHK_DONE
	
IRQ_RX1_SPEAKER	
	; code here for when you see a speaker badge
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	movf	INDF1, W
	andlw	0x08				; check if already has an egg
	btfsc	STATUS, Z
	goto	IRQ_RX1_BADGE_CHK_DONE
	bcf		INDF1, 3			; Set have egg
	; save the ID of who you got an egg from
	movlw	high(ram_eggID)	
	movwf	FSR1H
	movlw	low(ram_eggID)
	movwf	FSR1L	
	comf	rx_idH, W			; invert value for flash save (will be inverted again before sending out)
	movwi	FSR1++
	comf	rx_idL, W			; invert value for flash save (will be inverted again before sending out)
	movwf	INDF1		
	; update the knocked up counter
	movlw	high(ram_knocked)	
	movwf	FSR0H
	movlw	low(ram_knocked)
	movwf	FSR0L		
	call	_2BYTE_DEC_N_STOP
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0	
	goto	IRQ_RX1_BADGE_CHK_DONE

	
IRQ_RX1_FOUNDER	
	goto	IRQ_RX1_BADGE_CHK_DONE
	
IRQ_RX1_VENDOR
	; subtract off the current poop counter from max and save as new food value.  
	;------------------
	movlb	d'0'
	;------------------	
	movf	poo_cnt, W
	sublw	0xFF		; k - W  C = 0 when W > k, C = 1 when W <= K
	movwf	food_cnt	
	bsf	g_flags, 1	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off
	; set animation 	
	movf	oLED_ctrl, W
	andlw	0x03
	btfss	STATUS, Z
	goto	IRQ_RX1_not_feedme_norm
	movf	oLED_set, W
	movwf	oLED_last	
IRQ_RX1_not_feedme_norm	
	bsf	oLED_ctrl, 0				; bit 0 = one shot start, 1 = one shot done
	movlw	0x0C					; mine?
	movwf	oLED_set				; new set to move to 
	clrf	oLED_delay				; stop the counter update first then clear the internal phase
	clrf	oLED_phase
	clrf	oLED_seq_cnt	
	;------------------
	movlb	d'2'
	;------------------	
	movlw	high(ram_food)	
	movwf	FSR0H
	movlw	low(ram_food)
	movwf	FSR0L		
	call	_2BYTE_DEC_N_STOP	
	goto	IRQ_RX1_BADGE_CHK_DONE

IRQ_RX1_OUTHOUSE
	; clear the poop counter
	;------------------
	movlb	d'0'
	;------------------	
	clrf	poo_cnt
	clrf	poo_temp
	bsf		g_flags, 2	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off
	;------------------
	movlb	d'2'
	;------------------	
	; update the pooped counter
	movlw	high(ram_poops)	
	movwf	FSR0H
	movlw	low(ram_poops)
	movwf	FSR0L		
	call	_2BYTE_DEC_N_STOP
	; code here for when you see a outhouse button
	goto	IRQ_RX1_BADGE_CHK_DONE
	
IRQ_RX1_SNAKE	
	; code here for when you see a snake oil button
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	movf	INDF1, W
	andlw	0x02				; check count for pink eye (if not sick no effect)
	btfss	STATUS, Z
	goto	IRQ_RX1_BADGE_CHK_DONE
	movf	INDF1, W
	andlw	0x04				; check if badge already has cure if so skip (save EEPROM writes)
	btfsc	STATUS, Z
	goto	IRQ_RX1_BADGE_CHK_DONE
	bcf		INDF1, 2			; Set cure rcvd
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0	
	;goto	IRQ_RX1_BADGE_CHK_DONE
IRQ_RX1_BADGE_CHK_DONE	
	
IRQ_RX1_ignore_ns_dead_asleep	
	
	
IRQ_RX1_bad
	; something was not right reset the rx seq and the checksum reg
	clrf	ir_rx_seq
	clrf	ir_rx_chksum
IRQ_not_RX1	
	
	
	;******************************************************************
	; check if TX1 IRQ
	;******************************************************************
	;------------------
	movlb	d'14'
	;------------------	
	btfss	PIE3, TX1IE			; if the IRQ is not enabled ignore this check
	goto	IRQ_not_TX1
	btfss	PIR3, TX1IF			; check if IRQ is currently set
	goto	IRQ_not_TX1
	;------------------
	movlb	d'0'
	;------------------
	; if in postcon disable IR transmitter else bogus data may cause game issues. 
	btfsc	badge_ctrl, 2	    ; bit 0 = logo tick , bit 1 = poo led, bit 2 = postcon mode	
	goto	IRQ_TX1_done
	;------------------
	movlb	d'2'
	;------------------
	; IR header	
	movf	ir_tx_seq, W
	btfss	STATUS, Z
	goto	IRQ_TX1_sq1
	; check if this is a response to another packet if so delay a bit before starting so RX path does not get confused. 
	btfss	g_flags, 3				; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off, bit 3 = enable TX delay
	goto	IRQ_TX1_no_delay
	clrf	tx_delay2
	clrf	tx_delay
IRQ_TX1_delay
	decfsz	tx_delay, F
	goto	IRQ_TX1_delay
	decfsz	tx_delay2, F
	goto	IRQ_TX1_delay
IRQ_TX1_no_delay
	bcf		g_flags, 3				; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off, bit 3 = enable TX delay
	; your normal programing
	movlw	0x53				; S
	movwf	TX1REG
	incf	ir_tx_seq, F
	goto	IRQ_not_TX1		
IRQ_TX1_sq1	
	movf	ir_tx_seq, W
	xorlw	0x01
	btfss	STATUS, Z
	goto	IRQ_TX1_sq2
	movlw	0x6D				; m
	movwf	TX1REG
	incf	ir_tx_seq, F
	goto	IRQ_not_TX1		
IRQ_TX1_sq2	
	movf	ir_tx_seq, W
	xorlw	0x02
	btfss	STATUS, Z
	goto	IRQ_TX1_sq3
	movlw	0x61				; a
	movwf	TX1REG
	incf	ir_tx_seq, F
	goto	IRQ_not_TX1		
IRQ_TX1_sq3
	movf	ir_tx_seq, W
	xorlw	0x03
	btfss	STATUS, Z
	goto	IRQ_TX1_sq4
	movlw	0x73				; s
	movwf	TX1REG
	incf	ir_tx_seq, F
	goto	IRQ_not_TX1		
IRQ_TX1_sq4
	movf	ir_tx_seq, W
	xorlw	0x04
	btfss	STATUS, Z
	goto	IRQ_TX1_sq5
	movlw	0x68				; h
	movwf	TX1REG
	incf	ir_tx_seq, F
	goto	IRQ_not_TX1		
IRQ_TX1_sq5
	movf	ir_tx_seq, W
	xorlw	0x05
	btfss	STATUS, Z
	goto	IRQ_TX1_sq6
	movlw	0x3f				; ?
	movwf	TX1REG
	incf	ir_tx_seq, F
	movlw	0x3B				; S,m,a,s,h,? chars
	movwf	ir_tx_chksum		
	goto	IRQ_not_TX1		
IRQ_TX1_sq6
	; status bits
	movf	ir_tx_seq, W
	xorlw	0x06
	btfss	STATUS, Z
	goto	IRQ_TX1_sq7
	; build up status packet
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	clrf	tx_status
	btfss	INDF1, 0
	bsf		tx_status, 0		; con start bit
	btfss	INDF1, 1
	bsf		tx_status, 1		; sick
	btfss	INDF1, 2
	bcf		tx_status, 1		; sick but was cured (clear the bit I just set)
	
	; other status bits here
	
	movf	tx_status, W				
	movwf	TX1REG
	addwf	ir_tx_chksum, F
	incf	ir_tx_seq, F
	goto	IRQ_not_TX1		
IRQ_TX1_sq7	
	; packet type
	movf	ir_tx_seq, W
	xorlw	0x07
	btfss	STATUS, Z
	goto	IRQ_TX1_sq8
	movf	tx_type, W				
	movwf	TX1REG
	addwf	ir_tx_chksum, F
	incf	ir_tx_seq, F
	clrf	tx_data	
	goto	IRQ_not_TX1		
IRQ_TX1_sq8
	; badge ID
	movf	ir_tx_seq, W
	xorlw	0x08
	btfss	STATUS, Z
	goto	IRQ_TX1_sq9
	movf	badge_idH, W				
	movwf	TX1REG
	addwf	ir_tx_chksum, F
	incf	ir_tx_seq, F
	goto	IRQ_not_TX1		
IRQ_TX1_sq9
	movf	ir_tx_seq, W
	xorlw	0x09
	btfss	STATUS, Z
	goto	IRQ_TX1_sq10
	movf	badge_idL, W				
	movwf	TX1REG
	addwf	ir_tx_chksum, F
	incf	ir_tx_seq, F
	goto	IRQ_not_TX1		
IRQ_TX1_sq10
	; data
	movf	ir_tx_seq, W
	xorlw	0x0A
	btfss	STATUS, Z
	goto	IRQ_TX1_sq11
	; check what type of packet is to be sent. 
	movf	tx_type, W
	xorlw	0x02
	btfsc	STATUS, Z
	goto	IRQ_TX1_sq10_type2	; type 2 dump
	movf	tx_type, W
	xorlw	0x04
	btfsc	STATUS, Z
	goto	IRQ_TX1_sq10_type4	; type 4 credit return
	movf	tx_type, W
	xorlw	0x08
	btfsc	STATUS, Z
	goto	IRQ_TX1_sq10_type8	; type 8 food request accepted
	incf	ir_tx_seq, F		; Type 0 ping no data to transmit
	goto	IRQ_TX1_sq11		
	
IRQ_TX1_sq10_type2
	movf	tx_data, W
	xorlw	d'128'				; food byte
	btfss	STATUS, Z	
	goto	IRQ_TX1_sq10_type1_nfood
	;------------------
	movlb	d'0'
	;------------------	
	movf	food_cnt, W
	;------------------
	movlb	d'2'
	;------------------	
	movwf	TX1REG
	addwf	ir_tx_chksum, F	
	incf	tx_data, F
	goto	IRQ_not_TX1		
IRQ_TX1_sq10_type1_nfood	
	movf	tx_data, W
	xorlw	d'129'				; poo
	btfss	STATUS, Z	
	goto	IRQ_TX1_sq10_type1_npoo
	;------------------
	movlb	d'0'
	;------------------	
	movf	poo_cnt, W
	;------------------
	movlb	d'2'
	;------------------	
	movwf	TX1REG
	addwf	ir_tx_chksum, F	
	incf	tx_data, F
	goto	IRQ_not_TX1		
IRQ_TX1_sq10_type1_npoo	
	movf	tx_data, W
	xorlw	d'130'				; badge interal state (last byte of data to send)
	btfss	STATUS, Z	
	goto	IRQ_TX1_sq10_type1_nstate
	;------------------
	movlb	d'0'
	;------------------		
	movf	badge_status, W
	;------------------
	movlb	d'2'
	;------------------		
	movwf	TX1REG
	addwf	ir_tx_chksum, F	
	incf	tx_data, F
	goto	IRQ_not_TX1		
IRQ_TX1_sq10_type1_nstate	
	movf	tx_data, W
	xorlw	d'131'				; badge interal state (last byte of data to send)
	btfss	STATUS, Z	
	goto	IRQ_TX1_sq10_type1_nstate1
	;------------------
	movlb	d'0'
	;------------------		
	movf	badge_ctrl, W
	;------------------
	movlb	d'2'
	;------------------		
	movwf	TX1REG
	addwf	ir_tx_chksum, F	
	incf	tx_data, F
	goto	IRQ_not_TX1			
IRQ_TX1_sq10_type1_nstate1	
	movf	tx_data, W
	xorlw	d'132'				; once high byte
	btfss	STATUS, Z	
	goto	IRQ_TX1_sq10_type1_nonceh
	;------------------
	movlb	d'0'
	;------------------		
	call	_CYCLE_LFSR16		; when in precon mode LFSR is not running. Prevent predictive ONCE values even in that case. 
	movf	LFSR_0, W			
	;------------------
	movlb	d'2'
	;------------------
	movwf	onceH
	movwf	TX1REG
	addwf	ir_tx_chksum, F	
	incf	tx_data, F
	goto	IRQ_not_TX1			
IRQ_TX1_sq10_type1_nonceh	
	movf	tx_data, W
	xorlw	d'133'				; once low byte
	btfss	STATUS, Z	
	goto	IRQ_TX1_sq10_type1_nctl
	;------------------
	movlb	d'0'
	;------------------		
	movf	LFSR_1, W			
	;------------------
	movlb	d'2'
	;------------------
	movwf	onceL	
	movwf	TX1REG
	addwf	ir_tx_chksum, F	
	incf	tx_data, F
	incf	ir_tx_seq, F		; last byte in dump inc it
	goto	IRQ_not_TX1			
IRQ_TX1_sq10_type1_nctl	
	; send out buffer bytes
	movlw	high(start_buffer)
	movwf	FSR1H
	movlw	low(start_buffer)
	movwf	FSR1L
	movf	tx_data, W
	addwf	FSR1L, F
	btfsc	STATUS, C			; check for carry
	incf	FSR1H, F
	comf	INDF1, W
	movwf	TX1REG
	addwf	ir_tx_chksum, F	
	incf	tx_data, F
	goto	IRQ_not_TX1	
	
IRQ_TX1_sq10_type4
	movlw	high(temp_crypt0)	
	movwf	FSR1H
	movlw	low(temp_crypt0)
	movwf	FSR1L
	movf	tx_data, W
	addwf	FSR1L, F
	movf	INDF1, W
	movwf	TX1REG
	addwf	ir_tx_chksum, F	
	incf	tx_data, F
	movf	tx_data, W
	xorlw	0x0A
	btfsc	STATUS, Z
	incf	ir_tx_seq, F		; last byte in xfer inc it	
	goto	IRQ_not_TX1		

IRQ_TX1_sq10_type8
	movlw	high(start_rx_buffer)	
	movwf	FSR1H
	movlw	low(start_rx_buffer)
	movwf	FSR1L
	movf	INDF1, W
	movwf	TX1REG
	addwf	ir_tx_chksum, F	
	incf	tx_data, F
	incf	ir_tx_seq, F		; last byte in xfer inc it
	goto	IRQ_not_TX1			
	
IRQ_TX1_sq11
	movf	ir_tx_seq, W
	xorlw	0x0B
	btfss	STATUS, Z
	goto	IRQ_TX1_done		; something bad happened just abort now
	comf	ir_tx_chksum, F
	incf	ir_tx_chksum, W
	movwf	TX1REG
	
	
IRQ_TX1_done	
	;------------------
	movlb	d'14'
	;------------------	
	bcf	PIE3, TX1IE				; buffer empty disable Uart2 transmit IRQ	
IRQ_not_TX1
	
	
	retfie
;###########################################################################################################################
; end of IRQ code
;###########################################################################################################################	
	
START
	; init crap
	;------------------
	movlb	d'0'
	;------------------
	clrf	INTCON			    ; disable interupts
	clrf	LATA			    ; All low
	movlw	0xB0				
	movwf	LATB			    ; SDA, SCL, and IR_OUT high reset low
	movlw	0x67					
	movwf	LATC			    ; reset and both chip selects high reset low. 

	movlw	0x34				; Set boad id pins as inputs reset as outputs
	movwf	TRISA			    ; 0 = output 
	movlw	0x70				; Set I2C bus and IR_in as inputs rest outputs
	movwf	TRISB			    ; 0 = output	
	movlw	0x81				; Set Postcon and MISO as inputs reset outputs
	movwf	TRISC			    ; 0 = output	

	
	; clear control global vars
	clrf	g_flags
	
	; clear vars first 80 bytes (control structures) 
	movlw	0x20			; start of bank 0 vars
	movwf	FSR0L
	clrf	FSR0H
	movlw	0x50			; clear all of bank other than globals
	movwf	g_temp
init_bank0_loop
	clrf	INDF0
	incf	FSR0L, F
	decfsz	g_temp, F
	goto	init_bank0_loop	

	; clear bank 2 80 bytes (control structures) 
	movlw	0x20			; start of bank 0 vars
	movwf	FSR0L
	movlw	0x01
	movwf	FSR0H
	movlw	0x50			; clear all of bank other than globals
	movwf	g_temp
init_bank2_loop
	clrf	INDF0
	incf	FSR0L, F
	decfsz	g_temp, F
	goto	init_bank2_loop	
	
	; load setting register from flash into Banks 11 and 12
	movlw	high(start_buffer)
	movwf	FSR0H				; address of first ram reg
	movlw	low(start_buffer)
	movwf	FSR0L	
	movlw	high(start_eeprom)	; address of flash start (note flash address + 0x8000)
	movwf	FSR1H
	movlw	low(start_eeprom)
	movwf	FSR1L
	movlw	buffer_length
	movwf	g_temp
load_loop
	movf	INDF1, W
	movwf	INDF0
	incf	FSR0L, F
	incf	FSR1L, F
	decfsz	g_temp, F
	goto	load_loop
	
	
	; configure time phase to not be 0 at startup (causes a extra long initial delay
	movlw	0x01
	movwf	time_phase
	; load food and poo counters
	movlw	food_startup
	movwf	food_cnt
	movlw	poo_startup
	movwf	poo_cnt
	;clrf	poo_temp
	; init led cycle so not in sync at startup
	;clrf	logo_a
	;movlw	0xFF
	;movwf	logo_r
	;movlw	0x80
	;movwf	logo_g
	;clrf	logo_b
	
		
	; set bit for this badge if not already set
	;------------------
	movlb	d'16'
	;------------------	
	; get the user ID data (badge ID) 
	clrf	NVMADRH
	clrf	NVMADRL
	movlw	0x41
	movwf	NVMCON1					; read the config space selected
	nop								; instruction requires 1 cycle to complete. (may not be needed but just to be safe.)
	movf	NVMDATL, W
	;------------------
	movlb	d'0'
	;------------------	
	movwf	temp
	movwf	LFSR_0					; seed random number gen
	bsf		LFSR_0,	4				; make sure the LFSR is NOT all 0!!!
	movwf	LFSR_2
	;------------------
	movlb	d'2'
	;------------------	
	movwf	badge_idL
	;------------------
	movlb	d'16'
	;------------------	
	movf	NVMDATH, W
	;------------------
	movlb	d'2'
	;------------------	
	movwf	badge_idH
	;------------------
	movlb	d'0'
	;------------------	
	movwf	temp1
	movwf	LFSR_1					; seed random number gen
	movwf	LFSR_3					
	; set badge as found in ram
	movf	temp, W
	movwf	offset
	rrf		temp1, F			; need to rotate 2 bits over 
	rrf		offset, F
	rrf		temp1, F			; need to rotate 2 bits over 
	rrf		offset, F
	bcf		STATUS, C
	rrf		offset, F
	movlw	high(start_buffer_objs)
	movwf	FSR1H
	movf	offset, W
	addlw	low(start_buffer_objs)
	movwf	FSR1L
	; take the low 3 bits rotate 1 left (jump 2 for each) then branch
	bcf		STATUS, C
	rlf		temp, W
	andlw	0x0E
	brw
	bcf		INDF1, 0
	goto	START_ID_UPDATE_DONE	
	bcf		INDF1, 1
	goto	START_ID_UPDATE_DONE	
	bcf		INDF1, 2
	goto	START_ID_UPDATE_DONE	
	bcf		INDF1, 3
	goto	START_ID_UPDATE_DONE	
	bcf		INDF1, 4
	goto	START_ID_UPDATE_DONE	
	bcf		INDF1, 5
	goto	START_ID_UPDATE_DONE	
	bcf		INDF1, 6
	goto	START_ID_UPDATE_DONE	
	bcf		INDF1, 7
;	goto	IRQ_RX_ID_UPDATE_DONE		
START_ID_UPDATE_DONE	

	; get inital interaction count
	movlw	high(start_buffer_objs)
	movwf	FSR1H
	movlw	low(start_buffer_objs)
	movwf	FSR1L	
	movlw	objs_length
	movwf	temp
count_bits_loop
	movlw	0x08
	movwf	offset
	movf	INDF1,W
	movwf	temp1
count_bits_shift_loop
	rrf		temp1, F
	btfsc	STATUS, C	
	goto	count_bits_skip
	incf	countL, F
	btfsc	STATUS, Z
	incf	countH, F
count_bits_skip	
	decfsz	offset, F
	goto	count_bits_shift_loop
	incf	FSR1L, F
	decfsz	temp, F
	goto	count_bits_loop		
	
	; set up the badge status 
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfsc	INDF1, 0			; check if con is started
	goto	START_skip_status
	btfsc	INDF1, 7			; check if dead
	bsf		badge_status, 0		; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
START_skip_status	

	
	;------------------
	movlb	d'2'
	;------------------	
	; check if badge is founder, lifetime, or vendor if so it can never die
	movlw	high(founder_badge)
	subwf	badge_idH, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	START_undead_chk_done		; normal or speaker badge...
	btfss	STATUS, Z			; if greater than limit skip to next check
	goto	START_undead_founder
	movlw	low(founder_badge)
	subwf	badge_idL, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	START_undead_chk_done		; normal or speaker badge...
START_undead_founder
	bsf	g_flags, 5			; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off, bit 3 = enable TX delay, bit 4 = Hyron badge ID set, bit 5 = undead
START_undead_chk_done	
	
	;------------------
	movlb	d'4'
	;------------------
	; set up timer 1 to roll over on a 20Hz period
	clrf	TMR1H
	clrf	TMR1L
	clrf	T1GATE			    ; T1GPPS (not used)
	movlw	0x01				; use Fosc/4 MFINTOSC
	movwf	T1CLK				
	clrf	T1GCON				; gate control disabled
	movlw	0x11			    ; timer 1 on, 1:2 pre
	movwf	T1CON

	
	;------------------
	movlb	d'5'
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
	movlb	d'2'
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
	movlb	d'6'
	;------------------	
	; set up PWM engine
	movlw	IR_PULSE_WIDTH
	movwf	PWM5DCH
	movlw	0xC0
	movwf	PWM5DCL
	movlw	0x80			    ; engine on, active high
	movwf	PWM5CON

	;------------------
	movlb	d'11'
	;------------------	
	; Set up TMR0
	movlw	0xF2					; ~0.25s delay
	movwf	TMR0H
	clrf	TMR0L	
	movlw	0x95					; LFINTOSC 31kHz, no sync, 1:32 prescaler
	movwf	T0CON1
	movlw	0x80					; timer on, 8 bit, 1:1 postscaler
	movwf	T0CON0	
	
	;------------------
	movlb	d'14'
	;------------------	
	; set up interupts
	clrf	PIR0
	movlw	0x20					; TMR0
	movwf	PIE0
	clrf	PIR3
;	movlw	0x00
;	iorlw	0x80					; RC2IE (uart)
;	iorlw	0x40					; TX2IE (uart)
;	iorlw	0x20					; RC1IE (uart)
;	iorlw	0x10					; TX1IE (uart)
	movlw	0x20
	movwf	PIE3
	clrf	PIR4
	movlw	0x01					; TMR1E
	movwf	PIE4
	
	;------------------
	movlb	d'60'
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
	movlb	d'61'
	;------------------
	; unlock bits
	movlw	0x55
	movwf	PPSLOCK
	movlw	0xAA
	movwf	PPSLOCK
	bcf		PPSLOCK, PPSLOCKED
	
	; input PPS signals
	movlw	0x0E					; RB6
	movwf	RX1DTPPS	
	movlw	0x0D					; RB5
	movwf	SSP1DATPPS	
	movlw	0x0C					; RB4
	movwf	SSP1CLKPPS	
	
	;------------------
	movlb	d'62'
	;------------------	
	clrf	ANSELA				; 0 = digital, 1 = analog 
	clrf	ANSELB				; 0 = digital, 1 = analog 
	clrf	ANSELC				; 0 = digital, 1 = analog 
	
	movlw	0x34				; enable weak pull up on portA 0
	movwf	WPUA				
	;movlw	0x01				; enable weak pull up on portC 0
	;movwf	WPUC				

	; output PPS signals
	movlw	0x03				; CLC3OUT (IR TX)
	movwf	RB7PPS				; IR led
	movlw	0x15				; SCK1/SCL1
	movwf	RB4PPS
	movlw	0x16				; SDO1/SDA1
	movwf	RB5PPS

	
;	;------------------
;	movlb	d'61'
;	;------------------	
; Do not lock the PPS as we need to move it back and fourth to use one MSSP for both I2C and SPI devices. 	
;	; lock bits
;	movlw	0x55
;	movwf	PPSLOCK
;	movlw	0xAA
;	movwf	PPSLOCK
;	bsf		PPSLOCK, PPSLOCKED	
	
	;------------------
	movlb	d'3'
	;------------------
	; disable i2c engine 
	clrf	SSP1CON1		    ; reset I2C
	
	
	clrf	SSP1CON2
	clrf	SSP1CON3
	clrf	SSP1STAT
	movlw	0x80			    ; slew off, smb off
	movwf	SSP1STAT	
	movlw	0xFF
	movwf	SSP1MSK
	movlw	0x4F			    ; 0x4F with a 32MHz FOSC = 100kHz
	movwf	SSP1ADD			    ; I2C clock = FOSC/((ADD<7:0> + 1) *4)
	movlw	0x28			    ; port enabled, I2C master mode  
	movwf	SSP1CON1	

	;------------------
	movlb	d'0'
	;------------------
	movlw	0xC0
	movwf	INTCON			    ; enable interrupts

	; if con is started use sleep animation, If not use precon
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	movlw	0x06
	btfss	INDF1, 0
	movwf	oLED_set

	; if badge is dead move animation to that mode else use above
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	movlw	0x08
	btfss	INDF1, 7
	movwf	oLED_set
	
	
	; check for postcon mode
	btfsc	PORTC, 7
	bsf	badge_ctrl, 2	; bit 0 = logo tick , bit 1 = poo led, bit 2 = postcon mode
	
	
	;------------------------------------------------------------------------------------------------------
	; init the LED driver

	; case the LED driver chip was left in a weird state 	
	bcf	LATB, 4
	bcf	TRISB, 4
	bsf	TRISB, 4	
	call	_I2C_STOP
	
	; reset the device
	movlw	0x4F			    ; address byte
	movwf	i2c_off
	clrf	i2c_dat0		    ; data byte (0x00 reset device)
	call	_LED_WRITE_1

	; software power up (off after reset)
	clrf	i2c_off			    ; address byte
	movlw	0x01
	movwf	i2c_dat0		    ; data byte (0x00 reset device)
	call	_LED_WRITE_1		
	
	; reset the device
	movlw	0x4F			    ; address byte
	movwf	i2c_off
	clrf	i2c_dat0		    ; data byte (0x00 reset device)
	call	_LED_WRITE_2

	; software power up (off after reset)
	clrf	i2c_off			    ; address byte
	movlw	0x01
	movwf	i2c_dat0		    ; data byte (0x00 reset device)
	call	_LED_WRITE_2		
	
	; init LED drive for LOGO LEDs
	call	_I2C_START	
	movlw	0x78			    ; ISSI chip address
	call	_SEND_W_I2C
	movlw	0x26				; reg offset
	call	_SEND_W_I2C	
	movlw	d'36'				; loop though all leds and turn them on
	movwf	temp
INIT_update_loop1	
	movlw	0x01				; enable led full current
	call	_SEND_W_I2C
	decfsz	temp, F
	goto	INIT_update_loop1
	call	_I2C_STOP	
	
	call	_I2C_START	
	movlw	0x7E			    ; ISSI chip address
	call	_SEND_W_I2C
	movlw	0x26				; reg offset
	call	_SEND_W_I2C	
	movlw	d'36'				; loop though all leds and turn them on
	movwf	temp
INIT_update_loop2	
	movlw	0x01				; enable led full current
	call	_SEND_W_I2C
	decfsz	temp, F
	goto	INIT_update_loop2
	call	_I2C_STOP	

	
	movlp	0x18
	goto	oLED_INIT
oLED_INIT_return	
	
	call	_CFG_I2C

	movlp	0x00
#ifndef debug
	btfsc	PORTA, 3			; social button
#endif ;	
	goto	LED_SELFTEST_DONE
	movlp	0x08
	goto	LED_SELFTEST
LED_SELFTEST_DONE
	
	movlp	0x18
	goto	oLED_EEPROM_INIT
oLED_EEPROM_INIT_return	
	
	call	_CFG_I2C	
	
	goto	MAINLOOP	
	
CHECK_SPI_FAIL_INIT	
	bsf		LATC, 5				; SPI EEPROM CS pin
	call	_CFG_I2C
	
	; disable IOs to allow programer acess to the chip
	movlw	0xA7				; Set Postcon, MISO, MOSI, Sclk, and EEPROM_CS as inputs reset outputs
	movwf	TRISC			    ; 0 = output		
	
	; make RA0 a input and turn on weak pull up used to stop poop led blinking to keep SPI programming from corrupting. 
	movlw	0x35				; Set boad id pins and RA0 as inputs reset as outputs
	movwf	TRISA			    ; 0 = output 
	;------------------
	movlb	d'62'
	;------------------	
	movlw	0x35				; enable weak pull up on portA 0
	movwf	WPUA				
	;------------------
	movlb	d'0'
	;------------------	
	
	
CHECK_SPI_FAIL	
		
	; turn on white led
	movlw	d'28'
	movwf	i2c_off			    ; address byte
	movlw	0xff
	movwf	i2c_dat0		    
	call	_LED_WRITE_1		
	call	_LED_SET_1			; update the leds to the new state

	movlw	0x01
	movwf	delay_cnt
CHECK_SPI_FAIL_DELAY1
	movf	delay_cnt, W
	btfss	STATUS, Z
	goto	CHECK_SPI_FAIL_DELAY1
	
	; turn off white led
	movlw	d'28'
	movwf	i2c_off			    ; address byte
	movlw	0x00
	movwf	i2c_dat0		    
	call	_LED_WRITE_1	
	call	_LED_SET_1			; update the leds to the new state

	movlw	0x01
	movwf	delay_cnt
CHECK_SPI_FAIL_DELAY2
	movf	delay_cnt, W
	btfss	STATUS, Z
	goto	CHECK_SPI_FAIL_DELAY2
	
	btfss	PORTA, 0
	goto	PROGRAM_LED_STOP

	goto	CHECK_SPI_FAIL
	
	; check the SPI eeprom for header else blink the pooper
	
PROGRAM_LED_STOP
	goto	PROGRAM_LED_STOP
	
	
;--------------------------------------------------------------------------------------------------------------------------------------------------	
MAINLOOP
	;------------------
	movlb	d'0'
	;------------------	
	
	; if in postcon mode don't update the flash anymore. 
	btfsc	badge_ctrl, 2	    ; bit 0 = logo tick , bit 1 = poo led, bit 2 = postcon mode	
	goto	MAINLOOP_no_flash_update
	
	; see if a flash update event occured if so do it now
	btfsc	g_flags, 0
	call	_UPDATE_FLASH
	
	movlp	0x08					; select page 1
	goto	MAINLOOP2
	
MAINLOOP_no_flash_update	
	movlp	0x08					; select page 1
	goto	MAINLOOP2_postcon
	
	

	
	
;#########################################################	
; This function decrements the 16 bit value pointed to by FSR0
;#########################################################	
_2BYTE_DEC_N_STOP
	moviw	FSR0++
	btfss	STATUS, Z
	goto	_2BYTE_SUB_N_STOP_not_zero
	movf	INDF0, W
	btfsc	STATUS, Z
	return						; counter at 0 already so stop updating it	
_2BYTE_SUB_N_STOP_not_zero
	movlw	0x01
	subwf	INDF0, F			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfsc	STATUS, C
	return
	moviw	FSR0--				; use this command to dec the INDF (less code than the 16 bit math needed to do it the normal way. 	
	movlw	0x01
	subwf	INDF0, F			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfsc	STATUS, C
	return
	; if both bytes have a carry counter rolled. set it to 0
	movlw	0x00
	movwi	FSR0++
	movwi	FSR0++	
	return
	
;#########################################################	
; Move the 128 byte ram buffer to flash storage. 
;#########################################################	
_UPDATE_FLASH
	bcf		g_flags, 0			; programing started (in case there is a update between the start and end clear it now then it will run again and pick up any changes without loss)
	movf	BSR, W
	movwf	current_bsr	
	clrf	g_temp				; init offset counter since there are multiple pages to program. 
_UPDATE_FLASH_loop	
	;------------------
	movlw	d'16'
	movwf	BSR		
	;------------------	
	; erase	row of flash (32 words) 
	movlw	high(start_eeprom_p)
	movwf	NVMADRH
	movlw	low(start_eeprom_p)
	addwf	g_temp, W			; add offset
	movwf	NVMADRL
	movlw	0x14				; access program flash, flash erase, write enable 
	movwf	NVMCON1
	call	_UNLOCK_NVM			; unlock NVM
	bcf		NVMCON1, WREN		; disable write latch	
	
	; write row of flash (32 words)
	movlw	high(start_buffer)
	movwf	FSR1H				; address of first ram reg
	movlw	low(start_buffer)
	addwf	g_temp, W			; add offset
	movwf	FSR1L	
	movlw	high(start_eeprom_p)
	movwf	NVMADRH
	movlw	low(start_eeprom_p)
	addwf	g_temp, W			; add offset
	movwf	NVMADRL
	movlw	0x24				; access program flash, flash write latch only, write enable 
	movwf	NVMCON1

_UPDATE_FLASH_load_loop	
	moviw	FSR1++				; movw INDF0 to W and increment to next address
	movwf	NVMDATL
	movlw	0x3F				; upper bits unused leave in cleared state
	movwf	NVMDATH
	movf	NVMADRL, W
	andlw	0x1F				; check if 1 - a 32 word boundary (end of row)
	xorlw	0x1F
	btfsc	STATUS, Z
	goto	_UPDATE_FLASH_write
	call	_UNLOCK_NVM			; unlock NVM
	incf	NVMADRL, F
	goto	_UPDATE_FLASH_load_loop
	
_UPDATE_FLASH_write
	bcf		NVMCON1, LWLO		; next write programs row vs latches
	call	_UNLOCK_NVM			; unlock NVM
	bcf		NVMCON1, WREN		; clear write enable bit
	
	movlw	0x20				; erase page size (32)
	addwf	g_temp, F
	movf	g_temp, W
	sublw	d'127'				; C = 0 when W > k, C = 1 when W <= k
	btfsc	STATUS, C
	goto	_UPDATE_FLASH_loop
	
	movf	current_bsr, W
	movwf	BSR
	return

;#########################################################	
; unlock the NVM for write / erase
;#########################################################	
_UNLOCK_NVM
	; unlock seq
	bcf		INTCON, GIE			; disable IRQs for unlock
	movlw	0x55
	movwf	NVMCON2
	movlw	0xAA
	movwf	NVMCON2
	bsf		NVMCON1, WR			; kick off write or erase
	bsf		INTCON, GIE			; enable IRQs again
	
	return
	
;#########################################################
; This configures the MSSP to I2C
;#########################################################
_CFG_I2C
	movf	BSR, W
	movwf	current_bsr
	
	;------------------
	movlb	d'61'
	;------------------
	; input PPS signals
	movlw	0x0D					; RB5
	movwf	SSP1DATPPS	
	movlw	0x0C					; RB4
	movwf	SSP1CLKPPS	
	
	;------------------
	movlb	d'62'
	;------------------	
	; output PPS signals
	movlw	0x15				; SCK1/SCL1
	movwf	RB4PPS
	movlw	0x16				; SDO1/SDA1
	movwf	RB5PPS
	
	;------------------
	movlb	d'3'			   
	;------------------
	; disable MSSP engine 
	clrf	SSP1CON1		    ; reset MSSP
	clrf	SSP1CON2
	clrf	SSP1CON3
	clrf	SSP1STAT
	movlw	0x80			    ; slew off, smb off
	movwf	SSP1STAT	
	movlw	0xFF
	movwf	SSP1MSK
	movlw	0x4F			    ; 0x4F with a 32MHz FOSC = 100kHz
	movwf	SSP1ADD			    ; I2C clock = FOSC/((ADD<7:0> + 1) *4)
	movlw	0x28			    ; port enabled, I2C master mode  
	movwf	SSP1CON1	

	movf	current_bsr, W
	movwf	BSR
	return

	
;#########################################################
; update the leds to the new state
;#########################################################
_LED_SET_2	
	movlw	0x25			    ; address byte
	movwf	i2c_off			    ; address byte
	clrf	i2c_dat0		    ; data byte 
	call	_LED_WRITE_2
	return

;#########################################################
; update the leds to the new state
;#########################################################
_LED_SET_1
	movlw	0x25			    ; address byte
	movwf	i2c_off			    ; address byte
	clrf	i2c_dat0		    ; data byte 
	call	_LED_WRITE_1
	return
	
;#########################################################
; write 1 byte to the LED driver at offset given
; assumes user is in bank 0 before calling!!
;#########################################################
_LED_WRITE_2
	; reset the device
	call	_I2C_START	
	movlw	0x7E			    ; ISSI chip address
	call	_SEND_W_I2C
	movf	i2c_off, W		    ; address byte
	call	_SEND_W_I2C
	movf	i2c_dat0, W		    ; data byte (0x00 reset device)
	call	_SEND_W_I2C
	call	_I2C_STOP
	return

;#########################################################
; write 1 byte to the LED driver at offset given
; assumes user is in bank 0 before calling!!
;#########################################################
_LED_WRITE_1
	; reset the device
	call	_I2C_START	
	movlw	0x78			    ; ISSI chip address
	call	_SEND_W_I2C
	movf	i2c_off, W		    ; address byte
	call	_SEND_W_I2C
	movf	i2c_dat0, W		    ; data byte (0x00 reset device)
	call	_SEND_W_I2C
	call	_I2C_STOP
	return
	
;#########################################################
; send a restart bit (stop then start if supported)
;#########################################################
; not supported by this chip removed to save space
	
;#########################################################
; send a stop bit
;#########################################################
_I2C_STOP
	movf	BSR, W
	movwf	current_bsr
	;------------------
	movlb	d'3'			   
	;------------------
	; clear any error bits
	bcf	SSP1CON1, WCOL
	bcf	SSP1CON1, SSPOV
	; send stop bit
	bsf	SSP1CON2, PEN	
__WAIT_PEN
	btfsc	SSP1CON2, PEN
	goto	__WAIT_PEN
	movf	current_bsr, W
	movwf	BSR
	return
	
;#########################################################
; send a start bit
;#########################################################
_I2C_START
	movf	BSR, W
	movwf	current_bsr
	;------------------
	movlb	d'14'
	;------------------	
	bcf	PIR3, SSP1IF		    ; clear interrupt flag
	;------------------
	movlb	d'3'
	;------------------
	; clear any error bits
	bcf	SSP1CON1, WCOL
	bcf	SSP1CON1, SSPOV
	; send start bit
	bsf	SSP1CON2, SEN		
__WAIT_SEN
	btfsc	SSP1CON2, SEN
	goto	__WAIT_SEN	
	movf	current_bsr, W
	movwf	BSR
	return
	
;#########################################################
; send the value in the W register out the I2C bus
;#########################################################
_SEND_W_I2C
	movwf	g_temp
	movf	BSR, W
	movwf	current_bsr
	;------------------
	movlb	d'14'
	;------------------	
	bcf		PIR3, SSP1IF		    ; clear interrupt flag
	bcf		PIR3, BCL1IF		    ; clear interrupt flag
	;------------------
	movlb	d'3'
	;------------------
	movf	g_temp, W
	movwf	SSP1BUF 
	;------------------
	movlb	d'14'
	;------------------	
__WAIT_BYTE_DONE	
	btfss	PIR3, SSP1IF
	goto	__WAIT_BYTE_DONE
	bcf		PIR3, SSP1IF		    ; clear interrupt flag
	movf	current_bsr, W
	movwf	BSR
	
	return

;################################################################################
; cycle the LFSR (sudo random) generator 16 bits and return the new lower 8 result in W
;################################################################################
_CYCLE_LFSR16
	movlp	0x08
	call	_2_CYCLE_LFSR16
	movlp	0x00
	return
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; FLASH goto / call break here need to update the counter manually to jump back and forth from here.... 
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
;put the following at address 0800h
	org     0800h	

	
;#########################################################
; LED seq order for self test (look up table)
; assumes user is in bank 0 before calling!!
;#########################################################
_2_LED_ST_LUT2
	; check W is less than 35 else return 1
	movwf	g_temp
	sublw	d'35'		; C = 0 when W > k, C = 1 when W <= K
	btfss	STATUS, C
	retlw	0x01

#ifdef proto
	movf	g_temp, W
	brw
	retlw	d'29'		; D47
	retlw	d'28'		; D46
	retlw	d'27'		; D45
	retlw	d'26'		; D43
	retlw	d'25'		; D42
	retlw	d'24'		; D41
	retlw	d'23'		; D38
	retlw	d'22'		; D37
	retlw	d'21'		; D35
	retlw	d'20'		; D34
	retlw	d'19'		; D32
	retlw	d'18'		; D31
	retlw	d'17'		; D30
	retlw	d'16'		; D29
	retlw	d'15'		; D27
	retlw	d'14'		; D26
	retlw	d'13'		; D25
	retlw	d'12'		; D24
	retlw	d'11'		; D22
	retlw	d'10'		; D21
	retlw	d'9'		; D20
	retlw	d'8'		; D19
	retlw	d'7'		; D18
	retlw	d'6'		; D16
	retlw	d'5'		; D15
	retlw	d'4'		; D14
	retlw	d'3'		; D13
	retlw	d'2'		; D11
	retlw	d'1'		; D10
	retlw	d'35'		; D51
	retlw	d'34'		; D49
	retlw	d'33'		; D40
	retlw	d'32'		; D36
	retlw	d'30'		; D6
	retlw	d'31'		; D8
	retlw	d'36'		; D9
#else	
	movf	PORTA, W
	andlw	0x34
	movwf	temp
	btfsc	PORTA, 2
	bsf	temp, 3
	bcf	STATUS, C
	rrf	temp, F
	bcf	STATUS, C
	rrf	temp, F
	bcf	STATUS, C
	rrf	temp, F
	movf	temp, W
	sublw	d'4'		; C = 0 when W > k, C = 1 when W <= K
	btfss	STATUS, C
	retlw	0x01
	movf	temp, W
	brw
	goto	_2_LED_ST_LUT2_0
	goto	_2_LED_ST_LUT2_1
	goto	_2_LED_ST_LUT2_2
	goto	_2_LED_ST_LUT2_3
	goto	_2_LED_ST_LUT2_4	
	
_2_LED_ST_LUT2_0	
	movf	g_temp, W
	brw
	retlw	d'1'		; D10
	retlw	d'35'		; D51
	retlw	d'34'		; D49	
	retlw	d'29'		; D47
	retlw	d'20'		; D34	
	retlw	d'13'		; D25	
	retlw	d'2'		; D11
	retlw	d'7'		; D18	
	retlw	d'5'		; D15
	retlw	d'4'		; D14	
	retlw	d'3'		; D13
	retlw	d'6'		; D16
	retlw	d'15'		; D27
	retlw	d'17'		; D30
	retlw	d'21'		; D35
	retlw	d'18'		; D31
	retlw	d'16'		; D29
	retlw	d'10'		; D21
	retlw	d'9'		; D20
	retlw	d'8'		; D19	
	retlw	d'11'		; D22
	retlw	d'12'		; D24	
	retlw	d'14'		; D26
	retlw	d'19'		; D32
	retlw	d'22'		; D37
	retlw	d'23'		; D38	
	retlw	d'24'		; D41
	retlw	d'25'		; D42
	retlw	d'26'		; D43
	retlw	d'27'		; D45
	retlw	d'28'		; D46
	retlw	d'32'		; D36
	retlw	d'33'		; D40
	retlw	d'36'		; D9 egg	
	retlw	d'31'		; D8 stomic
	retlw	d'30'		; D6 heart
	
_2_LED_ST_LUT2_1    ; coyote
	movf	g_temp, W
	brw
	retlw	d'4'		; D14
	retlw	d'3'		; D13
	retlw	d'2'		; D11
	retlw	d'1'		; D10	
	retlw	d'5'		; D15
	retlw	d'6'		; D16	
	retlw	d'7'		; D18
	retlw	d'13'		; D25
	retlw	d'8'		; D19		
	retlw	d'9'		; D20
	retlw	d'10'		; D21
	retlw	d'12'		; D24	
	retlw	d'11'		; D22
	retlw	d'14'		; D26
	retlw	d'15'		; D27
	retlw	d'16'		; D29	
	retlw	d'17'		; D30
	retlw	d'18'		; D31	
	retlw	d'19'		; D32
	retlw	d'20'		; D34
	retlw	d'23'		; D38
	retlw	d'22'		; D37
	retlw	d'24'		; D41
	retlw	d'25'		; D42
	retlw	d'26'		; D43
	retlw	d'27'		; D45
	retlw	d'28'		; D46
	retlw	d'21'		; D35
	retlw	d'29'		; D47
	retlw	d'32'		; D36
	retlw	d'33'		; D40
	retlw	d'34'		; D49		
	retlw	d'35'		; D51
	retlw	d'36'		; D9 egg	
	retlw	d'31'		; D8 stomic
	retlw	d'30'		; D6 heart
	
_2_LED_ST_LUT2_2
	movf	g_temp, W
	brw
	retlw	d'1'		; D10
	retlw	d'2'		; D11
	retlw	d'5'		; D15
	retlw	d'4'		; D14	
	retlw	d'3'		; D13
	retlw	d'6'		; D16
	retlw	d'7'		; D18
	retlw	d'11'		; D22
	retlw	d'24'		; D41
	retlw	d'19'		; D32
	retlw	d'14'		; D26
	retlw	d'8'		; D19
	retlw	d'9'		; D20
	retlw	d'10'		; D21
	retlw	d'12'		; D24	
	retlw	d'13'		; D25
	retlw	d'17'		; D30
	retlw	d'21'		; D35
	retlw	d'22'		; D37
	retlw	d'23'		; D38
	retlw	d'20'		; D34	
	retlw	d'16'		; D29
	retlw	d'15'		; D27
	retlw	d'18'		; D31
	retlw	d'25'		; D42
	retlw	d'26'		; D43
	retlw	d'27'		; D45
	retlw	d'28'		; D46
	retlw	d'29'		; D47
	retlw	d'32'		; D36
	retlw	d'33'		; D40
	retlw	d'34'		; D49	
	retlw	d'35'		; D51
	retlw	d'36'		; D9 egg	
	retlw	d'31'		; D8 stomic
	retlw	d'30'		; D6 heart
	
_2_LED_ST_LUT2_3
	movf	g_temp, W
	brw
	retlw	d'1'		; D10
	retlw	d'2'		; D11
	retlw	d'3'		; D13
	retlw	d'4'		; D14
	retlw	d'5'		; D15
	retlw	d'9'		; D20
	retlw	d'10'		; D21
	retlw	d'6'		; D16
	retlw	d'7'		; D18
	retlw	d'8'		; D19
	retlw	d'11'		; D22
	retlw	d'13'		; D25
	retlw	d'12'		; D24
	retlw	d'14'		; D26
	retlw	d'16'		; D29
	retlw	d'15'		; D27
	retlw	d'20'		; D34
	retlw	d'21'		; D35
	retlw	d'19'		; D32
	retlw	d'18'		; D31
	retlw	d'22'		; D37
	retlw	d'23'		; D38
	retlw	d'24'		; D41
	retlw	d'17'		; D30
	retlw	d'25'		; D42
	retlw	d'26'		; D43
	retlw	d'29'		; D47
	retlw	d'28'		; D46
	retlw	d'27'		; D45
	retlw	d'32'		; D36
	retlw	d'33'		; D40
	retlw	d'34'		; D49	
	retlw	d'35'		; D51
	retlw	d'36'		; D9 egg	
	retlw	d'31'		; D8 stomic
	retlw	d'30'		; D6 heart
	
_2_LED_ST_LUT2_4
	movf	g_temp, W
	brw
	retlw	d'3'		; D13
	retlw	d'4'		; D14
	retlw	d'5'		; D15
	retlw	d'6'		; D16
	retlw	d'7'		; D18
	retlw	d'9'		; D20
	retlw	d'10'		; D21
	retlw	d'11'		; D22
	retlw	d'12'		; D24
	retlw	d'13'		; D25
	retlw	d'17'		; D30
	retlw	d'19'		; D32
	retlw	d'20'		; D34
	retlw	d'21'		; D35
	retlw	d'23'		; D38
	retlw	d'25'		; D42
	retlw	d'26'		; D43
	retlw	d'28'		; D46
	retlw	d'33'		; D40
	retlw	d'35'		; D51
	retlw	d'34'		; D49	
	retlw	d'32'		; D36
	retlw	d'29'		; D47
	retlw	d'27'		; D45
	retlw	d'24'		; D41
	retlw	d'22'		; D37
	retlw	d'18'		; D31
	retlw	d'16'		; D29
	retlw	d'15'		; D27
	retlw	d'14'		; D26
	retlw	d'8'		; D19	
	retlw	d'2'		; D11
	retlw	d'1'		; D10
	retlw	d'36'		; D9 egg	
	retlw	d'31'		; D8 stomic
	retlw	d'30'		; D6 heart
#endif
	
;#########################################################
; LED seq order for self test (look up table)
; assumes user is in bank 0 before calling!!
;#########################################################
_2_LED_ST_LUT1
	; check W is less than 35 else return 1
	movwf	g_temp
	sublw	d'35'		; C = 0 when W > k, C = 1 when W <= K
	btfss	STATUS, C
	retlw	0x01
	
#ifdef proto
	movf	g_temp, W
	brw
	retlw	d'28'		; D3 (white)
	retlw	d'20'		; D33 R
	retlw	d'21'		; D33 G
	retlw	d'22'		; D33 B	
	retlw	d'16'		; D28 R
	retlw	d'17'		; D28 G
	retlw	d'18'		; D28 B
	retlw	d'12'		; D17 R
	retlw	d'13'		; D17 G
	retlw	d'14'		; D17 B
	retlw	d'8'		; D12 R
	retlw	d'9'		; D12 G
	retlw	d'10'		; D12 B
	retlw	d'4'		; D7 R
	retlw	d'5'		; D7 G
	retlw	d'6'		; D7 B	
	retlw	d'3'		; D5
	retlw	d'7'		; D23
	retlw	d'11'		; D39
	retlw	d'15'		; D44
	retlw	d'19'		; D57
	retlw	d'23'		; D58
	retlw	d'27'		; D62
	retlw	d'25'		; D60
	retlw	d'24'		; D59
	retlw	d'26'		; D61
	retlw	d'29'		; D63
	retlw	d'31'		; D48
	retlw	d'30'		; D64
	retlw	d'32'		; D50
	retlw	d'33'		; D52
	retlw	d'34'		; D53
	retlw	d'35'		; D54
	retlw	d'36'		; D55
	retlw	d'2'		; D4
	retlw	d'1'		; D56
#else	
	movf	PORTA, W
	andlw	0x34
	movwf	temp
	btfsc	PORTA, 2
	bsf	temp, 3
	bcf	STATUS, C
	rrf	temp, F
	bcf	STATUS, C
	rrf	temp, F
	bcf	STATUS, C
	rrf	temp, F
	movf	temp, W
	sublw	d'4'		; C = 0 when W > k, C = 1 when W <= K
	btfss	STATUS, C
	retlw	0x01
	movf	temp, W
	brw
	goto	_2_LED_ST_LUT1_0
	goto	_2_LED_ST_LUT1_1
	goto	_2_LED_ST_LUT1_2
	goto	_2_LED_ST_LUT1_3
	goto	_2_LED_ST_LUT1_4
	
_2_LED_ST_LUT1_0
	movf	g_temp, W
	brw
	retlw	d'28'		; D3 (white)
	retlw	d'20'		; D33 R
	retlw	d'21'		; D33 G
	retlw	d'22'		; D33 B	
	retlw	d'16'		; D28 R
	retlw	d'17'		; D28 G
	retlw	d'18'		; D28 B
	retlw	d'12'		; D17 R
	retlw	d'13'		; D17 G
	retlw	d'14'		; D17 B
	retlw	d'8'		; D12 R
	retlw	d'9'		; D12 G
	retlw	d'10'		; D12 B
	retlw	d'4'		; D7 R
	retlw	d'5'		; D7 G
	retlw	d'6'		; D7 B	
	retlw	d'3'		; D5 A
	retlw	d'7'		; D23 A
	retlw	d'11'		; D39 A
	retlw	d'15'		; D44 A
	retlw	d'19'		; D57 A
	retlw	d'23'		; D58 A
	retlw	d'2'		; D4
	retlw	d'1'		; D56	
	retlw	d'34'		; D53
	retlw	d'31'		; D48
	retlw	d'30'		; D64
	retlw	d'29'		; D63
	retlw	d'25'		; D60
	retlw	d'24'		; D59
	retlw	d'27'		; D62
	retlw	d'26'		; D61	
	retlw	d'32'		; D50
	retlw	d'33'		; D52	
	retlw	d'35'		; D54	
	retlw	d'36'		; D55
	
_2_LED_ST_LUT1_1	
	movf	g_temp, W
	brw
	retlw	d'28'		; D3 (white)
	retlw	d'20'		; D33 R
	retlw	d'21'		; D33 G
	retlw	d'22'		; D33 B	
	retlw	d'16'		; D28 R
	retlw	d'17'		; D28 G
	retlw	d'18'		; D28 B
	retlw	d'12'		; D17 R
	retlw	d'13'		; D17 G
	retlw	d'14'		; D17 B
	retlw	d'8'		; D12 R
	retlw	d'9'		; D12 G
	retlw	d'10'		; D12 B
	retlw	d'4'		; D7 R
	retlw	d'5'		; D7 G
	retlw	d'6'		; D7 B	
	retlw	d'3'		; D5 A
	retlw	d'7'		; D23 A
	retlw	d'11'		; D39 A
	retlw	d'15'		; D44 A
	retlw	d'19'		; D57 A
	retlw	d'23'		; D58 A
	retlw	d'34'		; D53
	retlw	d'35'		; D54	
	retlw	d'1'		; D56
	retlw	d'2'		; D4
	retlw	d'36'		; D55
	retlw	d'33'		; D52
	retlw	d'32'		; D50
	retlw	d'29'		; D63
	retlw	d'30'		; D64
	retlw	d'31'		; D48
	retlw	d'24'		; D59
	retlw	d'25'		; D60
	retlw	d'26'		; D61	
	retlw	d'27'		; D62
	
_2_LED_ST_LUT1_2	
	movf	g_temp, W
	brw
	retlw	d'28'		; D3 (white)
	retlw	d'20'		; D33 R
	retlw	d'21'		; D33 G
	retlw	d'22'		; D33 B	
	retlw	d'16'		; D28 R
	retlw	d'17'		; D28 G
	retlw	d'18'		; D28 B
	retlw	d'12'		; D17 R
	retlw	d'13'		; D17 G
	retlw	d'14'		; D17 B
	retlw	d'8'		; D12 R
	retlw	d'9'		; D12 G
	retlw	d'10'		; D12 B
	retlw	d'4'		; D7 R
	retlw	d'5'		; D7 G
	retlw	d'6'		; D7 B	
	retlw	d'3'		; D5 A
	retlw	d'7'		; D23 A
	retlw	d'11'		; D39 A
	retlw	d'15'		; D44 A
	retlw	d'19'		; D57 A
	retlw	d'23'		; D58 A
	retlw	d'1'		; D56
	retlw	d'2'		; D4
	retlw	d'36'		; D55	
	retlw	d'34'		; D53
	retlw	d'35'		; D54
	retlw	d'33'		; D52
	retlw	d'24'		; D59
	retlw	d'25'		; D60
	retlw	d'26'		; D61
	retlw	d'31'		; D48	
	retlw	d'30'		; D64
	retlw	d'27'		; D62
	retlw	d'29'		; D63	
	retlw	d'32'		; D50

_2_LED_ST_LUT1_3
	movf	g_temp, W
	brw
	retlw	d'28'		; D3 (white)
	retlw	d'20'		; D33 R
	retlw	d'21'		; D33 G
	retlw	d'22'		; D33 B	
	retlw	d'16'		; D28 R
	retlw	d'17'		; D28 G
	retlw	d'18'		; D28 B
	retlw	d'12'		; D17 R
	retlw	d'13'		; D17 G
	retlw	d'14'		; D17 B
	retlw	d'8'		; D12 R
	retlw	d'9'		; D12 G
	retlw	d'10'		; D12 B
	retlw	d'4'		; D7 R
	retlw	d'5'		; D7 G
	retlw	d'6'		; D7 B	
	retlw	d'3'		; D5 A
	retlw	d'7'		; D23 A
	retlw	d'11'		; D39 A
	retlw	d'15'		; D44 A
	retlw	d'19'		; D57 A
	retlw	d'23'		; D58 A
	retlw	d'34'		; D53
	retlw	d'1'		; D56
	retlw	d'2'		; D4
	retlw	d'36'		; D55
	retlw	d'35'		; D54
	retlw	d'33'		; D52
	retlw	d'32'		; D50
	retlw	d'29'		; D63
	retlw	d'30'		; D64
	retlw	d'31'		; D48	
	retlw	d'27'		; D62
	retlw	d'25'		; D60
	retlw	d'24'		; D59
	retlw	d'26'		; D61
	
_2_LED_ST_LUT1_4	
	movf	g_temp, W
	brw
	retlw	d'28'		; D3 (white)
	retlw	d'20'		; D33 R
	retlw	d'21'		; D33 G
	retlw	d'22'		; D33 B	
	retlw	d'16'		; D28 R
	retlw	d'17'		; D28 G
	retlw	d'18'		; D28 B
	retlw	d'12'		; D17 R
	retlw	d'13'		; D17 G
	retlw	d'14'		; D17 B
	retlw	d'8'		; D12 R
	retlw	d'9'		; D12 G
	retlw	d'10'		; D12 B
	retlw	d'4'		; D7 R
	retlw	d'5'		; D7 G
	retlw	d'6'		; D7 B	
	retlw	d'3'		; D5 A
	retlw	d'7'		; D23 A
	retlw	d'11'		; D39 A
	retlw	d'15'		; D44 A
	retlw	d'19'		; D57 A
	retlw	d'23'		; D58 A
	retlw	d'35'		; D54
	retlw	d'36'		; D55
	retlw	d'1'		; D56
	retlw	d'2'		; D4	
	retlw	d'34'		; D53
	retlw	d'33'		; D52
	retlw	d'32'		; D50
	retlw	d'29'		; D63
	retlw	d'31'		; D48		
	retlw	d'30'		; D64
	retlw	d'27'		; D62
	retlw	d'25'		; D60
	retlw	d'24'		; D59
	retlw	d'26'		; D61
#endif
	
;#########################################################
; long call command
;#########################################################
_2_I2C_START	
	movlp	0x00					; select page 0
	call	_I2C_START
	movlp	0x08					; select page 1
	return

;#########################################################
; long call command
;#########################################################
_2_SEND_W_I2C	
	movlp	0x00					; select page 0
	call	_SEND_W_I2C
	movlp	0x08					; select page 1
	return

;#########################################################
; long call command
;#########################################################
_2_I2C_STOP	
	movlp	0x00					; select page 0
	call	_I2C_STOP
	movlp	0x08					; select page 1
	return

;#########################################################
; long call command
;#########################################################
_2_LED_SET_1	
	movlp	0x00					; select page 0
	call	_LED_SET_1
	movlp	0x08					; select page 1
	return

;#########################################################
; long call command
;#########################################################
_2_LED_SET_2
	movlp	0x00					; select page 0
	call	_LED_SET_2
	movlp	0x08					; select page 1
	return

;#########################################################
; long call command
;#########################################################
_2_LED_WRITE_2	
	movlp	0x00					; select page 0
	call	_LED_WRITE_2
	movlp	0x08					; select page 1
	return

;#########################################################
; long call command
;#########################################################
_2_LED_WRITE_1	
	movlp	0x00					; select page 0
	call	_LED_WRITE_1
	movlp	0x08					; select page 1
	return
	
;#########################################################
; long call command
;#########################################################
_2_2BYTE_DEC_N_STOP	
	movlp	0x00					; select page 0
	call	_2BYTE_DEC_N_STOP
	movlp	0x08					; select page 1
	return

;#########################################################	
; This function takes W and subtracts it from the 24 bit value pointed to by FSR0
;#########################################################	
_2_3BYTE_SUB_N_STOP
	movwf	g_temp
	moviw	FSR0++
	btfss	STATUS, Z
	goto	_3BYTE_SUB_N_STOP_not_zero1
	moviw	FSR0++
	btfss	STATUS, Z
	goto	_3BYTE_SUB_N_STOP_not_zero2
	movf	INDF0, W
	btfsc	STATUS, Z
	return						; counter at 0 already so stop updating it	
	goto	_3BYTE_SUB_N_STOP_not_zero2	
_3BYTE_SUB_N_STOP_not_zero1	
	moviw	FSR0++				; use this command to inc the INDF (less code than the 16 bit math needed to do it the normal way. 
_3BYTE_SUB_N_STOP_not_zero2	
	movf	g_temp, W
	subwf	INDF0, F			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfsc	STATUS, C
	return
	moviw	FSR0--				; use this command to dec the INDF (less code than the 16 bit math needed to do it the normal way. 	
	movlw	0x01
	subwf	INDF0, F			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfsc	STATUS, C
	return
	moviw	FSR0--				; use this command to dec the INDF (less code than the 16 bit math needed to do it the normal way. 	
	movlw	0x01
	subwf	INDF0, F			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfsc	STATUS, C
	return
	; if all 3 bytes have a carry counter rolled. set it to 0
	movlw	0x00
	movwi	FSR0++
	movwi	FSR0++
	movwi	FSR0++	
	return
	
;################################################################################
; cycle the LFSR (sudo random) generator 16 bits and return the new lower 8 result in W
;################################################################################
_2_CYCLE_LFSR16
	movlw	0x10
	movwf	LFSR_count
	goto	cycle_lfsr_loop
	
	; no return here sharing code with another function return is in that function
	
;################################################################################
; cycle the LFSR (sudo random) generator 8 bits and return the new result in W
;################################################################################
_2_CYCLE_LFSR
	movlw	0x08
	movwf	LFSR_count
cycle_lfsr_loop
	; seed register with inial value
	bcf		g_temp, 0
	btfsc	LFSR_0, 0
	bsf		g_temp, 0
	; test bit invert result if set
	btfsc	LFSR_0, 2
	comf	g_temp, f
	; test bit invert result if set
	btfsc	LFSR_0, 6
	comf	g_temp, f
	; test bit invert result if set
	btfsc	LFSR_0, 7
	comf	g_temp, f
	
	; set carry bit
	bcf		STATUS, C
	btfsc	g_temp, 0
	bsf		STATUS, C
	
	; rotat the bits 
	rrf		LFSR_3, F
	rrf		LFSR_2, F
	rrf		LFSR_1, F
	rrf		LFSR_0, F
	decfsz	LFSR_count, F
	goto	cycle_lfsr_loop
	movf	LFSR_0, W
	return	
		
;################################################################################
; cycle the LFSR (sudo random) generator 8 bits and return the new result in W
;################################################################################
_2_SELECT_PINK	
	brw
	retlw	d'1'
	retlw	d'2'
	retlw	d'24'
	retlw	d'25'
	retlw	d'26'
	retlw	d'27'
	retlw	d'29'
	retlw	d'30'
	retlw	d'31'
	retlw	d'32'
	retlw	d'33'
	retlw	d'34'
	retlw	d'35'
	retlw	d'36'
	retlw	d'1' + 0x80
	retlw	d'2' + 0x80
	retlw	d'3' + 0x80
	retlw	d'4' + 0x80
	retlw	d'5' + 0x80
	retlw	d'6' + 0x80
	retlw	d'7' + 0x80
	retlw	d'8' + 0x80
	retlw	d'9' + 0x80
	retlw	d'10' + 0x80
	retlw	d'11' + 0x80
	retlw	d'12' + 0x80
	retlw	d'13' + 0x80
	retlw	d'14' + 0x80
	retlw	d'15' + 0x80
	retlw	d'16' + 0x80
	retlw	d'17' + 0x80
	retlw	d'18' + 0x80
	retlw	d'19' + 0x80
	retlw	d'20' + 0x80
	retlw	d'21' + 0x80
	retlw	d'22' + 0x80
	retlw	d'23' + 0x80
	retlw	d'24' + 0x80
	retlw	d'25' + 0x80
	retlw	d'26' + 0x80
	retlw	d'27' + 0x80
	retlw	d'28' + 0x80
	retlw	d'29' + 0x80
	retlw	d'32' + 0x80
	retlw	d'33' + 0x80
	retlw	d'34' + 0x80
	retlw	d'35' + 0x80
	
;#########################################################	
; This function returns the heart off count for the various badge modes
;#########################################################	
_2_SELECT_HEART
	movf	badge_status, W		; check if dead if so do not update the LED anymore (LED updated to dead status in death routine) 
	andlw	0x03
	brw							; jump to LED reset value
	retlw	heart_led_sleep		; dead	(not used make = to sleep)
	retlw	heart_led_sleep		; sleep
	retlw	heart_led_active	; active
	retlw	heart_led_hyper		; hyper
	
;#########################################################	
; This function updates the oLED set to value in W and adds one if badge is sick
;#########################################################	
_2_set_oLED_mode
	movwf	oLED_set				; new set to move to 
	movlw	high(ram_status)			;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	movf	INDF1, W
	andlw	0x06
	xorlw	0x04					; check if badge has pink eye but has not been cured yet. 
	btfsc	STATUS, Z
	incf	oLED_set, F
	clrf	oLED_delay				; stop the counter update first then clear the internal phase
	clrf	oLED_phase
	clrf	oLED_seq_cnt	
	; clear out any one shots that may be in progress
	bcf	oLED_ctrl, 0				; bit 0 = one shot start, 1 = one shot done	
	bcf	oLED_ctrl, 1				; bit 0 = one shot start, 1 = one shot done	
	return

;#########################################################	
; This function updates the oLED set to value in W and adds one if badge is sick
;#########################################################	
_2_set_oLED_mode_one_shot
	movwf	oLED_set				; new set to move to 
	movlw	high(ram_status)			;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	movf	INDF1, W
	andlw	0x06
	xorlw	0x04					; check if badge has pink eye but has not been cured yet. 
	btfsc	STATUS, Z
	incf	oLED_set, F
	clrf	oLED_delay				; stop the counter update first then clear the internal phase
	clrf	oLED_phase
	clrf	oLED_seq_cnt	
	; clear out any one shots that may be in progress
	bcf		oLED_ctrl, 0				; bit 0 = one shot start, 1 = one shot done	
	bcf		oLED_ctrl, 1				; bit 0 = one shot start, 1 = one shot done	
	bsf		oLED_ctrl, 0			; bit 0 = one shot start, 1 = one shot done	
	return
	
	
	
;--------------------------------------------------------------------------------------	
	
LED_SELFTEST
	; start of LED self test code
	clrf	seq_cnt
LED_SELFTEST_LOOP1
	movf	seq_cnt, W
	call	_2_LED_ST_LUT1
	movwf	i2c_off			    ; address byte
	movlw	0xff
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_1	
	call	_2_LED_SET_1			; update the leds to the new state
	
	movlw	0x02
	movwf	delay_cnt
LED_SELFTEST_DELAY1
	movf	delay_cnt, W
	btfss	STATUS, Z
	goto	LED_SELFTEST_DELAY1

	movf	seq_cnt, W
	call	_2_LED_ST_LUT1
	movwf	i2c_off			    ; address byte
	movlw	0x00
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_1	
	call	_2_LED_SET_1			; update the leds to the new state

	incf	seq_cnt, F
	movf	seq_cnt, W
	sublw	d'35'		; C = 0 when W > k, C = 1 when W <= K
	btfsc	STATUS, C
	goto	LED_SELFTEST_LOOP1
	
	call	_2_LED_SET_1			; update the leds to the new state

	clrf	seq_cnt
LED_SELFTEST_LOOP2
	movf	seq_cnt, W
	call	_2_LED_ST_LUT2
	movwf	i2c_off			    ; address byte
	movlw	0xff
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_2	
	call	_2_LED_SET_2			; update the leds to the new state
	
	movlw	0x02
	movwf	delay_cnt
LED_SELFTEST_DELAY2
	movf	delay_cnt, W
	btfss	STATUS, Z
	goto	LED_SELFTEST_DELAY2

	movf	seq_cnt, W
	call	_2_LED_ST_LUT2
	movwf	i2c_off			    ; address byte
	movlw	0x00
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_2	

	incf	seq_cnt, F
	movf	seq_cnt, W
	sublw	d'35'		; C = 0 when W > k, C = 1 when W <= K
	btfsc	STATUS, C
	goto	LED_SELFTEST_LOOP2
	
	call	_2_LED_SET_2			; update the leds to the new state
	
	btfss	PORTA, 3			; social button
	goto	LED_SELFTEST
	movlp	0x00
	goto	LED_SELFTEST_DONE
	

	
;--------------------------------------------------------------------------------------------------------------------------------------------------	
MAINLOOP2_postcon
	
	; delay in this mode 
	movf	game_tick, W
	btfss	STATUS, Z
	goto	MAINLOOP2

	; set eye animation
MAINLOOP2_postcon_cycle_oLED		
	call	_2_CYCLE_LFSR
	andlw	0x0F
	movwf	oLED_set	
	; skip the HBDH set
	sublw	LAST_PRE_Hyr0n_animation			; k - W, C = 0 if W > k, C = 1 if W <= k	
	btfss	STATUS, C
	goto	MAINLOOP2_postcon_cycle_oLED		
	clrf	oLED_delay				; stop the counter update first then clear the internal phase
	clrf	oLED_phase
	clrf	oLED_seq_cnt		

	; clean up leds (causes a glitch on refresh if staying set)
	bsf	g_flags, 1	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off	
	bsf	g_flags, 2	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off	
	
	; food LED
	movlw	0xFF
	movwf	food_cnt
	call	_2_CYCLE_LFSR	
	sublw	0x20			; k - W, C = 0 if W > k, C = 1 if W <= k	
	btfsc	STATUS, C
	clrf	food_cnt

	; poo LED
	movlw	0xFF
	movwf	poo_cnt
	call	_2_CYCLE_LFSR	
	sublw	0xE0			; k - W, C = 0 if W > k, C = 1 if W <= k	
	btfsc	STATUS, C
	clrf	poo_cnt
	
	; Set up FSR
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	
	; Egg LED
	bsf	INDF1, 3		;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start	
	call	_2_CYCLE_LFSR	
	sublw	0x10			; k - W, C = 0 if W > k, C = 1 if W <= k	
	btfsc	STATUS, C
	bcf	INDF1, 3		;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start	
	
	; PRECON mode
	bcf	INDF1, 0		;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start	
	call	_2_CYCLE_LFSR	
	sublw	0x08			; k - W, C = 0 if W > k, C = 1 if W <= k	
	btfsc	STATUS, C
	bsf	INDF1, 0		;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start	
		
	; uber mode
	bsf	INDF1, 6		;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start	
	call	_2_CYCLE_LFSR	
	sublw	0x10			; k - W, C = 0 if W > k, C = 1 if W <= k	
	btfsc	STATUS, C
	bcf	INDF1, 6		;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start	

	; quest modes
	bsf	INDF1, 4		;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start		call	_2_CYCLE_LFSR	
	bsf	INDF1, 5		;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start		call	_2_CYCLE_LFSR	
	call	_2_CYCLE_LFSR	
	sublw	0x10			; k - W, C = 0 if W > k, C = 1 if W <= k	
	btfss	STATUS, C
	goto	MAINLOOP2_postcon_no_quest
	bcf	INDF1, 4		;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start	
	; Clear quest ID (controls white breathing vs green blink)
	movlw	high(ram_questID)	
	movwf	FSR1H
	movlw	low(ram_questID)
	movwf	FSR1L	
	movlw	0xFF
	movwi	FSR1++
	movwf	INDF1
	call	_2_CYCLE_LFSR	
	sublw	0x80			; k - W, C = 0 if W > k, C = 1 if W <= k	
	btfss	STATUS, C
	clrf	INDF1
MAINLOOP2_postcon_no_quest
	
	; heart 
	movf	badge_status, W
	andlw	0xFC
	movwf	badge_status
	call	_2_CYCLE_LFSR	
	andlw	0x03
	iorwf	badge_status,F
	
	
	movlw	POSTCON_MODE_TIME
	movwf	game_tick		
	
;--------------------------------------------------------------------------------------------------------------------------------------------------	
MAINLOOP2 

	; this is all oLED management related
	movlp	0x18
	goto	MAINLOOP3
MAINLOOP3_return	
	
	
	
	; control LED updates
	; heart
	movf	delay_cnt, W
	btfss	STATUS, Z
	goto	MAINLOOP2_no_heart
	movf	badge_status, W		; check if dead if so do not update the LED anymore (LED updated to dead status in death routine) 
	andlw	0x03
	btfsc	STATUS, Z
	goto	MAINLOOP2_no_heart
	incf	heart_seq, F
	incf	delay_cnt, F
	movf	heart_seq, W
	xorlw	0x01
	btfsc	STATUS, Z
	goto	MAINLOOP2_heart_on
	movf	heart_seq, W
	xorlw	0x02
	btfsc	STATUS, Z
	goto	MAINLOOP2_heart_off
	movf	heart_seq, W
	xorlw	0x03
	btfsc	STATUS, Z
	goto	MAINLOOP2_heart_on
	movf	heart_seq, W
	xorlw	0x04
	btfsc	STATUS, Z
	goto	MAINLOOP2_heart_off
	call	_2_SELECT_HEART
	subwf	heart_seq, W			; f - W, C = 0 if W > f, C = 1 if W <= f	
	btfsc	STATUS, C
	clrf	heart_seq
	goto	MAINLOOP2_no_heart
MAINLOOP2_heart_off	
	movlw	D'30'			    ; address byte
	movwf	i2c_off			    ; address byte
	movlw	0x00				
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_2
	call	_2_LED_SET_2			; update the leds to the new state
	goto	MAINLOOP2_no_heart
MAINLOOP2_heart_on
	movlw	d'30'
	movwf	i2c_off			    ; address byte
	movlw	icon_pwms
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_2	
	call	_2_LED_SET_2			; update the leds to the new state
MAINLOOP2_no_heart	
	; egg LED
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	movf	INDF1, W
	andlw	0x08			; has egg
	btfss	STATUS, Z
	goto	MAINLOOP2_no_egg	
	bsf	badge_status, 2		; set egg present bit
	movf	egg_delay, W
	btfss	STATUS,Z
	goto	MAINLOOP2_no_egg_update
	movlw	0x01
	movwf	egg_delay	
	btfss	badge_ctrl, 3		; bit 0 = logo tick , bit 1 = poo led, bit 2 = postcon mode, bit 3 = egg up/down
	goto	MAINLOOP2_egg_down
MAINLOOP2_egg_up	
	bsf	badge_ctrl, 3		; bit 0 = logo tick , bit 1 = poo led, bit 2 = postcon mode, bit 3 = egg up/down
	movlw	0x08
	addwf	egg_breath, F
	btfss	STATUS, C
	goto	MAINLOOP2_egg_ready
	movlw	0xFF
	movwf	egg_breath
MAINLOOP2_egg_down
	bcf	badge_ctrl, 3		; bit 0 = logo tick , bit 1 = poo led, bit 2 = postcon mode, bit 3 = egg up/down
	movlw	0x08
	subwf	egg_breath, F
	btfsc	STATUS, C
	goto	MAINLOOP2_egg_ready
	clrf	egg_breath
	goto	MAINLOOP2_egg_up
MAINLOOP2_egg_ready	
	movlw	d'36'
	movwf	i2c_off			    ; address byte
	movf	egg_breath, W
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_2	
	call	_2_LED_SET_2			; update the leds to the new state	
	goto	MAINLOOP2_no_egg_update
MAINLOOP2_no_egg	
	btfss	badge_status, 2
	goto	MAINLOOP2_no_egg_update
	movlw	D'36'				; address byte
	movwf	i2c_off			    ; address byte
	movlw	0x00				
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_2
	call	_2_LED_SET_2			; update the leds to the new state
	bcf		badge_status, 2
MAINLOOP2_no_egg_update
	
	
	
UPDATE_LOGO		
	; update counters
	; check for quest done
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfss	INDF1, 5			; 0 = quest done
	goto	LOGO_not_quest
	; check for quest mode
	btfsc	INDF1, 4			; 0 = in quest mode
	goto	LOGO_not_quest
	; check if quest is complete
	movlw	high(ram_questID)	
	movwf	FSR1H
	movlw	low(ram_questID)
	movwf	FSR1L	
	comf	INDF1, W
	btfss	STATUS, Z
	goto	LOGO_quest_done
	moviw	++FSR1				; easier than 16 bit math
	comf	INDF1, W
	btfsc	STATUS, Z
	goto	LOGO_quest
LOGO_quest_done	
	; check if update delay is done
	btfss	badge_ctrl, 0
	goto	LOGO_update_done
	bcf	badge_ctrl, 0	
	; quest ID recorded so task is done (blink green)
	clrf	logo_a				; amber LEDs off
	clrf	logo_r
	clrf	logo_b
	btfss	badge_status, 6			; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
	goto	LOGO_green_blink_on
	clrf	logo_g
	bcf	badge_status, 6			; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
	goto	LOGO_load_leds	
LOGO_green_blink_on
	movlw	0xFF
	movwf	logo_g
	bsf	badge_status, 6			; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
	goto	LOGO_load_leds	
LOGO_quest
	clrf	logo_a				; amber LEDs off
	btfss	badge_status, 5			; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
	goto	LOGO_down_white

	incf	logo_r, F
	movf	logo_r, W
	movwf	logo_r
	movwf	logo_g
	movwf	logo_b
	
	comf	logo_r, W
	btfsc	STATUS, Z
	bcf	badge_status, 5
	goto	LOGO_skip_white
	
LOGO_down_white
	decf	logo_r, F
	movf	logo_r, W
	movwf	logo_r
	movwf	logo_g
	movwf	logo_b
	btfsc	STATUS, Z
	bsf	badge_status, 5

LOGO_skip_white	
	goto	LOGO_load_leds

LOGO_not_quest
	; check if con started
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfss	INDF1, 0			; if set non uber mode
	goto	LOGO_not_quest_con_on
	; check if update delay is done
	movf	delay_cnt, W
	btfss	STATUS, Z	
	goto	LOGO_update_done
	movlw	0x01			; SUPPPER slow delay
	movwf	delay_cnt
	goto	LOGO_not_quest_update
	
LOGO_not_quest_con_on	
	; check if uber if so fast mode else slow
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfss	INDF1, 6			; if set non uber mode
	goto	LOGO_not_quest_update
	; check if update delay is done
	movlw	0x01
	subwf	logo_cntL, F			; f - W, C = 0 if W > f, C = 1 if W <= f
	movlw	0x00
	subwfb	logo_cntH, F			; f - W - #B, C = 0 if (W + #B) > f, C = 1 if (W + #B) <= f
	btfsc	STATUS, C
	goto	LOGO_update_done
	movlw	LOW(LOGO_SPEED)
	movwf	logo_cntL	
	movlw	HIGH(LOGO_SPEED)
	movwf	logo_cntH	
	
	
LOGO_not_quest_update	
; old code power draw too high. 	
;	; normal fade mode
;	btfss	badge_status, 4			; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
;	goto	LOGO_down_amber
;	incf	logo_a, F
;	comf	logo_a, W
;	btfsc	STATUS, Z
;	bcf	badge_status, 4
;	goto	LOGO_skip_amber
;LOGO_down_amber	
;	decf	logo_a, F
;	movf	logo_a, W
;	btfsc	STATUS, Z
;	bsf	badge_status, 4
;LOGO_skip_amber	
;
;	btfss	badge_status, 5			; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
;	goto	LOGO_down_red
;	incf	logo_r, F
;	comf	logo_r, W
;	btfsc	STATUS, Z
;	bcf	badge_status, 5
;	goto	LOGO_skip_red
;LOGO_down_red	
;	decf	logo_r, F
;	movf	logo_r, W
;	btfsc	STATUS, Z
;	bsf	badge_status, 5
;	movf	logo_r, W
;	xorlw	0x20
;	btfss	STATUS,	Z
;	goto	LOGO_skip_red
;	movlw	0x04
;	subwf	logo_r, F
;LOGO_skip_red	
;
;	btfss	badge_status, 6			; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
;	goto	LOGO_down_green
;	incf	logo_g, F
;	comf	logo_g, W
;	btfsc	STATUS, Z
;	bcf	badge_status, 6
;	goto	LOGO_skip_green
;LOGO_down_green	
;	decf	logo_g, F
;	movf	logo_g, W
;	btfsc	STATUS, Z
;	bsf	badge_status, 6
;	movf	logo_g, W
;	xorlw	0x10
;	btfss	STATUS,	Z
;	goto	LOGO_skip_green
;	movlw	0x07
;	subwf	logo_g, F
;LOGO_skip_green	
;
;	btfss	badge_status, 7			; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
;	goto	LOGO_down_blue
;	incf	logo_b, F
;	comf	logo_b, W
;	btfsc	STATUS, Z
;	bcf	badge_status, 7
;	goto	LOGO_skip_blue
;LOGO_down_blue	
;	decf	logo_b, F
;	movf	logo_b, W
;	btfsc	STATUS, Z
;	bsf	badge_status, 7
;	movf	logo_b, W
;	xorlw	0x10
;	btfss	STATUS,	Z
;	goto	LOGO_skip_blue
;	movlw	0x0A
;	subwf	logo_b, F
;LOGO_skip_blue	

	
	
; new hopefully lower power method
	; amber up
	movf	logo_seq, W
	btfss	STATUS, Z
	goto	LOGO_not_seq0
	incf	logo_a, F
	comf	logo_a, W
	btfsc	STATUS, Z
	incf	logo_seq, F
	goto	LOGO_load_leds	
LOGO_not_seq0	
	; amber down
	movf	logo_seq, W
	xorlw	0x01
	btfss	STATUS, Z
	goto	LOGO_not_seq1
	decf	logo_a, F
	movf	logo_a, W
	btfsc	STATUS, Z
	incf	logo_seq, F
	goto	LOGO_load_leds	
LOGO_not_seq1
	; red up
	movf	logo_seq, W
	xorlw	0x02
	btfss	STATUS, Z
	goto	LOGO_not_seq2
	incf	logo_r, F
	comf	logo_r, W
	btfsc	STATUS, Z
	incf	logo_seq, F
	goto	LOGO_load_leds	
LOGO_not_seq2	
	; red down
	movf	logo_seq, W
	xorlw	0x03
	btfss	STATUS, Z
	goto	LOGO_not_seq3
	decf	logo_r, F
	movf	logo_r, W
	btfsc	STATUS, Z
	incf	logo_seq, F
	goto	LOGO_load_leds	
LOGO_not_seq3
	; amber up
	movf	logo_seq, W
	xorlw	0x04
	btfss	STATUS, Z
	goto	LOGO_not_seq4
	incf	logo_a, F
	comf	logo_a, W
	btfsc	STATUS, Z
	incf	logo_seq, F
	goto	LOGO_load_leds	
LOGO_not_seq4
	; amber down
	movf	logo_seq, W
	xorlw	0x05
	btfss	STATUS, Z
	goto	LOGO_not_seq5
	decf	logo_a, F
	movf	logo_a, W
	btfsc	STATUS, Z
	incf	logo_seq, F
	goto	LOGO_load_leds	
LOGO_not_seq5
	; red up
	movf	logo_seq, W
	xorlw	0x06
	btfss	STATUS, Z
	goto	LOGO_not_seq6
	incf	logo_g, F
	comf	logo_g, W
	btfsc	STATUS, Z
	incf	logo_seq, F
	goto	LOGO_load_leds	
LOGO_not_seq6
	; red down
	movf	logo_seq, W
	xorlw	0x07
	btfss	STATUS, Z
	goto	LOGO_not_seq7
	decf	logo_g, F
	movf	logo_g, W
	btfsc	STATUS, Z
	incf	logo_seq, F
	goto	LOGO_load_leds	
LOGO_not_seq7
	; amber up
	movf	logo_seq, W
	xorlw	0x08
	btfss	STATUS, Z
	goto	LOGO_not_seq8
	incf	logo_a, F
	comf	logo_a, W
	btfsc	STATUS, Z
	incf	logo_seq, F
	goto	LOGO_load_leds	
LOGO_not_seq8
	; amber down
	movf	logo_seq, W
	xorlw	0x09
	btfss	STATUS, Z
	goto	LOGO_not_seq9
	decf	logo_a, F
	movf	logo_a, W
	btfsc	STATUS, Z
	incf	logo_seq, F
	goto	LOGO_load_leds	
LOGO_not_seq9
	; red up
	movf	logo_seq, W
	xorlw	0x0A
	btfss	STATUS, Z
	goto	LOGO_not_seqA
	incf	logo_b, F
	comf	logo_b, W
	btfsc	STATUS, Z
	incf	logo_seq, F
	goto	LOGO_load_leds	
LOGO_not_seqA
	; red down
	movf	logo_seq, W
	xorlw	0x0B
	btfss	STATUS, Z
	goto	LOGO_not_seqB
	decf	logo_b, F
	movf	logo_b, W
	btfss	STATUS, Z
	goto	LOGO_load_leds	
	incf	logo_seq, F	
LOGO_not_seqB
	; catch all to clean things up if out of sync
	clrf	logo_seq
	
LOGO_load_leds	
	call	_2_I2C_START	
	movlw	0x78				; ISSI chip address
	call	_2_SEND_W_I2C
	movlw	d'3'				; reg offset
	call	_2_SEND_W_I2C	
	movlw	0x05				; loop though 5 times to update all 4 led banks
	movwf	temp	
LOGO_update_loop1	
	movf	logo_a,	W			; amber leds
	call	_2_SEND_W_I2C
	movf	logo_r,	W			; red leds
	call	_2_SEND_W_I2C
	movf	logo_g, W			; green leds
	call	_2_SEND_W_I2C
	movf	logo_b, W			; blue leds
	call	_2_SEND_W_I2C
	decfsz	temp, F
	goto	LOGO_update_loop1
	movf	logo_a,	W			
	call	_2_SEND_W_I2C		; last amber led 
	call	_2_I2C_STOP	
	
	call	_2_LED_SET_1			; update the leds to the new state	
	call	_2_LED_SET_2			; update the leds to the new state	
	
LOGO_update_done
		
	

UPDATE_BODY
	call	_2_CYCLE_LFSR		; ok this was a lazy hack to keep the LFSR updating even when the con is not running. This is used by the once code as well so don't want stale data out there. 	
	
	
	; check if a sparkle LED is on right now
	movf	sparkle_last, W		; if 0 (init value) skip this code
	btfsc	STATUS, Z
	goto	BODY_bank_done_off

	; set up the delay to the next LED on 
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfss	INDF1, 6			
	goto	UPDATE_BODY_uber
	movf	INDF1, W
	andlw	0x30
	xorlw	0x20
	btfss	STATUS, Z
	goto	UPDATE_BODY_not_quest
	; check if quest is done
	movlw	high(ram_questID)	
	movwf	FSR1H
	movlw	low(ram_questID)
	movwf	FSR1L	
	comf	INDF1, W
	btfss	STATUS, Z
	goto	UPDATE_BODY_quest_done
	moviw	++FSR1				; easier than 16 bit math
	comf	INDF1, W
	btfss	STATUS, Z
	goto	UPDATE_BODY_quest_done
	movlw	0x10			; normal quest in progress
	movwf	sparkle_skip
	goto	UPDATE_BODY_not_uber
UPDATE_BODY_quest_done	
	movlw	0xFF			; normal quest done
	movwf	sparkle_skip
	goto	UPDATE_BODY_not_uber	
UPDATE_BODY_not_quest	
	movlw	0xFF			; normal non quest mode
	movwf	sparkle_skip
	goto	UPDATE_BODY_not_uber
UPDATE_BODY_uber
	movlw	0x01			; uber mode			
	movwf	sparkle_skip
UPDATE_BODY_not_uber	
	
	; turn off last random on LED. 
	btfss	sparkle_last, 7
	goto	BODY_bank1_off
	bcf	sparkle_last, 7
	call	_2_I2C_START	
	movlw	0x7E			    ; ISSI chip address
	call	_2_SEND_W_I2C
	movf	sparkle_last, W			; reg offset
	call	_2_SEND_W_I2C	
	movlw	0x00				; reg value
	call	_2_SEND_W_I2C
	call	_2_I2C_STOP
	clrf	sparkle_last
	goto	BODY_bank_done_off
BODY_bank1_off
	call	_2_I2C_START	
	movlw	0x78			    ; ISSI chip address
	call	_2_SEND_W_I2C
	movf	sparkle_last, W			; reg offset
	call	_2_SEND_W_I2C	
	movlw	0x00				; reg value
	call	_2_SEND_W_I2C
	call	_2_I2C_STOP	
	clrf	sparkle_last
BODY_bank_done_off	

	; check if con has started
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfsc	INDF1, 0			; 0 = con started
	goto	BODY_bank_skip	
	
	; non uber skip a few cycle before next blink
	decfsz	sparkle_skip, F
	goto	BODY_bank_skip
	
	; randomly select LED and value
BODY_lfsr_loop		
	call	_2_CYCLE_LFSR
	andlw	0x3F
	movwf	temp1
	sublw	d'46'			; k - W, C = 0 if W > k, C = 1 if W <= k	
	btfss	STATUS, C
	goto	BODY_lfsr_loop
	movf	temp1, W
	call	_2_SELECT_PINK
	movwf	temp1
	movwf	sparkle_last
	btfss	temp1, 7
	goto	BODY_bank1
	bcf	temp1, 7
	call	_2_I2C_START	
	movlw	0x7E			    ; ISSI chip address
	call	_2_SEND_W_I2C
	movf	temp1, W			; reg offset
	call	_2_SEND_W_I2C	
	call	_2_CYCLE_LFSR
	;movlw	0xFF				; reg value
	call	_2_SEND_W_I2C
	call	_2_I2C_STOP	
	goto	BODY_bank_done
BODY_bank1	
	call	_2_I2C_START	
	movlw	0x78			    ; ISSI chip address
	call	_2_SEND_W_I2C
	movf	temp1, W			; reg offset
	call	_2_SEND_W_I2C	
	call	_2_CYCLE_LFSR
	;movlw	0xFF			    ; reg value
	call	_2_SEND_W_I2C
	call	_2_I2C_STOP	
BODY_bank_done	
	call	_2_LED_SET_1			; update the leds to the new state	
	call	_2_LED_SET_2			; update the leds to the new state	
BODY_bank_skip	

	
	
	
	; check if warning lights need to be updated
	btfss	g_flags, 1	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off
	goto	MAINLOOP2_no_force_stomach
	; turn off stomach
	movlw	D'31'			    ; address byte
	movwf	i2c_off			    ; address byte
	movlw	0x00				
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_2
	call	_2_LED_SET_2			; update the leds to the new state
	bcf		g_flags, 1	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off
MAINLOOP2_no_force_stomach
	; turn off poo
	btfss	g_flags, 2	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off
	goto	MAINLOOP2_no_force_poo
	; turn off stomach
	movlw	D'28'			    ; address byte
	movwf	i2c_off			    ; address byte
	movlw	0x00				
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_1
	call	_2_LED_SET_1			; update the leds to the new state
	bcf		g_flags, 2	; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off
MAINLOOP2_no_force_poo		
	
	; update counter values
	movf	time_passed, W
	btfsc	STATUS, Z
	goto	MAINLOOP2_no_counter_update
	movwf	temp
	clrf	time_passed
	
	; if in postcon mode don't update counters or auto switch modes. (done above in the postcon ranomizer code) 
	btfsc	badge_ctrl, 2	    ; bit 0 = logo tick , bit 1 = poo led, bit 2 = postcon mode	
	goto	MAINLOOP2_postcon_skip_chks
	
	; check if con is running if not skip all 
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	movf	INDF1, W
	movwf	temp1
	andlw	0x01				; con started?
	btfss	STATUS, Z
	goto	MAINLOOP2_no_counter_update
	; check if badge is dead	
	movf	INDF1, W
	andlw	0x80				; is badge dead
	btfsc	STATUS, Z
	goto	MAINLOOP2_dead_led_skip	

MAINLOOP2_postcon_skip_chks	
	
	; this should tick over once a second use to blink warning lights as well	
	movlw	food_warn
	subwf	food_cnt, W			; f - W, C = 0 if W > f, C = 1 if W <= f	
	btfsc	STATUS, C
	goto	MAINLOOP2_no_food_warn
	btfsc	badge_status, 3		; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
	goto	MAINLOOP2_stomach_off
	; turn on stomach
	movlw	D'31'			    ; address byte
	movwf	i2c_off			    ; address byte
	movlw	0xFF				
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_2	
	call	_2_LED_SET_2			; update the leds to the new state
	bsf		badge_status, 3
	goto	MAINLOOP2_no_food_warn
MAINLOOP2_stomach_off	
	; turn off stomach
	movlw	D'31'			    ; address byte
	movwf	i2c_off			    ; address byte
	movlw	0x00				
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_2
	call	_2_LED_SET_2			; update the leds to the new state
	bcf		badge_status, 3
MAINLOOP2_no_food_warn	

	; this should tick over once a second use to blink warning lights as well	
	movlw	poo_warn
	subwf	poo_cnt, W			; f - W, C = 0 if W > f, C = 1 if W <= f	
	btfss	STATUS, C
	goto	MAINLOOP2_no_poo_warn
	btfsc	badge_ctrl, 1		; bit 0 = body uber, bit 1 = poo led	
	goto	MAINLOOP2_poo_off
	; turn on stomach
	movlw	D'28'			    ; address byte
	movwf	i2c_off			    ; address byte
	movlw	0xFF				
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_1
	call	_2_LED_SET_1			; update the leds to the new state
	bsf		badge_ctrl, 1
	goto	MAINLOOP2_no_poo_warn
MAINLOOP2_poo_off	
	; turn off stomach
	movlw	D'28'			    ; address byte
	movwf	i2c_off			    ; address byte
	movlw	0x00				
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_1
	call	_2_LED_SET_1			; update the leds to the new state
	bcf		badge_ctrl, 1
MAINLOOP2_no_poo_warn	
	
MAINLOOP2_dead_led_skip	
	

	; if in postcon mode don't update counters or auto switch modes. (done above in the postcon ranomizer code) 
	btfsc	badge_ctrl, 2	    ; bit 0 = logo tick , bit 1 = poo led, bit 2 = postcon mode	
	goto	MAINLOOP2_return_2_MAINLOOP
	
	
	; check if there is an egg (this counter runs even when dead...)
	btfsc	temp1, 3			; 0 = has egg     ; bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	goto	MAINLOOP2_no_counter_egg
	movlw	high(ram_prego)	
	movwf	FSR0H
	movlw	low(ram_prego)
	movwf	FSR0L	
	movf	temp, W
	call	_2_3BYTE_SUB_N_STOP
MAINLOOP2_no_counter_egg	
	; check badge status and add time where it should go
	movf	badge_status, W
	andlw	0x03
	xorlw	0x01
	btfss	STATUS,	Z
	goto	MAINLOOP2_no_counter_sleep
	movlw	high(ram_sleep)	
	movwf	FSR0H
	movlw	low(ram_sleep)
	movwf	FSR0L	
	movf	temp, W
	call	_2_3BYTE_SUB_N_STOP	
MAINLOOP2_no_counter_sleep	
	movf	badge_status, W
	andlw	0x03
	xorlw	0x02
	btfss	STATUS,	Z
	goto	MAINLOOP2_no_counter_active
	movlw	high(ram_active)	
	movwf	FSR0H
	movlw	low(ram_active)
	movwf	FSR0L	
	movf	temp, W
	call	_2_3BYTE_SUB_N_STOP	
MAINLOOP2_no_counter_active	
	movf	badge_status, W
	andlw	0x03
	xorlw	0x03
	btfss	STATUS,	Z
	goto	MAINLOOP2_no_counter_hyper
	movlw	high(ram_hyper)	
	movwf	FSR0H
	movlw	low(ram_hyper)
	movwf	FSR0L	
	movf	temp, W
	call	_2_3BYTE_SUB_N_STOP	
MAINLOOP2_no_counter_hyper
	; no need to check the dead state as there is no counter for that one. 
		
MAINLOOP2_no_counter_update		

	
	
	; check if con is started
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	movf	INDF1, W
	andlw	0x01				; con started?
	btfss	STATUS, Z
	goto	MAINLOOP2_DEEP_SLEEP
	; check if badge is dead	
	movf	INDF1, W
	andlw	0x80				; is badge dead
	btfsc	STATUS, Z
	goto	MAINLOOP2_return_2_MAINLOOP
	;------------------------------------------------------------------------
	; stuff here that is only valid when not dead and con start (most things)
	;------------------------------------------------------------------------	

	
	; change mode when timer expires
	movf	delay_downH, W
	btfss	STATUS, Z
	goto	MAINLOOP2_no_mode_shift	
	movf	delay_downL, W
	btfss	STATUS, Z
	goto	MAINLOOP2_no_mode_shift	
MAINLOOP2_mode_shift
	movf	badge_status, W
	andlw	0x03
	xorlw	0x03
	btfss	STATUS, Z
	goto	MAINLOOP2_shift_sleep
	bcf		badge_status, 0			; move from hyper to active..
	movlw	low(active_to_sleep)
	movwf	delay_downL
	movlw	high(active_to_sleep)
	movwf	delay_downH	
	; update the eye animation 
	movlw	0x04					; set to normal animation
	call	_2_set_oLED_mode		
	goto	MAINLOOP2_no_mode_shift
MAINLOOP2_shift_sleep	
	movf	badge_status, W
	andlw	0x03
	xorlw	0x02
	btfss	STATUS, Z
	goto	MAINLOOP2_no_mode_shift
	bcf		badge_status, 1			; move from active to sleep
	bsf		badge_status, 0			; move from active to sleep
	; indicate that this needs to be saved on next mainloop (sleep only happens every 15 min and good op to save counters). 
	bsf		g_flags, 0		
	; no downshift timer here
	; update the eye animation 
	movlw	0x06					; set to sleep animation
	call	_2_set_oLED_mode		
MAINLOOP2_no_mode_shift	
	
	; check food consumption
	movf	game_tick, W
	btfss	STATUS, Z
	goto	MAINLOOP2_no_tick
	; check if sleeping (con start and dead check is above)
	movf	badge_status, W		; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
	andlw	0x03
	xorlw	0x01
	btfsc	STATUS, Z
	goto	MAINLOOP2_no_tick
	; reload game_tick
	movlw	game_tick_time
	movwf	game_tick
	; check for the sickness
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	btfsc	INDF1, 1
	goto	MAINLOOP2_not_sick
	btfss	INDF1, 2
	goto	MAINLOOP2_not_sick
	; this badge is sick use the higher food rates
	; check for hyper
	movf	badge_status, W
	andlw	0x03
	xorlw	0x03
	btfss	STATUS, Z
	goto	MAINLOOP2_active_sick
	; update food counter (subtract value and die if 0)
	movlw	food_hyper_sick
	subwf	food_cnt, F			; f - W, C = 0 if W > f, C = 1 if W <= f	
	btfss	STATUS, C
	goto	MAINLOOP2_die
	; update poo countere (add 1 for every used up to 0xFF)
	movlw	food_hyper_sick
	addwf	poo_temp, F			
;	btfss	STATUS, C
	goto	MAINLOOP2_poop_chk
;	movlw	0xFF
;	movwf	poo_cnt		
;	goto	MAINLOOP2_no_tick
MAINLOOP2_active_sick	
	; update food counter (subtract value and die if 0)
	movlw	food_active_sick
	subwf	food_cnt, F			; f - W, C = 0 if W > f, C = 1 if W <= f	
	btfss	STATUS, C
	goto	MAINLOOP2_die
	; update poo countere (add 1 for every used up to 0xFF)
	movlw	food_active_sick
	addwf	poo_temp, F			
;	btfss	STATUS, C
	goto	MAINLOOP2_poop_chk
;	movlw	0xFF
;	movwf	poo_cnt	
;	goto	MAINLOOP2_no_tick
MAINLOOP2_not_sick	
	; check for hyper
	movf	badge_status, W
	andlw	0x03
	xorlw	0x03
	btfss	STATUS, Z
	goto	MAINLOOP2_active
	; update food counter (subtract value and die if 0)
	movlw	food_hyper
	subwf	food_cnt, F			; f - W, C = 0 if W > f, C = 1 if W <= f	
	btfss	STATUS, C
	goto	MAINLOOP2_die
	; update poo countere (add 1 for every used up to 0xFF)
	movlw	food_hyper
	addwf	poo_temp, F			
;	btfss	STATUS, C
	goto	MAINLOOP2_poop_chk
;	movlw	0xFF
;	movwf	poo_cnt		
;	goto	MAINLOOP2_no_tick
MAINLOOP2_active	
	; update food counter (subtract value and die if 0)
	movlw	food_active
	subwf	food_cnt, F			; f - W, C = 0 if W > f, C = 1 if W <= f	
	btfss	STATUS, C
	goto	MAINLOOP2_die
	; update poo countere (add 1 for every used up to 0xFF)
	movlw	food_active
	addwf	poo_temp, F			
;	btfss	STATUS, C
	goto	MAINLOOP2_poop_chk
;	movlw	0xFF
;	movwf	poo_cnt	
;	goto	MAINLOOP2_no_tick
MAINLOOP2_die
	; check if badge is undead (founder, lifetime, vendor)
	btfsc	g_flags, 5			; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off, bit 3 = enable TX delay, bit 4 = Hyron badge ID set, bit 5 = undead
	goto	MAINLOOP2_poop_chk
	clrf	food_cnt			; when food runs out it will loop around to FF and keep going lower. Set back to 0 to keep the debug easy. (note 0 food is ok -1 food kills ya)
	; update death bit
	movlw	high(ram_status)	;  bit 7 0 = dead, bit 6 0 = uber on, bit 5 0 = quest done, bit 4 0 = quest start, bit 3 = 0 has egg, bit 2 = 0 is cured, bit 1 = 0 has pink eye, bit 0 = 0 con start
	movwf	FSR1H
	movlw	low(ram_status)
	movwf	FSR1L	
	bcf		INDF1, 7			; set dead bit (inverted)
	; turn off heart 
	movlw	D'30'			    ; address byte
	movwf	i2c_off			    ; address byte
	movlw	0x00				
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_2
	; turn off stomach
	movlw	D'31'			    ; address byte
	movwf	i2c_off			    ; address byte
	movlw	0x00				
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_2
	call	_2_LED_SET_2			; update the leds to the new state	
	; turn off poo
	movlw	D'28'			    ; address byte
	movwf	i2c_off			    ; address byte
	movlw	0x00				
	movwf	i2c_dat0		    
	call	_2_LED_WRITE_1
	call	_2_LED_SET_1			; update the leds to the new state	
	; update badge status
	bcf		badge_status, 0		; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
	bcf		badge_status, 1		; bit 0,1 = 0 dead, 1 sleep, 2 active, 3 hyper; bit 2 = egg led state; bit 3 = stomach led state; bit 4 = amber dir; bit 5 = red dir; bit 6 = green dir; bit 7 = blue dir
	; update the death counter
	movlw	high(ram_died)	
	movwf	FSR0H
	movlw	low(ram_died)
	movwf	FSR0L		
	call	_2_2BYTE_DEC_N_STOP	
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0	
	; update the eye animation 
	movlw	0x08					; set to dead animation
	call	_2_set_oLED_mode
	
	
	
MAINLOOP2_poop_chk
	; check if there are enough temp poop points
	movlw	food2poop
	subwf	poo_temp, W			; f - W, C = 0 if W > f, C = 1 if W <= f
	btfss	STATUS, C
	goto	MAINLOOP2_no_tick
	movlw	food2poop
	subwf	poo_temp, F			; f - W, C = 0 if W > f, C = 1 if W <= f
	movlw	0x01
	addwf	poo_cnt, F			
	btfss	STATUS, C
	goto	MAINLOOP2_poop_chk
	movlw	0xFF
	movwf	poo_cnt	
	goto	MAINLOOP2_poop_chk
MAINLOOP2_no_tick		
	
	; debbounce button
	movf	button_up, W
	btfsc	STATUS, Z
	goto	mainloop_button_chk		; if debounce count is zero go check for a button press
	decf	button_up, F			; subtract one from counter
	btfsc	PORTA, 3				; social button
	goto	mainloop_button_chk_done
	movlw	0x40					; this debounce time is in 2 spots!
	movwf	button_up				; if button detected low during debounce reset the timer (maybe held down)
	goto	mainloop_button_chk_done
	
mainloop_button_chk		
	; check for button press 
	btfsc	PORTA, 3				; social button
	goto	mainloop_button_chk_done
	; set up for debounce
	movlw	0x40					; this debounce time is in 2 spots!
	movwf	button_up
	;move mode to hyper and set up timer to down shift to active
	movlw	0x03				; hyper mode
	iorwf	badge_status, F
	movlw	low(hyper_to_active)
	movwf	delay_downL
	movlw	high(hyper_to_active)
	movwf	delay_downH
	
	; update button click counter
	movlw	high(ram_button)	
	movwf	FSR0H
	movlw	low(ram_button)
	movwf	FSR0L	
	movlw	0x01
	call	_2_3BYTE_SUB_N_STOP	

		
	; update the eye animation 
	movlw	0x02					; set to hyper animation
	call	_2_set_oLED_mode	
	movlw	0x02					; set to hyper animation
	movwf	oLED_last				; save the previous setting
	movlw	0x0A					; set to eye beam animation
	call	_2_set_oLED_mode_one_shot	
	
	
	;------------------
	movlb	d'14'
	;------------------	
	btfsc	PIE3, TX1IE				; make sure TX routine is NOT already running. 
	goto	mainloop_button_chk_done
	;------------------
	movlb	d'2'
	;------------------	
	clrf	ir_tx_seq
	clrf	ir_tx_chksum
	; status updated other places just flow it here
	clrf	tx_type
		
	;------------------
	movlb	d'14'
	;------------------	
	bsf	PIE3, TX1IE				; enable Uart2 transmit IRQ		
		
mainloop_button_chk_done
	;------------------
	movlb	d'0'
	;------------------		

MAINLOOP2_return_2_MAINLOOP
	movlp	0x00					; select page 1
	goto	MAINLOOP
	
	
	
	
	
	
	
MAINLOOP2_DEEP_SLEEP
	
	; debbounce button
	movf	button_up, W
	btfsc	STATUS, Z
	goto	deepsleep_button_chk	; if debounce count is zero go check for a button press
	decf	button_up, F			; subtract one from counter
	btfsc	PORTA, 3				; social button
	goto	deepsleep_button_chk_done
	movlw	0x40					; this debounce time is in 2 spots!
	movwf	button_up				; if button detected low during debounce reset the timer (maybe held down)
	goto	deepsleep_button_chk_done
	
deepsleep_button_chk		
	; check for button press 
	btfsc	PORTA, 3				; social button
	goto	deepsleep_button_chk_done
	; set up for debounce
	movlw	0x40					; this debounce time is in 2 spots!
	movwf	button_up
	;set one shot wake animation here
	bsf		oLED_ctrl, 0			; bit 0 = one shot start, 1 = one shot done
	clrf	oLED_last				; set last animation to precon. 
	movlw	0x01					; sleep lazy eye
	movwf	oLED_set				; new set to move to 
	clrf	oLED_seq_cnt
	
deepsleep_button_chk_done	
	movlp	0x00					; select page 1
	goto	MAINLOOP
	
	
	
	

	

	
	
	
	
	
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; FLASH goto / call break here need to update the counter manually to jump back and forth from here.... 
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
;put the following at address 1000h
	org     1000h		

;################################################################################
; cycle the LFSR (sudo random) generator and return the new lower 8 result in W
;################################################################################
_3_CYCLE_LFSR
	movlp	0x08
	call	_2_CYCLE_LFSR
	movlp	0x10
	return	
	

	
DECRYPT_PACKET
	
	;------------------
	movlb	d'2'
	;------------------
	
	; ram buffer is twisted (first in is last byte) fix this 	
	movlw	high(start_rx_buffer)	
	movwf	FSR1H
	movlw	low(start_rx_buffer)
	movwf	FSR1L
	movlw	0x09
	addwf	FSR1L, F
	movlw	high(temp_crypt0)
	movwf	FSR0H
	movlw	low(temp_crypt0)
	movwf	FSR0L	
	movlw	0x0A
	movwf	loop_i
DECRYPT_PACKET_swap_packet	
	moviw	FSR1--
	movwi	FSR0++
	decfsz	loop_i, F
	goto	DECRYPT_PACKET_swap_packet	
	
	; copy decrypt key to ram
	movlw	high(start_key)
	movwf	FSR0H
	movlw	low(start_key)
	movwf	FSR0L
	movlw	high(temp_key0)
	movwf	FSR1H
	movlw	low(temp_key0)
	movwf	FSR1L
	movlw	0x0A
	movwf	loop_i
DECRYPT_PACKET_key_move_loop
	moviw	FSR0++
	movwi	FSR1++
	decfsz	loop_i, F
	goto	DECRYPT_PACKET_key_move_loop

	
	; cycle key
	;for ($i = 0; $i < $rounds; $i++){
	clrf	loop_i
DECRYPT_PACKET_cycle_key_i
	
	;$k0 = $temp_key[0 + $wbytes];
	movlw	high(temp_key0)
	movwf	FSR1H
	movlw	low(temp_key0)
	addlw	crypto_wbytes
	movwf	FSR1L	
	movf	INDF1, W
	movwf	k0
	
	;$ak = 0;
	clrf	ak
	
	;for ($j = 0; $j < $wbytes-1; $j++) {
	clrf	loop_j
DECRYPT_PACKET_cycle_key_j
	
	;$ak += $temp_key[$j] + $temp_key[$j + 1 + $wbytes];
	clrf	ak1
	movlw	0xF0
	andwf	FSR1L, F
	movf	loop_j, W
	addwf	FSR1L, F
	movf	INDF1, W
	addwf	ak, F
	btfsc	STATUS, C
	incf	ak1, F
	movlw	(crypto_wbytes + 1)
	addwf	FSR1, F
	moviw	FSR1--
	addwf	ak, F
	btfsc	STATUS, C
	incf	ak1, F
	
	;$temp_key[$j + $wbytes] = ($ak) & 0xFF;
	;decf	FSR1L, F taken care of by above moviw --
	movf	ak, W
	movwf	INDF1
	
	;$ak = $ak >> 8;
	movf	ak1, W
	movwf	ak
	incf	loop_j, F
	movf	loop_j, W
	xorlw	(crypto_wbytes - 1)
	btfss	STATUS, Z
	goto	DECRYPT_PACKET_cycle_key_j	
		
	;$ak += $temp_key[$wbytes - 1] + $k0;
	movlw	0xF0
	andwf	FSR1L, F
	movlw	(crypto_wbytes - 1)
	addwf	FSR1L, F
	movf	INDF1, W
	addwf	ak, F
	movf	k0, W
	addwf	ak, F
	
	;$temp_key[$wbytes - 1 + $wbytes] = $ak & 0xFF;
	movlw	crypto_wbytes
	addwf	FSR1L, F
	movf	ak, W
	movwf	INDF1
		
	;$temp_key[$wbytes] = ($temp_key[$wbytes] ^ $i) & 0xFF;
	movlw	0xF0
	andwf	FSR1L, F
	movlw	crypto_wbytes
	addwf	FSR1L, F
	movf	loop_i, W
	xorwf	INDF1, F
	
	;$k0 = $temp_key[$wbytes - 1];
	moviw	--FSR1
	movwf	k0	
	
	;for ($j = $wbytes-1; $j > 0; $j--) {
	movlw	(crypto_wbytes - 1)
	movwf	loop_j
DECRYPT_PACKET_cycle_key_j2
	
	; $temp_key[$j] = ((($temp_key[$j] << 3) | ($temp_key[$j - 1] >> 5)) ^ $temp_key[$j + $wbytes]) & 0xFF;
	movlw	0xF0
	andwf	FSR1L, F
	movf	loop_j, W
	addwf	FSR1L, F
	bcf		STATUS, C
	rlf		INDF1, F
	bcf		STATUS, C
	rlf		INDF1, F
	bcf		STATUS, C
	rlf		INDF1, F
	decf	FSR1L, F
	moviw	FSR1++
	movwf	ak
	movlw	0x05
	movwf	crypt_cnt
DECRYPT_PACKET_cycle_key_shift
	bcf	STATUS, C
	rrf	ak, F
	decfsz	crypt_cnt, F
	goto	DECRYPT_PACKET_cycle_key_shift
	movf	ak, W
	iorwf	INDF1, F
	movlw	crypto_wbytes
	addwf	FSR1L, F
	movf	INDF1, W
	movwf	ak
	movlw	crypto_wbytes
	subwf	FSR1L, F
	movf	ak, W
	xorwf	INDF1, F
	decfsz	loop_j, F
	goto	DECRYPT_PACKET_cycle_key_j2	
	
	; $temp_key[0] = ((($temp_key[0] << 3) | ($k0 >> 5)) ^ $temp_key[0 + $wbytes]) & 0xFF
	movlw	0xF0
	andwf	FSR1L, F
	bcf		STATUS, C
	rlf		INDF1, F
	bcf		STATUS, C
	rlf		INDF1, F
	bcf		STATUS, C
	rlf		INDF1, F
	movlw	0x05
	movwf	crypt_cnt
DECRYPT_PACKET_cycle_key_shift2
	bcf		STATUS, C
	rrf		k0, F
	decfsz	crypt_cnt, F
	goto	DECRYPT_PACKET_cycle_key_shift2
	movf	k0, W
	iorwf	INDF1, F	
	movlw	crypto_wbytes
	addwf	FSR1L, F
	movf	INDF1, W
	movwf	ak
	movlw	0xF0
	andwf	FSR1L, F
	movf	ak, W
	xorwf	INDF1, F	
	incf	loop_i, F
	movf	loop_i, W
	xorlw	crypto_rounds
	btfss	STATUS, Z
	goto	DECRYPT_PACKET_cycle_key_i
	

	; -------------------- start decrypt ------------------------------
	;for ($i = $rounds - 1; $i >= 0; $i--){
	movlw	(crypto_rounds - 1)
	movwf	loop_i
DECRYPT_PACKET_decrypt_i
	movlw	high(temp_crypt0)
	movwf	FSR0H
	movlw	low(temp_crypt0)
	movwf	FSR0L	

	
	;for($j = 0; $j < $wbytes; $j++){
	clrf	loop_j
DECRYPT_PACKET_decrypt_j	
	
	;$temp_key[$j] = $temp_key[$j] ^ $temp_key[$j + $wbytes];
	movlw	0xF0
	andwf	FSR1L, F
	movf	loop_j, W
	addlw	crypto_wbytes
	addwf	FSR1L, F
	movf	INDF1, W
	movwf	ak
	movlw	crypto_wbytes
	subwf	FSR1L, F			; F - W, W>F c=0, W<=F c=1 
	movf	ak, W
	xorwf	INDF1, F

	;$crypt[$j] = $crypt[$j] ^ $crypt[$j + $wbytes];
	movlw	0xF0
	andwf	FSR0L, F
	movf	loop_j, W
	addlw	crypto_wbytes
	addwf	FSR0L, F
	movf	INDF0, W
	movwf	ac
	movlw	crypto_wbytes
	subwf	FSR0L, F			; F - W, W>F c=0, W<=F c=1 
	movf	ac, W
	xorwf	INDF0, F
	incf	loop_j, F
	movf	loop_j, W
	xorlw	crypto_wbytes
	btfss	STATUS, Z
	goto	DECRYPT_PACKET_decrypt_j	
	
	;$k0 = $temp_key[0];
	movlw	0xF0
	andwf	FSR1L, F
	movf	INDF1, W
	movwf	k0
	
	;$c0 = $crypt[0];
	movlw	0xF0
	andwf	FSR0L, F
	movf	INDF0, W
	movwf	c0
	
	;for($j = 0; $j < $wbytes - 1; $j++) {
	clrf	loop_j
DECRYPT_PACKET_decrypt_j2
	
	;$temp_key[$j] = ((($temp_key[$j] >> 3) | ($temp_key[$j + 1] << 5))) & 0xFF;
	movlw	0xF0
	andwf	FSR1L, F
	movf	loop_j, W
	addwf	FSR1L, F
	bcf		STATUS, C
	rrf		INDF1, F
	bcf		STATUS, C
	rrf		INDF1, F
	bcf		STATUS, C
	rrf		INDF1, F
	incf	FSR1L, F
	moviw	FSR1--
	movwf	ak
	movlw	0x05
	movwf	crypt_cnt
DECRYPT_PACKET_decrypt_shift
	bcf		STATUS, C
	rlf		ak, F
	decfsz	crypt_cnt, F
	goto	DECRYPT_PACKET_decrypt_shift
	movf	ak, W
	iorwf	INDF1, F
	
	;$crypt[$j] = ((($crypt[$j] >> 3) | ($crypt[$j + 1] << 5))) & 0xFF;
	movlw	0xF0
	andwf	FSR0L, F
	movf	loop_j, W
	addwf	FSR0L, F
	bcf		STATUS, C
	rrf		INDF0, F
	bcf		STATUS, C
	rrf		INDF0, F
	bcf		STATUS, C
	rrf		INDF0, F
	incf	FSR0L, F
	moviw	FSR0--
	movwf	ak
	movlw	0x05
	movwf	crypt_cnt
DECRYPT_PACKET_decrypt_shift2
	bcf		STATUS, C
	rlf		ak, F
	decfsz	crypt_cnt, F
	goto	DECRYPT_PACKET_decrypt_shift2
	movf	ak, W
	iorwf	INDF0, F
	incf	loop_j, F
	movf	loop_j, W
	xorlw	(crypto_wbytes - 1)
	btfss	STATUS, Z
	goto	DECRYPT_PACKET_decrypt_j2
	
	;$temp_key[$wbytes - 1] = ((($temp_key[$wbytes - 1] >> 3) | ($k0 << 5))) & 0xFF;
	movlw	0xF0
	andwf	FSR1L, F
	movlw	crypto_wbytes
	addwf	FSR1L, F
	decf	FSR1L, F
	bcf		STATUS, C
	rrf		INDF1, F
	bcf		STATUS, C
	rrf		INDF1, F
	bcf		STATUS, C
	rrf		INDF1, F
	movlw	0x05
	movwf	crypt_cnt
DECRYPT_PACKET_decrypt_shift3
	bcf		STATUS, C
	rlf		k0, F
	decfsz	crypt_cnt, F
	goto	DECRYPT_PACKET_decrypt_shift3
	movf	k0, W
	iorwf	INDF1, F	
	
	;$crypt[$wbytes - 1] = ((($crypt[$wbytes - 1] >> 3) | ($c0 << 5))) & 0xFF;
	movlw	0xF0
	andwf	FSR0L, F
	movlw	crypto_wbytes
	addwf	FSR0L, F
	decf	FSR0L, F
	bcf		STATUS, C
	rrf		INDF0, F
	bcf		STATUS, C
	rrf		INDF0, F
	bcf		STATUS, C
	rrf		INDF0, F
	movlw	0x05
	movwf	crypt_cnt
DECRYPT_PACKET_decrypt_shift4
	bcf		STATUS, C
	rlf		c0, F
	decfsz	crypt_cnt, F
	goto	DECRYPT_PACKET_decrypt_shift4
	movf	c0, W
	iorwf	INDF0, F	
	
	;$temp_key[0 + $wbytes] = ($temp_key[0 + $wbytes] ^ $i) & 0xFF;
	movlw	0xF0
	andwf	FSR1L, F
	movlw	crypto_wbytes
	addwf	FSR1L, F
	movf	loop_i, W
	xorwf	INDF1, F
	
	;for($j = 0; $j < $wbytes; $j++) {
	clrf	loop_j
DECRYPT_PACKET_decrypt_j3
	
	;$crypt[$j + $wbytes] = ($crypt[$j + $wbytes] ^ $temp_key[$j]) & 0xFF;
	movlw	0xF0
	andwf	FSR0L, F
	movf	loop_j, W
	addlw	crypto_wbytes
	addwf	FSR0L, F
	movlw	0xF0
	andwf	FSR1L, F	
	movf	loop_j, W
	addwf	FSR1L, F
	movf	INDF1, W
	xorwf	INDF0, F
	incf	loop_j, F
	movf	loop_j, W
	xorlw	crypto_wbytes
	btfss	STATUS, Z
	goto	DECRYPT_PACKET_decrypt_j3	
	
	;$ak = 0;
	clrf	ak
	clrf	ak1
	clrf	ak2
	clrf	ak3
	;$ac = 0;
	clrf	ac
	clrf	ac1
	clrf	ac2
	clrf	ac3
	
	;for($j = 0; $j < $wbytes; $j++) {	
	clrf	loop_j
DECRYPT_PACKET_decrypt_j4	
	
	;$ak += $temp_key[$j + $wbytes] - $temp_key[$j];
	movlw	0xF0
	andwf	FSR1L, F
	movf	loop_j, W
	addlw	crypto_wbytes
	addwf	FSR1L, F
	movf	INDF1, W
	addwf	ak, F
	btfss	STATUS, C
	goto	DECRYPT_PACKET_decrypt_no_carry
	movlw	0x01
	addwf	ak1, F
	btfss	STATUS, C
	goto	DECRYPT_PACKET_decrypt_no_carry
	movlw	0x01
	addwf	ak2, F
	btfss	STATUS, C
	goto	DECRYPT_PACKET_decrypt_no_carry
	movlw	0x01
	addwf	ak3, F
DECRYPT_PACKET_decrypt_no_carry	
	movlw	crypto_wbytes
	subwf	FSR1L, F				; F - W, W>F c=0, W<=F c=1 
	movf	INDF1, W
	subwf	ak, F					; F - W, W>F c=0, W<=F c=1 
	btfsc	STATUS, C
	goto	DECRYPT_PACKET_decrypt_no_carry2	
	movlw	0x01
	subwf	ak1, F
	btfsc	STATUS, C
	goto	DECRYPT_PACKET_decrypt_no_carry2
	movlw	0x01
	subwf	ak2, F
	btfsc	STATUS, C
	goto	DECRYPT_PACKET_decrypt_no_carry2
	movlw	0x01
	subwf	ak3, F
DECRYPT_PACKET_decrypt_no_carry2
	
	;$temp_key[$j + $wbytes] = $ak & 0xFF;
	movlw	crypto_wbytes
	addwf	FSR1L, F
	movf	ak, W
	movwf	INDF1
	
	;$ak = $ak >> 8;
	movf	ak1, W
	movwf	ak	
	movf	ak2, W
	movwf	ak1	
	movf	ak3, W
	movwf	ak2	
	
	;$ac += $crypt[$j + $wbytes] - $crypt[$j];
	movlw	0xF0
	andwf	FSR0L, F
	movf	loop_j, W
	addlw	crypto_wbytes
	addwf	FSR0L, F
	movf	INDF0, W
	addwf	ac, F
	btfss	STATUS, C
	goto	DECRYPT_PACKET_decrypt_no_carry3
	movlw	0x01
	addwf	ac1, F
	btfss	STATUS, C
	goto	DECRYPT_PACKET_decrypt_no_carry3
	movlw	0x01
	addwf	ac2, F
	btfss	STATUS, C
	goto	DECRYPT_PACKET_decrypt_no_carry3
	movlw	0x01
	addwf	ac3, F
DECRYPT_PACKET_decrypt_no_carry3
	movlw	crypto_wbytes
	subwf	FSR0L, F				; F - W, W>F c=0, W<=F c=1 
	movf	INDF0, W
	subwf	ac, F					; F - W, W>F c=0, W<=F c=1 
	btfsc	STATUS, C
	goto	DECRYPT_PACKET_decrypt_no_carry4
	movlw	0x01
	subwf	ac1, F
	btfsc	STATUS, C
	goto	DECRYPT_PACKET_decrypt_no_carry4
	movlw	0x01
	subwf	ac2, F
	btfsc	STATUS, C
	goto	DECRYPT_PACKET_decrypt_no_carry4
	movlw	0x01
	subwf	ac3, F
DECRYPT_PACKET_decrypt_no_carry4
	
	;$crypt[$j + $wbytes] = $ac & 0xFF;
	movlw	crypto_wbytes
	addwf	FSR0L, F
	movf	ac, W
	movwf	INDF0	
	
	;$ac = $ac >> 8;
	movf	ac1, W
	movwf	ac	
	movf	ac2, W
	movwf	ac1	
	movf	ac3, W
	movwf	ac2	
	incf	loop_j, F
	movf	loop_j, W
	xorlw	crypto_wbytes
	btfss	STATUS, Z
	goto	DECRYPT_PACKET_decrypt_j4		
	
	;$k0 = $temp_key[$wbytes - 1 + $wbytes];
	movlw	0xF0
	andwf	FSR1L, F
	movlw	crypto_wbytes
	addwf	FSR1L, F
	addwf	FSR1L, F
	decf	FSR1L, F
	movf	INDF1, W
	movwf	k0
	
	;$c0 = $crypt[$wbytes - 1 + $wbytes];	
	movlw	0xF0
	andwf	FSR0L, F
	movlw	crypto_wbytes
	addwf	FSR0L, F
	addwf	FSR0L, F
	decf	FSR0L, F
	movf	INDF0, W
	movwf	c0	
	
	;for($j = $wbytes - 1; $j > 0; $j--) {
	movlw	(crypto_wbytes - 1)
	movwf	loop_j
DECRYPT_PACKET_decrypt_j5
	
	;$temp_key[$j + $wbytes] = $temp_key[$j - 1 + $wbytes];
	movlw	0xF0
	andwf	FSR1L, F
	movf	loop_j, W
	addlw	crypto_wbytes
	addwf	FSR1L, F
	decf	FSR1L, F
	moviw	FSR1++
	movwf	INDF1
	
	;$crypt[$j + $wbytes] = $crypt[$j - 1 + $wbytes];
	movlw	0xF0
	andwf	FSR0L, F
	movf	loop_j, W
	addlw	crypto_wbytes
	addwf	FSR0L, F
	decf	FSR0L, F
	moviw	FSR0++
	movwf	INDF0
	decfsz	loop_j, F
	goto	DECRYPT_PACKET_decrypt_j5	
	
	;$temp_key[0 + $wbytes] = $k0;
	movlw	0xF0
	andwf	FSR1L, F
	movlw	crypto_wbytes
	addwf	FSR1L, F
	movf	k0, W
	movwf	INDF1
	
	;$crypt[0 + $wbytes] = $c0;
	movlw	0xF0
	andwf	FSR0L, F
	movlw	crypto_wbytes
	addwf	FSR0L, F
	movf	c0, W
	movwf	INDF0
	decf	loop_i, F
	movf	loop_i, W
	xorlw	0xFF
	btfss	STATUS, Z	
	goto	DECRYPT_PACKET_decrypt_i
	
	; -------------------- validate data ------------------------------	
	;------------------
	movlb	d'14'
	;------------------	
	btfsc	PIE3, TX1IE				; make sure TX routine is NOT already running. 
	goto	RETURN_TO_IRQ_RX1_not_type3
	;------------------
	movlb	d'2'
	;------------------	
	movlw	0xF0
	andwf	FSR0L, F
	; check badge ID
	moviw	FSR0++
	xorwf	badge_idH, W
	btfss	STATUS, Z
	goto	RETURN_TO_IRQ_RX1_not_type3
	moviw	FSR0++
	xorwf	badge_idL, W
	btfss	STATUS, Z
	goto	RETURN_TO_IRQ_RX1_not_type3
	; once value
	moviw	FSR0++
	xorwf	onceH, W
	btfss	STATUS, Z
	goto	RETURN_TO_IRQ_RX1_not_type3
	moviw	FSR0++
	xorwf	onceL, W
	btfss	STATUS, Z
	goto	RETURN_TO_IRQ_RX1_not_type3
	; checksum
	movlw	0xF0
	andwf	FSR0L, F
	movlw	0x0A
	movwf	loop_i
	clrf	ac
DECRYPT_PACKET_validate_chksum
	moviw	FSR0++
	addwf	ac, F
	decfsz	loop_i, F
	goto	DECRYPT_PACKET_validate_chksum
	movf	ac, W
	btfss	STATUS, Z
	goto	RETURN_TO_IRQ_RX1_not_type3
	; compute available credits
	;------------------
	movlb	d'0'
	;------------------	
	movf	countL, W
	;------------------
	movlb	d'2'
	;------------------	
	movwf	ac
	;------------------
	movlb	d'0'
	;------------------	
	movf	countH, W
	;------------------
	movlb	d'2'
	;------------------	
	movwf	ac1
	movlw	high(ram_spent)
	movwf	FSR1H
	movlw	low(ram_spent)
	movwf	FSR1L	
	comf	INDF1, W
	movwf	ac3
	incf	FSR1L, F
	comf	INDF1, W
	movwf	ac2	
	; subtract spent from total credits
	movf	ac2, W
	subwf	ac, F		; f - w, W > F (neg) c = 0, W <= F (pos) C = 1
	movf	ac3, W
	subwfb	ac1, F		; f - w, W > F (neg) c = 0, W <= F (pos) C = 1
	btfss	STATUS, C
	goto	RETURN_TO_IRQ_RX1_not_type3
	movlw	0xF0
	andwf	FSR0L, F
	movlw	0x04
	addwf	FSR0L, F
	; subtract requested from total above 
	moviw	++FSR0
	subwf	ac, F		; f - w, W > F (neg) c = 0, W <= F (pos) C = 1
	moviw	--FSR0
	subwfb	ac1, F		; f - w, W > F (neg) c = 0, W <= F (pos) C = 1
	btfss	STATUS, C	; if negitive there was not enough funds so abort
	goto	RETURN_TO_IRQ_RX1_not_type3
	; if sufficent credits update spent with new value
	moviw	++FSR0
	addwf	ac2, F
	moviw	--FSR0
	addwfc	ac3, F
	comf	ac2, W
	movwi	FSR1--
	comf	ac3, W
	movwi	FSR1++
	; indicate that this needs to be saved on next mainloop. 
	bsf		g_flags, 0	
	; invalidate the badge once
	clrf	onceH
	comf	onceL, F
	; build up new packet
	movlw	0xF0
	andwf	FSR0L, F
	movlw	0x02
	addwf	FSR0L, F
	moviw	FSR0++
	movwf	ak				; badge onceH
	moviw	FSR0++
	movwf	ak1				; badge onceL
	moviw	FSR0++
	movwf	ak2				; creditsH
	moviw	FSR0++
	movwf	ak3				; creditsL
	moviw	FSR0++
	movwf	ac				; vendo onceH
	moviw	FSR0++
	movwf	ac1				; vendo onceM
	moviw	FSR0++
	movwf	ac2				; vendo onceL
	movlw	0xF0
	andwf	FSR0L, F
	movlw	0x02
	addwf	FSR0L, F
	movf	ac, W			; vendo onceH
	movwi	FSR0++
	movf	ac1, W			; vendo onceM
	movwi	FSR0++
	movf	ac2, W			; vendo onceL
	movwi	FSR0++
	movf	ak2, W
	movwi	FSR0++
	movf	ak3, W
	movwi	FSR0++
	;------------------
	movlb	d'0'
	;------------------			
	call	_3_CYCLE_LFSR
	;------------------
	movlb	d'2'
	;------------------		
	movwf	ac3
	xorwf	ak, W
	btfsc	STATUS, Z
	incf	ac3, F
	movf	ac3, W
	movwi	FSR0++
	;------------------
	movlb	d'0'
	;------------------			
	call	_3_CYCLE_LFSR
	;------------------
	movlb	d'2'
	;------------------		
	movwf	ac3
	xorwf	ak1, W
	btfsc	STATUS, Z
	incf	ac3, F
	movf	ac3, W
	movwi	FSR0++
	; generate checksum
	clrf	ir_tx_chksum
	movlw	0xF0
	andwf	FSR0L, F
	movlw	0x09
	movwf	loop_i
DECRYPT_PACKET_gen_chksum
	moviw	FSR0++
	addwf	ir_tx_chksum, F
	decfsz	loop_i, F
	goto	DECRYPT_PACKET_gen_chksum
	comf	ir_tx_chksum, F
	incf	ir_tx_chksum, W	
	movwf	INDF0	
	
	; -------------------- start encrypt ------------------------------	
ENCRYPT_PACKET	
	

; don't need to move the key over if decryption is done. Process leave key in original form ready for use to encrypt... 	
;	; copy decrypt key to ram
;	movlw	high(start_key)
;	movwf	FSR0H
;	movlw	low(start_key)
;	movwf	FSR0L
;	movlw	high(temp_key0)
;	movwf	FSR1H
;	movlw	low(temp_key0)
;	movwf	FSR1L
;	movlw	0x0A
;	movwf	loop_i
;ENCRYPT_PACKET_key_move_loop
;	moviw	FSR0++
;	movwi	FSR1++
;	decfsz	loop_i, F
;	goto	ENCRYPT_PACKET_key_move_loop	
	
	movlw	high(temp_crypt0)
	movwf	FSR0H
	movlw	low(temp_crypt0)
	movwf	FSR0L	
	movlw	high(temp_key0)
	movwf	FSR1H
	movlw	low(temp_key0)
	movwf	FSR1L	
	
	
	;for ($i = 0; $i < $rounds; $i++){
	clrf	loop_i
ENCRYPT_PACKET_i
	
	;$c0 = $crypt[0 + $wbytes];
	movlw	0xF0
	andwf	FSR0L, F
	movlw	crypto_wbytes
	addwf	FSR0L, F
	movf	INDF0, W
	movwf	c0
	
	;$k0 = $temp_key[0 + $wbytes];
	movlw	0xF0
	andwf	FSR1L, F
	movlw	crypto_wbytes
	addwf	FSR1L, F
	movf	INDF1, W
	movwf	k0
	
	;$ac = 0;
	clrf	ac
	clrf	ac1
	
	;$ak = 0;
	clrf	ak
	clrf	ak1
	
	;for ($j = 0; $j < $wbytes-1; $j++) {
	clrf	loop_j
ENCRYPT_PACKET_j

	;$ac += $crypt[$j] + $crypt[($j + 1) + $wbytes]; 
	movlw	0xF0
	andwf	FSR0L, F
	movf	loop_j, W
	addwf	FSR0L, F
	moviw	FSR0++
	addwf	ac, F
	btfsc	STATUS, C
	incf	ac1, F
	movlw	crypto_wbytes
	addwf	FSR0L, F
	moviw	FSR0--
	addwf	ac, F
	btfsc	STATUS, C
	incf	ac1, F
	
	;$crypt[$j + $wbytes] = ($ac & 0xFF) ^ $temp_key[$j]; 
	movf	ac, W
	movwf	INDF0
	movlw	0xF0
	andwf	FSR1L, F
	movf	loop_j, W
	addwf	FSR1L, F
	movf	INDF1, W
	xorwf	INDF0, F
	
	;$ac = $ac >> 8;
	movf	ac1, W
	movwf	ac
	clrf	ac1
	
	;$ak += $temp_key[$j] + $temp_key[($j + 1) + $wbytes]; 
	movlw	0xF0
	andwf	FSR1L, F
	movf	loop_j, W
	addwf	FSR1L, F
	moviw	FSR1++
	addwf	ak, F
	btfsc	STATUS, C
	incf	ak1, F
	movlw	crypto_wbytes
	addwf	FSR1L, F
	moviw	FSR1--
	addwf	ak, F
	btfsc	STATUS, C
	incf	ak1, F

	;$temp_key[$j + $wbytes] = ($ak & 0xFF);         
	movf	ak, W
	movwf	INDF1

	;$ak = $ak >> 8;	
	movf	ak1, W
	movwf	ak	
	clrf	ak1
		
	incf	loop_j, F
	movf	loop_j, W
	xorlw	(crypto_wbytes - 1)
	btfss	STATUS, Z
	goto	ENCRYPT_PACKET_j			

	;$ac += $crypt[$wbytes-1] + $c0; 
	movlw	0xF0
	andwf	FSR0L, F
	movlw	crypto_wbytes
	addwf	FSR0L, F
	decf	FSR0L, F
	movf	INDF0, W
	addwf	ac, F
	movf	c0, W
	addwf	ac, F
	
	;$crypt[($wbytes-1) + $wbytes] = ($ac & 0xFF) ^ $temp_key[$wbytes-1];
	movlw	crypto_wbytes
	addwf	FSR0L, F
	movf	ac, W
	movwf	INDF0
	movlw	0xF0
	andwf	FSR1L, F
	movlw	crypto_wbytes
	addwf	FSR1L, F
	decf	FSR1L, F
	movf	INDF1, W
	xorwf	INDF0, F	
	
	;$ak += $temp_key[$wbytes-1] + $k0; 
	movf	INDF1, W
	addwf	ak, F
	movf	k0, W
	addwf	ak, F
	
	;$temp_key[($wbytes-1) + $wbytes] = ($ak & 0xFF);
	movlw	crypto_wbytes
	addwf	FSR1L, F
	movf	ak, W
	movwf	INDF1
	
	;$temp_key[$wbytes] = $temp_key[$wbytes] ^ ($i & 0xFF);
	movlw	0xF0
	andwf	FSR1L, F
	movlw	crypto_wbytes
	addwf	FSR1L, F
	movf	loop_i, W
	xorwf	INDF1, F
	
	
	;$c0 = $crypt[$wbytes-1];
	movlw	0xF0
	andwf	FSR0L, F
	movlw	crypto_wbytes
	addwf	FSR0L, F
	decf	FSR0L, F	
	movf	INDF0, W
	movwf	c0
	
	;$k0 = $temp_key[$wbytes-1];
	decf	FSR1L, F
	movf	INDF1, W
	movwf	k0
	
	;for ($j = $wbytes-1; $j > 0; $j--){
	movlw	(crypto_wbytes - 1)
	movwf	loop_j
ENCRYPT_PACKET_j2
	
	;$crypt[$j] = (($crypt[$j] << 3 | ($crypt[$j - 1] >> 5)) ^ $crypt[$j + $wbytes]) & 0xFF;
	movlw	0xF0
	andwf	FSR0L, F
	movf	loop_j, W
	addwf	FSR0L, F
	bcf		STATUS, C
	rlf		INDF0, F
	bcf		STATUS, C
	rlf		INDF0, F
	bcf		STATUS, C
	rlf		INDF0, F
	moviw	--FSR0
	movwf	ac
	movlw	0x05
	movwf	crypt_cnt
ENCRYPT_PACKET_shift
	bcf		STATUS, C
	rrf		ac, F
	decfsz	crypt_cnt, F
	goto	ENCRYPT_PACKET_shift
	incf	FSR0L, F
	movf	ac, W
	iorwf	INDF0, F	
	movlw	crypto_wbytes
	addwf	FSR0L, F
	movf	INDF0, W
	movwf	ac
	movlw	crypto_wbytes
	subwf	FSR0L, F
	movf	ac, W
	xorwf	INDF0, F		
	
	;$temp_key[$j] = ((($temp_key[$j] << 3) | ($temp_key[($j - 1)] >> 5)) ^ $temp_key[$j + $wbytes]) & 0xFF;	
	movlw	0xF0
	andwf	FSR1L, F
	movf	loop_j, W
	addwf	FSR1L, F
	bcf		STATUS, C
	rlf		INDF1, F
	bcf		STATUS, C
	rlf		INDF1, F
	bcf		STATUS, C
	rlf		INDF1, F
	moviw	--FSR1
	movwf	ak
	movlw	0x05
	movwf	crypt_cnt
ENCRYPT_PACKET_shift2
	bcf		STATUS, C
	rrf		ak, F
	decfsz	crypt_cnt, F
	goto	ENCRYPT_PACKET_shift2
	incf	FSR1L, F
	movf	ak, W
	iorwf	INDF1, F	
	movlw	crypto_wbytes
	addwf	FSR1L, F
	movf	INDF1, W
	movwf	ak
	movlw	crypto_wbytes
	subwf	FSR1L, F
	movf	ak, W
	xorwf	INDF1, F		
	decfsz	loop_j, F
	goto	ENCRYPT_PACKET_j2	
	
	
	;$crypt[0] = ((($crypt[0] << 3) | ($c0 >> 5)) ^ $crypt[0 + $wbytes]) & 0xFF;
	movlw	0xF0
	andwf	FSR0L, F
	bcf		STATUS, C
	rlf		INDF0, F
	bcf		STATUS, C
	rlf		INDF0, F
	bcf		STATUS, C
	rlf		INDF0, F
	movlw	0x05
	movwf	crypt_cnt
ENCRYPT_PACKET_shift3
	bcf		STATUS, C
	rrf		c0, F
	decfsz	crypt_cnt, F
	goto	ENCRYPT_PACKET_shift3
	movf	c0, W
	iorwf	INDF0, F	
	movlw	crypto_wbytes
	addwf	FSR0L, F
	movf	INDF0, W
	movwf	ac
	movlw	crypto_wbytes
	subwf	FSR0L, F
	movf	ac, W
	xorwf	INDF0, F	
	
	;$temp_key[0] = ((($temp_key[0] << 3) | ($k0 >> 5)) ^ $temp_key[0 + $wbytes]) & 0xFF;
	movlw	0xF0
	andwf	FSR1L, F
	bcf		STATUS, C
	rlf		INDF1, F
	bcf		STATUS, C
	rlf		INDF1, F
	bcf		STATUS, C
	rlf		INDF1, F
	movlw	0x05
	movwf	crypt_cnt
ENCRYPT_PACKET_shift4
	bcf		STATUS, C
	rrf		k0, F
	decfsz	crypt_cnt, F
	goto	ENCRYPT_PACKET_shift4
	movf	k0, W
	iorwf	INDF1, F	
	movlw	crypto_wbytes
	addwf	FSR1L, F
	movf	INDF1, W
	movwf	ak
	movlw	crypto_wbytes
	subwf	FSR1L, F
	movf	ak, W
	xorwf	INDF1, F	
	incf	loop_i, F
	movf	loop_i, W
	xorlw	crypto_rounds
	btfss	STATUS, Z
	goto	ENCRYPT_PACKET_i	
	
	; set up packet send
	clrf	ir_tx_seq
	clrf	ir_tx_chksum
	; status updated other places just flow it here
	movlw	0x04
	movwf	tx_type		
	bsf		g_flags, 3				; bit 0 = update flash, bit 1 = force stomach off, bit 2 = force poo off, bit 3 = enable TX delay
	;------------------
	movlb	d'14'
	;------------------	
	bsf	PIE3, TX1IE				; enable Uart2 transmit IRQ					
RETURN_TO_IRQ_RX1_not_type3	
	;------------------
	movlb	d'2'
	;------------------		
	movlp	0x00
	goto	IRQ_RX1_not_type3
	
	

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; FLASH goto / call break here need to update the counter manually to jump back and forth from here.... 
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
;put the following at address 1000h
	org     1800h		

;################################################################################
; cycle the LFSR (sudo random) generator and return the new lower 8 result in W
;################################################################################
_4_CYCLE_LFSR
	movlp	0x08
	call	_2_CYCLE_LFSR
	movlp	0x18
	return	
	
;#########################################################
; This configures the MSSP to I2C
;#########################################################
_4_CFG_I2C
	movlp	0x00
	call	_CFG_I2C
	movlp	0x18
	return
	
;#########################################################
; This configures the MSSP to SPI
;#########################################################
_4_CFG_SPI
	movf	BSR, W
	movwf	current_bsr
	;------------------
	movlb	d'61'
	;------------------
	; input PPS signals
	movlw	0x10					; RC0
	movwf	SSP1DATPPS	
	
	;------------------
	movlb	d'62'
	;------------------	
	; output PPS signals
	movlw	0x15				; SCK1/SCL1
	movwf	RC2PPS
	movlw	0x16				; SDO1/SDA1
	movwf	RC1PPS
	
	
	;movlw	0x01				; enable weak pull up on portC 0
	;movwf	WPUC	
	
	
	
	;------------------
	movlb	d'3'
	;------------------
	; disable MSSP engine 
	clrf	SSP1CON1		    ; reset MSSP
	clrf	SSP1CON2
	clrf	SSP1CON3
	clrf	SSP1STAT
	movlw	0xFF
	movwf	SSP1MSK
	;movlw	0x80			    ; SMP = 1, CKE = 0
	movlw	0xC0			    ; SMP = 1, CKE = 1
	movwf	SSP1STAT	
	movlw	0x07			    ; 0x07 with a 32MHz FOSC = 1MHz
	movwf	SSP1ADD			    ; clock = FOSC/((ADD<7:0> + 1) *4)
	movlw	0x2A			    ; port enabled, CKP = 1, S{O master mode user baud calc   
	movwf	SSP1CON1	
	
	movf	current_bsr, W
	movwf	BSR
	return
	
;#########################################################
; send the value in the W register out the SPI bus and return the value we get back in W
;#########################################################
_4_SEND_RCV_W_SPI
	movwf	g_temp
	movf	BSR, W
	movwf	current_bsr
	;------------------
	movlb	d'14'
	;------------------	
	bcf	PIR3, SSP1IF		    ; clear interrupt flag
	bcf	PIR3, BCL1IF		    ; clear interrupt flag (i2c col)
	;------------------
	movlb	d'3'
	;------------------
	movf	g_temp, W
	movwf	SSP1BUF 
	;------------------
	movlb	d'14'
	;------------------	
__WAIT_SPI_BYTE_DONE	
	btfss	PIR3, SSP1IF
	goto	__WAIT_SPI_BYTE_DONE
	bcf	PIR3, SSP1IF		    ; clear interrupt flag
	;------------------
	movlb	d'3'
	;------------------
	movf	SSP1BUF, W			; read byte 
	movwf	g_temp
	
	movf	current_bsr, W
	movwf	BSR
	
	movf	g_temp, W
	return		
	

	
;#########################################################
; Address the oLED display
; page in i2c_off and colum number in W
;#########################################################
_4_ADDRESS_oLED
	movwf	i2c_dat0
	; Address the starting block of pixles to update
	bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0x20				; set memory addressing mode
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	;movlw	0x00				; horisontal addressing mode
	;movlw	0x01				; vertical addressing mode
	movlw	0x02				; page addressing mode
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin	
	;bcf		LATC, 4				; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movf	i2c_off, W
	andlw	0x07
	iorlw	0xB0				; select memory addressing page (0xB0 to 0xB7 valid. B0 is stripe with lowest corner, B4 is stripe with upper corner of the screen, B5-7 not used)
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	;bcf		LATC, 4				; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movf	i2c_dat0, W
	andlw	0x0F					; select memory addressing column low nibble
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	;bcf		LATC, 4				; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	swapf	i2c_dat0, W
	andlw	0x0F
	iorlw	0x10				; select memory addressing column high nibble
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	
	return
	
	
;---------------------------------------------------------------------------------------	
	
oLED_INIT	
	call	_4_CFG_SPI
	
	; init the oLED display.... 
	; may need to drive reset hight then low then high again.... 
	bsf		LATC, 3				; #oLED_Reset
	movlw	0x01
	movwf	delay_cnt
oLED_INIT_DELAY
	movf	delay_cnt, W
	btfss	STATUS, Z
	goto	oLED_INIT_DELAY
	
	bcf		LATC, 4				; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0xAE				; set display off
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin

	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0x40				; set display start line:COM0
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	
	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0x81				; set contrast control
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x2F				;
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin	
	
	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0xA0				; set segment re-map
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	
	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0xA4				; entire display on
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	
	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0xA6				; set inverse off
	;movlw	0xA7				; set inverse on
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	
	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0xA8				; set multiplex ratio
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x27				; 1/40 duty ratio
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	
	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0xC0				; set com output scan direction
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	
	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0xD3				; set display offset
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x00				;
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin

	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0xD5				; set display clock divide ratio
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x80				; 105Hz
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	
	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0xD9				; set pre-charge period
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x22				; 
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	
	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0xDA				; set com pins hardware configuration
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x12				; 
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin

	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0xAD				; set internal IREF
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x30				; 
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	
	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0xDB				; set vcomh deselect level
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x20				; 0.77*VCC
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	
	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0x8D				; set pre-charge period
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x14				; enable charge pump, VCC=7.5V
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin

	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0xAF				; set display on
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin
	
	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0x20				; set memory addressing mode
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x00				; horisontal addressing mode
	;movlw	0x01				; vertical addressing mode
	;movlw	0x02				; page addressing mode
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin

	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0x22				; set page range
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x00				; start
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x07				; end
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin

	
	;bcf		LATC, 4			; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0x21				; set column range
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x00				; start
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	movlw	0x7F				; end
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	bsf		LATC, 6				; oLED CS pin

	; clear the ram
	bsf		LATC, 4				; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	0x04
	movwf	temp1
	clrf	temp
test_loop	
	movlw	0x00				; display data
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	decfsz	temp, F
	goto	test_loop	
	decfsz	temp1, F
	goto	test_loop		
	bsf		LATC, 6				; oLED CS pin	

	
	; Address the starting block of pixles to update
	movlw	0x00		    ; select memory addressing page (0xB0 to 0xB7 valid. B0 is stripe with lowest corner, B4 is stripe with upper corner of the screen, B5-7 not used)
	movwf	i2c_off
	movlw	0x1C		    ; starting column
	call	_4_ADDRESS_oLED
	
	; set on one block of pixles
	bsf		LATC, 4				; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	; first edge
	movlw	0xFF			;
	call	_4_SEND_RCV_W_SPI
	; top row
	movlw	d'70'
	movwf	temp
test_loop1	
	movlw	0x01			;
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	decfsz	temp, F
	goto	test_loop1	
	; first edge
	movlw	0xFF	
	call	_4_SEND_RCV_W_SPI
	bsf		LATC, 6				; oLED CS pin
	
	
	; Address the starting block of pixles to update
	movlw	0x01		    ; select memory addressing page (0xB0 to 0xB7 valid. B0 is stripe with lowest corner, B4 is stripe with upper corner of the screen, B5-7 not used)
	movwf	i2c_off
	movlw	0x1C		    ; starting column
	call	_4_ADDRESS_oLED
	
	; set on one block of pixles
	bsf		LATC, 4				; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	; first edge
	movlw	0xFF			;
	call	_4_SEND_RCV_W_SPI
	; middle
	movlw	d'27'
	movwf	temp
test_loop2	
	movlw	0x00			;
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	decfsz	temp, F
	goto	test_loop2
	
	movlw	0x90			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x90			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x18			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0xE8			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x08			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x10			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x10			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x20			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0xC0			;
	call	_4_SEND_RCV_W_SPI		
	
	movlw	d'34'
	movwf	temp
test_loop2a	
	movlw	0x00			;
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	decfsz	temp, F
	goto	test_loop2a	
	
	; first edge
	movlw	0xFF	
	call	_4_SEND_RCV_W_SPI
	bsf		LATC, 6				; oLED CS pin
	
	
	; Address the starting block of pixles to update
	movlw	0x02		    ; select memory addressing page (0xB0 to 0xB7 valid. B0 is stripe with lowest corner, B4 is stripe with upper corner of the screen, B5-7 not used)
	movwf	i2c_off
	movlw	0x1C		    ; starting column
	call	_4_ADDRESS_oLED
	
	; set on one block of pixles
	bsf		LATC, 4				; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	; first edge
	movlw	0xFF			;
	call	_4_SEND_RCV_W_SPI
	; middle
	movlw	d'21'
	movwf	temp
test_loop3	
	movlw	0x00			;
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	decfsz	temp, F
	goto	test_loop3	
	
	movlw	0x38			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0xcE			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x10			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x10			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x16			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x08			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x08			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x64			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x63			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x00			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x00			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x66			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x66			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x00			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x00			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0xc3			;
	call	_4_SEND_RCV_W_SPI	
	movlw	0x3c			;
	call	_4_SEND_RCV_W_SPI	
	
	
	
	movlw	d'32'  ;23
	movwf	temp
test_loop3a	
	movlw	0x00			;
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	decfsz	temp, F
	goto	test_loop3a	
	; first edge
	movlw	0xFF	
	call	_4_SEND_RCV_W_SPI
	bsf		LATC, 6				; oLED CS pin
	
	
	; Address the starting block of pixles to update
	movlw	0x03		    ; select memory addressing page (0xB0 to 0xB7 valid. B0 is stripe with lowest corner, B4 is stripe with upper corner of the screen, B5-7 not used)
	movwf	i2c_off
	movlw	0x1C		    ; starting column
	call	_4_ADDRESS_oLED
	
	; set on one block of pixles
	bsf		LATC, 4				; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	; first edge
	movlw	0xFF			;
	call	_4_SEND_RCV_W_SPI
	; middle
	movlw	d'23'
	movwf	temp
test_loop4	
	movlw	0x00			;
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	decfsz	temp, F
	goto	test_loop4
	
	movlw	0x01			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x02			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x02			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x04			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x04			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x08			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x08			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x08			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x08			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x04			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x04			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x02			;
	call	_4_SEND_RCV_W_SPI		
	movlw	0x01			;
	call	_4_SEND_RCV_W_SPI		
	
	movlw	d'34'
	movwf	temp
test_loop4a	
	movlw	0x00			;
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	decfsz	temp, F
	goto	test_loop4a	
	; first edge
	movlw	0xFF	
	call	_4_SEND_RCV_W_SPI
	bsf		LATC, 6				; oLED CS pin
	
	
	; Address the starting block of pixles to update
	movlw	0x04		    ; select memory addressing page (0xB0 to 0xB7 valid. B0 is stripe with lowest corner, B4 is stripe with upper corner of the screen, B5-7 not used)
	movwf	i2c_off
	movlw	0x1C		    ; starting column
	call	_4_ADDRESS_oLED
	
	; set on one block of pixles
	bsf		LATC, 4				; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	; first edge
	movlw	0xFF			;
	call	_4_SEND_RCV_W_SPI
	; top row
	movlw	d'70'
	movwf	temp
test_loop5	
	movlw	0x80			;
	call	_4_SEND_RCV_W_SPI	
	; discard this byte	
	decfsz	temp, F
	goto	test_loop5	
	; first edge
	movlw	0xFF	
	call	_4_SEND_RCV_W_SPI
	bsf		LATC, 6				; oLED CS pin	
	
	movlp	0x00
	goto	oLED_INIT_return

;---------------------------------------------------------------------------------------	
	
oLED_EEPROM_INIT	
	call	_4_CFG_SPI	
	
#ifdef	SKIP_EEPROM_TEST	
	goto	oLED_SKIP_EEPROM_CHK	
#endif	
	
	bcf		LATC, 5				; SPI EEPROM CS pin
	movlw	0xAB				; Release from deep power down. Should return dummy, dummy, dummy, 0x15
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movlw	0xFF
	call	_4_SEND_RCV_W_SPI	
	movlw	0xFF
	call	_4_SEND_RCV_W_SPI	
	movlw	0xFF
	call	_4_SEND_RCV_W_SPI	
	movlw	0xFF
	call	_4_SEND_RCV_W_SPI	
	xorlw	0x15
	btfss	STATUS, Z
	goto	oLED_SELFTEST_chk_fail
	bsf		LATC, 5				; SPI EEPROM CS pin
	

	bcf		LATC, 5				; SPI EEPROM CS pin
	movlw	0x9F				; JEDEC ID, Should return 0x01, 0x40, 0x16
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movlw	0xFF
	call	_4_SEND_RCV_W_SPI	
	xorlw	0x01
	btfss	STATUS, Z
	goto	oLED_SELFTEST_chk_fail	
	movlw	0xFF
	call	_4_SEND_RCV_W_SPI	
	xorlw	0x40
	btfss	STATUS, Z
	goto	oLED_SELFTEST_chk_fail
	movlw	0xFF
	call	_4_SEND_RCV_W_SPI	
	xorlw	0x16
	btfss	STATUS, Z
	goto	oLED_SELFTEST_chk_fail
	bsf		LATC, 5				; SPI EEPROM CS pin
	
		
;	bcf		LATC, 5				; SPI EEPROM CS pin
;	movlw	0x06				; Write Enable
;	call	_4_SEND_RCV_W_SPI	
;	; discard this byte
;	bsf		LATC, 5				; SPI EEPROM CS pin

	
;	bcf		LATC, 5				; SPI EEPROM CS pin
;	movlw	0x02				; write page (256 bytes max) at 24 bit address command
;	call	_4_SEND_RCV_W_SPI	
;	; discard this byte
;	movlw	0x00
;	call	_4_SEND_RCV_W_SPI	
;	; discard this byte
;	movlw	0x00
;	call	_4_SEND_RCV_W_SPI	
;	; discard this byte
;	movlw	0x00
;	call	_4_SEND_RCV_W_SPI	
;	; discard this byte
;	
;	movlw	0xFE
;	call	_4_SEND_RCV_W_SPI	
;	; discard this byte
;	movlw	0xED
;	call	_4_SEND_RCV_W_SPI	
;	; discard this byte
;	movlw	0xB0
;	call	_4_SEND_RCV_W_SPI	
;	; discard this byte
;	movlw	0xB0
;	call	_4_SEND_RCV_W_SPI	
;	; discard this byte
;	bsf		LATC, 5				; SPI EEPROM CS pin
	
	
	bcf		LATC, 5				; SPI EEPROM CS pin
	movlw	0x03				; Read at 24 bit address command
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movlw	0x00
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movlw	0x00
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movlw	0x00
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movlw	0xFF
	call	_4_SEND_RCV_W_SPI	
	xorlw	0xFE
	btfss	STATUS, Z
	goto	oLED_SELFTEST_chk_fail	
	movlw	0xFF
	call	_4_SEND_RCV_W_SPI	
	xorlw	0xED
	btfss	STATUS, Z
	goto	oLED_SELFTEST_chk_fail	
	movlw	0xFF
	call	_4_SEND_RCV_W_SPI	
	xorlw	0xB0
	btfss	STATUS, Z
	goto	oLED_SELFTEST_chk_fail	
	movlw	0xFF
	call	_4_SEND_RCV_W_SPI	
	xorlw	0xB0
	btfss	STATUS, Z
	goto	oLED_SELFTEST_chk_fail	
	bsf		LATC, 5				; SPI EEPROM CS pin
	
oLED_SKIP_EEPROM_CHK
	
	
	movlp	0x00
	goto	oLED_EEPROM_INIT_return
	
oLED_SELFTEST_chk_fail	
	movlp	0x00
	goto	CHECK_SPI_FAIL_INIT
	
	
	
	;-----------------------------------------------------------------------------------------------------------
	
MAINLOOP3	
	;------------------
	movlb	d'0'
	;------------------	

	; if needed to force the next animation now do
	;clrf	oLED_delay			; stop the counter update first then clear the internal phase
	;clrf	oLED_phase
	;movlw	0x00
	;movwf	oLED_set			; new set to move to 
	;clrf	oLED_seq_cnt

	
	; check if the oLED delay is running 
	movf	oLED_delay, W
	btfss	STATUS, Z
	goto	MAINLOOP3_oLED_done

	; set the MSSP engine back up for I2C 
	call	_4_CFG_SPI	
	
	; check if this seq is done or not
	movf	oLED_seq_cnt, W
	btfss	STATUS, Z
	goto	MAINLOOP3_oLED_get_next
	
	; check if this is a one shot start
	btfss	oLED_ctrl, 0			; bit 0 = one shot start, 1 = one shot done
	goto	MAINLOOP3_not_oneshot_start
	bcf		oLED_ctrl, 0			; bit 0 = one shot start, 1 = one shot done
	bsf		oLED_ctrl, 1			; bit 0 = one shot start, 1 = one shot done
	goto	MAINLOOP3_oneshot_done
MAINLOOP3_not_oneshot_start
	btfss	oLED_ctrl, 1			; bit 0 = one shot start, 1 = one shot done
	goto	MAINLOOP3_oneshot_done
	bcf		oLED_ctrl, 1			; bit 0 = one shot start, 1 = one shot done
	movf	oLED_last, W
	movwf	oLED_set				; restore saved value (back to normal display
MAINLOOP3_oneshot_done
	
		
	; verify set number is vaild if not set to 0
	movf	oLED_set, W			; update next line to be equal to the max number of animation sets
	sublw	Hyr0n_animation				; k - W, C = 0 if W > k, C = 1 if W <= k	
	btfss	STATUS, C	
	clrf	oLED_set
	
	; Select the oLED seq from the active set
	movlw	0x10
	movwf	oLED_seq_addr0
	clrf	oLED_seq_addr1
	clrf	oLED_seq_addr2
	movf	oLED_set, W
	movwf	temp
	btfsc	STATUS, Z
	goto	MAINLOOP3_oLED_set_loop_skip
MAINLOOP3_oLED_set_loop	
	movlw	d'64'
	addwf	oLED_seq_addr0, F
	movlw	0x00
	addwfc	oLED_seq_addr1, F
	addwfc	oLED_seq_addr2, F
	; should check for overflow but should not ever hit it
	decfsz	temp, F
	goto	MAINLOOP3_oLED_set_loop
MAINLOOP3_oLED_set_loop_skip	
	; randomly pick the seq from this set
	call	_4_CYCLE_LFSR
	andlw	0x3C				; this is a combined mask to 0-15 and shift left 2 for the 4 byte alignment of the regs
	addwf	oLED_seq_addr0, F
	movlw	0x00
	addwfc	oLED_seq_addr1, F
	addwfc	oLED_seq_addr2, F
			
	; read out the address and number of frames in this seq
	bcf		LATC, 5				; SPI EEPROM CS pin
	movlw	0x03				; Read at 24 bit address command
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movf	oLED_seq_addr2, W
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movf	oLED_seq_addr1, W
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movf	oLED_seq_addr0, W
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movlw	0xFF
	call	_4_SEND_RCV_W_SPI	
	movwf	oLED_seq_addr0
	call	_4_SEND_RCV_W_SPI	
	movwf	oLED_seq_addr1
	call	_4_SEND_RCV_W_SPI	
	movwf	oLED_seq_addr2
	call	_4_SEND_RCV_W_SPI	
	movwf	oLED_seq_cnt
	bsf		LATC, 5				; SPI EEPROM CS pin	
	
	; load new frame to screen
MAINLOOP3_oLED_get_next

	clrf	temp1
MAINLOOP3_oLED_row_loop
	; loop though 72 times to read out the row data to a buffer
	movlw	high(start_spi_buffer)
	movwf	FSR0H
	movlw	low(start_spi_buffer)
	movwf	FSR0L
	; send read command + address
	bcf		LATC, 5				; SPI EEPROM CS pin
	movlw	0x03				; Read at 24 bit address command
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movf	oLED_seq_addr2, W
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movf	oLED_seq_addr1, W
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movf	oLED_seq_addr0, W
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movlw	d'72'
	movwf	temp
MAINLOOP3_oLED_read_row
	call	_4_SEND_RCV_W_SPI	
	movwi	FSR0++
	decfsz	temp, F
	goto	MAINLOOP3_oLED_read_row	
	bsf		LATC, 5				; SPI EEPROM CS pin
	; update starting address to next block of data
	movlw	d'72'
	addwf	oLED_seq_addr0, F
	movlw	0x00
	addwfc	oLED_seq_addr1, F
	addwfc	oLED_seq_addr2, F

	
	; loop though 72 times to write out the row data to the oLED
	movlw	high(start_spi_buffer)
	movwf	FSR0H
	movlw	low(start_spi_buffer)
	movwf	FSR0L
	; Address the starting block of pixles to update
	movf	temp1, W		    ; select memory addressing page (0xB0 to 0xB7 valid. B0 is stripe with lowest corner, B4 is stripe with upper corner of the screen, B5-7 not used)
	movwf	i2c_off
	movlw	0x1C				; starting column
	call	_4_ADDRESS_oLED	
	; set on one block of pixles
	bsf		LATC, 4				; oLED D/#C pin
	bcf		LATC, 6				; oLED CS pin
	movlw	d'72'
	movwf	temp
MAINLOOP3_oLED_write_row
	moviw	FSR0++
	call	_4_SEND_RCV_W_SPI
	decfsz	temp, F
	goto	MAINLOOP3_oLED_write_row	
	bsf		LATC, 6				; oLED CS pin	

	incf	temp1, F
	movf	temp1, W
	xorlw	0x05
	btfss	STATUS, Z
	goto	MAINLOOP3_oLED_row_loop
	
	
	; read out the delay value
	bcf		LATC, 5				; SPI EEPROM CS pin
	movlw	0x03				; Read at 24 bit address command
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movf	oLED_seq_addr2, W
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movf	oLED_seq_addr1, W
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movf	oLED_seq_addr0, W
	call	_4_SEND_RCV_W_SPI	
	; discard this byte
	movlw	0xFF
	call	_4_SEND_RCV_W_SPI	
	movwf	oLED_dt	
	bsf		LATC, 5				; SPI EEPROM CS pin	
	movlw	d'1'
	addwf	oLED_seq_addr0, F
	movlw	0x00
	addwfc	oLED_seq_addr1, F
	addwfc	oLED_seq_addr2, F
		
	; point to the next frame
	decf	oLED_seq_cnt, F
		
	; set up the delay timer
	;------------------
	movlb	d'4'
	;------------------
	; stop the timer
	bcf		T1CON, 0
	; clear it
	clrf	TMR1H
	clrf	TMR1L
	;------------------
	movlb	d'0'
	;------------------
	clrf	oLED_phase
	; move delay value to the oLED timer
	movf	oLED_dt, W
	movwf	oLED_delay
	;------------------
	movlb	d'4'
	;------------------
	; start timer
	bsf		T1CON, 0
	;------------------
	movlb	d'0'
	;------------------
	
	; set the MSSP engine back up for I2C 
	call	_4_CFG_I2C
	
MAINLOOP3_oLED_done	
	
	
	movlp	0x08
	goto	MAINLOOP3_return
	
	;-----------------------------------------------------------------------------------------------------------
	
	de	CODE_VER_STRING
			
	;### end of program ###
	end	








