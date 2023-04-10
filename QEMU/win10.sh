#!/bin/bash
monfile=mon.txt
pidfile=pid
qemustdout=QEMU.txt
monaddr=`grep monitoraddress= qemu.sh | awk -F '=' '{print $2}'`
monport=`grep monitorport= qemu.sh | awk -F '=' '{print $2}'`

./qemu.sh > $qemustdout 2>&1&

while true
do
    bash -c '> /dev/tcp/'$monaddr'/'$monport'' > /dev/null 2>&1
    [ $? -eq 0 ] && break
done
exec 3<>/dev/tcp/$monaddr/$monport
cat <& 3 | tee $monfile&
echo info cpus >& 3
while true; do [[ `grep CPU $monfile` != '' ]] && break; done
./bindcpu.sh $monfile cpubind.txt
./read >& 3
[[ $? ]] && ./read echo
