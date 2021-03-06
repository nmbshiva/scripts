Bunch of various scripts to make life easier.

### WEB Enumeration
---

#### robots_dir.py:
Specify a domain, get the robots.txt and test which subdomains return a 200.

#### crt_shy.py:
Query crt.sh to get a list of subdomains related to the specified domain.

#### threatcrowd.py:
Get a list of previously seen subdomains via threatcrowd.org.

#### webrecon.sh
Enumerate a domain for subdomains and directories. Useful for bug bounties or pentests with no regard for noise.

### OS/Network enumeration
---

#### password_check.py:
Check if a list of usernames in a specified file have a password that matches the username.

#### recon.sh:
Basic recon script for machine enumeration - nmap, enum4linux, cme (includes default cred checks; user/pass files not included)

#### ssh-attack.sh
Find open ssh instances and brute force using hydra.
