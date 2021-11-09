#!/bin/bash
## author: lujianguo
## date: 20210930
## version: v1.0
## description:  Obtain specified nic traffic and packets.
## 获取某个网卡的流量和包转发量，此脚本根据/proc/net/dev来获取的流量信息，和其他工具的数据可能会存在不一致的情况。
## 共识: 变量-小写字母加下划线，函数-开头字母大写加下划线
#######################################################

## vars  需要输入网卡名称
nic_name=$1

##functions 编辑函数，四个函数：使用提示，颜色函数，流量单位函数，网络设备流量处理。
## 显示颜色，31红色，32绿色，33黄色，34蓝色
Echo_Color() {
  echo -e "\e[$1;1m$2\e[0m"
}

Usage_Fun(){
   Echo_Color 31 "The nic does not exist!!  Usage: bash $0 nic-name"
}

## 流量单位处理， /proc/net/dev默认单位是字节(bytes,即B)
## 此处划分了4个层级，B/s，KB/s，MB/s，GB/s。
## 单位是 MB/s，GB/s则显示绿色，以方便更容易观察。
Traffic_Unit() {
  rate_unit=$1
  if [[ $rate_unit -le 1024  ]] ; then 
    echo "$rate_unit B/s"
  elif [[ $rate_unit -gt 1024 &&  $rate_unit -le 1048576  ]]; then
    echo "$(($rate_unit/1024)) KB/s"
  elif [[ $rate_unit -gt 1048576 && $rate_unit -le  1073741824 ]] ; then
    Echo_Color 32 $(echo $rate_unit |awk '{print $1/1024/1024 "MB/s"}')
  else
    Echo_Color 32 $(echo $rate_unit |awk '{print $1/1024/1024/1024 "GB/s"}')
  fi
}

## 网络设备流量和包处理数据, 分两种情况，一个是实时情况以秒为单位，一个是平均情况。
## 此处保留小数后5位，通过awk来处理，bc处理话还需要单独安装，awk更优些；
## 数据每秒刷新一次，可以通过ctrl+c退出。
Handle_Net_Dev() {
  ## 判断网卡是否存在，如果不存在抛出异常并退出
  grep -w $nic_name  /proc/net/dev  > /dev/null 2>&1
  if [[ $? -ne 0 ]] ; then 
    Usage_Fun && exit 0  
  fi  

  rx_bytes_all1=$( grep -w  $nic_name:  /proc/net/dev |awk '{print $2}' )
  tx_bytes_all1=$( grep -w  $nic_name:  /proc/net/dev |awk '{print $10}' )
  rx_packets_all1=$( grep -w  $nic_name:  /proc/net/dev |awk '{print $3}' )
  tx_packets_all1=$( grep -w  $nic_name:  /proc/net/dev |awk '{print $11}' )
  
  while true ; do
    ## 实时流量和包转发处理
    rx_bytes1=$( grep -w  $nic_name:  /proc/net/dev |awk '{print $2}' ) 
    tx_bytes1=$( grep -w  $nic_name:  /proc/net/dev |awk '{print $10}' )
    rx_packets1=$( grep -w  $nic_name:  /proc/net/dev |awk '{print $3}' )
    tx_packets1=$( grep -w  $nic_name:  /proc/net/dev |awk '{print $11}' )
    sleep 1 ; let count_nu++
    rx_bytes=$(( $(grep -w  $nic_name:  /proc/net/dev |awk '{print $2}') - $rx_bytes1 ))
    tx_bytes=$(( $(grep -w  $nic_name:  /proc/net/dev |awk '{print $10}') - tx_bytes1 ))
    rx_packets=$(( $(grep -w  $nic_name:  /proc/net/dev |awk '{print $3}') - $rx_packets1 ))
    tx_packets=$(( $(grep -w  $nic_name:  /proc/net/dev |awk '{print $11}') - $tx_packets1 ))
    
    clear
    echo -e "$(date +%F" "%T) \t Receive \tTransmit" 
    Echo_Color 34 "-----------------------------------------------------The current speed" 
    echo -e "\t$nic_name traffic \t $(Traffic_Unit $rx_bytes) \t  $(Traffic_Unit $tx_bytes)"
    echo -e "\t$nic_name packets \t ${rx_packets} p/s \t  ${tx_packets} p/s"
 
    ## 平均流量和包转发处理
    #echo $count_nu
    rx_bytes_all=$((  ( $(grep -w  $nic_name:  /proc/net/dev |awk '{print $2}') - $rx_bytes_all1 )/$count_nu ))
    tx_bytes_all=$((  ( $(grep -w  $nic_name:  /proc/net/dev |awk '{print $10}') - $tx_bytes_all1 )/$count_nu ))
    rx_packets_all=$((  ( $(grep -w  $nic_name:  /proc/net/dev |awk '{print $3}') - $rx_packets_all1 )/$count_nu ))
    tx_packets_all=$((  ( $(grep -w  $nic_name:  /proc/net/dev |awk '{print $11}') - $tx_packets_all1 )/$count_nu ))
    
    Echo_Color 34 "----------------------------------------------------Average speed over $count_nu seconds" 
    echo -e "\t$nic_name traffic\t $(Traffic_Unit $rx_bytes_all) \t  $(Traffic_Unit $tx_bytes_all)"
    echo -e "\t$nic_name packets\t ${rx_packets_all} p/s \t  ${tx_packets_all} p/s"
  done
}

##run function  只运行网络设备流量和包处理函数
Handle_Net_Dev
