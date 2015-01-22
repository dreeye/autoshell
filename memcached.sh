#include init
. ./init.sh
#exce init function in init.sh
init
clear

#memcached server
echo "============================Install memcached================================"
cd $soft_dir
#memcached
if [ -s "$soft_dir/memcached-1.4.15.tar.gz" ]; then
    echo 'memcached-1.4.15.tar.gz[found]'
else
    echo 'Downloading memcached-1.4.15.tar.gz' 
    wget -c 'http://soft.vpser.net/web/memcached/memcached-1.4.15.tar.gz'
fi
#libevent
if [ -s "$soft_dir/libevent-2.0.21-stable.tar.gz" ]; then
    echo 'libevent-2.0.21-stable.tar.gz[found]'
else
    echo 'Downloading libevent-2.0.21-stable.tar.gz' 
    wget -c 'http://soft.vpser.net/lib/libevent/libevent-2.0.21-stable.tar.gz'
fi

tar zxf libevent-2.0.21-stable.tar.gz 
cd libevent-2.0.21-stable 
./configure --prefix=/usr/local/libevent/
make && make install
ln -s /usr/local/libevent/lib/libevent-2.0.so.5 /lib/libevent-2.0.so.5
cd ../

tar zxf memcached-1.4.15.tar.gz
cd memcached-1.4.15
./configure --prefix=/usr/local/memcached --with-libevent=/usr/local/libevent/
make && make install
cd ../
echo "============================memcached finished================================"
