#!/usr/bin/perl -w

# Simpleness Parents - block adult web-sites on linux OS
# Main script
# more on http://parents.simpleness.org/
# Copyright 2013 Dimitry Ivanov <2@ivanoff.org.ua>
# Licensed under the Apache License, Version 2.0.

use strict;
use Storable;
use utf8;

die &help_message if !@ARGV || $ARGV[0] =~ /^-*h(elp)?$/;       # show help message

die "Error: Must run as root (sudo $0 ".(join ' ', @ARGV).")\n" if $>;

$| = 1;                                         # forces a flush right away
my $agent = "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:23.0) Gecko/20100101 Firefox/23.0"; #wget agent
my $pid = &get_pid;
my $dir = ( $0 =~ m%^(.*/)% )[0];               # where we're located
my $store = $dir.'sites';                       # path to hash storable file with domains
my $sites = -f $store? retrieve( $store ) : {}; # retrieve previous domain names

$_ = $ARGV[0];

# List domains
/^list$/ && do {
    die "there is no information about domains" unless $sites;
    foreach my $type ( keys %$sites ) {
        next if $ARGV[1] && $ARGV[1] ne $type;
        print "$type:\n";
        foreach my $name ( sort keys %{$sites->{$type}} ){
            next if $ARGV[2] && $ARGV[2] !~ /$name/i;
            print "\t$name\n";
        }
    }
};

# Add domains to the list
/^add$/ && do {
    &need_bw( $ARGV[1] );
    &need_name( $ARGV[2] );
    $sites->{$ARGV[1]}{$ARGV[2]} = 1;
    store $sites, $store;
    hosts( 'add', $ARGV[2] );
    $ARGV[1]=($ARGV[1] eq 'black')? 'white' : 'black';  # trick - delete domain from oposite side
    $_ = 'delete';
};

# Delete domains from the list
/^delete$/ && do {
    &need_name( $ARGV[1] );
    delete $sites->{$_}{$ARGV[1]} foreach 'white', 'black';
    store $sites, $store;
    hosts( 'delete', $ARGV[1] );
};

# Restart the programm
/^restart$/ && do {
    $_ = 'stop-';       # trick - stop/start operations 
};

# Stop the programm
/^stop(-)?$/ && do {
    `kill $pid` if $pid;
    $pid = &get_pid;
    $_ = ($1)? 'start' : 'status';      # start (in case of restart's trick)
};

# Start the programm
/^start$/ && do {
    die "Already running!\n" if $pid;
    my $pid_fork = fork();
    if ($pid_fork) {
        $_ = 'status';          # lets show status after start
    } else {
        # main parents programm
	$0 = $0.' started';     # rename runned process for get_pid subroutine
	# We will read tcpdump's output on port 80 to find Host with domain name
        open (STDIN,"/usr/sbin/tcpdump 'port 80' -vvvs 1024 -l -A -i any |");
        while (<STDIN>) {
            next unless /Host: (\S+)\s$/;                   # We are looking for domainname after 'Host:'
            my $d = $1;
            next if $sites->{white}{$d} || $sites->{black}{$d}; # skip if we already found domain name before

            # download the website's homepages/refreshes to find bad words
            my $c = `wget -q -U "$agent" -O - http://$d `;
            $c = `wget -q -U "$agent" -O - http://$d/$1` while $c =~ /meta.*?http-equiv="Refresh".*?content=".*?URL=(.*?)"/i;

            $sites = -f $store? retrieve( $store ) : {};    # retrieve previous domain names again after slow sites
            if ( 15 < $c =~ s/p[o0]rn[o0]?|sex|anal\b|tits|harcore|cumshots|blowjob|lesbian|pusy|fucking|orgasm|pissing|pussy|порно|секс//ig ) {
                hosts('add', $d);                           # if we found more than 15 bad words, then ban site
                $sites->{black}{$d} = 1;
        	`killall firefox`;                          # `killall opera`; 
        	`killall chromium-browser`;                 # or whatever your are
            } else {
                $sites->{white}{$d} = 1;                    # if not found, then store domainname as white site
            }
            store $sites, $store;
        }
        exit(0);
    }
};

# show staturs of the programm
/^status$/ && do {
    $pid = &get_pid;
    die ( ($pid)? "Running [PID $pid]\n" : "Stopped\n" );
};

# Add or delete hostname from /etc/hosts
# Parameters are command and domain name.
sub hosts {
    my( $t, $name ) = @_;
    $t=~/^delete$/ && do {
        open my $f, '<', '/etc/hosts';
        my @records = <$f>;
        close $f;
        @records = grep { !/\Q127.0.0.1\E\s+\Q$name\E$/i } @records;

	open $f, '>', '/etc/hosts';
        print {$f} @records;
	close $f;
    };
    $t=~/^add$/ && do {  
	open my $f, '>>', '/etc/hosts';
	print {$f} "\n127.0.0.1\t$name";  
	close $f;
    };
}

# Returns PID of running parents.pl process
sub get_pid {
    `ps aux | grep parents | grep started | grep -v grep | awk '{printf "%d", \$2}'`;
}

# Dies if parameter is not black or white
sub need_bw {
    die "list type is not acceptable, only black or white. '$0 -h' for more info" if $_[0] !~ /^black|white$/;
}

# Dies unless parameter
sub need_name {
    die "need domain name. '$0 -h' for more info" unless $_[0];
}

# Help message
sub help_message {
<<EOF;
Block adult sites. 
More on parents.simpleness.org
Usage:  $0 {parameters} [black|white] [domain name]
Command line parameters:
    start       start parents agent
    stop        stop parents agent
    restart     restart parents agent
    status      show current status
    list        list all domains
    add         add domain to black or white list
    delete      delete domain from black or white list
    help        show this help
Example:
    $0 status
    $0 list
    $0 list black simple.*
    $0 add white simpleness.org
    $0 delete black analytics.google.com
EOF
}

