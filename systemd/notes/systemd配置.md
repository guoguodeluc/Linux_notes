# systemd配置
详细说明见
`man 5 systemd.service`
https://www.freedesktop.org/software/systemd/man/bootup.html#System%20Manager%20Bootup
https://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html

## 查看配置方式
```
# systemctl cat sshd 
# cat /usr/lib/systemd/system/sshd.service 
```

## 重新加载配置
```
# systemctl daemon-reload
```


## [Unit]区域
启动顺序和依赖关系

Description字段: 给出当前服务的简单描述
Documentation字段：给出文档位置。

After和Before字段：只涉及启动顺序，不涉及依赖关系。
Wants字段(弱依赖)与Requires字段(强依赖)：只涉及依赖关系，与启动顺序无关，默认情况下是同时启动的。


## [Services]区域
如何启动和关闭服务
Type字段: 启动类型
- simple（默认值）：ExecStart字段启动的进程为主进程
- forking：ExecStart字段将以fork()方式启动，此时父进程将会退出，子进程将成为主进程
- oneshot：类似于simple，但只执行一次，Systemd 会等它执行完，才启动其他服务
- dbus：类似于simple，但会等待 D-Bus 信号后启动
- notify：类似于simple，启动结束后会发出通知信号，然后 Systemd 再启动其他服务
- idle：类似于simple，但是要等到其他任务都执行完，才会启动该服务。一种使用场合是为让该服务的输出，不与其他服务的输出相混合



EnvironmentFile字段: 环境变量, systemctl show sshd可以查看服务的环境变量;
ExecStart字段：定义启动进程时执行的命令， 正常是可以执行文件加上选项参数；
ExecReload字段：重启服务时执行的命令
ExecStop字段：停止服务时执行的命令
ExecStartPre字段：启动服务之前执行的命令
ExecStartPost字段：启动服务之后执行的命令
ExecStopPost字段：停止服务之后执行的命令

KillMode字段：定义 Systemd 如何停止服务

- control-group（默认值）：当前控制组里面的所有子进程，都会被杀掉
- process：只杀主进程
- mixed：主进程将收到 SIGTERM 信号，子进程收到 SIGKILL 信号
- none：没有进程会被杀掉，只是执行服务的 stop 命令。

Restart字段：定义了服务退出后，Systemd 的重启方式
- no（默认值）：退出后不会重启
- on-success：只有正常退出时（退出状态码为0），才会重启
- on-failure：非正常退出时（退出状态码非0），包括被信号终止和超时，才会重启
- on-abnormal：只有被信号终止和超时，才会重启
- on-abort：只有在收到没有捕捉到的信号终止时，才会重启
- on-watchdog：超时退出，才会重启
- always：不管是什么退出原因，总是重启

RestartSec字段：表示 Systemd 重启服务之前，需要等待的秒数。


## [Install]区域
WantedBy字段：表示该服务所在的 Target，正常设置multi-user.target即可；


