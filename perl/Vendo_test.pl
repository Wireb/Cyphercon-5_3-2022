

use Term::ReadKey;
#ReadMode 4; # Turn off controls keys
#ReadMode 0; # Reset tty mode before exiting


$sph = &open_serial("com6");
$| = 1; # autoflush

$seq = 0;
@bytes = ();
$string = "";
$decode_str = "";
$command = "";
$decode = "n";
$count = 0;
$expected = 0;

info();
print("init done \n");



while(1){
	$key = ReadKey(-1);
	if($key eq "\r"){
		print("\n");
	}
	if($key eq "?"){
		info();
	}
	if($key eq "a"){
		print("\nsending reset\n");
		send_packet($sph, chr(0x00).chr(0x00));
		$decode = "n";
	}
	if($key eq "b"){
		print("\nsending dead to leds\n");
		send_packet($sph, chr(0x01).chr(0x05).chr(0x3D).chr(0x4F).chr(0x77).chr(0x3D).chr(0x20));
		$decode = "n";
	}
	if($key eq "c"){
		print("\nsending beef to leds\n");
		send_packet($sph, chr(0x01).chr(0x05).chr(0x1F).chr(0x4F).chr(0x4F).chr(0x47).chr(0x40));
		$decode = "n";
	}
	if($key eq "d"){
		print("\nsending dispense row 4 col 4\n");
		send_packet($sph, chr(0x02).chr(0x02).chr(0x04).chr(0x04));
		$decode = "n";
	}
	if($key eq "e"){
		print("\nsending dispense row 3 col 0\n");
		send_packet($sph, chr(0x02).chr(0x02).chr(0x03).chr(0x08));
		$decode = "n";
	}
	if($key eq "f"){
		print("\nsending dispense row 2 col 1\n");
		send_packet($sph, chr(0x02).chr(0x02).chr(0x00).chr(0x02));
		$command = "";
		$decode = "n";
	}
	if($key eq "g"){
		print("\nsending dispense row 8 col 9\n");
		send_packet($sph, chr(0x02).chr(0x02).chr(0x07).chr(0x08));
		$decode = "n";
	}
	if($key eq "h"){
		print("\nsending get vendo status\n");
		send_packet($sph, chr(0x03).chr(0x00));
		$decode = "n";
	}
	if($key eq "i"){
		print("\nsending get key buffer\n");
		send_packet($sph, chr(0x04).chr(0x00));
		$decode = "n";
	}
	if($key eq "j"){
		print("\nsending IR request dump\n");
		send_packet($sph, chr(0x05).chr(0x01).chr(0x01));
		$command = "j";
		$decode = "n";
	}
	if($key eq "k"){
		print("\nsending IR set quest for badge 0x02FD\n");
		send_packet($sph, chr(0x05).chr(0x03).chr(0x06).chr(0x02).chr(0xFD));
		$decode = "n";
	}
	if($key eq "l"){
		print("\nsending dump IR buffer 1\n");
		$decode = "y";
		$decode_str = "";
		$count_dec = 0;
		$expected = 146;	
		# 8f536d6173683f000202fe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000403ccd0001790d0a
		send_packet($sph, chr(0x06).chr(0x00));
	}
	
	
	
	
	if($key eq "x"){
		print("got x exiting\n");
		$sph->close();
		exit(0);
	}
	
	
	($count, $rcvstring) = $sph->read(1);	#actual read
	if($count != 0){
		#print($rcvstring);
		$string .= $rcvstring;
		$decode_str .= $rcvstring;
		$count_dec += $count;
		print(unpack("H*",$rcvstring));
		if(unpack("H*",$rcvstring) eq "0a"){
			$string =~ s/[^a-zA-z0-9]//gi;
			print("  ".$string."\n");
			$string = "";
		}
		
		if($count_dec >= $expected && $decode eq "y"){
			if($command eq "j"){
				# decode dump packet
				print("\nDecoding badge dump packet\n");
				$ok = 1;
				@chars = split("",$decode_str);
				
				foreach $temp(@chars){
					push(@bytes, sprintf("%02X",ord($temp)))
				}
				
				if($chars[0] eq chr(0x8F)){
					print("	Packet length ok\n");
				}else{
					print("	Packet length incorrect 0x".sprintf("%02X",ord($bytes[6])),"\n");
					$ok = 0;
				}
				$temp = "";
				for($i = 1; $i <= 6; $i++){
					$temp .= $chars[$i];
				}
				if($ok == 1){
					if($temp eq "Smash?"){
						print("	Smash? header ok\n");
					}else{
						print("	Error on Smash? header\n");
						$ok = 0;
					}
				}
				if($ok == 1){
					print("Status = 0x".sprintf("%02X",ord($chars[7])));
					if((ord($chars[7]) & 0x01) != 0){
						print(" Con_start,");
					}
					if((ord($chars[7]) & 0x02) != 0){
						print(" sick,");
					}
					print("\n");
					
					print("type = 0x".sprintf("%02X",ord($chars[8]))." ");
					if(ord($chars[8]) == 0x00){
						print("Social ping\n");
					}elsif(ord($chars[8]) == 0x01){
						print("Request dump\n");
					}elsif(ord($chars[8]) == 0x02){
						print("Data dump\n");
					}elsif(ord($chars[8]) == 0x06){
						print("Start quest\n");
					}elsif(ord($chars[8]) == 0x09){
						print("Clear egg\n");
					}elsif(ord($chars[8]) == 0x0A){
						print("Uber\n");
					}elsif(ord($chars[8]) == 0x0B){
						print("End quest\n");
					}else{
						print("unknown packet\n");
					}				
					print("Badge ID = 0x".$bytes[9].$bytes[10]." ");
					if(hex($bytes[9].$bytes[10]) < 0x200){
						print("Standard badge \n");
					}elsif(hex($bytes[9].$bytes[10]) < 0x240){
						print("Speaker or turkey baster\n");
					}elsif(hex($bytes[9].$bytes[10]) < 0x280){
						print("Founder\n");
					}elsif(hex($bytes[9].$bytes[10]) < 0x2A0){
						print("Vendor or bird seed bag\n");
					}elsif(hex($bytes[9].$bytes[10]) < 0x2C0){
						print("Outhouse or port-a-potty\n");
					}elsif(hex($bytes[9].$bytes[10]) < 0x2E0){
						print("Snake oil\n");
					}elsif(hex($bytes[9].$bytes[10]) < 0x2FE){
						print("Necrollamacon\n");
					}elsif(hex($bytes[9].$bytes[10]) == 0x2FE){
						print("Start button\n");
					}elsif(hex($bytes[9].$bytes[10]) == 0x2FF){
						print("Vendo\n");
					}else{
						print("Unknown badge type\n");
					}

					#status byte
					print("	Internal status byte 0x".sprintf("%02X",ord($chars[11]))."\n");
					if((ord($chars[11]) & 0x01) != 0){
						print("		Con started\n");
					}						
					if((ord($chars[11]) & 0x02) != 0){
						print("		Has / Had pink eye\n");
					}						
					if((ord($chars[11]) & 0x04) != 0){
						print("		Pink eye cured\n");
					}						
					if((ord($chars[11]) & 0x08) != 0){
						print("		Has a egg\n");
					}						
					if((ord($chars[11]) & 0x10) != 0){
						print("		Quest started\n");
					}						
					if((ord($chars[11]) & 0x20) != 0){
						print("		Quest done\n");
					}						
					if((ord($chars[11]) & 0x40) != 0){
						print("		Uber!\n");
					}						
					if((ord($chars[11]) & 0x80) != 0){
						print("		Is dead\n");
					}	
					# spent
					print("	Spent ".hex(unpack("H*",$chars[12].$chars[13]))."\n");
					# sick ID
					if((ord($chars[11]) & 0x02) != 0){
						print("	Got sick from 0x".unpack("H*",$chars[14].$chars[15])."\n");
					}
					# egg ID
					if((ord($chars[11]) & 0x08) != 0){
						print("	Got knocked up by 0x".unpack("H*",$chars[16].$chars[17])."\n");
						$egg_idH = $chars[16];
						$egg_idL = $chars[17];
					}
					# button clicks
					print("	Sent ".hex(unpack("H*",$chars[18].$chars[19].$chars[20]))." social pings\n");
					# sleep
					print("	Slept ".hex(unpack("H*",$chars[21].$chars[22].$chars[23]))."s\n");
					# active
					print("	Active ".hex(unpack("H*",$chars[24].$chars[25].$chars[26]))."s\n");
					# Hyper
					print("	Hyper ".hex(unpack("H*",$chars[27].$chars[28].$chars[29]))."s\n");
					# Prego
					print("	Prego ".hex(unpack("H*",$chars[30].$chars[31].$chars[32]))."s\n");
					# died
					print("	Died ".hex(unpack("H*",$chars[33].$chars[34]))." times\n");
					# food
					print("	Got food ".hex(unpack("H*",$chars[35].$chars[36]))." times\n");
					# pooped
					print("	Pooped ".hex(unpack("H*",$chars[37].$chars[38]))." times\n");
					# knocked up
					print("	Got knocked up ".hex(unpack("H*",$chars[39].$chars[40]))." times\n");
					# Quest ID
					if((ord($chars[11]) & 0x10) != 0){
						print("	Got quest item from 0x".unpack("H*",$chars[41].$chars[42])."\n");
					}
					print("	Seen IDs: ");
					for($i = 43; $i <= 138; $i++){
						print(unpack("H*",$chars[$i]));
					}
					print("\n");
					# food
					print("	Food level ".ord($chars[139])." units\n");
					# poop
					print("	Poop level ".ord($chars[140])." units\n");
					#state byte
					print("	State byte 0x".sprintf("%02X",ord($chars[141])).sprintf("%02X",ord($chars[142]))."\n");
					if((ord($chars[141]) & 0x03) == 0){
						print("		Badge is dead or precon\n");
					}elsif((ord($chars[141]) & 0x03) == 1){
						print("		Badge is sleeping\n");
					}elsif((ord($chars[141]) & 0x03) == 2){
						print("		Badge is active\n");
					}else{
						print("		Badge is hyper\n");
					}					
					if((ord($chars[141]) & 0x04) != 0){
						print("		egg led on\n");
					}						
					if((ord($chars[141]) & 0x08) != 0){
						print("		stomach led on\n");
					}						
					if((ord($chars[141]) & 0x10) != 0){
						print("		inc amber logo\n");
					}						
					if((ord($chars[141]) & 0x20) != 0){
						print("		inc red logo\n");
					}						
					if((ord($chars[141]) & 0x40) != 0){
						print("		inc green logo\n");
					}						
					if((ord($chars[141]) & 0x80) != 0){
						print("		inc blue logo\n");
					}	
#					if((ord($chars[135]) & 0x01) != 0){
#						print("		\n");
#					}	
					if((ord($chars[142]) & 0x02) != 0){
						print("		poo led on\n");
					}	


# add checksum check


					$decode = "n";
				}
			
			}
		}
	}
}	


