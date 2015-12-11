Check_Download()
{
    Echo_Blue "[+] Downloading files..."
    cd ${shell_dir}/software
    Download_Files ${Pcre_Mirror} ${Pcre_Ver}.tar.gz
    Download_Files ${Libiconv_Mirror} ${Libiconv_Ver}.tar.gz
    Download_Files ${LibMcrypt_Mirror} ${LibMcrypt_Ver}.tar.gz
    Download_Files ${Mcypt_Mirror} ${Mcypt_Ver}.tar.gz
    Download_Files ${Php_Mirror} ${Php_Ver}.tar.gz
    Download_Files ${Autoconf_Mirror} ${Autoconf_Ver}.tar.gz
    Download_Files ${Mhash_Mirror} ${Mhash_Ver}.tar.gz
}

Init_iptables()
{
    if [ -s /usr/sbin/firewalld ]; then
        systemctl stop firewalld
        systemctl disable firewalld
        yum -y install iptables-services
        systemctl enable iptables
    fi 

}

Press_Install()
{
    echo ""
    Echo_Green "Press any key to start...or Press Ctrl+c to cancel"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}

Init_Shell()
{
    # create common.sh 
    if [ ! -s "/etc/profile.d/common.sh" ]; then
        touch '/etc/profile.d/common.sh'
    fi

    alias_color=$(grep 'alias grep='\''grep --color=auto'\''' /etc/profile.d/common.sh)

    if [ "$alias_color" == "" ]; then
        # sed -i '$a alias grep='\''grep --color=auto'\''' /etc/profile.d/common.sh
        echo 'alias grep='\''grep --color=auto'\''' >> /etc/profile.d/common.sh
    fi

    alias_utime=$(grep 'alias utime='\''sudo ntpdate -u pool.ntp.org'\''' /etc/profile.d/common.sh)

    if [ "$alias_utime" == "" ]; then
        # sed -i '$a alias utime='\''sudo ntpdate -u pool.ntp.org'\''' /etc/profile.d/common.sh
        echo 'alias utime='\''sudo ntpdate -u pool.ntp.org'\''' >> /etc/profile.d/common.sh
    fi

    goroot=$(grep "$GOROOT" /etc/profile.d/common.sh)

    if [ "$goroot" == "" ]; then
        # sed -i '$a export $GOROOT=$dst_root/go' /etc/profile.d/common.sh
        echo 'export $GOROOT=$dst_root/go' >> /etc/profile.d/common.sh
    fi

    #root_path=$(grep "$dst_root/bin" /etc/profile.d/common.sh)

    #if [ "$root_path" == "" ]; then
        # echo "PATH=$dst_root/bin:$dst_root/sbin:~/bin:$GOROOT/bin:$PATH" >> /etc/profile.d/common.sh
    #    echo "export PATH" /etc/profile.d/common.sh
    #fi

}

# 初始化yum更新
CentOS_Dependent()
{
    cp /etc/yum.conf /etc/yum.conf.lnmp
    sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf

    Echo_Blue "[+] Yum installing dependent packages..."
    for packages in gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel libxslt-devel libffi-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers zip unzip man perl-CPAN cmake bison wget mlocate git openssh-server openssh-clients patch make gcc-g77 flex file libtool libtool-libs kernel-devel libpng10 libpng10-devel gd gd-devel fonts-chinese gettext gettext-devel gmp-devel pspell-devel libcap diffutils libpcap-devel readline-devel lrzsz screen rubygems tar libevent libevent-devel net-tools libc-client-devel psmisc libXpm-devel c-ares-devel;
    do yum -y install $packages; done

    mv -f /etc/yum.conf.lnmp /etc/yum.conf
}

Disable_Selinux()
{
    if [ -s /etc/selinux/config ]; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    fi
}

Install_Autoconf()
{
    Echo_Blue "[+] Installing ${Autoconf_Ver}"
    Tar_Cd ${Autoconf_Ver}.tar.gz ${Autoconf_Ver}
    ./configure --prefix=${dst_root}/autoconf
    make && make install
}

Install_Libiconv()
{
    Echo_Blue "[+] Installing ${Libiconv_Ver}"
    Tar_Cd ${Libiconv_Ver}.tar.gz ${Libiconv_Ver}
    ./configure 
    make && make install
}

Install_Libmcrypt()
{
    Echo_Blue "[+] Installing ${LibMcrypt_Ver}"
    Tar_Cd ${LibMcrypt_Ver}.tar.gz ${LibMcrypt_Ver}
    ./configure
    make && make install
    /sbin/ldconfig
    cd libltdl/
    ./configure --enable-ltdl-install
    make && make install
    ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
    ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
    ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
    ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
    ldconfig
}

Install_Mcrypt()
{
    Echo_Blue "[+] Installing ${Mcypt_Ver}"
    Tar_Cd ${Mcypt_Ver}.tar.gz ${Mcypt_Ver}
    ./configure
    make && make install
}

Install_Mhash()
{
    Echo_Blue "[+] Installing ${Mhash_Ver}"
    Tar_Cd ${Mhash_Ver}.tar.gz ${Mhash_Ver}
    ./configure
    make && make install
    ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
    ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
    ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
    ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
    ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
    ldconfig
}

Install_Pcre()
{
    #Cur_Pcre_Ver=`pcre-config --version`
    #if echo "${Cur_Pcre_Ver}" | grep -vEqi '^8.';then
        Echo_Blue "[+] Installing ${Pcre_Ver}"
        Tar_Cd ${Pcre_Ver}.tar.gz ${Pcre_Ver}
        ./configure
        make && make install
    #fi
}

CentOS_Lib_Opt()
{
    # common.sh 53
    if [ "${Is_64bit}" = "y" ] ; then
    ln -s /usr/lib64/libpng.* /usr/lib/
    ln -s /usr/lib64/libjpeg.* /usr/lib/
    fi

    ulimit -v unlimited

    if [ `grep -L "/lib"    '/etc/ld.so.conf'` ]; then
        echo "/lib" >> /etc/ld.so.conf
    fi

    if [ `grep -L '/usr/lib'    '/etc/ld.so.conf'` ]; then
        echo "/usr/lib" >> /etc/ld.so.conf
        #echo "/usr/lib/openssl/engines" >> /etc/ld.so.conf
    fi

    if [ -d "/usr/lib64" ] && [ `grep -L '/usr/lib64'    '/etc/ld.so.conf'` ]; then
        echo "/usr/lib64" >> /etc/ld.so.conf
        #echo "/usr/lib64/openssl/engines" >> /etc/ld.so.conf
    fi

    if [ `grep -L '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
        echo "/usr/local/lib" >> /etc/ld.so.conf
    fi

    ldconfig

    cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof

    echo "fs.file-max=65535" >> /etc/sysctl.conf
}

#pipize 安装so扩展必要,会检查autoconf是否安装
Export_PHP_Autoconf()
{
    if [ -d "${dst_root}/autoconf" ]; then
        export PHP_AUTOCONF=${dst_root}/autoconf/bin/autoconf
        export PHP_AUTOHEADER=${dst_root}/autoconf/bin/autoheader
    else
        Echo_Red "isnt setup autoconf , Please sh install.sh and allow setup phpext!"
        exit 1
    fi
}
