. install.sh


function install_nginx()
{
echo "============================Install Nginx================================="

grep '^nginx' /etc/passwd || /usr/sbin/useradd -s /sbin/nologin --groups=web nginx 

# 配置文件目录
mkdir ${dst_etc}/nginx
# 缓存文件
mkdir ${dst_tmp}/nginx
# pid
mkdir ${dst_run}/nginx
mkdir ${dst_log}/nginx

Tar_Cd ${Nginx_Mirror} ${Nginx_Ver}

./configure --user=nginx --group=web --prefix=${dst_root} --conf-path=${dst_etc}/nginx/nginx.conf --with-pcre=${soft_dir}/pcre-8.12 --error-log-path=${dst_logs}/nginx/error.log --with-http_stub_status_module --with-http_ssl_module --with-http_spdy_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_random_index_module --with-http_secure_link_module

# mkdir -p ${dst_htdocs}/nginx && sed -i "/html/ s#/Maov'#/Maov/htdocs/nginx'#" objs/Makefile

make && make install
cd ../

# rm -f ${dst_etc}/nginx/nginx.conf
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
rc_nginx_local=$(grep "${dst_root}/sbin/nginx" /etc/rc.d/rc.local)
if [ "$rc_nginx_local" == "" ]; then
    sed -i "\$a ${dst_root}/sbin/nginx" /etc/rc.d/rc.local
fi
#iptables port 80 rules
if [ -s /sbin/iptables ]; then
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
/etc/rc.d/init.d/iptables save
/etc/rc.d/init.d/iptables restart
fi

}
