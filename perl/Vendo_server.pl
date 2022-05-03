
use strict;
use warnings;
use Time::HiRes;
use DBI;

my $vendo_serial_sn = "A6006ZRY";
my $vendo_serial_port = "";
my $display_serial_port = "/dev/ttyAMA0";
my $keypad_timeout = 20; 
my $dbfile = "/home/pi/cyphercon2022.db";
my $dsn = "dbi:SQLite:dbname=".$dbfile;
my $db_user = "";
my $db_password = "";
my $dump_dump = 0;
my $key_file = "/home/pi/Tymkrs_Cyphercon_2020_keys.txt";


my @insert_badge_strings = ("insert badge", "Present bird", "Insert Bird", "Vendo Check-in", "Put it in", "don't be scared", "nothing to see here", "are you sure", "is it safe", "give me your eldest");
my @invalid_selection_strings = ("invalid selection", "nope", "negatory", "nopnopnop", "are you even trying", "try again later", "try harder", "back to school", "not quite", "close but no");
my @cost_display_strings = ("credits","bazingas","floppies","telephones","ucks","ducks","bottles of beer","billion dollars","forget me nots");
my @badge_not_loaded_strings = ("Badge not detected","Your missing something","Who are you","What's your number", "PC LOAD LETTER", "You pulled out", "Come back", "Where did you go", "Don't leave me", "You will be back");
my @badge_scan_strings = ("Scan", "Wait", "Read", "Busy"); # limit to 4 char due to no update during scan
my @badge_read_error_strings = ("Error badge communication failed  Unplug and try again");  
my @badge_select_item_strings = ("Select item", "Pick something already", "What do you want", "others are waiting", "lets go", "come on", "chop chop", "decide already", "there's a line"); 
my @insufficient_credits_strings = ("insufficient credits", "No deal", "Trade's off", "Come back when you have more credits", "are you broke", "where's your money", "do i look that cheap", "better luck next time", "need dolla dollas yall", "we don't accept Ious", "You need more friends");
my @quest_not_done_strings = ("Quest not done", "See your spiritual advisor", "The cult is calling", "forget about teh quest","is this a quest", "could this be a quest", "close to a quest", "i quest you", "questerrific");
my @flamingo_strings = ("Why did you do that to that poor flamingo", "flamin go bye bye", "How did you get this number", "destructoflamingo", "That badge has gone the way of the dodo", "bye flamingo bye", "bye bye birdie");
my @coyote_strings = ("Why did you do that to that poor coyote", "coyote go bye bye", "How did you get this number", "destructocoyote", "That badge has gone the way of the dodo", "bye coyote bye", "bye bye birdie");
my @llama_strings = ("Why did you do that to that poor llama", "llama go bye bye", "How did you get this number", "destructollama", "That badge has gone the way of the dodo", "bye llama bye", "bye bye birdie");
my @Parrot_strings = ("Why did you do that to that poor Parrot", "Parrot go bye bye", "How did you get this number", "destructoParrot", "That badge has gone the way of the dodo", "bye Parrot bye", "bye bye birdie");
my @Peacock_strings = ("Why did you do that to that poor Peacock", "Peacock go bye bye", "How did you get this number", "destructoPeacock", "That badge has gone the way of the dodo", "bye Peacock bye", "bye bye birdie");
my @vend_strings = ("Vend", "Poop", "Drop", "Plop", "Whee");


my %vend_inputs = (
	"998001" => 1,
	"ED209" => 2,
	"42" => 3,
	"2125554240" => 4,
	"5558632" => 5,
	"3119362364" => 6,
	"5663" => 7,
	"CHEE5E" => 8,
	"53203" => 9,
	"2" => 10,
	"8675309" => 11,
	"BEE5" => 12,
	"44556767103" => 13,
	"DEADBEEF" => 14,
	"CHE55" => 15,
	"127001" => 16,
	"3125550690" => 17,
	"1" => 18,
	"9" => 19,
	"C2" => 20,
	"2600" => 21,
	"007" => 22,
	"AE35" => 23,
	"6387" => 24,
	"5912535122535" => 25,
	"75" => 26,
	"4152739164" => 27,
	"80" => 28,
	"2375345200" => 29,
	"47688283" => 30,   # necrollamacon
	"101" => 31,
	"7446" => 32,
	"1337" => 33,
	"A310D8D410" => 34, #flamingo
	"U4A102BC10E" => 35, #coyote
	"A473D10D1C" => 36, #llama
	"1086710A20U" => 37, #Parrot
	"101234CDEF" => 38, #Peacock
);

#my @vend_costs = (-6, 75, 75, 50, 75, 30, 75, 10, 10, 10, 30, 100, 100, 20, 100, 10, 75, 25, 10, 10, 75, 75, 10, 50, 30, 75, 100, 30, 10, 30, 200, 50, 50, 65536, -1, -2, -3, -4, -5);
my @vend_costs = (-6, 37, 37, 25, 37, 10, 37,  1,  1,  1, 10,  50,  50, 10,  50,  1, 37, 15,  1,  1, 37, 37,  1, 25, 10, 37,  50, 10,  1, 10,  75, 25, 25, 65536, -1, -2, -3, -4, -5);
my @vend_row = (-6, 1, 2, 0, 4, 2, 1, 4, 2, 1, 4, 3, 2, 2, 3, 2, 3, 3, 3, 3, 3, 4, 0, 2, 4, 1, 4, 3, 4, 4, 4, 3, 0, 1, -1, -2, -3, -4, -5);
my @vend_col = (-6, 4, 4, 0, 0, 6, 3, 3, 1, 0, 2, 0, 5, 3, 1, 2, 4, 8, 5, 3, 2, 4, 1, 0, 7, 2, 6, 6, 5, 1, 8, 7, 2, 1, -1, -2, -3, -4, -5);



my $cmd = "";
my $rc = "";
my $temp = "";
my $line ="";
my $vendo = "";
my %vendo_display = ();
my $vendo_status = 0;
my $keypad_buffer = "";
my $keypad_timer = 0;
my $last_badge_pres_status = 0;
my $retry_cnt = 0;
my $error = 0;
my $cmd_timer = 0;
my $badge_dump = "";
my $display_comm_error = 0;
my @chars = "";
my %badge_info = ();
my $dbh = "";
my $sql = "";
my $i = 0;
my $msg = "";
my $count = 0;
my $sth = "";
my @row = ();
my $found = "";
my $display = "";
my $badge_ready = 0;
my $creditH = 0;
my $creditL = 0;
my $vonceH = 0;
my $vonceM = 0;
my $vonceL = 0;
my $checksum = 0;		
my @crypt = ();
my @keys = ();
my @parts = ();
my $rcvstring = "";
my $whixr_buffer = "";


print("Connect to DB\n");
$dbh = DBI->connect($dsn, $db_user, $db_password, {
   PrintError       => 0,
   RaiseError       => 1,
   AutoCommit       => 1,
});


if(ref($dbh) ne "DBI::db"){
	print("Error unable to connect to DB exiting.\n");
	exit(-1);
}

if(0){
	print("Purge and create tables\n");

	# drop existing tables
	$sql = 'DROP table IF EXISTS badge_data';
	$dbh->do($sql);
	$sql = 'DROP table IF EXISTS spending';
	$dbh->do($sql);
	$sql = 'DROP table IF EXISTS eggs';
	$dbh->do($sql);

	# create badge status table 
	$sql = 'CREATE TABLE badge_data (
		id char(4) PRIMARY KEY,
		active_time char(6),
		ate char(4),
		clicks char(6),
		credits int,
		died char(4),
		egg_from char(4),
		flags char(2),
		food char(2),
		hyper_time char(6),
		interaction_cnt int,
		interactions char(192),
		knocked_up char(4),
		poop char(2),
		pooped char(4),
		prego_time char(6),
		quest_id char(4),
		sick_from char(4),
		sleep_time char(6),
		spent char(4),
		state char(4),
		status char(2),
		flamingo_code bit(1),
		coyote_code bit(1),
		llama_code bit(1),
		Parrot_code bit(1),
		Peacock_code bit(1)
	)';
	$dbh->do($sql);

	#type char(2),
	#once char(4),

	# create spending table
	$sql = 'CREATE TABLE spending (
		ts timestamp NOT NULL default CURRENT_TIMESTAMP,
		id char(4),
		item int,
		cost int
	)';
	$dbh->do($sql);

	# create spending table
	$sql = 'CREATE TABLE eggs (
		id char(4),
		count int
	)';
	$dbh->do($sql);
	
	exit(0);
}
	
print("Loading keys\n");
open(IN, "<", $key_file) or die("Error unable to open ".$key_file);
foreach $line(<IN>){
	chomp($line);
	$line =~ s/\s+//gi;
	if($line !~ m/^#/i){
		@parts = split(",", $line);
		$keys[$parts[0]] = $parts[1];
		#print($parts[0]," = ",$parts[1],"\n");
	}
}
close(IN);


