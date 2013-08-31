parents.simpleness.org
======================

Parental control script. Forbid porno sites on linux.


Description:

This short program will block adult web-sites on linux OS.

After you have opened the website, the program is catch a domain name and check the contents of the home page.

If more than 15 bad word will be on the main page, the site will banned (add domain name with 127.0.0.1 in /etc/hosts).

Install (for Ubuntu/Debian users):

    echo "deb http://parents.simpleness.org/deb ./" | sudo tee -a /etc/apt/sources.list 
    sudo apt-get update
    sudo apt-get install parents

Pre-install:

    wget https://raw.github.com/ivanoff/parents.simpleness.org/master/parents.t
    sudo perl parents.t

Install:

    wget -q -U "install" -O - parents.simpleness.org | sudo bash - 

or

    curl -A "install" parents.simpleness.org 2>/dev/null | sudo bash - 

or

    wget https://raw.github.com/ivanoff/parents.simpleness.org/master/parents -O /tmp/parents | sudo perl /tmp/parents install

or download parents and run: sudo perl parents install

Usage:  ./parents (parameters) [black|white] [domain name]

Command line parameters:

    start       start parents agent

    stop        stop parents agent

    restart     restart parents agent

    status      show current status

    list        list all domains

    add         add domain to black or white list

    delete      delete domain from black or white list

    install     install programm

    help        show this help

Example:

    ./parents status

    ./parents list

    ./parents list black simple.*

    ./parents add white simpleness.org

    ./parents delete black analytics.google.com

F.A.Q.

Can't locate Test/More.pm in @INC

    sudo yum -y install cpan || sudo apt-get -y install cpan

    sudo cpan Test::More 

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


Tests

OS, passed on: 

    Xubuntu 13.04

    ubuntu-12.04.2

    ubuntu-9.10

    debian-6.0.7

    debian-5.0.10

    CentOS-6.4

    CentOS-5.9

    Fedora-19

    Fedora-15 

Perl version, passed on: 

    perl v5.19.3

    perl v5.18.1

    perl v5.16.3

    perl v5.14.4

    perl v5.12.5

    perl v5.10.1

    perl v5.8.9

    perl v5.6.2 
