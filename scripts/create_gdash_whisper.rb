#!/usr/bin/env ruby

# code dn365
# v 0.03
# add users top 5
#
require "rest_client"
require 'json'
#require 'fileutils'
whisp_sources = "http://graphite1.dntmon.com/metrics/index.json"
#gdash_path = "/opt/gdash/graph_templates"
gdash_path = "/opt/chef-server/embedded/service/gdash/graph_templates"

whisp_data = RestClient.get(whisp_sources)

def file_write(title,body)
    file =  File.open("#{title}","w")
    file.write("#{body}")
    file.close
    print "#{title} create success. \n"
end

def mk_dir(dir_name)
  unless File.directory?(dir_name)
    Dir.mkdir(dir_name)
    print "app directory #{dir_name} created success .\n"
  end
end

color_list = ["#2828FF","#73BF00","#AD5A5A","#AE0000","#66B3FF","#009393","#FF79BC","#009100","#D94600","#9F4D95","#9F4D95"]
nodes_gdash_sources = []
test_cour = JSON.parse(whisp_data).group_by{|i| i.split(".")[1] }.map{|dom,value| v_sou = value.map{|i| i.split(".")[3..-1].join(".") unless i.split(".")[2].eql?("all") }.compact; [dom,v_sou] unless %w[carbon uwsgi].include?(dom)}.compact

gdash_sour = Hash.new
test_cour.each do |dom,value|
  gdash_sour[dom] = Hash.new
  value.group_by{|i| i.split(".")[0]}.map{|n,vv| gdash_sour[dom][n] = vv }
end