$cmd = "ls /dev/ttyUSB*";
$rc = `$cmd`;
#print($rc,"\n");


print("Finding vendo serial port\n");
foreach $line(split("\n",$rc)){
	#print($line,"\n");
	$cmd = "udevadm info --name=".$line." --attribute-walk | grep ATTRS{serial}";
	$temp = `$cmd`;
	#print($temp,"\n");
	if($temp =~ m/"$vendo_serial_sn"/i){
		print("	Found vendo USB to serial adapter at ".$line."\n");
		$vendo_serial_port = $line;
	}
}
if(! defined($vendo_serial_port) || $vendo_serial_port eq ""){
	print("error vendo serial port with SN ".$vendo_serial_sn." not found exiting\n");
	exit(-1);
}


print("opening ports\n");
$vendo = open_serial($vendo_serial_port, 57600);
$display = open_serial($display_serial_port, 115200);



print("Starting main loop\n");


$vendo_display{"clear"} = 0;
$vendo_display{"string"} = "    ".$insert_badge_strings[0];
$vendo_display{"time"} = 0;
$vendo_display{"delay"} = 0.25;
$vendo_display{"count"} = 0;
$vendo_display{"last"} = "";
$vendo_display{"dp1"} = 0;
$vendo_display{"dp2"} = 0;
$vendo_display{"dp3"} = 0;
$vendo_display{"dp4"} = 0;
$vendo_display{"change"} = 0;
$vendo_display{"another"} = 0;
$vendo_display{"countdown"} = 1;
$vendo_display{"now"} = 0;



