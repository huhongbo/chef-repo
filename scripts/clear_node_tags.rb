#!/usr/bin/env ruby
# code dn365
# v 0.01
# clean node tags
# execute this script "knife exec __FILE_"
print "enter exec tpyes\n"
puts "tag: delete trash tags; role: add sudo"
types = ARGV

def delete_tags(name,tags)
  del_tag = Chef::Knife::TagDelete.new()
  del_tag.name_args[0] = name
  del_tag.name_args[1..-1] = tags
  del_tag.run
end

def add_roles(name,roles)
  add_role = Chef::Knife::NodeRunListAdd.new()
  add_role.name_args[0] = name
  add_role.name_args[1..-1] = [roles]
  add_role.run
end 
puts types[-1]
nodes.all do |n|
  case types[-1]
  when "tag"
    tags = n['tags']
    if tags.size > 1
      del_tags = tags.reject {|value| ["sensu"].include?(value)}
      puts "#{n.hostname} tags: #{del_tags}"
      delete_tags(n.hostname, del_tags)
    end
  when "role"
    if n.os == "aix" || n.os == "hpux"
      unless n.run_list.recipes.include?("sudo")
        puts "add role"
        add_roles(n.hostname,"recipe[sudo]")
      end
    end
  end
end