gdash_sour.each do |dom,v|
  dom_path = gdash_path + "/" + dom
  mk_dir(dom_path)
  v.each do |node,vv|
    host_path = dom_path +"/"+node
    name = node
    mk_dir(host_path)
    # create files
    
    dash = file_write("#{host_path}/dash.yaml",":name: #{name} Metrics\n:description: Hourly metrics for the #{name} system\n")
    
    user_top_cpu = file_write("#{host_path}/cpu_top5.graph","title \"Combined CPU Top 5 Usage\"\nvtitle \"percent\"\narea :none\nymin 0\ndescription \"The combined user CPU Total top 5 usage for all Exim Anti Spam servers\"\ngroup :cpu_top5, :data  => \"highestMax(*.*.#{name}.users.*.cpu_total,5)\", :subgroup => 4\n")
    
    user_top_memoey = file_write("#{host_path}/memory_top5.graph","title \"Combined user memory Top 5 Usage\"\nvtitle \"percent\"\narea :none\nymin 0\ndescription \"The combined user memory Total top 5 usage for all Exim Anti Spam servers\"\ngroup :mem_top5, :data  => \"highestMax(*.*.#{name}.users.*.mem_total,5)\", :subgroup => 4\n")
    
    user_top_count = file_write("#{host_path}/user_count_top5.graph","title \"Combined user count Top 5 Usage\"\nvtitle \"int\"\narea :none\nymin 0\ndescription \"The combined user count Total top 5 usage for all Exim Anti Spam servers\"\ngroup :count_top5, :data  => \"highestMax(*.*.#{name}.users.*.count,5)\", :subgroup => 4\n")

    cpu = file_write("#{host_path}/cpu.graph","title \"Combined CPU Usage\"\nvtitle \"percent\"\narea :none\nymax 100\nymin 0\ndescription \"The combined CPU usage for all Exim Anti Spam servers\"\nfield :wait, :scale => 1, :color => \"red\", :alias => \"Cpu Wait\", :data  => \"*.*.#{name}.cpu.wait\"\nfield :system, :scale => 1, :color => \"orange\", :alias => \"Cpu System\", :data  => \"*.*.#{name}.cpu.sys\"\nfield :user, :scale => 1, :color => \"yellow\", :alias => \"Cpu User\", :data  => \"*.*.#{name}.cpu.user\"\n")
    
    cpu_total = file_write("#{host_path}/cpu_total_used.graph", "title \"Combined CPU Total Used Usage\"\nvtitle \"percent\"\narea :none\nymax 100\nymin 0\ndescription \"The combined CPU Total usage for all Exim Anti Spam servers\"\nfield :total_used, :scale => 1, :color => \"red\", :alias => \"Cpu Total Uesd\", :data => \"*.*.#{name}.cpu.total\"\n")
    
    memory = file_write("#{host_path}/memory.graph","title \"Combined Memory Usage\"\nvtitle \"precent\"\nymax 100\nymin 0\narea :none\nfield :sys, :scale => 1,:color => \"#1d953f\", :alias => \"Memory Sys\", :data  => \"*.*.#{name}.memory.mem_sys\"\nfield :use, :scale => 1,:color => \"#bed742\",:alias => \"Memory used\", :data  => \"*.*.#{name}.memory.mem_used\"\nfield :swap, :scale => 1,:color => \"#d71345\",:alias => \"Swap Used\",:data  => \"*.*.#{name}.memory.swap_used\"\n")
    
    load = file_write("#{host_path}/load.graph", "title \"Combined Load\"\nvtitle \"int\"\narea :first\nfield :loadone, :scale => 1,:color => \"green\",:alias => \"Load One\",:data  => \"*.*.#{name}.load.onemonute\"\nfield :loadfive, :scale => 1,:color => \"#585eaa\", :alias => \"Load Five\", :data  => \"*.*.#{name}.load.fivemonute\"\nfield :loadfifteen, :scale => 1,:color => \"#faa755\",:alias => \"Load Fifteen\",:data  => \"*.*.#{name}.load.fifteenmonute\"\n")

    io = file_write("#{host_path}/disk_io.graph","title \"Combined Disk IO\"\nvtitle \"int\"\narea :none\nfield :disks, :scale => 1,:color => \"blue\",:alias => \"Disk Quantity\",:data  => \"*.*.#{name}.disk.disk_quantity\"\nfield :io, :scale => 1, :color => \"green\", :alias => \"Disk IO\", :data  => \"*.*.#{name}.disk.tps\"\n")
    hba_a = []
    vv.each do |s|
      tmp_s = s.split(".")
      case tmp_s[1]
      when /interface/
        infter_name = tmp_s[2]
        interface = file_write("#{host_path}/interface-#{infter_name}.graph","title \"Combined Network #{infter_name} Usage\"\nvtitle \"Byte\"\narea :none\nfield :networkup, :color => \"green\",:alias => \"Net Out\",:data  => \"*.*.#{name}.interface.#{infter_name}.tx_Bytes\"\nfield :networkdown, :color => \"blue\",:alias => \"Net In\",:data  => \"*.*.#{name}.interface.#{infter_name}.rx_Bytes\"\n")
      when /hba/
        hba_fc_name = tmp_s[2]
        hba_a << hba_fc_name
        hba = file_write("#{host_path}/hba_#{hba_fc_name}.graph","title \"Combined hba #{hba_fc_name} network\"\nvtitle \"MByte\"\narea :none\nfield :rmbs, :scale => 1,:color => \"blue\",:alias => \"Net OUT\",:data  => \"*.*.#{name}.hba.#{hba_fc_name}.rmbs\"\nfield :wmbs, :scale => 1,:color => \"green\",:alias => \"Net IN\",:data  => \"*.*.#{name}.hba.#{hba_fc_name}.wmbs\"\n")
      end
    end
    unless hba_a.empty?
      count = hba_a.map{|hba_name| "field :#{hba_name}, :scale => 1, :alias => \"#{hba_name} Iops\", :data  => \"*.*.#{name}.hba.#{hba_name}.iops\""}
      hba_iops = file_write("#{host_path}/hba_iops.graph","title \"Combined hbas IOPS\"\nvtitle \"int\"\narea :none\n"+count.join("\n"))
    end
  end
end