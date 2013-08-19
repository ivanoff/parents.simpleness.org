#!/bin/bash

# Simpleness Parents - block adult web-sites on linux OS
# Installing module
# more on http://parents.simpleness.org/
# Copyright 2013 Dimitry Ivanov <2@ivanoff.org.ua>
# Licensed under the Apache License, Version 2.0.

echo "Installing Simpleness Parental Control"
echo "More on http://parents.simpleness.org"

# check for root privileges
if [ "$(id -u)" != "0" ]; then
   echo "Error: This script must be run as root" 1>&2
   exit 1
fi

# need curl for download file
yum -y install curl || apt-get -y install curl

folder=/opt/parents     # main folder of the program on local computer
name=parents            # name of the program on local computer

mkdir -p $folder        # create folder 
chown root:root $folder # only root is owner and group owner
chmod 0740 $folder      # nobody else can't enter to this folder

# download last version from GitHub and make it runuble
curl https://raw.github.com/ivanoff/parents.simpleness.org/master/parents.pl >$folder/$name 2>/dev/null
chmod +x $folder/$name

# run on start computer ( if not done yet )
grep $folder/$name /etc/rc.local || echo /usr/bin/perl $folder/$name start >> /etc/rc.local

echo "Program installed if was not errors";
