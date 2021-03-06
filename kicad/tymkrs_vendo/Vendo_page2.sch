EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 2
Title "Vendo control"
Date "2019-12-28"
Rev "V0"
Comp "Tymkrs"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector_Generic:Conn_01x19 P?
U 1 1 5E0F2BD4
P 10850 3350
F 0 "P?" H 10800 4350 50  0000 L CNN
F 1 "Motors 0.45pin x 0.157pitch" V 10950 2800 50  0000 L CNN
F 2 "" H 10850 3350 50  0001 C CNN
F 3 "~" H 10850 3350 50  0001 C CNN
	1    10850 3350
	1    0    0    -1  
$EndComp
Text Notes 10500 3250 0    50   ~ 0
Key
Wire Wire Line
	10650 2650 8500 2650
Wire Wire Line
	8600 2750 10650 2750
$Comp
L Allegro_pjs:UCN5890 U9
U 1 1 5E0F2BF3
P 8300 1550
F 0 "U9" H 7500 1650 50  0000 C CNN
F 1 "UCN5890" V 7800 900 50  0000 C CNN
F 2 "" H 7800 1350 25  0001 C CNN
F 3 "" H 7800 1350 25  0001 C CNN
	1    8300 1550
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R?
U 1 1 5E135118
P 8300 4700
AR Path="/5E135118" Ref="R?"  Part="1" 
AR Path="/5F9F9111/5E135118" Ref="R?"  Part="1" 
F 0 "R?" V 8300 4650 25  0000 L CNN
F 1 "1.5 Ohm 1.2W" V 8350 4550 25  0000 L CNN
F 2 "" H 8300 4700 50  0001 C CNN
F 3 "~" H 8300 4700 50  0001 C CNN
	1    8300 4700
	-1   0    0    1   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5E13511E
P 8300 4900
AR Path="/5E13511E" Ref="#PWR?"  Part="1" 
AR Path="/5F9F9111/5E13511E" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 8300 4650 50  0001 C CNN
F 1 "GND" H 8305 4727 50  0000 C CNN
F 2 "" H 8300 4900 50  0001 C CNN
F 3 "" H 8300 4900 50  0001 C CNN
	1    8300 4900
	1    0    0    -1  
$EndComp
Wire Wire Line
	8300 4800 8300 4900
Wire Wire Line
	8300 4600 8300 4500
Wire Wire Line
	8300 4500 8400 4500
Connection ~ 8300 4500
Text GLabel 8400 4500 2    50   Input ~ 0
Motor_cur_sns
Wire Wire Line
	8300 2450 10650 2450
Wire Wire Line
	8400 2550 8400 2350
Wire Wire Line
	8400 2350 8300 2350
Wire Wire Line
	8400 2550 10650 2550
Wire Wire Line
	8500 2650 8500 2250
Wire Wire Line
	8500 2250 8300 2250
Wire Wire Line
	8600 2750 8600 2150
Wire Wire Line
	8600 2150 8300 2150
Wire Wire Line
	8700 2850 8700 2050
Wire Wire Line
	8700 2050 8300 2050
Wire Wire Line
	8700 2850 10650 2850
Wire Wire Line
	8800 2950 8800 1750
Wire Wire Line
	8800 1750 8300 1750
Wire Wire Line
	8800 2950 10650 2950
Wire Wire Line
	8900 3050 8900 1850
Wire Wire Line
	8900 1850 8300 1850
Wire Wire Line
	8900 3050 10650 3050
Wire Wire Line
	9000 3150 9000 1950
Wire Wire Line
	9000 1950 8300 1950
Wire Wire Line
	9000 3150 10650 3150
Wire Wire Line
	8300 1550 8400 1550
Wire Wire Line
	8400 1550 8400 1450
$Comp
L power:+24V #PWR?
U 1 1 5E143D7D
P 8400 1450
F 0 "#PWR?" H 8400 1300 50  0001 C CNN
F 1 "+24V" H 8415 1623 50  0000 C CNN
F 2 "" H 8400 1450 50  0001 C CNN
F 3 "" H 8400 1450 50  0001 C CNN
	1    8400 1450
	1    0    0    -1  
$EndComp
Wire Wire Line
	7300 2450 7200 2450
Wire Wire Line
	7200 2450 7200 2550
