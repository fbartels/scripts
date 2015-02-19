#!/bin/bash
# uses .netrc file for credentials
# get urls from http://synology-nas:5005/video/ or https://synology-nas:5006/video/

#To add:
# - 

echo "Downloads (Movie-)Files from NAS and deletes files from local disk that have been commented."
echo "Can be called with additional dir to copy files to usb drive after download."
echo "Usage: $0 [/path/to/extra/copy]"
echo "###############################"

WGETCMD="wget -c -nc --no-check-certificate"
VIDEODIR=$HOME/Videos

files="
http://synology-nas:5005/video/movies/movie-name/movie-name.mkv
http://synology-nas:5005/video/tvshows/some-show/Season.04/very-long-episode-title.mp4
"

if [ ! -z "$1" ] && [ -d "$1" ]; then
	echo "###############################"
	echo "getting files from $1 first"
	rsync -avPh --size-only --update --stats --exclude 1_synology_watchlist.sh $1/Videos/ $VIDEODIR
fi

cd $VIDEODIR
for url in $files; do
	filename=${url##*/}
	url2=${url%.*} # url without file extension
	filename2=${url2##*/}
	nametemp=${url##*tvshows/}
	name=${nametemp%/Season*}
	nameclean=${name//%20/.}
	shownfo=${url%/Season*}
	# case statement to download movies and tvshows into different dirs
	case "$url" in
	*video/tvshows*)
		mkdir -p $VIDEODIR/tvshows/"$nameclean" && cd $VIDEODIR/tvshows/"$nameclean"
		$WGETCMD $shownfo/tvshow.nfo
		;;
	*video/movies*)
		mkdir -p $VIDEODIR/movies && cd $VIDEODIR/movies
		;;
	esac
	# case statement to remove commented files
	case "$url" in
	\#*)
		echo "$filename was commented.. removing it."
		rm $filename 2>/dev/null
		rm $filename2.nfo 2>/dev/null
		;;
	*)
		echo "downloading $filename"
		$WGETCMD $url
		$WGETCMD $url2.nfo
		;;
	esac
	cd $VIDEODIR
	# delete empty folders
	find . -type d -empty -exec rmdir {} \;
done

if [ ! -z "$1" ] && [ -d "$1" ]; then
	echo "###############################"
	echo "copying to path $1"
	rsync -avPh --size-only --update --delete --exclude 1_synology_watchlist.sh --stats $VIDEODIR $1
	cp $0 $1/Videos/1_synology_watchlist.sh
	df -h $1
fi

df -h $VIDEODIR
