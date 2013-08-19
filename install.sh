#!/bin/bash

echo installing Simpleness Parental Control
echo more on http://parents.simpleness.org

folder=/opt/parents     # main folder of the program on local computer
name=parents            # name of the program on local computer

mkdir -p $folder        # create folder 
chown root:root $folder # only root is owner and group owner
chmod 0740 $folder      # nobody else can't enter to this folder

# download last version from GitHub and make it runuble
curl https://raw.github.com/ivanoff/parents.simpleness.org/master/parents.pl >$folder/$name 2>/dev/null
chmod +x $name

# run on start computer ( if not done yet )
grep $folder/$name /etc/rc.local || echo /usr/bin/perl $folder/$name start >> /etc/rc.local

