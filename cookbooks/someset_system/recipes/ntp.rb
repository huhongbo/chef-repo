# set ntp conf

file = node['ntp']['file']

ntp_group = value_for_platform(
{
  "ubuntu" => {"default"=>"ubuntu_ntp.conf.erb"},
  "suse" => {"default"=>"suse_ntp.conf.erb"},
  "aix" => {"default"=>"aix_ntp.conf.erb"},
  "hpux" => {"default"=>"hpux_ntp.conf.erb"}
})

puts ntp_group

template file do
  source "ntp/#{ntp_group}"
  variables(:def_ntp => node['ntp']['server'])
  #notifies :restart, "service[ntp]", :delayed
end


#server

service "ntp" do
  case node['os']
  when "hpux"
    service_name "xntpd"
    provider Chef::Provider::Service::Hpux
  when "aix"
    service_name "xntpd"
    pattern "xntpd"
    start_command "startsrc -s xntpd"
    stop_command "stopsrc -s xntpd"
    restart_command "stopsrc -s xntpd && sleep 2 && startsrc -s xntpd"
    status_command "ps exw | grep xntpd | grep -v grep | awk '{ print $1 }'"
  end
  supports :restart => true, :status => true
  action :start
  subscribes :restart, resources("template[#{file}]"), :delayed
end

  