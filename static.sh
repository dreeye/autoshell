#come into dir:static and install modules
# cd ./static
# npm install
static_dir="/Maov/htdocs/www.maov.cc/static"
echo "Please input the path for static:"
read -p "(Default static path: ${static_dir}):" static_dir
if [ "$static_dir" = "" ]; then
    static_dir="/Maov/htdocs/www.maov.cc/static"
fi

if [ ! -d "${static_dir}"]; then
    mkdir -p ${static_dir}
fi

cd $static_dir
npm install
