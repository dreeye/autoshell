#include init
. ./init.sh
#exce init function in init.sh
init
clear
echo "========================================================================="
echo "Install LNMP"
echo "========================================================================="

#php ext memcached eaccelerator imMagick
function install_php_ext()
{
echo "============================Install php ext================================"
#memcached
cd $soft_dir

tar zxf libmemcached-1.0.18.tar.gz
cd libmemcached-1.0.18
./configure --prefix=/usr/local/libmemcached
make && make install
cd ../

tar zxf memcached-2.2.0.tgz
cd memcached-2.2.0
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-libmemcached-dir=/usr/local/libmemcached/
make && make install

cd ../
echo "Modify php.ini......"
echo "Add memcached.so"
sed -i '/; extension_dir = "ext"/a\extension = "memcached.so"' /usr/local/php/etc/php.ini
#eaccelerator
cd $soft_dir

tar jxf eaccelerator-0.9.6.1.tar.bz2
cd eaccelerator-0.9.6.1/ 
/usr/local/php/bin/phpize
./configure --enable-eaccelerator=shared  --with-php-config=/usr/local/php/bin/php-config
make && make install

cd ../
echo "mkdir eaccelerator_cache dir"
mkdir -p  /usr/local/eaccelerator_cache
cd $soft_dir
cat >ea.ini<<EOF
[eaccelerator]
zend_extension="/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/eaccelerator.so"
eaccelerator.shm_size="64"      
eaccelerator.cache_dir="/usr/local/eaccelerator_cache"
eaccelerator.enable="1"      
eaccelerator.optimizer="1"      
eaccelerator.check_mtime="1"      
eaccelerator.debug="0"      
eaccelerator.filter=""      
eaccelerator.shm_max="0"      
eaccelerator.shm_ttl="3600"      
eaccelerator.shm_prune_period="3600"      
eaccelerator.shm_only="0"      
eaccelerator.compress="1"      
eaccelerator.compress_level="9"
EOF

sed -i '$ r ea.ini' /usr/local/php/etc/php.ini

rm -f ea.ini

#imMagick
cd $soft_dir
tar zxf ImageMagick-6.5.1-2.tar.bz2
cd ImageMagick-6.5.1-2/ 
./configure --prefix=/usr/local/phplibs/ImageMagick
make && make install
cd ../

tar zxf imagick-2.3.0.tgz
cd imagick-2.3.0/
/usr/local/php/bin/phpize
export PKG_CONFIG_PATH = /usr/local/phplibs/ImageMagick/lib/pkgconfig/ 
./configure  --with-php-config=/usr/local/php/bin/php-config  --with-imagick=/usr/local/phplibs/ImageMagick/ 
make && make install
cd ../
echo "Modify php.ini......"
echo "Add imagick.so"
sed -i '/; extension_dir = "ext"/a\extension = "imagick.so"' /usr/local/php/etc/php.ini
echo "============================Install php ext finished================================"

}





function install_php()
{
echo "============================Install PHP 5.3.28================================"
cd $soft_dir
export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
tar zxf php-5.3.28.tar.gz
cd php-5.3.28/
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-magic-quotes --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --disable-fileinfo

make ZEND_EXTRA_LIBS='-liconv'
make install

rm -f /usr/bin/php
ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize
ln -s /usr/local/php/sbin/php-fpm /usr/bin/php-fpm

echo "Copy new php configure file."
mkdir -p /usr/local/php/etc
cp php.ini-production /usr/local/php/etc/php.ini

cd $soft_dir
# php extensions
echo "Modify php.ini......"
sed -i 's/post_max_size = 8M/post_max_size = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = PRC/g' /usr/local/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/; cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini
sed -i 's/register_long_arrays = On/;register_long_arrays = On/g' /usr/local/php/etc/php.ini
sed -i 's/magic_quotes_gpc = On/;magic_quotes_gpc = On/g' /usr/local/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini


echo "Creating new php-fpm configure file......"
cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice
emergency_restart_threshold = 10
emergency_restart_interval = 1m
process_control_timeout = 5s
daemonize = yes
rlimit_files = 1024
rlimit_core = 0

[www]
user = www
group = www
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
slowlog = var/log/slow.log
EOF

#echo "Copy php-fpm init.d file......"
#cp $soft_dir/php-5.3.28/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
#chmod +x /etc/init.d/php-fpm
#
#cp $soft_dir/lnmp /root/lnmp
#chmod +x /root/lnmp
#sed -i 's:/usr/local/php/logs:/usr/local/php/var/run:g' /root/lnmp
echo "============================PHP 5.3.28 install completed======================"
}

