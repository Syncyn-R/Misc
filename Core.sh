#!/bin/bash

roomid=$1
logdir=logs
outputformat=mkv
corelogfilename=`date +'Core-%Y-%m-%d_%H-%M-%S.log'`

tlog(){
    echo [`date +'%Y-%m-%d %H:%M:%S'`] $* | tee -a $logdir/$corelogfilename
}

while true
do
	filename=`date +'%Y-%m-%d_%H-%M-%S'`
	[ ! -d $logdir ] && mkdir $logdir
	if [[ `curl -s https://api.live.bilibili.com/room/v1/Room/room_init?id=$roomid | grep '"live_status":1'` != '' ]]
	then
		sourceaddress=`curl -s 'https://api.live.bilibili.com/room/v1/Room/playUrl?cid='$roomid'&qn=10000&platform=web' | jq '.data.durl[0].url' -r`
		tlog Started $filename
		ffmpeg -user_agent 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36' -headers 'referer: https://live.bilibili.com/'$roomid -re -i $sourceaddress -c copy $filename.$outputformat > $logdir/Record-$filename.log 2>&1
		returncode=$?
		[ $returncode -eq 255 ] && exit 0
		tlog FFMPEG return $returncode.
		grep -q 'HTTP error 404 Not Found' $logdir/Record-$filename.log
		[ $? -eq 0 ] && rm logs/Record-$filename.log && tlog Deleted 404 $logdir/Record-$filename.log
	fi
done
