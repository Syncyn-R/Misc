#!/bin/bash

logdir=logs
outputformat=mkv
corelogfilename=`date +'Core-%Y-%m-%d_%H-%M-%S.log'`

tlog(){
    echo [`date +'%Y-%m-%d %H:%M:%S'`] $* | tee -a $logdir/$corelogfilename
}

record(){
	corelogfilename=$2
	roomid=$1
	filename=`date +'%Y-%m-%d_%H-%M-%S'`
	if [[ `curl -s 'https://api.live.bilibili.com/room/v1/Room/room_init?id='$roomid | jq '.data.live_status' -r` == '1' ]]
	then
		tlog Detect $roomid live started.
		sourceurl=`curl -s 'https://api.live.bilibili.com/room/v1/Room/playUrl?cid='$roomid'&qn=10000&platform=web' | jq '.data.durl[0].url' -r`
		tlog Source url: $sourceurl
		tlog Start recording: $filename.$outputformat
		ffmpeg -user_agent 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36' -headers 'referer: https://live.bilibili.com/'$roomid -re -i $sourceurl -c copy $filename.$outputformat > $logdir/Record-$filename.log 2>&1
		returncode=$?
		[ $returncode -eq 255 ] && exit 0
		tlog FFMPEG return $returncode.
		grep -q 'HTTP error 404 Not Found' $logdir/Record-$filename.log
		[ $? -eq 0 ] && rm logs/Record-$filename.log && tlog Deleted 404 $logdir/Record-$filename.log
	fi
}

loop(){
	tlog Script Started.
	while true
	do
		$0 record $1 $2
		[ $? -eq 0 ] && exit 0
	done
}

envcheck(){
	[ ! -d $logdir ] && mkdir $logdir && Created Logdir. || tlog Logdir exist.
	corelogfilename=`date +'Core-%Y-%m-%d_%H-%M-%S.log'`
	error=0
	if [[ `which jq` != '' ]]
	then
		tlog jq version: `jq --version  | head -n 1`
		else
		tlog jq not found!
		error=`expr $error + 1`
	fi
	if [[ `which ffmpeg` != '' ]]
	then
		tlog ffmpeg version: `ffmpeg -version | head -n 1`
		else
		tlog ffmpeg not found!
		error=`expr $error + 1`
	fi
	if [[ `which curl` != '' ]]
	then
		tlog curl version: `curl --version | head -n 1`
		else
		tlog curl not found!
		error=`expr $error + 1`
	fi
	[ $error -ne 0 ] && tlog $error command not found. && exit 2
	loop $1 $corelogfilename
}

case "$1" in
record) record $2 $3;;
$1) envcheck $1;;
esac
