#
# Cookbook Name:: sudo
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
# code dn365

# install sudo

case node.os
when "aix"
  remote_directory "/var/chef/pkg" do
    source "aix"
    recursive true
  end
  package "sudo" do
    action :install
    options "-vh"
    source "/var/chef/pkg/sudo-1.6.9p23-2noldap.aix5.3.ppc.rpm"
    provider Chef::Provider::Package::Rpm
  end
when "hpux"
  remote_directory "/var/chef/pkg" do
    source "hpux"
    recursive true
  end
  if node.os_version.include?("11.31")
    if node["cpu"]["0"]["model"] == "Itanium"
      execute "sudo" do
        command "/usr/sbin/swinstall -x mount_all_filesystems=false -s /var/chef/pkg/sudo-1.8.5p2-ia64-11.31.depot sudo"
        not_if { ::File.exist?("/usr/local/bin/sudo")}
      end
    elsif node["cpu"]["0"]["model"].include?("PA RISC")
      execute "sudo" do
        command "/usr/sbin/swinstall -x mount_all_filesystems=false -s /var/chef/pkg/sudo-1.8.5p2-hppa-11.31.depot sudo"
        not_if { ::File.exist?("/usr/local/bin/sudo")}
      end
    end
  elsif node.os_version.include?("11.11")
    execute "sudo" do
      command "/usr/sbin/swinstall -x mount_all_filesystems=false -s /var/chef/pkg/sudo-1.8.5p2-hppa-11.11.depot sudo"
      not_if { ::File.exist?("/usr/local/bin/sudo")}
    end
  end
end

if platform?("hpux") || platform?("aix")  
  template "/etc/sudoers" do
    path "/usr/local/etc/sudoers" if platform?("hpux")
    source "sudoers.erb"
    mode 0440
    owner "root"
    group platform?("hpux") ? "sys" : "system"
    variables(
      :sudoers_groups => node["sudo"]["groups"],
      :sudoers_users => node["sudo"]["users"],
      :passwordless => node["sudo"]["passwordless"]
      )
  end
end
