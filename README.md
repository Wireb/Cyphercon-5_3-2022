# Cyphercon 5.3 2022 
This repo is a collection of files related to the Cyphercon 5.3 badge and support hardware. 
Peacock board files and data pulled out to make the lifetime badges a bit harder to forge. 

## KiCad
This is a KiCad 5.x project. 

## MplabX
This is a mplabX 5.35 project. All programming / debug was done with a PicKit4.

## FreeCAD
These are FreeCAD 0.19 

## Inkscape
Version 1.0.1 used

## Documentation

- Cyphercon 2020.xlsx - Master document used for badge development. BOMs, communication, game mech, flash layout, animation documentation
- FreeCAD/Start button-2022  Cad files related to the conference start button
- FreeCAD/tymkrs_Cyphercon_2022 Cad files related to the badge and vending machine 
   - bottle_button_support.FCStd - support structure for IR button used in the snake oil button 
   - button_case.FCStd - support structure for IR button used in the bee and bird seed bags
   - coyote_final.FCStd - screen alignment tool
   - coyote_stencil.FCStd - flocking stencil and blocks
   - flamingo_final.FCStd - screen alignment tool
   - flamingo_flock_blocks.FCStd - alignment blocks for badge on stencil machine 
   - flamingo_pgm_fixture.FCStd - programing fixture for flamingo badges
   - flamingo_stencil_2_tone_a.FCStd - flocking stencil
   - flamingo_stencil_V2.FCStd - flocking stencil
   - llama_final.FCStd - screen alignment tool
   - llama_stencil.FCStd - flocking stencil and blocks
   - Outhouse_socket.FCStd - socket for holding badge in outhouse
   - parrot_final.FCStd - screen alignment tool
   - parrot_stencil.FCStd - flocking stencil and blocks
   - peacock_final.FCStd - screen alignment tool
   - port_a_potty.FCStd - port-a-potty IR button housing 
   - Starfish.FCStd - starfish stencil for back of all the badges
   - Vendo_bracket.FCStd - support bracket for replacement processor board in the vending machine
   - Vendo_socket.FCStd - socket for badge on front of the vending machine 
   - wash_holders.FCStd - holder for running PCBs though flux remover in the ultrasonic cleaner
- inkscape - Intermediate files used to build up the stencils from the silk screen layers
- kicad 
   - tymkrs_Cyphercon_2020_Coyote - Coyote badge files
   - tymkrs_Cyphercon_2020_flamingo - Flamingo badge files
   - tymkrs_Cyphercon_2020_IRbutton - IR button files 
   - tymkrs_Cyphercon_2020_IRhack - IR hack and start button board (note start button was highly modified and mostly just used as a PIC chip holder.)
   - tymkrs_Cyphercon_2020_Llama - Llama badge files
   - tymkrs_Cyphercon_2020_Parrot - Parrot badge files 
   - tymkrs_vendo - Vendo processor replacement board (note "vendo.???" files are my schematics from reverse engineering the vending machine board) 
- mplab
    - Tymkrs_Cyphercon2020_IRblaster - Firmware for con start button
    - Tymkrs_Cyphercon2020_IRhack - Firmware for IRhack board 
    - Tymkrs_Cyphercon_2020_badge - Firmware for badges (one build supports all. Function defined by ID range) 
    - Tymkrs_Cyphercon_2020_IRbutton - Firmware for IR buttons and outhouses (Note there is a #ifdef to set outhouse vs IR button mode) 
- perl
   - Animation_build_list - flamingo.txt - build list to go with build_animations.pl script to generate animation_flamingo.bin
   - Animation_build_list_CPL.txt - build list to go with build_animations.pl script to generate animation_CPL.bin
   - Animation_build_list_peacock.txt - build list to go with animation_peacock.pl script to generate animation_flamingo.bin
   - animation_CPL.bin - output animation data file that should be written to the SPI eeprom on the badge for coyote, parrot, and llama
   - animation_flamingo.bin - output animation data file that should be written to the SPI eeprom on the badge
   - animation_peacock.bin - output animation data file that should be written to the SPI eeprom on the badge
   - build_animations.pl - this script takes in the animation frames in PNG format per the animation_build_list and generates the binary files to be written to the - eeprom
   - CPL_eyes - file folder of png files for coyote, parrot, and llama
   - cyphercon2020-pgm.pl - programing script for the PIC generate random key for crypto and takes user input for badge ID (badge type is determined by ID range. See documentation)
   - cyphercon2022.db - database dump from the vending machine 
   - Cyphercon_2020_test.pl - test utility to be use with a IR hack to gest the various badge communication functions
   - F_eyes - file folder of png files for flamingos
   - hbdh.png - Happy birthday Hyr0n (was going to be on his birthday in 2020... Happy belated bday Hyr0n) 
   - metroid.png - PNG used in base firmware to test the LCD when the SPI eeprom is not programed
   - P_eyes - file folder of png files for peacocks
   - Tymkrs_Cyphercon_2020_badge.X.production.hex - final released firmware (should be the same as the copy in the mplab directory... I hope) 
   - Tymkrs_Cyphercon_2020_keys.txt - Master list of keys used in the vending machine. Use the last one in the file when duplicates badge IDs are found. 
   - Vending_data.xlsx - Decoded dump in excel with some post processing to get some stats
   - Vendo_decode.pl - used to export the vending machine database to CSV files
   - Vendo_server.pl - Vending machine server script that did all the vending machine functions other that the monitor display
   - Vendo_test.pl - test script for the vending machine controller board


Copyright (c) 2019 - 2022 Peter Shabino

Permission is hereby granted, free of charge, to any person obtaining a copy of this hardware, software, and associated documentation files 
(the "Product"), to deal in the Product without restriction, including without limitation the rights to use, copy, modify, merge, publish, 
distribute, sublicense, and/or sell copies of the Product, and to permit persons to whom the Product is furnished to do so, subject to the 
following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Product.

THE PRODUCT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
WITH THE PRODUCT OR THE USE OR OTHER DEALINGS IN THE PRODUCT.
