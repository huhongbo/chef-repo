#!/bin/sh

#v 0.01 install chef client shell
# code dn365
gem_local_sources_url="http://pc-monsvc:9292"
#gem_local_sources_url="http://pc-mon02:9292"
chef_server_url="http://pc-monsvc:4000"
validation_key_path="/etc/chef/validation.pem"
host="pc-monsvc"
ipadd="10.70.181.217"

system=unknown
if [ -f /etc/redhat-release ]; then
    system=redhat
elif [ -f /etc/debian_version ]; then
    system=debian
elif [ -f /etc/SuSE-release ]; then
    system=suse
elif [ -f /etc/gentoo-release ]; then
    system=gentoo
elif [ -f /etc/arch-release ]; then
     system=arch
elif [ -f /etc/slackware-version ]; then
    system=slackware
elif [ -f /etc/lfs-release ]; then
    system=lfs
elif [ `echo | uname` = "HP-UX" ]; then
	system=hpux
	export PATH=/usr/local/ruby1.9/bin:$PATH
elif [ `echo | uname` = "AIX" ]; then
	system=aix
	export PATH=/opt/freeware/ruby1.9/bin:$PATH
fi

platform_type=unknown
if [ "$system" = "aix" ]; then	
	export PATH=/opt/freeware/ruby1.9/bin:$PATH
	if [ -n `oslevel -r|grep '5300'` ]; then
		platform_type="powerpc-aix-5"
	elif [ -n `oslevel -r|grep '6100'` ]; then
		platform_type="powerpc-aix-6"
	fi
elif [ "$system" = "hpux" ]; then
	export PATH=/usr/local/ruby1.9/bin:$PATH
	if [ -n $(uname -r|grep '11.31') ] && [ -n $(uname -m|grep 'ia64') ]; then
		platform_type="ia64-hpux-11"
	elif [ -n `uname -r|grep '11.11'` ] && [ -n `uname -m|grep '9000/800'` ]; then
		platform_type="hppa2.0w-hpux-11"
	fi
fi

if [ -x `which gem` ]; then
	gem_path=`which gem`
else
	echo "Not found executable file: ruby gem, Please check your ruby environmental in system"
	exit 0
fi
cat /etc/hosts | grep $host >/dev/null 2>&1
if [ $? -ne 0 ];then
	echo "add host info to /etc/hosts"
	echo "$ipadd\t$host" >> /etc/hosts
fi
"$gem_path" sources | grep "$gem_local_sources_url" > /dev/null 2>&1
if [ $? -ne 0 ];then
	echo "change ruby gem sources url ..."
	$gem_path sources -r http://rubygems.org/
	$gem_path sources -a $gem_local_sources_url
fi

sleep 2

echo "gem install chef ...."

if [ "$platform_type" = unknown ]; then
	echo "install chef not platform ..."
	$gem_path install chef --no-ri --no-rdoc
	$gem_path install sigar --no-ri --no-rdoc
else
	echo "install chef and platform ..."
	$gem_path install chef --no-ri --no-rdoc --version "10.14.2" --platform $platform_type
	$gem_path install sigar --no-ri --no-rdoc --platform $platform_type
fi

sleep 2
if [ -x `which chef-client` ]; then
	chef_client_bin=`which chef-client`
else
	echo "Not found executable file: chef-client, Please check your chef environmental "
	exit 0
fi
chef_version=`$chef_client_bin -v`
echo "Chef version: $chef_version"

sleep 3

###########-----------##################

echo "Registered clients to chef server ."

chef_conf_path="/etc/chef"
knife_conf_path="/root/.chef"
node_name=`hostname`

if [ "$system" = "aix" -o "$system" = "hpux" ]; then
	knife_conf_path="/.chef"
fi

if [ ! -d $chef_conf_path ]; then
	echo " mkdir $chef_conf_path ..."
	mkdir -p $chef_conf_path
	cp validation.pem $chef_conf_path
else
	echo "Directory $chef_conf_path and $knife_conf_path existed ."
fi
if [ ! -d $knife_conf_path ]; then
	echo " mkdir  $knife_conf_path ..."
	mkdir -p $knife_conf_path
else
	echo "Directory $chef_conf_path and $knife_conf_path existed ."
fi

if [ -f $validation_key_path ]; then
	echo "run chef client and Registered client ..."
	$chef_client_bin -S $chef_server_url
else
	echo "Not found the chef server key: $validation_key_path, Please add this file ."
	exit 0
fi

if [ -f "$chef_conf_path/client.pem" ]; then
	echo "run knife and generate a knife.rb configuration file ..."
	knife_conf="log_level :info\n log_location STDOUT\nnode_name '$node_name'\nclient_key '$chef_conf_path/client.pem'\nvalidation_client_name 'chef-validator'\nvalidation_key '$validation_key_path'\nchef_server_url '$chef_server_url'\ncache_type 'BasicFile'\ncache_options(:path => '$knife_conf_path/checksums')\n"
	echo $knife_conf > $knife_conf_path/knife.rb
else
	echo "Not found $chef_conf_path/client.pem, Pleach run chef clinet or check your chef environmental ."
	exit 0
fi

if [ -x `which knife` ]; then
	echo "add knife roles ..."
	knife_bin=`which knife`
	$knife_bin node run_list add $node_name "role[chef-client],role[sensu-client]"
	sleep 2
	echo "Run chef client again and Deploy the default configuration ..."
	$chef_client_bin -S $chef_server_url
else
	echo "Not found executable file: chef knife, Please check your chef environmental ."
	exit 0
fi
sleep 3

echo "-----end-------"
echo "chef client run success ."