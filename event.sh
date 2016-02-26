#!/bin/bash
. ./install.sh
clear

Install_Libevent()
{
    echo "====== Installing Libevent ======"
    
    # 根据php版本确定php扩展的准确目录,以便确定是否安装成功
    Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}libevent.so"
    # 删除旧版libevent.so
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi
    sed -i '/libevent.so/d' ${dst_root}/php/etc/php.ini

    cd ${shell_dir}/software
    Download_Files ${Libevent_Mirror} ${Libevent_Ver}.tgz

    Tar_Cd ${Libevent_Ver}.tgz ${Libevent_Ver}
    ${dst_root}/php/bin/phpize
    ./configure --with-php-config=${dst_root}/php/bin/php-config
    make && make install
    cd ../


    sed -i '/the dl()/i\
    extension = "libevent.so"' ${dst_root}/php/etc/php.ini

    if [ -s "${zend_ext}" ]; then
        #Restart_PHP
        echo "====== Libevent install completed ======"
        echo "Libevent installed successfully, enjoy it!"
    else
        sed -i '/libevent.so/d' ${dst_root}/php/etc/php.ini
        echo "libevent install failed!"
    fi
}

Uninstall_Libevent()
{
    echo "You will uninstall Libevent..."
    #Press_Start
    Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}libevent.so"
    # 删除旧版libevent.so
    if [ -s "${zend_ext}" ]; then
        echo "Delete Libevent so..."
        rm -f "${zend_ext}"
    fi
    sed -i '/libevent.so/d' ${dst_root}/php/etc/php.ini
    #Restart_PHP
    echo "Uninstall Libevent completed."
}
Export_PHP_Autoconf
Install_Libevent
