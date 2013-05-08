#!c:/opscode/chef/embedded/bin/ruby.exe

require "optparse"
require 'net/http'

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = 'here is help messages of the command line tool.'
  options[:nt4] = false
  opts.on('-t','--true','Win nt4 Set options as switch') do
    options[:nt4] = true
  end

  opts.on('-s SERVER', '--server Chef-server', 'Pass-in Chef Server Hostname') do |value|
    options[:host] = value
  end
  
  opts.on('-i ipaddress', '--ip Ipaddress', 'Pass-in Chef Server ipaddress') do |value|
    options[:ip] = value
  end

end.parse!



def write_hosts(ip,hostname,switch=false)
  
  default_host_path = "C:/Windows/System32/drivers/etc"
  if switch
    default_host_path = "C:/WINDOWS/system32/drivers/etc"
  end
  
  host_r = File.read("#{default_host_path}/hosts")
  #p host_r
  if switch
    host_f = File.open("#{default_host_path}/hosts","w")
  else
    host_f = File.open("#{default_host_path}/hosts_bak","w")
  end
  host_f.puts(host_r)
  host_f.puts("#{ip} #{hostname}") unless host_r.include?("#{ip} #{hostname}")
  host_f.puts("#{ip} infoboard.dntmon.com") unless host_r.include?("infoboard.dntmon.com")
  host_f.close
  unless switch
    system("cd #{default_host_path} && MOVE /Y hosts_bak hosts")
  end
end

#p options

if options[:host] and options[:ip]
  
  write_hosts(options[:ip],options[:host], options[:nt4])
  
  files_domian = "infoboard.dntmon.com"
  file_key = "validation.pem"
  url = URI("http://#{files_domian}/files/pem_key/chef-validator.txt")
  content = Net::HTTP.get(url)
  
  system("C:/opscode/chef/bin/knife.bat configure client c:/etc/chef")
  
  vk = File.open("C:/etc/chef/#{file_key}","w")
  vk.puts(content)
  vk.close
  
  # write client.rb
  client_con = "log_level :info
log_location STDOUT
chef_server_url  'https://#{options[:host]}'
validation_client_name 'chef-validator'
file_backup_path 'C:/etc/chef/backup'
file_cache_path 'C:/etc/chef/cache'
validation_key  'c:/etc/chef/validation.pem'
client_key  'c:/etc/chef/client.pem'
cache_options ({:path => 'c:/etc/chef/cache/checksums', :skip_expires => true})"

  cl = File.open("C:/etc/chef/client.rb","w")
  cl.puts(client_con)
  cl.close

  #run chef-client
  
  system("C:/opscode/chef/bin/chef-client.bat -c C:/etc/chef/client.rb --no-fork -o role[default_client]")

else
  print "Please reset chef server hostname and ipaddress\n"
end


