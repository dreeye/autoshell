#!/bin/bash
. ./install.sh
clear

Install_Yaf()
{
    echo "====== Installing Yaf ======"
    
    # 根据php版本确定php扩展的准确目录,以便确定是否安装成功
    Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}yaf.so"
    # 删除旧版yaf.so
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi
    sed -i '/yaf.so/d' ${dst_root}/php/etc/php.ini

    cd ${shell_dir}/software
    Download_Files ${Yaf_Mirror} ${Yaf_Ver}.tgz

    Tar_Cd ${Yaf_Ver}.tgz ${Yaf_Ver}
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
    Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}yaf.so"
    # 删除旧版yaf.so
    if [ -s "${zend_ext}" ]; then
        echo "Delete Yaf so..."
        rm -f "${zend_ext}"
    fi
    sed -i '/yaf.so/d' ${dst_root}/php/etc/php.ini
    #Restart_PHP
    echo "Uninstall Yaf completed."
}
Export_PHP_Autoconf
Install_Yaf
