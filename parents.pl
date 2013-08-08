#!/usr/bin/perl -w

use strict;
use Storable;
use WWW::Mechanize;

die &help_message if !@ARGV || $ARGV[0] =~ /^-*h(elp)?$/;       #show help message

$| = 1;                                 #forces a flush right away
my $dir = ( $0 =~ m%^(.*/)% )[0];       #where we're located
my $store = $dir.'sites';               #path to hash storable file with domains
my $sites = -f $store? retrieve( $store ) : {};     #retrieve previous domain names
my $mech = WWW::Mechanize->new();

$_ = $ARGV[0];

/^list$/ && do {
    die "there is no information about domains" unless $sites;
    foreach my $type ( keys %$sites ) {
        next if $ARGV[1] && $ARGV[1] ne $type;
        print "$type :\n";
        foreach my $name ( keys %{$sites->{$type}} ){
            next if $ARGV[2] && $ARGV[2] !~ /$name/i;
            print "\t$name\n";
        }
    }
}

/^add$/ && do {
    die "need type and domain name. type $0 -h for more info" unless $ARGV[2];
    die "type is not acceptable. type $0 -h for more info" if $ARGV[1] !~ /^black|white$/;
    $sites->{$ARGV[1]}{$ARGV[2]} = 1;
    store $sites, $store;
}

/^start$/ && do {
#we will read tcpdump's output on port 80 to find Host with domain name
open (STDIN,"/usr/sbin/tcpdump 'port 80' -vvvs 1024 -l -A |");
while (<STDIN>) {
    next unless /Host: (\S+)\s$/;
    my $_ = $1;
    next if $sites->{white}{$_} || $sites->{black}{$_}; #skip if we already found domain name before
    eval{ $mech->get( 'http://'.$_ ) };                 #download the website's homepage to find bad words
    my $c = $mech->content();
    #if we found more than 15 bad words, then ban it
    $sites = -f $store? retrieve( $store ) : {};     #retrieve previous domain names again after slow download
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
    store $sites, $store;
}
}

sub help_message {
<<EOF;
Block adult sites. 
More on parents.simpleness.org
Usage:  $0 (parameters) [black|white] [domain name]
Command line parameters:
    start       start parents agent
    stop        stop parents agent
    restart     restart parents agent
    status      show current status
    list        list all domains
    add         add domain to black or white list
    delete      delete domain from black or white list
    --help   show this help
Example:
    $0 status
    $0 list
    $0 list black simple.*
    $0 add white simpleness.org
    $0 delete black ivanoff.org.ua
EOF
}

