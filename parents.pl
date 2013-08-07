#!/usr/bin/perl -w

use strict;
use Storable;
use WWW::Mechanize;

$| = 1;                                 #forces a flush right away
my $dir = ( $0 =~ m%^(.*/)% )[0];       #where we're located
my $store = $dir.'sites';               #path to hash storable file with domains
my $sites = -f $store? retrieve( $store ) : {}; #retrieve previous domain names
my $mech = WWW::Mechanize->new();

#we will read tcpdump's output on port 80 to find Host with domain name
open (STDIN,"/usr/sbin/tcpdump 'port 80' -vvvs 1024 -l -A |");
while (<STDIN>) {
    next unless /Host: (\S+)\s$/;
    my $_ = $1;
    next if $sites->{white}{$_} || $sites->{black}{$_}; #skip if we already found domain name before
    eval{ $mech->get( 'http://'.$_ ) }; #enter to the website to find bad words
    my $c = $mech->content();
    #if we found more than 15 bad words, then ban it
    if ( 15 < $c =~ s/p[o0]rn[o0]?|sex|anal|tits|harcore|cumshots|blowjob|lesbian|pusy|fucking|orgasm|pissing//ig ) {
        if( !$sites->{black}{$_} ) {
            open my $f, '>>', '/etc/hosts';     #write black domain name to /etc/hosts to ban
            print {$f} "\n127.0.0.1\t$_";
            close $f;
        }
        $sites->{black}{$_} = 1;
    } else {
        $sites->{white}{$_} = 1;
    }
    store $sites, $dir.'/sites';
}
