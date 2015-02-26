#!/bin/bash
# originally by http://devrandom.de/postshtml/2014-02-04_fritzbox_curl_login_session_id.md.html
## ip, idfile, password and username can optionally be specified as global variables
## Example:
## to get sid of fritz.powerline and store it in /tmp/avmsidpowerine use the following
# commands before calling fritzbox-login.sh
# export tempip=fritz.powerline
# export tempid=/tmp/avmsidpowerline
# 
avmfbip=${tempip:-fritz.box}
avmfbuser=${tempuser:-""}
avmfbpwd=${temppwd:-"password"}
avmsidfile=${tempid:-/tmp/avmsid}


if [ ! -f $avmsidfile ]; then
	touch $avmsidfile
fi

avmsid=$(cat $avmsidfile)

# check if current login is valid, otherwise generate session id
result=$(curl -s "http://$avmfbip/login_sid.lua?sid=$avmsid" | grep -c "0000000000000000")

if [ $result -gt 0 ]; then
	echo "Login neccessary"
	challenge=$(curl -s http://$avmfbip/login_sid.lua |  grep -o "<Challenge>[a-z0-9]\{8\}" | cut -d'>' -f 2)
	hash=$(echo -n "$challenge-$avmfbpwd" |sed -e 's,.,&\n,g' | tr '\n' '\0' | md5sum | grep -o "[0-9a-z]\{32\}")
	curl -s "http://$avmfbip/login_sid.lua" -d "response=$challenge-$hash" -d 'username='${avmfbuser} \
	| grep -o "<SID>[a-z0-9]\{16\}" |  cut -d'>' -f 2 > $avmsidfile
fi
avmsid=$(cat $avmsidfile)
#echo $avmsid

# end of login function
