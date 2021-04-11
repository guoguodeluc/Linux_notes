#! /usr/bin/bash

#Show the information of hostname/cpu/memory and ip 

echo "Hostname is `hostname`"
echo "CPU is `lscpu | awk '$1=="CPU(s):"{print $2}'`"
echo "Mem is `free -h | awk '/Mem/{print $2}'`"
echo "`cat /etc/redhat-release`"
echo "`uname -r`"
for i in `ifconfig | awk '$1=="inet"{print $2,$4}'`
do
        echo "$i"
done