$sph->close();
exit(0);

###########################################################################################################
sub send_packet{
	my $sph = $_[0];
	my $payload = $_[1];
		
	$payload = "Vendo".$payload.chr(0x0D).chr(0x0A);
	sendraw($sph, $payload);

	return();
} # end sub send_packet

###########################################################################################################
sub info{

	print("? = this list\n");
	print("a = send reset\n");
	print("b = send dead to LEDs\n");
	print("c = send beef to LEDs\n");
	print("d = send dispense row 1 col 1\n");
	print("e = send dispense row 2 col 2\n");
	print("f = send dispense row 3 col 3\n");
	print("g = send dispense row 8 col 9\n");
	print("h = send get vendo status\n");
	print("i = send get key buffer\n");
	print("j = send IR request dump\n");
	print("k = send IR set quest for badge 0x02FD\n");
	print("l = send dump IR buffer\n");
	
	print("x = !!EXIT!!\n");

	return();
} #end sub info()

###########################################################################################################
sub sendraw{
	my $sph = $_[0];
	my $raw = $_[1];
	
	
	$count = $sph->write($raw);
	if($count != length($raw)){
		print("Error on send of: ".$raw."\n");
		exit(-1);
	}		
	
	return();
} #end sub sendraw()

###########################################################################################################
sub sendrcv{
	my $sph = $_[0];
	my $raw = $_[1];
	
	my $count = 0;
	my $string = "";
	my $rcvstring = "";
	
	
	print($raw,"\n");
	$count = $sph->write($raw);
	if($count != length($raw)){
		print("Error on send of: ".$raw."\n");
		exit(-1);
	}
	$string = "";
	do{
		($count, $rcvstring) = $sph->read(1);	#actual read
		if($count != 0){
			$string .= $rcvstring;
		}
	}while($count != 0);

	return($string);
} #end sub sendrcv()


