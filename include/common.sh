Install_LSB()
{
    if [ "$PM" = "yum" ]; then
        yum -y install redhat-lsb
    elif [ "$PM" = "apt" ]; then
        apt-get update
        apt-get install -y lsb-release
    fi
}

# 安装redhat-lsb,确定centos版本号
Get_Dist_Version()
{
    Install_LSB
    eval ${DISTRO}_Version=`lsb_release -rs`
    eval echo "${DISTRO} \${${DISTRO}_Version}"
}

# 获取DISTOR(系统版本名)和PM(包管理器名)
Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

# 是否为64位系统
Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        Is_64bit='y'
    else
        Is_64bit='n'
    fi
}


Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
  echo $(Color_Text "$1" "33")
}

Echo_Blue()
{
  echo $(Color_Text "$1" "34")
}

# CentOS删除httpd,php,mysql rpm包
CentOS_RemoveAMP()
{
    Echo_Blue "[-] Yum remove packages..."
    rpm -qa|grep httpd
    rpm -e httpd httpd-tools
    rpm -qa|grep mysql
    rpm -e mysql mysql-libs
    rpm -qa|grep php
    rpm -e php-mysql php-cli php-gd php-common php

    yum -y remove httpd*
    yum -y remove mysql-server mysql mysql-libs
    yum -y remove php*
    yum clean all
}

# CentOS 安装ntp并更新时间
CentOS_InstallNTP()
{
    Echo_Blue "[+] Installing ntp..."
    yum install -y ntp
    ntpdate -u pool.ntp.org
    date
}

# 打印系统内存信息
Print_Sys_Info()
{
    cat /etc/issue
    cat /etc/*-release
    uname -a
    MemTotal=`free -m | grep Mem | awk '{print  $2}'`  
    echo "Memory is: ${MemTotal} MB "
    df -h
}

# 设置时间
Set_Timezone()
{
    Echo_Blue "Setting timezone..."
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}



Tar_Cd()
{
    local FileName=$1
    local DirName=$2
    cd ${shell_dir}/software
    [[ -d "${DirName}" ]] && rm -rf ${DirName}
    echo "Uncompress ${FileName}..."
    tar zxf ${FileName}
    echo "cd ${DirName}..."
    cd ${DirName}
}

Download_Files()
{
    local URL=$1
    local FileName=$2
    if [ -s "${FileName}" ]; then
        echo "${FileName} [found]"
    else
        echo "Error: ${FileName} not found!!!download now..."
        wget -c ${URL}
    fi
}

Get_PHP_Ext_Dir()
{
    Cur_PHP_Version=`${dst_root}/bin/php -r 'echo PHP_VERSION;'`
    if echo "${Cur_PHP_Version}" | grep -Eqi '^5.2.'; then
       zend_ext_dir="/usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/"
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^5.3.'; then
       zend_ext_dir="/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/"
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^5.4.'; then
       zend_ext_dir="/usr/local/php/lib/php/extensions/no-debug-non-zts-20100525/"
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^5.5.'; then
       zend_ext_dir="/usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/"
    elif echo "${Cur_PHP_Version}" | grep -Eqi '^5.6.'; then
       zend_ext_dir="/usr/local/php/lib/php/extensions/no-debug-non-zts-20131226/"
    fi
}
