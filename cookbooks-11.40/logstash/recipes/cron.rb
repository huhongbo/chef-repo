cron "aix-logstat-cron" do
  if platform?("aix") or platform?("hpux")
    provider Chef::Provider::Cron::Solaris
  end
  command "\* \* \* \* \* /opt/logstash/parse.pl > /opt/logstash/errpt.log 2>&1"
end