while(1){
	# update display
	update_display($vendo, \%vendo_display);
	
	# pick next string to display if counters are up
	if($keypad_buffer ne "" ){
		# do nothing keypad entry screen up
	}elsif($last_badge_pres_status == 1){
		if($display_comm_error == 1 && $vendo_display{"countdown"} == 0){
			$vendo_display{"string"} = "    ".pick_random_string(\@badge_read_error_strings); # 4 char so no scroll
			$vendo_display{"dp1"} = 0;
			$vendo_display{"dp2"} = 0;
			$vendo_display{"dp3"} = 0;
			$vendo_display{"dp4"} = 0;
			$vendo_display{"change"} = 0;
			$vendo_display{"another"} = 0;
			$vendo_display{"countdown"} = 1;			
		}elsif($badge_ready == 1 && $vendo_display{"countdown"} == 0){
			$vendo_display{"string"} = "    ".pick_random_string(\@badge_select_item_strings); # 4 char so no scroll
			$vendo_display{"dp1"} = 0;
			$vendo_display{"dp2"} = 0;
			$vendo_display{"dp3"} = 0;
			$vendo_display{"dp4"} = 0;
			$vendo_display{"change"} = 0;
			$vendo_display{"another"} = 0;
			$vendo_display{"countdown"} = 1;		
		}else{
			# do nothing badge plugged in
			
			
			
		}
		
		
	}elsif($vendo_display{"countdown"} == 0){
		if(int(rand(150)) == 0){
			$vendo_display{"string"} = "    H00100V00";		
			$vendo_display{"dp1"} = 1;
			$vendo_display{"dp2"} = 1;
			$vendo_display{"dp3"} = 1;
			$vendo_display{"dp4"} = 1;
		}else{
			$vendo_display{"string"} = "    ".pick_random_string(\@insert_badge_strings);
			$vendo_display{"dp1"} = 0;
			$vendo_display{"dp2"} = 0;
			$vendo_display{"dp3"} = 0;
			$vendo_display{"dp4"} = 0;
		}
		$vendo_display{"countdown"} = 1;
		$vendo_display{"change"} = 0;
		$vendo_display{"another"} = 0;		
	}
	
	# check if badge is there 
	$vendo_status = check_status($vendo);
	#print("Vendo status: ".$vendo_status."\n");
	
	
	# check keypad
	if(($vendo_status & 0x01) != 0){
		#print("Keypress detected\n");
		$keypad_buffer .= get_keypad($vendo);
		if($keypad_buffer ne ""){
			if($vendo_display{"another"} == 0){
				$vendo_display{"clear"} = 1;
			}
			$vendo_display{"another"} = 1;
			$keypad_timer = time();
			$vendo_display{"string"} = "    ".$keypad_buffer;
			
			# enter (down arrow / Z) pressed?
			if(substr($keypad_buffer, -1, 1) eq "Z"){
				#print($keypad_buffer,"\n");
				chop($keypad_buffer);
				if(defined($vend_inputs{$keypad_buffer}) && $vend_inputs{$keypad_buffer} ne ""){
					#print("Selected item ".$vend_inputs{$keypad_buffer}."\n");
					
					# badge not present
					if($badge_ready != 1){
						if($vend_costs[$vend_inputs{$keypad_buffer}] > 0){
							# items that can be dispensed
							$vendo_display{"string"} = "    ".$vend_costs[$vend_inputs{$keypad_buffer}]." ".pick_random_string(\@cost_display_strings);
							$vendo_display{"countdown"} = 3;  # note +1 due to clear below	
							$vendo_display{"change"} = 1;							
						}elsif($vend_costs[$vend_inputs{$keypad_buffer}] > -6){
							# badge codes
							$vendo_display{"string"} = "    ".pick_random_string(\@badge_not_loaded_strings);
							$vendo_display{"countdown"} = 2;  # note +1 due to clear below	
						}		
					}else{
						# badge present see if conditons met to dispense 
						if($vend_inputs{$keypad_buffer} == 30 && (hex($badge_info{"flags"}) & 0x20) == 0){
							# badge has not completed the quest.... 
							$vendo_display{"string"} = "    ".pick_random_string(\@quest_not_done_strings);
							$vendo_display{"countdown"} = 2;  # note +1 due to clear below
							$vendo_display{"another"} = 0;
							$vendo_display{"clear"} = 1;
							$vendo_display{"now"} = 1;
							$keypad_buffer = "";
							
						}elsif($vend_inputs{$keypad_buffer} == 34){
							$vendo_display{"string"} = "    ".pick_random_string(\@flamingo_strings);
							$vendo_display{"countdown"} = 2;  # note +1 due to clear below
							$vendo_display{"another"} = 0;
							$vendo_display{"clear"} = 1;
							$vendo_display{"now"} = 1;
							$keypad_buffer = "";

							# Update table with info
							$sql = 'UPDATE badge_data SET flamingo_code =  1 WHERE id = \''.$badge_info{"id"}.'\'';
							$dbh->do($sql);

						}elsif($vend_inputs{$keypad_buffer} == 35){
							$vendo_display{"string"} = "    ".pick_random_string(\@coyote_strings);
							$vendo_display{"countdown"} = 2;  # note +1 due to clear below
							$vendo_display{"another"} = 0;
							$vendo_display{"clear"} = 1;
							$vendo_display{"now"} = 1;
							$keypad_buffer = "";

							# Update table with info
							$sql = 'UPDATE badge_data SET coyote_code =  1 WHERE id = \''.$badge_info{"id"}.'\'';
							$dbh->do($sql);

						}elsif($vend_inputs{$keypad_buffer} == 36){
							$vendo_display{"string"} = "    ".pick_random_string(\@llama_strings);
							$vendo_display{"countdown"} = 2;  # note +1 due to clear below
							$vendo_display{"another"} = 0;
							$vendo_display{"clear"} = 1;
							$vendo_display{"now"} = 1;
							$keypad_buffer = "";

							# Update table with info
							$sql = 'UPDATE badge_data SET llama_code =  1 WHERE id = \''.$badge_info{"id"}.'\'';
							$dbh->do($sql);

						}elsif($vend_inputs{$keypad_buffer} == 37){
							$vendo_display{"string"} = "    ".pick_random_string(\@Parrot_strings);
							$vendo_display{"countdown"} = 2;  # note +1 due to clear below
							$vendo_display{"another"} = 0;
							$vendo_display{"clear"} = 1;
							$vendo_display{"now"} = 1;
							$keypad_buffer = "";

							# Update table with info
							$sql = 'UPDATE badge_data SET Parrot_code =  1 WHERE id = \''.$badge_info{"id"}.'\'';
							$dbh->do($sql);

						}elsif($vend_inputs{$keypad_buffer} == 38){
							$vendo_display{"string"} = "    ".pick_random_string(\@Peacock_strings);
							$vendo_display{"countdown"} = 2;  # note +1 due to clear below
							$vendo_display{"another"} = 0;
							$vendo_display{"clear"} = 1;
							$vendo_display{"now"} = 1;
							$keypad_buffer = "";

							# Update table with info
							$sql = 'UPDATE badge_data SET Peacock_code =  1 WHERE id = \''.$badge_info{"id"}.'\'';
							$dbh->do($sql);	
						
						}else{
							
							#print("Item cost = ".$vend_costs[$vend_inputs{$keypad_buffer}]." credits\n");
							#print("Badge has = ".$badge_info{"credits"}." credits\n");
	
							if($vend_costs[$vend_inputs{$keypad_buffer}] <= $badge_info{"credits"} && $vend_costs[$vend_inputs{$keypad_buffer}] > 0 && $vend_row[$vend_inputs{$keypad_buffer}] >= 0 && $vend_col[$vend_inputs{$keypad_buffer}] >= 0){
								#print("Start Crypto\n");
								
								$error = 0;
								
								# build up credit packet
								#print(sprintf("%04X",$vend_costs[$vend_inputs{$keypad_buffer}]),"\n");
								$creditH = chr(hex(substr(sprintf("%04X",$vend_costs[$vend_inputs{$keypad_buffer}]), 0, 2)));
								$creditL = chr(hex(substr(sprintf("%04X",$vend_costs[$vend_inputs{$keypad_buffer}]), 2, 2)));

								$vonceH = chr(int(rand(255)));
								$vonceM = chr(int(rand(255)));
								$vonceL = chr(int(rand(255)));
								#print("	Packet contents:\n");
								#print("		0x".$badge_info{"id"}," badge ID\n");
								#print("		0x".$badge_info{"once"}," badge ONCE\n");
								#print("		0x".unpack("H*",$creditH.$creditL)," requested credits\n");
								#print("		0x".unpack("H*",$vonceH.$vonceM.$vonceL)," vendo ONCE\n");
								$checksum = hex(substr($badge_info{"id"}, 0, 2)) + hex(substr($badge_info{"id"}, 2, 2)) + hex(substr($badge_info{"once"}, 0, 2)) + hex(substr($badge_info{"once"}, 2, 2)) + ord($creditH) + ord($creditL) + ord($vonceH) + ord($vonceM) + ord($vonceL);
								$checksum = chr((256 - $checksum & 0xFF) & 0xFF);	# convert to zero sum		
								#print("		0x".unpack("H*",$checksum)," checksum\n");		
								@crypt = (chr(hex(substr($badge_info{"id"}, 0, 2))),chr(hex(substr($badge_info{"id"}, 2, 2))),chr(hex(substr($badge_info{"once"}, 0, 2))),chr(hex(substr($badge_info{"once"}, 2, 2))),$creditH,$creditL,$vonceH,$vonceM,$vonceL,$checksum);	
								$temp = &crypt($badge_info{"id"}, \@crypt, \@keys);
									# badge id in hex (for key lookup), data to encrypt, array of badge keys

								#print("message length = ",length(join("",@{$temp})),"\n");

								$vendo_display{"string"} = pick_random_string(\@badge_scan_strings); # 4 char so no scroll
								$vendo_display{"clear"} = 1;
								#$vendo_display{"dp1"} = 0;
								$vendo_display{"dp2"} = 0;
								$vendo_display{"dp3"} = 0;
								$vendo_display{"dp4"} = 1;
								$vendo_display{"change"} = 0;
								$vendo_display{"another"} = 0;
								$vendo_display{"now"} = 1;				
								update_display($vendo, \%vendo_display);	# force a update right now
									
								$rc = send_packet($vendo, chr(0x05).chr(0x0B).chr(0x03).join("",@{$temp}));	
									# SPH, ir send command - vendo data len - IR cmd  - data
								if($rc !~ m/^Done\r\n$/){
									print("Warning bad packet detected on send crypto got: ".unpack("H*",$rc)."\n");
									$error = 1;
								}	
								
								#print("Wait for badge to respond\n");
								$cmd_timer = time();
								do{
									$vendo_status = check_status($vendo);	
								}while((time()-$cmd_timer) < 3 && ($vendo_status & 0x02) != 0 && ($vendo_status & 0x04) == 0);
								

								if(($vendo_status & 0x02) == 0 || ($vendo_status & 0x04) == 0){
									print("Error detected in wait for crypto got status ".$vendo_status."\n");
									$error = 1;
								}
								
								if(($vendo_status & 0x04) != 0){
									#print("Dump IR buffer\n");
									$rc = send_packet($vendo, chr(0x06).chr(0x00)); # get IR buffer 1
									if($rc !~ m/\r\nDone\r\n$/){
										print("Warning bad packet detected on get IR buffer got: ".unpack("H*",$rc)."\n");
										$error = 1;
									}		

									if($error == 0){
										#print("check dump packet\n");
										#print("len = ".length($rc)."\n");
										#print(unpack("H*",$rc)."\n");
										
										#len = 154
										#91536d6173683f0102022009000000000200000001000c6200025700012c000f89000000020002000100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008001000000010000800100000000000080010000800100008000000000010000c0d90c05013028790d0a446f6e650d0a
										if(length($rc) == 30){
											#print("\nDecoding badge dump packet\n");
											@chars = split("",$rc);

											if($chars[0] ne chr(0x15)){
												print("Warning packet length incorrect 0x".sprintf("%02X",ord($chars[0])),"\n");
												$error = 1;
											}
											$temp = "";
											if($error == 0){
												for($i = 1; $i <= 6; $i++){
													$temp .= $chars[$i];
												}
												if($temp ne "Smash?"){
													print("Warning error on Smash? header\n");
													$error = 1;
												}
											}
											if($error == 0){
												if($chars[8] ne chr(0x04)){
													print("Warning packet type incorrect 0x".sprintf("%02X",ord($chars[8])),"\n");
													$error = 1;
												}							
											}
										
											if($error == 0){
												$badge_dump = $rc;
												$badge_dump =~ s/^\x15\x53\x6d\x61\x73\x68\x3f....//;
												$badge_dump =~ s/.\x0d\x0a\x44\x6f\x6e\x65\x0d\x0a$//;
											
												#print(unpack("H*",$rc)."\n");
												#print("Returned packet = ",unpack("H*",$badge_dump)."\n");
												
												
												#01040220 daa5425e10aeb6451d4a
												
												@crypt = split("", $badge_dump);
												$temp = &decrypt($badge_info{"id"}, \@crypt, \@keys);
												#print("decrypt = ",unpack("H*",join("",@crypt)),"\n");
												#print("	Packet contents:\n");
												#print("		0x".unpack("H*",chr(${$temp}[0]).chr(${$temp}[1]))," badge ID\n");
												#print("		0x".unpack("H*",chr(${$temp}[2]).chr(${$temp}[3]).chr(${$temp}[4]))," vendo ONCE\n");
												#print("		0x".unpack("H*",chr(${$temp}[5]).chr(${$temp}[6]))," requested credits\n");
												#print("		0x".unpack("H*",chr(${$temp}[7]).chr(${$temp}[8]))," NOT badge ONCE\n");
												#print("		0x".unpack("H*",chr(${$temp}[9]))," checksum\n");
												$checksum = 0;
												for($i = 0; $i < 10; $i++){
													$checksum += ${$temp}[$i];
												}
												if(($checksum & 0xFF) != 0){
													print("	Packet ERROR checksum wrong\n");
													$error = 1;
												}elsif(uc(unpack("H*",chr(${$temp}[0]).chr(${$temp}[1]))) ne uc($badge_info{"id"})){
													print("	Packet ERROR badge ID wrong\n");
													print(unpack("H*",chr(${$temp}[0]).chr(${$temp}[1]))." ne ".$badge_info{"id"}."\n");
													$error = 1;
												}elsif(chr(${$temp}[2]).chr(${$temp}[3]).chr(${$temp}[4]) ne $vonceH.$vonceM.$vonceL){
													print("	Packet ERROR vendo ONCE wrong\n");
													$error = 1;
												}elsif(chr(${$temp}[5]).chr(${$temp}[6]) ne $creditH.$creditL){
													print("	Packet ERROR credits requeted wrong\n");
													$error = 1;
												}elsif(chr(${$temp}[7]) eq chr(hex(substr($badge_info{"once"}, 0, 2))) || chr(${$temp}[8]) eq chr(hex(substr($badge_info{"once"}, 2, 2)))){
													print("	Packet ERROR badge ONCE matched (should be different now)\n");
													$error = 1;
												}else{
												
													print("rescan badge and verify credits taken off\n");
													
													$temp = $badge_info{"credits"};
													$badge_ready = scan_badge(\%vendo_display, $vendo, \%badge_info, $dump_dump, $dbh, \$display_comm_error, $display);
												
													if(($temp - $vend_costs[$vend_inputs{$keypad_buffer}])  == $badge_info{"credits"}){
														print("	Packet all good. Vend the LOOT!! ".$vend_inputs{$keypad_buffer}."\n");
														
														# update the spending table
														$sql = 'INSERT INTO spending (id, item, cost) VALUES(\''.$badge_info{"id"}.'\', \''.$vend_inputs{$keypad_buffer}.'\', \''.$vend_costs[$vend_inputs{$keypad_buffer}].'\')';
														$dbh->do($sql);
														
														### Vend stuff here ###
														$vendo_display{"string"} = pick_random_string(\@vend_strings); # 4 char so no scroll
														$vendo_display{"clear"} = 1;
														$vendo_display{"dp1"} = 0;
														$vendo_display{"dp2"} = 0;
														$vendo_display{"dp3"} = 0;
														$vendo_display{"dp4"} = 0;
														$vendo_display{"change"} = 0;
														$vendo_display{"another"} = 0;
														$vendo_display{"now"} = 1;				
														update_display($vendo, \%vendo_display);	# force a update right now														
														
														print("		".$vend_row[$vend_inputs{$keypad_buffer}]." ".$vend_col[$vend_inputs{$keypad_buffer}]."\n");
														$rc = send_packet($vendo, chr(0x02).chr(0x02).chr($vend_row[$vend_inputs{$keypad_buffer}]).chr($vend_col[$vend_inputs{$keypad_buffer}]));
														
														
														$cmd_timer = time();
														do{
															($count, $rcvstring) = $vendo->read(1);	#actual read
															if($count != 0){
																$rc .= $rcvstring;
															}
														}while(length($rc) < 6 && (time()-$cmd_timer) < 20);
														
														if($rc !~ m/^Done\r\n$/){
															print("Warning error detected on dispense got: ".unpack("H*",$rc)."\n");
															$error = 1;
														}	

													
													}else{
														print("Error credits not reduced by apropriate ammount post vend\n".$temp." - ".$vend_costs[$vend_inputs{$keypad_buffer}]." != ".$badge_info{"credits"}."\n");
														$error = 1;
													}
												}								
											}
										}else{
											$error = 1;
										}
									}
								}
								
								if($error != 0){
									print("Warning cyrpto error detected\n");
								}


								$last_badge_pres_status = 0;   # rescan badge
								
							
							
							}else{
								print("Insuffcient credits\n");
								$vendo_display{"string"} = "    ".$vend_costs[$vend_inputs{$keypad_buffer}]." credits  ".pick_random_string(\@insufficient_credits_strings);
								$vendo_display{"countdown"} = 2;  # note +1 due to clear below	
								$vendo_display{"change"} = 1;					
							}
						}
					}
				}else{
					print("invalid entry\n");
					$vendo_display{"string"} = "    ".pick_random_string(\@invalid_selection_strings);
					$vendo_display{"countdown"} = 2;  # note +1 due to clear below
				}
				$vendo_display{"another"} = 0;
				$vendo_display{"clear"} = 1;
				$vendo_display{"now"} = 1;
				$keypad_buffer = "";
			}
		}
	}
	
	# check keypad timeout
	if($keypad_buffer ne "" && $keypad_timer + $keypad_timeout < time()){
		#print("keypad timeout\n");
		$vendo_display{"another"} = 0;
		$vendo_display{"clear"} = 1;
		$keypad_buffer = "";
	}

	# check badge present
	if(($vendo_status & 0x02) != 0){
		
		if($last_badge_pres_status == 0){
			#print("Badge plug detected\n");
			
			
			$badge_ready = scan_badge(\%vendo_display, $vendo, \%badge_info, $dump_dump, $dbh, \$display_comm_error, $display);
			$keypad_buffer = "";  # flush the buffer to prevent accidental vends 
		
			$last_badge_pres_status = 1;
		}		

	}else{
		if($last_badge_pres_status == 1){
			# print("Badge unplug detected\n");
			
			
			# signal whixr badge gone
			$temp = "Disp:".chr(0x00);
			for($i = 0; $i < 138; $i++){
				$temp .= chr(0x00);
			}
			$temp .= "\n";
			sendraw($display, $temp);
			
			#print(length($badge_dump)," ",length($temp),"\n");
			#print(unpack("H*",$temp),"\n");
		
			$error = 0;
			$badge_ready = 0;
			$last_badge_pres_status = 0;
			$vendo_display{"now"} = 1;
			$vendo_display{"clear"} = 1;
			$vendo_display{"countdown"} = 1; # clear will move this to 0
		}
	}

	# check IR buffer full
	if(($vendo_status & 0x04) != 0){
		# if there is anyting in the IR buffer at this point just purge it
		#print("IR buffer full\n");
		send_packet($vendo, chr(0x06).chr(0x00)); # get IR buffer 1
	}
	
	#check for data from Whixr
	do{
		($count, $rcvstring) = $display->read(1);	#actual read
		if($count != 0){
			$whixr_buffer .= $rcvstring;
		}
	}while($count != 0);
	
	
#	"Vendo:X\n"
	
	if($whixr_buffer =~ m/Vendo:(.)\n/){
		print("Whixr buffer = 0x".unpack("H*",$1)."\n");
		$temp = $1;
		
		if($temp eq chr(0x01)){
			# drop the egg from badge
			print("\nsending clear egg to badge 0x",$badge_info{"id"}," for egg id 0x",$badge_info{"egg_from"},"\n");
			$temp = chr(hex(substr($badge_info{"id"}, 0, 2))).chr(hex(substr($badge_info{"id"}, 2, 2))).chr(hex(substr($badge_info{"egg_from"}, 0, 2))).chr(hex(substr($badge_info{"egg_from"}, 2, 2)));
			$rc = send_packet($vendo, chr(0x05).chr(0x05).chr(0x09).$temp);	
					# SPH, ir send command - vendo data len - IR cmd  - data
			if($rc ne "Done\r\n"){
				print("Warning bad packet detected at drop egg got: ".unpack("H*",$rc)."\n");
			}						
		}elsif($temp eq chr(0x02)){
			# start the quest
								
			if((hex($badge_info{"flags"}) & 0x80) != 0 && (hex($badge_info{"flags"}) & 0x10) == 0){			
				print("\nsending start quest to badge 0x",$badge_info{"id"},"\n");
				$temp = chr(hex(substr($badge_info{"id"}, 0, 2))).chr(hex(substr($badge_info{"id"}, 2, 2)));
				$rc = send_packet($vendo, chr(0x05).chr(0x03).chr(0x06).$temp);	
						# SPH, ir send command - vendo data len - IR cmd  - data
				if($rc ne "Done\r\n"){
					print("Warning bad packet detected at drop egg got: ".unpack("H*",$rc)."\n");
				}		
			}
			
		}else{
			# do nothing
		}
		
		# purge the buffer
		$whixr_buffer =~ s/^.*Vendo:(.)\n//;
	}
	
	if(length($whixr_buffer) > 20){
		$whixr_buffer = substr($whixr_buffer, -8);
	}
	
	
		

			
	
	
}


