. ./install.sh
clear


function install_nginx()
{
echo "============================Install Nginx================================="

grep '^nginx' /etc/passwd || /usr/sbin/useradd -s /sbin/nologin --groups=web nginx 

# 配置文件目录
# 缓存文件
ls ${dst_root}/nginx/tmp || mkdir -p ${dst_root}/nginx/tmp
# pid
ls ${dst_root}/nginx/run || mkdir -p ${dst_root}/nginx/run
ls ${dst_root}/nginx/logs || mkdir -p ${dst_root}/nginx/logs
ls ${dst_root}/htdocs || mkdir -p ${dst_root}/htdocs

cd ${shell_dir}/software

Download_Files ${Nginx_Mirror} ${Nginx_Ver}.tar.gz
Tar_Cd ${Nginx_Ver}.tar.gz ${Nginx_Ver}

./configure --user=nginx --group=web --prefix=${dst_root}/nginx --conf-path=${dst_root}/nginx/etc/nginx.conf --with-pcre=${shell_dir}/software/pcre-8.37 --error-log-path=${dst_root}/nginx/logs/error.log --with-http_stub_status_module --with-http_ssl_module --with-http_spdy_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_random_index_module --with-http_secure_link_module

# mkdir -p ${dst_htdocs}/nginx && sed -i "/html/ s#/Maov'#/Maov/htdocs/nginx'#" objs/Makefile

make && make install
cd ../

# rm -f ${dst_root}/nginx/nginx.conf
cd $conf_dir
cp nginx/nginx.conf ${dst_root}/nginx/etc/nginx.conf
#ls ${dst_root}/nginx/etc/common/ || mkdir ${dst_root}/nginx/etc/common/
cp nginx/error.conf ${dst_root}/nginx/etc/error.conf

ls ${dst_root}/nginx/etc/vhost || mkdir -p ${dst_root}/nginx/etc/vhost
cp nginx/vhost_www.test.cc.conf ${dst_root}/nginx/etc/vhost/

chown -R nginx:web ${dst_root}/nginx/etc/vhost
chown -R nginx:web ${dst_root}/nginx/logs
chmod 755 ${dst_root}/nginx/etc/vhost
chmod 755 ${dst_root}/nginx/logs
chmod 755 ${dst_root}/htdocs

ln -sf ${dst_root}/nginx/sbin/nginx /usr/sbin/nginx

#startup
rc_nginx_local=$(grep "${dst_root}/sbin/nginx" /etc/rc.d/rc.local)
if [ "$rc_nginx_local" == "" ]; then
    sed -i "\$a ${dst_root}/sbin/nginx" /etc/rc.d/rc.local
fi
#iptables port 80 rules
if [ -s /sbin/iptables ]; then
    /sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
#    if [ -s /usr/sbin/firewalld ]; then
    service iptables save
    systemctl restart iptables
#    else
#        /etc/rc.d/init.d/iptables save
#        /etc/rc.d/init.d/iptables restart
#    fi
fi
}

install_nginx 2>&1 | tee /root/as-nginx-install.log
