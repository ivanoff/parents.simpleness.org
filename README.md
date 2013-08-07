parents.simpleness.org
======================

parents control. forbid porno sites on linux.

Description:
This short program will block adult web-sites on linux OS.
After you have opened the website, the program is catch a domain name and check the contents of the home page.
If more than 15 bad word will be on the main page, the site will banned (add domain name with 127.0.0.1 in /etc/hosts).

Install:
cpan WWW::Mechanize
cpan Storable
sudo mkdir /opt/parents
sudo mv parents.pl /opt/parents/

to run automaticly, insert into /etc/rc.local: "/usr/bin/perl /opt/parents/parents.pl" without quotes before "exit 0" line

