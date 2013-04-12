# set ntp conf

file = node['ntp']['file']

ntp_group = value_for_platform(
{
  "ubuntu" => {"default"=>"ubuntu_ntp.conf.erb"},
  "suse" => {"default"=>"suse_ntp.conf.erb"},
  "aix" => {"default"=>"aix_ntp.conf.erb"},
  "hpux" => {"default"=>"hpux_ntp.conf.erb"}
})

#puts ntp_group
ntp_data_value = data_bag_item('config','ntp')
ntp_server_ip = node['ntp']['server']
other_conf = []
if ntp_data_value[node.hostname]
  ntp_server_ip = ntp_data_value[node.hostname]['ip']
  other_conf = ntp_data_value[node.hostname]['other']
elsif ntp_data_value['default']
  ntp_server_ip = ntp_data_value['default']['ip']
  other_conf = ntp_data_value['default']['other']
end


template file do
  source "ntp/#{ntp_group}"
  variables(:def_ntp => ntp_server_ip,:othconf=>other_conf)
end

if node['os'].eql?("aix")
  template "/etc/init.d/ntp" do
    source "aix_ntpxd.erb"
    mode 0755
  end
end

#server

service "ntp" do
  case node['os']
  when "hpux"
    service_name "xntpd"
    provider Chef::Provider::Service::Hpux
  end
  supports :restart => true, :status => true
  action :start
  subscribes :restart, resources("template[#{file}]"), :delayed
end

  