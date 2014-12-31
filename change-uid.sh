#!/bin/bash
# Script to change user ids

read -p "Enter username to change: " name
name=${name:-DEFAULTUSER}

id $name

if [[ ! $? -eq 0 ]]; then
	exit 1
fi

read -p "Enter new uid: " newuid

olduid=$(id -u $name)
newuid=${newuid:-1027}
oldgid=$(id -g $name)
newgid=${newgid:-100}

echo "Changing uid from $olduid to $newuid".
echo "Changing gid from $oldgid to $newgid".

if [[ $newuid = $olduid ]]; then
	echo "ids are the same. quitting."
	exit 1
fi

echo "Processes still running?"
ps aux | grep $name | grep -v grep

read -p "Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[YyJj]$ ]]; then
	exit 1
fi

sudo usermod -u $newuid $name
sudo groupmod -g $newgid $name
sudo find / -path /media -prune -o -path /proc -prune -o -path /var/lib/lightdm/.gvfs -prune -o -user $olduid -exec chown -h $newuid {} \;
sudo find / -path /media -prune -o -path /proc -prune -o -path /var/lib/lightdm/.gvfs -prune -o -group $oldgid -exec chgrp -h $newgid {} \;
sudo usermod -g $newgid $name

id $name
