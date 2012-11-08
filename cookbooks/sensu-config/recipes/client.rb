# sensu version 0.9.7 client 

#
# Cookbook Name:: sensu-config
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
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


root_group = value_for_platform(
  ["aix"] => { "default" => "system" },
  ["hpux"] => { "default" => "sys" },
  "default" => "root"
)

directory "#{node["sensu"]["path"]}" do
  action :create
end

case node["os"]
when "hpux"
  directory "/sbin/init.d" do
    action :create
  end
else
  directory "/etc/init.d" do
    action :create
  end
end

directory "/var/log" do
  action :create
end


case node["os"]
when "aix"
  directory "/var/chef/run" do
    owner "root"
    group "system"
    mode 0755
    action :create
  end
else
  directory "/var/run" do
    action :create
  end
end




# remote copy files conf.d  
remote_directory "#{node["sensu"]["path"]}/conf.d" do
  source "sensu/conf.d"
  recursive true
  notifies :restart, "service[sensu-client]", :delayed
end

remote_directory "#{node["sensu"]["path"]}/handlers" do
  source "sensu/handlers"
  recursive true
  files_mode 0755
end

remote_directory "#{node["sensu"]["path"]}/plugins" do
  source "sensu/plugins"
  files_mode 0755
  recursive true
end

directory "#{node["sensu"]["path"]}/plugins/system" do
  action :create
end

# remote config.json
cookbook_file "#{node["sensu"]["path"]}/config.json" do
  source "sensu/config.json"
  notifies :restart, "service[sensu-client]", :delayed
end

cookbook_file "#{node["sensu"]["path"]}/redis-event.rb" do
  source "sensu/redis-event.rb"
end


# template client.json erb
node["conf_files"].each do |conf|
  template "#{node["sensu"]["path"]}/conf.d/#{conf}" do
    source "conf.d/#{conf}.erb"
    mode 0644
    notifies :restart, "service[sensu-client]", :delayed
  end
end

# temp system erb
node["plugin_files"].each do |pluginfile|
  template "#{node["sensu"]["path"]}/plugins/system/#{pluginfile}" do
    source "plugins/system/#{pluginfile}.erb"
    mode 0755
  end
end


#service config

conf_dir = value_for_platform(
  ["hpux"] => { "default" => "/sbin/init.d" },
  "default" => "/etc/init.d")
  

#template "#{conf_dir}/sensu_client" do
#  source "sensu_client.erb"
#  mode 0755
#end


file "#{conf_dir}/sensu_client" do
  action :delete
end

cookbook_file "#{conf_dir}/sensu-client" do
  source "sensu-client"
  mode 0755
end

service "sensu-client" do
  if (platform?("hpux"))
    provider Chef::Provider::Service::Hpux
  elsif (platform?("aix"))
    provider Chef::Provider::Service::Init
  end
  supports :restart => true
  action :start
end

# check sensu client Process status
if File.exist?("/var/log/sensu-client.log")
  file_time = File.mtime("/var/log/sensu-client.log").to_i
  unless (Time.now.to_i - file_time) < 100
    service "sensu-client" do
      if platform?("hpux")
        provider Chef::Provider::Service::Hpux
      elsif platform?("aix")
        provider Chef::Provider::Service::Init
      end
        action :restart
    end
  end
end

