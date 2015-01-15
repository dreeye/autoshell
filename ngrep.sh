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
if [ ! -d "conf" ]; then
    echo 'please cd PNshell dir'
    exit 0
fi
if [ ! -d "${shell_dir}/software" ]; then
    mkdir $shell_dir'/software'
fi
# software dir
soft_dir=$shell_dir'/software'
# conf dir
conf_dir=$shell_dir'/conf'

cd $soft_dir

if [ -s "$soft_dir/ngrep-1.45.tar.bz2" ]; then
    echo 'ngrep-1.45.tar.bz2[found]'
else
    echo 'Downloading ngrep-1.45.tar.bz2' 
    wget -c 'http://colocrossing.dl.sourceforge.net/project/ngrep/ngrep/1.45/ngrep-1.45.tar.bz2'
fi
	for packages in gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel libxslt-devel libffi-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers zip unzip man perl-CPAN cmake bison wget mlocate git openssh-server openssh-clients patch make gcc-g77 flex file libtool libtool-libs kernel-devel libpng10 libpng10-devel gd gd-devel fonts-chinese gettext gettext-devel gmp-devel pspell-devel libcap diffutils libpcap-devel;
	do yum -y install $packages; done

tar jxf ngrep-1.45.tar.bz2
cd ngrep-1.45
sudo ./configure --with-pcap-includes=/usr/include/pcap
make && make install



