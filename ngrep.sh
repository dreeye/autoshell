. ./install.sh
clear
echo "========================================================================="
echo "install ngrep command"
echo "========================================================================="

cd ${shell_dir}/software

if [ -s "$soft_dir/ngrep-1.45.tar.bz2" ]; then
    echo 'ngrep-1.45.tar.bz2[found]'
else
    echo 'Downloading ngrep-1.45.tar.bz2' 
    wget -c 'http://prdownloads.sourceforge.net/ngrep/ngrep-1.45.tar.bz2'
fi

tar jxf ngrep-1.45.tar.bz2
cd ngrep-1.45
sudo ./configure --prefix=$dst_root --with-pcap-includes=/usr/include/pcap
make && make install

