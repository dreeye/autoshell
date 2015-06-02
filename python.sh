# choose your username by vim

#include init
. ./init.sh
#exce init function in init.sh
init
clear

grep '^python' /etc/passwd || /usr/sbin/useradd --groups=web python

function install_python3()
{

echo "============================ Install Python 3.4.3 ================================"

if [ -e "$dst_root/bin/python3.4" ]; then
    echo "python3.4 exits!!"
    exit 0
fi

cd $soft_dir

if [ -s "$soft_dir/Python-3.4.3.tgz" ]; then
    echo 'Python-3.4.3.tgz [found]'
else
    echo 'Downloading Python-3.4.3.tgz'
    wget -c 'https://www.python.org/ftp/python/3.4.3/Python-3.4.3.tgz' 
fi

tar zxf Python-3.4.3.tgz
cd Python-3.4.3
./configure --prefix=$dst_root
make && make install

cd $soft_dir

# upgrade pip
pip3.4 install --upgrade pip | tee /root/as-pip.log
# install PyMysql
pip3.4 install PyMySQL | tee /root/as-pymysql.log
pip3.4 install pymongo | tee /root/as-pymongo.log
# install requests
pip3.4 install requests | tee /root/as-requests.log
# install beautiful soup 4
pip3.4 install beautifulsoup4 | tee /root/as-beautifulsoup4.log
# install lxml
pip3.4 install lxml | tee /root/as-lxml.log
# install tornado
pip3.4 install tornado | tee /root/as-tornado.log
pip3.4 install redis | tee /root/as-redis.log
pip3.4 install pep8 | tee /root/as-pep8.log
# install supervisor
# /usr/local/python3.4/bin/pip3.4 install  | tee /root/as-redis.log
}

install_python3 2>&1 | tee /root/as-python3.log
