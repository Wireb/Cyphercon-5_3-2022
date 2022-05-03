
use warnings;
use strict;

#my $ipecmd = '"C:\\Program Files (x86)\\Microchip\\MPLABX\\v5.30\\mplab_platform\\mplab_ipe/ipecmd.exe" ';
my $ipecmd = '"C:\\Program Files (x86)\\Microchip\\MPLABX\\v5.35\\mplab_platform\\mplab_ipe/ipecmd.exe" ';
my $cmd = "";
my $rc = "";
#my $firmware = 'D:\\cam_offload_cache\\mplab\\Tymkrs_CNS2017_proto\\Tymkrs_CNS2017_proto.X\\dist\\default\\production\\Tymkrs_CNS2017_proto.X.production.hex';
my $firmware = './Tymkrs_Cyphercon_2020_badge.X.production.hex';
my $key_file = './Tymkrs_Cyphercon_2020_keys.txt';
my $SQTP = "c:\\temp\\SQTP.hex";
my $pic_model = "16F15345";
my $time = time();
my $start_id = 0;
my $end_id = 1000;
my $i = 0;
my $temp = "";
#my $pickit = "-TPPK3 ";
my $pickit = "-TPPK4 ";
#my $pickit = "-TPPK4 -W5";
#my $pickit = "-TPICD3 ";
my @key = ();
my $j = 0;
my $checksum = 0;
my $line = "";

