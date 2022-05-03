EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Vendo control"
Date "2020-01-04"
Rev "V0"
Comp "Tymkrs"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L metroid:Metroid icon1
U 1 1 5F232FE4
P 7050 6700
F 0 "icon1" H 7075 6753 60  0000 L CNN
F 1 "Metroid" H 7075 6647 60  0000 L CNN
F 2 "PJS-icons:metroid" H 7050 6700 60  0001 C CNN
F 3 "" H 7050 6700 60  0000 C CNN
	1    7050 6700
	1    0    0    -1  
$EndComp
Text Notes 8250 7250 0    25   ~ 0
Copyright (c) 2019 Peter Shabino\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this hardware, software, and associated documentation files \n(the "Product"), to deal in the Product without restriction, including without limitation the rights to use, copy, modify, merge, publish, \ndistribute, sublicense, and/or sell copies of the Product, and to permit persons to whom the Product is furnished to do so, subject to the \nfollowing conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Product.\n\nTHE PRODUCT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF \nMERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE \nFOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION \nWITH THE PRODUCT OR THE USE OR OTHER DEALINGS IN THE PRODUCT.\n\n\n\n
$Comp
L Connector_Generic:Conn_01x40 J2
U 1 1 5E1850BA
P 850 2900
F 0 "J2" H 850 4900 50  0000 C CNN
F 1 "Vendo Processor Socket" V 950 2900 50  0000 C CNN
F 2 "Package_DIP:DIP-40_W15.24mm_Socket_LongPads" H 850 2900 50  0001 C CNN
F 3 "~" H 850 2900 50  0001 C CNN
	1    850  2900
	-1   0    0    -1  
$EndComp
Wire Wire Line
	1050 2900 1150 2900
Wire Wire Line
	1150 2900 1150 5050
Wire Wire Line
	1050 4900 1250 4900
Wire Wire Line
	1250 4900 1250 850 
$Comp
L power:GND #PWR0101
U 1 1 5E188A1F
P 1150 5050
F 0 "#PWR0101" H 1150 4800 50  0001 C CNN
F 1 "GND" H 1155 4877 50  0000 C CNN
F 2 "" H 1150 5050 50  0001 C CNN
F 3 "" H 1150 5050 50  0001 C CNN
	1    1150 5050
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0102
U 1 1 5E18A202
P 1250 850
F 0 "#PWR0102" H 1250 700 50  0001 C CNN
F 1 "+5V" H 1265 1023 50  0000 C CNN
F 2 "" H 1250 850 50  0001 C CNN
F 3 "" H 1250 850 50  0001 C CNN
	1    1250 850 
	1    0    0    -1  
$EndComp
Wire Wire Line
	1050 4500 1450 4500
Text GLabel 1450 4500 2    50   Input ~ 0
Current_high
Wire Wire Line
	1050 4300 1450 4300
Text GLabel 1450 4300 2    50   Input ~ 0
Current_low
Wire Wire Line
	1050 3800 1450 3800
Text GLabel 1450 3800 2    50   Input ~ 0
Dollar_mech_in
Wire Wire Line
	1050 3900 1450 3900
Text GLabel 1450 3900 2    50   Input ~ 0
Dollar_mech_out
Wire Wire Line
	1050 3000 1450 3000
Wire Wire Line
	1450 3100 1050 3100
Wire Wire Line
	1050 4000 1450 4000
Text GLabel 1450 4000 2    50   Input ~ 0
Keypad_MISO
Text GLabel 1450 3100 2    50   Input ~ 0
Keypad_CS
Text GLabel 1450 3000 2    50   Input ~ 0
Keypad_CLK
Wire Wire Line
	1050 2700 1450 2700
Wire Wire Line
	1050 3500 1450 3500
Text GLabel 1450 3500 2    50   Input ~ 0
Display_CLK
Text GLabel 1450 2700 2    50   Input ~ 0
Display_Motor_MOSI
Wire Wire Line
	1050 2600 1450 2600
Wire Wire Line
	1050 2800 1450 2800
Text GLabel 1450 2800 2    50   Input ~ 0
Motor_CLK
Text GLabel 1450 2600 2    50   Input ~ 0
Motor_OE
Wire Wire Line
	1050 3600 1450 3600
Wire Wire Line
	1050 3700 1450 3700
