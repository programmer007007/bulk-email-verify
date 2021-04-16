use strict;
use warnings;
use File::Find;
use File::Basename;
use Parallel::ForkManager;
use Mail::CheckUser qw(check_email last_check);
$Mail::CheckUser::Timeout = 15;

open(FR,"<","putemail.txt");
open(FW,">","good_emails.txt");
my $pm = Parallel::ForkManager->new(50);
foreach(<FR>){
	$pm->start and next;
	chomp;
	if(check_email($_)) {
		print "E-mail address <$_> is GOOD\n";
		print FW $_."\n";
	}else{
		print "E-mail address <$_> isn't valid: ",last_check()->{reason}, "\n";		
	}
	$pm->finish; # do the exit in the child process
}
$pm->wait_all_children;
close FR;