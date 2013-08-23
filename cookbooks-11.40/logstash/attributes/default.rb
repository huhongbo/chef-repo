require 'rbconfig'


default["logstash"]["host"] = "10.78.170.11"

default["logstash"]["aix_cron"] = "* * * * *"

default["logstash"]["dir_path"] = "/opt/logstash"

default["ruby"]["env_path"] = "/opt/chef/embedded/bin"

case node['platform_family']
when "aix"
  default["ruby"]["env_path"] = "/opt/freeware/ruby1.9/bin"
when "hpux"
  default["ruby"]["env_path"] = "/usr/local/ruby1.9/bin"
when "debian","rhel","fedora","suse"
when "windows"
  default["ruby"]["env_path"] = "C:/opscode/chef/embedded/bin"
end