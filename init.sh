#!/bin/bash
# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

. include/common.sh

# Linux版本
if [ "${DISTRO}" = "unknow" ]; then
    Echo_Red "Unable to get Linux distribution name, or do NOT support the current distribution."
    exit 1
fi


# 安装路径
dst_root=$(tail -n 1 DST_ROOT)
dst_var=$dst_root/var
dst_etc=$dst_root/etc
dst_htdocs=$dst_root/htdocs
# var/
dst_logs=$dst_var/logs
dst_run=$dst_var/run
dst_tmp=$dst_var/tmp
if [ ! -d "$dst_root" ]; then
    mkdir $dst_var
    mkdir $dst_etc
    mkdir $dst_htdocs
    mkdir -p $dst_logs
    mkdir -p $dst_run
    mkdir -p $dst_tmp
    echo 'all files will install to' $dst_root
fi

clear
echo "========================================================================="
echo "Include the init.sh file"
echo "========================================================================="


# 添加 web 用户组, 跟网络操作相关的用户, 都应该属于 web 组
grep '^web' /etc/group || /usr/sbin/groupadd web


#shell dir
shell_dir=$(pwd)
if [ ! -d "conf" ]; then
    echo 'please cd PNshell dir'
    exit 0
fi
if [ ! -d "${shell_dir}/software" ]; then
    mkdir $shell_dir'/software'
fi

# software dir
soft_dir=$shell_dir'/software'
echo -e "\n software directory is $soft_dir"
# conf dir
conf_dir=$shell_dir'/conf'
echo -e "\n config file directory is $conf_dir"

function init()
{
    # 打印系统内存信息,CentOS版本
    Print_Sys_Info

    #Set timezone
    Set_Timezone

    # CentOS 安装ntp并更新时间
    CentOS_InstallNTP
    # CentOS删除httpd,php,mysql rpm包
    CentOS_RemoveAMP
    # 初始化yum更新
    CentOS_Dependent
    #Disable SeLinux
    Disable_Selinux

    alias_color=$(grep 'alias grep='\''grep --color=auto'\''' /etc/bashrc)

    if [ "$alias_color" == "" ]; then
        sed -i '$a alias grep='\''grep --color=auto'\''' /etc/bashrc
    fi

    alias_utime=$(grep 'alias utime='\''sudo ntpdate -u pool.ntp.org'\''' /etc/bashrc)

    if [ "$alias_utime" == "" ]; then
        sed -i '$a alias utime='\''sudo ntpdate -u pool.ntp.org'\''' /etc/bashrc
    fi
    goroot=$(grep "$GOROOT" /etc/bashrc)

    if [ "$goroot" == "" ]; then
        sed -i '$a export $GOROOT=$dst_root/go' /etc/bashrc
    fi

    root_path=$(grep "$dst_root/bin" /etc/bashrc)

    if [ "$root_path" == "" ]; then
        sed -i "\$a PATH=$dst_root/bin:$dst_root/sbin:~/bin:$GOROOT/bin:$PATH" /etc/bashrc
        sed -i "\$a export PATH" /etc/bashrc
    fi


}
