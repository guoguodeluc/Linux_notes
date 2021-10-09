# linux路由问题

如果服务器有多个网卡配置多个地址，并且有访问不同的网络段需求时，就可以添加静态路由，让相应网卡可以通过指定网关访问目标网段。

## 路由概念



代理ARP：路由下一跳是接口还是IP设备的最大区别就是ARP表的区别：下一跳是IP设备的话，外LAN数据包毫无疑问交给了IP网关，但是如果下一跳只是接口的话这个是需要单独对目标ip做arp解析的，如果IP网关上没有开启接口的proxy arp feature的话是不会响应这个arp请求的。



```ini
Destination: 目标网络(network)或者目标主机(host)
Gateway: 网关地址，*表示并未设置网关地址；
Genmask: 目标网络。其中’255.255.255’用于指示单一目标主机，’0.0.0.0’用于指示默认路由
Metric: 路由距离，到达指定网络所需的中转数。当前Linux内核并未使用，但是routing daemons可能会需要这个值
Ref: 路由项引用次数（linux内核中没有使用）
Use: 此路由项被路由软件查找的次数
Iface: 当前路由会使用哪个接口来发送数据
Flags: 标记，可能的标记如下
U (route is up)： 路由是活动的
H (target is a host)： 目标是一个主机而非网络
G (use gateway)： 需要透过外部的主机（gateway)来转递封包
R (reinstate route for dynamic routing)： 使用动态路由时，对动态路由进行复位设置的标志
D (dynamically installed by daemon or redirect)： 由后台程序或转发程序动态安装的路由
M (modified from routing daemon or redirect)： 由后台程序或转发程序修改的路由
A (installed by addrconf)： 由addrconf安装的路由
C (cache entry)： 缓存的路由信息
!  (reject route)： 这个路由将不会被接受（主要用来抵御不安全的网络）
```



## 路由分类

### 默认路由

当主机不能在路由表中查找到目标主机的IP地址或网络路由时，数据包就被发送到默认路由（默认网关）上。默认路由的Flags字段为G。



### 网络路由

网络路由是代表主机可以到达的网络。网络路由的Flags字段为`G`。例如，在下面的示例中，本地主机将发送到网络192.19.12.0的数据包转发到IP地址为192.168.1.1的路由器上



### 主机路由

主机路由是路由选择表中指向单个IP地址或主机名的路由记录。主机路由的Flags字段为`H`。例如，在下面的示例中，本地主机通过IP地址192.168.1.1的路由器到达IP地址为10.0.0.10的主机：



### 多路径路由multipath routing

加了两个下一跳，然后每一个都有一个权重(weight),而最终选择那个nexthop，主要是根据权重值。

```shell
ip route add default  proto static scope global nexthop  via 192.168.1.1 weight 100 nexthop  via 192.168.1.2 weight 1
```



## 添加临时路由

### route命令

#### 使用参数

```shell
Usage: inet_route [-vF] del {-host|-net} Target[/prefix] [gw Gw] [metric M] [[dev] If]
       inet_route [-vF] add {-host|-net} Target[/prefix] [gw Gw] [metric M]
                              [netmask N] [mss Mss] [window W] [irtt I]
                              [mod] [dyn] [reinstate] [[dev] If]
       inet_route [-vF] add {-host|-net} Target[/prefix] [metric M] reject
       inet_route [-FC] flush      NOT supported
```

#### 实例

```shell
查看
# route -n
# route -nee
# netstat -nr ## 该命令和route -n输出结果一样
添加
route add default gw 192.168.0.1
route add -net 192.168.1.0/24 gw 192.168.0.1
route add -host 192.168.1.2 dev eth0
删除
route del default gw 192.168.0.1
route del -net 192.168.1.0/24 gw 192.168.0.1
route del -host 192.168.1.2 dev eth0
```

> add 增加路由  del 删除路由  
>
> -net 设置到某个网段的路由  -host 设置到某台主机的路由
>
> gw 出口网关 IP地址  dev 出口网关 物理设备名

### ip命令

#### 使用参数

```shell
ip route { add | del | change | append | replace } ROUTE
```

> ip route 可以简写成ip r

#### 实例

```shell
查看
ip route
添加
ip route add default via 192.168.0.1 dev eth0
ip r add 192.168.1.0/24 gw 192.168.0.1
ip r add 192.168.1.2 dev eth0
删除
ip route delete default via 192.168.0.1 dev eth0
ip r d 192.168.1.0/24 gw 192.168.0.1
ip r d 192.168.1.2 dev eth0
```

> add 增加路由 del 删除路由  via 网关出口 IP地址 dev 网关出口 物理设备名

## 添加永久路由

在命令行使用ip或者route命令设定的静态路由会在系统关机或重启后丢失，要配置静态路由以便在系统重启后也可以保留，大概方式有以下3中方式。

> 以下修改方式针对CentOS7,Ubuntu方式略有不同。

### /etc/sysconfig/static-routes方式

