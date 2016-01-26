#!/bin/bash
#  example script to force the "downgrade" rom webapp 1:1.6 to 2.0
# @commit this is a test

webappversion=$(dpkg-query -W -f='${Version}' zarafa-webapp)

if [[ $webappversion = "1:"* ]]; then
echo "Old WebApp detected. Forcing install of version 2.x."
	apt-get install zarafa-webapp=2*
fi
