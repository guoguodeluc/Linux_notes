#! /usr/bin/bash

# define my ping function

myping(){
  ping -c 2 -i0.1 -w 1 $1 &>/dev/null
  if test $? -eq 0 ; then
    echo "$1 is up"
  else
    echo "$1 is down"
  fi
}

#Check the network segment of 192.168.4.0/24, you can modify it for check.

for i in {1..254}
do
  myping 192.168.4.$i&
done