$Comp
L power:GND #PWR?
U 1 1 5E145445
P 7200 2550
F 0 "#PWR?" H 7200 2300 50  0001 C CNN
F 1 "GND" H 7205 2377 50  0000 C CNN
F 2 "" H 7200 2550 50  0001 C CNN
F 3 "" H 7200 2550 50  0001 C CNN
	1    7200 2550
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 5E14618F
P 6950 2950
F 0 "#PWR?" H 6950 2800 50  0001 C CNN
F 1 "+5V" H 6965 3123 50  0000 C CNN
F 2 "" H 6950 2950 50  0001 C CNN
F 3 "" H 6950 2950 50  0001 C CNN
	1    6950 2950
	1    0    0    -1  
$EndComp
Wire Wire Line
	7300 1550 7200 1550
Wire Wire Line
	7200 1550 7200 1350
$Comp
L Device:R_Small R50-?
U 1 1 5E14B50A
P 7050 1550
AR Path="/5E14B50A" Ref="R50-?"  Part="1" 
AR Path="/5F9F9111/5E14B50A" Ref="R50-4"  Part="1" 
F 0 "R50-4" V 7050 1500 20  0000 L CNN
F 1 "10k" V 7100 1400 25  0000 L CNN
F 2 "" H 7050 1550 50  0001 C CNN
F 3 "~" H 7050 1550 50  0001 C CNN
	1    7050 1550
	1    0    0    -1  
$EndComp
Wire Wire Line
	7300 1750 7050 1750
Wire Wire Line
	7050 1750 7050 1650
Wire Wire Line
	7050 1450 7050 1350
Wire Wire Line
	7050 1350 7200 1350
Connection ~ 7200 1350
Wire Wire Line
	7200 1350 7200 1250
$Comp
L Device:C_Small C?
U 1 1 5E15183B
P 7800 1000
AR Path="/5E15183B" Ref="C?"  Part="1" 
AR Path="/5F9F9111/5E15183B" Ref="C19"  Part="1" 
F 0 "C19" V 7850 875 25  0000 L CNN
F 1 "0.1uF" V 7850 1050 25  0000 L CNN
F 2 "" H 7800 1000 50  0001 C CNN
F 3 "~" H 7800 1000 50  0001 C CNN
	1    7800 1000
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 5E15239F
P 7800 750
F 0 "#PWR?" H 7800 600 50  0001 C CNN
F 1 "+5V" H 7815 923 50  0000 C CNN
F 2 "" H 7800 750 50  0001 C CNN
F 3 "" H 7800 750 50  0001 C CNN
	1    7800 750 
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5E152C1B
P 7800 1250
F 0 "#PWR?" H 7800 1000 50  0001 C CNN
F 1 "GND" H 7805 1077 50  0000 C CNN
F 2 "" H 7800 1250 50  0001 C CNN
F 3 "" H 7800 1250 50  0001 C CNN
	1    7800 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	7800 750  7800 800 
Wire Wire Line
	7800 1100 7800 1200
Wire Wire Line
	7050 1750 6550 1750
Connection ~ 7050 1750
Text GLabel 6550 1750 0    25   Input ~ 0
PB7-19
Wire Wire Line
	7300 1850 6950 1850
$Comp
L Device:R_Small R50-?
U 1 1 5E157719
P 6950 1550
AR Path="/5E157719" Ref="R50-?"  Part="1" 
AR Path="/5F9F9111/5E157719" Ref="R50-3"  Part="1" 
F 0 "R50-3" V 6950 1500 20  0000 L CNN
F 1 "10k" V 7000 1400 25  0000 L CNN
F 2 "" H 6950 1550 50  0001 C CNN
F 3 "~" H 6950 1550 50  0001 C CNN
	1    6950 1550
	1    0    0    -1  
$EndComp
Wire Wire Line
	6950 1650 6950 1850
Connection ~ 6950 1850
Wire Wire Line
	6950 1850 6550 1850
Wire Wire Line
	6950 1450 6950 1350
Wire Wire Line
	6950 1350 7050 1350
Connection ~ 7050 1350
Text GLabel 6550 1850 0    25   Input ~ 0
PB6-18
$Comp
L Device:R_Small R50-?
U 1 1 5E159A4A
P 6850 1550
AR Path="/5E159A4A" Ref="R50-?"  Part="1" 
AR Path="/5F9F9111/5E159A4A" Ref="R50-6"  Part="1" 
F 0 "R50-6" V 6850 1500 20  0000 L CNN
F 1 "10k" V 6900 1400 25  0000 L CNN
F 2 "" H 6850 1550 50  0001 C CNN
F 3 "~" H 6850 1550 50  0001 C CNN
	1    6850 1550
	1    0    0    -1  