Text GLabel 1450 3600 2    50   Input ~ 0
Motor_O1
Text GLabel 1450 3700 2    50   Input ~ 0
Motor_O2
$Comp
L Connector_Generic:Conn_01x05 J4
U 1 1 5E18E47A
P 850 6100
F 0 "J4" H 850 6400 50  0000 C CNN
F 1 "Badge_Drawer" V 950 6100 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x05_P2.54mm_Vertical" H 850 6100 50  0001 C CNN
F 3 "~" H 850 6100 50  0001 C CNN
	1    850  6100
	-1   0    0    -1  
$EndComp
$Comp
L power:GND #PWR0103
U 1 1 5E190341
P 1150 6400
F 0 "#PWR0103" H 1150 6150 50  0001 C CNN
F 1 "GND" H 1155 6227 50  0000 C CNN
F 2 "" H 1150 6400 50  0001 C CNN
F 3 "" H 1150 6400 50  0001 C CNN
	1    1150 6400
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0104
U 1 1 5E190D0E
P 1150 5550
F 0 "#PWR0104" H 1150 5400 50  0001 C CNN
F 1 "+5V" H 1165 5723 50  0000 C CNN
F 2 "" H 1150 5550 50  0001 C CNN
F 3 "" H 1150 5550 50  0001 C CNN
	1    1150 5550
	1    0    0    -1  
$EndComp
Wire Wire Line
	1050 6300 1150 6300
Wire Wire Line
	1150 6300 1150 6400
Wire Wire Line
	1050 5900 1150 5900
Wire Wire Line
	1150 5900 1150 5650
Wire Wire Line
	1050 6000 1400 6000
Wire Wire Line
	1050 6100 1400 6100
Wire Wire Line
	1400 6200 1250 6200
Text GLabel 1400 6000 2    50   Input ~ 0
IR_in
Text GLabel 1400 6100 2    50   Input ~ 0
IR_out
Text GLabel 1400 6200 2    50   Input ~ 0
Drawer_switch
$Comp
L Connector_Generic:Conn_01x05 J1
U 1 1 5E196D60
P 6950 2300
F 0 "J1" H 6950 2600 50  0000 C CNN
F 1 "PicKit" V 7050 2300 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x05_P2.54mm_Vertical" H 6950 2300 50  0001 C CNN
F 3 "~" H 6950 2300 50  0001 C CNN
	1    6950 2300
	1    0    0    -1  
$EndComp
Wire Wire Line
	4350 4100 4250 4100
Wire Wire Line
	3800 4100 3800 2100
Wire Wire Line
	3800 2100 6750 2100
Wire Wire Line
	6750 2200 6650 2200
Wire Wire Line
	6650 2200 6650 2000
Wire Wire Line
	6750 2300 6650 2300
Wire Wire Line
	6650 2300 6650 2600
Wire Wire Line
	4350 2900 4250 2900
Wire Wire Line
	4250 2900 4250 2800
Wire Wire Line
	4350 5400 4250 5400
Wire Wire Line
	4250 5400 4250 5500
$Comp
L power:GND #PWR0105
U 1 1 5E19D09D
P 4250 5500
F 0 "#PWR0105" H 4250 5250 50  0001 C CNN
F 1 "GND" H 4255 5327 50  0000 C CNN
F 2 "" H 4250 5500 50  0001 C CNN
F 3 "" H 4250 5500 50  0001 C CNN
	1    4250 5500
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0106
U 1 1 5E19DCD7
P 4250 2800
F 0 "#PWR0106" H 4250 2650 50  0001 C CNN
F 1 "+5V" H 4265 2973 50  0000 C CNN
F 2 "" H 4250 2800 50  0001 C CNN
F 3 "" H 4250 2800 50  0001 C CNN
	1    4250 2800
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0107
U 1 1 5E19EFC5
P 6650 2000
F 0 "#PWR0107" H 6650 1850 50  0001 C CNN
F 1 "+5V" H 6665 2173 50  0000 C CNN
F 2 "" H 6650 2000 50  0001 C CNN
F 3 "" H 6650 2000 50  0001 C CNN
	1    6650 2000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0108
U 1 1 5E19FED4
P 6650 2600
F 0 "#PWR0108" H 6650 2350 50  0001 C CNN
F 1 "GND" H 6655 2427 50  0000 C CNN
F 2 "" H 6650 2600 50  0001 C CNN
F 3 "" H 6650 2600 50  0001 C CNN
	1    6650 2600
	1    0    0    -1  
$EndComp
Wire Wire Line
	5800 3800 6150 3800
