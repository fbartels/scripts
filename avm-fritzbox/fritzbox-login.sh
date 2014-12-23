#!/bin/bash
avmfbip="fritz.box"
avmfbuser=""
avmfbpwd="12345"
avmsidfile="/tmp/avmsid"

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
