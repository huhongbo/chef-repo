# sensu version 0.9.12 server

#
# Cookbook Name:: sensu
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

confing = {
  "rabbitmq"=> {
    "host"=> node["sensu"]["config"]["rabbitmq_ip"],
    "port"=> node["sensu"]["config"]["rabbitmq_prot"],
    "user"=> node["sensu"]["config"]["rabbitmq_user"],
    "password"=> node["sensu"]["config"]["rabbitmq_password"],
    "vhost"=> "/sensu"
  },
  "redis"=> {
    "host"=>"127.0.0.1",
    "port"=> 6379
  },
  "api"=> {
    "host"=> "127.0.0.1",
    "port"=> 4567
  }
}

file "#{node["sensu"]["path"]}/config.json" do
  content confing.to_json
  action :create
  notifies :run, "execute[restart sensu-server]", :delayed
  notifies :run, "execute[restart sensu-client]", :delayed
end

# client.rb file
client = {
  "client"=> {
    "name"=> node.hostname,
    "address"=> node.ipaddress,
    "subscriptions"=> ["system"] + node["sensu"]["tags"]["sources"]
  }
}
file "#{node["sensu"]["conf.d"]}/client.json" do
  content client.to_json
  action :create
  notifies :run, "execute[restart sensu-server]", :delayed
  notifies :run, "execute[restart sensu-client]", :delayed
end

remote_directory node["sensu"]["path"] do
  source "sensu"
  recursive true
  files_owner "dntmon"
  files_group "dntmon"
  owner "dntmon"
  group "dntmon"
  files_mode 0755
  notifies :run, "execute[restart sensu-server]", :delayed
  notifies :run, "execute[restart sensu-client]", :delayed
end

begin
 data_bag('sensu')
 bag_sensu = data_bag('sensu')
rescue
  bag_sensu = []
end

if bag_sensu.to_s.include?("checks")
  check_data = data_bag_item('sensu','checks')
else
 check_data = node["sensu"]["default_value"]
end

#if !data_bag('sensu').empty? and !data_bag_item('sensu','checks').empty?
#  check_data = data_bag_item('sensu','checks').reject{|k,v| ["id"].include?(k)}
#end

check_source = check_data['check_source_list']
check_array = []
check_source.each do |source|
  value = (check_data[node.hostname] and check_data[node.hostname]["#{source}"]) ? check_data[node.hostname]["#{source}"] : check_data['default']["#{source}"]
  check_array << [source,value]
end


template "#{node["sensu"]["conf.d"]}/check_event.json" do
  source "conf.d/check_event.json.erb"
  variables(:check_hash => Hash[check_array])
  notifies :run, "execute[restart sensu-server]", :delayed
  notifies :run, "execute[restart sensu-client]", :delayed
end

dom_conf = Hash.new

if bag_sensu.to_s.include?("domain")
  dom_conf = data_bag_item('sensu','domain')
end
if dom_conf[node.hostname]
  domain_path = dom_conf[node.hostname]["ndom"] + "." + dom_conf[node.hostname]["nsubdom"]
  cpu_c = dom_conf[node.hostname]["tpcc"].to_i.to_f / 1000000
else
  domain_path = node["node"]["class"]
  cpu_c = 0
end

node["sensu"]["system_script"].each do |script|
  template "#{node["sensu"]["system"]}/#{script}" do
    source "plugins/system/#{script}.erb"
    variables(:path => domain_path,:cpu_tp=>cpu_c)
    mode 0755
  end
end


execute "restart sensu-server" do
  command "sv restart sensu-server"
  action :nothing
end

execute "restart sensu-client" do
  command "sv restart sensu-client"
  action :nothing
end

execute "start sensu-server" do
  command "sv start sensu-server"
  action :run
end
execute "start sensu-client" do
  command "sv start sensu-client"
  action :run
end
execute "start sensu-api" do
  command "sv start sensu-api"
  action :run
end
execute "start sensu-dashboard" do
  command "sv start sensu-dashboard"
  action :run
end