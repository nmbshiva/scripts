# script to check service account passwords
# requires install of ldap-python module
# logs to a file when authenication is successful due to password == username
# only checks user == password, no other testing takes place
# does not log failed attempts
# has a time delay between auth attempts (short, 1sec)

# usage password_check.py <ldap://server> <path to uid file>

import os
import datetime
import sys
import random
import time

auth_success = "(97, [], 1, [])"

log = open("auth_success.log", 'w')
server = ""

print "\n[- SERVICE ACCOUNT PASSWORD CHECKER -]\n"
#print "Usage: %s <UID list>\n" % sys.argv[0]

svc_users = sys.argv[1]

if os.path.isfile(svc_users):
	print ""
else:
		sys.exit("[!] Error. File %s does not exist. Exiting." % sys.argv[1])

# check if python-ldap is installed
try:
	import ldap
	print "[*] ldap module loaded OK."
except:
	print "[!] Error: python-ldap module not installed. Please install before proceeding.\n"
	sys.exit(0)

conn = ldap.initialize(server)
conn.protocol_version = 3
conn.set_option(ldap.OPT_REFERRALS, 0)

try:
	uids = open(svc_users, 'rb')
	users = uids.readlines()
	uids.close()
	log.write('Usernames loaded OK.\n')
	print "[*] Usernames loaded OK."
except Exception,e:
	sys.exit(e)

current_time = datetime.datetime.now().time()

try:
	log.write('Authentication attempt started at ' +  current_time.isoformat()+"\n")
	print "[+] Log file OK.\n"
except Exception,e:
	print e
	sys.exit(e)

for uid in users:
	uid = uid.rstrip()
	passw = uid
	try:
		print "[*] Trying %s:%s" % (uid, passw)
		result = conn.simple_bind_s(uid, passw)
		result2 = str(result)
		if result2.startswith("(97, [], 1, [])"):
			print "[!] Valid credentials -- %s\n" % uid
			log.write("Auth found: " + uid + "\n")
	except ldap.INVALID_CREDENTIALS:
		print "[-] Invalid credentials: %s\n" % uid
	except ldap.SERVER_DOWN:
		print "[!] Server down"
	except ldap.LDAPError, e:
		if type(e.message) == dict and e.message.has_key('desc'):
			print "[!] Other LDAP error: \n" + e.message['desc']
		else: 
			print "[!] Other LDAP error: \n" + e
	time.sleep(1)

print "\n\n[*] Finished at " + current_time.isoformat() + "\n"
conn.unbind_s()
log.close()