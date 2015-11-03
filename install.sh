#!/bin/bash
# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

. include/common.sh
. include/init.sh

Get_Dist_Name

# Linux版本
if [ "${DISTRO}" = "unknow" ]; then
    Echo_Red "Unable to get Linux distribution name, or do NOT support the current distribution."
    exit 1
fi



dst_root=$(tail -n 1 DST_ROOT) # 安装路径
dst_etc=$dst_root/etc # 配置文件
dst_htdocs=$dst_root/htdocs 
dst_logs=$dst_root/var/logs
dst_run=$dst_root/var/run # nginx pid
dst_tmp=$dst_root/var/tmp # nginx tmp
# if [ ! -d "$dst_root" ]; then
ll $dst_etc || mkdir $dst_etc
ll $dst_htdocs || mkdir $dst_htdocs
ll $dst_logs || mkdir -p $dst_logs
ll $dst_run ||  mkdir -p $dst_run
ll $dst_tmp || mkdir -p $dst_tmp
echo 'all files will install to' $dst_root
# fi

clear
echo "========================================================================="
echo "Include the init.sh file"
echo "========================================================================="


# 添加 web 用户组, 跟网络操作相关的用户, 都应该属于 web 组
grep '^web' /etc/group || /usr/sbin/groupadd web
grep '^git' /etc/passwd || /usr/sbin/useradd --groups=web git


shell_dir=$(pwd)
# conf dir
conf_dir=$shell_dir'/conf'

echo -e "\n config file directory is $conf_dir"

function init()
{
    # 提示安装,并加载version.sh
    Press_Install
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
    # Disable SeLinux
    Disable_Selinux
    # init common shell
    Init_Shell
    Check_Download
    Install_Autoconf
    Install_Libiconv
    Install_Libmcrypt
    Install_Mhash
    Install_Mcrypt
    Install_Pcre

    CentOS_Lib_Opt

    

}

    Press_Install
# init 2>&1 | tee /root/as-init-install.log
