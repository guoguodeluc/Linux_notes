#! /usr/bin/python
# coding:utf-8

import re

x = open("/var/log/httpd/access_log")
abc = {}
for i in x:
    m = re.search('Firefox|Chrome', i)
    if m:
        key = m.group()
        abc[key] = abc.get(key, 0) + 1
print abc
x.close()
