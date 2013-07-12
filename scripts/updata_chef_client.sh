SERVER_NAME="dntmon"
SERVER_IP="10.168.5.32"

echo "add server ip to /etc/hosts"
echo $SERVER_IP $SERVER_NAME >> /etc/hosts
echo $SERVER_IP gemserver >> /etc/hosts

OS_TYPE=`uname`
if [ $OS_TYPE = "AIX" ]; then
  ruby_bin="/opt/freeware/ruby1.9/bin"
elif [ $OS_TYPE = "HP-UX" ]; then
  ruby_bin="/usr/local/ruby1.9/bin"
else
  ruby_bin="/usr/bin"
fi
#echo $ruby_bin/gem
echo "add gem sources "
$ruby_bin/gem sources -r http://chefserver-ubuntu:9292
$ruby_bin/gem sources -a http://gemserver

echo "update chef client ..."

$ruby_bin/chef-client -S https://$SERVER_NAME -o role[default_client]