#
# Cookbook Name:: sensu-config
# Recipe:: default
#
# Copyright 2013, dn365
# v0.1
# All rights reserved - Do Not Redistribute
#

#Add Graphite web url to hosts

hosts_file = "/etc/hosts"
if node.platform.eql?("windows")
  hosts_file = "C:/Windows/System32/drivers/etc/hosts"
end

content = File.read(hosts_file)

unless content.include?("#{node["graphite"]["url"]}")
  hosts_stat = File.open(hosts_file,"w")
  hosts_stat.puts(content)
  hosts_stat.puts("#{node["graphite"]["ser_ip"]} #{node["graphite"]["url"]}")
  hosts_stat.close
else
  a_array = []
  content.each_line do |i|
    if i.include?(node["graphite"]["url"])
      name = i.split(" ")[-1]
      new_string = "#{node["graphite"]["ser_ip"]} #{name}"
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

unless node.platform.include?("windows")
  
  gem_package "sensu" do
    version "0.9.7"
    action :remove
  end
  
  gem_package "sensu-client" do
    options "--no-ri --no-rdoc"
    version "0.9.13"
    action :install
  end

  gem_package "sensu-plugin" do
    options "--no-ri --no-rdoc"
    #version ""
    action :install
  end
  #gem_package "sigar" do
  #  options "--no-ri --no-rdoc"
    #version ""
  #  action :install
  #end
end


include_recipe "sensu::client"