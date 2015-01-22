#include init
. ./init.sh
#exce init function in init.sh
init
clear
echo "========================================================================="
echo "install ngrep command"
echo "========================================================================="

cd $soft_dir

if [ -s "$soft_dir/ngrep-1.45.tar.bz2" ]; then
    echo 'ngrep-1.45.tar.bz2[found]'
else
    echo 'Downloading ngrep-1.45.tar.bz2' 
    wget -c 'http://colocrossing.dl.sourceforge.net/project/ngrep/ngrep/1.45/ngrep-1.45.tar.bz2'
fi

tar jxf ngrep-1.45.tar.bz2
cd ngrep-1.45
sudo ./configure --with-pcap-includes=/usr/include/pcap
make && make install