Wire Wire Line
	5800 3900 6150 3900
Wire Wire Line
	6150 4000 5800 4000
Wire Wire Line
	6150 5100 5800 5100
Wire Wire Line
	6150 5200 5800 5200
Wire Wire Line
	6150 5300 5800 5300
Wire Wire Line
	6150 5400 5800 5400
Wire Wire Line
	6150 3100 5800 3100
Wire Wire Line
	6150 3200 5800 3200
Wire Wire Line
	6150 4700 5800 4700
Wire Wire Line
	6150 4800 5800 4800
Wire Wire Line
	6150 4900 5800 4900
Wire Wire Line
	6150 5000 5800 5000
Wire Wire Line
	6150 2900 5800 2900
Wire Wire Line
	6150 3000 5800 3000
$Comp
L Device:R_Small R1
U 1 1 5E1AE200
P 4250 3550
F 0 "R1" V 4250 3500 25  0000 L CNN
F 1 "100k" V 4300 3350 25  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric" H 4250 3550 50  0001 C CNN
F 3 "~" H 4250 3550 50  0001 C CNN
	1    4250 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	4250 2900 4250 3450
Connection ~ 4250 2900
Wire Wire Line
	4250 3650 4250 4100
Connection ~ 4250 4100
Wire Wire Line
	4250 4100 3800 4100
$Comp
L Device:C_Small C6
U 1 1 5E1B346E
P 3950 7100
F 0 "C6" V 4000 6950 25  0000 L CNN
F 1 "0.1uF" V 4000 7150 25  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 3950 7100 50  0001 C CNN
F 3 "~" H 3950 7100 50  0001 C CNN
	1    3950 7100
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C7
U 1 1 5E1B4818
P 4100 7100
F 0 "C7" V 4150 6950 25  0000 L CNN
F 1 "10uf" V 4150 7150 25  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 4100 7100 50  0001 C CNN
F 3 "~" H 4100 7100 50  0001 C CNN
	1    4100 7100
	1    0    0    -1  
$EndComp
Wire Wire Line
	3950 7200 3950 7350
Wire Wire Line
	3950 7350 4100 7350
Wire Wire Line
	4100 7350 4100 7200
Wire Wire Line
	4100 7350 4100 7450
Connection ~ 4100 7350
Wire Wire Line
	4100 7000 4100 6850
Wire Wire Line
	4100 6850 3950 6850
Wire Wire Line
	3950 6850 3950 7000
Wire Wire Line
	3950 6850 3950 6750
Connection ~ 3950 6850
$Comp
L power:GND #PWR0109
U 1 1 5E1BA46D
P 4100 7450
F 0 "#PWR0109" H 4100 7200 50  0001 C CNN
F 1 "GND" H 4105 7277 50  0000 C CNN
F 2 "" H 4100 7450 50  0001 C CNN
F 3 "" H 4100 7450 50  0001 C CNN
	1    4100 7450
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0110
U 1 1 5E1BADC3
P 3950 6750
F 0 "#PWR0110" H 3950 6600 50  0001 C CNN
F 1 "+5V" H 3965 6923 50  0000 C CNN
F 2 "" H 3950 6750 50  0001 C CNN
F 3 "" H 3950 6750 50  0001 C CNN
	1    3950 6750
	1    0    0    -1  
$EndComp
Text GLabel 6150 3100 2    50   Input ~ 0
Motor_O1
Text GLabel 6150 3200 2    50   Input ~ 0
Motor_O2
Text GLabel 6150 4700 2    50   Input ~ 0
Motor_OE
Text GLabel 6150 4900 2    50   Input ~ 0
Display_Motor_MOSI
Text GLabel 6150 4800 2    50   Input ~ 0
Motor_CLK
Text GLabel 6150 5000 2    50   Input ~ 0
Display_CLK
Text GLabel 6150 2900 2    50   Input ~ 0
Current_low
Text GLabel 6150 3000 2    50   Input ~ 0
Current_high
Text GLabel 6150 3800 2    50   Input ~ 0
Keypad_CLK
Text GLabel 6150 3900 2    50   Input ~ 0
Keypad_CS
Text GLabel 6150 4000 2    50   Input ~ 0
Keypad_MISO
Text GLabel 6150 5100 2    50   Input ~ 0
Dollar_mech_in
Text GLabel 6150 5200 2    50   Input ~ 0
Dollar_mech_out
Text GLabel 6150 5300 2    50   Input ~ 0
IR_in
Text GLabel 6500 5400 2    50   Input ~ 0
IR_out
Text GLabel 6150 3300 2    50   Input ~ 0
Drawer_switch
$Comp
L Microchip_pjs:PIC16F15355-SSOP U1
U 1 1 5E1BF3ED
P 5700 2900
F 0 "U1" H 4500 3000 60  0000 C CNN
F 1 "PIC16F15355" H 5100 300 60  0000 C CNN
F 2 "Package_SO:SOIC-28W_7.5x18.7mm_P1.27mm" H 5700 2900 60  0001 C CNN
F 3 "" H 5700 2900 60  0001 C CNN
	1    5700 2900
	1    0    0    -1  
