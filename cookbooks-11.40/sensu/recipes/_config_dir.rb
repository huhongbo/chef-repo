
# Create sensu config directory if C:/etc not exist
if node.platform.eql?("windows")
  directory "C:/etc" do
    action :create
  end
end

directory "#{node["sensu"]["path"]}" do
  action :create
end

[node["sensu"]["log_dir"],node["sensu"]["conf.d"],node["sensu"]["handlers"],node["sensu"]["plugins"],node["sensu"]["system"]].each do |path|
  directory path do
    action :create
  end
end