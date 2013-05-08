# sensu version 0.9.7 client

#
# Cookbook Name:: sensu-config
# sensu server config
#
# Copyright 2012, dn365
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

#copy sensu files to sensu path
remote_directory "#{node["sensu"]["path"]}" do
  source "sensu"
  recursive true
  owner "sensu"
  group "sensu"
  files_owner "sensu"
  files_group "sensu"
  files_mode 0755
end

# create sensu config.json
config = data_bag_item('sensu','config').reject{|k,v| ["id"].include?(k) }
file "#{node["sensu"]["path"]}/config.json" do
  content config.to_json
  owner "sensu"
  group "sensu"
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
  owner "sensu"
  group "sensu"
  variables(:check_hash => Hash[check_array])
  notifies :restart, "service[sensu-client]", :delayed
end
## template client.json erb
template "#{node["sensu"]["path"]}/conf.d/client.json" do
  source "conf.d/client.json.erb"
  mode 0644
  owner "sensu"
  group "sensu"
  notifies :restart, "service[sensu-client]", :delayed
end

## create sensu plugins system srcript dir
directory "#{node["sensu"]["path"]}/plugins/system" do
  owner "sensu"
  group "sensu"
  action :create
end

#graphite whisper directory
dom_conf = data_bag_item('sensu','domain')
if dom_conf[node.hostname]
  domain_path = dom_conf[node.hostname]["ndom"] + "." + dom_conf[node.hostname]["nsubdom"]
  cpu_c = dom_conf[node.hostname]["tpcc"].to_i.to_f / 1000000
else
  domain_path = node["node"]["app"]
  cpu_c = 0
end


## template load plugin systems script
node["plugin_files"].each do |pluginfile|
  template "#{node["sensu"]["path"]}/plugins/system/#{pluginfile}" do
    source "plugins/system/#{pluginfile}.erb"
    variables(:path => domain_path,:cpu_tp=>cpu_c)
    mode 0755
    owner "sensu"
    group "sensu"
  end
end

template "#{node["sensu"]["path"]}/handlers/alarm_sms.rb" do
  source "handlers/alarm_sms.rb.erb"
  mode 0644
  owner "sensu"
  group "sensu"
end

# ruby script file chmod
Dir.glob("#{node["sensu"]["path"]}/**/*.rb").map do |rb_file|
  file "#{rb_file}" do
    mode 0755
    owner "sensu"
    group "sensu"
  end
end

# create sensu client service script
conf_dir = value_for_platform(
  ["hpux"] => { "default" => "/sbin/init.d" },
  "default" => "/etc/init.d")

directory "#{conf_dir}" do
  owner "sensu"
  group "sensu"
  action :create
end

cookbook_file "#{conf_dir}/sensu-client" do
  source "sensu-client"
  mode 0755
  owner "sensu"
  group "sensu"
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