for($i = $start_id; $i <= $end_id; $i++){
	print("Press enter to program #".$i."\a\n");
	$temp = <STDIN>;
	if($temp =~ m/^(\d+)$/i){
		$i = $temp;
		chomp($i);
	}

	$time = time();
	print("Generate firmware file with ID ".$i."\n");

	#print(sprintf("%04x",(hex(substr(sprintf("%04x", $i), 2, 2))+hex(substr(sprintf("%04x", $i)))+2)),"\n");
	#print(((hex(substr(sprintf("%04x", $i), 2, 2)) + hex(substr(sprintf("%04x", $i), 0, 2)) + 2) & hex(ff)),"\n");
	#print(sprintf("%02x", (hex(100) - ((hex(substr(sprintf("%04x", $i), 2, 2)) + hex(substr(sprintf("%04x", $i), 0, 2)) + 2) & hex(ff)))),"\n");
	#print(":02000000".substr(sprintf("%04x", $i), 2, 2).substr(sprintf("%04x", $i), 0, 2).(substr(sprintf("%02x", (hex(100) - ((hex(substr(sprintf("%04x", $i), 2, 2)) + hex(substr(sprintf("%04x", $i), 0, 2)) + 2) & hex(ff)))),-2))."\n");
		
	#exit(0);	
		
	open(IN, "<".$firmware) || die("Error unable to open ".$firmware."\n");
	open(OUT, ">".$SQTP) || die("Error unable to open ".$SQTP."\n");
	
	$temp = 0;
	foreach $line(<IN>){
		if($line =~ m/^\s*:020000040001F9\s*$/i){
			$temp = 1;
			print(OUT $line);				
		}elsif($temp == 1 && $line =~ m/^\s*:020000000000FE\s*$/i){
			# # :020000000000FE
			print(OUT ":02000000".substr(sprintf("%04x", $i), 2, 2).substr(sprintf("%04x", $i), 0, 2).(substr(sprintf("%02x", (hex(100) - ((hex(substr(sprintf("%04x", $i), 2, 2)) + hex(substr(sprintf("%04x", $i), 0, 2)) + 2) & 0xff))),-2))."\n");
		}elsif($temp == 0 && $line =~ m/^\s*:103EE00001000200030004000500F000E000D00023\s*$/i){
			#:10 3EE0 00 01000200030004000500F000E000D000 23
			# generate new key
			@key = ();
			for($j = 0; $j < 10; $j++){
				$key[$j] = sprintf("%02x",int(rand(255)));
			}
							
			# save key to file
			open(KEY, ">>", $key_file) || die("Error unable to open ".$key_file."\n");
			print(KEY $i,",",join("",@key),"\n");
			close(KEY);

			# build line
			$checksum = 0;
			print(OUT ":103EE000");
			$checksum += 0x10 + 0x3E + 0xE0;
			for($j = 0; $j < 8; $j++){
				print(OUT uc($key[$j])."00");
				$checksum += hex($key[$j]);
			}
			$checksum = $checksum & 0xFF; 
			$checksum = 0x100 - $checksum;
			$checksum = $checksum & 0xFF; 
			print(OUT uc(sprintf("%02x", $checksum)),"\n");


		}elsif($temp == 0 && $line =~ m/^\s*:103EF000C000A000FF00FF00FF00FF00FF00FF0068\s*$/i){
			#:10 3EF0 00 C000A000FF00FF00FF00FF00FF00FF00 68
			# build line
			$checksum = 0;
			print(OUT ":103EF000");
			$checksum += 0x10 + 0x3E + 0xF0;
			for($j = 8; $j < 10; $j++){
				print(OUT uc($key[$j])."00");
				$checksum += hex($key[$j]);
			}
			print(OUT "FF00FF00FF00FF00FF00FF00");
			$checksum += 0xFF * 6;
			$checksum = $checksum & 0xFF; 
			$checksum = 0x100 - $checksum;
			$checksum = $checksum & 0xFF; 
			print(OUT uc(sprintf("%02x", $checksum)),"\n");
		}else{
			$temp = 0;
			print(OUT $line);
		}	
	}
	
	close(IN);
	close(OUT);
	
		
	if(0){
		print(time() - $time,"s	blank check device\n");
		$cmd = $ipecmd."-C -P".$pic_model." ".$pickit;
		$rc = `$cmd`;
		if($rc !~ m/Blank\s+check\s+complete/i){
			print($rc."\n");
			print("\nError unable to blank check device.\nExiting\n");
			exit(-1);
		}	
		if($rc !~ m/Blank\s+check\s+complete,\s+device\s+is\s+blank\./i){
			print(time() - $time,"s	erase device\n");
			$cmd = $ipecmd."-E -P".$pic_model." ".$pickit;
			$rc = `$cmd`;
			if($rc !~ m/Erase\s+successful/i || $rc !~ m/Operation\s+Succeeded/i){
				print($rc."\n");
				print("\nError part not blank after erase.\nExiting\n");
				exit(-1);
			}
			
			print(time() - $time,"s	blank check device\n");
			$cmd = $ipecmd."-C -P".$pic_model." ".$pickit;
			$rc = `$cmd`;
			if($rc !~ m/Blank\s+check\s+complete,\s+device\s+is\s+blank\./i){
				print($rc."\n");
				print("\nError part not blank after erase.\nExiting\n");
				exit(-1);
			}
		}
	}else{
		print(time() - $time,"s	erase device\n");
		$cmd = $ipecmd."-E -P".$pic_model." ".$pickit;
		#print($cmd,"\n");
		$rc = `$cmd`;
		if($rc !~ m/Erase\s+successful/i || $rc !~ m/Operation\s+Succeeded/i){
			print($rc."\n");
			print("\nError part not blank after erase.\nExiting\n");
			exit(-1);
		}	
	}
	
	
	print("Program SPI then press enter\a\n");
	$temp = <STDIN>;


	print(time() - $time,"s	Programing base firmware\n");
	$cmd = $ipecmd."-M -P".$pic_model." ".$pickit." -F".$SQTP;
	$rc = `$cmd`;
	if($rc !~ m/Program\s+Succeeded./i || $rc !~ m/Operation\s+Succeeded/i){
		print($rc."\n");
		print("\nError base program failed.\nExiting\n");
		exit(-1);
	}

	if(0){
		print(time() - $time,"s	Verify base firmware\n");
		$cmd = $ipecmd."-Y -P".$pic_model." ".$pickit." -F".$SQTP;
		$rc = `$cmd`;
		if($rc !~ m/Verification successful./i || $rc !~ m/Verify Succeeded./i || $rc !~ m/Operation\s+Succeeded/i){
			print($rc."\n");
			print("\nError base verify failed.\nExiting\n");
			exit(-1);
		}
	}
	
	if(0){
		print(time() - $time,"s	Programing ID\n");
		$cmd = $ipecmd." -MI -P".$pic_model." ".$pickit." -F".$SQTP;
		$rc = `$cmd`;
		if($rc !~ m/Program\s+Succeeded./i || $rc !~ m/Operation\s+Succeeded/i){
			print($rc."\n");
			print("\nError base program failed.\nExiting\n");
			exit(-1);
		}

		print(time() - $time,"s	Verify ID\n");
		$cmd = $ipecmd."-YI -P".$pic_model." ".$pickit." -F".$SQTP;
		$rc = `$cmd`;
		if($rc !~ m/Verification successful./i || $rc !~ m/Verify Succeeded./i || $rc !~ m/Operation\s+Succeeded/i){
			print($rc."\n");
			print("\nError ID verify failed.\nExiting\n");
			exit(-1);
		}
	}

	print(" Total time taken: ",(time() - $time),"s\n");
}
	
exit(0);



