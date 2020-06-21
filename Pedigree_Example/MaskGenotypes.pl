$IndicesFile = $ARGV[0];
$HaplotypesFile = $ARGV[1];
$HaplotypesExitFile = $ARGV[2];

open(IND,$IndicesFile) or die "NO!";
%IndicesHash = ();
@IndicesArray = ();
$LineNumber = 1;
while (<IND>){
	chomp;
#	print "Indices File Line Number = $LineNumber\n";
	$LineNumber = $LineNumber + 1;
	$Line = $_;
	@LineElements = split(/,/,$Line);
	$element = $LineElements[0] ;
if (grep {$_ eq $element} @IndicesArray) {
#  print "Element '$element' found!\n" ;
  $IndicesHash{$LineElements[0]} = $IndicesHash{$LineElements[0]}.",".$LineElements[1];
}else{
	push(@IndicesArray,$LineElements[0]);
	$IndicesHash{$LineElements[0]} = $LineElements[1];
}

}
close(IND);
#die "Enough!";
open(HAP,$HaplotypesFile) or die "NO!";
open(EXIT,">$HaplotypesExitFile") or die "NO!";
$LineNumber = 1;
while (<HAP>) {
	chomp;
	$Line = $_;
	print "Haplotype File Line Number = $LineNumber\n";
	@LineElements = split(/\t/,$Line);
	if ($IndicesHash{$LineNumber}){
		
		@HashElements = split (/,/,$IndicesHash{$LineNumber});
		foreach $j (@HashElements){
			
			print "$j\t";
			$ElementNumber = $j + 4;
			$LineElements[$ElementNumber] = "./.";
		}

		foreach $j (@LineElements){
			print EXIT "$j\t";
		}
			print EXIT "\n";
		print "\n";
	}else{
		#print "Hueves! $LineNumber\n";
		foreach $j (@LineElements){
			print EXIT "$j\t";
		}
			print EXIT "\n";

}
	$LineNumber = $LineNumber + 1;
}
close(HAP);
