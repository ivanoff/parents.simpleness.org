parents.simpleness.org
======================

Parental control script. Forbid porno sites on linux.


Description:

This short program will block adult web-sites on linux OS.

After you have opened the website, the program is catch a domain name and check the contents of the home page.

If more than 15 bad word will be on the main page, the site will banned (add domain name with 127.0.0.1 in /etc/hosts).

Install:

curl parents.simpleness.org 2>/dev/null | sudo bash - 

or

wget -q -O - "$@" https://raw.github.com/ivanoff/parents.simpleness.org/master/install.sh | sudo bash -

or download install.sh and run: 

sudo ./install.sh

F.A.Q.

bash: sudo: command not found 

su -

apt-get -y install sudo || yum -y install sudo 

UserName is not in the sudoers file

su -

echo "UserName ALL=(ALL) ALL" >> /etc/sudoers 

Another app is currently holding the yum lock

sudo rm -f /var/run/yum.pid

-bash: curl: command not found

sudo apt-get -y install curl || sudo yum -y install curl 


Tested on:

good: 

CentOS-6.4-i386

debian-6.0.7-i386

ubuntu-12.04.2-server

bad: 

Fedora-15-i386 ( add to /etc/rc.local faled )