$EndComp
Wire Wire Line
	4350 5300 4250 5300
Wire Wire Line
	4250 5300 4250 5400
Connection ~ 4250 5400
Wire Wire Line
	5800 4500 5900 4500
Wire Wire Line
	5900 4500 5900 2400
Wire Wire Line
	5800 4400 6000 4400
Wire Wire Line
	6000 4400 6000 2500
Wire Wire Line
	5900 2400 6750 2400
Wire Wire Line
	6000 2500 6750 2500
Wire Wire Line
	5800 3300 6150 3300
Text GLabel 6150 3400 2    50   Input ~ 0
PLC_solved
Wire Wire Line
	5800 3400 6150 3400
Text GLabel 6150 4100 2    50   Input ~ 0
TX
Text GLabel 6150 4200 2    50   Input ~ 0
RX
Wire Wire Line
	5800 4100 6150 4100
Wire Wire Line
	6150 4200 5800 4200
$Comp
L Connector_Generic:Conn_01x02 J5
U 1 1 5E1F80E5
P 850 7300
F 0 "J5" H 850 7400 50  0000 C CNN
F 1 "PLC" V 950 7250 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x02_P2.54mm_Vertical" H 850 7300 50  0001 C CNN
F 3 "~" H 850 7300 50  0001 C CNN
	1    850  7300
	-1   0    0    -1  
$EndComp
Wire Wire Line
	1050 7300 1150 7300
Wire Wire Line
	1050 7400 1150 7400
Wire Wire Line
	1150 7400 1150 7500
$Comp
L power:GND #PWR0111
U 1 1 5E1FD83E
P 1150 7500
F 0 "#PWR0111" H 1150 7250 50  0001 C CNN
F 1 "GND" H 1155 7327 50  0000 C CNN
F 2 "" H 1150 7500 50  0001 C CNN
F 3 "" H 1150 7500 50  0001 C CNN
	1    1150 7500
	1    0    0    -1  
$EndComp
Text GLabel 1250 7300 2    50   Input ~ 0
PLC_solved
$Comp
L Device:R_Small R3
U 1 1 5E200B9F
P 1150 7100
F 0 "R3" V 1150 7050 25  0000 L CNN
F 1 "1k" V 1200 6950 25  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric" H 1150 7100 50  0001 C CNN
F 3 "~" H 1150 7100 50  0001 C CNN
	1    1150 7100
	1    0    0    -1  
$EndComp
Wire Wire Line
	1150 7000 1150 6900
Wire Wire Line
	1150 7200 1150 7300
Connection ~ 1150 7300
Wire Wire Line
	1150 7300 1250 7300
$Comp
L power:+5V #PWR0112
U 1 1 5E205610
P 1150 6900
F 0 "#PWR0112" H 1150 6750 50  0001 C CNN
F 1 "+5V" H 1165 7073 50  0000 C CNN
F 2 "" H 1150 6900 50  0001 C CNN
F 3 "" H 1150 6900 50  0001 C CNN
	1    1150 6900
	1    0    0    -1  
