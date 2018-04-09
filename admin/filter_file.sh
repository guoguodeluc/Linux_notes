#! /usr/bin/bash

#Filter the file that greater than 10000

file_tmp=`ls -l /root/ | grep -v ^d | awk '{if($5>10000){print $9}}'`

for i in $file_tmp
do
        cp /root/$i /tmp/
done


for i in `ls /root`
do
        if  test -f /root/$i ; then
                if test `ls -l /root/$i | awk '{print $5}'` -gt 10000 ; then
                        cp /root/$i /tmp
                fi
        fi
done
