#!/usr/bin/perl

#Module declaration
use v5.16;
use strict;
use warnings;
use Data::Dumper;
use Net::DNS::Resolver;
use Term::ANSIColor qw(:constants);

#Reset the terminal to default colors when finished.
$Term::ANSIColor::AUTORESET = 1;

#Validatin cPanel installation and that the server has accounts.

my $domainFile = '/etc/userdomains';
my $iscPanel = '/usr/local/cpanel/version';

if (-e $domainFile && -e $iscPanel ) {
	
	print_information("This is a cPanel server");
	my $iscP='1';

} else {
	print_warning("This script is only useful on cPanel servers with valid domains");

}


#Executing main functions

resolve_domain(cp_domains());

#Pretty printing

sub print_warning {

	my $text = shift // '';
	return if $text eq '';

	print BOLD RED ON_BLACK '[WARN] *';
	print BOLD WHITE ON_BLACK "$text\n";

}

sub print_information {

	my $text = shift // '';
	return if $text eq '';

	print BOLD GREEN ON_BLACK '[INFO] *';
	print BOLD WHITE ON_BLACK "$text\n";

}

#Get domains into hash

sub cp_domains {
	
	open(my $fh, $domainFile) or die "Coult not open file '$domainFile'";
		while (my $row = <$fh>) {
			chomp $row;
			my @domain = split /:/, $row;
			#print Dumper @domain[0];
			resolve_domain($domain[0]);	
	}		
	close($fh);
}


#Resolving the domain

sub resolve_domain {

my $name_server1 = '8.8.8.8';
my $name_server2 = '8.8.4.4';

	#for test
	my $res = Net::DNS::Resolver->new;
	my $query = $res->search(@_);
 	#print Dumper $query;
	my $result;

		if($query) {
			
			foreach my $rr ($query->answer) {
				
				if($rr->type eq "A") {
				
					$result = $rr->address;
						
				}
				
				if($result) {
			
					print_information("@_ : $result");	
					return $result;
				} else { say "FAILED";   }
								
			}
		}		
}

#Get server's IP


