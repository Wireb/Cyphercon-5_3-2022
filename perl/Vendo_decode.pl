
use strict;
use warnings;
use Time::HiRes;
use DBI;


my $dbfile = "./cyphercon2022.db";
my $dsn = "dbi:SQLite:dbname=".$dbfile;
my $db_user = "";
my $db_password = "";

my $dbh = "";
my $sth = "";
my $count = 0;
my $line = "";
my $sql = "";
my $cmd = "";
my $rc = "";
my $temp = "";
my $dump_port = "";
my @row = ();
my $out = "";
my $item = "";
my %header = ();
my %data = ();

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




foreach $item("badge_data","spending","eggs"){
	open(OUT, ">".$item.".csv");
	print("\n\n#*#* Dumping ".$item." table *#*#\n");
		
	# Get column names
	#print("get column names\n");
	$out = "";
	$sql = 'pragma table_info('.$item.')';
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$count = 0;
	%header = ();
	while (@row = $sth->fetchrow_array) {
		$out .= $row[1].",";
		$header{$row[1]} = $count;
		$count++;
	}
	$out =~ s/,$/\n/;
	print(OUT $out."\n");
	print("Count = ".$count."\n");

	#print("Get data\n");
	$sql = 'SELECT * FROM '.$item;
	$sth = $dbh->prepare($sql);
	$sth->execute();
	$count = 0;
	while (@row = $sth->fetchrow_array) {
	  print(OUT join(",",@row)."\n");
	  #print($row[$header{"clicks"}],"\n");
	  #if($data{"max_clicks"} < hex($row[$header{"clicks"}])){
		#	$data{"max_clicks"} = hex($row[$header{"clicks"}]);
		#	$data{"max_clicks_id"} = hex($row[$header{"id"}]);
	  #}
	  $count++;
	}
	print("Count = ".$count."\n");
	
	print("ID ",$data{"max_clicks_id"}," => ",$data{"max_clicks"},"\n");
	
	print("\n\n#*#* End ".$item." table *#*#\n");
	


}




$dbh->disconnect;
print("Script done.\n");
exit(0);


		


