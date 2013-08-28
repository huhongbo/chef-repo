
#create logstash dir
directory node["logstash"]["dir_path"] do
  recursive true
end


remote_directory node["logstash"]["dir_path"] + "/etc" do
  source "etc"
  recursive true
end


directory node["logstash"]["dir_path"] + "/etc" do
  recursive true
end

template node["logstash"]["dir_path"] + "/etc/shipper.conf" do
  source "shipper.conf.erb"
  mode 0755
  not_if {File.exists?("#{node["logstash"]["dir_path"]}/etc/shipper.conf")}
end

if node.os == "linux"
  #cp log.jar file to logstash path
  cookbook_file "#{node["logstash"]["dir_path"]}/log.jar" do
    source "log.jar"
    mode 0755
  end
  cookbook_file "/etc/init.d/logstash" do
    source "logstash"
    mode 0755
  end
else 
  # gem install logstash
  gem_package "logstash" do
    gem_binary "#{node["ruby"]["env_path"]}/gem" if ::File.exist?("#{node["ruby"]["env_path"]}/gem")
    action :install
    options "--no-ri --no-rdoc"
    version "1.1.10"
  end
  cookbook_file "logstash" do
    case node[:platform]
    when "aix"
      path "/etc/init.d/logstash"
    when "hpux"
      path "/sbin/init.d/logstash"
    end
    source "unlinux/logstash"
    mode 0755
  end
end

if node.os == "aix"
  #cp parse.pl to logstash path
  template "#{node["logstash"]["dir_path"]}/parse.pl" do
    source "parse.pl.erb"
    mode 0755
  end
  include_recipe "logstash::cron"
end

if ::File.exist?("/etc/syslog.conf")
  syslog_conf = ::File.read("/etc/syslog.conf")
  unless syslog_conf.include?("10.70.213.133")
    %x[echo "*.warning;mail.none     @10.70.213.133" >> /etc/syslog.conf]
    case node[:platform]
    when "aix"
      execute "restart syslogd" do
        command "refresh -s syslogd"
        action :run 
      end
    when "hpux"
      execute "stop syslogd" do
        command "/sbin/init.d/syslogd stop"
        action :run 
      end
      execute "start syslogd" do
        command "/sbin/init.d/syslogd start"
        action :run 
      end
    else
      service "syslogd" do
        action :restart
      end
    end
  end
end


#start service logstash
service "logstash" do
  if (platform?("hpux"))
    provider Chef::Provider::Service::Hpux
  elsif (platform?("aix")) or node.os == "linux"
    provider Chef::Provider::Service::Init
  end
  #supports :restart => true, :status => true
  action :start
end



