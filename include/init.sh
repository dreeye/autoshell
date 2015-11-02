Check_Download()
{
    Echo_Blue "[+] Downloading files..."
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/lib/autoconf/${Autoconf_Ver}.tar.gz ${Autoconf_Ver}.tar.gz
    Download_Files ${Download_Mirror}/web/libiconv/${Libiconv_Ver}.tar.gz ${Libiconv_Ver}.tar.gz
    Download_Files ${Download_Mirror}/web/libmcrypt/${LibMcrypt_Ver}.tar.gz ${LibMcrypt_Ver}.tar.gz
    Download_Files ${Download_Mirror}/web/mcrypt/${Mcypt_Ver}.tar.gz ${Mcypt_Ver}.tar.gz
    Download_Files ${Download_Mirror}/web/mhash/${Mash_Ver}.tar.gz ${Mash_Ver}.tar.gz
    Download_Files ${Download_Mirror}/lib/freetype/${Freetype_Ver}.tar.gz ${Freetype_Ver}.tar.gz
    Download_Files ${Download_Mirror}/lib/curl/${Curl_Ver}.tar.gz ${Curl_Ver}.tar.gz
    Download_Files ${Download_Mirror}/web/pcre/${Pcre_Ver}.tar.gz ${Pcre_Ver}.tar.gz
    if [ "${SelectMalloc}" = "2" ]; then
        Download_Files ${Download_Mirror}/lib/jemalloc/${Jemalloc_Ver}.tar.bz2 ${Jemalloc_Ver}.tar.bz2
    elif [ "${SelectMalloc}" = "3" ]; then
        Download_Files ${Download_Mirror}/lib/tcmalloc/${TCMalloc_Ver}.tar.gz ${TCMalloc_Ver}.tar.gz
        Download_Files ${Download_Mirror}/lib/libunwind/${Libunwind_Ver}.tar.gz ${Libunwind_Ver}.tar.gz
    fi
    Download_Files ${Download_Mirror}/web/nginx/${Nginx_Ver}.tar.gz ${Nginx_Ver}.tar.gz
    Download_Files ${Download_Mirror}/datebase/mysql/${Mysql_Ver}.tar.gz ${Mysql_Ver}.tar.gz
    Download_Files ${Download_Mirror}/datebase/mariadb/${Mariadb_Ver}.tar.gz ${Mariadb_Ver}.tar.gz
    Download_Files ${Download_Mirror}/web/php/${Php_Ver}.tar.gz ${Php_Ver}.tar.gz
    if [ ${PHPSelect} = "1" ]; then
        Download_Files ${Download_Mirror}/web/phpfpm/${Php_Ver}-fpm-0.5.14.diff.gz ${Php_Ver}-fpm-0.5.14.diff.gz
    fi
    Download_Files ${Download_Mirror}/datebase/phpmyadmin/${PhpMyAdmin_Ver}.tar.gz ${PhpMyAdmin_Ver}.tar.gz
    Download_Files ${Download_Mirror}/prober/p.tar.gz p.tar.gz
    if [ "${Stack}" != "lnmp" ]; then
        Download_Files ${Download_Mirror}/web/apache/${Apache_Version}.tar.gz ${Apache_Version}.tar.gz
        Download_Files ${Download_Mirror}/web/apache/${APR_Ver}.tar.gz ${APR_Ver}.tar.gz
        Download_Files ${Download_Mirror}/web/apache/${APR_Util_Ver}.tar.gz ${APR_Util_Ver}.tar.gz
        Download_Files ${Download_Mirror}/web/apache/rpaf/${Mod_RPAF_Ver}.tar.gz ${Mod_RPAF_Ver}.tar.gz
    fi
}

Press_Install()
{
    echo ""
    echo "Press any key to install...or Press Ctrl+c to cancel"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
    . include/version.sh
}

Init_Shell()
{
    # create common.sh 
    if [ ! -s "/etc/profile.d/common.sh" ]; then
        touch '/etc/profile.d/common.sh'
    fi

    alias_color=$(grep 'alias grep='\''grep --color=auto'\''' /etc/profile.d/common.sh)

    if [ "$alias_color" == "" ]; then
        # sed -i '$a alias grep='\''grep --color=auto'\''' /etc/profile.d/common.sh
        echo 'alias grep='\''grep --color=auto'\''' >> /etc/profile.d/common.sh
    fi

    alias_utime=$(grep 'alias utime='\''sudo ntpdate -u pool.ntp.org'\''' /etc/profile.d/common.sh)

    if [ "$alias_utime" == "" ]; then
        # sed -i '$a alias utime='\''sudo ntpdate -u pool.ntp.org'\''' /etc/profile.d/common.sh
        echo 'alias utime='\''sudo ntpdate -u pool.ntp.org'\''' >> /etc/profile.d/common.sh
    fi

    goroot=$(grep "$GOROOT" /etc/profile.d/common.sh)

    if [ "$goroot" == "" ]; then
        # sed -i '$a export $GOROOT=$dst_root/go' /etc/profile.d/common.sh
        echo 'export $GOROOT=$dst_root/go' >> /etc/profile.d/common.sh
    fi

    root_path=$(grep "$dst_root/bin" /etc/profile.d/common.sh)

    if [ "$root_path" == "" ]; then
        # sed -i "\$a PATH=$dst_root/bin:$dst_root/sbin:~/bin:$GOROOT/bin:$PATH" /etc/profile.d/common.sh
        # sed -i "\$a export PATH" /etc/profile.d/common.sh
        echo "PATH=$dst_root/bin:$dst_root/sbin:~/bin:$GOROOT/bin:$PATH" >> /etc/profile.d/common.sh
        echo "export PATH" /etc/profile.d/common.sh
    fi

}
