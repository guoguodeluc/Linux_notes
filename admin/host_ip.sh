#! /usr/bin/bash

echo "Hostname is `hostname`"
for i in `ifconfig | awk '$2=="inet"{print "IP is "$2}'`
do
        echo "$i"
done
