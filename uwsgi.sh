#include init
. ./init.sh
#exce init function in init.sh
init
clear

grep '^python' /etc/passwd || /usr/sbin/useradd --groups=web python

function install_uwsgi()
{


echo "============================ Install uwsgi ================================"

if [ ! -d "${dst_etc}/uwsgi" ]; then
    echo "mkdir etc/uwsgi dir!!!"
    mkdir -p ${dst_etc}/uwsgi
fi

if [ ! -d "${dst_logs}/uwsgi" ]; then
    echo "mkdir var/logs/uwsgi dir!!!"
    mkdir -p ${dst_logs}/uwsgi
fi
chown -R python:python ${dst_logs}/uwsgi

if [ ! -d "${dst_run}/uwsgi" ]; then
    echo "mkdir var/run/uwsgi dir!!!"
    mkdir -p ${dst_run}/uwsgi
fi
chown -R python:python ${dst_run}/uwsgi

pip3 install --upgrade uwsgi

cd $conf_dir/uwsgi
cp s.maov.cc.ini  ${dst_etc}/uwsgi
cp uwsgictl ${dst_root}/bin/
chown -R python:python ${dst_etc}/uwsgi
chown -R python:python ${dst_logs}/uwsgi
chown -R python:python ${dst_root}/bin/uwsgictl
chmod 755 ${dst_root}/bin/uwsgictl

echo "============================ Install uwsgi finished ================================"

}

install_uwsgi 2>&1 | tee /root/as-uwsgi.log