$EndComp
$Comp
L Interface_UART:MAX232I U2
U 1 1 5E210606
P 8750 3900
F 0 "U2" H 8200 4950 50  0000 C CNN
F 1 "MAX232IDR" H 8750 4150 50  0000 C CNN
F 2 "Package_SO:SOIC-16_3.9x9.9mm_P1.27mm" H 8800 2850 50  0001 L CNN
F 3 "http://www.ti.com/lit/ds/symlink/max232.pdf" H 8750 4000 50  0001 C CNN
	1    8750 3900
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C2
U 1 1 5E214D63
P 7850 3150
F 0 "C2" V 7900 3000 25  0000 L CNN
F 1 "1uF" V 7900 3200 25  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 7850 3150 50  0001 C CNN
F 3 "~" H 7850 3150 50  0001 C CNN
	1    7850 3150
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C3
U 1 1 5E217732
P 9650 3150
F 0 "C3" V 9700 3000 25  0000 L CNN
F 1 "1uF" V 9700 3200 25  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 9650 3150 50  0001 C CNN
F 3 "~" H 9650 3150 50  0001 C CNN
	1    9650 3150
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C4
U 1 1 5E217FE4
P 9750 3500
F 0 "C4" V 9800 3350 25  0000 L CNN
F 1 "1uF" V 9800 3550 25  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 9750 3500 50  0001 C CNN
F 3 "~" H 9750 3500 50  0001 C CNN
	1    9750 3500
	0    1    1    0   
$EndComp
$Comp
L Device:C_Small C5
U 1 1 5E219ADF
P 9750 3800
F 0 "C5" V 9800 3650 25  0000 L CNN
F 1 "1uF" V 9800 3850 25  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 9750 3800 50  0001 C CNN
F 3 "~" H 9750 3800 50  0001 C CNN
	1    9750 3800
	0    1    1    0   
$EndComp
$Comp
L Device:C_Small C1
U 1 1 5E219F71
P 8950 2600
F 0 "C1" V 9000 2450 25  0000 L CNN
F 1 "1uF" V 9000 2650 25  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 8950 2600 50  0001 C CNN
F 3 "~" H 8950 2600 50  0001 C CNN
	1    8950 2600
	0    1    1    0   
$EndComp
Wire Wire Line
	7950 3000 7850 3000
Wire Wire Line
	7850 3000 7850 3050
Wire Wire Line
	7850 3250 7850 3300
Wire Wire Line
	7850 3300 7950 3300
Wire Wire Line
	9550 3000 9650 3000
Wire Wire Line
	9650 3000 9650 3050
Wire Wire Line
	9550 3300 9650 3300
Wire Wire Line
	9650 3300 9650 3250
Wire Wire Line
	9550 3500 9650 3500
Wire Wire Line
	9850 3500 9950 3500
Wire Wire Line
	9950 3500 9950 3800
Wire Wire Line
	9850 3800 9950 3800
Connection ~ 9950 3800
Wire Wire Line
	9950 3800 9950 3900
Wire Wire Line
	9550 3800 9650 3800
Wire Wire Line
	8750 2700 8750 2600
Wire Wire Line
	8850 2600 8750 2600
Connection ~ 8750 2600
Wire Wire Line
	8750 2600 8750 2500
Wire Wire Line
	9050 2600 9150 2600
Wire Wire Line
	9150 2600 9150 2650
Wire Wire Line
	8750 5100 8750 5200
$Comp
L power:GND #PWR0113
U 1 1 5E23929B
P 8750 5300
F 0 "#PWR0113" H 8750 5050 50  0001 C CNN
F 1 "GND" H 8755 5127 50  0000 C CNN
F 2 "" H 8750 5300 50  0001 C CNN
F 3 "" H 8750 5300 50  0001 C CNN
	1    8750 5300
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0114
U 1 1 5E23A24C
P 9950 3900
F 0 "#PWR0114" H 9950 3650 50  0001 C CNN
F 1 "GND" H 9955 3727 50  0000 C CNN
F 2 "" H 9950 3900 50  0001 C CNN
F 3 "" H 9950 3900 50  0001 C CNN
	1    9950 3900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0115
U 1 1 5E23AC3D
P 9150 2650
F 0 "#PWR0115" H 9150 2400 50  0001 C CNN
F 1 "GND" H 9155 2477 50  0000 C CNN
F 2 "" H 9150 2650 50  0001 C CNN
F 3 "" H 9150 2650 50  0001 C CNN
	1    9150 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	9550 4000 9650 4000
Wire Wire Line
	9650 4000 9650 4400
Wire Wire Line
	9650 4400 9550 4400
Wire Wire Line
	7950 4200 7850 4200
Wire Wire Line
	7850 4200 7850 5200
Wire Wire Line
	7850 5200 8750 5200
Connection ~ 8750 5200
Wire Wire Line
	8750 5200 8750 5300
Wire Wire Line
	7950 4000 7750 4000
Wire Wire Line
	7950 4600 7750 4600
Text GLabel 7750 4000 0    50   Input ~ 0
TX
Text GLabel 7750 4600 0    50   Input ~ 0
RX
Wire Wire Line
	9550 4600 9950 4600
