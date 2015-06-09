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

echo "============================ Upgrade pip ================================"

# upgrade pip
pip3.4 install --upgrade pip | tee /root/as-pip.log

echo "============================ Upgrade pip finished ================================"

echo "============================ Install supervisor ================================"

# install supervisor
if [ -d "$soft_dir/supervisor" ]; then
    echo 'supervisor [found]'
else
    echo 'Downloading supervisor'
    git clone 'https://github.com/Supervisor/supervisor.git' 
fi

cd supervisor
python3 setup.py install --record /tmp/supervisor_install.log

if [ ! -d "${dst_etc}/supervisor" ]; then
    echo "mkdir etc/supervisor dir!!!"
    mkdir -p ${dst_etc}/supervisor
fi
# echo_supervisord_conf > ${dst_etc}/supervisor/supervisord.conf
cd $conf_dir/supervisor
cp -rf * ${dst_etc}/supervisor
chown -R python:python ${dst_etc}/supervisor


if [ ! -d "${dst_logs}/supervisor" ]; then
    echo "mkdir var/logs/supervisor dir!!!"
    mkdir -p ${dst_logs}/supervisor
fi
chown -R python:python ${dst_logs}/supervisor

echo "============================ Install supervisor finished ================================"

}

install_python3 2>&1 | tee /root/as-python3.log
