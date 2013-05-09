#!/usr/bin/env ruby
# delete sensu client log
# code dn365
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'sigar'

class ClearSensuLog < Sensu::Plugin::Check::CLI
  def run
    log_file = "/var/log/sensu-client.log"

    sigar = Sigar.new
    uname = sigar.sys_info.name.downcase

    cat_null = "cat /dev/null > #{log_file}"

    log_size = File.exist?(log_file) ? File.size(log_file).to_f / (1024 ** 2) : 0
    clearlog = system(cat_null) if log_size >= 300
    
    if clearlog
      ok msg = "Clear Sensu Log success"
    else
      if log_size < 300
        ok msg = "Sensu Log < limit value"
      else
        warning msg = "Clear execute false"
      end
    end
  end
end


