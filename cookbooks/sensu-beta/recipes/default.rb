#
# Cookbook Name:: sensu-config
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# update sensu version to 0.9.7

gem_package "sensu" do
  if node["sensu"]["gem"]["platform"]
    options "--no-ri --no-rdoc --platform #{node["sensu"]["gem"]["platform"]}"
  else
    options "--no-ri --no-rdoc"
  end
  version "#{node["sensu"]["version"]}"
  action :install
end

gem_package "sensu-plugin" do
  options "--no-ri --no-rdoc"
  version "#{node["sensu"]["plugin"]["version"]}"
  action :install
end