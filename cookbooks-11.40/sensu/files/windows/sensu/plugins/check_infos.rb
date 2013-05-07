#
# code dn365
# v 0.01
# check file system and processes to windows

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require "ruby-wmi"
require "ohai/mash"
#require 'sigar'

$VERBOSE = nil
class CheckProc < Sensu::Plugin::Check::CLI
  option :proc,
    :short => '-p',
    :long => '--proc',
    :description => 'Mix proc warring'
  option :file,
      :short => '-f',
      :long => '--file',
      :description => 'Windows Disk utilization'
  option :critical,
    :short => '-c',
    :long => '--critical=VALUE',
    :description => 'Critical threshold Procent 0 -- 100',
    :default => 95
  option :warning,
    :short => '-w',
    :long => '--warning=VALUE',
    :description => 'Warning threshold Procent 0 -- 100',
    :default => 90
  option :help,
    :short => "-h",
    :long => "--help",
    :description => "Check usage",
    :on => :tail,
    :boolean => true,
    :show_options => true,
    :exit => 0
    
    def sprintf_int(num,intnum=1)
      return num.nil? ? 0 : sprintf("%.0f", num.to_i * intnum)
    end
    
    def files_value
      diskfile = Mash.new
      disks = WMI::Win32_LogicalDisk.find(:all)
      disks.each do |disk|
        if disk.DeviceID != "A:" and !disk.Size.to_i.eql?(0)
          name = disk.DeviceID
          diskfile[name] = Mash.new
          total = disk.Size.to_i / (1000 * 1000)
          free = disk.FreeSpace.to_i / (1000 * 1000)
          used_prec = 100 - free.to_f/total*100
          diskfile[name]['free'] = free
          diskfile[name]['uesd'] = used_prec
        end
      end
      return diskfile
    end
    
    
    def user_proc
      process = WMI::Win32_Process.find(:all)
      proc_total = process.size
      return  proc_total
    end
    
    def run
      crit_value = config[:critical].to_i
      warn_value = config[:warning].to_i
      
     if config[:proc]
       proc = user_proc
       max_process = 10000
       proc_prec = proc.to_f / max_process * 100
       if proc_prec >= crit_value
         critical msg = "process more than #{max_process}, Current number of #{proc}"
       elsif proc_prec >= warn_value
         warning msg = "process more than latter, Current number of #{proc}"
       else
         ok msg = "It's ok, value #{proc}"
       end
       #user_proc(crit_value,warn_value)
     elsif config[:file]
       disks = files_value
       cri_a,war_a,ok_a = [],[],[]
       disks.each do |name,value|
         #p value["uesd"]
         if value["uesd"] >= crit_value
           cri_a << "#{name} disk uesd #{sprintf_int(value["uesd"])}%, disk free #{value["free"]}M"
           #critical msg = "#{name} disk uesd #{sprintf_int(value["uesd"])}%, disk free #{value["free"]}M"
         elsif value["uesd"] >= warn_value
           war_a << "#{name} disk uesd #{sprintf_int(value["uesd"])}%, disk free #{value["free"]}M"
           #warning msg = "#{name} disk uesd #{sprintf_int(value["uesd"])}%, disk free #{value["free"]}M"
         else
           ok_a << name
           #ok msg = name
         end
       end
       if !cri_a.empty?
         critical msg = "Critical: " + cri_a.join(";")
       elsif !war_a.empty?
         warning msg = "Warning: " + war_a.join(";")
       else
         ok msg = "It's ok: " + ok_a.join(";")
      end
     else
       unknown msg = "Not find, please -h"
     end    
  end
end