# install chef client to windows


template "#{node["chef_client"]["winsw_dir"]}/chef-client.xml" do
  source "windows/chef-client.xml.erb"
  notifies :run, "execute[restart chef-client using winsw wrapper]", :delayed
end

winsw_path = File.join(node["chef_client"]["winsw_dir"], node["chef_client"]["winsw_exe"])

cookbook_file winsw_path do
  source "windows/#{node["chef_client"]["winsw_bin"]}"
  not_if { File.exists?(winsw_path) }
end

directory node["chef_client"]["log_dir"] do    
  action :create  
end

# Work-around for CHEF-2541
# Should be replaced by a service :restart action

execute "restart chef-client using winsw wrapper" do
  command "#{winsw_path} restart"
  not_if { WMI::Win32_Service.find(:first, :conditions => {:name => "chef-client"}).nil? }
  action :nothing
end

execute "Install chef-client service using winsw" do
  command "#{winsw_path} install"
  only_if { WMI::Win32_Service.find(:first, :conditions => {:name => "chef-client"}).nil? }
end

service "chef-client" do
  action :start
end