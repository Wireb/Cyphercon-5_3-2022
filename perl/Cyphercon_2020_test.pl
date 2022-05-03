

use Term::ReadKey;
#ReadMode 4; # Turn off controls keys
#ReadMode 0; # Reset tty mode before exiting


my $port = "com6";

if(join(" ",@ARGV) =~ m/(com\d+)(\s|$)/i){
	$port = $1;
}

$sph = &open_serial($port);
$| = 1; # autoflush

$seq = 0;
@bytes = ();

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
		print("\nsending start of con\n");
		send_packet($sph, chr(0x01).chr(0x00).chr(0x02).chr(0xFE)); # status, type, badge id x2, data
	}
	if($key eq "b"){
		print("\nsending sick flag\n");
		sendraw($sph, "Smash?".chr(0x02).chr(0x00).chr(0x00).chr(0x01).chr(0xC2));
	}
	if($key eq "c"){
		print("\nsending start of normal\n");
		send_packet($sph, chr(0x00).chr(0x00).chr(0x00).chr(0x00)); # status, type, badge id x2, data
	}
	if($key eq "d"){
		print("\nsending end of normal\n");
		sendraw($sph, "Smash?".chr(0x00).chr(0x00).chr(0x01).chr(0xFF).chr(0xC5));
	}
	if($key eq "e"){
		print("\nsending start of speaker\n");
		sendraw($sph, "Smash?".chr(0x00).chr(0x00).chr(0x02).chr(0x00).chr(0xC3));
	}
	if($key eq "f"){
		print("\nsending end of speaker\n");
		sendraw($sph, "Smash?".chr(0x00).chr(0x00).chr(0x02).chr(0x3F).chr(0x84));
	}
	if($key eq "g"){
		print("\nsending start of founder\n");
		sendraw($sph, "Smash?".chr(0x00).chr(0x00).chr(0x02).chr(0x40).chr(0x83));
	}
	if($key eq "h"){
		print("\nsending end of founder\n");
		sendraw($sph, "Smash?".chr(0x00).chr(0x00).chr(0x02).chr(0x7F).chr(0x44));
	}
	if($key eq "i"){
		print("\nsending start of vendor\n");
		send_packet($sph, chr(0x00).chr(0x00).chr(0x02).chr(0x80)); # status, type, badge id x2, data
	}
	if($key eq "j"){
		print("\nsending end of vendor\n");
		sendraw($sph, "Smash?".chr(0x00).chr(0x00).chr(0x02).chr(0x9F).chr(0x24));
	}
	if($key eq "k"){
		print("\nsending start of outhouse\n");
		sendraw($sph, "Smash?".chr(0x00).chr(0x00).chr(0x02).chr(0xA0).chr(0x23));
	}
	if($key eq "l"){
		print("\nsending end of outhouse\n");
		sendraw($sph, "Smash?".chr(0x00).chr(0x00).chr(0x02).chr(0xBF).chr(0x04));
	}
	if($key eq "m"){
		print("\nsending start of snake oil\n");
		sendraw($sph, "Smash?".chr(0x00).chr(0x00).chr(0x02).chr(0xC0).chr(0x03));
	}
	if($key eq "n"){
		print("\nsending end of snake oil\n");
		sendraw($sph, "Smash?".chr(0x00).chr(0x00).chr(0x02).chr(0xDF).chr(0xE4));
	}
	if($key eq "o"){
		print("\nsending start of necrollamacon\n");
		sendraw($sph, "Smash?".chr(0x00).chr(0x00).chr(0x02).chr(0xE0).chr(0xE3));
	}
	if($key eq "p"){
		print("\nsending end of necrollamacon\n");
		sendraw($sph, "Smash?".chr(0x00).chr(0x00).chr(0x02).chr(0xFE).chr(0xC5));
	}
	if($key eq "q"){
		print("\nsending start of vendo\n");
		send_packet($sph, chr(0x00).chr(0x00).chr(0x02).chr(0xFF));
	}
	if($key eq "r"){
		print("\nsending request dump from vendo\n");
		send_packet($sph, chr(0x00).chr(0x01).chr(0x02).chr(0xFF)); # status, type, badge id x2, data
	}
	if($key eq "s"){
		print("\nsending request dump from 0x0012\n");
		send_packet($sph, chr(0x00).chr(0x01).chr(0x00).chr(0x12)); # status, type, badge id x2, data
	}
	if($key eq "t"){
		print("\nsending clear egg to badge 0x",unpack("H*",$badge_idH.$badge_idL)," for egg id 0x",unpack("H*",$egg_idH.$egg_idL),"\n");
		send_packet($sph, chr(0x00).chr(0x09).chr(0x02).chr(0xFF).$badge_idH.$badge_idL.$egg_idH.$egg_idL); # status, type, badge id x2, data
	}
	if($key eq "u"){
		print("\nsending clear badge\n");
		send_packet($sph, chr(0x00).chr(0xde).chr(0xad).chr(0xbe).chr(0xef).chr(0x29).chr(0xd6).chr(0xa2)); # status, type, badge id x2, data
	}
	if($key eq "v"){
		print("\nsending uber to badge 0x",unpack("H*",$badge_idH.$badge_idL),"\n");
		send_packet($sph, chr(0x00).chr(0x0A).chr(0x02).chr(0xFF).$badge_idH.$badge_idL); # status, type, badge id x2, data
	}
	if($key eq "w"){
		print("\nsending start quest to badge 0x",unpack("H*",$badge_idH.$badge_idL),"\n");
		send_packet($sph, chr(0x00).chr(0x06).chr(0x02).chr(0xFF).$badge_idH.$badge_idL); # status, type, badge id x2, data
	}
	if($key eq "x"){
		print("got x exiting\n");
		$sph->close();
		exit(0);
	}
	if($key eq "y"){
		print("\nsending end quest to badge 0x",unpack("H*",$badge_idH.$badge_idL),"\n");
		send_packet($sph, chr(0x00).chr(0x0B).chr(0x02).chr(0xFF).$badge_idH.$badge_idL); # status, type, badge id x2, data
	}
	if($key eq "z"){
		print("\nsending string of nulls to reset badge state\n");
		sendraw($sph, chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00).chr(0x00));
	}
	if($key eq "A"){
		print("\nsending request 0x80 food to badge 0x",unpack("H*",$badge_idH.$badge_idL),"\n");
		send_packet($sph, chr(0x00).chr(0x07).chr(0x02).chr(0xFF).$badge_idH.$badge_idL.chr(0x80)); # status, type, badge id x2, data
	}
	if($key eq "B"){
		print("\nsending request 0x10 food to badge 0x",unpack("H*",$badge_idH.$badge_idL),"\n");
		send_packet($sph, chr(0x00).chr(0x07).chr(0x02).chr(0xFF).$badge_idH.$badge_idL.chr(0x10)); # status, type, badge id x2, data
	}
	if($key eq "C"){
		print("\nsending spend 0x01 credit request to badge 0x",unpack("H*",$badge_idH.$badge_idL)," once = 0x",unpack("H*",$onceH.$onceL),"\n");
		# build up credit packet
		$creditH = chr(0x00);
		$creditL = chr(0x01);
		$vonceH = chr(int(rand(255)));
		$vonceM = chr(int(rand(255)));
		$vonceL = chr(int(rand(255)));
		print("	Packet contents:\n");
		print("		0x".unpack("H*",$badge_idH.$badge_idL)," badge ID\n");
		print("		0x".unpack("H*",$onceH.$onceL)," badge ONCE\n");
		print("		0x".unpack("H*",$creditH.$creditL)," requested credits\n");
		print("		0x".unpack("H*",$vonceH.$vonceM.$vonceL)," vendo ONCE\n");
		$checksum = ord($badge_idH) + ord($badge_idL) + ord($onceH) + ord($onceL) + ord($creditH) + ord($creditL) + ord($vonceH) + ord($vonceM) + ord($vonceL);
		$checksum = chr((256 - $checksum & 0xFF) & 0xFF);	# convert to zero sum		
		print("		0x".unpack("H*",$checksum)," checksum\n");		
		@crypt = ($badge_idH,$badge_idL,$onceH,$onceL,$creditH,$creditL,$vonceH,$vonceM,$vonceL,$checksum);	
		$temp = &crypt(unpack("H*",$badge_idH.$badge_idL), \@crypt);
			# badge id in hex (for key lookup), data to encrypt			
		send_packet($sph, chr(0x00).chr(0x03).chr(0x02).chr(0xFF).join("",@{$temp})); # status, type, data
	}	
	if($key eq "D"){
		print("\nsending spend 0x02 credit request to badge 0x",unpack("H*",$badge_idH.$badge_idL)," once = 0x",unpack("H*",$onceH.$onceL),"\n");
		# build up credit packet
		$creditH = chr(0x00);
		$creditL = chr(0x02);
		$vonceH = chr(int(rand(255)));
		$vonceM = chr(int(rand(255)));
		$vonceL = chr(int(rand(255)));
		print("	Packet contents:\n");
		print("		0x".unpack("H*",$badge_idH.$badge_idL)," badge ID\n");
		print("		0x".unpack("H*",$onceH.$onceL)," badge ONCE\n");
		print("		0x".unpack("H*",$creditH.$creditL)," requested credits\n");
		print("		0x".unpack("H*",$vonceH.$vonceM.$vonceL)," vendo ONCE\n");
		$checksum = ord($badge_idH) + ord($badge_idL) + ord($onceH) + ord($onceL) + ord($creditH) + ord($creditL) + ord($vonceH) + ord($vonceM) + ord($vonceL);
		$checksum = chr((256 - $checksum & 0xFF) & 0xFF);	# convert to zero sum		
		print("		0x".unpack("H*",$checksum)," checksum\n");		
		@crypt = ($badge_idH,$badge_idL,$onceH,$onceL,$creditH,$creditL,$vonceH,$vonceM,$vonceL,$checksum);		
		$temp = &crypt(unpack("H*",$badge_idH.$badge_idL), \@crypt);
			# badge id in hex (for key lookup), data to encrypt			
		send_packet($sph, chr(0x00).chr(0x03).chr(0x02).chr(0xFF).join("",@{$temp})); # status, type, data
	}	
	if($key eq "E"){
		print("\nsending set Hyr0n to 0x0005\n");
		send_packet($sph, chr(0x00).chr(0x05).chr(0x02).chr(0xFF).chr(0x00).chr(0x05)); # status, type, badge id x2, data
	}
	if($key eq "F"){
		print("\nsending Social ping from 0x0005 clear status\n");
		send_packet($sph, chr(0x00).chr(0x00).chr(0x00).chr(0x05)); # status, type, badge id x2, data
	}
	if($key eq "G"){
		print("\nsending mine? from 0x0006 clear status\n");
		send_packet($sph, chr(0x00).chr(0x0C).chr(0x00).chr(0x06)); # status, type, badge id x2, data
	}
	
	
	($count, $rcvstring) = $sph->read(1);	#actual read
	if($count != 0){
		#print($rcvstring);
		print(unpack("H*",$rcvstring));
		if(unpack("H*",$rcvstring) eq "0a"){
			print("\n");
		}
		
		foreach $char(split("", $rcvstring)){
			if($seq == 0 && $char eq "S"){
				#print("  seq0\n");
				$seq++;
				$checksum = ord($char);
				#print("\nFound S\n");
			}elsif($seq == 1 && $char eq "m"){
				$seq++;
				$checksum += ord($char);
			}elsif($seq == 2 && $char eq "a"){
				$seq++;
				$checksum += ord($char);
			}elsif($seq == 3 && $char eq "s"){
				$seq++;
				$checksum += ord($char);
			}elsif($seq == 4 && $char eq "h"){
				$seq++;
				$checksum += ord($char);
			}elsif($seq == 5 && $char eq "?"){
				#print("  seq5\n");			
				$seq++;
				$checksum += ord($char);
			}elsif($seq == 6){	# status
				#print("  seq6 (status)\n");
				$bytes[0] = $char;
				$seq++;
				$checksum += ord($char);
				#print("\nFound Status\n");
			}elsif($seq == 7){	# type
				#print("  seq7 (type)\n");
				$bytes[1] = $char;
				$seq++;
				$checksum += ord($char);				
				if(ord($char) == 0x00){
					$data = 9999;
				}elsif(ord($char) == 0x01){
					$data = 9999;
				}elsif(ord($char) == 0x02){
					$data = 134;
					$cnt = 4;
				}elsif(ord($char) == 0x03){
					$data = 10;
					$cnt = 4;
				}elsif(ord($char) == 0x04){
					$data = 10;
					$cnt = 4;
				}elsif(ord($char) == 0x05){
					$data = 2;
					$cnt = 4;					
				}elsif(ord($char) == 0x06){
					$data = 2;
					$cnt = 4;
				}elsif(ord($char) == 0x07){
					$data = 3;
					$cnt = 4;
				}elsif(ord($char) == 0x08){
					$data = 1;
					$cnt = 4;
				}elsif(ord($char) == 0x09){
					$data = 4;
					$cnt = 4;
				}elsif(ord($char) == 0x0A){
					$data = 2;
					$cnt = 4;
				}elsif(ord($char) == 0x0B){
					$data = 2;
					$cnt = 4;
				}elsif(ord($char) == 0x0C){
					$data = 9999;
					$cnt = 4;
				}else{
					$seq = 0;
				}
			}elsif($seq == 8){	# badge ID
				$bytes[2] = unpack("H*",$char);
				if(ord($bytes[1]) == 0x02){
					$badge_idH = $char;
				}
				$seq++;
				$checksum += ord($char);
			}elsif($seq == 9){	# badge ID
				#print("  seq9 (badge ID)\n");
				$bytes[3] = unpack("H*",$char);
				if(ord($bytes[1]) == 0x02){
					$badge_idL = $char;
				}
				$seq++;
				$checksum += ord($char);
				#print("\nFound badge ID\n");

			}elsif($data < 9999 && $seq == 10){	# data
				$bytes[$cnt] = $char;
				$checksum += ord($char);
				$cnt++;
				$data--;
				if($data == 0){
					$seq++;
				}
			}elsif(($data >= 9999 && $seq == 10) || ($data < 9999 && $seq == 11)){	#checksum (end of packet)
				#print("  seq10/11 (checksum)\n");
				#print("\n".unpack("H*",$char)."\n");
				$seq = 0;
				$checksum += ord($char);
				$checksum = $checksum & 0xFF;
				print("\n");
				print("Status = 0x".sprintf("%02X",ord($bytes[0])));
				if((ord($bytes[0]) & 0x01) != 0){
					print(" Con_start,");
				}
				if((ord($bytes[0]) & 0x02) != 0){
					print(" sick,");
				}
				print("\n");
				print("type = 0x".sprintf("%02X",ord($bytes[1]))." ");
				if(ord($bytes[1]) == 0x00){
					print("Social ping\n");
				}elsif(ord($bytes[1]) == 0x01){
					print("Request dump\n");
				}elsif(ord($bytes[1]) == 0x02){
					print("Data dump\n");
				}elsif(ord($bytes[1]) == 0x03){
					print("Request credits\n");
				}elsif(ord($bytes[1]) == 0x04){
					print("Confirm credits\n");
				}elsif(ord($bytes[1]) == 0x05){
					print("HBDH\n");				
				}elsif(ord($bytes[1]) == 0x06){
					print("Start quest\n");
				}elsif(ord($bytes[1]) == 0x07){
					print("Request food\n");
				}elsif(ord($bytes[1]) == 0x08){
					print("Confirm food\n");
				}elsif(ord($bytes[1]) == 0x09){
					print("Clear egg\n");
				}elsif(ord($bytes[1]) == 0x0A){
					print("Uber\n");
				}elsif(ord($bytes[1]) == 0x0B){
					print("End quest\n");
				}elsif(ord($bytes[1]) == 0x0C){
					print("mine?\n");
				}else{
					print("unknown packet\n");
				}				
				print("Badge ID = 0x".$bytes[2].$bytes[3]." / ".hex($bytes[2].$bytes[3])." ");
				if(hex($bytes[2].$bytes[3]) < 0x200){
					print("Standard badge \n");
				}elsif(hex($bytes[2].$bytes[3]) < 0x240){
					print("Speaker or turkey baster\n");
				}elsif(hex($bytes[2].$bytes[3]) < 0x280){
					print("Founder\n");
				}elsif(hex($bytes[2].$bytes[3]) < 0x2A0){
					print("Vendor or bird seed bag\n");
				}elsif(hex($bytes[2].$bytes[3]) < 0x2C0){
					print("Outhouse or port-a-potty\n");
				}elsif(hex($bytes[2].$bytes[3]) < 0x2E0){
					print("Snake oil\n");
				}elsif(hex($bytes[2].$bytes[3]) < 0x2FE){
					print("Necrollamacon\n");
				}elsif(hex($bytes[2].$bytes[3]) == 0x2FE){
					print("Start button\n");
				}elsif(hex($bytes[2].$bytes[3]) == 0x2FF){
					print("Vendo\n");
				}else{
					print("Unknown badge type\n");
				}
				print("Checksum = 0x".sprintf("%02X",$checksum)." ");
				if($checksum == 0){
					print("[ok]\n");
				}else{
					print("[bad]\n");
				}
				if(ord($bytes[1]) == 0x02 && $checksum == 0){
					print("Dump decode\n");
					#status byte
					print("	Status byte 0x".sprintf("%02X",ord($bytes[4]))."\n");
					if((ord($bytes[4]) & 0x01) != 0){
						print("		Con started\n");
					}						
					if((ord($bytes[4]) & 0x02) != 0){
						print("		Has / Had pink eye\n");
					}						
					if((ord($bytes[4]) & 0x04) != 0){
						print("		Pink eye cured\n");
					}						
					if((ord($bytes[4]) & 0x08) != 0){
						print("		Has a egg\n");
					}						
					if((ord($bytes[4]) & 0x10) != 0){
						print("		Quest started\n");
					}						
					if((ord($bytes[4]) & 0x20) != 0){
						print("		Quest done\n");
					}						
					if((ord($bytes[4]) & 0x40) != 0){
						print("		Uber!\n");
					}						
					if((ord($bytes[4]) & 0x80) != 0){
						print("		Is dead\n");
					}	
					# spent
					print("	Spent ".hex(unpack("H*",$bytes[5].$bytes[6]))."\n");
					$spent = hex(unpack("H*",$bytes[5].$bytes[6]));
					# sick ID
					if((ord($bytes[4]) & 0x02) != 0){
						print("	Got sick from 0x".unpack("H*",$bytes[7].$bytes[8])."\n");
					}
					# egg ID
					if((ord($bytes[4]) & 0x08) != 0){
						print("	Got knocked up by 0x".unpack("H*",$bytes[9].$bytes[10])."\n");
						$egg_idH = $bytes[9];
						$egg_idL = $bytes[10];
					}
					# button clicks
					print("	Sent ".hex(unpack("H*",$bytes[11].$bytes[12].$bytes[13]))." social pings\n");
					# sleep
					print("	Slept ".hex(unpack("H*",$bytes[14].$bytes[15].$bytes[16]))."s\n");
					# active
					print("	Active ".hex(unpack("H*",$bytes[17].$bytes[18].$bytes[19]))."s\n");
					# Hyper
					print("	Hyper ".hex(unpack("H*",$bytes[20].$bytes[21].$bytes[22]))."s\n");
					# Prego
					print("	Prego ".hex(unpack("H*",$bytes[23].$bytes[24].$bytes[25]))."s\n");
					# died
					print("	Died ".hex(unpack("H*",$bytes[26].$bytes[27]))." times\n");
					# food
					print("	Got food ".hex(unpack("H*",$bytes[28].$bytes[29]))." times\n");
					# pooped
					print("	Pooped ".hex(unpack("H*",$bytes[30].$bytes[31]))." times\n");
					# knocked up
					print("	Got knocked up ".hex(unpack("H*",$bytes[32].$bytes[33]))." times\n");
					# Quest ID
					if((ord($bytes[4]) & 0x10) != 0){
						print("	Got quest item from 0x".unpack("H*",$bytes[34].$bytes[35])."\n");
					}
					print("	Seen IDs: ");
					$credits = 0;
					for($i = 36; $i <= 131; $i++){
						print(unpack("H*",$bytes[$i]));
						foreach $temp(split("",unpack("b*",$bytes[$i]))){
							if($temp == 1){
								$credits++;
							}
						}
					}
					print("\n");
					print("	Badge has:\n		Seen ".$credits." other badges\n		Has spent ".$spent."\n		".($credits - $spent)." credits left.\n");
					# food
					print("	Food level ".ord($bytes[132])." units\n");
					# poop
					print("	Poop level ".ord($bytes[133])." units\n");
					#state byte
					print("	State byte 0x".sprintf("%02X",ord($bytes[134])).sprintf("%02X",ord($bytes[135]))."\n");
					if((ord($bytes[134]) & 0x03) == 0){
						print("		Badge is dead or precon\n");
					}elsif((ord($bytes[134]) & 0x03) == 1){
						print("		Badge is sleeping\n");
					}elsif((ord($bytes[134]) & 0x03) == 2){
						print("		Badge is active\n");
					}else{
						print("		Badge is hyper\n");
					}					
					if((ord($bytes[134]) & 0x04) != 0){
						print("		egg led on\n");
					}						
					if((ord($bytes[134]) & 0x08) != 0){
						print("		stomach led on\n");
					}						
					if((ord($bytes[134]) & 0x10) != 0){
						print("		inc amber logo\n");
					}						
					if((ord($bytes[134]) & 0x20) != 0){
						print("		inc red logo\n");
					}						
					if((ord($bytes[134]) & 0x40) != 0){
						print("		inc green logo\n");
					}						
					if((ord($bytes[134]) & 0x80) != 0){
						print("		inc blue logo\n");
					}	
					if((ord($bytes[135]) & 0x01) != 0){
						print("		Logo tick\n");
					}	
					if((ord($bytes[135]) & 0x02) != 0){
						print("		poo led on\n");
					}	
					if((ord($bytes[135]) & 0x04) != 0){
						print("		!!PostCon enabled!!\n");
					}	
					if((ord($bytes[135]) & 0x08) != 0){
						print("		egg up\n");
					}	
					# once value
					print("	once = 0x".unpack("H*",$bytes[136].$bytes[137])."\n");
					$onceH = $bytes[136];
					$onceL = $bytes[137];
					
					
					
				}elsif(ord($bytes[1]) == 0x03 && $checksum == 0){
					print("Dump decode\n");
					#target badge	
					print("	Raw string 0x".unpack("H*",$bytes[4].$bytes[5].$bytes[6].$bytes[7].$bytes[8].$bytes[9].$bytes[10].$bytes[11].$bytes[12].$bytes[13])."\n");
					@crypt = ($bytes[4],$bytes[5],$bytes[6],$bytes[7],$bytes[8],$bytes[9],$bytes[10],$bytes[11],$bytes[12],$bytes[13]);
					$temp = &decrypt(unpack("H*",$badge_idH.$badge_idL), \@crypt);
					print("	Packet contents:\n");
					print("		0x".unpack("H*",chr(${$temp}[0]).chr(${$temp}[1]))," badge ID\n");
					print("		0x".unpack("H*",chr(${$temp}[2]).chr(${$temp}[3]))," badge ONCE\n");
					print("		0x".unpack("H*",chr(${$temp}[4]).chr(${$temp}[5]))," requested credits\n");
					print("		0x".unpack("H*",chr(${$temp}[6]).chr(${$temp}[7]).chr(${$temp}[8]))," vendo ONCE\n");
					print("		0x".unpack("H*",chr(${$temp}[9]))," checksum\n");
				}elsif(ord($bytes[1]) == 0x04 && $checksum == 0){
					print("Dump decode\n");
					#target badge	
					print("	Raw string 0x".unpack("H*",$bytes[4].$bytes[5].$bytes[6].$bytes[7].$bytes[8].$bytes[9].$bytes[10].$bytes[11].$bytes[12].$bytes[13])."\n");
					@crypt = ($bytes[4],$bytes[5],$bytes[6],$bytes[7],$bytes[8],$bytes[9],$bytes[10],$bytes[11],$bytes[12],$bytes[13]);
					$temp = &decrypt(unpack("H*",$badge_idH.$badge_idL), \@crypt);
					print("	Packet contents:\n");
					print("		0x".unpack("H*",chr(${$temp}[0]).chr(${$temp}[1]))," badge ID\n");
					print("		0x".unpack("H*",chr(${$temp}[2]).chr(${$temp}[3]).chr(${$temp}[4]))," vendo ONCE\n");
					print("		0x".unpack("H*",chr(${$temp}[5]).chr(${$temp}[6]))," requested credits\n");
					print("		0x".unpack("H*",chr(${$temp}[7]).chr(${$temp}[8]))," NOT badge ONCE\n");
					print("		0x".unpack("H*",chr(${$temp}[9]))," checksum\n");
					$checksum = 0;
					for($i = 0; $i < 10; $i++){
						$checksum += ${$temp}[$i];
					}
					if(($checksum & 0xFF) != 0){
						print("	Packet ERROR checksum wrong\n");
					}elsif(chr(${$temp}[0]).chr(${$temp}[1]) ne $badge_idH.$badge_idL){
						print("	Packet ERROR badge ID wrong\n");
					}elsif(chr(${$temp}[2]).chr(${$temp}[3]).chr(${$temp}[4]) ne $vonceH.$vonceM.$vonceL){
						print("	Packet ERROR vendo ONCE wrong\n");
					}elsif(chr(${$temp}[5]).chr(${$temp}[6]) ne $creditH.$creditL){
						print("	Packet ERROR credits requeted wrong\n");
					}elsif(chr(${$temp}[7]) eq $onceH || chr(${$temp}[8]) eq $onceL){
						print("	Packet ERROR badge ONCE matched\n");
					}else{
						print("	Packet all good. Vend the LOOT!!\n");
					}
					
				}elsif(ord($bytes[1]) == 0x06 && $checksum == 0){
					print("Dump decode\n");
					#target badge	
					print("	Target badge 0x".unpack("H*",$bytes[4].$bytes[5])."\n");
				}elsif(ord($bytes[1]) == 0x07 && $checksum == 0){
					print("Dump decode\n");
					#target badge	
					print("	Target badge 0x".unpack("H*",$bytes[4].$bytes[5])."\n");
					print("	Requested 0x".unpack("H*",$bytes[6])." food\n");
				}elsif(ord($bytes[1]) == 0x08 && $checksum == 0){
					print("Dump decode\n");
					#target badge	
					print("	Confirm 0x".unpack("H*",$bytes[4])." food\n");
				}
				
				
				
				print("\n");
			}else{
				# out of sync
				$seq = 0;
			}
			
		}
		
	}
}	

