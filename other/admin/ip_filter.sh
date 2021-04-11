#! /usr/bin/bash

#Filter ip from the top 10 

cat /var/log/httpd/access_log | awk '{a[$1]++}END{for(i in a){print a[i],i}}' |sort -rn | head -10

cat /var/log/httpd/access_log | awk '{print $1}' | uniq -c |sort -rn | head -10
