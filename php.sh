#!/bin/bash
. ./install.sh
clear

Install_Composer()
{
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
}

Ln_PHP_Bin()
{
    ln -sf ${dst_root}/php/bin/php /usr/bin/php
    ln -sf ${dst_root}/php/bin/phpize /usr/bin/phpize
    ln -sf ${dst_root}/php/bin/pear /usr/bin/pear
    ln -sf ${dst_root}/php/bin/pecl /usr/bin/pecl
    ln -sf ${dst_root}/php/sbin/php-fpm /usr/bin/php-fpm
}
# 避免出现PECL: configuration option "php_ini" is not set to php.ini location 
Pear_Pecl_Set()
{
    pear config-set php_ini ${dst_root}/php/etc/php.ini
    pecl config-set php_ini ${dst_root}/php/etc/php.ini
}

Install_PHP_7()
{
    # 此变量在mirror.sh
    Echo_Blue "[+] Installing ${Php_Ver7}"
    grep '^php' /etc/passwd || /usr/sbin/useradd -s /sbin/nologin --groups=web php 

    # 赋值autoconf环境变量
    Export_PHP_Autoconf

    # 拷贝动态链接库
    cp -frp /usr/lib64/libldap* /usr/lib/

    Tar_Cd ${Php_Ver7}.tar.gz ${Php_Ver7}

        ./configure --prefix=${dst_root}/php --with-config-file-path=${dst_root}/php/etc --enable-fpm --with-fpm-user=php --with-fpm-group=web --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache --enable-exif --with-bz2  --enable-calendar --with-gmp --with-ldap --with-readline --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-wddx --with-xsl

    make ZEND_EXTRA_LIBS='-liconv'
    make install

    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p ${dst_root}/php/etc
    \cp php.ini-production ${dst_root}/php/etc/php.ini

    cd ${shell_dir}
    # php extensions 暂用默认
    #echo "Modify php.ini......"
    #sed -i 's/post_max_size = 8M/post_max_size = 50M/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/;date.timezone =/date.timezone = PRC/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/short_open_tag = Off/short_open_tag = On/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/max_execution_time = 30/max_execution_time = 300/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' ${dst_root}/php/etc/php.ini
    Pear_Pecl_Set

cat >>${dst_root}/php/etc/php.ini<<EOF

;eaccelerator

;ionCube

;opcache
[Zend Opcache]
zend_extension=opcache.so
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache end

;xcache
;xcache end
EOF


echo "Creating new php-fpm configure file..."
cat >${dst_root}/php/etc/php-fpm.conf<<EOF
[global]
pid = ${dst_root}/php/var/run/php-fpm.pid
error_log = ${dst_root}/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = php
listen.group = web
listen.mode = 0666
user = php 
group = web
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = ${dst_root}/php/var/log/slow.log
EOF

# echo "Copy php-fpm init.d file..."
# \cp ${cur_dir}/src/${Php_Ver}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
# chmod +x /etc/init.d/php-fpm
}

Install_PHP_56()
{
    # 此变量在mirror.sh
    Echo_Blue "[+] Installing ${Php_Ver}"
    grep '^php' /etc/passwd || /usr/sbin/useradd -s /sbin/nologin --groups=web php 

    # 赋值autoconf环境变量
    Export_PHP_Autoconf

    # 拷贝动态链接库
    cp -frp /usr/lib64/libldap* /usr/lib/

    Tar_Cd ${Php_Ver}.tar.gz ${Php_Ver}

        ./configure --prefix=${dst_root}/php --with-config-file-path=${dst_root}/php/etc --enable-fpm --with-fpm-user=php --with-fpm-group=web --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-opcache --enable-exif --with-bz2  --enable-calendar --with-gmp --with-ldap --with-readline --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-wddx --with-xsl

    make ZEND_EXTRA_LIBS='-liconv'
    make install

    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p ${dst_root}/php/etc
    \cp php.ini-production ${dst_root}/php/etc/php.ini

    cd ${shell_dir}
    # php extensions 暂用默认
    #echo "Modify php.ini......"
    #sed -i 's/post_max_size = 8M/post_max_size = 50M/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/;date.timezone =/date.timezone = PRC/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/short_open_tag = Off/short_open_tag = On/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/max_execution_time = 30/max_execution_time = 300/g' ${dst_root}/php/etc/php.ini
    #sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' ${dst_root}/php/etc/php.ini
    Pear_Pecl_Set

cat >>${dst_root}/php/etc/php.ini<<EOF

;eaccelerator

;ionCube

;opcache
[Zend Opcache]
zend_extension=opcache.so
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache end

;xcache
;xcache end
EOF


echo "Creating new php-fpm configure file..."
cat >${dst_root}/php/etc/php-fpm.conf<<EOF
[global]
pid = ${dst_root}/php/var/run/php-fpm.pid
error_log = ${dst_root}/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = php
listen.group = web
listen.mode = 0666
user = php 
group = web
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = ${dst_root}/php/var/log/slow.log
EOF

# echo "Copy php-fpm init.d file..."
# \cp ${cur_dir}/src/${Php_Ver}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
# chmod +x /etc/init.d/php-fpm
}

#Install_PHP_56
Install_PHP_7
