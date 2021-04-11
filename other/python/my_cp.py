#!/usr/bin/python
#coding:utf-8

import sys

#x=raw_input('source file:')
#y=raw_input('destination file')
file1=open(sys.argv[1])
file2=open(sys.argv[2],'w')
for i in file1:
    file2.writelines(i)
file1.close()
file1.close()
