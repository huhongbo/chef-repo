require 'rbconfig'


default["graphite"]["url"] = "graphite.zj.chinamobile.com"
default["graphite"]["ser_ip"] = "10.70.181.217"


default["sensu"]["path"] = "/etc/sensu"

#if node["system"].nil? or node["system"]["Business"].nil?
default["node"]["app"] = "OTHER.SUBOTHER"
#else
#  default["node"]["app"] = node["system"]["Business"]
#end

default["sensu"]["package"] = "sensu"
default["sensu"]["version"] = "0.9.7"
default["sensu"]["plugin"]["package"] = "sensu-plugin"
default["sensu"]["plugin"]["version"] = "0.1.4"
default["sensu"]["db"]["host"] = "10.70.181.217"
default["sensu"]["db"]["user"] = "dntmon"
default["sensu"]["db"]["password"] = "dPassw0rd"
default["sensu"]["check"]["randtime"] = 45

default["sensu"]["windows"]["ruby_bin"] = "C:/opscode/chef/embedded/bin/ruby.exe"
default["sensu"]["windows"]["sensu_bin"] = "C:/opscode/chef/embedded/bin/sensu-client"
default["sensu"]["windows"]["path"] = "C:/etc/sensu"
default["sensu"]["windows"]["log_dir"] = "C:/etc/log/sensu"

default["sensu"]["windows"]["winsw_dir"] = "C:/opscode/chef/bin"




case os
when "aix"
  if platform_version =~ /5/
    default["sensu"]["gem"]["platform"] = "powerpc-aix-5"
  elsif platform_version =~ /6/
    default["sensu"]["gem"]["platform"] = "powerpc-aix-6"
  else
    default["sensu"]["gem"]["platform"] = nil
  end
when "hpux"
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



default["plugin_files"] = [
                            "network.rb",
                            "load.rb",
                            "system_default.rb",
                            "hpux-ruby-memory.rb",
                            "system_user_cpu_used.rb",
                            "disk_tps.rb",
                            "hba.rb"
                          ]
                          

#default["handler_files"] = ["client-log_del.rb"]
#default["conf_files"] = ["client.json", "check_cpu.json"]
