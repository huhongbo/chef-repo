# sensu version 0.9.12 client

#
# Cookbook Name:: sensu-config
# sensu server config
#
# Copyright 2013, dn365
#
# All rights reserved - Do Not Redistribute
#

#add graphite web url to hosts
hosts_file = File.open("/etc/hosts").read
unless hosts_file.include?("#{node["graphite"]["url"]}")
  hosts_stat = File.open("/etc/hosts","w")
  hosts_stat.puts(hosts_file)
  hosts_stat.puts("#{node["graphite"]["ser_ip"]} #{node["graphite"]["url"]}")
  hosts_stat.close
end

include_recipe "sensu::_config_dir"

include_recipe "sensu::client"