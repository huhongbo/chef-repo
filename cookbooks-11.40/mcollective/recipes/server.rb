# mcollective server config
# code dn365


directory node["mcollective"]["config_dir"] do
  action :create
end



remote_directory "#{node["mcollective"]["libdir"]}" do
  source "plugins"
  recursive true
  notifies :run, "execute[restart mcollective]", :delayed
end

template "#{node["mcollective"]["config_dir"]}/server.cfg" do
  source "server.cfg.erb"
  notifies :run, "execute[restart mcollective]", :delayed
end

ruby_block "create facts file" do
  block do
    state = ::File.open("#{node["mcollective"]["config_dir"]}/facts.yaml", "w")
    state.puts("---\n")
    node['mcollective']['fact_whitelist'].each do |facts|
      keys = node["#{facts}"]
      state.puts("#{facts}: #{keys}")
    end
    state.close
  end
end


#ruby_block "store node data locally" do
#  block do
#    state = ::File.open("#{node["mcollective"]["config_dir"]}/chefnode.txt", "w")
#    node.run_state[:seen_recipes].keys.each do |recipe|
#      state.puts("recipe.#{recipe}")
#    end
#    node.run_list.roles.each do |role|
#      state.puts("role.#{role}")
#    end
#    node[:tags].each do |tag|
#      state.puts("tag.#{tag}")
#    end
#    state.close
#  end
#end




case node.platform
when "windows"
  directory "#{node["mcollective"]["config_dir"]}/log" do
    action :create
  end
  
  winsw_bin = File.join(node["mcollective"]["windows"]["winsw_dir"],node["mcollective"]["windows"]["mco_exe"])

  template "#{node["mcollective"]["windows"]["winsw_dir"]}/mcollective.xml" do
    source "mcollective.xml.erb"
    notifies :run, "execute[restart mcollective]", :delayed
  end
  cookbook_file winsw_bin do
    source "winsw-1.9-bin.exe"
    not_if { File.exists?(winsw_bin) }
  end

  execute "restart mcollective" do
    command "#{winsw_bin} restart"
    not_if { WMI::Win32_Service.find(:first, :conditions => {:name => "mcollective"}).nil? }
    action :nothing
  end

  execute "Install mcollective service using winsw" do
    command "#{winsw_bin} install"
    only_if { WMI::Win32_Service.find(:first, :conditions => {:name => "mcollective"}).nil? }
  end

  service "mcollective" do
    action :start
  end

else
  
  directory "/var/chef/lock" do
    action :create
  end

  service_path = value_for_platform(
    ["hpux"] => {"default" => "/sbin/init.d"},
    "default" => "/etc/init.d"
  )

  directory "#{service_path}" do
    action :create
  end

  template "#{service_path}/mcollective" do
    source "mcollective.erb"
    mode 0755
  end
  
  execute "restart mcollective" do
    command "#{service_path}/mcollective restart"
    action :nothing
  end

  service "mcollective" do
    case node[:platform]
    when "hpux"
      provider Chef::Provider::Service::Hpux
    when "aix"
      provider Chef::Provider::Service::Init
    end
    supports :restart => true, :status => true
    action :start
  end

  execute "delete  log file" do
    command "#{service_path}/mcollective restart"
    action :run
    only_if do
      lock = ::File.exists?('/var/chef/lock/mcollective') && ::File.mtime('/var/chef/lock/mcollective') < Time.now - 86400
      log = ::File.exists?('/var/log/mcollective.log') && ::File.mtime('/var/log/mcollective.log') < Time.now - 600
      first = !::File.exists?('/var/log/mcollective.log')
      lock || log || first
    end
  end

end







