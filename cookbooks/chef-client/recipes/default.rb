#
# Cookbook Name:: chef-client
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#add chef server ip to hosts
hosts_file = File.open("/etc/hosts").read
unless hosts_file.include?("#{node["chef"]["hosts"]["name"]}")
  hosts_stat = File.open("/etc/hosts","w")
  hosts_stat.puts(hosts_file)
  hosts_stat.puts("#{node["chef"]["hosts"]["ip"]} #{node["chef"]["hosts"]["name"]}")
  hosts_stat.close
end


# change gem sources url
if (gem_in_path=%x{which gem}.chomp) && ::File.executable?(gem_in_path)
  gem_path = gem_in_path
elsif ::File.executable?(node["ruby"]["gem"]["path"])
  gem_path = node["ruby"]["gem"]["path"]
else
  raise "Could not locate the gem in any known path"
end
#unless %x{#{gem_path} sources}.include?(node["gem"]["local"]["sources"])
#  execute "delete old gem sources" do
#    command "#{gem_path} sources -r http://rubygems.org/"
#    action :run
#  end
#  execute "add local server url" do
#    command "#{gem_path} sources -a #{node["gem"]["local"]["sources"]}"
#    action :run
#  end
#end



directory "#{node["chef_client"]["conf_dir"]}/plugins" do
  action :create
end


#remote chef client.rb in chef conf path
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
#remote knife.rb in knife path
knife_path = node.os.eql?("linux") ? "/root/.chef" : "/.chef"
template "#{knife_path}/knife.rb" do
  source "knife.rb.erb"
  variables(:path => knife_path)
end



gem_package "chef" do
  action :install
  if node["chef"]["gem"]["platform"]
    options "--no-ri --no-rdoc --platform #{node["chef"]["gem"]["platform"]}"
  else
    options "--no-ri --no-rdoc"
  end
  version "#{node['chefgems']['version']}"
end
