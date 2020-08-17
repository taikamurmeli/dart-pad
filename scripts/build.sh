scripts_dir=$(dirname $0)
cd ${scripts_dir}/..

image_name="$(cat $scripts_dir/image_name.txt)"

docker build -t $image_name $@ .
