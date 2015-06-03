# choose your username by vim

#include init
. ./init.sh
#exce init function in init.sh
init
clear

echo "============================ Install nodejs ================================"

grep '^nodejs' /etc/passwd || /usr/sbin/useradd --groups=web nodejs

cd $soft_dir

if [ -s "$soft_dir/node-v0.12.4.tar.gz" ]; then
    echo 'node-v0.12.4.tar.gz[found]'
else
    echo 'Downloading node-v0.12.4.tar.gz' 
    wget -c 'http://nodejs.org/dist/v0.12.4/node-v0.12.4.tar.gz'
fi

tar -xvzf ./node-v0.12.4.tar.gz
cd ./node-v0.12.4
./config
make && make install
rm -rf ./node-v0.12.4.tar.gz
rm -rf ./node-v0.12.4

#install front-build modules. eg:grunt
sudo npm install grunt -g
sudo npm install bower -g

#come into dir:static and install modules
cd ./static
npm install

