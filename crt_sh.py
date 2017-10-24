#!/bin/env python
# numbshiva
# query crt.sh to find a list of domains based on certificate issued

import requests
import os
import sys
import re
import argparse
from urlparse import urlparse
from urlparse import parse_qs

results_file = open('results.txt','w')

banner =  "\n########################################################################\n"
banner += "                    crt.sh domain finder                                  \n"
banner += "########################################################################\n"

if len(sys.argv) > 1:
	domain=sys.argv[1]
	print banner

	print "[+] Domain set to: {0}".format(domain)
	print "[+] Querying crt.sh for related certificates..."
	try:
		result = requests.get("https://crt.sh/?q=%25"+domain)
		results_file.write(result.text)

	except Exception,e:
		sys.exit(e)
	url = os.system("grep '.*%s' results.txt | tr -d '<TD>|</TD>' | sort | uniq >> urls.txt" % (str(domain)))
	os.system("cat urls.txt")
	results_file.close()

	print "\n[+] Completed. Check urls.txt for a list of addresses.\n"
	
else:
	banner += "\n[!] Error! Usage: {0} <domain>\n".format(sys.argv[0])
	print banner