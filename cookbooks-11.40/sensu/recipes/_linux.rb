
#create logs dirstory
directory "/var/log" do
  action :create
end

case node.os
when "aix"
  directory "/var/chef/run" do
    owner "root"
    group "system"
    mode 0755
    action :create
  end
when "hpux"
  directory "/var/run" do
    action :create
  end
when "linux"
  directory "/var/run" do
    action :create
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



# restart sensu client
execute "restart sensu-client" do
  command "#{conf_dir}/sensu-client restart"
  action :nothing
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
    execute "delete sensu-client log file" do
      command "#{conf_dir}/sensu-client restart"
      action :run
    end
  end
end
