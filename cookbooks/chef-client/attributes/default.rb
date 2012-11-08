#require 'rbconfig'

default["chefgems"]["name"] = "chef"
default["chefgems"]["version"] = "10.14.2"
#default["chefgems"]["mixlib"] = "mixlib-authentication-1.3.0.gem"
#default["chefgems"]["mixversion"] = "1.3.0"
case os
when "aix"
  if platform_version =~ /5/
    default["chef"]["gem"]["platform"] = "powerpc-aix-5"
  elsif platform_version =~ /6/
    default["chef"]["gem"]["platform"] = "powerpc-aix-6"
  else
    default["chef"]["gem"]["platform"] = nil
  end
when "hpux"
  if platform_version =~ /11.31/ and cpu["0"]["model"] =~ /Itanium/
    default["chef"]["gem"]["platform"] = "ia64-hpux-11"
  elsif platform_version =~ /11.11/ and cpu["0"]["model"] =~ /PA RISC/
    default["chef"]["gem"]["platform"] = "hppa2.0w-hpux-11"
  else
    default["chef"]["gem"]["platform"] = nil
  end
else
  default["chef"]["gem"]["platform"] = nil
end

default["gem"]["local"]["sources"] = "http://pc-mon02:9292"
default["chef_client"]["conf_dir"]    = "/etc/chef"
default["chef_client"]["bin"]         = "/usr/bin/chef-client"
default["chef_client"]["server_url"]  = "http://pc-mon02:4000"
default["chef_client"]["validation_client_name"] = "chef-validator"
default["chef_client"]["cron"] = { "minute" => "0,15,30,45", "hour" => "*", "path" => nil}
default["chef_client"]["rand_time"] = "420"


case platform
when "debian","ubuntu","redhat","centos","fedora"
  default["ruby"]["gem"]["path"] = "gem"
  default["chef_client"]["init_style"]  = "init"
  default["chef_client"]["run_path"]    = "/var/run/chef"
  default["chef_client"]["cache_path"]  = "/var/chef/cache"
  default["chef_client"]["backup_path"] = "/var/chef/backup"
when "hpux"
  default["ruby"]["gem"]["path"] = "/usr/local/ruby1.9/bin/gem"
  default["chef_client"]["init_style"] = "hpux"
  default["chef_client"]["run_path"]   = "/var/run"
  default["chef_client"]["cache_path"] = "/var/chef/cache"
  default["chef_client"]["backup_path"] = "/var/chef/backup"
else
  default["ruby"]["gem"]["path"] = "/opt/freeware/ruby1.9/bin/gem"
  default["chef_client"]["init_style"]  = "none"
  default["chef_client"]["run_path"]    = "/var/run"
  default["chef_client"]["cache_path"]  = "/var/chef/cache"
  default["chef_client"]["backup_path"] = "/var/chef/backup"
end
