# /etc/systemd/system和/usr/lib/systemd/system区别

详细说明见
` # man 5 systemd.unit `
       Table 1.  Load path when running in system mode (--system).
       ┌────────────────────────┬─────────────────────────────┐
       │Path                    │ Description                 │
       ├────────────────────────┼─────────────────────────────┤
       │/etc/systemd/system     │ Local configuration         │
       ├────────────────────────┼─────────────────────────────┤
       │/run/systemd/system     │ Runtime units               │
       ├────────────────────────┼─────────────────────────────┤
       │/usr/lib/systemd/system │ Units of installed packages │
       └────────────────────────┴─────────────────────────────┘
这三个目录的配置文件优先级依次从高到低，如果同一选项三个地方都配置了，优先级高的会覆盖优先级低的。

## /etc/systemd/system/(系统管理员安装的单元, 优先级更高)
> Files in /etc/systemd/system are manually placed here by the operator of the system for ad-hoc software installations that are not in the form of a package. This would include tarball type software installations or home grown scripts

创建开机自启  Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /etc/systemd/system/docker.service.

## [/usr]/lib/systemd/system/ 该目录中包含的是软件包安装的单元,也就是说通过yum、dnf、rpm等软件包管理命令管理的systemd单元文件，都放置在该目录下。
[/usr]/lib/systemd/system/
> The expectation is that `/lib/systemd/system` is a directory that should only contain systemd unit files which were put there by the package manager (YUM/DNF/RPM/APT/etc).


如果我们想要修改系统默认的配置，比如nginx.service
一般有两种方法：
在/etc/systemd/system目录下创建nginx.service文件，里面写上我们自己的配置。
在/etc/systemd/system下面创建nginx.service.d目录，在这个目录里面新建任何以.conf结尾的文件，然后写入我们自己的配置。推荐这种做法。
