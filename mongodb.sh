#include init
. ./init.sh
#exce init function in init.sh
init
clear

echo "============================Install mongodb================================"
cd $soft_dir

if [ -s "$soft_dir/mongodb-linux-x86_64-3.0.0" ]; then
    echo 'mongodb-linux-x86_64-3.0.0[found]'
else
    echo 'Downloading mongodb-linux-x86_64-3.0.0' 
    wget -c 'https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.0.tgz'
fi

if [ -d "/data/mongo_data" ]; then
    echo "mongo_data dir exits!!"
    exit 0
fi


tar zxf mongodb-linux-x86_64-3.0.0.tgz
mv mongodb-linux-x86_64-3.0.0 /usr/local/mongodb
mkdir /data/mongo_data
#/usr/local/mongodb/bin/mongod --fork --dbpath /data/mongo_data --logpath /var/log/mongodb.log 
cd ../
echo "============================mongodb finished================================"
