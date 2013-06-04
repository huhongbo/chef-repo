# sensu version 0.9.12 client

#
# Cookbook Name:: sensu-config
# Recipe:: default
#
# Copyright 2013, dn365
# v0.1
# All rights reserved - Do Not Redistribute
#


# create directory
include_recipe "sensu::_config_dir"


# config.json file
confing = {
  "rabbitmq"=> {
    "host"=> node["sensu"]["config"]["rabbitmq_ip"],
    "port"=> node["sensu"]["config"]["rabbitmq_prot"],
    "user"=> node["sensu"]["config"]["rabbitmq_user"],
    "password"=> node["sensu"]["config"]["rabbitmq_password"],
    "vhost"=> "/sensu"
  }
}

file "#{node["sensu"]["path"]}/config.json" do
  content confing.to_json
  action :create
  notifies :run, "execute[restart sensu-client]", :delayed
end

# client.rb file

ip_address = node["ipaddress"] ? node.ipaddress : nil
unless ip_address
 ip_address = system("ping -c1 jfrddw01").to_s.scan(/\(([^\(]*)\)/).flatten[0]
end

client = {
  "client"=> {
    "name"=> node.hostname,
    "address"=> ip_address,
    "safe_mode"=>false,
    "subscriptions"=> ["system"] + node["sensu"]["tags"]["sources"]
  }
}
file "#{node["sensu"]["conf.d"]}/client.json" do
  content client.to_json
  action :create
  notifies :run, "execute[restart sensu-client]", :delayed
end

#files_path = value_for_platform(
#  "windows" => {"default"=> "windows"}
  #"default" => "default"
#)

cookbook_file "#{node["sensu"]["conf.d"]}/graphite.json" do
  source "sensu/conf.d/graphite.json"
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
  notifies :run, "execute[restart sensu-client]", :delayed
end

##copy sensu plugin files
remote_directory node["sensu"]["plugins"] do
  source "sensu/plugins"
  recursive true
  files_mode 0755 unless node.platform.eql?("windows")
end

dom_conf = Hash.new

if bag_sensu.to_s.include?("domain")
  dom_conf = data_bag_item('sensu','domain')
end
if dom_conf[node.hostname]
  domain_path = dom_conf[node.hostname]["ndom"] + "." + dom_conf[node.hostname]["nsubdom"]
  cpu_c = dom_conf[node.hostname]["tpcc"].to_f / 1000000
else
  domain_path = node["node"]["class"]
  cpu_c = 0
end

node["sensu"]["system_script"].each do |script|
  template "#{node["sensu"]["system"]}/#{script}" do
    source "plugins/system/#{script}.erb"
    variables(:path => domain_path,:cpu_tp=>cpu_c)
    mode 0755 unless node.platform.eql?("windows")
  end
end

case node.platform
when "windows"
  include_recipe "sensu::_windows"
else
  include_recipe "sensu::_linux"
end
