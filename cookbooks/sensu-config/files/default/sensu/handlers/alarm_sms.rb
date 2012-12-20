#!/usr/bin/env ruby
#
# This handler create event file.
#
# code dn365
#
# encoding: UTF-8
ENV['ORACLE_HOME']="/usr/lib/oracle/11.2/client64"
ENV['TNS_ADMIN']="/usr/lib/oracle/11.2/client64/network/admin"
ENV['NLS_LANG']="American_America.zhs16gbk"
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
#require 'sqlite3'
require '/etc/sensu/sms'
#require '/etc/sensu/sqlitedata'
require '/etc/sensu/mysqldata'

class AlarmSms < Sensu::Handler
  
  def action_to_string
    @event['action'].eql?('resolve') ? "RESOLVE" : "ALERT"
  end
  def occurrence_time
    Time.now.strftime("%m%d %H:%M")
  end
  
  def handle
    data = MysqlData.new("127.0.0.1","root","passw0rd","dashboard_production")
    #if action_to_string.eql?("ALERT") and !@event['check']['name'].eql?('keepalive') and @event['check']['status'].eql?(2)   
    unless action_to_string.eql?("RESOLVE") or @event['check']['name'].eql?('keepalive') or !@event['check']['status'].eql?(2)
      
      alert_type = @event['check']['name']
      output = @event['check']['output'].split(":")[1..-1].join(" ").strip
      contact_array = data.show_data_contact(alert_type)
      time = occurrence_time
      
      sms_alert_array = []
      sms_his_array = []
      sms_time = Time.now
      contact_array.each do |contact|
        sms_alert_array << ["#{contact[1]}","#{@event['client']['name']} #{time} #{output}"]
        sms_his_array << ["#{contact[0]}","#{contact[1]}","#{@event['client']['name']}","#{@event['client']['name']} #{time} #{output}"]
      end
      
      sms_alert_array.each do |s|
        sms = DataBaseApi.new
        #puts "xxxxxx #{s.to_s}"
        sms.insert_alarm_table(s)
        puts "insert #{s.to_s} success!"
      end
      
      sms_his_array.each do |x|
        data.insert_history_sms("#{x[0]}","#{x[1]}","#{x[2]}","#{x[3]}","#{sms_time}")
        puts "insert hist #{x.to_s} #{sms_time} success!"
      end
    end
  end
  
end