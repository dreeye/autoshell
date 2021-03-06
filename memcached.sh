#!/bin/bash
. ./install.sh
clear

Install_PHPMemcached()
{
    echo "Install memcached php extension..."
    yum install cyrus-sasl-devel -y

    cd ${shell_dir}/software
    Download_Files ${Libmemcached_Mirror} ${Libmemcached_Ver}.tar.gz
    Download_Files ${PHPMemcached_Mirror} ${PHPMemcached_Ver}.tgz

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

Install_PHPMemcache()
{
    echo "Install memcache php extension..."
    yum install cyrus-sasl-devel -y

    cd ${shell_dir}/software
    Download_Files ${PHPMemcache_Mirror} ${PHPMemcache_Ver}.tgz

    Tar_Cd ${PHPMemcache_Ver}.tgz ${PHPMemcache_Ver}
    ${dst_root}/php/bin/phpize
    ./configure --with-php-config=${dst_root}/php/bin/php-config
    make && make install
    cd ../
}


#Install_Autoconf()
#{
#    Echo_Blue "[+] Installing ${Autoconf_Ver}"
#    cd ${shell_dir}/software
#    Download_Files ${Autoconf_Mirror} ${Autoconf_Ver}.tar.gz
#    Tar_Cd ${Autoconf_Ver}.tar.gz ${Autoconf_Ver}
#    ./configure --prefix=${dst_root}/autoconf
#    make && make install
#}

Install_Memcached()
{

    PHP_ZTS="memcache.so"
    PHP_ZTS_D="memcached.so"

    echo "====== Installing memcached ======"

    sed -i '/memcache.so/d' ${dst_root}/php/etc/php.ini
    sed -i '/memcached.so/d' ${dst_root}/php/etc/php.ini
    Get_PHP_Ext_Dir
    zend_ext=${zend_ext_dir}${PHP_ZTS}
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi
    zend_ext_d=${zend_ext_dir}${PHP_ZTS_D}
    if [ -s "${zend_ext_d}" ]; then
        rm -f "${zend_ext_d}"
    fi


        sed -i "/the dl()/i\
extension = \"${PHP_ZTS}\"" ${dst_root}/php/etc/php.ini

        sed -i "/the dl()/i\
extension = \"${PHP_ZTS_D}\"" ${dst_root}/php/etc/php.ini

    echo "Install memcached..."

    cd ${shell_dir}/software
    Download_Files ${Memcached_Mirror} ${Memcached_Ver}.tar.gz

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
    Install_PHPMemcache
    #echo "Copy Memcached PHP Test file..."
    #\cp ${cur_dir}/conf/memcached${ver}.php /home/wwwroot/default/memcached.php

    #Restart_PHP

    if [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT -p tcp -s 127.0.0.1 --dport 11211 -j ACCEPT
        /sbin/iptables -I INPUT -p udp -s 127.0.0.1 --dport 11211 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp --dport 11211 -j DROP
        /sbin/iptables -A INPUT -p udp --dport 11211 -j DROP
        if [ -s /usr/sbin/firewalld ]; then
            service iptables save
            systemctl restart iptables
        else
            /etc/rc.d/init.d/iptables save
            /etc/rc.d/init.d/iptables restart
        fi
    fi  

    #echo "Starting Memcached..."
    #/etc/init.d/memcached start

    if [ -s ${zend_ext} ]; then
        echo "====== Memcache install completed ======"
        echo "Memcached installed successfully, enjoy it!"
    else
        sed -i '/${PHP_ZTS}/d' ${dst_root}/php/etc/php.ini
        echo "Memcached install failed!"
    fi
    if [ -s ${zend_ext_d} ]; then
        echo "====== Memcached install completed ======"
        echo "Memcached installed successfully, enjoy it!"
    else
        sed -i '/${PHP_ZTS_D}/d' ${dst_root}/php/etc/php.ini
        echo "Memcached install failed!"
    fi
}

#Install_Autoconf
Export_PHP_Autoconf
Install_Memcached
