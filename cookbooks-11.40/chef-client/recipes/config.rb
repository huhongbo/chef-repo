# config chef client.rb

# Create config directorys

if  node.platform_family.include?("windows")
  directory "C:/etc" do
    action :create
  end
end

directory node["chef_client"]["conf_dir"] do
  action :create
end

[node["chef_client"]["log_dir"],node["ohai"]["plugins"]].each do |dir_path|
  directory dir_path do
    action :create
  end
end


#remote chef client.rb in chef conf path
template "#{node["chef_client"]["conf_dir"]}/client.rb" do
  source "client.rb.erb"
  variables(
    :chef_server_url => node["chef_client"]["server_url"],
    :validation_client_name => node["chef_client"]["validation_client_name"],
    :file_backup_path => node["chef_client"]["backup_path"],
    :file_cache_path => node["chef_client"]["cache_path"],
    :chef_ohai_pulgins => node["ohai"]["plugins"],
    :disabled_plugins => node["ohai"]["disabled_plugins"]
  )
end