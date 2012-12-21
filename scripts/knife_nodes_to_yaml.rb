#!/usr/bin/env ruby

# code dn365
# v 0.02
# create Nodes yaml file
# execute this script "knife exec __FILE_"

require "yaml"
yaml_file_path = "/var/chef/data_yaml"

yaml_arry = []
nodes.all do |n|
  hostname = n.hostname
  os = n.os
  os_version = n.platform_version || ""
  manufacturer = n['dmi']['system'] != nil ? n['dmi']['system']['manufacturer'] : ""
  product_name = n['dmi']['system'] != nil ? n['dmi']['system']['product_name'] : ""
  serial_number = n['dmi']['system'] != nil ? n['dmi']['system']['serial_number'] : ""
  cpu_mhz = n['cpu']['0']['mhz'] || ""
  cpu_model = n['cpu']['0']['model'] || ""
  cpu_vendor_id = n['cpu']['0']['vendor_id'] || ""
  cpu_total = n.cpu.total || ""
  memory = n.memory.total || ""
  ipaddress = n.ipaddress || ""
  uptime = n.uptime || ""
  app_name = "zmcc"
  if n['system'] != nil
   app_name =  n['system']['Business'] ? n['system']['Business'] : "zmcc"
  end
  

  network = n['network']['interfaces'].reject do |key,value|
               ["lo", "lo0", "bond0"].include?(key)
             end
  net_arry = []
  network.each do |key,value|
    if n['network']['interfaces'][key]['addresses'] != nil
      add_arry=[]
      n['network']['interfaces'][key]['addresses'].each do |add,val|
        if add =~ /[A-F\d]{2}:[A-F\d]{2}:[A-F\d]{2}:[A-F\d]{2}:[A-F\d]{2}:[A-F\d]{2}/
          add_arry << add
        end
      end
      net = {
        "#{key}" => {
          "mac" => "#{add_arry}"
        }
      }
      net_arry << net
    end
  end


storage_arry = []
unless n['storage'] == nil
  unless n['storage']['interfaces'] == nil
    n['storage']['interfaces'].each_key do |name|
      a = {
        "#{name}" => {
          "name" => n['storage']['interfaces'][name]['name'],
          "wwn" => n['storage']['interfaces'][name]['wwn'],
          "status" => n['storage']['interfaces'][name]['status']
        }
      }
      storage_arry << a
    end
  end
end
  nodes_base = {
    hostname => {
      "os" => "#{os}",
      "os_version" => "#{os_version}",
      "manufacturer" => "#{manufacturer}",
      "product_name" => "#{product_name}",
      "serial_number" => "#{serial_number}",
      "cpu_mhz" => "#{cpu_mhz}",
      "cpu_model" => "#{cpu_model}",
      "cpu_vendor_id" => "#{cpu_vendor_id}",
      "cpu_total" => "#{cpu_total}",
      "memory" => "#{memory}",
      "ipaddress" => "#{ipaddress}",
      "app_name" => app_name,
      "uptime" => "#{uptime}",
      "storage" => storage_arry,
      "network" => net_arry
    }
  }
  yaml_arry << nodes_base
end

file = File.open("#{yaml_file_path}/data.yaml","w")
yaml_arry.each do |yaml|
  temp = yaml.to_yaml
file.puts(temp.gsub(/---/,""))
end
file.close

