#!/bin/bash

logdir=logs
outputformat=mkv
corelogfilename=`date +'Core-%Y-%m-%d_%H-%M-%S.log'`

tlog(){
    echo [`date +'%Y-%m-%d %H:%M:%S'`] $* | tee -a $logdir/$corelogfilename
}

record(){
	roomid=$1
	filename=`date +'%Y-%m-%d_%H-%M-%S'`
	if [[ `curl -s 'https://api.live.bilibili.com/room/v1/Room/room_init?id='$roomid | jq '.data.live_status' -r` == '1' ]]
	then
		tlog Detected $roomid status 1.
		sourceaddress=`curl -s 'https://api.live.bilibili.com/room/v1/Room/playUrl?cid='$roomid'&qn=10000&platform=web' | jq '.data.durl[0].url' -r`
		tlog Started $filename
		ffmpeg -user_agent 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36' -headers 'referer: https://live.bilibili.com/'$roomid -re -i $sourceaddress -c copy $filename.$outputformat > $logdir/Record-$filename.log 2>&1
		returncode=$?
		[ $returncode -eq 255 ] && exit 0
		tlog FFMPEG return $returncode.
		grep -q 'HTTP error 404 Not Found' $logdir/Record-$filename.log
		[ $? -eq 0 ] && rm logs/Record-$filename.log && tlog Deleted 404 $logdir/Record-$filename.log
	fi
}

loop(){
	[ ! -d $logdir ] && mkdir $logdir
	tlog Script Started.
	while true
	do
		$0 record $1
	done
}

case "$1" in
record) record $2;;
$1) loop $1;;
esac
