
#! /bin/bash

myping(){
        ping -c2 -i0.3 -W1 $1 &>/dev/null
        if test $? -eq 0 ; then
                echo "$1 is up"
        else
                echo "$1 is down"
        fi
}

i=1
for i in {1..254}
do
        myping 176.47.9.$i &
done