$EndComp
Wire Wire Line
	6850 1650 6850 1950
Wire Wire Line
	6850 1950 7300 1950
Wire Wire Line
	6850 1450 6850 1350
Wire Wire Line
	6850 1350 6950 1350
Connection ~ 6950 1350
$Comp
L Device:R_Small R50-?
U 1 1 5E161133
P 6750 1550
AR Path="/5E161133" Ref="R50-?"  Part="1" 
AR Path="/5F9F9111/5E161133" Ref="R50-5"  Part="1" 
F 0 "R50-5" V 6750 1500 20  0000 L CNN
F 1 "10k" V 6800 1400 25  0000 L CNN
F 2 "" H 6750 1550 50  0001 C CNN
F 3 "~" H 6750 1550 50  0001 C CNN
	1    6750 1550
	1    0    0    -1  
$EndComp
Wire Wire Line
	7300 2050 6750 2050
Wire Wire Line
	6750 2050 6750 1650
Wire Wire Line
	6750 1450 6750 1350
Wire Wire Line
	6750 1350 6850 1350
Connection ~ 6850 1350
Wire Wire Line
	6750 2050 6550 2050
Connection ~ 6750 2050
Text GLabel 6550 2050 0    25   Input ~ 0
PB5-17
Text Notes 7400 2600 0    50   ~ 0
Can only drive a high
$Comp
L Allegro_pjs:UCN5842 U10
U 1 1 5E1758FA
P 8200 3150
F 0 "U10" H 7600 3250 50  0000 C CNN
F 1 "UCN5842" V 7800 2300 50  0000 C CNN
F 2 "" H 8450 3550 50  0001 C CNN
F 3 "" H 7850 3150 50  0001 C CNN
	1    8200 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	8200 3150 8300 3150
Wire Wire Line
	8300 3150 8300 3050
$Comp
L power:+24V #PWR?
U 1 1 5E179800
P 8300 3050
F 0 "#PWR?" H 8300 2900 50  0001 C CNN
F 1 "+24V" H 8315 3223 50  0000 C CNN
F 2 "" H 8300 3050 50  0001 C CNN
F 3 "" H 8300 3050 50  0001 C CNN
	1    8300 3050
	1    0    0    -1  
$EndComp
Wire Wire Line
	8200 4350 8300 4350
Wire Wire Line
	8300 4350 8300 4500
Wire Wire Line
	8200 4250 8300 4250
Wire Wire Line
	8300 4250 8300 4350
Connection ~ 8300 4350
Wire Wire Line
	8200 3350 10650 3350
Wire Wire Line
	8200 3450 10650 3450
Wire Wire Line
	8200 3550 10650 3550
Wire Wire Line
	8200 3650 10650 3650
Wire Wire Line
	8200 3750 10650 3750
Wire Wire Line
	8200 3850 10650 3850
Wire Wire Line
	8200 3950 10650 3950
Wire Wire Line
	8200 4050 10650 4050
Text Notes 7400 4500 0    50   ~ 0
Can only drive a low
$Comp
L Device:C_Small C?
U 1 1 5E1A7745
P 7950 1000
AR Path="/5E1A7745" Ref="C?"  Part="1" 
AR Path="/5F9F9111/5E1A7745" Ref="C18"  Part="1" 
F 0 "C18" V 8000 875 25  0000 L CNN
F 1 "0.1uF" V 8000 1050 25  0000 L CNN
F 2 "" H 7950 1000 50  0001 C CNN
F 3 "~" H 7950 1000 50  0001 C CNN
	1    7950 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	7800 800  7950 800 
Wire Wire Line
	7950 800  7950 900 
Connection ~ 7800 800 
Wire Wire Line
	7800 800  7800 900 
Wire Wire Line
	7800 1200 7950 1200
Wire Wire Line
	7950 1200 7950 1100
Connection ~ 7800 1200
Wire Wire Line
	7800 1200 7800 1250
Wire Wire Line
	7400 4350 7300 4350
Wire Wire Line
	7300 4350 7300 4450
$Comp
L power:GND #PWR?
U 1 1 5E1B4D2B
P 7300 4450
F 0 "#PWR?" H 7300 4200 50  0001 C CNN
F 1 "GND" H 7305 4277 50  0000 C CNN
F 2 "" H 7300 4450 50  0001 C CNN
F 3 "" H 7300 4450 50  0001 C CNN
	1    7300 4450
	1    0    0    -1  
