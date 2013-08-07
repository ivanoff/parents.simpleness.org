#!/usr/bin/perl -w

use strict;
use Storable;
use WWW::Mechanize;

$| = 1;
my $dir = ( $0 =~ m%^(.*/)% )[0];
my $store = $dir.'sites';
my $sites = -f $store? retrieve( $store ) : {};
my $mech = WWW::Mechanize->new();

open (STDIN,"/usr/sbin/tcpdump 'port 80' -vvvs 1024 -l -A |");
while (<STDIN>) {
    next unless /Host: (\S+)\s$/;
    my $_ = $1;
    next if $sites->{white}{$_};
    eval{ $mech->get( 'http://'.$_ ) };
    my $c = $mech->content();
    if ( 15 < $c =~ s/p[o0]rn[o0]?|sex|anal|tits|harcore|cumshots|blowjob|lesbian|pusy|fucking|orgasm|pissing//ig ) {
        if( !$sites->{black}{$_} ) {
            open my $f, '>>', '/etc/hosts';
            print {$f} "\n127.0.0.1\t$_";
            close $f;
            `/usr/bin/killall firefox`;
        }
        $sites->{black}{$_} = 1;
    } else {
        $sites->{white}{$_} = 1;
    }
    store $sites, $dir.'/sites';
}
