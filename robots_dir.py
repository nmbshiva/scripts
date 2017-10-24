#!/bin/env/python

# ROBOTS PARSER FOR CONTENT
# twitter.com/numbshiva

###############################################################

import urllib
import urllib2
import os
import sys
import requests

banner = ("\n|==============================================================================|\n"
	      "|                            robots sub-dir grabber                            |\n"
          "|==============================================================================|\n")

usage = "[!] Usage: {0} <domain>".format(sys.argv[0])
headers = {'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.79 Safari/537.36 Edge/14.14393'}

print banner

if len(sys.argv) > 1:
	if not sys.argv[1].startswith("https://www."):
		domain = "https://www."+sys.argv[1]
	else:
		domain = sys.argv[1]
else:		
	print "[!] Error! \n{0}".format(usage)
	sys.exit(0)

robots = domain + "/robots.txt"
results = open('results.txt', 'w')

print "[+] Domain to test: {0}".format(domain)

result = os.popen("curl -s " + robots).read()
result_data_set = {"disallow":[], "allow":[]}

for line in result.split("\n"):
	if line.startswith('allow'):
		print "[+] Allowed sub-dir found: {0}".format(line.split(': ')[1].split(' ')[0])
	elif line.lower().startswith('disallow'):
		test_url = domain + line.split(': ')[1].split(' ')[0]
		print "[+] Sub-dir found for testing: {0}".format(test_url)
		# print test_url
		result = requests.get(test_url, headers=headers)
		if result.status_code == 200:
			print '[+] Sub-dir found! {0}\n'.format(test_url)
			results.write("Found: " + test_url + "\n")