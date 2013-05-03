## chef client 11.4.0
# fix windows
###

require 'rbconfig'

# chef server ip
default["chef"]["server"]["ip"] = "10.211.55.16"
default["chef"]["server"]["hostname"] = "chef-server"

default["chef_client"]["interval"]    = "300"
default["chef_client"]["splay"]       = "30"
default["chef_client"]["log_dir"]     = "/var/log/chef"
default["chef_client"]["log_file"]    = nil
default["chef_client"]["log_level"]   = :info
default["chef_client"]["verbose_logging"] = true
default["chef_client"]["conf_dir"]    = "/etc/chef"
default["chef_client"]["bin"]         = "/usr/bin/chef-client"
default["chef_client"]["server_url"]  = "https://#{node["chef"]["server"]["hostname"]}"
default["chef_client"]["validation_client_name"] = "chef-validator"



default["chef_client"]["cron"] = {
  "minute" => "0",
  "hour" => "*/4",
  "path" => nil,
  "environment_variables" => nil,
  "log_file" => "/dev/null",
  "use_cron_d" => false
}

default["chef_client"]["environment"] = nil
default["chef_client"]["load_gems"] = {}
default["chef_client"]["report_handlers"] = []
default["chef_client"]["exception_handlers"] = []
default["chef_client"]["checksum_cache_skip_expires"] = true
default["chef_client"]["daemon_options"] = []
default["ohai"]["plugins"] = "#{node["chef_client"]["conf_dir"]}/plugins"
default["ohai"]["disabled_plugins"] = ["network_listeners"]


case node['platform_family']
when "aix"
  default["ruby"]["gem"]["path"] = "/opt/freeware/ruby1.9/bin/gem"
  default["chef_client"]["init_style"]  = "aix"
  default["chef_client"]["run_path"]    = "/var/run"
  default["chef_client"]["cache_path"]  = "/var/chef/cache"
  default["chef_client"]["backup_path"] = "/var/chef/backup"
when "hpux"
  default["ruby"]["gem"]["path"] = "/usr/local/ruby1.9/bin/gem"
  default["chef_client"]["init_style"] = "hpux"
  default["chef_client"]["run_path"]   = "/var/run"
  default["chef_client"]["cache_path"] = "/var/chef/cache"
  default["chef_client"]["backup_path"] = "/var/chef/backup"
when "debian","rhel","fedora","suse"
  default["chef_client"]["init_style"]  = "init"
  default["chef_client"]["run_path"]    = "/var/run/chef"
  default["chef_client"]["cache_path"]  = "/var/cache/chef"
  default["chef_client"]["backup_path"] = "/var/lib/chef"
when "openbsd","freebsd"
  default["chef_client"]["init_style"]  = "bsd"
  default["chef_client"]["run_path"]    = "/var/run"
  default["chef_client"]["cache_path"]  = "/var/chef/cache"
  default["chef_client"]["backup_path"] = "/var/chef/backup"
# don't use bsd paths per COOK-1379
when "mac_os_x","mac_os_x_server"
  default["chef_client"]["init_style"]  = "launchd"
  default["chef_client"]["log_dir"]     = "/Library/Logs/Chef"
  # Launchd doesn't use pid files
  default["chef_client"]["run_path"]    = "/var/run/chef"
  default["chef_client"]["cache_path"]  = "/Library/Caches/Chef"
  default["chef_client"]["backup_path"] = "/Library/Caches/Chef/Backup"
  # Set to "daemon" if you want chef-client to run
  # continuously with the -d and -s options, or leave
  # as "interval" if you want chef-client to be run
  # periodically by launchd
  default["chef_client"]["launchd_mode"] = "interval"
when "openindiana","opensolaris","nexentacore","solaris2"
  default["chef_client"]["init_style"]  = "smf"
  default["chef_client"]["run_path"]    = "/var/run/chef"
  default["chef_client"]["cache_path"]  = "/var/chef/cache"
  default["chef_client"]["backup_path"] = "/var/chef/backup"
  default["chef_client"]["method_dir"] = "/lib/svc/method"
  default["chef_client"]["bin_dir"] = "/usr/bin"
when "smartos"
  default["chef_client"]["init_style"]  = "smf"
  default["chef_client"]["run_path"]    = "/var/run/chef"
  default["chef_client"]["cache_path"]  = "/var/chef/cache"
  default["chef_client"]["backup_path"] = "/var/chef/backup"
  default["chef_client"]["method_dir"] = "/opt/local/lib/svc/method"
  default["chef_client"]["bin_dir"] = "/opt/local/bin"
when "windows"
  default["chef_client"]["init_style"]  = "winsw"
  default["chef_client"]["conf_dir"]    = "C:/etc/chef"
  default["chef_client"]["run_path"]    = "#{node["chef_client"]["conf_dir"]}/run"
  default["chef_client"]["cache_path"]  = "#{node["chef_client"]["conf_dir"]}/cache"
  default["chef_client"]["backup_path"] = "#{node["chef_client"]["conf_dir"]}/backup"
  default["chef_client"]["log_dir"]     = "#{node["chef_client"]["conf_dir"]}/log"
  default["ohai"]["plugins"]            = "#{node["chef_client"]["conf_dir"]}/plugins"
  default["chef_client"]["bin"]         = "C:/opscode/chef/bin/chef-client"
  default["chef_client"]["daemon_options"] = ["--no-fork"]
  #Required for minsw wrapper
  default["chef_client"]["ruby_bin"]    = File.join(RbConfig::CONFIG['bindir'], "ruby.exe")
  default["chef_client"]["winsw_bin"]   = "winsw-1.9-bin.exe"
  default["chef_client"]["winsw_dir"]   = "C:/opscode/chef/bin"
  default["chef_client"]["winsw_exe"]   = "chef-client.exe"
  
else
  default["chef_client"]["init_style"]  = "none"
  default["chef_client"]["run_path"]    = "/var/run"
  default["chef_client"]["cache_path"]  = "/var/chef/cache"
  default["chef_client"]["backup_path"] = "/var/chef/backup"
end

default["chef_client"]["checksum_cache_path"] = "#{node["chef_client"]["cache_path"]}/checksums"