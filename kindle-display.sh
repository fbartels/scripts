#!/bin/sh
# https://news.ycombinator.com/item?id=11897804

sleeptime=600 #seconds
url="http://whatever/formatted-for-kindle.png"
tmp_image="/tmp/image.png"

wifienable() {lipc-set-prop com.lab126.cmd wirelessEnable 1}
wifidisable() {lipc-set-prop com.lab126.cmd wirelessEnable 0}
sleepfor() {lipc-set-prop -i com.lab126.powerd rtcWakeup $1}

wait_for_wifi() {return `lipc-get-prop com.lab126.wifid cmState | grep CONNECTED | wc -l`;} #return true if keyword not found
wait_for_ready_suspend() {return `powerd_test -s | grep Ready | wc -l`;}

while true;
	do wifienable
	while wait_for_wifi; do sleep 1; done
	wget -O $tmp_image $url
	eips -g $tmp_image
	wifidisable
	while wait_for_ready_suspend; do sleep 1; done
	sleepfor $sleeptime
done
