#win_path = value_for_platform(
#  "windows" => {"default"=>"windows"}
  #"default" => "default"
#)

winsw_bin = File.join(node["sensu"]["windows"]["winsw_dir"],node["sensu"]["windows"]["sensu_exe"])

template "#{node["sensu"]["windows"]["winsw_dir"]}/sensu-client.xml" do
  source "sensu-client.xml.erb"
  notifies :run, "execute[restart sensu-client]", :delayed
end
cookbook_file winsw_bin do
  source "services/winsw-1.9-bin.exe"
  not_if { File.exists?(winsw_bin) }
end

execute "restart sensu-client" do
  command "#{winsw_bin} restart"
  not_if { WMI::Win32_Service.find(:first, :conditions => {:name => "sensu-client"}).nil? }
  action :nothing
end

execute "Install sensu-client service" do
  command "#{winsw_bin} install"
  only_if { WMI::Win32_Service.find(:first, :conditions => {:name => "sensu-client"}).nil? }
end

service "sensu-client" do
  action :start
end