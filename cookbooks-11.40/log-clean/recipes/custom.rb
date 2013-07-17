# Reconstructed Clean Filesystem logs file
# v 0.02
# code dn365
# include clearlog lib
class Chef::Recipe
  include ClearLog
end


nodes = data_bag_item("logs","nodes")

nodes_hash = data_bag_to_hash(nodes)


rm_arry, archive_arry, cat_arry = [],[],[]
stat_run = false
if nodes_hash["#{node.hostname}"]
nodes_hash["#{node.hostname}"].each do |k,v|
  file_path = v["file_path"]
  matches = v["matches"]
  recurse = v["recurse"]
  size = v["file_size"]  
  age = v["age"]    
  operate_type = v["operate_type"]       
  type = v["type"]
  run = v["run"]
  stat_run = true if run
  
  fileage = file_age(age.scan(/h|d|w/)[-1], age.scan(/\d+/)[0])
  filesize = size ? file_size(size.scan(/b|k|m|g|t/)[-1], size.scan(/\d+/)[0]) : nil
  files_arry = []
  if recurse(recurse,file_path)
    recurse(recurse,file_path).each{|path| files_arry << matches(path, matches) }
  end
  
  files_arry = files_arry.flatten
  files_age_arry = files_arry.empty? ? false : files_arry.map {|f| f if (Time.now.to_i - file_time(type, f)) > fileage }
  ungzp_arry =  files_age_arry ? files_age_arry.map {|f| f unless f =~ /^.bz2|gz|zip|tar/ } : []
  
  if files_age_arry
    case operate_type
    when 0
      rm = []
      if filesize
        files_age_arry.map {|f| rm << f if f and (File.size(f) > filesize) }
      else
        rm = files_age_arry
      end
      rm_arry << rm
    when 1
      archive = []
      if filesize
        ungzp_arry.map {|f| archive << f if f and (File.size(f) > filesize) }
      else
        archive = ungzp_arry
      end
      archive_arry << archive
    when 2
      cat = []
      if filesize
        ungzp_arry.map {|f| cat << f if f and (File.size(f) > filesize) }
      else
        cat = ungzp_arry
      end     
      cat_arry << cat
    end
  end
end
end

files_hash = {
  "rm" => rm_arry.flatten.compact,
  "archive" => archive_arry.flatten.compact,
  "cat" => cat_arry.flatten.compact
}

directory "/var/chef/exec" do
  action :create
end

unless files_hash["rm"].empty? && files_hash["archive"].empty? && files_hash["cat"].empty?
  time = Time.now.to_i
  template "/var/chef/exec/clean-log-#{time}.sh" do
    source "clean-log.sh.erb"
    mode 0755
    variables(
      :config_rm => files_hash["rm"],
      :config_archive => files_hash["archive"],
      :config_cat => files_hash["cat"]
      )
  end
  execute "clear logs file" do
    command "sh /var/chef/exec/clean-log-#{time}.sh"
    not_if { stat_run }
  end
end

# if stat_run
#   hold_time = (60 **2)*24*30
#   execute "clear logs file" do
#     command "sh /var/chef/exec/clean-log-#{time}.sh"
#     not_if { ::File.exists?("/var/chef/exec/clean-log-#{time}.sh")}
#   end
# else
#   hold_time = (60 **2)*24*2
# end
hold_time = stat_run ? (60 **2)*24*30 : (60 **2)*24*2
Dir.glob("/var/chef/exec/*.sh").each do |file|
  if (Time.now.to_i - File.mtime(file).to_i) > hold_time
    file "#{file}" do
      action :delete
    end
  end
end

  