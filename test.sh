#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

clear
echo "========================================================================="
echo "PNshell for CentOS6.6 Linux Server, Written by ProNoz"
echo "========================================================================="
#shell dir
shell_dir=$(pwd)
if [ ! -d "${shell_dir}/software" ]; then
    mkdir $shell_dir'/software'
fi
# software dir
soft_dir=$shell_dir'/software'
# conf dir
conf_dir=$shell_dir'/conf'

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
groupadd www
useradd -s /sbin/nologin -g www www
cd $soft_dir
tar zxf pcre-8.12.tar.gz
cd pcre-8.12/
./configure
make && make install
cd ../

ldconfig

tar zxf nginx-1.6.2.tar.gz
cd nginx-1.6.2/
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6 --with-pcre=${soft_dir}/pcre-8.12
make && make install
cd ../

ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
rm -f /usr/local/nginx/conf/nginx.conf
cd $conf_dir
cp nginx/nginx.conf /usr/local/nginx/conf/nginx.conf

#www项目目录创建
mkdir -p /usr/local/webserver/htdocs/pronoz
chmod +w /usr/local/webserver/htdocs/pronoz     
chown -R www:www /usr/local/webserver/htdocs/pronoz
#vhost
cd $conf_dir
mkdir  /usr/local/nginx/conf/vhost
cp nginx/vhost_www.pronoz.cc.conf /usr/local/nginx/conf/vhost/
chmod +w /usr/local/nginx/conf/vhost
chown -R www:www /usr/local/nginx/conf/vhost
#logs dir
chmod +w /usr/local/nginx/logs/      
chown -R www:www /usr/local/nginx/logs/
#startup
sed -i '$a /usr/local/nginx/sbin/nginx' /etc/rc.local
#iptables port 80 rules
if [ -s /sbin/iptables ]; then
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
/etc/rc.d/init.d/iptables save
/etc/rc.d/init.d/iptables restart
fi

}

function InstallVim74()
{
	echo "==========================="
    #指定vim的用户
	username="willis"
	echo "Please input the username for vim:"
	read -p "(Default User: willis):" username
	if [ "$username" = "" ]; then
		username="willis"
	fi
    #如果输入的用户不存在，则自动创建用户
	if [ ! -d "/home/$username" ]; then
        useradd $username
	fi
	echo "==========================="
	echo "New add user is :$username"
	echo "==========================="
    #用户根目录
    user_dir='/home/'$username

echo "============================Install VIM7.4=================================="
cd $soft_dir
tar jxf vim-7.4.tar.bz2
cd vim74
./configure --prefix=/usr/local/vim74 --enable-multibyte  --enable-fontset --with-features=huge
make && make install
ln -s /usr/local/vim74/bin/vim /bin/vim
ln -s /usr/local/vim74/bin/vim /usr/bin/vim
#修改desert模板
cp -f ${conf_dir}/vim/desert.vim /usr/local/vim74/share/vim/vim74/colors/desert.vim
#root和创建的用户都用同一个vimrc
cp ${conf_dir}/vim/.vimrc /root
cp ${conf_dir}/vim/.vimrc ${user_dir}/


echo "Install NERD_TREE For VIM7.4"
cd $soft_dir
unzip -q nerdtree.zip
#root的nerdtree插件目录
mkdir -p /root/.vim/plugin
mkdir -p /root/.vim/doc
cp -p plugin/NERD_tree.vim /root/.vim/plugin
cp -p doc/NERD_tree.txt /root/.vim/doc
#新建账号的nerdtree插件目录
mkdir -p ${user_dir}/.vim/plugin
mkdir -p ${user_dir}/.vim/doc
cp -p plugin/NERD_tree.vim ${user_dir}/.vim/plugin
cp -p doc/NERD_tree.txt ${user_dir}/.vim/doc
cd ${user_dir}/
#修改新建账号权限
chown $username:$username .vimrc
chown -R $username:$username .vim
echo "Install VIM7.4 Finished"

}

function init_install()
{
    #show CentOS版本
	cat /etc/issue
    #show Linux core
	uname -a
    #show memory
	MemTotal=`free -m | grep Mem | awk '{print  $2}'`  
	echo -e "\n Memory is: $MemTotal MB "
	#Set timezone
	rm -rf /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

	yum install -y ntp
	ntpdate -u pool.ntp.org
	date

	#Disable SeLinux
	if [ -s /etc/selinux/config ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	fi

	for packages in gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers zip unzip man perl-CPAN cmake bison wget mlocate git openssh-server openssh-clients;
	do yum -y install $packages; done
}

function check_download_software()
{
    clear
    cd $soft_dir
    #下载vim7.4
    if [ -s "$soft_dir/vim-7.4.tar.bz2" ]; then
        echo 'vim-7.4.tar.bz2[found]'
    else
        echo 'Downloading vim-7.4.tar.bz2'
        wget -c 'http://ftp.vim.org/vim/unix/vim-7.4.tar.bz2' 
    fi
    #download nerdtree
    if [ -s "$soft_dir/nerdtree.zip" ]; then
        echo 'nerdtree.zip[found]'
    else
        echo 'Downloading nerdtree.zip'
        wget -c 'http://www.vim.org/scripts/download_script.php?src_id=17123' -O nerdtree.zip
    fi
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
    

}

#excute
#init_install 2>&1 | tee /root/as-init-install.log
#check_download_software 2>&1 | tee /root/as-download-software.log
#InstallVim74 2>&1 | tee /root/as-vim-install.log
#install_mysql 2>&1 | tee /root/as-mysql-install.log