$dbh->disconnect;
print("Script done.\n");
exit(0);




###########################################################################################################
sub scan_badge{
	my $vendo_display = $_[0];
	my $vendo = $_[1];
	my $badge_info = $_[2];
	my $dump_dump = $_[3];
	my $dbh = $_[4];
	my $display_comm_error = $_[5];
	my $display = $_[6];

		
	my $retry_cnt = 0;
	my $badge_dump = "";
	my $error = 0;
	my $rc = "";
	my $cmd_timer = 0;
	my $vendo_status = "";
	my @chars = ();
	my $temp = "";
	my $i = 0;
	my $msg = "";
	my $sql = "";
	my $sth = "";
	my $found = 0;
	my @row = ();
	my $badge_ready = 0;
	
	do{		
		$error = 0;
		
		${$vendo_display}{"string"} = pick_random_string(\@badge_scan_strings); # 4 char so no scroll
		${$vendo_display}{"clear"} = 1;
		#${$vendo_display}{"dp1"} = 0;
		${$vendo_display}{"dp2"} = 0;
		${$vendo_display}{"dp3"} = 0;
		${$vendo_display}{"dp4"} = 1;
		${$vendo_display}{"change"} = 0;
		${$vendo_display}{"another"} = 0;
		${$vendo_display}{"now"} = 1;				
		update_display($vendo, $vendo_display);	# force a update right now
		
		
		$rc = send_packet($vendo, chr(0x05).chr(0x01).chr(0x01));  # send dump command
			# SPH, command - data len - data
		if($rc !~ m/^Done\r\n$/){
			print("Warning bad packet detected on send dump got: ".unpack("H*",$rc)." ".$rc."\n");
			$error = 1;
		}
		
		#print("Wait for badge to respond\n");
		$cmd_timer = time();
		do{
			$vendo_status = check_status($vendo);
			
		}while((time()-$cmd_timer) < 3 && ($vendo_status & 0x02) != 0 && ($vendo_status & 0x04) == 0);
		

		if(($vendo_status & 0x02) == 0 || ($vendo_status & 0x04) == 0){
			print("Error detected in scan got status ".$vendo_status."\n");
			$error = 1;
		}
		
		if(($vendo_status & 0x04) != 0){
			#print("Dump IR buffer\n");
			$rc = send_packet($vendo, chr(0x06).chr(0x00)); # get IR buffer 1
			if($rc !~ m/\r\nDone\r\n$/){
				print("Warning bad packet detected on get IR buffer got: ".unpack("H*",$rc)."\n");
				$error = 1;
			}		

			if($error == 0){
				#print("check dump packet\n");
				#print("len = ".length($rc)."\n");
				#print(unpack("H*",$rc)."\n");
				
				${$vendo_display}{"dp1"} = 1;
				
				#len = 154
				#91536d6173683f0102022009000000000200000001000c6200025700012c000f89000000020002000100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008001000000010000800100000000000080010000800100008000000000010000c0d90c05013028790d0a446f6e650d0a
				if(length($rc) == 154){
					#print("\nDecoding badge dump packet\n");
					@chars = split("",$rc);

					if($chars[0] ne chr(0x91)){
						print("Warning packet length incorrect 0x".sprintf("%02X",ord($chars[0])),"\n");
						$error = 1;
					}
					$temp = "";
					if($error == 0){
						for($i = 1; $i <= 6; $i++){
							$temp .= $chars[$i];
						}
						if($temp ne "Smash?"){
							print("Warning error on Smash? header\n");
							$error = 1;
						}
					}
					if($error == 0){
						if($chars[8] ne chr(0x02)){
							print("Warning packet type incorrect 0x".sprintf("%02X",ord($chars[8])),"\n");
							$error = 1;
						}							
					}
				
					if($error == 0){
						$badge_dump = $rc;
						$badge_dump =~ s/^\x91\x53\x6d\x61\x73\x68\x3f//;
						$badge_dump =~ s/.\x0d\x0a\x44\x6f\x6e\x65\x0d\x0a$//;
					
						#print(unpack("H*",$rc)."\n");
						#print(unpack("H*",$badge_dump)."\n");
					}
				}else{
					$error = 1;
				}
			}else{
				${$vendo_display}{"dp1"} = 0;
			}
		}
		
		if($error != 0){
			print("Warning dump error detected\n");
			sleep(1);
		}
	
		
		$retry_cnt++;	
	}while($retry_cnt < 10 && ($vendo_status & 0x02) != 0 && $badge_dump eq "");
	
	#print("exit dump loop\n");
	
	
	# dump done decode it or pop up comm error message 
	if($badge_dump ne ""){
		#print("Valid dump decode it \n");
		
		@chars = split("",$badge_dump);
		${$badge_info}{"status"} = sprintf("%02X",ord($chars[0]));
		${$badge_info}{"type"} = sprintf("%02X",ord($chars[1]));
		${$badge_info}{"id"} = sprintf("%02X",ord($chars[2])).sprintf("%02X",ord($chars[3]));
		${$badge_info}{"flags"} = sprintf("%02X",ord($chars[4]));
		${$badge_info}{"spent"} = sprintf("%02X",ord($chars[5])).sprintf("%02X",ord($chars[6]));
		${$badge_info}{"sick_from"} = sprintf("%02X",ord($chars[7])).sprintf("%02X",ord($chars[8]));
		${$badge_info}{"egg_from"} = sprintf("%02X",ord($chars[9])).sprintf("%02X",ord($chars[10]));
		${$badge_info}{"clicks"} = sprintf("%02X",ord($chars[11])).sprintf("%02X",ord($chars[12])).sprintf("%02X",ord($chars[13]));
		${$badge_info}{"sleep_time"} = sprintf("%02X",ord($chars[14])).sprintf("%02X",ord($chars[15])).sprintf("%02X",ord($chars[16]));
		${$badge_info}{"active_time"} = sprintf("%02X",ord($chars[17])).sprintf("%02X",ord($chars[18])).sprintf("%02X",ord($chars[19]));
		${$badge_info}{"hyper_time"} = sprintf("%02X",ord($chars[20])).sprintf("%02X",ord($chars[21])).sprintf("%02X",ord($chars[22]));
		${$badge_info}{"prego_time"} = sprintf("%02X",ord($chars[23])).sprintf("%02X",ord($chars[24])).sprintf("%02X",ord($chars[25]));
		${$badge_info}{"died"} = sprintf("%02X",ord($chars[26])).sprintf("%02X",ord($chars[27]));
		${$badge_info}{"ate"} = sprintf("%02X",ord($chars[28])).sprintf("%02X",ord($chars[29]));
		${$badge_info}{"pooped"} = sprintf("%02X",ord($chars[30])).sprintf("%02X",ord($chars[31]));
		${$badge_info}{"knocked_up"} = sprintf("%02X",ord($chars[32])).sprintf("%02X",ord($chars[33]));
		${$badge_info}{"quest_id"} = sprintf("%02X",ord($chars[34])).sprintf("%02X",ord($chars[35]));		
		${$badge_info}{"interaction_cnt"} = 0;
		$msg = "";
		for($i = 36; $i <= 131; $i++){
			$msg .= sprintf("%02X",ord($chars[$i]));
			foreach $temp(split("",unpack("b*",$chars[$i]))){
				if($temp == 1){
					${$badge_info}{"interaction_cnt"}++;
				}
			}
		}
		${$badge_info}{"interactions"} = $msg;				
		${$badge_info}{"credits"} = ${$badge_info}{"interaction_cnt"} - hex(${$badge_info}{"spent"});
		${$badge_info}{"food"} = sprintf("%02X",ord($chars[132]));
		${$badge_info}{"poop"} = sprintf("%02X",ord($chars[133]));
		${$badge_info}{"state"} = sprintf("%02X",ord($chars[134])).sprintf("%02X",ord($chars[135]));
		${$badge_info}{"once"} = sprintf("%02X",ord($chars[136])).sprintf("%02X",ord($chars[137]));




		if($dump_dump){
			foreach $temp(sort(keys(%{$badge_info}))){
				print("	",$temp," => 0x".${$badge_info}{$temp});
				if($temp eq "status"){
					if((hex(${$badge_info}{$temp}) & 0x01) != 0){
						print(" Con_start,");
					}
					if((hex(${$badge_info}{$temp}) & 0x02) != 0){
						print(" sick");
					}					
				}elsif($temp eq "type"){
					if(hex(${$badge_info}{$temp}) == 0x00){
						print(" Social ping");
					}elsif(hex(${$badge_info}{$temp}) == 0x01){
						print(" Request dump");
					}elsif(hex(${$badge_info}{$temp}) == 0x02){
						print(" Data dump");
					}elsif(hex(${$badge_info}{$temp}) == 0x03){
						print(" Request credits");
					}elsif(hex(${$badge_info}{$temp}) == 0x04){
						print(" Confirm credits");
					}elsif(hex(${$badge_info}{$temp}) == 0x05){
						print(" HBDH");				
					}elsif(hex(${$badge_info}{$temp}) == 0x06){
						print(" Start quest");
					}elsif(hex(${$badge_info}{$temp}) == 0x07){
						print(" Request food");
					}elsif(hex(${$badge_info}{$temp}) == 0x08){
						print(" Confirm food");
					}elsif(hex(${$badge_info}{$temp}) == 0x09){
						print(" Clear egg");
					}elsif(hex(${$badge_info}{$temp}) == 0x0A){
						print(" Uber");
					}elsif(hex(${$badge_info}{$temp}) == 0x0B){
						print(" End quest");
					}elsif(hex(${$badge_info}{$temp}) == 0x0C){
						print(" mine?");
					}else{
						print(" unknown packet");
					}					
				}elsif($temp eq "id"){
					if(hex(${$badge_info}{$temp}) < 0x200){
						print(" Standard badge");
					}elsif(hex(${$badge_info}{$temp}) < 0x240){
						print(" Speaker or turkey baster");
					}elsif(hex(${$badge_info}{$temp}) < 0x280){
						print(" Founder");
					}elsif(hex(${$badge_info}{$temp}) < 0x2A0){
						print(" Vendor or bird seed bag");
					}elsif(hex(${$badge_info}{$temp}) < 0x2C0){
						print(" Outhouse or port-a-potty");
					}elsif(hex(${$badge_info}{$temp}) < 0x2E0){
						print(" Snake oil");
					}elsif(hex(${$badge_info}{$temp}) < 0x2FE){
						print(" Necrollamacon");
					}elsif(hex(${$badge_info}{$temp}) == 0x2FE){
						print(" Start button");
					}elsif(hex(${$badge_info}{$temp}) == 0x2FF){
						print(" Vendo");
					}else{
						print(" Unknown badge type");
					}								
				}elsif($temp eq "flags"){
					if((hex(${$badge_info}{$temp}) & 0x01) != 0){
						print(" Con started,");
					}						
					if((hex(${$badge_info}{$temp}) & 0x02) != 0){
						print(" Has / Had pink eye,");
					}						
					if((hex(${$badge_info}{$temp}) & 0x04) != 0){
						print(" Pink eye cured,");
					}						
					if((hex(${$badge_info}{$temp}) & 0x08) != 0){
						print(" Has a egg,");
					}						
					if((hex(${$badge_info}{$temp}) & 0x10) != 0){
						print(" Quest started,");
					}						
					if((hex(${$badge_info}{$temp}) & 0x20) != 0){
						print(" Quest done,");
					}						
					if((hex(${$badge_info}{$temp}) & 0x40) != 0){
						print(" Uber!,");
					}						
					if((hex(${$badge_info}{$temp}) & 0x80) != 0){
						print(" Is dead");
					}							
				}elsif($temp eq "state"){
					if((hex(substr(${$badge_info}{$temp},0 ,2)) & 0x03) == 0){
						print(" Badge is dead or precon,");
					}elsif((hex(substr(${$badge_info}{$temp},0 ,2)) & 0x03) == 1){
						print("		Badge is sleeping,");
					}elsif((hex(substr(${$badge_info}{$temp},0 ,2)) & 0x03) == 2){
						print(" Badge is active,");
					}else{
						print(" Badge is hyper,");
					}					
					if((hex(substr(${$badge_info}{$temp},0 ,2)) & 0x04) != 0){
						print(" egg led on,");
					}						
					if((hex(substr(${$badge_info}{$temp},0 ,2)) & 0x08) != 0){
						print(" stomach led on,");
					}						
					if((hex(substr(${$badge_info}{$temp},0 ,2)) & 0x10) != 0){
						print(" inc amber logo,");
					}						
					if((hex(substr(${$badge_info}{$temp},0 ,2)) & 0x20) != 0){
						print(" inc red logo,");
					}						
					if((hex(substr(${$badge_info}{$temp},0 ,2)) & 0x40) != 0){
						print(" inc green logo,");
					}						
					if((hex(substr(${$badge_info}{$temp},0 ,2)) & 0x80) != 0){
						print(" inc blue logo,");
					}	
					if((hex(substr(${$badge_info}{$temp},0 ,2)) & 0x01) != 0){
						print(" Logo tick,");
					}	
					if((hex(substr(${$badge_info}{$temp},0 ,2)) & 0x02) != 0){
						print(" poo led on,");
					}	
					if((hex(substr(${$badge_info}{$temp},0 ,2)) & 0x04) != 0){
						print(" !!PostCon enabled!!,");
					}	
					if((hex(substr(${$badge_info}{$temp},0 ,2)) & 0x08) != 0){
						print(" egg up,");
					}						
				
				}
				print("\n");
			}
		}


		# check if record exists 
		$sql = 'SELECT id FROM badge_data WHERE id = \''.${$badge_info}{"id"}.'\'';
		$sth = $dbh->prepare($sql);
		$sth->execute();
		$found = 0;
		while (@row = $sth->fetchrow_array) {
			if($row[0] eq ${$badge_info}{"id"}){
				$found = 1;
			}
		}

		if($found == 0){
			# insert into table 
			$sql = 'INSERT INTO badge_data (id, active_time, ate, clicks, credits, died, egg_from, flags, food, hyper_time, interaction_cnt, interactions, knocked_up, poop, pooped, prego_time, quest_id, sick_from, sleep_time, spent, state, status, flamingo_code, coyote_code, llama_code, Parrot_code, Peacock_code)
				VALUES(\''.${$badge_info}{"id"}.'\', \''.${$badge_info}{"active_time"}.'\', \''.${$badge_info}{"ate"}.'\', \''.${$badge_info}{"clicks"}.'\', \''.${$badge_info}{"credits"}.'\', \''.${$badge_info}{"died"}.'\', \''.${$badge_info}{"egg_from"}.'\', \''.${$badge_info}{"flags"}.'\', \''.${$badge_info}{"food"}.'\', \''.${$badge_info}{"hyper_time"}.'\', \''.${$badge_info}{"interaction_cnt"}.'\', \''.${$badge_info}{"interactions"}.'\', \''.${$badge_info}{"knocked_up"}.'\', \''.${$badge_info}{"poop"}.'\', \''.${$badge_info}{"pooped"}.'\', \''.${$badge_info}{"prego_time"}.'\', \''.${$badge_info}{"quest_id"}.'\', \''.${$badge_info}{"sick_from"}.'\', \''.${$badge_info}{"sleep_time"}.'\', \''.${$badge_info}{"spent"}.'\', \''.${$badge_info}{"state"}.'\', \''.${$badge_info}{"status"}.'\',0,0,0,0,0)';
			$dbh->do($sql);
		}else{
			# Update table with info
			$sql = 'UPDATE badge_data SET active_time = \''.${$badge_info}{"active_time"}.'\', ate = \''.${$badge_info}{"ate"}.'\', clicks = \''.${$badge_info}{"clicks"}.'\', credits = \''.${$badge_info}{"credits"}.'\', 
				died = \''.${$badge_info}{"died"}.'\', egg_from = \''.${$badge_info}{"egg_from"}.'\', flags = \''.${$badge_info}{"flags"}.'\', food = \''.${$badge_info}{"food"}.'\', hyper_time = \''.${$badge_info}{"hyper_time"}.'\', 
				interaction_cnt = \''.${$badge_info}{"interaction_cnt"}.'\', interactions = \''.${$badge_info}{"interactions"}.'\', knocked_up = \''.${$badge_info}{"knocked_up"}.'\', poop = \''.${$badge_info}{"poop"}.'\', 
				pooped = \''.${$badge_info}{"pooped"}.'\', prego_time = \''.${$badge_info}{"prego_time"}.'\', quest_id = \''.${$badge_info}{"quest_id"}.'\', sick_from = \''.${$badge_info}{"sick_from"}.'\', 
				sleep_time = \''.${$badge_info}{"sleep_time"}.'\', spent = \''.${$badge_info}{"spent"}.'\', state = \''.${$badge_info}{"state"}.'\', status = \''.${$badge_info}{"status"}.'\'
				WHERE id = \''.${$badge_info}{"id"}.'\'';
			$dbh->do($sql);
		}


		if((hex(${$badge_info}{"flags"}) & 0x10) != 0 && (hex(${$badge_info}{"flags"}) & 0x20) == 0 && ${$badge_info}{"quest_id"} ne "0000"  && ${$badge_info}{"quest_id"} ne "FFFF"){	
			# quest started, not complete, and quest id set. Send quest done.
			$temp = chr(hex(substr($badge_info{"id"}, 0, 2))).chr(hex(substr($badge_info{"id"}, 2, 2)));
			$rc = send_packet($vendo, chr(0x05).chr(0x03).chr(0x0B).$temp);	
					# SPH, ir send command - vendo data len - IR cmd  - data
			if($rc ne "Done\r\n"){
				print("Warning bad packet detected at end quest got: ".unpack("H*",$rc)."\n");
			}	


			
		}

		
#				# read data back
#				print("read data from DB\n");
#				$sql = 'SELECT sleep_time FROM badge_data WHERE id = \''.${$badge_info}{"id"}.'\'';
#				$sth = $dbh->prepare($sql);
#				$sth->execute();
#				while (@row = $sth->fetchrow_array) {
#				   print(join(" ",@row)."\n");
#				}


		${$display_comm_error} = 0;
		
		#signal whixr badge plugged
		#print("to whixr\n");
		$temp = "Disp:".chr(0x01).$badge_dump."\n";
		#print("Sending ".length($temp)." bytes total\n");
		sendraw($display, $temp);
		
		#print(length($badge_dump)," ",length($temp),"\n");
		#print(unpack("H*",$temp),"\n");
		
		${$vendo_display}{"string"} = "    You have ".${$badge_info}{"credits"}." ".pick_random_string(\@cost_display_strings);
		${$vendo_display}{"dp1"} = 0;
		${$vendo_display}{"dp4"} = 0;
		${$vendo_display}{"countdown"} = 3;  # note +1 due to clear below	
		${$vendo_display}{"change"} = 1;
		${$vendo_display}{"now"} = 1;
		${$vendo_display}{"clear"} = 1;				

		
		if((hex(${$badge_info}{"flags"}) & 0x08) != 0){
			#print("Badge was prego from ".${$badge_info}{"egg_from"}."\n");
		
			# check if record exists 
			$sql = 'SELECT id FROM eggs WHERE id = \''.${$badge_info}{"egg_from"}.'\'';
			$sth = $dbh->prepare($sql);
			$sth->execute();
			$found = 0;
			while (@row = $sth->fetchrow_array) {
				if($row[0] eq ${$badge_info}{"egg_from"}){
					$found = 1;
				}
			}
			if($found == 0){
				#print("Record not found\n");
				$sql = 'INSERT INTO eggs (id, count) VALUES(\''.${$badge_info}{"egg_from"}.'\', 1)';
				$dbh->do($sql);
			}else{
				#print("Record found\n");
				$sql = 'UPDATE eggs SET count = count + 1 WHERE id = \''.${$badge_info}{"egg_from"}.'\'';
				$dbh->do($sql);			
			}

#				# read data back
#				print("read data from DB\n");
#				$sql = 'SELECT * FROM eggs';
#				$sth = $dbh->prepare($sql);
#				$sth->execute();
#				while (@row = $sth->fetchrow_array) {
#				   print(join(" ",@row)."\n");
#				}



		
		}


	
		
		$badge_ready = 1;
		

	}else{
		print("Dump failed\n");
		${$display_comm_error} = 1;
		${$vendo_display}{"string"} = "    ".pick_random_string(\@badge_read_error_strings); # 4 char so no scroll
		${$vendo_display}{"clear"} = 1;
		${$vendo_display}{"dp1"} = 0;
		${$vendo_display}{"dp2"} = 0;
		${$vendo_display}{"dp3"} = 0;
		${$vendo_display}{"dp4"} = 0;
		${$vendo_display}{"change"} = 0;
		${$vendo_display}{"another"} = 0;
		${$vendo_display}{"now"} = 1;	
		${$vendo_display}{"countdown"} = 2;	# due to clear above			
		update_display($vendo, $vendo_display);	# force a update right now
		
		$badge_ready = 0;
	}
	
	return($badge_ready);
} # end sub scan_badge()

###########################################################################################################
sub decrypt{
	my $badge_id = hex($_[0]);
	my $temp = $_[1];
	my @keys = @{$_[2]};
	
	my @key = ();			# byte array # $const_bbytes long
	my @crypt = @{$temp};	# # $const_bbytes long
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
	
	#print("	decrypt data\n		Get badge key\n");	
	if(!defined($keys[$badge_id]) || $keys[$badge_id] !~ m/^[a-f0-9]{20}$/i){
		print("Error key for badge ".$badge_id." missing or corrupt\n");
		return("");
	}
	#print("		key = ".$keys[$badge_id]."\n");
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

	#print("		key     = ");
	#&print_array(\@key);
	#print("		input   = ");
	#&print_array(\@crypt);

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

	#print("		decrypt = ");
	#&print_array(\@crypt);
	
	return(\@crypt);
	
} # end sub decrypt()

###########################################################################################################
sub crypt{
	my $badge_id = hex($_[0]);
	my $temp = $_[1];
	my @keys = @{$_[2]};
	
	my @key = ();			# byte array # $const_bbytes long
	my @crypt = @{$temp};	# # $const_bbytes long
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


	#print("	encrypt data\n		Get badge key\n");	
	if(!defined($keys[$badge_id]) || $keys[$badge_id] !~ m/^[a-f0-9]{20}$/i){
		print("Error key for badge ".$badge_id." missing or corrupt\n");
		return("");
	}
	#print("		key = ".$keys[$badge_id]."\n");
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

	#print("		key   = ");
	#&print_array(\@key);
	#print("		input = ");
	#&print_array(\@crypt);

	
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
	#print("		crypt = ");
	#&print_array(\@crypt);

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
sub get_keypad{
	my $sph = $_[0];
	
	my $rc = "";
	my $cmd = chr(0x04).chr(0x00);
	my @parts = ();
	my $part = "";
	my $data = "";
	my $i = 0;
	my $cnt = 0;
	
	$rc = send_packet($sph, $cmd);
		# SPH, command - data len - data
	if($rc !~ m/\r\nDone\r\n$/){
		print("Warning bad packet detected got: ".unpack("H*",$rc)."\n");
	}else{
		@parts = split("", $rc);
		for($i = 1; $i < scalar(@parts) - 8; $i++){
			$cnt++; 
			$part = ord($parts[$i]);
			if($part > 0 && $part <= 9){
				$data .= $part;
			}elsif($part == 10){
				$data .= 0;
			}elsif($part == 11){
				$data .= "A";
			}elsif($part == 12){
				$data .= "B";
			}elsif($part == 13){
				$data .= "C";
			}elsif($part == 14){
				$data .= "D";
			}elsif($part == 15){
				$data .= "E";
			}elsif($part == 16){
				$data .= "F";
			}elsif($part == 17){
				$data .= "G";
			}elsif($part == 18){
				$data .= "H";
			}elsif($part == 19){
				$data .= "U";
			}elsif($part == 20){
				$data .= "Z";
			}else{
				print("Warning invalid key value detected: ".$part."\n");
			}
		}
		if($cnt != ord($parts[0])){
			print("Warning key count recvd (".$cnt.") does not match expected value: ".ord($parts[0])."\n");
		}
	}	
	#print($data." => ".unpack("H*",$rc)."\n");

	
	# bit 0 = key presses
	# bit 1 = Badge present 
	# bit 2 = IR buffer 1 full 
	
	return($data);
} # end sub get_keypad()

###########################################################################################################
sub check_status{
	my $sph = $_[0];
	
	my $rc = "";
	my $cmd = chr(0x03).chr(0x00);
	my $data = 0;


	$rc = send_packet($sph, $cmd);
		# SPH, command - data len - data
	if($rc !~ m/^(.)Done\r\n$/){
		print("Warning bad packet detected got: ".unpack("H*",$rc)."\n");
	}else{
		$data = ord(substr($rc, 0, 1));
	}	
	#print($data." => ".unpack("H*",$rc)."\n");

	
	# bit 0 = key presses
	# bit 1 = Badge present 
	# bit 2 = IR buffer 1 full 
	
	return($data);
} # end sub check_status()

###########################################################################################################
sub pick_random_string{
	my @string_array = @{$_[0]};
	
	my $i = int(rand(scalar(@string_array)));
	
	return($string_array[$i]);
} # end sub pick_random_string()

###########################################################################################################
sub update_display{
	my $sph = $_[0];
	my $display = $_[1];
	
	
	my %translate = ();
	my @parts = ();
	my $cmd = "";
	my $temp = "";
	
	
	# Translation table
	$translate{" "} = 0b00000000;
	$translate{"0"} = 0b01111110;
	$translate{"1"} = 0b00110000;
	$translate{"2"} = 0b01101101;
	$translate{"3"} = 0b01111001;
	$translate{"4"} = 0b00110011;
	$translate{"5"} = 0b01011011;
	$translate{"6"} = 0b01011111;
	$translate{"7"} = 0b01110000;
	$translate{"8"} = 0b01111111;
	$translate{"9"} = 0b01111011;
	$translate{"A"} = 0b01110111;
	$translate{"a"} = 0b01110111;
	$translate{"B"} = 0b00011111;	#top, top right, bottom right, bottom, bottom left, top left, middle
	$translate{"b"} = 0b00011111;
	$translate{"C"} = 0b01001110;
	$translate{"c"} = 0b00001101;
	$translate{"D"} = 0b00111101;
	$translate{"d"} = 0b00111101;
	$translate{"E"} = 0b01001111;
	$translate{"e"} = 0b01001111;
	$translate{"F"} = 0b01000111;
	$translate{"f"} = 0b01000111;  
	$translate{"G"} = 0b01011110;
	$translate{"g"} = 0b01011110;
	$translate{"H"} = 0b00110111;
	$translate{"h"} = 0b00010111;
	$translate{"I"} = 0b00000110;
	$translate{"i"} = 0b00000110;
	$translate{"J"} = 0b00111100;
	$translate{"j"} = 0b00111100;
	$translate{"K"} = 0b01010111;
	$translate{"k"} = 0b01010111;
	$translate{"L"} = 0b00001110;
	$translate{"l"} = 0b00001110;
	$translate{"M"} = 0b01010101;
	$translate{"m"} = 0b01010101;
	$translate{"N"} = 0b00010101;
	$translate{"n"} = 0b00010101;	
	$translate{"O"} = 0b01111110;
	$translate{"o"} = 0b00011101;
	$translate{"P"} = 0b01100111;
	$translate{"p"} = 0b01100111;
	$translate{"Q"} = 0b01110011;
	$translate{"q"} = 0b01110011;
	$translate{"R"} = 0b00000101;
	$translate{"r"} = 0b00000101;
	$translate{"S"} = 0b01011011;
	$translate{"s"} = 0b01011011;
	$translate{"T"} = 0b01000110;
	$translate{"t"} = 0b00001111;
	$translate{"U"} = 0b00111110;
	$translate{"u"} = 0b00011100;
	$translate{"V"} = 0b00011000;
	$translate{"v"} = 0b00011000;
	$translate{"W"} = 0b00101010;
	$translate{"w"} = 0b00101010;
	$translate{"X"} = 0b01001001;
	$translate{"x"} = 0b01001001;
	$translate{"Y"} = 0b00111011;
	$translate{"y"} = 0b00111011;
	$translate{"Z"} = 0b01101101;
	$translate{"z"} = 0b01101101;
	$translate{"_"} = 0b00001000;
	$translate{"-"} = 0b00000001;
	$translate{"["} = 0b01001110;
	$translate{"]"} = 0b01111000;
	$translate{"("} = 0b01001110;
	$translate{")"} = 0b01111000;
	$translate{"|"} = 0b00000110;
	$translate{"="} = 0b01000001;
	$translate{"\'"} = 0b00000010;
	
	#top, top right, bottom right, bottom, bottom left, top left, middle
	

	


	if(Time::HiRes::time() > ${$display}{"time"} || ${$display}{"now"} == 1){
		#print("Updating display\n");
		
		${$display}{"now"} = 0;
		
		if(length(${$display}{"string"}) <= 4 || ${$display}{"count"} - 1 > length(${$display}{"string"}) || ${$display}{"clear"} == 1){
			#print("clear display counter\n");
			${$display}{"count"} = 0;
			${$display}{"clear"} = 0;
			if(${$display}{"countdown"} > 0){
				${$display}{"countdown"}--;
			}
		}elsif(${$display}{"count"} - 1 > length(${$display}{"string"}) || ${$display}{"clear"} == 1){
			#print("clear display counter\n");
			${$display}{"count"} = 0;
			${$display}{"clear"} = 0;
			if(${$display}{"countdown"} > 0){
				${$display}{"countdown"}--;
			}
		}

		@parts = split("", ${$display}{"string"});
	
		#load command and length
		$cmd = chr(0x01).chr(0x05);

		#	byte 0			
		#		bit 7	N/U 	
		#		bit 6	digit 1 (left)	top seg
		#		bit 5	digit 1 (left)	top right seg
		#		bit 4	digit 1 (left)	bottom right seg
		#		bit 3	digit 1 (left)	bottom seg
		#		bit 2	digit 1 (left)	bottom left seg
		#		bit 1	digit 1 (left)	top left set
		#		bit 0	digit 1 (left)	middle seg
		#	byte 1			
		#		bit 7	digit 1 (left)	decimal point
		#		bit 6	digit 2	top seg
		#		bit 5	digit 2	top right seg
		#		bit 4	digit 2	bottom right seg
		#		bit 3	digit 2	bottom seg
		#		bit 2	digit 2	bottom left seg
		#		bit 1	digit 2	top left set
		#		bit 0	digit 2	middle seg
		#	byte 2			
		#		bit 7	digit 2	decimal point
		#		bit 6	digit 3	top seg
		#		bit 5	digit 3	top right seg
		#		bit 4	digit 3	bottom right seg
		#		bit 3	digit 3	bottom seg
		#		bit 2	digit 3	bottom left seg
		#		bit 1	digit 3	top left set
		#		bit 0	digit 3	middle seg
		#	byte 3			
		#		bit 7	digit 3	decimal point
		#		bit 6	digit 4 (right)	top seg
		#		bit 5	digit 4 (right)	top right seg
		#		bit 4	digit 4 (right)	bottom right seg
		#		bit 3	digit 4 (right)	bottom seg
		#		bit 2	digit 4 (right)	bottom left seg
		#		bit 1	digit 4 (right)	top left set
		#		bit 0	digit 4 (right)	middle seg
		#	byte 4			
		#		bit 7	digit 4 (right)	decimal point
		#		bit 6	lower led	
		#		bit 5	upper led	
		#		bit 4	N/U 	
		#		bit 3	N/U 	
		#		bit 2	N/U 	
		#		bit 1	N/U 	
		#		bit 0	N/U 			
		
		#load left most byte (bit 7 unused no decimal point)
		if(!defined($parts[${$display}{"count"}]) || $parts[${$display}{"count"}] eq ""){
			$temp = $translate{" "};
		}else{
			$temp = $translate{$parts[${$display}{"count"}]};
		}
		if(! defined($temp) || $temp eq ""){
			$temp = $translate{" "};
		}
		$cmd .= chr($temp);

		#load left mid byte (bit 7 dp 1)
		if(!defined($parts[${$display}{"count"} + 1]) || $parts[${$display}{"count"} + 1] eq ""){
			$temp = $translate{" "};
		}else{
			$temp = $translate{$parts[${$display}{"count"} + 1]};
		}
		if(! defined($temp) || $temp eq ""){
			$temp = $translate{" "};
		}
		#tack on the DP led value
		if(${$display}{"dp1"} != 0){
			$temp = $temp | 0x80;
		}
		$cmd .= chr($temp);
		
		#load right mid byte (bit 7 dp 1)
		if(!defined($parts[${$display}{"count"} + 2]) || $parts[${$display}{"count"} + 2] eq ""){
			$temp = $translate{" "};
		}else{
			$temp = $translate{$parts[${$display}{"count"} + 2]};
		}
		if(! defined($temp) || $temp eq ""){
			$temp = $translate{" "};
		}
		#tack on the DP led value
		if(${$display}{"dp2"} != 0){
			$temp = $temp | 0x80;
		}
		$cmd .= chr($temp);

		#load right most byte (bit 7 dp 1)
		if(!defined($parts[${$display}{"count"} + 3]) || $parts[${$display}{"count"} + 3] eq ""){
			$temp = $translate{" "};
		}else{
			$temp = $translate{$parts[${$display}{"count"} + 3]};
		}
		if(! defined($temp) || $temp eq ""){
			$temp = $translate{" "};
		}
		#tack on the DP led value
		if(${$display}{"dp3"} != 0){
			$temp = $temp | 0x80;
		}
		$cmd .= chr($temp);

		#load extra leds (bit 7 dp 1, bit 6 lower led, bit 5 upper led)
		$temp = 0x00;
		#tack on the DP led value
		if(${$display}{"dp4"} != 0){
			$temp = $temp | 0x80;
		}
		#tack on the make another selection led value
		if(${$display}{"another"} != 0){
			$temp = $temp | 0x40;
		}
		#tack on the exact change led value
		if(${$display}{"change"} != 0){
			$temp = $temp | 0x20;
		}
		$cmd .= chr($temp);


		if($cmd ne ${$display}{"last"}){
			$rc = send_packet($sph, $cmd);
				# SPH, command - data len - data
			if($rc ne "Done\r\n"){
				print("Warning bad packet detected got: ".unpack("H*",$rc)."\n");
			}
			
		}else{
			#print("String same no update\n");
		}
		
		${$display}{"last"} = $cmd;
		${$display}{"count"}++;
		${$display}{"time"} = ${$display}{"delay"} + Time::HiRes::time();
	}


	return();
} # end sub update_display()



###########################################################################################################
sub send_packet{
	my $sph = $_[0];
	my $payload = $_[1];
	
	my $string = "";
	my $rcvstring = "";
		
	$payload = "Vendo".$payload.chr(0x0D).chr(0x0A);
	sendraw($sph, $payload);

	$string = "";
	do{
		($count, $rcvstring) = $sph->read(1);	#actual read
		if($count != 0){
			$string .= $rcvstring;
		}
	}while($count != 0);
	
	return($string);
} # end sub send_packet()

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
# this function configures and opens the serial port. 
# arguments
# 	serial port
# returns
#	serial port handle 
###########################################################################################################
sub open_serial{
	my $serial_port = $_[0];
	my $baud_rate = $_[1];
	
	my $count = 0;
	my $string = "";
	my $serial_handle = "";
	

	print("Opening the serial port ",$serial_port,"\n");
		
#	if($^O =~ m/win/i){
#		require 5.003;
#		eval(use Win32::SerialPort qw( :STAT 0.19 );); #(more info at http://members.aol.com/Bbirthisel/SerialPort.html)
#	
#		# open the serial port  (more info at http://members.aol.com/Bbirthisel/SerialPort.html)
#		$serial_handle = new Win32::SerialPort ($serial_port) || die("Can't open ".$serial_port.": ".$^E."\n");    # actualy opens the serial port
#	
#		# configure the port
#		$serial_handle->baudrate(57600);
#		$serial_handle->databits(8);
#		$serial_handle->stopbits(1);
#		$serial_handle->handshake("none");
#		$serial_handle->binary("T");          		# just say Yes (Win 3.x option)
#		$serial_handle->parity_enable(0); 
#		$serial_handle->parity("none");
#		$serial_handle->debug(0);
#		$serial_handle->write_char_time(50);	# needed for write timeouts
#		$serial_handle->write_const_time(100);	# needed for write timeouts
#		$serial_handle->read_interval(100);    # needed for read timeouts max time between read char (milliseconds)
#		$serial_handle->read_char_time(5);     	# needed for read timeouts avg time between read char
#		$serial_handle->read_const_time(100);  # needed for read timeouts total = (avg * bytes) + const 
#		$serial_handle->buffers(4096, 4096);
#		$serial_handle->write_settings;			# actualy use the settings above	

	if($^O =~ m/linux/i){
		# For Linux 
		use Device::SerialPort;
		$serial_handle = Device::SerialPort->new($serial_port) || die("Can't open ".$serial_port.": ".$^E."\n");    # actualy opens the serial port

		# configure the port
		$serial_handle->baudrate($baud_rate);
		$serial_handle->databits(8);
		$serial_handle->stopbits(1);
		$serial_handle->handshake("none");
		$serial_handle->binary("T");          		# just say Yes (Win 3.x option)
		$serial_handle->parity_enable(0); 
		$serial_handle->parity("none");
		$serial_handle->debug(0);
		#$serial_handle->write_char_time(50);	# needed for write timeouts - not valid in linux
		#$serial_handle->write_const_time(100);	# needed for write timeouts - not valid in linux
		#$serial_handle->read_interval(100);    # needed for read timeouts max time between read char (milliseconds) - not valid in linux
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

