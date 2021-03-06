# mcollective config
require 'rbconfig'

default["ruby"]["env_path"] = "/opt/chef/embedded/bin"
# stomp config
default["chef"]["server"]["hostname"] = "dntmon"
default["mcollective"]["stomp"]["host"] = node["chef"]["server"]["hostname"]
default["mcollective"]["stomp"]["port"] = "61613"
default["mcollective"]["stomp"]["user"] = "mcollective"
default["mcollective"]["stomp"]["password"] = "Passw0rd"

default["mcollective"]["version"] = "2.2.3"

# mcollective plugins path
default["mcollective"]["config_dir"] = "/etc/mcollective"
default["mcollective"]["libdir"] = "#{node["mcollective"]["config_dir"]}/mcollective-plugins"

default["mcollective"]["log_dir"] = "/var/log"

# mcollective security
default["mcollective"]["psk"] = "unset"

default['mcollective']['fact_whitelist'] = [
                                            'fqdn',
                                            'hostname',
                                            'ipaddress',
                                            'macaddress',
                                            'os',
                                            'os_version',
                                            'platform',
                                            'platform_version',
                                            'ohai_time',
                                            'uptime',
                                            'uptime_seconds'
                                           ]
case node['platform_family']
when /aix/
  default["ruby"]["env_path"] = "/opt/freeware/ruby1.9/bin"
when /hpux/
  default["ruby"]["env_path"] = "/usr/local/ruby1.9/bin"
when "windows"
  default["ruby"]["env_path"] = "C:/opscode/chef/embedded/bin"
  default["mcollective"]["config_dir"] = "C:/etc/mcollective"
  default["mcollective"]["libdir"] = "#{node["mcollective"]["config_dir"]}/mcollective-plugins"
  default["mcollective"]["log_dir"] = "#{node["mcollective"]["config_dir"]}/log"

  default["mcollective"]["windows"]["ruby_bin"] = "C:/opscode/chef/embedded/bin/ruby.exe"
  default["mcollective"]["windows"]["bin"] = "C:/opscode/chef/embedded/bin/mcollectived"
  default["mcollective"]["windows"]["winsw_dir"] = "C:/opscode/chef/bin"
  default["mcollective"]["windows"]["mco_exe"] = "mcollective.exe"
end
                                        