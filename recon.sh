#!/bin/bash

# host recon tool
# uses nmap, enum4linux to check host

# setup variables
target=$1
nmap=`which nmap`
e4l=`locate enum4linux.pl`
cme=`which cme`
cme_command="--local-auth --shares --sessions --users --lusers --pass-pol"
working_dir=$PWD

# check if target IP supplied at cmdline
if [ -z ${target} ]; then
	echo ""
	echo "[**] Error! Target IP not set!"
	echo ""
	exit 1
fi

# check if enum4linux is unstalled, optional check for crackmapexec
if [ -z "$e4l" ]
	then echo "[-] enum4linux not found - is it present?"
	exit 1
fi
if [ -z "$cme" ]
	then echo "[-] crackmapexec does not appear to be present, will be skipped."
elif [ -n "$cme" ]
	then echo "[+] CME found, will be included in recon."
fi

# confirm variables with user
echo ""
echo "[+] Target set to $target"
echo "[+} nmap located at $nmap"
echo "[+] enum4linux located at $e4l"
echo ""

# echo "[+] Starting nmap scan"
echo "[+] Getting open ports."

# run nmap
nmap -T4 -p- -oN nmap.txt $target
grep "open" nmap.txt | awk {'print $1'} | awk -F/ {'print $1'} > ports.txt && cat ports.txt | tr '\n' ',' > open.txt
echo ""
echo "[+] Performing service scan on open ports."
echo ""
nmap -T4 -sV -sC -p `cat open.txt` -oN banners.txt $target && grep "open" banners.txt > banners1.txt && mv banners1.txt banners.txt
rm ports.txt open.txt

# check if smb open and if so offer to scan for vulns
grep -q "445/tcp   open" nmap.txt
if [ $? -eq 0 ] ; then 
	echo ""
	read -p "[+] Port 445 (SMB) is open, would you like to scan for vulnerabilities using nse engine? (y/n) " yn
	case $yn in
		[Yy]* ) nmap -T 4 -sV -sC -p 135,139,445 --script=smb-vuln-cve-2017-7494,smb-vuln-cve2009-3103,smb-vuln-ms06-025,smb-vuln-ms07-029,smb-vuln-ms08-067,smb-vuln-ms10-054,smb-vuln-ms10-061,smb-vuln-ms17-010 -oN smb-vulns.txt $target;;
		[Nn]* ) echo "[-] You have elected not to scan for common SMB vulns, skipping.";;
		esac
fi


echo ""

# check if open smb found
grep -q "445/tcp   open" nmap.txt
if [ $? -eq 0 ]	; then 
	echo "[+] 445 is open, using Enum4Linux to test for null sessions."
	echo ""
	$e4l -a $target | tee enum4linux.txt
else
	echo "[**] 445 not open! Skipping enum4linux!"
fi

# check if user and password files found, and if so run cme
echo ""
if [ -n "$cme" ]
	then if [ ! -f ./users.txt ]
		then echo "[**] User list 'users'.txt' not present, unable to proceed!"
		exit 1
	fi
	
	if [ ! -f ./pass.txt ]
		then echo "[**] Password list 'pass.txt' not present, unable to proceed!"
	fi
	
	echo "[+] Starting crackmapexec user, sessions and shares enumeration with provided creds."
	echo "[!] WARNING: Ensure you don't inadvertently lock user accounts on the target machine!"
	echo ""
	
	# for user in `cat users.txt`; do for pass in `cat pass.txt`; do $cme $target -u $user -p $pass $cme_command | tee cme_output.txt;done;done 
	$cme smb $target -u $working_dir/users.txt -p $working_dir/pass.txt $cme_command | tee cme_output.txt

	echo ""
	echo "[+] CME complete."
fi

# display open ports to users
echo ""
echo "[+] Here are the open ports:"
grep -E "/tcp.*open" banners.txt

echo ""

# check if admin creds found from cme
grep -qa "Pwn3d" cme_output.txt
if [ $? -eq 0 ] ; then
	echo "[+] Admin credentials found!"
	grep -a "Pwn3d" cme_output.txt
else
	echo "[-] Admin credentials not found."
fi

echo ""

echo "[+] Done."
