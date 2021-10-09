# linux查看端口流量和包转发量



日常给工作中需要查看linux服务器端口流量，对于正常进程导致的带宽跑满或跑高的问题，需要对服务器的带宽进行升级或者优化；而对于异常进程，有可能是由于恶意程序问题或部分IP恶意访问导致，也可能是服务遭到攻击，需要进行相应的处理或者优化；所以查看端口流量和分析是很有必要的。

每个人使用的需求不一样，可以根据需求选择相应的工具或者编写相应的脚本来或者流量信息。

## 工具

### 常用工具示例

```shell
nload eth0
iftop -i eth0 -n
sar -n DEV 1 2
iptraf-ng -d eth0
nethogs eth0
```

> 以上几个命令使用场景不一样：
>
> nload查看总体流量；iftop总体流量和精确到ip连接；sar除了流量还有包转发量；iptraf-ng更精细基本可以满足所有流量查看需求；nethogs针对进程或者服务来查看流量。

### nload

#### 安装

```shell
# yum install -y nload
```

#### 使用参数

```shell
nload [options] [devices]
-u h|b|k|m|g    Sets the type of unit used for the display of traffic numbers.
   H|B|K|M|G    h: auto, b: Bit/s, k: kBit/s, m: MBit/s etc.
                H: auto, B: Byte/s, K: kByte/s, M: MByte/s etc.
                Default is h.
-u 指定流量单位，但是默认是自动根据流量大小来设置单位
```

#### 实例

```ini
# nload eth0
Device eth0 [ip] (1/1):
Incoming:
 Curr: 10.09 GBit/s
 Avg: 2.87 GBit/s
 Min: 856.00 Bit/s
 Max: 15.09 GBit/s
 Ttl: 3843.83 GB
Outgoing:
 Curr: 6.99 MBit/s
 Avg: 2.15 MBit/s
 Min: 4.75 kBit/s
 Max: 11.66 MBit/s
Ttl: 2.78 GByte
```

> 这里显示为GBit/s，其实字节bit(常说的b)，不仔细看容易被误导为bytes(常说的B)；如果显示B，加-u H

### iftop

#### 安装

```shell
# yum install -y iftop
```

#### 使用参数

```shell
 iftop -h | [-npblNBP] [-i interface] [-f filter code]
   -n                  don't do hostname lookups
   -B                  display bandwidth in bytes
   -i interface        listen on named interface
   -t                  use text interface without ncurses
-n 显示ip而不是域名或者主机名， -B单位为bytes而不是bit， -i 指定网卡名，-t非窗口模式
```

#### 实例

```ini
# iftop -i eth0
TX:             cum:   18.0MB   peak:	7.88Mb         rates:   7.17Mb  7.15Mb  6.55Mb
RX:                    32.5GB              0b                   13.5Gb  12.8Gb  11.8Gb
TOTAL:                 32.5GB              0b                   13.5Gb  12.9Gb  11.8Gb
```

> TX：发送流量  RX：接收流量  TOTAL：总流量 Cumm：运行 iftop 到目前时间的总流量 peak：流量峰值rates：分别表示过去 2s 10s 40s 的平均流量

### sar

#### 安装

```shell
# yum install -y sysstat
```

> 提供工具 cifsiostat  iostat  mpstat  nfsiostat-sysstat pidstat sadf sar tapestat

#### 使用参数

```shell
Usage: sar [ options ] [ <interval> [ <count> ] ]
-n  Report network statistics  流量查看

Possible keywords are DEV, EDEV, NFS, NFSD, SOCK, IP, EIP, ICMP, EICMP,  TCP,  ETCP,  UDP,  SOCK6,  IP6,  EIP6,ICMP6, EICMP6 and UDP6
主要使用
DEV 显示网络接口信息。
EDEV 显示关于网络错误的统计数据。
ALL 显示所有
```

#### 实例

```ini
# sar -n DEV 1 2
Linux 3.10.0-957.1.3.el7.x86_64 (host-10-135-139-76) 	10/01/2021 	_x86_64_	(2 CPU)
04:29:18 AM     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
04:29:19 AM      eth0  22787.00  15115.00 1347287.92    982.51      0.00      0.00      0.00
04:29:19 AM        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00

04:29:19 AM     IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
04:29:20 AM      eth0  26608.00  17013.00 1549286.02   1105.03      0.00      0.00      0.00
04:29:20 AM        lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00

Average:        IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s
Average:         eth0  24697.50  16064.00 1448286.97   1043.77      0.00      0.00      0.00
Average:           lo      0.00      0.00      0.00      0.00      0.00      0.00      0.00
```

