#!/usr/bin/perl

#Module declaration
use strict;
use warnings;
use Data::Dumper;
use Term::ANSIColor qw(:constants);
use Net::DNS;
use IO::Interface::Simple;

#Reset the terminal to default colors when finished.
$Term::ANSIColor::AUTORESET = 1;

#Validatin cPanel installation and that the server has accounts.

my $domainFile = '/etc/userdomains';
my $iscPanel = '/usr/local/cpanel/version';


if (-e $domainFile && -e $iscPanel ) {
    
  my $iscP='1'; #For later use.

} else {

    print_warning("This script is only useful on cPanel servers with valid domains");

}

#Executing main functions

resolve_domains(cp_domains(compare_domain()));

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


#Compare domain's IP

compare_domain();

sub compare_domain {
    my $dip = shift @_;
    my $sip = shift @_;

}

#Resolve domains

sub resolve_domains {
    my @domain = @_;
    my $nameserver = '8.8.8.8';
    my $resolver = Net::DNS::Resolver->new;
    my $query;
    my $ip;

    foreach(@domain) {

        $query = $resolver->search($_);    
        if($query) {
            foreach my $rr($query->answer) {
                if($rr->type eq "A") {
                    my $ip = $rr->address;
                    compare_domain($ip);
                    next;
                }

            }    
        }
    }    
}

#Get domains into hash

sub cp_domains {
    open(my $fh, $domainFile) or die "Coult not open file '$domainFile'";
        while (my $row = <$fh>) {
          chomp $row;
          my @domain = split /:/, $row;
          resolve_domains($domain[0]);   
        }
    close($fh);
}

#Get server's IP

sub get_servip {
   
    my @public_ip = ();
    my @ips = ();
    my @interfaces = IO::Interface::Simple->interfaces;
    for my $if (@interfaces) {
        push(@ips, $if->address); 
    }
    return unless @public_ip = grep(!/127\.0\.0\.1/, @ips);
    compare_domain(@public_ip);

}



