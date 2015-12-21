#!/bin/bash
# inspired by https://github.com/Tscherno/Fritzbox.sh
# script is defunct without WEBCM which was removed with firmware version 6.30

source $HOME/bin/fritzbox-login.sh

FRITZLOGIN="/login_sid.lua"
FRITZWEBCM="/cgi-bin/webcm"
FRITZHOME="/home/home.lua"

CURLCMD="curl -s"

MYNAME=$(basename $0)

TEMPFile="/var/tmp/FritzBox_tempfile.txt"
CURLFile=""
ANRUFLIST="/var/tmp/FritzBox_anruferliste.csv"

# Wohin soll geloggt werden
Debug="/tmp/test.log"
# Alle Debugnachrichten Nachrichten
Debugmsg="FritzBox.sh 0.x.x  "

FritzBoxURL="http://$avmfbip"

# Parameter 1: POST/GET Daten
# Parameter 2: (default POST) GET -> Get request
# Parameter 3: Servlet (default FRITZWEBCM)
PerformPOST(){
	# Parameter 3 ueberpruefen (URL)
	if [ "$3" = "" ]; then
		local URL=$FritzBoxURL$FRITZWEBCM
	else
		local URL=$FritzBoxURL$3
	fi
	# Parameter 2 ueberpruefen (POST oder GET)
	if [ "$2" = "GET" ]; then
		echo "GET  : $1"
		echo "GET  : URL $URL?$1"
		$CURLCMD "$URL?$1"
	else
		echo "POST : $1"
		echo "POST : $URL"
		$CURLCMD -d "$1" "$URL"
	fi
}

