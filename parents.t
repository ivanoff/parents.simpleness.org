#!/usr/bin/perl -w

# Simpleness Parents - block adult web-sites on linux OS
# Test script
# more on http://parents.simpleness.org/
# Copyright 2013 Dimitry Ivanov <2@ivanoff.org.ua>
# Licensed under the Apache License, Version 2.0.

use strict;
use Test::More tests => 33;

ok `/usr/sbin/tcpdump -h 2>&1` =~ /tcpdump version/i, 'find /usr/sbin/tcpdump';
ok `wget --help` =~ /--output-document/i, 'find wget';

ok !$>, "must run as root (sudo)";

my $p = '/tmp/parents';

`wget -q https://raw.github.com/ivanoff/parents.simpleness.org/master/parents -O $p`;

ok -f $p, "parents downloaded";
ok -s $p, "parents file not empty";

`chmod +x $p`;
ok -x $p, "can execute parents";

ok `$p 2>&1` =~ /parents.simpleness.org/i, "program without errors";

ok system ("$p start 2>&1" =~ /Running/), "program is started";
ok system ("$p status 2>&1" =~ /Running/), "program is still started";
ok system ("$p stop 2>&1" =~ /Stopped/), "program is stopped";
ok system ("$p status 2>&1" =~ /Stopped/), "program is still stopped";

my $pid_fork = fork();
`$p start 2>/dev/null` unless $pid_fork;

if ($pid_fork) {
    sleep 2;
    ok system ("$p status 2>&1" =~ /Running/), "program is started";

    ok `wget -q http://el-ladies.com -O -` =~ /sex/i, "download adult content";
    `wget -q http://el-ladies.com -O - >/dev/null` for 1..4;
    sleep 5;
    ok `$p list black` =~ /el-ladies.com/, "adult content catched";
    ok `grep el-ladies.com /etc/hosts` =~ /el-ladies.com/, "adult content banned";
    `$p delete el-ladies.com`;
    ok `$p list black` !~ /el-ladies.com/, "adult site removed from blacklist";
    ok `grep el-ladies.com /etc/hosts` !~ /el-ladies.com/, "adult content unbanned";

    ok `wget -q http://ivanoff.org.ua -O -` !~ /sex/i, "download non-adult content";
    `wget -q http://ivanoff.org.ua -O - >/dev/null` for 1..4;
    sleep 5;
    ok `$p list white` =~ /ivanoff.org.ua/, "non-adult content catched";
    ok `grep ivanoff.org.ua /etc/hosts` !~ /ivanoff.org.ua/, "non-adult content not banned";
    `$p delete ivanoff.org.ua`;
    ok `$p list white` !~ /ivanoff.org.ua/, "non-adult site removed from whitelist";
    ok `grep ivanoff.org.ua /etc/hosts` !~ /ivanoff.org.ua/, "non-adult content still not banned";

    `$p add black el-ladies.com`;
    ok `$p list black` =~ /el-ladies.com/, "adult content catched";
    ok `grep el-ladies.com /etc/hosts` =~ /el-ladies.com/, "adult content banned";
    `$p delete el-ladies.com`;
    ok `$p list black` !~ /el-ladies.com/, "adult site removed from blacklist";
    ok `grep el-ladies.com /etc/hosts` !~ /el-ladies.com/, "adult content unbanned";

    `$p add white ivanoff.org.ua`;
    ok `$p list white` =~ /ivanoff.org.ua/, "non-adult content catched";
    ok `grep ivanoff.org.ua /etc/hosts` !~ /ivanoff.org.ua/, "non-adult content not banned";
    `$p delete ivanoff.org.ua`;
    ok `$p list white` !~ /ivanoff.org.ua/, "non-adult site removed from whitelist";
    ok `grep ivanoff.org.ua /etc/hosts` !~ /ivanoff.org.ua/, "non-adult content still not banned";

    $p =~ s/parents$/sites/;
    ok -f $p, "parents data was created";
    ok -s $p, "parents data file not empty";

    ok system ("$p status 2>&1" =~ /Stopped/), "program is stopped";

    #clear
    $p =~ s/sites$/parents/;
    `$p stop 2>/dev/null`;
    `rm $p`;
    $p =~ s/parents$/sites/;
    `rm $p`;
}
