

use strict;
use warnings;
use Imager;	# https://metacpan.org/pod/distribution/Imager/lib/Imager/ImageTypes.pod

my $input_file = "./Animation_build_list.txt";
my $output_file = "./animation.bin";

# init array with header
my @data = (0xFE,0xED,0xB0,0xB0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF);
my @lines = ();
my $line = "";
my $mode = 0;
my $data_offset = 1296;
my %offsets = ();
my @parts = ();
my $part = "";
my $linecnt = 0;
my $file = "";
my $delay = 0;
my $delay_unit = 0.049152;
my $temp = "";
my $i = 0;
my %frame_count = ();
my $seq_name = "";
my $set_cnt = 0;
my $set = 0;

open(IN, "<", $input_file) || die("Unable to open ".$input_file."\n");
@lines = <IN>;
close(IN);

#load the seq information. 
foreach $line(@lines){
	$linecnt++;
	if($line !~ m/^\s*#/i){
		chomp($line);
		if($mode == 0 && $line =~ m/^\s*start\s+seq\s+(.+)$/i){
			#start seq sleep
			print("	creating sequance #".$i."\n");
			$mode = 1;
			$seq_name = $1;
			if(defined($offsets{$seq_name}) && $offsets{$seq_name} ne ""){
				print("Error on line ".$linecnt." seq name ".$seq_name." reused \n");
				exit(-1);
			}
			$offsets{$seq_name} = $data_offset;			
		}elsif($mode == 1 && $line =~ m/^\s*end\s+seq\s*$/i){
			print("	Done. \n");
			$mode = 0;	
			if($frame_count{$seq_name} <= 0 || $frame_count{$seq_name} > 256){
				print("Error detected on line ".$linecnt." too many frame in seq:\n");
				print("Exiting\n");
				exit(-1);			
			}
			if($frame_count{$seq_name} == 256){
				$frame_count{$seq_name} = 0;
			}
		}elsif($mode == 1){
			if($line =~m/^\s*(\S+)\s+(\d+|\d+\.\d+)s/i){
				#./Untitled.png 1s
				$file = $1;
				$delay = $2;
				if(!-e $1){
					print("Error detected on line ".$linecnt." :\n");
					print("file ",$1,"\n");
					print("Exiting\n");
					exit(-1);
				}else{
					do{
						if($delay > (255 * $delay_unit)){
							$temp = (255 * $delay_unit);
							$delay -= (255 * $delay_unit);
						}else{
							$temp = $delay;
							$delay = 0;
						}
						print("		".$data_offset." adding frame ".$file." to seq for ".$temp."s\n");
						$data_offset = &load_frame(\@data, $data_offset, int($temp/$delay_unit), $file, 1);	
						$frame_count{$seq_name}++;
					}while($delay > 0);
				}
			}else{
				print("Error detected on line ".$linecnt." :\n");
				print($line,"\n");
				print("Exiting\n");
				exit(-1);
			}
		}
		
	}
}

#load the set information. 
foreach $line(@lines){
	$linecnt++;
	if($line !~ m/^\s*#/i){
		chomp($line);
		if($mode == 0 && $line =~ m/^\s*start\s+set\s+(\d+)$/i){
			#start set 1
			if($1 < 0 || $1 > 15){
				print("Error detected on line ".$linecnt." set out of range:\n");
				print($line,"\n");
				print("Exiting\n");
				exit(-1);
			}
			print("	creating set ".$1."\n");
			$mode = 1;
			$set = $1;
			$set_cnt = 0;
		}elsif($mode == 1 && $line =~ m/^\s*end\s+set\s*$/i){
			if($set_cnt != 16){
				print("Error detected on line ".$linecnt." runt set detected.\n");
				print("Exiting\n");
				exit(-1);			
			}
			print("	Done. \n");
			$mode = 0;	
		}elsif($mode == 1 && $line =~m/^\s*(\S+)\s*/i){
			$temp = $1;
			if(defined($offsets{$temp}) && $offsets{$temp} =~ m/^\d+$/i){
				$part = sprintf("%06X", $offsets{$temp});
				$data[16+64*($set)+4*$set_cnt+0] = hex(substr($part,4,2));
				$data[16+64*($set)+4*$set_cnt+1] = hex(substr($part,2,2));
				$data[16+64*($set)+4*$set_cnt+2] = hex(substr($part,0,2));
				$data[16+64*($set)+4*$set_cnt+3] = $frame_count{$temp};
				$set_cnt++;
			}else{
				print("Error detected on line ".$linecnt." unknown animation seq:\n");
				print($line,"\n");
				print("Exiting\n");
				exit(-1);
			}
		}		
	}
}


