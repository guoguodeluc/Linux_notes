# Linux禁用和启用ping

## 使用场景

ping虽然可以帮助我们分析网络故障， 但是某些病毒木马会强行大量远程执行ping命令抢占你的网络资源，导致系统变慢，网速变慢。

严禁ping入侵作为大多数防火墙的一个基本功能提供给用户进行选择。通常的情况下如果你没有什么特殊的要求，就禁止他吧，来保护系统的安全。

## 条件

系统是否允许ping由两个因素决定的：内核参数和防火墙。只要两个因素都允许才允许被ping，如果其中一个因素不允许就会禁止被ping。

## 1.内核参数

### 1.1直接编辑proc系统文件

```shell
# cat /proc/sys/net/ipv4/icmp_echo_ignore_all 
0
禁用
# echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all 
开启
# echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_all 
```

> 0是开启，1是禁用；此方式为临时操作，服务器重启后将失效。

### 1.2 编辑sysctl.conf文件

```shell
以开启ping为例
# cat /etc/sysctl.conf 
net.ipv4.icmp_echo_ignore_all = 0
# sysctl --system
或者
# sysctl -p
```

> sysctl -p 只加载/etc/sysctl.conf 文件；sysctl --system加载目下/usr/lib/sysctl.d/、/etc/sysctl.d下*.conf文件以及/etc/sysctl.conf；优先使用sysctl --system来加载内核配置。

## 2.防火墙

### 2.1 命令行临时配置

```shell
添加规则
禁用ping
# iptables -I INPUT -p icmp -s 0/0 -d 0/0 -j DROP
启用ping
# iptables -I INPUT -p icmp -s 0/0 -d 0/0 -j ACCEPT
删除规则
# iptables -D INPUT -p icmp -s 0/0 -d 0/0 -j DROP
# iptables -D INPUT -p icmp -s 0/0 -d 0/0 -j ACCEPT
```

> -I insert插入规则，将规则放到INPUT链最前面；-A append是追加规则，将规则放到INPUT链最后面；-D delete删除规则； 确保规则生效，建议使用-I，正常不常使用的规则使用-A追加即可。

### 2.2 /etc/sysconfig/iptables文件配置

```shell
备份iptables规则
# iptables-save >  /tmp/iptables
添加iptables规则
# vim /etc/sysconfig/iptables
-I INPUT -p icmp -s 0/0 -d 0/0 -j ACCEPT
加载iptables规则
# iptables-restore /etc/sysconfig/iptables
```

> iptables-restore 会把现有规则覆盖掉，执行该命令需谨慎。



## 附件



### iptables-save保留文件

```ini
# Generated by iptables-save v1.4.21 on Thu Sep 30 13:11:07 2021
*mangle
:PREROUTING ACCEPT [492:28721]
:INPUT ACCEPT [184:14461]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [32:5621]
:POSTROUTING ACCEPT [32:5621]
-A POSTROUTING -o virbr0 -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill
COMMIT
# Completed on Thu Sep 30 13:11:07 2021
# Generated by iptables-save v1.4.21 on Thu Sep 30 13:11:07 2021
*nat
:PREROUTING ACCEPT [308:14260]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:DOCKER - [0:0]
-A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER
-A OUTPUT ! -d 127.0.0.0/8 -m addrtype --dst-type LOCAL -j DOCKER
-A POSTROUTING -s 192.168.122.0/24 -d 224.0.0.0/24 -j RETURN
-A POSTROUTING -s 192.168.122.0/24 -d 255.255.255.255/32 -j RETURN
-A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -p tcp -j MASQUERADE --to-ports 1024-65535
-A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -p udp -j MASQUERADE --to-ports 1024-65535
-A POSTROUTING -s 192.168.122.0/24 ! -d 192.168.122.0/24 -j MASQUERADE
-A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
-A DOCKER -i docker0 -j RETURN
COMMIT
# Completed on Thu Sep 30 13:11:07 2021
# Generated by iptables-save v1.4.21 on Thu Sep 30 13:11:07 2021
*filter
:INPUT ACCEPT [184:14461]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [32:5621]
:DOCKER - [0:0]
:DOCKER-ISOLATION - [0:0]
-A INPUT -p icmp -j ACCEPT
-A INPUT -i virbr0 -p udp -m udp --dport 53 -j ACCEPT
-A INPUT -i virbr0 -p tcp -m tcp --dport 53 -j ACCEPT
-A INPUT -i virbr0 -p udp -m udp --dport 67 -j ACCEPT
-A INPUT -i virbr0 -p tcp -m tcp --dport 67 -j ACCEPT
-A FORWARD -d 192.168.122.0/24 -o virbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -s 192.168.122.0/24 -i virbr0 -j ACCEPT
-A FORWARD -i virbr0 -o virbr0 -j ACCEPT
-A FORWARD -o virbr0 -j REJECT --reject-with icmp-port-unreachable
-A FORWARD -i virbr0 -j REJECT --reject-with icmp-port-unreachable
-A FORWARD -j DOCKER-ISOLATION
-A FORWARD -o docker0 -j DOCKER
-A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i docker0 ! -o docker0 -j ACCEPT
-A FORWARD -i docker0 -o docker0 -j ACCEPT
-A OUTPUT -o virbr0 -p udp -m udp --dport 68 -j ACCEPT
-A DOCKER-ISOLATION -j RETURN
COMMIT
# Completed on Thu Sep 30 13:11:07 2021
```