$EndComp
Wire Wire Line
	7400 3150 7300 3150
Wire Wire Line
	7300 3150 7300 3050
$Comp
L power:+5V #PWR?
U 1 1 5E1B7BEA
P 7300 3050
F 0 "#PWR?" H 7300 2900 50  0001 C CNN
F 1 "+5V" H 7315 3223 50  0000 C CNN
F 2 "" H 7300 3050 50  0001 C CNN
F 3 "" H 7300 3050 50  0001 C CNN
	1    7300 3050
	1    0    0    -1  
$EndComp
Wire Wire Line
	7400 3350 7050 3350
Wire Wire Line
	7050 3350 7050 1750
Wire Wire Line
	6850 2150 6850 3450
Wire Wire Line
	6850 3450 7400 3450
Wire Wire Line
	6850 2150 7300 2150
$Comp
L Device:R_Small R50-?
U 1 1 5E1BE488
P 6950 3150
AR Path="/5E1BE488" Ref="R50-?"  Part="1" 
AR Path="/5F9F9111/5E1BE488" Ref="R50-7"  Part="1" 
F 0 "R50-7" V 6950 3100 20  0000 L CNN
F 1 "10k" V 7000 3000 25  0000 L CNN
F 2 "" H 6950 3150 50  0001 C CNN
F 3 "~" H 6950 3150 50  0001 C CNN
	1    6950 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	7400 3650 6950 3650
Wire Wire Line
	6950 3650 6950 3250
Wire Wire Line
	6950 2950 6950 3050
Wire Wire Line
	7400 3750 6750 3750
Wire Wire Line
	6750 3750 6750 2050
$Comp
L Transistor_Array:ULN2003A U14
U 1 1 5E1D29C0
P 8800 5500
F 0 "U14" H 8550 6050 50  0000 C CNN
F 1 "ULN2003A" V 8900 5400 50  0000 C CNN
F 2 "" H 8850 4950 50  0001 L CNN
F 3 "http://www.ti.com/lit/ds/symlink/uln2003a.pdf" H 8900 5300 50  0001 C CNN
	1    8800 5500
	1    0    0    -1  
$EndComp
Wire Wire Line
	9200 5300 9800 5300
Wire Wire Line
	9800 5300 9800 4150
Wire Wire Line
	9800 4150 10650 4150
Wire Wire Line
	9900 4250 9900 5400
Wire Wire Line
	9900 5400 9200 5400
Wire Wire Line
	9900 4250 10650 4250
Wire Wire Line
	8800 6100 8800 6200
Wire Wire Line
	8800 6200 8900 6200
Wire Wire Line
	9200 5100 9300 5100
Wire Wire Line
	9300 5100 9300 5000
Wire Wire Line
	8400 5300 8150 5300
Wire Wire Line
	8400 5400 8150 5400
Wire Wire Line
	8400 5500 8300 5500
Wire Wire Line
	8300 5500 8300 5600
Wire Wire Line
	8400 5600 8300 5600
Connection ~ 8300 5600
Wire Wire Line
	8300 5600 8300 5700
Wire Wire Line
	8400 5700 8300 5700
Connection ~ 8300 5700
Wire Wire Line
	8300 5700 8300 5800
Wire Wire Line
	8400 5800 8300 5800
Connection ~ 8300 5800
Wire Wire Line
	8300 5800 8300 5900
Wire Wire Line
	8400 5900 8300 5900
Connection ~ 8300 5900
Wire Wire Line
	8300 5900 8300 6000
Text GLabel 8900 6200 2    50   Input ~ 0
Motor_cur_sns
$Comp
L power:+5V #PWR?
U 1 1 5E1FF104
P 7200 1250
F 0 "#PWR?" H 7200 1100 50  0001 C CNN
F 1 "+5V" H 7215 1423 50  0000 C CNN
F 2 "" H 7200 1250 50  0001 C CNN
F 3 "" H 7200 1250 50  0001 C CNN
	1    7200 1250
	1    0    0    -1  
$EndComp
$Comp
L power:+24V #PWR?
U 1 1 5E1FF977
P 9300 5000
F 0 "#PWR?" H 9300 4850 50  0001 C CNN
F 1 "+24V" H 9315 5173 50  0000 C CNN
F 2 "" H 9300 5000 50  0001 C CNN
F 3 "" H 9300 5000 50  0001 C CNN
	1    9300 5000
	1    0    0    -1  
