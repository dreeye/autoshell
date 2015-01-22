#include init
. ./init.sh
#exce init function in init.sh
init

# choose your username by vim
username="willis"
echo "Please input the username for vim:"
read -p "(Default User: willis):" username


echo "==========================="
#指定vim的用户
if [ "$username" = "" ]; then
    username="willis"
fi
#如果输入的用户不存在，则自动创建用户
if [ ! -d "/home/$username" ]; then
    useradd $username
fi
echo "==========================="
echo "New add user is :$username"
echo "==========================="
#用户根目录
user_dir='/home/'$username

echo "============================Install VIM7.4=================================="

cd $soft_dir

#下载vim7.4
if [ -s "$soft_dir/vim-7.4.tar.bz2" ]; then
    echo 'vim-7.4.tar.bz2[found]'
else
    echo 'Downloading vim-7.4.tar.bz2'
    wget -c 'http://ftp.vim.org/vim/unix/vim-7.4.tar.bz2' 
fi
#download nerdtree
if [ -s "$soft_dir/nerdtree.zip" ]; then
    echo 'nerdtree.zip[found]'
else
    echo 'Downloading nerdtree.zip'
    wget -c 'http://www.vim.org/scripts/download_script.php?src_id=17123' -O nerdtree.zip
fi


tar jxf vim-7.4.tar.bz2
cd vim74
./configure --prefix=/usr/local/vim74 --enable-multibyte  --enable-fontset --with-features=huge
make && make install
ln -s /usr/local/vim74/bin/vim /bin/vim
ln -s /usr/local/vim74/bin/vim /usr/bin/vim
#修改desert模板
cp -f ${conf_dir}/vim/desert.vim /usr/local/vim74/share/vim/vim74/colors/desert.vim
#root和创建的用户都用同一个vimrc
cp ${conf_dir}/vim/.vimrc /root
cp ${conf_dir}/vim/.vimrc ${user_dir}/


echo "==============Install NERD_TREE For VIM7.4==========="
cd $soft_dir
unzip -q nerdtree.zip

#root的nerdtree插件目录
mkdir -p /root/.vim/plugin
mkdir -p /root/.vim/doc
cp -p plugin/NERD_tree.vim /root/.vim/plugin
cp -p doc/NERD_tree.txt /root/.vim/doc

#新建账号的nerdtree插件目录
mkdir -p ${user_dir}/.vim/plugin
mkdir -p ${user_dir}/.vim/doc
cp -p plugin/NERD_tree.vim ${user_dir}/.vim/plugin
cp -p doc/NERD_tree.txt ${user_dir}/.vim/doc
cd ${user_dir}/

#修改新建账号权限
chown $username:$username .vimrc
chown -R $username:$username .vim

echo "==============Install VIM7.4 Finished=============="