case $1 in
	"test")
		suche="true"
		linie=\"DECT\"
		string=$($CURLCMD "$FritzBoxURL$FRITZHOME?sid=$avmsid" 2>/dev/null | grep $linie )
		if echo "$string" | egrep -q "true" ; then
			echo "TRUE: $string"
		else
			echo "FALSE: $string"
		fi
		;;
	"available")
		echo "URL: $FritzBoxURL/net/network_user_devices.lua?sid=$avmsid"
		case $2 in
			"LAN")
			CURLOUTPUT=$($CURLCMD "$FritzBoxURL/net/network_user_devices.lua?sid=$avmsid" | grep '"_node"] = "landevice' -A27 -B2 | sed -e 's/\["//g' -e 's/\"]//g' -e 's/\"//g' | grep "wlan = 0" -B26 | grep "active = 1" -A24 | grep " name = " | sed -e 's/name =//' -e 's/,//')
			DEVICE=$3
			;;
			"WLAN")
			CURLOUTPUT=$($CURLCMD "$FritzBoxURL/net/network_user_devices.lua?sid=$avmsid" | grep '"_node"] = "landevice' -A27 -B2 | sed -e 's/\["//g' -e 's/\"]//g' -e 's/\"//g' | grep "wlan = 1" -B26 | grep "active = 1" -A24 | grep " name = " | sed -e 's/name =//' -e 's/,//')
			DEVICE=$3
			;;
			*)
			CURLOUTPUT=$($CURLCMD "$FritzBoxURL/net/network_user_devices.lua?sid=$avmsid" | grep '"_node"] = "landevice' -A27 -B2 | sed -e 's/\["//g' -e 's/\"]//g' -e 's/\"//g' | grep "active = 1" -A24 | grep " name = " | sed -e 's/name =//' -e 's/,//')
			DEVICE=$2
			;;
		esac
		if [ ! -z $DEVICE ]; then
			DEVICEAVAIL=$(echo $CURLOUTPUT | grep "$DEVICE" )
			if [ "$DEVICEAVAIL" != "" ]; then
				echo "Result: $DEVICE is available"
			else
				echo "Result: $DEVICE not available"
			fi
		else
			echo -e "All devices:\n$CURLOUTPUT"
		fi
		;;
	"online")
		echo "URL: $FritzBoxURL/net/network_user_devices.lua?sid=$avmsid"
		case $2 in
			"LAN")
			CURLOUTPUT=$($CURLCMD "$FritzBoxURL/net/network_user_devices.lua?sid=$avmsid" | grep '"_node"] = "landevice' -A27 -B2 | sed -e 's/\["//g' -e 's/\"]//g' -e 's/\"//g' | grep "wlan = 0" -B26 | grep "online = 1" -B1 | grep " name = " | sed -e 's/name =//' -e 's/,//')
			DEVICE=$3
			;;
			"WLAN")
			CURLOUTPUT=$($CURLCMD "$FritzBoxURL/net/network_user_devices.lua?sid=$avmsid" | grep '"_node"] = "landevice' -A27 -B2 | sed -e 's/\["//g' -e 's/\"]//g' -e 's/\"//g' | grep "wlan = 1" -B26 | grep "online = 1" -B1 | grep " name = " | sed -e 's/name =//' -e 's/,//')
			DEVICE=$3
			;;
			*)
			CURLOUTPUT=$($CURLCMD "$FritzBoxURL/net/network_user_devices.lua?sid=$avmsid" | grep '"_node"] = "landevice' -A27 -B2 | sed -e 's/\["//g' -e 's/\"]//g' -e 's/\"//g' | grep "online = 1" -B1 | grep " name = " | sed -e 's/name =//' -e 's/,//')
			DEVICE=$2
			;;
		esac
		if [ ! -z $DEVICE ]; then
			DEVICEAVAIL=$(echo $CURLOUTPUT | grep "$DEVICE" )
			if [ "$DEVICEAVAIL" != "" ]; then
				echo "Result: $DEVICE is online"
			else
				echo "Result: $DEVICE not online"
			fi
		else
			echo -e "All devices:\n$CURLOUTPUT"
		fi
		;;
	"WLANNight")
		echo "URL: $FritzBoxURL/system/wlan_night.lua?sid=$avmsid"
		status=$($CURLCMD "$FritzBoxURL/system/wlan_night.lua?sid=$avmsid" | grep 'name="active" id="uiActive"')
		if echo $status | grep -q 'id="uiActive" checked>' ; then
			echo "Result: Timer on"
		else
			echo "Result: Timer off"
		fi
		;;
	"connection")
		echo "URL: $FritzBoxURL/internet/inetstat_monitor.lua?sid=$avmsid"
		status=$($CURLCMD "$FritzBoxURL/internet/inetstat_monitor.lua?sid=$avmsid" | grep 'connection0:status/ip')
		if echo $status | grep -q '"-"' ; then 
			echo "Connection status: not connected"
		else
			echo "Connection status: connected"
		fi
		;;
	"connectionTime")
		echo "URL: $FritzBoxURL/internet/inetstat_monitor.lua?sid=$avmsid"
		status=$($CURLCMD "$FritzBoxURL/internet/inetstat_monitor.lua?sid=$avmsid" | grep "connection0:status/conntime_date" -A1)
		status2=$(echo -e $status | sed -e 's/"connection0:status\/conntime_date"//;s/"connection0:status\/conntime_time"//;s/\[\] =//g;s/"//g;s/,//g;s/\n//g;s/^ //g;s/ / /g;s/\./-/g' | sed ':a;N;$!ba;s/\n//g')
		if echo $status2 | grep -q '\"-\"' ; then 
			echo "Connected since: -"
		else
			echo "Connected since: $status2"
		fi
		;;
	"connectionIP")
		echo "URL: $FritzBoxURL/internet/inetstat_monitor.lua?sid=$avmsid"
		status=$($CURLCMD "$FritzBoxURL/internet/inetstat_monitor.lua?sid=$avmsid" | grep 'connection0:status/ip')
		if echo $status | grep -q '"-"' ; then 
			echo "Connected IP: -"
		else
			ip=$(echo $status |  sed -e 's/= //;s/",//g;s/"*//g;s/\[connection0:status\/ip\]//g')
			echo "Connected IP: $ip"
		fi
		;;
	"WLAN")
		state=${2:-0}
		PerformPOST "wlan:settings/ap_enabled=$state&sid=$avmsid" "POST"
		;;
	"WLAN5")
		state=${2:-0}
		PerformPOST "wlan:settings/ap_enabled_scnd=$state&sid=$avmsid" "POST"
		;;
	"WLANGast")
		state=${2:-0}
		PerformPOST "wlan:settings/guest_ap_enabled=$state&sid=$avmsid" "POST"
		;;
	"WLAN-Status")
		echo "URL: $FritzBoxURL/wlan/wlan_settings.lua?sid=$avmsid"
		status=$($CURLCMD "$FritzBoxURL/wlan/wlan_settings.lua?sid=$avmsid" | grep wlan:settings)
		status24=$(echo "$status" | grep 'wlan:settings/ap_enabled"')
		status5=$(echo "$status" | grep 'wlan:settings/ap_enabled_scnd"')
		statusguest=$($CURLCMD "$FritzBoxURL/wlan/guest_access.lua?sid=$avmsid" | grep wlan:settings | grep 'wlan:settings/guest_ap_enabled')
		if echo $status24 | grep -q '1' ; then
			echo "2,4 Ghz WLAN: on"
		else
			echo "2,4 Ghz WLAN: off"
		fi
		# if variable is empty, router does not offer 5ghz
		if [[ ! -z $status5 ]]; then
			if echo $status5 | grep -q '1' ; then
				echo "5 Ghz WLAN: on"
			else
				echo "5 Ghz WLAN: off"
			fi
		fi
		if echo $statusguest | grep -q '1' ; then
			echo "Gäste WLAN: on"
		else
			echo "Gäste WLAN: off"
		fi
		;;
	"WLAN-Verbunden")
		echo "URL: $FritzBoxURL/wlan/wlan_settings.lua?sid=$avmsid"
		status=$($CURLCMD "$FritzBoxURL/wlan/wlan_settings.lua?sid=$avmsid")
		echo "$status"
		;;
	"UMTS")
		PerformPOST "umts:settings/enabled=$2&sid=$avmsid" "POST"
		;;
	"reboot")
		PerformPOST "logic:command/reboot=../gateway/commands/saveconfig.html&sid=$avmsid" "POST" 
		PerformPOST "security:command/logout=1&sid=$avmsid" "POST"
		;;
	*) echo "Welcome to fritzbox-control. Options in brackets are optional. 
General usage: $MYNAME <action> [0|1] (off|on)

available / online
Usage: $MYNAME available|online [LAN|WLAN] [DEVICE]
List devices that are either available (powered up) or also online (connected to the internet).
Can be optionally queried for devices on LAN/WLAN.
If the hostname of a device is given this functions returns if this device is on or off.

WLAN 0|1
WLAN5 0|1
WLANGast 0|1
Usage $MYNAME WLAN 0|1
Toggle 2.4Ghz, 5Ghz or Guest Lan. If no second parameter is given option will set to off.

WLAN-Status
Report status on all wifi networks 2.4Ghz, 5Ghz (if available) and guest network.

UMTS
Usage: $MYNAME UMTS 0|1
Turn UMTS off or on

$MYNAME reboot
Reboot the Fritz!Box"
;;
esac
