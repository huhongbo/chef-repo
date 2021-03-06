require 'rbconfig'

#default["graphite"]["url"] = "graphite1.dntmon.com"
default["graphite"]["url"] = "graphite1.dntmon.com"
default["graphite"]["ser_ip"] = "127.0.0.1"


default["ruby"]["env_path"] = "/opt/chef/embedded/bin"

# sensu config directory

default["sensu"]["path"] = "/etc/sensu"
default["sensu"]["log_dir"] = "#{node["sensu"]["path"]}/log"
default["sensu"]["conf.d"] = "#{node["sensu"]["path"]}/conf.d"
default["sensu"]["handlers"] = "#{node["sensu"]["path"]}/handlers"
default["sensu"]["plugins"] = "#{node["sensu"]["path"]}/plugins"
default["sensu"]["system"] = "#{node["sensu"]["plugins"]}/system"

# rabbitmq ipaddress and port

default["sensu"]["config"]["rabbitmq_ip"] = node["graphite"]["ser_ip"]
default["sensu"]["config"]["rabbitmq_prot"] = 5672
default["sensu"]["config"]["rabbitmq_user"] = "sensu"
default["sensu"]["config"]["rabbitmq_password"] = "Passw0rd"

default["senus"]["server"]["user"] = "dntmon"
default["senus"]["server"]["group"] = "dntmon"

# sensu server handler warn data insert db config
default["sensu"]["warn_db"]["host"] = "127.0.0.1"
default["sensu"]["warn_db"]["user"] = "dntmon"
default["sensu"]["warn_db"]["password"] = "dPassw0rd"

# check script run splay time
default["sensu"]["check_graphite"]["randtime"] = 45

# default Application Class in node
default["node"]["class"] = "OTHER.SUBOTHER"


default["sensu"]["tags"]["sources"] = []

# default graphite data's checks script file
default["sensu"]["check_plugins"] = [
  "check_graph.rb",
  "check_max_proc.rb",
  "check_system_event.rb",
  "client-log_del.rb"
  ]

default["sensu"]["system_script"] = [
                                          "system_default.rb",
                                          "network.rb",
                                          "netstat.rb",
                                          "load.rb",
                                          "system_user_cpu_used.rb",
                                          "disk_tps.rb",
                                          "hba.rb"
                                        ]


default["sensu"]["default_value"] = {
  :default => {
    :cpu => {
      :warning => 95,
      :critical => 100
    },
    :stdev_cpu => {
      :warning => 10,
      :critical => 12
    },
    :filesystem_event => {
      :warning => 90,
      :critical=> 95
    },
    :memory_event => {
      :warning => 90,
      :critical => 95
    },
    :swap_event => {
      :warning => 95,
      :critical => 98
    },
    :proc_event => {
      :warning => 90,
      :critical => 95
    }
  },
  :check_source_list => ["cpu","stdev_cpu","filesystem_event","memory_event","swap_event","proc_event"]
} 


case os
when "aix"
  default["ruby"]["env_path"] = "/opt/freeware/ruby1.9/bin"
  if platform_version =~ /5/
    default["sensu"]["gem"]["platform"] = "powerpc-aix-5"
  elsif platform_version =~ /6/
    default["sensu"]["gem"]["platform"] = "powerpc-aix-6"
  else
    default["sensu"]["gem"]["platform"] = nil
  end
when "hpux"
  default["ruby"]["env_path"] = "/usr/local/ruby1.9/bin"
  if platform_version =~ /11.31/ and cpu["0"]["model"] =~ /Itanium/
    default["sensu"]["gem"]["platform"] = "ia64-hpux-11"
  elsif platform_version =~ /11.11/ and cpu["0"]["model"] =~ /PA RISC/
    default["sensu"]["gem"]["platform"] = "hppa2.0w-hpux-11"
  else
    default["sensu"]["gem"]["platform"] = nil
  end
else
  default["sensu"]["gem"]["platform"] = nil
end



case node['platform_family']
when "windows"
  default["ruby"]["env_path"] = "C:/opscode/chef/embedded/bin"
  default["sensu"]["path"] = "C:/etc/sensu"
  default["sensu"]["log_dir"] = "#{node["sensu"]["path"]}/log"
  default["sensu"]["conf.d"] = "#{node["sensu"]["path"]}/conf.d"
  default["sensu"]["handlers"] = "#{node["sensu"]["path"]}/handlers"
  default["sensu"]["plugins"] = "#{node["sensu"]["path"]}/plugins"
  default["sensu"]["system"] = "#{node["sensu"]["plugins"]}/system"
  
  default["sensu"]["windows"]["ruby_bin"] = "C:/opscode/chef/embedded/bin/ruby.exe"
  default["sensu"]["windows"]["sensu_bin"] = "C:/opscode/chef/embedded/bin/sensu-client"
  default["sensu"]["windows"]["winsw_dir"] = "C:/opscode/chef/bin"
  default["sensu"]["windows"]["sensu_exe"] = "sensu-client.exe"
  
  default["sensu"]["system_script"] = ["win_sysinfo.rb","win_network.rb","win_futility.rb"]
end