$EndComp
Text GLabel 8150 5300 0    25   Input ~ 0
PC0-28
Text GLabel 8150 5400 0    25   Input ~ 0
PC1-27
$Comp
L power:GND #PWR?
U 1 1 5E20110E
P 8300 6000
AR Path="/5E20110E" Ref="#PWR?"  Part="1" 
AR Path="/5F9F9111/5E20110E" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 8300 5750 50  0001 C CNN
F 1 "GND" H 8305 5827 50  0000 C CNN
F 2 "" H 8300 6000 50  0001 C CNN
F 3 "" H 8300 6000 50  0001 C CNN
	1    8300 6000
	1    0    0    -1  
$EndComp
Text Notes 8850 6100 0    50   ~ 0
Can only drive a low
$Comp
L LiteON_pjs:LTM-8328C DISP?
U 1 1 5E207AB5
P 3500 2200
F 0 "DISP?" H 3250 2300 50  0000 C CNN
F 1 "LTM-8328C" H 3650 1500 50  0000 C CNN
F 2 "" H 3500 2000 50  0001 C CNN
F 3 "" H 3500 2000 50  0001 C CNN
	1    3500 2200
	1    0    0    -1  
$EndComp
$Comp
L Device:LED_Small_ALT D?
U 1 1 5E209278
P 4250 2400
F 0 "D?" H 4150 2350 25  0000 C CNN
F 1 "Red" H 4350 2350 25  0000 C CNN
F 2 "" V 4250 2400 50  0001 C CNN
F 3 "~" V 4250 2400 50  0001 C CNN
	1    4250 2400
	1    0    0    -1  
$EndComp
$Comp
L Device:LED_Small_ALT D?
U 1 1 5E20AED2
P 4250 2500
F 0 "D?" H 4150 2450 25  0000 C CNN
F 1 "Red" H 4350 2450 25  0000 C CNN
F 2 "" V 4250 2500 50  0001 C CNN
F 3 "~" V 4250 2500 50  0001 C CNN
	1    4250 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	4000 2400 4150 2400
Wire Wire Line
	4150 2500 4000 2500
Wire Wire Line
	3050 2900 2950 2900
Wire Wire Line
	2950 2900 2950 3000
$Comp
L power:GND #PWR?
U 1 1 5E216D7D
P 2950 3000
F 0 "#PWR?" H 2950 2750 50  0001 C CNN
F 1 "GND" H 2955 2827 50  0000 C CNN
F 2 "" H 2950 3000 50  0001 C CNN
F 3 "" H 2950 3000 50  0001 C CNN
	1    2950 3000
	1    0    0    -1  
$EndComp
$Comp
L Device:D_Small_ALT D?
U 1 1 5E21ABB3
P 4250 2200
AR Path="/5E21ABB3" Ref="D?"  Part="1" 
AR Path="/5F9F9111/5E21ABB3" Ref="D12"  Part="1" 
F 0 "D12" H 4150 2250 25  0000 C CNN
F 1 "1N4002" H 4400 2250 25  0000 C CNN
F 2 "" V 4250 2200 50  0001 C CNN
F 3 "~" V 4250 2200 50  0001 C CNN
	1    4250 2200
	1    0    0    -1  
$EndComp
$Comp
L Device:D_Small_ALT D?
U 1 1 5E21E7E4
P 4650 2200
AR Path="/5E21E7E4" Ref="D?"  Part="1" 
AR Path="/5F9F9111/5E21E7E4" Ref="D11"  Part="1" 
F 0 "D11" H 4550 2250 25  0000 C CNN
F 1 "1N4002" H 4800 2250 25  0000 C CNN
F 2 "" V 4650 2200 50  0001 C CNN
F 3 "~" V 4650 2200 50  0001 C CNN
	1    4650 2200
	1    0    0    -1  
$EndComp
Wire Wire Line
	4000 2200 4100 2200
Wire Wire Line
	4350 2200 4550 2200
$Comp
L Device:R_Small R50-?
U 1 1 5E227471
P 2750 2200
AR Path="/5E227471" Ref="R50-?"  Part="1" 
AR Path="/5F9F9111/5E227471" Ref="R51"  Part="1" 
F 0 "R51" V 2750 2150 25  0000 L CNN
F 1 "15k" V 2800 2050 25  0000 L CNN
F 2 "" H 2750 2200 50  0001 C CNN
F 3 "~" H 2750 2200 50  0001 C CNN
	1    2750 2200
	1    0    0    -1  
