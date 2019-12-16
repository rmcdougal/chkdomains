#!/usr/bin/perl

#Module declaration
use strict;
use warnings;

#Validatin cPanel installation and that the server has accounts.

my $domainFile = '/etc/userdomains';
my $iscPanel = '/usr/local/cpanel/version';


if (-e $domainFile && -e $iscPanel ) {
	
	print "Files are there";

} else {

	print "This script would be useful on cPanel servers with valid accounts\n";

}
