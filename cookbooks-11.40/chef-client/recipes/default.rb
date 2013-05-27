#
# Cookbook Name:: chef-client
# Recipe:: default
#
# Copyright 2013, dn365
# version 11.40
# All rights reserved - Do Not Redistribute
#

#Add chef server ip to hosts
hosts_file = "/etc/hosts"
if node.platform.eql?("windows")
  hosts_file = "C:/Windows/System32/drivers/etc/hosts"
end

content = File.read(hosts_file)

unless content.include?("#{node["chef"]["server"]["hostname"]}")
  hosts_stat = File.open(hosts_file,"w")
  hosts_stat.puts(content)
  hosts_stat.puts("#{node["chef"]["server"]["ip"]} #{node["chef"]["server"]["hostname"]}")
  hosts_stat.close
else
  a_array = []
  content.each_line do |i|
    if i.include?(node["chef"]["server"]["hostname"])
      name = i.split(" ")[-1]
      new_string = "#{node["chef"]["server"]["ip"]} #{name}"
      a_array << new_string
    else
      a_array << i
    end
  end
  hosts_stat = File.open(hosts_file,"w")
  a_array.each do |cc|
    hosts_stat.puts(cc)
  end
  hosts_stat.close
end




# upgrading chef version
gem_package "chef" do
  action :install
  options "--no-ri --no-rdoc"
  version "11.4.0"
end

include_recipe "chef-client::config"
case node.platform
when "windows"
  include_recipe "chef-client::win_services"
else
  include_recipe "chef-client::cron"
end

include_recipe "chef-client::delete_validation"
