# code dn365

# COOK-635 account for alternate gem paths
# try to use the bin provided by the node attribute

case node.platform_family
when "debian", "fedora", "suse", "aix", "hpux"
  if ::File.executable?(node["chef_client"]["bin"])
    client_bin = node["chef_client"]["bin"]
  elsif (chef_in_path=%x{which chef-client}.chomp) && ::File.executable?(chef_in_path)
    client_bin = chef_in_path
  else
    raise "Could not locate the chef-client bin in any known path. Please set the proper path by overriding node['chef_client']['bin'] in a role."
  end
  cron "chef-client" do
    minute node['chef_client']['cron']['minute']	
    hour	node['chef_client']['cron']['hour']
    user	"root"
    if platform?("aix") or platform?("hpux")
      provider Chef::Provider::Cron::Solaris
    end
    command "#{client_bin} -s #{node["chef_client"]["splay"]}"
  end
end


