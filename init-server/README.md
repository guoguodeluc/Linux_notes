# init linux server
## 1.基础配置: hostname, hosts, users, environments
### hostname: 
  - 根据ansible hosts.ini中 my_hostname来修改主机名，不设置则使用系统默认主机名；
### hosts
  - 修改/etc/hosts配置，格式为"inventory_hostname  ansible_hostname"，注意hosts.ini里inventory_hostname需要是ip地址；
### users
  - 添加用户和key，变量在roles/common/vars/main.yml设置；
  - key可以指定目录，如果没有，会在~/.ssh目录下寻找，都没有则会使用默认roles/common/files/id_rsa.pub；
### environments
  - 提示符-包括PS1和登录提示,登录超时时间300s；
  - 历史命令记录,记录5000，并收录到日志内;
  - 语言时区,LANG="en_US.UTF-8"；
  - 关闭ctrl-alt-del。

## 2.服务设置: iptables, selinux, sshd, NetworkManger, rsyslog
### iptables
  - 关闭iptables或者firewalld服务，并关闭开机自启； 
### selinux
  - 修改/etc/selinux/config中SELINUX=disabled；
  - setenforce 0；
### sshd
  - 修改/etc/ssh/sshd_config多个参数；
  - PermitEmptyPasswords no；
  - GSSAPIAuthentication no；
  - UseDNS no；
  - 配置文件最后，设置不允许root密码登录，除了私有网段除外；
### NetworkManager
  - NetworkManager服务关闭和关闭开机自启；
### rsyslog
  - 设置rsyslog远端收集日志服务器，并且记录历史命令在/var/log/.history-command.log下。
## 3.调优配置: sysctl, limits
### sysctl
  - 文件位置为/etc/sysctl.d/98-sysctl.conf
  - net
  - vm
  - kernel
### limits
  - 文件位置为/etc/security/limits.d/10-limits.conf
  - nofile
  - nproc
  - core
## 4.公共服务: dns, repo ,ntp
### dns
  - 可以dns_servers设置多个dns，如果不设置默认会使用114.114.114.114;
### repo
  - 移除原有源配置，从template拷贝新文件，base和epel源，默认是aliyun的源;
### ntp
  - 使用chronyd来做时间同步, 跟进ntp_servers来设置，如果没有设置则默认使用cn.pool.ntp.org

## 5.软件包和工具: 
### kenerl升级，
### 网络工具
  - vim, telnet, tcpdump, nc, man-pages 
### 查看资源工具
  - 
### 其他
  - 
## 6.网络配置: bond, ipv6

## 7.安全加固: 

