#! /usr/bin/bash

#某个网卡的接受和发送的总流量--函数
get_flow(){
        rx=`ifconfig $1 |awk '/bytes/{print $5}' |sed -n 1p`
        tx=`ifconfig $1 |awk '/bytes/{print $5}' |sed -n 2p`
        rx_m=$[rx/1024**2]
        tx_m=$[tx/1024**2]
        echo "the flow of receive are $rx_m Mb"
        echo "the flow of transmission are $rx_m Mb"
}

#某个网卡的每秒的传输速度--函数
rate_flow(){
        rx_1=`ifconfig $1 |awk '/bytes/{print $5}' |sed -n 1p`
        tx_1=`ifconfig $1 |awk '/bytes/{print $5}' |sed -n 2p`
        sleep 1
        rx_2=`ifconfig $1 |awk '/bytes/{print $5}' |sed -n 1p`
        tx_2=`ifconfig $1 |awk '/bytes/{print $5}' |sed -n 2p`
        rx_b=$[rx_2-rx_1]
        tx_b=$[tx_2-tx_1]
        echo "the rate of receive is $rx_b bytes/s"
        echo "the rate of transmission  is $tx_b bytes/s"
        }
read -p "Please input the name of network card:" eth
tmp=`ifconfig | awk '$1=="'${eth}':" {print $1}' `
if test -z $tmp ;then
        echo "-----wrong name of network card !!!--"
else
        get_flow $eth
        rate_flow $eth
fi
      