> 流量单位是KB，和数据包接收和发送量

### iptraf-ng

#### 安装

```shell
# yum install iptraf-ng
```

#### 使用参数

```
usage: iptraf-ng [options]
-i ip 针对ip连接分析；-d detail 详细流量情况，比较综合查看； -s 针对tcp和udp情况擦查看；-z size 根据包大小和数量查看； -l lan 根据lan情况查看
   -i <iface>            start the IP traffic monitor (use '-i all' for all interfaces)
    -d <iface>            start the detailed statistics facility on an interface
    -s <iface>            start the TCP and UDP monitor on an interface
    -z <iface>            shows the packet size counts on an interface
    -l <iface>            start the LAN station monitor (use '-l all' for all LAN interfaces)
    -g                    start the general interface statistics
```

> 常用 -i和-d

#### 实例

以iptraf-ng -d eth0 为例

```ini
# iptraf-ng -d eth0  
iptraf-ng 1.1.4
 Statistics for eth0 qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
                                                                               
               Total      Total    Incoming   Incoming    Outgoing   Outgoing  
             Packets      Bytes     Packets      Bytes     Packets      Bytes  
 Total:       309635     11753M      190789     11747M      118846    6240292  
 IPv4:        309635     11753M      190789     11747M      118846    6240292  
 IPv6:             0          0           0          0           0          0  
 TCP:         309635     11753M      190789     11747M      118846    6240292  
 UDP:              0          0           0          0           0          0  
 ICMP:             0          0           0          0           0          0  
 Other IP:         0          0           0          0           0          0  
 Non-IP:           0          0           0          0           0          0  
                                                                               
                                                                               
 Total rates:      10194.80 Mbps            Broadcast packets:            0    
                      34004 pps             Broadcast bytes:              0    
                                                                               
 Incoming rates:   10189.31 Mbps                                               
                      20881 pps                                                
                                            IP checksum errors:           0    
 Outgoing rates:    5494.23 kbps                                               
                      13123 pps                                                
```

> 蓝色背景，x退出

### nethogs

#### 安装

```shell
# yum install -y nethogs
```

#### 使用参数

```shell
usage: nethogs [-V] [-h] [-b] [-d seconds] [-v mode] [-c count] [-t] [-p] [-s] [device [device [device ...]]]
-v 查看模式； -a所有设备
		-v : view mode (0 = KB/s, 1 = total KB, 2 = total B, 3 = total MB). default is 0.
        -a : monitor all devices, even loopback/stopped ones.
		device : device(s) to monitor. default is all interfaces up and running excluding loopback
When nethogs is running, press:
 q: quit
 s: sort by SENT traffic
 r: sort by RECEIVE traffic
 m: switch between total (KB, B, MB) and KB/s mode
```

> 运行时使用 m切换单位

#### 实例

```ini
# nethogs eth0
NetHogs version 0.8.5

    PID USER     PROGRAM                   DEV        SENT      RECEIVED       
  21532 root     iperf                     eth0      508.509  111983.000 KB/sec
  29759 user  sshd: user@pts/0             eth0        0.642       0.116 KB/sec
      ? root     unknown TCP                           0.000       0.000 KB/sec
  TOTAL                                               712.304  374156.377 KB/se
```

> 查看单个进程流量而设计的工具，按照进程进行带宽分组。

## 脚本

### 说明

脚本见附件，此脚本获取/proc/net/dev，经过处理获取相应的数据。

不需要额外再安装软件，并且可自定义欲查看接口，精确到小数后5位，可根据流量大小灵活显示单位。

```ini
# cat /proc/net/dev
Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
  eth0: 9294385440352 154675312    0    0    0     0          0         0 6467128879 97440505    0    0    0     0       0          0
    lo:     416       6    0    0    0     0          0         0      416       6    0    0    0     0       0          0
bytes表示收发的字节数；
packets表示收发正确的包量；
errs表示收发错误的包量；
drop表示收发丢弃的包量；
```



### 实例

```ini
#  bash net-dev.sh eth0
2021-10-01 06:52:12 	 Receive 	Transmit
-----------------------------------------------------The current speed
	eth0 traffic 	 1.54482GB/s 	  1.08588MB/s
	eth0 packets 	 27648 p/s 	  17317 p/s
----------------------------------------------------Average speed over 8392 seconds
	eth0 traffic	 603.725MB/s 	  419 KB/s
	eth0 packets	 10467 p/s 	  6487 p/s
```

> 指定网卡的实时流量和包速度以及平均速度。

## 附件

```shell
# cat net-dev.sh
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
```