###########################################################################################################
# this function configures and opens the serial port. 
# arguments
# 	serial port
# returns
#	serial port handle 
###########################################################################################################
sub open_serial{
	my $serial_port = $_[0];
	
	my $count = 0;
	my $string = "";
	my $serial_handle = "";
	

	print("Opening the serial port ",$serial_port,"\n");
		
	if($^O =~ m/win/i){
		require 5.003;
		use Win32::SerialPort qw( :STAT 0.19 ); #(more info at http://members.aol.com/Bbirthisel/SerialPort.html)
	
		# open the serial port  (more info at http://members.aol.com/Bbirthisel/SerialPort.html)
		$serial_handle = new Win32::SerialPort ($serial_port) || die("Can't open ".$serial_port.": ".$^E."\n");    # actualy opens the serial port
	
		# configure the port
		$serial_handle->baudrate(57600);
		$serial_handle->databits(8);
		$serial_handle->stopbits(1);
		$serial_handle->handshake("none");
		$serial_handle->binary("T");          		# just say Yes (Win 3.x option)
		$serial_handle->parity_enable(0); 
		$serial_handle->parity("none");
		$serial_handle->debug(0);
		$serial_handle->write_char_time(50);	# needed for write timeouts
		$serial_handle->write_const_time(100);	# needed for write timeouts
		$serial_handle->read_interval(100);    # needed for read timeouts max time between read char (milliseconds)
		$serial_handle->read_char_time(5);     	# needed for read timeouts avg time between read char
		$serial_handle->read_const_time(100);  # needed for read timeouts total = (avg * bytes) + const 
		$serial_handle->buffers(4096, 4096);
		$serial_handle->write_settings;			# actualy use the settings above	
	}else{
		print("Error unsupported OS detected got: ",$^O,"\n");
		exit(-1);
	}

#	$serial_handle->rts_active(0) || die("Error setting RTS\n"); # 1 = RTS to V+ (tristate), 0 = RTS to V- (drive)

	#flush serial port buffers
	#$string = "                 "; 		# 17 garbage chars at start are to just flush out port
	#$count = $serial_handle->write($string); 		# actual send of data
	#if(length($string) != $count){ 			# error check send fail if bad
	#	print("Error send failed!!\n",$count," Sent out of ",length($string),"\n");
	#	exit(-1);
	#}

	# this code clears the read buffer (just read all the chars in until its empty)
	$count = 1;		# inital value to start while loop
	while ($count == 1){						
		($count, $string) = $serial_handle->read(1);	# read 1 byte 
	#	print($string);
	}

#	$serial_handle->rts_active(1) || die("Error setting RTS\n"); # 1 = RTS to V+ (tristate), 0 = RTS to V- (drive)
	
	return($serial_handle);
} # end sub open_serial()