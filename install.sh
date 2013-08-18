#!/bin/bash

name=/opt/parents/parents.pl

mkdir -p /opt/parents

curl https://raw.github.com/ivanoff/parents.simpleness.org/master/parents.pl >$name 2>/dev/null

chmod +x $name

grep $name /etc/rc.local || echo /usr/bin/perl $name >> /etc/rc.local