#ffffffffffffffff ffffffffffffffff
#ffffffffffffffff ffffffffffffffff
#ffffffffffffffff ffffffffffffffff
#ffffffffffffffff ffffffffffffffff
#ffffffffffffffff ffffffffffffffff
#ffffffffffffffff ffffffffffffbf00
#0000000000000000 0000000000000000
#0000000000000000 00000000000000de
#ad8157

$sph->close();
exit(0);

###########################################################################################################
sub send_packet{
	my $sph = $_[0];
	my $payload = $_[1];
	
	my @bytes = ();
	my $byte = "";
	my $checksum = 0;
	
	$payload = "Smash?".$payload;
	@bytes = split("", $payload);
	foreach $byte(@bytes){
		$checksum += ord($byte);
	}
	
	$checksum = $checksum & 0xFF;
	$checksum = 0xFF - $checksum + 1;
	
	$payload = $payload.chr($checksum);

	sendraw($sph, $payload);

	return();
} # end sub send_packet


###########################################################################################################
sub decrypt{
	my $badge_id = hex($_[0]);
	my $temp = $_[1];
	
	my @key = ();			# byte array # $const_bbytes long
	my @crypt = @{$temp};	# # $const_bbytes long
	my @keys = ();
	my $line = "";

	# Speck 80 bit key / block constants 
	my $const_wbytes = 5;
	my $const_bbytes = 2 * $const_wbytes;
	my $const_rounds = 26;

	# variables needed
	my $byte_i = 0;
	my $byte_j = 0;
	my $byte_c0 = "";
	my $byte_k0 = "";
	my $int32_ac = 0;
	my $int32_ak = 0;
	
	print("	decrypt data\n		Get badge key\n");	
	open(IN, "<", "./Tymkrs_Cyphercon_2020_keys.txt") or die("Error unable to open ./badge_keys.txt");
	foreach $line(<IN>){
		chomp($line);
		$line =~ s/\s+//gi;
		if($line !~ m/^#/i){
			@parts = split(",", $line);
			$keys[$parts[0]] = $parts[1];
		}
	}
	if(!defined($keys[$badge_id]) || $keys[$badge_id] !~ m/^[a-f0-9]{20}$/i){
		print("Error key for badge ".$badge_id." missing or corrupt\n");
		exit(-1);
	}
	#print("		key = ".$keys[$badge_id]."\n");
	$keys[$badge_id] =~ s/0x//i;
	print("		key = ".$keys[$badge_id]."\n");
	@parts = split("", $keys[$badge_id]);
	for($i = 0; $i < length($keys[$badge_id]); $i += 2){
		$key[$i/2] = hex($parts[$i].$parts[$i+1]);	
	}
	
	#######################################
	### NOTE the @key and @crypt arrays will get scrambled as part of this function
	#######################################

	#convert from char to decimal values (perl thing)
	for($byte_i = 0; $byte_i < scalar(@crypt); $byte_i++){
		$crypt[$byte_i] = ord($crypt[$byte_i]);
	}

	print("		key     = ");
	&print_array(\@key);
	print("		input   = ");
	&print_array(\@crypt);

	# cycle key
	for ($byte_i = 0; $byte_i < $const_rounds; $byte_i++){
		$byte_k0 = $key[0 + $const_wbytes];
		$int32_ak = 0;

		for ($byte_j = 0; $byte_j < $const_wbytes-1; $byte_j++) {
			$int32_ak += $key[$byte_j] + $key[$byte_j + 1 + $const_wbytes];
			$key[$byte_j + $const_wbytes] = ($int32_ak);
			$key[$byte_j + $const_wbytes] = $key[$byte_j + $const_wbytes] & 0xFF;	# only needed due to perl not having byte vars
			$int32_ak = $int32_ak >> 8;
		}
		$int32_ak += $key[$const_wbytes - 1] + $byte_k0;
		$key[$const_wbytes - 1 + $const_wbytes] = $int32_ak;
		$key[$const_wbytes - 1 + $const_wbytes] = $key[$const_wbytes - 1 + $const_wbytes] & 0xFF;	# only needed due to perl not having byte vars
		$key[$const_wbytes] = $key[$const_wbytes] ^ $byte_i;
		$key[$const_wbytes] = $key[$const_wbytes] & 0xFF;	# only needed due to perl not having byte vars
		$byte_k0 = $key[$const_wbytes - 1];
		for ($byte_j = $const_wbytes-1; $byte_j > 0; $byte_j--) {
			$key[$byte_j] = (($key[$byte_j] << 3) | ($key[$byte_j - 1] >> 5)) ^ $key[$byte_j + $const_wbytes];
			$key[$byte_j] = $key[$byte_j] & 0xFF;	# only needed due to perl not having byte vars
		}
		$key[0] = (($key[0] << 3) | ($byte_k0 >> 5)) ^ $key[0 + $const_wbytes];
		$key[0] = $key[0] & 0xFF;	# only needed due to perl not having byte vars
	}

	#print("mutated     =  ");
	#&print_array(\@key);


	# start decrypt 
	for ($byte_i = $const_rounds - 1; $byte_i >= 0; $byte_i--){
		for($byte_j = 0; $byte_j < $const_wbytes; $byte_j++){
			$key[$byte_j] = $key[$byte_j] ^ $key[$byte_j + $const_wbytes];
			$crypt[$byte_j] = $crypt[$byte_j] ^ $crypt[$byte_j + $const_wbytes];
		}
		
		$byte_k0 = $key[0];
		$byte_c0 = $crypt[0];
		for($byte_j = 0; $byte_j < $const_wbytes - 1; $byte_j++) {
			$key[$byte_j] = (($key[$byte_j] >> 3) | ($key[$byte_j + 1] << 5));
			$key[$byte_j] = $key[$byte_j] & 0xFF;	# only needed due to perl not having byte vars
			$crypt[$byte_j] = (($crypt[$byte_j] >> 3) | ($crypt[$byte_j + 1] << 5));
			$crypt[$byte_j] = $crypt[$byte_j] & 0xFF;	# only needed due to perl not having byte vars
		}
		
		$key[$const_wbytes - 1] = (($key[$const_wbytes - 1] >> 3) | ($byte_k0 << 5));
		$key[$const_wbytes - 1] = $key[$const_wbytes - 1] & 0xFF;	# only needed due to perl not having byte vars
		$crypt[$const_wbytes - 1] = (($crypt[$const_wbytes - 1] >> 3) | ($byte_c0 << 5));
		$crypt[$const_wbytes - 1] = $crypt[$const_wbytes - 1] & 0xFF;	# only needed due to perl not having byte vars
		$key[0 + $const_wbytes] = $key[0 + $const_wbytes] ^ $byte_i;
		$key[0 + $const_wbytes] = $key[0 + $const_wbytes] & 0xFF;	# only needed due to perl not having byte vars

		for($byte_j = 0; $byte_j < $const_wbytes; $byte_j++) {
			$crypt[$byte_j + $const_wbytes] = $crypt[$byte_j + $const_wbytes] ^ $key[$byte_j];
			$crypt[$byte_j + $const_wbytes] = $crypt[$byte_j + $const_wbytes] & 0xFF;	# only needed due to perl not having byte vars
		}
		
		$int32_ak = 0;
		$int32_ac = 0;
		for($byte_j = 0; $byte_j < $const_wbytes; $byte_j++) {
			$int32_ak += $key[$byte_j + $const_wbytes] - $key[$byte_j];
			$key[$byte_j + $const_wbytes] = $int32_ak;
			$key[$byte_j + $const_wbytes] = $key[$byte_j + $const_wbytes] & 0xFF;	# only needed due to perl not having byte vars
			$int32_ak = $int32_ak >> 8;
				
			$int32_ac += $crypt[$byte_j + $const_wbytes] - $crypt[$byte_j];
			$crypt[$byte_j + $const_wbytes] = $int32_ac;
			$crypt[$byte_j + $const_wbytes] = $crypt[$byte_j + $const_wbytes] & 0xFF;	# only needed due to perl not having byte vars
			$int32_ac = $int32_ac >> 8;
		}

		$byte_k0 = $key[$const_wbytes - 1 + $const_wbytes];
		$byte_c0 = $crypt[$const_wbytes - 1 + $const_wbytes];	
		for($byte_j = $const_wbytes - 1; $byte_j > 0; $byte_j--) {
			$key[$byte_j + $const_wbytes] = $key[$byte_j - 1 + $const_wbytes];
			$crypt[$byte_j + $const_wbytes] = $crypt[$byte_j - 1 + $const_wbytes];
		}
		$key[0 + $const_wbytes] = $byte_k0;
		$crypt[0 + $const_wbytes] = $byte_c0;
	}

	print("		decrypt = ");
	&print_array(\@crypt);
	
	return(\@crypt);
	
} # end sub decrypt()
	
