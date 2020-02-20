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


return unless -e $domainFile && -e $iscPanel or die("Not a cPanel server");

#Executing main functions

#Pretty printing

sub print_warning {

my $text = shift // '';
    return if $text eq '';
    print BOLD WHITE ON_BLACK "\\_$text\n";
}

sub print_information {
    my $text = shift // '';
    return if $text eq '';

    print BOLD WHITE ON_BLACK "\\_$text\n";
}

#Compare domain's IP

output();

sub output {

#Assigning hash references
 my ($r_hosted, $l_hosted) = compare_domain();
    
 #Printing the remote domains
    if(defined($r_hosted)) {
        print BOLD RED ON_BLACK "[WARN] Domains not pointing to the server:\n";
        
        for my $remote (keys %$r_hosted) {
        print_warning("$remote: $r_hosted->{$remote}");
        
        }
    }

 #Printing the local domains
    if(defined($l_hosted)) {
    
        print BOLD GREEN ON_BLACK "[INFO] Domains pointing to the server:\n";
        for my $local (keys %$l_hosted) {
        print_information("$local: $l_hosted->{$local}");
        
        }
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
                $locally_hosted{$domain} = $server_ip;
                 
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
 
#Prevent duplicated output

    foreach my $de_duplicated(keys %locally_hosted) {
        foreach my $duplicated(keys %remote_domain) {
            if($de_duplicated eq $duplicated){

                delete $remote_domain{$de_duplicated};

            }
        }
    }     


#print Dumper %remote_domain;
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
    
    open(my $FH, $domainFile) or die "Coult not open file '$domainFile'";
        while (my $row = <$FH>) {
          chomp $row;
          my @domain = split /:/, $row;
          push(@domains, @domain); 
    }
    close($FH);
    return @domains;
}

#Get server's IP

sub get_servip {

    #Modify the function to look for NAT IPs
    my @ips = ();
    my @public_ip = ();
    my %ip = ();
    my $cpnat_file = '/var/cpanel/cpnat';
    if(-e $cpnat_file) {

        open FH, '<', $cpnat_file or die "Could not open file '$cpnat_file'";
        while (my $row = <FH>) {
            chomp $row;
                push(@ips, $row);
        }  
        foreach my $ip(@ips) {
            %ip = split /\s+/, $ip;
            push(@public_ip, values %ip); 
        }
        close $cpnat_file;
        return @public_ip;
    }       
    else {
        my @interfaces = IO::Interface::Simple->interfaces;
        for my $if (@interfaces) {
        push(@ips, $if->address); 
        }   
     return @public_ip = grep(!/127\.0\.0\.1/, @ips);
    }
}
