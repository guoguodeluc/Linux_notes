#!/bin/bash
## author:lujianguo
## date: 20211108
## version: v1.0
### description: get pids open files
### 获取单个进程文件句柄限制和使用量，以及所有进程的文件句柄信息。
####################################

### Set Vars ### 该$2变量为单个进程pid号，会显示该pid的文件句柄信息。
my_pid=$2

### Functions ### 定义多个函数；
### Usage使用方式， Echo_title显示标头，；
### Handle_Pid_Info处理pid信息， Get_Pid_Info获取单个pid信息， Get_All_Pid所有进程信息。
Usage() {
  echo -e "\e[31;1mUsage: bash $0 get pid \n       bash $0 (get all pid info)\e[0m"
}

## 显示pida，软限制，硬限制，目前文件句柄使用量，进程名
Echo_title(){
  echo -e "\e[32;1mPid\tSoft_fd\tHard_fd\tCur_fd\tComm\e[0m"
}

## 获取单个pid的软限制，硬限制，目前文件句柄使用量，进程名
Handle_Pid_Info(){
  soft_fd=`awk '/open files/{print $4}' /proc/$1/limits`
  hard_fd=`awk '/open files/{print $5}' /proc/$1/limits`
  current_fd=`ls -l /proc/$1/fd |wc -l`
  pid_comm=`cat /proc/$1/comm`
  echo -e "$1\t$soft_fd\t$hard_fd\t$current_fd\t$pid_comm"
}

## 获取单个pid文件句柄，如果pid不存在
Get_Pid_Info(){
  ps -Ao pid | grep -w $1 >/dev/null 2>&1  
  if [ $? -eq 0 ] ; then
    Echo_title && Handle_Pid_Info $1
  else
    echo "Pid $1 is not exsiting or Wrong pid !!!" && Usage
  fi
}

## 获取所有pid的文件句柄，标准错误不显示，并按照目前文件句柄使用量排序。
Get_All_Pid(){
  Echo_title
  ps -Ao pid |egrep -v 'PID' |while read i;
  do
    Handle_Pid_Info $i
  done 2> /dev/null |sort -k4rn
}

### Run Functions ### 运行函数，默认不加参数会获取所有pid的文件句柄数。
case $1 in
  get  ) Get_Pid_Info $2 ;;
  help|-h ) Usage ;;
  all|* ) Get_All_Pid ;;
esac
