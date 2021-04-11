#! /usr/bin/python
# coding:utf-8

import subprocess
import threading

# define function myping 
def myping(ip):
    x = subprocess.call('ping -i0.1 -w1 -c2 %s &>/dev/null' % ip, shell=True)
    if x == 0:
        print "%s is up" % ip
    else:
        print "%s is down" % ip


l = ['176.47.9.%d' % i for i in range(1, 255)]
for i in l:
    t = threading.Thread(target=myping, args=[i])
    t.start()
