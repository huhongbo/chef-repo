# sensu version 0.9.7 client 

#
# Cookbook Name:: sensu-config
# sensu server config
#
# Copyright 2012, dn365
#
# All rights reserved - Do Not Redistribute
#

#copy sensu files to sensu path

remote_directory "#{node["sensu"]["path"]}" do
  source "sensu"
  recursive true
end
## create sensu plugins system srcript dir
directory "#{node["sensu"]["path"]}/plugins/system" do
  action :create
end
# create sensu config.json
config = data_bag_item('sensu','config').reject{|k,v| ["id"].include?(k) }
file "#{node["sensu"]["path"]}/config.json" do
  content config.to_json
  action :create
  #notifies :restart, "service[sensu-client]", :delayed
end

# create sensu check files
## create alram checks file
check_data = data_bag_item('sensu','checks').reject{|k,v| ["id"].include?(k)}
check_source = check_data['check_source_list']

check_array = []
check_source.each do |source|
  value = (check_data[node.hostname] and check_data[node.hostname]["#{source}"]) ? check_data[node.hostname]["#{source}"] : check_data['default']["#{source}"]
  check_array << [source,value]
end
##create file check_event.json
template "#{node["sensu"]["path"]}/conf.d/check_event.json" do
  source "conf.d/check_event.json.erb"
  variables(check_hash: Hash[check_array])
  notifies :restart, "service[sensu-client]", :delayed
end
## template client.json erb
template "#{node["sensu"]["path"]}/conf.d/client.json" do
  source "conf.d/client.json.erb"
  mode 0644
  notifies :restart, "service[sensu-client]", :delayed
end


## template load plugin systems script
node["plugin_files"].each do |pluginfile|
  template "#{node["sensu"]["path"]}/plugins/system/#{pluginfile}" do
    source "plugins/system/#{pluginfile}.erb"
    mode 0755
  end
end

# ruby script file chmod
Dir.glob("#{node["sensu"]["path"]}/**/*.rb").map do |rb_file|
  file "#{rb_file}" do
    mode 0755
  end
end

# create sensu client service script
conf_dir = value_for_platform(
  ["hpux"] => { "default" => "/sbin/init.d" },
  "default" => "/etc/init.d")
  
directory "#{conf_dir}" do
  action :create
end
cookbook_file "#{conf_dir}/sensu-client" do
  source "sensu-client"
  mode 0755
end

# sensu client service start
service "sensu-client" do
  if (platform?("hpux"))
    provider Chef::Provider::Service::Hpux
  elsif (platform?("aix"))
    provider Chef::Provider::Service::Init
  end
  supports :restart => true, :status => true
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