###########################################################################################################
sub crypt{
	my $badge_id = hex($_[0]);
	my $temp = $_[1];
	
	my @key = ();			# byte array # $const_bbytes long
	my @crypt = @{$temp};	# # $const_bbytes long
	my @keys = ();
	my $line = "";

	# Speck 80 bit key / block constants 
	my $const_wbytes = 5;
	my $const_bbytes = 2 * $const_wbytes;
	my $const_rounds = 26;

	# variables needed
	my $byte_i = 0;
	my $byte_j = 0;
	my $byte_c0 = "";
	my $byte_k0 = "";
	my $int32_ac = 0;
	my $int32_ak = 0;


	print("	encrypt data\n		Get badge key\n");	
	open(IN, "<", "./Tymkrs_Cyphercon_2020_keys.txt") or die("Error unable to open ./badge_keys.txt");
	foreach $line(<IN>){
		chomp($line);
		$line =~ s/\s+//gi;
		if($line !~ m/^#/i){
			@parts = split(",", $line);
			$keys[$parts[0]] = $parts[1];
		}
	}
	if(!defined($keys[$badge_id]) || $keys[$badge_id] !~ m/^[a-f0-9]{20}$/i){
		print("Error key for badge ".$badge_id." missing or corrupt\n");
		exit(-1);
	}
	print("		key = ".$keys[$badge_id]."\n");
	$keys[$badge_id] =~ s/0x//i;
	@parts = split("", $keys[$badge_id]);
	for($i = 0; $i < length($keys[$badge_id]); $i += 2){
		$key[$i/2] = hex($parts[$i].$parts[$i+1]);	
	}
	
	#######################################
	### NOTE the @key and @crypt arrays will get scrambled as part of this function
	#######################################

	#convert from char to decimal values (perl thing)
	for($byte_i = 0; $byte_i < scalar(@crypt); $byte_i++){
		$crypt[$byte_i] = ord($crypt[$byte_i]);
	}

	print("		key   = ");
	&print_array(\@key);
	print("		input = ");
	&print_array(\@crypt);

	
	for ($byte_i = 0; $byte_i < $const_rounds; $byte_i++){
		$byte_c0 = $crypt[0 + $const_wbytes];
		$byte_k0 = $key[0 + $const_wbytes];
		$int32_ac = 0;
		$int32_ak = 0;
			
		for ($byte_j = 0; $byte_j < $const_wbytes-1; $byte_j++) {
			$int32_ac += $crypt[$byte_j] + $crypt[($byte_j + 1) + $const_wbytes]; 
			$crypt[$byte_j + $const_wbytes] = $int32_ac ^ $key[$byte_j]; 		
			$crypt[$byte_j + $const_wbytes] = $crypt[$byte_j + $const_wbytes] & 0xFF;	# only needed due to perl not having byte vars
			$int32_ac = $int32_ac >> 8;
			
			$int32_ak += $key[$byte_j] + $key[($byte_j + 1) + $const_wbytes]; 
			$key[$byte_j + $const_wbytes] = $int32_ak;
			$key[$byte_j + $const_wbytes] = $key[$byte_j + $const_wbytes] & 0xFF;	# only needed due to perl not having byte vars
			$int32_ak = $int32_ak >> 8;
		}

		$int32_ac += $crypt[$const_wbytes-1] + $byte_c0; 
		$crypt[($const_wbytes-1) + $const_wbytes] = $int32_ac ^ $key[$const_wbytes-1];
		$crypt[($const_wbytes-1) + $const_wbytes] = $crypt[($const_wbytes-1) + $const_wbytes] & 0xFF;	# only needed due to perl not having byte vars
		
		$int32_ak += $key[$const_wbytes-1] + $byte_k0; 
		$key[($const_wbytes-1) + $const_wbytes] = $int32_ak;
		$key[($const_wbytes-1) + $const_wbytes] = $key[($const_wbytes-1) + $const_wbytes] & 0xFF;	# only needed due to perl not having byte vars
		$key[$const_wbytes] = $key[$const_wbytes] ^ $byte_i;
		$key[$const_wbytes] = $key[$const_wbytes] & 0xFF;	# only needed due to perl not having byte vars

		$byte_c0 = $crypt[$const_wbytes-1];
		$byte_k0 = $key[$const_wbytes-1];
		for ($byte_j = $const_wbytes-1; $byte_j > 0; $byte_j--){
			$crypt[$byte_j] = ($crypt[$byte_j] << 3 | ($crypt[$byte_j - 1] >> 5)) ^ $crypt[$byte_j + $const_wbytes];
			$crypt[$byte_j] = $crypt[$byte_j] & 0xFF;	# only needed due to perl not having byte vars
			$key[$byte_j] = (($key[$byte_j] << 3) | ($key[($byte_j - 1)] >> 5)) ^ $key[$byte_j + $const_wbytes];
			$key[$byte_j] = $key[$byte_j] & 0xFF;	# only needed due to perl not having byte vars
		}
		$crypt[0] = (($crypt[0] << 3) | ($byte_c0 >> 5)) ^ $crypt[0 + $const_wbytes];
		$crypt[0] = $crypt[0] & 0xFF;	# only needed due to perl not having byte vars
		$key[0] = (($key[0] << 3) | ($byte_k0 >> 5)) ^ $key[0 + $const_wbytes];
		$key[0] = $key[0] & 0xFF;	# only needed due to perl not having byte vars
	}	
	print("		crypt = ");
	&print_array(\@crypt);

	#convert from decimal values to char (perl thing)
	for($byte_i = 0; $byte_i < scalar(@crypt); $byte_i++){
		$crypt[$byte_i] = chr($crypt[$byte_i]);
	}
	
	return(\@crypt);
} # end sub crypt()