$EndComp
Wire Wire Line
	4750 2200 4950 2200
Wire Wire Line
	3050 2200 2900 2200
Wire Wire Line
	4950 1950 4950 2200
Wire Wire Line
	3050 2400 2950 2400
Wire Wire Line
	2950 2400 2950 2900
Connection ~ 2950 2900
$Comp
L Device:C_Small C?
U 1 1 5E23B713
P 2750 2900
AR Path="/5E23B713" Ref="C?"  Part="1" 
AR Path="/5F9F9111/5E23B713" Ref="CC12"  Part="1" 
F 0 "CC12" V 2800 2775 25  0000 L CNN
F 1 "0.1uF" V 2800 2950 25  0000 L CNN
F 2 "" H 2750 2900 50  0001 C CNN
F 3 "~" H 2750 2900 50  0001 C CNN
	1    2750 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	4100 2200 4100 2300
Wire Wire Line
	4100 2300 4450 2300
Wire Wire Line
	4450 2300 4450 2400
Wire Wire Line
	4450 2500 4350 2500
Connection ~ 4100 2200
Wire Wire Line
	4100 2200 4150 2200
Wire Wire Line
	4350 2400 4450 2400
Connection ~ 4450 2400
Wire Wire Line
	4450 2400 4450 2500
Wire Wire Line
	2750 3000 2750 3100
$Comp
L power:GND #PWR?
U 1 1 5E2532DC
P 2750 3100
F 0 "#PWR?" H 2750 2850 50  0001 C CNN
F 1 "GND" H 2755 2927 50  0000 C CNN
F 2 "" H 2750 3100 50  0001 C CNN
F 3 "" H 2750 3100 50  0001 C CNN
	1    2750 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	2750 2300 2750 2700
Wire Wire Line
	2750 2700 3050 2700
Connection ~ 2750 2700
Wire Wire Line
	2750 2700 2750 2800
Wire Wire Line
	2900 2200 2900 2000
Wire Wire Line
	2900 2000 2750 2000
Wire Wire Line
	2750 2000 2750 2100
Wire Wire Line
	2900 2000 2900 1900
Connection ~ 2900 2000
$Comp
L power:+5V #PWR?
U 1 1 5E2D7854
P 2900 1900
F 0 "#PWR?" H 2900 1750 50  0001 C CNN
F 1 "+5V" H 2915 2073 50  0000 C CNN
F 2 "" H 2900 1900 50  0001 C CNN
F 3 "" H 2900 1900 50  0001 C CNN
	1    2900 1900
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR?
U 1 1 5E2D90CF
P 4950 1950
F 0 "#PWR?" H 4950 1800 50  0001 C CNN
F 1 "+5V" H 4965 2123 50  0000 C CNN
F 2 "" H 4950 1950 50  0001 C CNN
F 3 "" H 4950 1950 50  0001 C CNN
	1    4950 1950
	1    0    0    -1  
$EndComp
Wire Wire Line
	3050 2600 2650 2600
Wire Wire Line
	3050 2500 2550 2500
Text GLabel 2550 2500 0    25   Input ~ 0
PB6-18
$Comp
L Device:R_Small R?
U 1 1 5E2F22C0
P 2650 2200
AR Path="/5E2F22C0" Ref="R?"  Part="1" 
AR Path="/5F9F9111/5E2F22C0" Ref="R?"  Part="1" 
F 0 "R?" V 2650 2150 25  0000 L CNN
F 1 "10k" V 2700 2050 25  0000 L CNN
F 2 "" H 2650 2200 50  0001 C CNN
F 3 "~" H 2650 2200 50  0001 C CNN
	1    2650 2200
	1    0    0    -1  
$EndComp
Text GLabel 2550 2600 0    25   Input ~ 0
PC2-26
Wire Wire Line
	2650 2300 2650 2600
Connection ~ 2650 2600
Wire Wire Line
	2650 2600 2550 2600
Wire Wire Line
	2650 2100 2650 2000
Wire Wire Line
	2650 2000 2750 2000
Connection ~ 2750 2000
Text Notes 3100 3050 0    25   ~ 0
https://www.datasheets360.com/pdf/-5440550495646308264
Text Notes 7900 6450 0    50   ~ 0
http://www.thevendingcenter.com/128_129_SS_manual.pdf\nhttps://forums.adafruit.com/viewtopic.php?f=8&p=697826\n
$EndSCHEMATC
