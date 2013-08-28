#!/usr/bin/env ruby
# code dn365
# v 0.2
# install chef client v 11.40

require "optparse"
require 'net/http'

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = 'here is help messages of the command line tool.'
  
  opts.on('-s SERVER', '--server Chef-server', 'Pass-in Chef Server Hostname') do |value|
    options[:host] = value
  end
  
  opts.on('-i ipaddress', '--ip Ipaddress', 'Pass-in Chef Server ipaddress') do |value|
    options[:ip] = value
  end

end.parse!

def write_hosts(ip,hostname)
  host_path = "/etc/hosts"
  
  host_r = File.read(host_path)
  host_w = File.open(host_path,"w")
  host_w.puts(host_r)
  host_w.puts("#{ip} #{hostname}")
  host_w.puts("#{ip} infoboard.dntmon.com") unless host_r.include?("infoboard.dntmon.com")
  host_w.puts("#{ip} gemserver") unless host_r.include?("gemserver")
  host_w.close
end

if options[:host] and options[:ip]
  write_hosts(options[:ip],options[:host])
  
  files_domian = "infoboard.dntmon.com"
  file_key = "validation.pem"
  url = URI("http://#{files_domian}/files/pem_key/chef-validator.txt")
  content = Net::HTTP.get(url)
  
  system("mkdir -p /etc/chef")
  
  vk = File.open("/etc/chef/#{file_key}","w")
  vk.puts(content)
  vk.close
  os_type = %x(uname)
  case os_type.to_s
  when /HP-UX/
    bin_path = "/usr/local/ruby1.9/bin"
    gem_bin = "#{bin_path}/gem"
    client_bin = "#{bin_path}/chef-client"
  when /AIX/
    bin_path = "/opt/freeware/ruby1.9/bin"
    gem_bin = "#{bin_path}/gem"
    client_bin = "#{bin_path}/chef-client"
  when /Linux/
    bin_path = "/usr/bin"
    bin_path = "/opt/chef/embedded/bin" if File.directory?("/opt/chef/embedded/bin")
    gem_bin = "#{bin_path}/gem"
    client_bin = "/opt/chef/bin/chef-client"
  else
    gem_bin = "gem"
    client_bin = "chef-client"
  end
  
  
  
  #gem_s = system("#{gem_bin} sources -l").to_s
  #unless gem_s.include?("gemserver")
  #system("#{gem_bin} uninstall -aIx ohai")
  system("#{gem_bin} sources -a http://gemserver/")
  system("#{gem_bin} sources -r http://rubygems.org/")
  system("#{gem_bin} sources -r https://rubygems.org/")
  #system("#{gem_bin} install ohai")
  system("#{gem_bin} install sigar --no-ri --no-rdoc")
  system("#{gem_bin} install chef --no-ri --no-rdoc")
  #end
  
  system("#{client_bin} -S https://#{options[:ip]} -o role[default_client]")
else
  print "Please reset chef server hostname and ipaddress\n"
end
  
