#
# Cookbook Name:: chef-client
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#Add chef server ip to hosts
hosts_file = "/etc/hosts"
if node.platform.eql?("windows")
  hosts_file = "C:/Windows/System32/drivers/etc/hosts"
end

content = File.read(hosts_file)

unless content.include?("#{node["chef"]["server"]["ip"]} #{node["chef"]["server"]["hostname"]}")
  hosts_stat = File.open(hosts_file,"w")
  hosts_stat.puts(content)
  hosts_stat.puts("#{node["chef"]["server"]["ip"]} #{node["chef"]["server"]["hostname"]}")
  hosts_stat.close
end

include_recipe "chef-client::config"
case node.platform
when "windows"
  include_recipe "chef-client::win_services"
else
  include_recipe "chef-client::cron"
end

include_recipe "chef-client::delete_validation"
