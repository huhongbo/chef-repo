#
# Cookbook Name:: chef-client
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

directory "#{node["chef_client"]["conf_dir"]}/plugins" do
  action :create
end

template "#{node["chef_client"]["conf_dir"]}/client.rb" do
  source "client.rb.erb"
  variables(
    :chef_server_url => node["chef_client"]["server_url"],
    :validation_client_name => node["chef_client"]["validation_client_name"],
    :file_backup_path => node["chef_client"]["backup_path"],
    :file_cache_path => node["chef_client"]["cache_path"],
    :chef_ohai_pulgins => node["chef_client"]["conf_dir"]
  )
end



gem_package "chef" do
  action :install
  options "--no-ri --no-rdoc"
  version "#{node['chefgems']['version']}"
end
