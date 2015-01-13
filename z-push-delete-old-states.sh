#!/bin/bash
IFS=$'\n'
ZPA=/usr/share/z-push/z-push-admin.php

#date +"%Y-%m-%d"
SIXMONTHSAGO=$(date +"%s" --date='6 months ago')
#echo $SIXMONTHSAGO

for i in $($ZPA -a lastsync | tail -n +6); do
        DEVICE=$(echo $i | awk '{print $1}')
        USER=$(echo $i | awk '{print $2}')
        LASTDATE=$(echo $i | awk '{print $3}')
        #LASTDATE2=$(date -d $LASTDATE +%s)

        #echo $LASTDATE2
        if [[ $LASTDATE == *"never"* ]]; then
                echo "$DEVICE never synced"
                $ZPA -a remove -u $USER -d $DEVICE
                continue
        else
                LASTDATE2=$(date -d $LASTDATE +%s)
        fi
        if [[ $SIXMONTHSAGO -ge $LASTDATE2 ]]; then
                echo "$DEVICE is older than 6 months"
                $ZPA -a remove -u $USER -d $DEVICE
        fi
done
