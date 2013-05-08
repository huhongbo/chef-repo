#!/usr/bin/env ruby
#
# code dn365
# v 0.02
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'sigar'

class CheckSystem < Sensu::Plugin::Check::CLI
  option :filesystem,
    :short => '-f',
    :long => '--file',
    :description => 'File system used precent warnning'
  option :memory,
    :short => '-m',
    :long => '--memory',
    :description => 'Memory used precent warnning'
  option :swap,
    :short => '-s',
    :long => '--swap',
    :description => 'Swap used 98% warnning'
  option :critical,
    :short => '-c',
    :long => '--critical=VALUE',
    :description => 'Critical threshold',
    :default => 95
  option :warning,
    :short => '-w',
    :long => '--warning=VALUE',
    :description => 'Warning threshold',
    :default => 90
  option :help,
    :short => "-h",
    :long => "--help",
    :description => "Check usage",
    :on => :tail,
    :boolean => true,
    :show_options => true,
    :exit => 0
    
     
    def sprintf_int(num)
      num = 0 unless num
      value = sprintf("%.0f", num)
      return value.to_i
    end
    def files_system_used(os,mount,size,used,free,crit_value,warn_value)
      case os
      when /linux|aix/
        filesys = %x[df -m]
      when /hpux/
        filesys = %x("bdf")
      end
      
      file,message = [],[]
      filesys.each_line {|f| file << f }
      
      file[1..-1].each do |f|
        mount_name = f.split(" ")[mount]
        disk_used = f.split(" ")[used].to_i
        case os
        when /linux|aix/
          disk_size = f.split(" ")[size].to_i
          disk_free = f.split(" ")[free].to_i
        when /hpux/
          disk_size = sprintf_int(f.split(" ")[size].to_i.to_f / 1024)
          disk_free = sprintf_int(f.split(" ")[free].to_i.to_f / 1024)
        end
        
        micro_par = 5
        unless mount_name =~ /\/dev|db2|oradata|dbdata|media|proc/
            unless mount_name =~ /arch/
              if disk_size > 2048
                if disk_free <= 2048 && disk_used > warn_value && disk_free > 1024
                  message << "warning:#{mount_name} used:#{disk_used}% free:#{disk_free}MB"
                elsif disk_free <=1024 && disk_used >warn_value
                  message << "critical:#{mount_name} used:#{disk_used}% free:#{disk_free}MB"
                end
              else
                if disk_used > warn_value
                  message << "warning:#{mount_name} used:#{disk_used}%"
                elsif disk_used > crit_value
                  message << "critical:#{mount_name} used:#{disk_used}%"
                end     
              end
            else
              if disk_size > 2048
                if disk_free <= 2048 && disk_used > (warn_value - micro_par) && disk_free > 1024
                  message << "warning:#{mount_name} used:#{disk_used}% free:#{disk_free}MB"
                elsif disk_free <=1024 && disk_used > (warn_value - micro_par)
                  message << "critical:#{mount_name} used:#{disk_used}% free:#{disk_free}MB"
                end
              else
                if disk_used > (warn_value - micro_par)
                  message << "warning:#{mount_name} used:#{disk_used}%"
                elsif disk_used > (crit_value - micro_par)
                  message << "critical:#{mount_name} used:#{disk_used}%"
                end
              end
            end
        end
      end
        warning_count,critical_count = [],[]
        message.each do |m|     
          warning_count << m.sub(/warning:(.*)/,'\1') if m.include?("warning")
          #ok_count << m.sub(/ok:(.*)/,'\1') if m.include?("ok")
          critical_count << m.sub(/critical:(.*)/,'\1') if m.include?("critical")
        end
        if !critical_count.empty?
          critical msg = "#{critical_count[0..-1].join("; ")}"
        elsif !warning_count.empty?
          warning msg = "#{warning_count[0..-1].join("; ")}"
        else
          ok msg = "OK"
        end
    end
    
    
    def memory_used(sys_type,free,po,crit_value,warn_value)
      sigar = Sigar.new
      vmstat = %x[vmstat | tail -n1]
      mem = sigar.mem

      mem_actual = mem.actual_used.to_f
      case sys_type
      when "aix","linux"
        mem_precent = sprintf_int((mem_actual.to_f / mem.total)*100)
      when "hpux"
        mem_precent = sprintf_int((mem.used.to_f / mem.total)*100)
      end
      mem_free = sprintf_int(vmstat.split(" ")[free].to_i.to_f / 1024)
      swap_po = vmstat.split(" ")[po].to_i
      #return mem_precent,swap_precent,mem_free,swap_so
      #puts "mem:#{mem_actual / (1024*1024) } free:#{mem_free}"
      #
      if (mem_precent >= warn_value) && (mem_free <= 400) && (swap_po >= 400)
        critical msg = "Memory:#{mem_precent}%; free:#{mem_free}MB"
      elsif (mem_precent >= warn_value) && (mem_free <= 400) && (swap_po >= 100)
        warning msg = "Memory: #{mem_precent}%; free:#{mem_free}MB"
      else
        ok msg = "Memory: #{mem_precent}%; free:#{mem_free}MB"
      end 
    end

    def swap_used(crit_value,warn_value)
      sigar = Sigar.new
      swap = sigar.swap
      swap_precent = sprintf_int(swap.used / swap.total).to_i

      if swap_precent >= crit_value
        critical msg = "Swap: #{swap_precent}%"
      elsif swap_precent >= warn_value
        warning msg = "Swap: #{swap_precent}%"
      else
        ok msg = "Swap: #{swap_precent}%"
      end
    end
    
    def run
      sigar = Sigar.new
      uname = sigar.sys_info.name.downcase
      crit_value = config[:critical].to_i
      warn_value = config[:warning].to_i
      
      if config[:filesystem]
          case uname
          when /linux/
            files_system_used("linux",5,1,4,3,crit_value,warn_value)
          when /aix/
            files_system_used("aix",6,1,3,2,crit_value,warn_value)
          when /hpux/
            files_system_used("hpux",5,1,4,3,crit_value,warn_value)
          end
      elsif config[:memory]
          case uname
          when /linux/
            memory_used("linux",4,7,crit_value,warn_value)
          when /aix/
            memory_used("aix",3,6,crit_value,warn_value)
          when /hpux/
            memory_used("hpux",4,8,crit_value,warn_value)
          end
      elsif config[:swap]
        swap_used(crit_value,warn_value)
      else
        unknown msg = "Not find -c crit or -w warn, please -h "
      end
              
    end 
end