print("Creating output file ".$output_file."\n");
open(OUT, ">", $output_file) || die("Error unable to open ".$output_file."\n");
binmode(OUT);

for($i = 0; $i < scalar(@data); $i++){
	if(defined($data[$i]) && $data[$i] >= 0 && $data[$i] <= 255){	
		print(OUT chr($data[$i]));
	}else{
		print(OUT chr(0xFF));
	}
}
close(OUT);


print("Script done\n");
exit(0);

#################################################################################################################
sub load_frame{
	my $data = $_[0];
	my $data_offset = $_[1];
	my $delay = $_[2];
	my $file = $_[3];
	my $invert = $_[4];




	my $img = "";
	my $x = 0;
	my $y = 0;
	my $x_max = 0;
	my $y_max = 0;
	my @parts = ();
	my $cnt = 0;
	my @bits = ();
	my $byte = 0;
	my $temp = 0;
	my $start = $data_offset;



	$img = Imager->new;
	$img->read(file=>$file, type=>"png") or die("Cannot read ".$file.": ",$img->errstr);
	
	if(0){ # debug print messages
		print("image dimentions: ",$img->getwidth()," x ",$img->getheight(),"\n");
		print("image channels: ",$img->getchannels(),"\n");
		print("image bits: ",$img->bits(),"\n");
		print("image virtual: ",$img->virtual(),"\n");
		my $color = $img->getcolorcount(maxcolors=>512);
		print("Actual number of colors in image: ");
		print defined($color) ? $color : ">512", "\n";
		print("image type: ",$img->type(),"\n");

		if($img->type() eq 'direct'){
			print("Modifiable Channels: ");
			print join " ", map {
			($img->getmask() & 1<<$_) ? $_ : ()
			} 0..$img->getchannels();
			print("\n");
		}else{
			# palette info
			my $count = $img->colorcount;  
			my @colors = $img->getcolors();
			print("Palette size: ".$count."\n");
			my $mx = @colors > 4 ? 4 : 0+@colors;
			print("First $mx entries:\n");
			for(@colors[0..$mx-1]){
				my @res = $_->rgba();
				print "(", join(", ", @res[0..$img->getchannels()-1]), ")\n";
			}
		}
 
		my @tags = $img->tags();
		if(@tags){
			print("Tags:\n");
			for(@tags){
				print shift @$_, ": ", join " ", @$_, "\n";
			}
		}else{
			print("No tags in image\n");
		}
	}

	if($img->getheight() != 40 || $img->getwidth() != 72){
		print("			Error file must be 72x40 pixles exiting.\n");
		exit(-1);
	}

	$x_max = $img->getwidth() - 1;
	$y_max = $img->getheight() - 1;
	for($y = 0; $y < $img->getheight(); $y++){
		for($x = 0; $x < $img->getwidth(); $x++){
			@parts = $img->getpixel( x=>$x, y=>$y, type=>'8bit' )->rgba();
			if($parts[0] > 0 || $parts[1] > 0 || $parts[2] > 0){
				if($invert == 1){
					$bits[$x_max - $x][$y_max - $y] = 0;
				}else{
					$bits[$x_max - $x][$y_max - $y] = 1;
				}
				#print("*");
			}else{
				if($invert == 1){
					$bits[$x_max - $x][$y_max - $y] = 1;
				}else{
					$bits[$x_max - $x][$y_max - $y] = 0;
				}
				#print(" ");
			}
		}
		#print("\n");
	}

	for($y = 0; $y < 40; $y += 8){
		for($x = 0; $x < 72; $x++){
			${$data}[$data_offset] = oct("0b".$bits[$x][$y+7].$bits[$x][$y+6].$bits[$x][$y+5].$bits[$x][$y+4].$bits[$x][$y+3].$bits[$x][$y+2].$bits[$x][$y+1].$bits[$x][$y+0]);
			$data_offset++;
		}
	}
	
	# add delay byte as last item in frame_count
	${$data}[$data_offset] = $delay;
	$data_offset++;
	
	return($data_offset);
} # end sub load_frame()


