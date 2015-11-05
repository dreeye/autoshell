#!/bin/bash
. ./install.sh
clear

Install_PHPMemcached()
{
    echo "Install memcached php extension..."
    #cd ${cur_dir}/src
    yum install cyrus-sasl-devel -y
    Tar_Cd ${Libmemcached_Ver}.tar.gz ${Libmemcached_Ver}
    ./configure --prefix=${dst_root}/libmemcached --with-memcached
    make && make install
    cd ../

    Tar_Cd ${PHPMemcached_Ver}.tgz ${PHPMemcached_Ver}
    ${dst_root}/php/bin/phpize
    ./configure --with-php-config=${dst_root}/php/bin/php-config --enable-memcached --with-libmemcached-dir=${dst_root}/libmemcached
    make && make install
    cd ../
}

Export_PHP_Autoconf()
{
    export PHP_AUTOCONF=${dst_root}/autoconf/bin/autoconf
    export PHP_AUTOHEADER=${dst_root}/autoconf/bin/autoheader
}

Install_Autoconf()
{
    Echo_Blue "[+] Installing ${Autoconf_Ver}"
    Tar_Cd ${Autoconf_Ver}.tar.gz ${Autoconf_Ver}
    ./configure --prefix=${dst_root}/autoconf
    make && make install
}

Install_Memcached()
{

    PHP_ZTS="memcached.so"

    echo "====== Installing memcached ======"
    #Press_Install

    sed -i '/memcache.so/d' ${dst_root}/php/etc/php.ini
    sed -i '/memcached.so/d' ${dst_root}/php/etc/php.ini
    Get_PHP_Ext_Dir
    zend_ext=${zend_ext_dir}${PHP_ZTS}
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

        sed -i "/the dl()/i\
extension = \"${PHP_ZTS}\"" ${dst_root}/php/etc/php.ini

    echo "Install memcached..."
    Tar_Cd ${Memcached_Ver}.tar.gz ${Memcached_Ver}
    ./configure --prefix=${dst_root}/memcached
    make &&make install
    cd ../

    ln -sf ${dst_root}/memcached/bin/memcached /usr/bin/memcached

    #\cp ${cur_dir}/init.d/init.d.memcached /etc/init.d/memcached
    #chmod +x /etc/init.d/memcached
    #useradd -s /sbin/nologin nobody

    #if [ ! -d /var/lock/subsys ]; then
     # mkdir -p /var/lock/subsys
    #fi

    #StartUp memcached

    Install_PHPMemcached

    #echo "Copy Memcached PHP Test file..."
    #\cp ${cur_dir}/conf/memcached${ver}.php /home/wwwroot/default/memcached.php

    #Restart_PHP

    if [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT -p tcp -s 127.0.0.1 --dport 11211 -j ACCEPT
        /sbin/iptables -I INPUT -p udp -s 127.0.0.1 --dport 11211 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp --dport 11211 -j DROP
        /sbin/iptables -A INPUT -p udp --dport 11211 -j DROP
        service iptables save
    fi

    #echo "Starting Memcached..."
    #/etc/init.d/memcached start

    if [ -s ${zend_ext} ]; then
        echo "====== Memcached install completed ======"
        echo "Memcached installed successfully, enjoy it!"
    else
        sed -i '/${PHP_ZTS}/d' ${dst_root}/php/etc/php.ini
        echo "Memcached install failed!"
    fi
}

Uninstall_Memcached()
{
    echo "You will uninstall Memcached..."
    Press_Start
    sed -i '/memcache.so/d' ${dst_root}php/etc/php.ini
    sed -i '/memcached.so/d' ${dst_root}php/etc/php.ini
    Restart_PHP
    Remove_StartUp memcached
    echo "Delete Memcached files..."
    rm -rf ${dst_root}libmemcached
    rm -rf ${dst_root}memcached
    rm -rf /etc/init.d/memcached
    rm -rf /usr/bin/memcached
    if [ -s /sbin/iptables ]; then
        /sbin/iptables -D INPUT -p tcp -s 127.0.0.1 --dport 11211 -j ACCEPT
        /sbin/iptables -D INPUT -p udp -s 127.0.0.1 --dport 11211 -j ACCEPT
        /sbin/iptables -D INPUT -p tcp --dport 11211 -j DROP
        /sbin/iptables -D INPUT -p udp --dport 11211 -j DROP
        if [ "$PM" = "yum" ]; then
            service iptables save
        elif [ "$PM" = "apt" ]; then
            iptables-save > /etc/iptables.rules
        fi
    fi
    echo "Uninstall Memcached completed."
}
Install_Autoconf
Export_PHP_Autoconf
Install_Memcached
