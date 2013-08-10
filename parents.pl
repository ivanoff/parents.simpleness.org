#!/usr/bin/perl -w

use strict;
use Storable;
use WWW::Mechanize;

die "Error: Must run as root (sudo $0 ".(join ' ', @ARGV).")\n" if $>;
die &help_message if !@ARGV || $ARGV[0] =~ /^-*h(elp)?$/;       #show help message

$| = 1;                                 #forces a flush right away
my $pid = `ps aux | grep parents.pl | grep started | grep -v grep | awk '{printf "%d", \$2}'`;
my $dir = ( $0 =~ m%^(.*/)% )[0];       #where we're located
my $store = $dir.'sites';               #path to hash storable file with domains
my $sites = -f $store? retrieve( $store ) : {};     #retrieve previous domain names
my $mech = WWW::Mechanize->new();

$_ = $ARGV[0];

/^list$/ && do {
    die "there is no information about domains" unless $sites;
    foreach my $type ( keys %$sites ) {
        next if $ARGV[1] && $ARGV[1] ne $type;
        print "$type:\n";
        foreach my $name ( keys %{$sites->{$type}} ){
            next if $ARGV[2] && $ARGV[2] !~ /$name/i;
            print "\t$name\n";
        }
    }
};

/^add$/ && do {
    &need_bw( $ARGV[1] );
    &need_name( $ARGV[2] );
    $sites->{$ARGV[1]}{$ARGV[2]} = 1;
    store $sites, $store;
    hosts( 'add', $ARGV[2] );
    $ARGV[1]=($ARGV[1] eq 'black')? 'white' : 'black';
    $_ = 'delete';
};

/^delete$/ && do {
    &need_name( $ARGV[1] );
    delete $sites->{$_}{$ARGV[1]} foreach 'white', 'black';
    store $sites, $store;
    hosts( 'delete', $ARGV[1] );
};

/^restart$/ && do {
    $_ = 'stop-';
};

/^stop(-)?$/ && do {
    `kill $pid` if $pid;
    $_ = ($1)? 'start' : 'status';
};

/^start$/ && do {
    die "Already running!\n" if $pid;
    my $pid_fork = fork();
    if ($pid_fork) {
        $_ = 'status';
    } else {
	$0 = $0.' started';
	#we will read tcpdump's output on port 80 to find Host with domain name
        open (STDIN,"/usr/sbin/tcpdump 'port 80' -vvvs 1024 -l -A -i any |");
        while (<STDIN>) {
            next unless /Host: (\S+)\s$/;
            my $_ = $1;
            next if $sites->{white}{$_} || $sites->{black}{$_}; #skip if we already found domain name before
            eval{ $mech->get( 'http://'.$_ ) };                 #download the website's homepage to find bad words
            my $c = $mech->content();
            #if we found more than 15 bad words, then ban it
            $sites = -f $store? retrieve( $store ) : {};     #retrieve previous domain names again after slow download
            if ( 15 < $c =~ s/p[o0]rn[o0]?|sex|anal\b|tits|harcore|cumshots|blowjob|lesbian|pusy|fucking|orgasm|pissing//ig ) {
                hosts('add', $_);
                $sites->{black}{$_} = 1;
            } else {
                $sites->{white}{$_} = 1;
            }
            store $sites, $store;
        }
        exit(0);
    }
};

/^status$/ && do {
    die ( ($pid)? "Running [PID $pid]\n" : "Stopped\n" );
};

sub hosts {
    my( $_, $name ) = @_;
    /^delete$/ && do {
        open my $f, '<', '/etc/hosts';
        my @records = <$f>;
        close $f;
        @records = grep { !/\Q127.0.0.1\E\s+\Q$name\E$/i } @records;

	open $f, '>', '/etc/hosts';
        print {$f} @records;
	close $f;
    };
    /^add$/ && do {  
	open my $f, '>>', '/etc/hosts';
	print {$f} "\n127.0.0.1\t$name";  
	close $f;
    };
}

sub need_bw {
    die "list type is not acceptable, only black or white. '$0 -h' for more info" if $_[0] !~ /^black|white$/;
}

sub need_name {
    die "need domain name. '$0 -h' for more info" unless $_[0];
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

