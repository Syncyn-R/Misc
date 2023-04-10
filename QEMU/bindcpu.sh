#!/bin/bash
#grep CPU | awk -F ' #' '{print $2}' | awk -F ': ' '{print $1,$2}' | awk -F '=' '{print $1,$2}' | awk -F ' ' '{print $1,$3}'
IFS=$'\n'
[[ -f $1 ]] || exit 1
for vcpus in `grep 'CPU\|thread_id=' $1 | awk -F ' #' '{print $2}' | awk -F ': ' '{print $1,$2}' | awk -F '=' '{print $1,$2}' | awk -F ' ' '{print $1,$3}'`
do
    xcore=`echo $vcpus | awk -F ' ' '{print $1}'`
    xthread=`echo $vcpus | awk -F ' ' '{print $2}' | dos2unix`
    #taskset -cp $xcore $xthread
    cthread[$xcore]=$xthread
#    echo $xcore=${cthread[$xcore]}
done

[[ -f $2 ]] || exit 1
for binds in `cat $2`
do
    vcpu=`echo $binds | awk -F '=' '{print $1}'`
    hcpu=`echo $binds | awk -F '=' '{print $2}'`
    vcpus=${#cthread[*]}
    vcthread=${cthread[$vcpu]}
    [[ $vcpu -lt $vcpus ]] && taskset -cp $hcpu $vcthread || echo Skip vCPU:$vcpu
done
