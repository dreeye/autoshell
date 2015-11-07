#!/bin/bash
. ./install.sh
clear




Install_Redis()
{

    PHP_ZTS="redis.so"

    echo "====== Installing redis ======"

    sed -i '/redis.so/d' ${dst_root}/php/etc/php.ini
    cd ${shell_dir}/software
    Get_PHP_Ext_Dir
    zend_ext=${zend_ext_dir}${PHP_ZTS}
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi


    echo "Install redis..."

    cd ${shell_dir}/software
    Download_Files ${Redis_Mirror} ${Redis_Ver}.tar.gz
    Tar_Cd ${Redis_Ver}.tar.gz ${Redis_Ver}

    ./configure --prefix=${dst_root}/redis
    make PREFIX=${dst_root}/redis install

    mkdir -p ${dst_root}/redis/etc/
    \cp redis.conf  ${dst_root}/redis/etc/
    sed -i 's/daemonize no/daemonize yes/g' ${dst_root}/redis/etc/redis.conf
    sed -i 's/# bind 127.0.0.1/bind 127.0.0.1/g' ${dst_root}/redis/etc/redis.conf
    cd ../ 

    if [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT -p tcp -s 127.0.0.1 --dport 6379 -j ACCEPT
        /sbin/iptables -A INPUT -p tcp --dport 6379 -j DROP
        if [ "$PM" = "yum" ]; then
            service iptables save
        elif [ "$PM" = "apt" ]; then
            iptables-save > /etc/iptables.rules
        fi  
    fi  

    if [ -s ${PHPRedis_Ver} ]; then
        rm -rf ${PHPRedis_Ver}
    fi  

    Download_Files ${PHPRedis_Ver} ${PHPRedis_Ver}.tgz
    Tar_Cd ${PHPRedis_Ver}.tgz ${PHPRedis_Ver}
    ${dst_root}/php/bin/phpize
    ./configure --with-php-config=${dst_root}/php/bin/php-config
    make && make install
    cd ../

sed -i '/the dl()/i\
extension = "redis.so"' ${dst_root}/php/etc/php.ini

    ln -sf ${dst_root}/redis/bin/redis /usr/bin/redis


    if [ -s ${zend_ext} ]; then
        echo "====== Redis install completed ======"
        echo "Redis installed successfully, enjoy it!"
    else
        sed -i '/${PHP_ZTS}/d' ${dst_root}/php/etc/php.ini
        echo "Redis install failed!"
    fi
}

Uninstall_Redis()
{
    echo "You will uninstall Redis..."
    Press_Start
    sed -i '/memcache.so/d' ${dst_root}php/etc/php.ini
    sed -i '/redis.so/d' ${dst_root}php/etc/php.ini
    Restart_PHP
    Remove_StartUp redis
    echo "Delete Redis files..."
    rm -rf ${dst_root}libredis
    rm -rf ${dst_root}redis
    rm -rf /etc/init.d/redis
    rm -rf /usr/bin/redis
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
    echo "Uninstall Redis completed."
}
#Install_Autoconf
Export_PHP_Autoconf
Install_Redis
