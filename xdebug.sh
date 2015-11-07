#!/bin/bash
. ./install.sh
clear




Install_Xdebug()
{

    PHP_ZTS="xdebug.so"

    echo "====== Installing xdebug ======"

    sed -i '/xdebug.so/d' ${dst_root}/php/etc/php.ini
    cd ${shell_dir}/software
    Get_PHP_Ext_Dir
    zend_ext=${zend_ext_dir}${PHP_ZTS}
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi


    echo "Install xdebug..."

    cd ${shell_dir}/software
    Download_Files ${Xdebug_Mirror} ${Xdebug_Ver}.tgz
    Tar_Cd ${Xdebug_Ver}.tgz ${Xdebug_Ver}
    ${dst_root}/php/bin/phpize
    ./configure --enable-xdebug --with-php-config=${dst_root}/php/bin/php-config
    make && make install
    cd ../

sed -i '/the dl()/i\
zend_extension = "xdebug.so"' ${dst_root}/php/etc/php.ini

    if [ -s ${zend_ext} ]; then
        echo "====== Xdebug install completed ======"
        echo "Xdebug installed successfully, enjoy it!"
    else
        sed -i '/${PHP_ZTS}/d' ${dst_root}/php/etc/php.ini
        echo "Xdebug install failed!"
    fi
}

Uninstall_Xdebug()
{
    echo "You will uninstall Xdebug..."
    Press_Start
    sed -i '/memcache.so/d' ${dst_root}php/etc/php.ini
    sed -i '/xdebug.so/d' ${dst_root}php/etc/php.ini
    Restart_PHP
    Remove_StartUp xdebug
    echo "Delete Xdebug files..."
    rm -rf ${dst_root}libxdebug
    rm -rf ${dst_root}xdebug
    rm -rf /etc/init.d/xdebug
    rm -rf /usr/bin/xdebug
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
    echo "Uninstall Xdebug completed."
}
#Install_Autoconf
Export_PHP_Autoconf
Install_Xdebug
