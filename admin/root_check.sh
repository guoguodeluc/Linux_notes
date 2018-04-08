#! /bin/bash

if test "$USER" == "root" ;then
	yum -y install vsftpd
else
	echo "you are not root,you do not have permission to install software!"
fi
