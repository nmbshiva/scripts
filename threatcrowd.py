#!/bin/env python

instr = "\n[=] Queries threatcrowd.org for domain provided." \
	"\n[=] Pretty prints json response." \
	"\n[=] Writes response to file in same directory as script." \
	"\n"

import requests
import json
import sys
from datetime import datetime

print instr

if len(sys.argv) < 2:
	sys.exit("[!] Error! No domain specified!\n")

f = open(sys.argv[1]+'.txt', 'w')
log = open('log.txt', 'w')
i = datetime.now()

print "[+] Started at {0}".format(i.strftime("%H:%M:%S %d/%m/%Y"))
print "[+] Querying domain {0}, please wait.\n".format(sys.argv[1])

try:
	
	result =  requests.get("http://www.threatcrowd.org/searchApi/v2/domain/report/", \
	params = {"domain": sys.argv[1]})

	data = json.loads(result.text)
	print "[+] Written to file {0}.txt.".format(sys.argv[1])
	urls = json.loads(result.text)
	print "[+] Subdomains found:\n"
#	f.write("[+] Subdomains found:\n")
	for url in urls["subdomains"]:
		print "	-> {0}".format(url)
		f.write(url + "\n")
	print "\n"
	log.write("\n<!-- "+ i.strftime("%H:%M:%S %d/%m/%Y") +" -->\n")
	log.write(json.dumps(data, indent=4, sort_keys=True))
	log.write("\n")

	f.close()
	log.close()

except Exception,e:
	print e
#	print "[!] Oops! Something went wrong!\n"
	f.close()
	sys.exit(0)