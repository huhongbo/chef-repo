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

template file do
  source "ntp/#{ntp_group}"
  variables(:def_ntp => node['ntp']['server'])
  #notifies :restart, "service[ntp]", :delayed
end

if node['os'].eql?("aix")
  template "/etc/init.d/ntp" do
    source "aix_ntpxd.erb"
    files_mode 0755
    #notifies :restart, "service[ntp]", :delayed
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

  