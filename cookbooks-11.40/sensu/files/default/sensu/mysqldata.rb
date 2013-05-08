#!/usr/bin/env ruby
# encoding: UTF-8
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'mysql2'

class MysqlData
  
  def initialize(host,user,passwd,db,port=3306)
    @db = Mysql2::Client.new(:host => "#{host}", :username => "#{user}", :password => "#{passwd}", :port=>port, :database => "#{db}")
  end
  
  def show_data_contact(alert_type)
    alert_name = alert_type
    contact = @db.query("select c.name, c.mobi_phon from contacts c inner join contact_groups d on c.id=d.contact_id  where d.group_id in (SELECT a.group_id FROM sms_groups a inner join  message_sms b on a.message_sm_id=b.id where b.alarm_type='#{alert_name}')")
    
    if contact
      contact_array = []
      contact.each{|c| contact_array << c.values }
      return contact_array.uniq
    else
      return []
    end
  end
  
  def insert_history_sms(name,mobi_phone,node,message,times)
    time = times
    sms_his = @db.query("INSERT INTO sms_his(name,mobi_phone,node,message,created_at,updated_at) VALUES('#{name}','#{mobi_phone}','#{node}','#{message}','#{time}','#{time}')")
  end
end