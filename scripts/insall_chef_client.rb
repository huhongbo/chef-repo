#!/usr/bin/env ruby
# code dn365
# v 0.1
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
  host_w.puts("#{ip} #{hostname}") unless host_r.include?("#{ip} #{hostname}")
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
  
  gem_bin = "gem"
  if (gem_bin_path=%x{which gem}.chomp) && File.executable?(gem_bin_path)
    gem_bin = gem_bin_path
  end
  gem_s = system("#{gem_bin} sources -l")
  #unless gem_s.include?("gemserver")
    system("#{gem_bin} sources -a http://gemserver/")
    system("#{gem_bin} sources -r http://rubygems.org/")
    system("#{gem_bin} sources -r https://rubygems.org/")
    #end
  
  client_bin = "chef-client"
  if (chef_in_path=%x{which chef-client}.chomp) && File.executable?(chef_in_path)
    client_bin = chef_in_path
  end
  
  system("#{client_bin} -S https://#{options[:ip]} -o role[default_client]")
else
  print "Please reset chef server hostname and ipaddress\n"
end
  
