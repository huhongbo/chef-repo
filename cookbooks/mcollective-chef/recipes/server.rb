# mcollective server config
# code dn365

gem_package "mcollective" do
  options "--no-ri --no-rdoc"
  version "#{node["mcollective"]["version"]}"
  action :install
end

directory "/etc/mcollective" do
  action :create
end
directory "/var/chef/lock" do
  action :create
end

remote_directory "#{node["mcollective"]["libdir"]}" do
  source "plugins"
  recursive true
  notifies :restart, "service[mcollective]", :delayed
end

template "/etc/mcollective/server.cfg" do
  source "server.cfg.erb"
  notifies :restart, "service[mcollective]", :delayed
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


ruby_block "store node data locally" do
  block do

    state = ::File.open("/etc/mcollective/chefnode.txt", "w")
    node.run_state[:seen_recipes].keys.each do |recipe|
      state.puts("recipe.#{recipe}")
    end
    node.run_list.roles.each do |role|
      state.puts("role.#{role}")
    end
    node[:tags].each do |tag|
      state.puts("tag.#{tag}")
    end

    state.close
  end
end

ruby_block "create facts file" do
  block do
    state = ::File.open("/etc/mcollective/facts.yaml", "w")
    state.puts("---\n")
    node['mcollective']['fact_whitelist'].each do |facts|
      keys = node["#{facts}"]
      state.puts("#{facts}: #{keys}")
    end

    state.close
  end
end

service "mcollective" do
  case node[:platform]
  when "hpux"
    provider Chef::Provider::Service::Hpux
  when "aix"
    provider Chef::Provider::Service::Init
  end
  supports :restart => true, :status => true
  action :restart
  ignore_failure true
  only_if do
    lock = ::File.exists?('/var/chef/lock/mcollective') && ::File.mtime('/var/chef/lock/mcollective') < Time.now - 86400
    log = ::File.exists?('/var/log/mcollective.log') && ::File.mtime('/var/log/mcollective.log') < Time.now - 600
    lock || log
  end
end
