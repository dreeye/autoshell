Check_Download()
{
    Echo_Blue "[+] Downloading files..."
    cd ${shell_dir}/software
    Download_Files ${Pcre_Mirror} ${Pcre_Ver}
    Download_Files ${Libiconv_Mirror} ${Libiconv_Ver}
    Download_Files ${LibMcrypt_Mirror} ${LibMcrypt_Ver}
    Download_Files ${Mcypt_Mirror} ${Mcypt_Ver}
    Download_Files ${Php_Mirror} ${Php_Ver}
    Download_Files ${Autoconf_Mirror} ${Autoconf_Ver}
    Download_Files ${Mash_Mirror} ${Mash_Ver}
    Download_Files ${Libmemcached_Mirror} ${Libmemcached_Ver}
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
