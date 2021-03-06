#include init
. ./init.sh
#exce init function in init.sh
init
clear

echo "============================ Install mongodb ================================"

grep '^mongo' /etc/passwd || /usr/sbin/useradd --groups=web mongodb

cd $soft_dir

if [ -s "mongodb-linux-x86_64-3.0.0.tgz" ]; then
    echo 'mongodb-linux-x86_64-3.0.0[found]'
else
    echo 'Downloading mongodb-linux-x86_64-3.0.0' 
    wget -c 'https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.0.tgz'
fi

if [ ! -d "/data/mongo_data" ]; then
    echo "mkdir mongo_data dir!!!"
    mkdir -p /data/mongo_data
fi


tar zxf mongodb-linux-x86_64-3.0.0.tgz
cp -av mongodb-linux-x86_64-3.0.0/* $dst_root
if [ ! -d "${dst_etc}/mongodb" ]; then
    echo "mkdir etc/mongodb dir!!!"
    mkdir -p ${dst_etc}/mongodb
fi


if [ ! -d "${dst_logs}/mongodb" ]; then
    echo "mkdir var/logs/mongodb dir!!!"
    mkdir -p ${dst_logs}/mongodb
fi


echo "cp bin/mongodbctl shell!!!"
cd $conf_dir
cp mongodb/mongodbctl ${dst_root}/bin/

chown -R mongodb:mongodb ${dst_etc}/mongodb
chown -R mongodb:mongodb /data/mongo_data
chown -R mongodb:mongodb ${dst_logs}/mongodb
chown -R mongodb:mongodb ${dst_root}/bin/mongodbctl
chmod 755 ${dst_root}/bin/mongodbctl

cd $dst_root
rm -f THIRD-PARTY-NOTICES
rm -f README
rm -f GNU-AGPL-3.0

cd ../
echo "============================ mongodb finished ================================"
