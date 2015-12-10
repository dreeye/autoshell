#!/bin/bash
# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

. include/common.sh
. include/init.sh
. include/mirror.sh

Get_Dist_Name

# Linux版本
if [ "${DISTRO}" = "unknow" ]; then
    Echo_Red "Unable to get Linux distribution name, or do NOT support the current distribution."
    exit 1
fi



dst_root=$(tail -n 1 DST_ROOT) # 安装路径
echo 'all files will install to' $dst_root

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

# 打印系统内存信息,CentOS版本
Print_Sys_Info
Get_Dist_Version
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

if [ -d "${dst_root}/autoconf" ]; then
    Echo_Blue "autoconf already setuped !! "
else
    Install_Autoconf
fi

function ext()
{
    # 提示安装,需要研究下
    #Press_Install
    Install_Libiconv
    Install_Libmcrypt
    Install_Mhash
    Install_Mcrypt
    Install_Pcre

    # 动态库软连接
    CentOS_Lib_Opt


}

Press_Install

setup_phpext="n"
echo "Need start setup iconv, mcrypt, mhash, pcre?"
read -p "(Press y going setup. Default: n):" setup_phpext 
if [ "$setup_phpext" = "" ];then
    setup_phpext="n"
fi
if [ "$setup_phpext" = "y" ];then
    ext 2>&1 | tee /root/as-init-install.log
fi
