parents.simpleness.org
======================

Parental control script. Forbid porno sites on linux.


Description:

This short program will block adult web-sites on linux OS.

After you have opened the website, the program is catch a domain name and check the contents of the home page.

If more than 15 bad word will be on the main page, the site will banned (add domain name with 127.0.0.1 in /etc/hosts).

Install:

curl parents.simpleness.org | sudo bash - 

or

wget -q -O - "$@" https://raw.github.com/ivanoff/parents.simpleness.org/master/install.sh | sudo bash -

or download install.sh and run: 

sudo ./install.sh