network脚本执行时调用的一个文件/etc/sysconfig/static-routes，添加文件的格式any net 192.168.0.0/16 gw 网关ip。

```
# cat /etc/sysconfig/static-routes
any net 192.168..0/16 gw
```

这样设置是因为/etc/rc.d/init.d/network有相应的说明，必须是以any开头，网络和主机不需要添加‘-’。

```shell
# less /etc/rc.d/init.d/network
    ......
    # Add non interface-specific static-routes.
    if [ -f /etc/sysconfig/static-routes ]; then
        if [ -x /sbin/route ]; then
            grep "^any" /etc/sysconfig/static-routes | while read ignore args ; do
                /sbin/route add -$args
            done
        else
            net_log $"Legacy static-route support not available: /sbin/route not found"
        fi
    fi
```

### /etc/sysconfig/network-scripts/route-网卡名 方式

需要在/etc/sysconfig/network-scripts/目录中创建格式为"route-网卡名"的配置文件，通过默认是不存在route-"网卡名"文件。

```shell
# cat /etc/sysconfig/network-scripts/route-eth0 
192.168.0.0/24 via 10.135.139.65  dev eth0
# systemctl restart network
```

> 格式为：网段或主机  via 网关  dev 网卡名; 需要重启网络才生效。

[红帽官网](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/deployment_guide/sec-configuring_static_routes_in_ifcfg_files)

```
# cat /etc/sysconfig/network-scripts/ifup-routes
......
handle_file () {
......
        line="$line dev $2"
        /sbin/ip route add $line
......
}

......
# Red Hat network configuration format
NICK=${2:-$1}
CONFIG="/etc/sysconfig/network-scripts/$NICK.route"
[ -f $CONFIG ] && handle_file $CONFIG $1

# Routing rules
FILES="/etc/sysconfig/network-scripts/rule-$1 /etc/sysconfig/network-scripts/rule6-$1"
if [ -n "$2" -a "$2" != "$1" ]; then
    FILES="$FILES /etc/sysconfig/network-scripts/rule-$2 /etc/sysconfig/network-scripts/rule6-$2"
fi
```



### /etc/rc.local方式



## 附件



```shell
# ip route help
Usage: ip route { list | flush } SELECTOR
       ip route save SELECTOR
       ip route restore
       ip route showdump
       ip route get ADDRESS [ from ADDRESS iif STRING ]
                            [ oif STRING ] [ tos TOS ]
                            [ mark NUMBER ] [ vrf NAME ]
                            [ uid NUMBER ]
       ip route { add | del | change | append | replace } ROUTE
SELECTOR := [ root PREFIX ] [ match PREFIX ] [ exact PREFIX ]
            [ table TABLE_ID ] [ vrf NAME ] [ proto RTPROTO ]
            [ type TYPE ] [ scope SCOPE ]
ROUTE := NODE_SPEC [ INFO_SPEC ]
NODE_SPEC := [ TYPE ] PREFIX [ tos TOS ]
             [ table TABLE_ID ] [ proto RTPROTO ]
             [ scope SCOPE ] [ metric METRIC ]
INFO_SPEC := NH OPTIONS FLAGS [ nexthop NH ]...
NH := [ encap ENCAPTYPE ENCAPHDR ] [ via [ FAMILY ] ADDRESS ]
	    [ dev STRING ] [ weight NUMBER ] NHFLAGS
FAMILY := [ inet | inet6 | ipx | dnet | mpls | bridge | link ]
OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ] [ as [ to ] ADDRESS ]
           [ rtt TIME ] [ rttvar TIME ] [ reordering NUMBER ]
           [ window NUMBER ] [ cwnd NUMBER ] [ initcwnd NUMBER ]
           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]
           [ rto_min TIME ] [ hoplimit NUMBER ] [ initrwnd NUMBER ]
           [ features FEATURES ] [ quickack BOOL ] [ congctl NAME ]
           [ pref PREF ] [ expires TIME ]
TYPE := { unicast | local | broadcast | multicast | throw |
          unreachable | prohibit | blackhole | nat }
TABLE_ID := [ local | main | default | all | NUMBER ]
SCOPE := [ host | link | global | NUMBER ]
NHFLAGS := [ onlink | pervasive ]
RTPROTO := [ kernel | boot | static | NUMBER ]
PREF := [ low | medium | high ]
TIME := NUMBER[s|ms]
BOOL := [1|0]
FEATURES := ecn
ENCAPTYPE := [ mpls | ip | ip6 ]
ENCAPHDR := [ MPLSLABEL ]
```



```ini
Debian/Ununtu添加路由的脚本放到/etc/network/interfaces里执行：
auto eth0
iface eth0 inet static
address 192.168.1.88
netmask 255.255.255.0
gateway 192.168.1.1
up route add -net 192.168.2.0 netmask 255.255.255.0 gw 192.168.2.1
down route del -net 192.168.2.0 netmask 255.255.255.0 gw 192.168.2.1
```

