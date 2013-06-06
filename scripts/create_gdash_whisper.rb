#!/usr/bin/env ruby

# code dn365
# v 0.02
# add users top 5

#require 'fileutils'
whisp_path = "/opt/graphite/storage/whisper"
gdash_path = "/opt/gdash/graph_templates"

def file_write(title,body)
  unless File.exist?(title)
   file =  File.open("#{title}","w")
   file.write("#{body}")
   file.close
   print "#{title} create success. \n"
  else
   print "File #{title} exist ... \n"
  end
end

def mk_dir(dir_name)
  unless File.directory?(dir_name)
    Dir.mkdir(dir_name)
    print "app directory #{dir_name} created success .\n"
  else
    print "app dirrctory #{dir_name} exist ..\n"
  end
end


Dir["#{whisp_path}/*"].each do |app|
  unless app.include?("carbon")
    app_name = app.split("/")[-1]
    mk_dir("#{gdash_path}/#{app_name}")
    Dir["#{app}/*"].each do |c|
      host_name = c.split("/")[-1]
      host_dir = "#{gdash_path}/#{app_name}/#{host_name}"
      graphite_url = "#{app_name}.#{host_name}"
      mk_dir("#{gdash_path}/#{app_name}/#{host_name}")
      dash = file_write("#{host_dir}/dash.yaml",":name: #{host_name} Metrics
:description: Hourly metrics for the #{host_name} system\n")
      Dir["#{c}/system/*"].each do |sys|
        cname = sys.split("/")[-1]
        case cname
        when "users"
          user_top_cpu = file_write("#{host_dir}/cpu_top5.graph","title \"Combined CPU Top 5 Usage\"
vtitle \"percent\"
area :none
ymin 0
description \"The combined user CPU Total top 5 usage for all Exim Anti Spam servers\"

group :cpu_top5, :data  => \"highestMax(#{graphite_url}.system.users.*.cpu_total,5)\",
          :subgroup => 4")
          user_top_memoey = file_write("#{host_dir}/memory_top5.graph","title \"Combined user memory Top 5 Usage\"
vtitle \"percent\"
area :none
ymin 0
description \"The combined user memory Total top 5 usage for all Exim Anti Spam servers\"

group :mem_top5, :data  => \"highestMax(#{graphite_url}.system.users.*.mem_total,5)\",
          :subgroup => 4")
          user_top_count = file_write("#{host_dir}/user_count_top5.graph","title \"Combined user count Top 5 Usage\"
vtitle \"int\"
area :none
ymin 0
description \"The combined user count Total top 5 usage for all Exim Anti Spam servers\"

group :count_top5, :data  => \"highestMax(#{graphite_url}.system.users.*.count,5)\",
          :subgroup => 4")
        when "cpu"
          cpu = file_write("#{host_dir}/cpu.graph","title \"Combined CPU Usage\"
vtitle \"percent\"
area :none
ymax 100 
ymin 0
description \"The combined CPU usage for all Exim Anti Spam servers\"

field :wait, :scale => 1,
              :color => \"red\",
              :alias => \"Cpu Wait\",
              :data  => \"#{graphite_url}.system.cpu.wait\"

field :system, :scale => 1,
              :color => \"orange\",
              :alias => \"Cpu System\",
              :data  => \"#{graphite_url}.system.cpu.sys\"

field :user, :scale => 1,
            :color => \"yellow\",
            :alias => \"Cpu User\",
            :data  => \"#{graphite_url}.system.cpu.user\"\n")
            cpu_total_used = file_write("#{host_dir}/cpu_total_used.graph", "title \"Combined CPU Total Used Usage\"
vtitle \"percent\"
area :none
ymax 100 
ymin 0
description \"The combined CPU Total usage for all Exim Anti Spam servers\"

field :total_used, :scale => 1,
                  :color => \"red\",
                  :alias => \"Cpu Total Uesd\",
                  :data  => \"sumSeries(#{graphite_url}.system.cpu.sys,#{graphite_url}.system.cpu.user,#{graphite_url}.system.cpu.wait)\"\n")

        when "memory"
          memory = file_write("#{host_dir}/memory.graph","title \"Combined Memory Usage\"
vtitle \"precent\"
ymax 100 
ymin 0
area :none

field :sys, :scale => 1,
          :color => \"#1d953f\",
          :alias => \"Memory Sys\",
          :data  => \"#{graphite_url}.system.memory.mem_sys\"
field :use, :scale => 1,
          :color => \"#bed742\",
          :alias => \"Memory used\",
          :data  => \"#{graphite_url}.system.memory.mem_used\"
field :swap, :scale => 1,
            :color => \"#d71345\",
            :alias => \"Swap Used\",
            :data  => \"#{graphite_url}.system.memory.swap_used\"\n")
        when "load"
          load = file_write("#{host_dir}/load.graph", "title \"Combined Load\"
vtitle \"int\"
area :first

field :loadone, :scale => 1,
              :color => \"green\",
              :alias => \"Load One\",
              :data  => \"#{graphite_url}.system.load.onemonute\"
field :loadfive, :scale => 1,
                :color => \"#585eaa\",
                :alias => \"Load Five\",
                :data  => \"#{graphite_url}.system.load.fivemonute\"
field :loadfifteen, :scale => 1,
                  :color => \"#faa755\",
                  :alias => \"Load Fifteen\",
                  :data  => \"#{graphite_url}.system.load.fifteenmonute\"\n")
        when "hba"
          color_list = ["#2828FF","#73BF00","#AD5A5A","#AE0000","#66B3FF","#009393","#FF79BC","#009100","#D94600","#9F4D95","#9F4D95"]
          hba_name, hba_i = [], 0
          Dir["#{sys}/*"].each do |n|
            hba_i += 1
            hba_fc_name = n.split("/")[-1]
            hba_name << hba_fc_name
            #graphite_hba_url = "#{graphite_url}.#{hba_fc_name}"
            hba = file_write("#{host_dir}/hba_#{hba_fc_name}.graph","title \"Combined hba #{hba_fc_name} network\"
vtitle \"MByte\"
area :none

field :rmbs, :scale => 1,
            :color => \"blue\",
            :alias => \"Net OUT\",
            :data  => \"#{graphite_url}.system.hba.#{hba_fc_name}.rmbs\"
field :wmbs, :scale => 1,
          :color => \"green\",
          :alias => \"Net IN\",
          :data  => \"#{graphite_url}.system.hba.#{hba_fc_name}.wmbs\"\n")          
          end
          puts count = (0..(hba_i.to_i - 1)).map {|x| "field :#{hba_name[x]}, :scale => 1, :color => \"#{color_list[x]}\", \n:alias => \"#{hba_name[x]} Iops\", :data  => \"#{graphite_url}.system.hba.#{hba_name[x]}.iops\""}
          hba_iops = File.open("#{host_dir}/hba_iops.graph","w")
          hba_iops.puts("title \"Combined hbas IOPS\"
vtitle \"int\"
area :none")
hba_iops.puts(count)
hba_iops.puts("\n")
hba_iops.close
        when "interface"
          Dir["#{sys}/*"].each do |n|
            infter_name = n.split("/")[-1]
            unless ["lo","lo0","bond0"].include?(infter_name)
              interface = file_write("#{host_dir}/interface-#{infter_name}.graph","title \"Combined Network #{infter_name} Usage\"
vtitle \"Byte\"
area :none

field :networkup, :color => \"green\",
              :alias => \"Net Out\",
              :data  => \"#{graphite_url}.system.interface.#{infter_name}.tx_Bytes\"

field :networkdown, :color => \"blue\",
                  :alias => \"Net In\",
                  :data  => \"#{graphite_url}.system.interface.#{infter_name}.rx_Bytes\"\n")
            end
          end
        when "disk"
          io = file_write("#{host_dir}/disk_io.graph","title \"Combined Disk IO\"
vtitle \"int\"
area :none

field :disks, :scale => 1,
            :color => \"blue\",
            :alias => \"Disk Quantity\",
            :data  => \"#{graphite_url}.system.disk.disk_quantity\"
field :io, :scale => 1,
          :color => \"green\",
          :alias => \"Disk IO\",
          :data  => \"#{graphite_url}.system.disk.tps\"\n")
        end 
      end
    end
  end
end