###########################################################################################################
sub print_array{
	my $byte_input = $_[0];

	my $byte_i = 0;
	
	print("0x");
	for($byte_i = 0; $byte_i < scalar(@{$byte_input}); $byte_i++){
		print(sprintf("%02X",${$byte_input}[$byte_i]));
	}
	print("\n");
		
	return();
} # end sub print_array()

###########################################################################################################
sub info{

	print("? = this list\n");
	print("a = send social ping from ID 0x02FE (start button) with start of con set\n");
	print("b = send social ping from ID 0x0001 with sick bit set\n");
	print("c = send social ping from ID 0x0000 with clear status\n");
	print("d = send social ping from ID 0x01FF with clear status end of normal\n");
	print("e = send social ping from ID 0x0200 with clear status start of speaker\n");
	print("f = send social ping from ID 0x023F with clear status end of speaker\n");
	print("g = send social ping from ID 0x0240 with clear status start of founder\n");
	print("h = send social ping from ID 0x025F with clear status end of founder\n");
	print("i = send social ping from ID 0x0260 with clear status start of vendor\n");
	print("j = send social ping from ID 0x029F with clear status end of vendor\n");
	print("k = send social ping from ID 0x02A0 with clear status start of outhouse\n");
	print("l = send social ping from ID 0x02BF with clear status end of outhouse\n");
	print("m = send social ping from ID 0x02C0 with clear status start of snake oil\n");
	print("n = send social ping from ID 0x02DF with clear status end of snake oil\n");
	print("o = send social ping from ID 0x02E0 with clear status start of necrollamacon\n");
	print("p = send social ping from ID 0x02FE with clear status end of necrollamacon\n");
	print("q = send social ping from ID 0x02FF with clear status start of vendo\n");
	print("r = send dump request from ID 0x02FF(Vendo) with clear status\n");
	print("s = send dump request from ID 0x0012(Normal) with clear status\n");
	print("t = send clear egg based off last dump return\n");
	print("u = clear badge to defaults\n");
	print("v = send uber\n");
	print("w = start quest\n");	
	print("x = !!EXIT!!\n");
	print("y = end quest\n");	
	print("z = send 0s to get badge and app back in sync\n");
	print("A = send request 0x80 food based off last dump return\n");
	print("B = send request 0x10 food based off last dump return\n");
	print("C = send spend 1 credit based off last dump return\n");
	print("D = send spend 2 credits based off last dump return\n");
	print("E = send set Hyr0n 0x0005\n");
	print("F = send social ping from 0x0005 with clear status\n");
	print("G = send mine? from 0x0006 with clear status\n");

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
		$serial_handle->baudrate(4800);
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