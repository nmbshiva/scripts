#!/bin/bash

# requires sublister, nmap, gobuster

if [ -z "$1" ]
	then echo "No target supplied. Make sure to supply the target when calling the script." && echo ""
exit 1; fi

hostalive(){
	cat domains.txt | sort -u | while read line; do
		if [ $(curl --write-out %{http_code} --silent --output /dev/null -m 5 $line) = 000 ];
		then
		  echo "$line was unreachable" | tee -a unreachable-$(date +"%Y-%m-%d").txt
		else
		  echo "$line is up" | tee -a responsive-$(date +"%Y-%m-%d").txt
		fi
	done
	cat responsive-$(date +"%Y-%m-%d").txt | awk -F' is' ' { print $1 } ' | tee -a up.txt
}

sublister(){
	python ~/tools/Sublist3r/sublist3r.py -d $target -o sublister.txt
}

certspotter(){
	curl -s https://certspotter.com/api/v0/certs\?domain\=$target | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $1 | tee -a certspotter.txt
}

crt(){
	curl 'https://crt.sh/?q=%25.dropbox.com&output=json' | jq .name_value | awk -F '"' ' { print $2 } ' | sort -u | sed 's/\*\.//' | tee -a crt.txt
}

recon(){
	for line in $(cat up.txt); do
		nmap -sV -T4 -Pn -p 80,3868,3366,8443,8080,9443,9091,3000,8000,5900,8081,6000,10000,8181,3306,5000,4000,8888,5432,15672,9999,161,4044,7077,4040,9000,8089,443,7447,7080,8880,8983,5673,7443 $line -oN $line.nmap;
	done
	for line in $(cat up.txt); do
		gobuster -w ~/tools/SecLists/Discovery/Web-Content/mega.txt -u $line -o gobuster_$line.txt -t 20 -f;
	done
	python ~/tools/webscreenshot/webscreenshot.py -i up.txt -m -o `pwd`
}

getDNS(){
	echo "$1 DNS servers are:"
	dig $1 NS | grep -E 'NS\s' | awk -F ' ' ' { print $5 } ' | tee -a target_dns.txt
}

echo ""
echo "Attack Recon. Not silent. If red teaming, do so carefully (ie. probably not this tool..)"
echo ""

target=$1

mkdir $target; cd $target

# find subdomains
	# run sublister to get domains
echo "Running Sublister to brute force subdomains."
sublister $target
	
	# run certspotter
echo "Using certspotter to get a list of subdomains."
certspotter $target

echo "Using crt.sh to get a list of subdomains."
crt $target

echo ""
echo "Done. Checking for live hosts."
hostalive

echo ""
echo "Starting recon. This may take a while."
recon

echo ""
getDNS

cat sublister.txt certspotter.txt crt.txt >> domains.txt

for sub in $(cat domains.txt);
	do
		echo $sub;
		if host "$sub" > /dev/null; then
			echo "$sub is live" && echo "$sub" >> live.txt;
		else
			echo "$sub not live" && echo "$sub" >> notlive.txt;
		fi
	done
