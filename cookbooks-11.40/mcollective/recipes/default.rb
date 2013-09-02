#
# Cookbook Name:: mcollective-chef
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

#

unless node.platform.eql?("windows")
  gem_package "mcollective" do
    gem_binary "#{node["ruby"]["env_path"]}/gem" if ::File.exist?("#{node["ruby"]["env_path"]}/gem")
    options "--no-ri --no-rdoc"
    version "2.2.3"
    action :install
  end
end

include_recipe "mcollective::server"
  