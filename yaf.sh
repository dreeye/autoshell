#!/bin/bash
. ./install.sh
clear

Install_Yaf()
{
    echo "====== Installing Yaf ======"

    sed -i '/yaf.so/d' ${dst_root}/php/etc/php.ini
    Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}yaf.so"
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

    cd ${shell_dir}/software
    Download_Files ${Yaf_Mirror} ${Yaf_Ver}.tar.gz

    Tar_Cd ${Yaf_Ver}.tar.gz ${Yaf_Ver}
    ${dst_root}/php/bin/phpize
    ./configure --with-php-config=${dst_root}/php/bin/php-config
    make && make install
    cd ../


    sed -i '/the dl()/i\
    extension = "yaf.so"' ${dst_root}/php/etc/php.ini

    if [ -s "${zend_ext}" ]; then
        #Restart_PHP
        echo "====== Yaf install completed ======"
        echo "Yaf installed successfully, enjoy it!"
    else
        sed -i '/yaf.so/d' ${dst_root}/php/etc/php.ini
        echo "yaf install failed!"
    fi
}

Uninstall_Yaf()
{
    echo "You will uninstall Yaf..."
    #Press_Start
    sed -i '/yaf.so/d' ${dst_root}/php/etc/php.ini
    echo "Delete Yaf directory..."
    rm -rf ${dst_root}/yaf
    #Restart_PHP
    echo "Uninstall Yaf completed."
}
Export_PHP_Autoconf
Install_Yaf
