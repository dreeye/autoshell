#!/bin/bash
. ./install.sh
clear

Install_ImageMagic()
{
    echo "====== Installing ImageMagic ======"
    #Press_Install

    sed -i '/imagick.so/d' ${dst_root}/php/etc/php.ini
    Get_PHP_Ext_Dir
    zend_ext="${zend_ext_dir}imagick.so"
    if [ -s "${zend_ext}" ]; then
        rm -f "${zend_ext}"
    fi

    cd ${shell_dir}/software
    Download_Files ${ImageMagick_Mirror} ${ImageMagick_Ver}.tar.gz
    Download_Files ${Imagick_Mirror} ${Imagick_Ver}.tgz

    Tar_Cd ${ImageMagick_Ver}.tar.gz ${ImageMagick_Ver}
    ./configure --prefix=${dst_root}/imagemagick
    make && make install
    cd ../

    Tar_Cd ${Imagick_Ver}.tgz ${Imagick_Ver}
    ${dst_root}/php/bin/phpize
    ./configure --with-php-config=${dst_root}/php/bin/php-config --with-imagick=${dst_root}/imagemagick
    make && make install
    cd ../

    sed -i '/the dl()/i\
    extension = "imagick.so"' ${dst_root}/php/etc/php.ini

    if [ -s "${zend_ext}" ]; then
        Restart_PHP
        echo "====== ImageMagick install completed ======"
        echo "ImageMagick installed successfully, enjoy it!"
    else
        sed -i '/imagick.so/d' ${dst_root}/php/etc/php.ini
        echo "imagick install failed!"
    fi
}

Uninstall_ImageMagick()
{
    echo "You will uninstall ImageMagick..."
    Press_Start
    sed -i '/imagick.so/d' ${dst_root}/php/etc/php.ini
    echo "Delete ImageMagick directory..."
    rm -rf ${dst_root}/imagemagick
    Restart_PHP
    echo "Uninstall ImageMagick completed."
}
Export_PHP_Autoconf
Install_ImageMagic
