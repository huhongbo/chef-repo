require 'rbconfig'

default["graphite"]["url"] = "graphite.zj.chinamobile.com"
default["graphite"]["ser_ip"] = "10.70.181.217"



# sensu config directory

default["sensu"]["path"] = "/etc/sensu"
default["sensu"]["log_dir"] = "#{node["sensu"]["path"]}/log"
default["sensu"]["conf.d"] = "#{node["sensu"]["path"]}/conf.d"
default["sensu"]["handlers"] = "#{node["sensu"]["path"]}/handlers"
default["sensu"]["plugins"] = "#{node["sensu"]["path"]}/plugins"
default["sensu"]["system"] = "#{node["sensu"]["plugins"]}/system"

# rabbitmq ipaddress and port

default["sensu"]["config"]["rabbitmq_ip"] = "10.211.55.16"
default["sensu"]["config"]["rabbitmq_prot"] = 5672
default["sensu"]["config"]["rabbitmq_user"] = "sensu"
default["sensu"]["config"]["rabbitmq_password"] = "Passw0rd"

default["senus"]["server"]["user"] = "dntmon"
default["senus"]["server"]["group"] = "dntmon"

# sensu server handler warn data insert db config
default["sensu"]["warn_db"]["host"] = "10.211.55.16"
default["sensu"]["warn_db"]["user"] = "dntmon"
default["sensu"]["warn_db"]["password"] = "dPassw0rd"

# check script run splay time
default["sensu"]["check_graphite"]["randtime"] = 45

# default Application Class in node
default["node"]["class"] = "OTHER.SUBOTHER"


default["sensu"]["tags"]["sources"] = []

# default graphite data's checks script file
default["sensu"]["system_script"] = [
                                          "system_default.rb",
                                          "network.rb",
                                          "load.rb",
                                          "system_user_cpu_used.rb",
                                          "disk_tps.rb",
                                          "hba.rb"
                                        ]



case node['platform_family']
when "windows"
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
  
  default["sensu"]["system_script"] = ["win_sysinfo.rb","win_network.rb"]
end