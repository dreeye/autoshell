#!/bin/bash

# 安装路径
dst_root=$(tail -n 1 DST_ROOT)
if [ ! -d "$dst_root" ]; then
    mkdir  $dst_root
    echo 'all files will install to' $dst_root
fi
PATH=$dst_root/bin:$dst_root/sbin:~/bin:$PATH
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
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
    #show CentOS版本
    cat /etc/issue

    #show Linux core
    uname -a

    #show memory
    MemTotal=`free -m | grep Mem | awk '{print  $2}'`  
    echo -e "\n Memory is: $MemTotal MB "

    #Set timezone
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    yum -y install ntp
    ntpdate -u pool.ntp.org
    date

    alias_color=$(grep 'alias grep='\''grep --color=auto'\''' /etc/bashrc)

    if [ "$alias_color" == "" ]; then
        sed -i '$a alias grep='\''grep --color=auto'\''' /etc/bashrc
    fi

    alias_utime=$(grep 'alias utime='\''sudo ntpdate -u pool.ntp.org'\''' /etc/bashrc)

    if [ "$alias_utime" == "" ]; then
        sed -i '$a alias utime='\''sudo ntpdate -u pool.ntp.org'\''' /etc/bashrc
    fi

    #Disable SeLinux
    if [ -s /etc/selinux/config ]; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    fi

    for packages in gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel libxslt-devel libffi-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers zip unzip man perl-CPAN cmake bison wget mlocate git openssh-server openssh-clients patch make gcc-g77 flex file libtool libtool-libs kernel-devel libpng10 libpng10-devel gd gd-devel fonts-chinese gettext gettext-devel gmp-devel pspell-devel libcap diffutils libpcap-devel readline-devel lrzsz screen;
    do yum -y install $packages; done
    
    #update glibc 6.4 to 6.5
    yum -y update glibc 
}
