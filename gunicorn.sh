#include init
. ./init.sh
#exce init function in init.sh
init
clear

grep '^python' /etc/passwd || /usr/sbin/useradd --groups=web python

function install_gunicorn()
{


echo "============================ Install gunicorn ================================"

if [ ! -d "${dst_etc}/gunicorn" ]; then
    echo "mkdir etc/gunicorn dir!!!"
    mkdir -p ${dst_etc}/gunicorn
fi

if [ ! -d "${dst_logs}/gunicorn" ]; then
    echo "mkdir var/logs/gunicorn dir!!!"
    mkdir -p ${dst_logs}/gunicorn
fi

if [ ! -d "${dst_run}/gunicorn" ]; then
    echo "mkdir var/run/gunicorn dir!!!"
    mkdir -p ${dst_run}/gunicorn
fi

pip3 install --upgrade gunicorn

cd $conf_dir/gunicorn
cp s.maov.cc.ini  ${dst_etc}/gunicorn
cp gunicornctl ${dst_root}/bin/
chown -R python:python ${dst_etc}/gunicorn
chown -R python:python ${dst_logs}/gunicorn
chown -R python:python ${dst_run}/gunicorn
chown -R python:python ${dst_root}/bin/gunicornctl
chmod 755 ${dst_root}/bin/gunicornctl

echo "============================ Install gunicorn finished ================================"

}

install_gunicorn 2>&1 | tee /root/as-gunicorn.log
