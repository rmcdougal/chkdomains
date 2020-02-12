#!/usr/local/cpanel/3rdparty/bin/perl

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

output();

sub output {

 #Assigning hash references
 my ($r_hosted, $l_hosted) = compare_domain();
    
 #Printing the remote domains
    for my $remote (keys %$r_hosted) {

        print_warning(" Not pointing to the server: $remote: $r_hosted->{$remote}");

    }

 #Printing the local domains
 
    for my $local (keys %$l_hosted) {

        print_information(" Pointing to the server: $local: $l_hosted->{$local}");

    }
}

#compare_domain();

sub compare_domain {
  
    my %domain_and_remote_ips = resolve_domains();
    my @server_ips = get_servip();
    my %locally_hosted = ();
    my %remote_domain  = ();

    foreach my $domain(keys %domain_and_remote_ips) {  
        foreach my $server_ip(@server_ips) {
            if($domain_and_remote_ips{$domain} eq $server_ip) {
                $locally_hosted{$domain} = $server_ip
            }
        }
    }   

    foreach my $r_domain(keys %domain_and_remote_ips) {
        foreach my $server_ip(@server_ips) {
            if($domain_and_remote_ips{$r_domain} ne $server_ip) {
                $remote_domain{$r_domain} = $domain_and_remote_ips{$r_domain}; 
            }
        }
    }

 #   print Dumper %remote_domain;
    return(\%remote_domain, \%locally_hosted);

}

#Resolve domains

sub resolve_domains {
    my @domain = cp_domains();
    my $nameserver = '8.8.8.8';
    my $resolver = Net::DNS::Resolver->new;
    my $query;
    my %ips;

    foreach(@domain) {

        $query = $resolver->search($_);    
        if($query) {
            foreach my $rr($query->answer) {
                if($rr->type eq "A") {
                    my $ip = $rr->address;
                    $ips{$_} = $ip;
                }
            }    
        }
    }
    return %ips;    
}

#Get domains into hash

sub cp_domains {
    my @domains = ();
    
    open(my $fh, $domainFile) or die "Coult not open file '$domainFile'";
        while (my $row = <$fh>) {
          chomp $row;
          my @domain = split /:/, $row;
          push(@domains, @domain); 
    }
    close($fh);
    return @domains;
}

#Get server's IP

sub get_servip {
   
    my @public_ip = ();
    my @ips = ();
    my @interfaces = IO::Interface::Simple->interfaces;
    for my $if (@interfaces) {
        push(@ips, $if->address); 
    }
    
   return @public_ip = grep(!/127\.0\.0\.1/, @ips);

}
