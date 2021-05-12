# init linux server
## 1.基础配置: hostname, hosts, users, environments
- hostname: 根据ansible hosts.ini中 my_hostname来修改，不设置则使用系统默认主机名；
- hosts: 修改/etc/hosts配置，格式为inventory_hostname  ansible_hostname，注意hosts.ini需要是ip地址；
- users: 添加用户和key，变量在roles/common/vars/main.yml设置，key可以指定目录，如果没有，会~/.ssh目录，都没有则会使用默认roles/common/files/id_rsa.pub；
- environments：提示符-包括PS1和登录提示；历史命令记录，语言时区，关闭ctrl-alt-del。

2.服务设置: iptables, selinux, sshd, NetworkManger, rsyslog

3.调优配置: kernel, limits

4.基础服务: ntp, dns, repo

5.常用工具: vim, telnet, tcpdump, nc

6.网络配置: bond, ipv6

7.安全加固: 

