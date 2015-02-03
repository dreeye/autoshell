# choose your username by vim
version="3"
echo "Please input the version for python:"
read -p "(Default Version: 3):" version

if ["$version" == ""]; then
    version="3"
fi
#include init
. ./init.sh
#exce init function in init.sh
init
clear

#python2.7
function install_python7()
{

echo "============================Install python2.7.9================================"

if [ -d "/usr/local/python2.7" ]; then
    echo "python2.7 dir exits!!"
    exit 0
fi

cd $soft_dir
if [ -s "$soft_dir/Python-2.7.9.tgz" ]; then
    echo 'Python-2.7.9.tgz[found]'
else
    echo 'Downloading Python-2.7.9.tgz'
    wget -c 'https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz' 
fi
tar zxf Python-2.7.9.tgz
cd Python-2.7.9 
./configure --prefix=/usr/local/python2.7/
make && make install
cd $soft_dir
#downloading setup pip
if [ -s "$soft_dir/get-pip.py" ]; then
    echo 'get-pip.py[found]'
else
    echo 'Downloading get-pip.py'
    wget -c 'https://bootstrap.pypa.io/get-pip.py' 
fi
#install pip
/usr/local/python2.7/bin/python2.7 get-pip.py | tee /root/as-pip.log
#install lxml
/usr/local/python2.7/bin/pip2.7 install lxml | tee /root/as-lxml.log
#install Scrapy
/usr/local/python2.7/bin/pip2.7 install Scrapy | tee /root/as-scrapy.log
#install service_identity
/usr/local/python2.7/bin/pip2.7 install service_identity | tee /root/as-service_identity.log
#install mysql-python(指定mysql安装路径)
if [ -s "/usr/local/mysql/bin" ]; then
    export PATH=$PATH:/usr/local/mysql/bin
    /usr/local/python2.7/bin/pip2.7 install mysql-python | tee /root/as_mysql.log
    ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.18
else
    echo "==unstall mysql_python==="
fi
ln -s /usr/local/python2.7/bin/python2.7 /usr/bin/python7
echo "============================python2.7.9 finished================================"
}

function install_python3()
{

echo "============================Install python3.4.2================================"

if [ -d "/usr/local/python3.4" ]; then
    echo "python3.4 dir exits!!"
    exit 0
fi

cd $soft_dir

if [ -s "$soft_dir/Python-3.4.2.tgz" ]; then
    echo 'Python-3.4.2.tgz[found]'
else
    echo 'Downloading Python-3.4.2.tgz'
    wget -c 'https://www.python.org/ftp/python/3.4.2/Python-3.4.2.tgz' 
fi

tar zxf Python-3.4.2.tgz
cd Python-3.4.2
./configure --prefix=/usr/local/python3.4/
make && make install

cd $soft_dir

#downloading setup pip
if [ -s "$soft_dir/get-pip.py" ]; then
    echo 'get-pip.py[found]'
else
    echo 'Downloading get-pip.py'
    wget -c 'https://bootstrap.pypa.io/get-pip.py' 
fi
#install pip
/usr/local/python3.4/bin/python3.4 get-pip.py | tee /root/as-pip3.4.log
#install PyMysql
/usr/local/python3.4/bin/pip3.4 install PyMySQL | tee /root/as-pymysql.log
#install requests
/usr/local/python3.4/bin/pip3.4 install requests | tee /root/as-requests.log
#install beautiful soup 4
/usr/local/python3.4/bin/pip3.4 install beautifulsoup4 | tee /root/as-beautifulsoup4.log
#install douban-client
/usr/local/python3.4/bin/pip3.4 install douban-client | tee /root/as-douban-client.log
#install lxml
/usr/local/python3.4/bin/pip3.4 install lxml | tee /root/as-lxml.log
#install tornado
/usr/local/python3.4/bin/pip3.4 install tornado | tee /root/as-tornado.log
/usr/local/python3.4/bin/pip3.4 install torndb | tee /root/as-torndb.log

ln -s /usr/local/python3.4/bin/python3.4 /usr/bin/python3
}

if [ "$version" == "3" ]; then
    install_python3 2>&1 | tee /root/as-python7.log
else
    install_python7 2>&1 | tee /root/as-python7.log
fi
