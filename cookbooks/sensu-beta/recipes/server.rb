#sensu version 0.9.7 server

directory "#{node["sensu"]["path"]}" do
  action :create
end

#remote files

remote_directory "#{node["sensu"]["path"]}" do
  source "sensu"
  recursive true
end

# template client.json
template "#{node["sensu"]["path"]}/conf.d/client.json" do
  source "conf.d/client.json.erb"
end

# plugins script
node["plugin_files"].each do |pluginfile|
  template "#{node["sensu"]["path"]}/plugins/system/#{pluginfile}" do
    source "plugins/system/#{pluginfile}.erb"
  end
end

Dir.glob("#{node["sensu"]["path"]}/**/*.rb").map do |rb_file|
  file "#{rb_file}" do
    mode 0755
  end
end