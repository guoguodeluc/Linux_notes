#! /usr/bin/python
#coding:utf-8

import paramiko
host='192.168.4.6'
ssh=paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect(host,username='root',password='123456')
ssh.exec_command('touch /a.txt.log')