Wire Wire Line
	9950 4600 9950 4300
Wire Wire Line
	9950 4300 10450 4300
Wire Wire Line
	9550 4200 10450 4200
Wire Wire Line
	10450 4500 10350 4500
Wire Wire Line
	10350 4500 10350 5000
$Comp
L power:GND #PWR0116
U 1 1 5E266B4E
P 10350 5100
F 0 "#PWR0116" H 10350 4850 50  0001 C CNN
F 1 "GND" H 10355 4927 50  0000 C CNN
F 2 "" H 10350 5100 50  0001 C CNN
F 3 "" H 10350 5100 50  0001 C CNN
	1    10350 5100
	1    0    0    -1  
$EndComp
Wire Wire Line
	5800 3600 6350 3600
$Comp
L Device:LED_Small_ALT D1
U 1 1 5E26AF28
P 6450 3600
F 0 "D1" H 6350 3650 25  0000 C CNN
F 1 "Red" H 6550 3650 25  0000 C CNN
F 2 "LED_SMD:LED_0603_1608Metric" V 6450 3600 50  0001 C CNN
F 3 "~" V 6450 3600 50  0001 C CNN
	1    6450 3600
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R2
U 1 1 5E26D21D
P 6850 3600
F 0 "R2" V 6850 3550 25  0000 L CNN
F 1 "1k" V 6900 3450 25  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric" H 6850 3600 50  0001 C CNN
F 3 "~" H 6850 3600 50  0001 C CNN
	1    6850 3600
	0    1    1    0   
$EndComp
$Comp
L power:+5V #PWR0117
U 1 1 5E26E653
P 8750 2500
F 0 "#PWR0117" H 8750 2350 50  0001 C CNN
F 1 "+5V" H 8765 2673 50  0000 C CNN
F 2 "" H 8750 2500 50  0001 C CNN
F 3 "" H 8750 2500 50  0001 C CNN
	1    8750 2500
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0118
U 1 1 5E26F5AB
P 7050 3500
F 0 "#PWR0118" H 7050 3350 50  0001 C CNN
F 1 "+5V" H 7065 3673 50  0000 C CNN
F 2 "" H 7050 3500 50  0001 C CNN
F 3 "" H 7050 3500 50  0001 C CNN
	1    7050 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	6550 3600 6750 3600
Wire Wire Line
	6950 3600 7050 3600
Wire Wire Line
	7050 3600 7050 3500
$Comp
L Assmann_pjs:AE10921-ND J3
U 1 1 5E12D282
P 10550 4100
F 0 "J3" H 10550 4200 50  0000 R CNN
F 1 "AE10921-ND" V 10150 3850 50  0000 R CNN
F 2 "PJS-pth-parts:ASSMANN_dsub-9F_RA_AE10921-ND" H 10550 4100 50  0001 C CNN
F 3 "" H 10550 4100 50  0001 C CNN
	1    10550 4100
	-1   0    0    -1  
$EndComp
Wire Wire Line
	10450 5000 10350 5000
Connection ~ 10350 5000
Wire Wire Line
	10350 5000 10350 5100
$Comp
L Device:R_Small R4
U 1 1 5E12D8EE
P 6250 5400
F 0 "R4" V 6250 5350 25  0000 L CNN
F 1 "27 Ohn" V 6300 5250 25  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric" H 6250 5400 50  0001 C CNN
F 3 "~" H 6250 5400 50  0001 C CNN
	1    6250 5400
	0    1    1    0   
$EndComp
Wire Wire Line
	6350 5400 6500 5400
$Comp
L Device:R_Small R5
U 1 1 5E131677
P 1250 5800
F 0 "R5" V 1250 5750 25  0000 L CNN
F 1 "1k" V 1300 5650 25  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric" H 1250 5800 50  0001 C CNN
F 3 "~" H 1250 5800 50  0001 C CNN
	1    1250 5800
	1    0    0    -1  
$EndComp
Wire Wire Line
	1250 5900 1250 6200
Connection ~ 1250 6200
Wire Wire Line
	1250 6200 1050 6200
Wire Wire Line
	1250 5700 1250 5650
Wire Wire Line
	1250 5650 1150 5650
Connection ~ 1150 5650
Wire Wire Line
	1150 5650 1150 5550
Text Notes 6650 5950 0    150  ~ 0
TODO swap pins 10 and 11 on U2!!!
$EndSCHEMATC