function install_depend()
{
echo "============================Install Depend================================="
cd $soft_dir
# init中会yum autoconf,试下不编译会怎样
#tar zxf autoconf-2.13.tar.gz
#cd autoconf-2.13/
#./configure --prefix=/usr/local/autoconf-2.13
#make && make install
#cd ../


tar zxf libiconv-1.14.tar.gz
cd libiconv-1.14/
./configure
make && make install
cd ../

cd $soft_dir
tar zxf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8/
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../

cd $soft_dir
tar zxf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9/
./configure
make && make install
cd ../

ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1

export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

cd $soft_dir
tar zxf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8/
./configure
make && make install
cd ../

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	ln -s /usr/lib64/libpng.* /usr/lib/
	ln -s /usr/lib64/libjpeg.* /usr/lib/
fi

ulimit -v unlimited

if [ ! `grep -l "/lib"    '/etc/ld.so.conf'` ]; then
	echo "/lib" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/lib'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib" >> /etc/ld.so.conf
fi

if [ -d "/usr/lib64" ] && [ ! `grep -l '/usr/lib64'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib64" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
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

echo "============================Install Depend complied================================="
}





function install_mysql()
{
echo "============================Install Mysql-5.6.12================================="
cd $soft_dir
groupadd mysql
useradd -s /sbin/nologin -M -g mysql mysql
tar zxf mysql-5.6.12.tar.gz
cd mysql-5.6.12/
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql/ -DEXTRA_CHARSETS=all -DWITH_READLINE=1 -DWITH_SSL=yes -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1
make && make install
cd ../

#database dir
mkdir -p /usr/local/mysql/3306/data/
mkdir -p /usr/local/mysql/3306/binlog/
mkdir -p /usr/local/mysql/3306/relaylog/

chmod +w /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql
cd /usr/local/mysql
#以mysql用户帐号的身份建立数据表
scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/usr/local/mysql/3306/data --user=mysql 
cd $conf_dir
#mysql conf 
cp mysql/my.cnf /usr/local/mysql/3306/my.cnf
#mysql control shell 
cp mysql/mysql /usr/local/mysql/3306/mysql
chmod +x /usr/local/mysql/3306/mysql
ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe
echo "============================Install Mysql-5.6.12 Finished================================="
}


function install_nginx()
{
echo "============================Install Nginx================================="
grep '^nginx' /etc/passwd || /usr/sbin/useradd -s /sbin/nologin --groups=web nginx 
grep '^git' /etc/passwd || /usr/sbin/useradd --groups=web git
cd $soft_dir
#download pcre
if [ -s "$soft_dir/pcre-8.12.tar.gz" ]; then
    echo 'pcre-8.12.tar.gz[found]'
else
    echo 'Downloading pcre-8.12.tar.gz'
    wget -c 'http://downloads.sourceforge.net/project/pcre/pcre/8.12/pcre-8.12.tar.gz'
fi
#download nginx
if [ -s "$soft_dir/nginx-1.6.2.tar.gz" ]; then
    echo 'nginx-1.6.2.tar.gz[found]'
else
    echo 'Downloading nginx-1.6.2.tar.gz'
    wget -c 'http://nginx.org/download/nginx-1.6.2.tar.gz'
fi
tar zxf pcre-8.12.tar.gz
cd pcre-8.12/
./configure
make && make install
cd ../

ldconfig

tar zxf nginx-1.6.2.tar.gz
cd nginx-1.6.2/
./configure --user=nginx --group=web --prefix=${dst_root} --conf-path=${dst_etc}/nginx/nginx.conf --with-pcre=${soft_dir}/pcre-8.12 --error-log-path=${dst_logs}/nginx/error.log --with-http_stub_status_module --with-http_ssl_module --with-http_spdy_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_random_index_module --with-http_secure_link_module

mkdir -p ${dst_htdocs}/nginx && sed -i "/html/ s#/Maov'#/Maov/htdocs/nginx'#" objs/Makefile

make && make install
cd ../

mkdir ${dst_tmp}/nginx
mkdir ${dst_run}/nginx
rm -f ${dst_etc}/nginx/nginx.conf
cd $conf_dir
cp nginx/nginx.conf ${dst_etc}/nginx/nginx.conf
mkdir ${dst_etc}/nginx/common/
cp nginx/error.conf ${dst_etc}/nginx/common/

#vhost
cd $conf_dir
mkdir  ${dst_etc}/nginx/vhost
cp nginx/vhost_www.maov.cc.conf ${dst_etc}/nginx/vhost/
chmod +w ${dst_etc}/nginx/vhost
chown -R nginx:web ${dst_etc}/nginx/vhost

chmod +w ${dst_logs} 
#startup
rc_nginx_local=$(grep "${dst_root}/sbin/nginx" /etc/rc.local)
if [ "$rc_nginx_local" == "" ]; then
    sed -i "\$a ${dst_root}/sbin/nginx" /etc/rc.local
fi
#iptables port 80 rules
if [ -s /sbin/iptables ]; then
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
/etc/rc.d/init.d/iptables save
/etc/rc.d/init.d/iptables restart
fi

}



function check_download_software()
{
    clear
    cd $soft_dir
    #download pcre
    if [ -s "$soft_dir/pcre-8.12.tar.gz" ]; then
        echo 'pcre-8.12.tar.gz[found]'
    else
        echo 'Downloading pcre-8.12.tar.gz'
        wget -c 'http://downloads.sourceforge.net/project/pcre/pcre/8.12/pcre-8.12.tar.gz'
    fi
    #download nginx
    if [ -s "$soft_dir/nginx-1.6.2.tar.gz" ]; then
        echo 'nginx-1.6.2.tar.gz[found]'
    else
        echo 'Downloading nginx-1.6.2.tar.gz'
        wget -c 'http://nginx.org/download/nginx-1.6.2.tar.gz'
    fi
    #download mysql5.6.12
    if [ -s "$soft_dir/mysql-5.6.12.tar.gz" ]; then
        echo 'mysql-5.6.12.tar.gz[found]'
    else
        echo 'Downloading mysql-5.6.12.tar.gz'
        wget -c 'http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.12.tar.gz'
    fi
    #autoconf
    if [ -s "$soft_dir/autoconf-2.13.tar.gz" ]; then
        echo 'autoconf-2.13.tar.gz[found]'
    else
        echo 'Downloading autoconf-2.13.tar.gz'
        wget -c 'http://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz'
    fi
    #libiconv
    if [ -s "$soft_dir/libiconv-1.14.tar.gz" ]; then
        echo 'libiconv-1.14.tar.gz[found]'
    else
        echo 'Downloading libiconv-1.14.tar.gz'
        wget -c 'http://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz'
    fi
    #mhash
    if [ -s "$soft_dir/mhash-0.9.9.9.tar.gz" ]; then
        echo 'mhash-0.9.9.9.tar.gz[found]'
    else
        echo 'Downloading mhash-0.9.9.9.tar.gz'
        wget -c 'http://downloads.sourceforge.net/mhash/mhash-0.9.9.9.tar.gz'
    fi
    #libmcrypt
    if [ -s "$soft_dir/libmcrypt-2.5.8.tar.gz" ]; then
        echo 'libmcrypt-2.5.8.tar.gz[found]'
    else
        echo 'Downloading libmcrypt-2.5.8.tar.gz'
        wget -c 'http://downloads.sourceforge.net/mcrypt/libmcrypt-2.5.8.tar.gz'
    fi
    #mcrypt
    if [ -s "$soft_dir/mcrypt-2.6.8.tar.gz" ]; then
        echo 'mcrypt-2.6.8.tar.gz[found]'
    else
        echo 'Downloading mcrypt-2.6.8.tar.gz'
        wget -c 'http://downloads.sourceforge.net/mcrypt/mcrypt-2.6.8.tar.gz'
    fi
    #php
    if [ -s "$soft_dir/php-5.3.28.tar.gz" ]; then
        echo 'php-5.3.28.tar.gz[found]'
    else
        echo 'Downloading php-5.3.28.tar.gz' 
        wget -c 'http://cn2.php.net/get/php-5.3.28.tar.gz/from/this/mirror' -O php-5.3.28.tar.gz
    fi
    #memcached php
    if [ -s "$soft_dir/libmemcached-1.0.18.tar.gz" ]; then
        echo 'libmemcached-1.0.18.tar.gz[found]'
    else
        echo 'Downloading libmemcached-1.0.18.tar.gz' 
        wget -c 'https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz'
    fi
    if [ -s "$soft_dir/memcached-2.2.0" ]; then
        echo 'memcached-2.2.0[found]'
    else
        echo 'Downloading memcached-2.2.0' 
        wget -c 'http://pecl.php.net/get/memcached-2.2.0.tgz'
    fi
    #eacc
    if [ -s "$soft_dir/eaccelerator-0.9.6.1.tar.bz2" ]; then
        echo 'eaccelerator-0.9.6.1.tar.bz2[found]'
    else
        echo 'Downloading eaccelerator-0.9.6.1.tar.bz2' 
        wget -c 'http://jaist.dl.sourceforge.net/project/eaccelerator/eaccelerator/eAccelerator%200.9.6.1/eaccelerator-0.9.6.1.tar.bz2'
    fi
    #imMagick
    if [ -s "$soft_dir/ImageMagick-6.5.1-2.tar.bz2" ]; then
        echo 'ImageMagick-6.5.1-2.tar.bz2[found]'
    else
        echo 'Downloading ImageMagick-6.5.1-2.tar.bz2' 
        wget -c 'http://blog.zyan.cc/soft/linux/nginx_php/imagick/ImageMagick.tar.gz' -O ImageMagick-6.5.1-2.tar.bz2
    fi
    #imagick-2.3.0.tgz 
    if [ -s "$soft_dir/imagick-2.3.0.tgz" ]; then
        echo 'imagick-2.3.0.tgz[found]'
    else
        echo 'Downloading imagick-2.3.0.tgz' 
        wget -c 'http://pecl.php.net/get/imagick-2.3.0.tgz'
    fi
    
#    if [ -s "$soft_dir/" ]; then
#        echo '[found]'
#    else
#        echo 'Downloading ' 
#        wget -c ''
#    fi
    

}

#excute
#check_download_software 2>&1 | tee /root/as-download-software.log
install_nginx 2>&1 | tee /root/as-nginx-install.log
#install_mysql 2>&1 | tee /root/as-mysql-install.log
#install_depend 2>&1 | tee /root/as-depend.log
#install_php 2>&1 | tee /root/as-php.log
#install_php_ext 2>&1 | tee /root/as-php-ext.log
