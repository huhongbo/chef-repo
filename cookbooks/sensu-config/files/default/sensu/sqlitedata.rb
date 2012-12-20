#!/usr/bin/env ruby
# encoding: UTF-8
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sqlite3'
class SqlitData
  
  def initialize(data_path_name)
    @data_base_file = data_path_name
    @db = SQLite3::Database.new(@data_base_file)
  end
  
  def sqlite_data_contact(alert_type)
    begin
      alert_name = alert_type
  #content sqlite databases
      
  # find contact info (name mobiphone)
      contacts = @db.execute("select c.name, c.mobi_phon from contacts c inner join contact_groups d on c.id=d.contact_id  where d.group_id in (SELECT a.group_id FROM sms_groups a inner join  message_sms b on a.message_sm_id=b.id where b.alarm_type='#{alert_name}')")
    
      return contacts.uniq
    
    rescue SQLite3::CantOpenException => e
      print "***********My God, open db error **********\n"
      puts e
    end
    
  end

  def insert_history_sms(name,mobi_phone,node,message,times)
    time = times
    sms_his = @db.execute("INSERT INTO sms_his(name,mobi_phone,node,message,created_at,updated_at) VALUES('#{name}','#{mobi_phone}','#{node}','#{message}','#{time}','#{time}');COMMIT;")
    #sms_his.close
  end
end