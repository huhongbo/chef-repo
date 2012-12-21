#!/usr/bin/env ruby
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'oci8'

class DataBaseApi

  def wg_alarm(policy_id,title,desc,dev_ip,module_name,time_stamp=Time.now,instance_id="",class_name="plat",severity=3,obj_type="DEVICE",event_type="Threshold")
    wg_username = "bomc"
    wg_username = "bomc"
    wg_tnsname = "openview"
    username = "mon"
    password = "mon"
    tnsname = "zjmon"
    conn = OCI8.new(username,password,tnsname)
    conn1 = OCI8.new(wg_username,wg_password,wg_tnsname)
    conn.exec %q{alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS'}
    conn1.exec %q{alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS'}
    unless title.length < 128
      puts "Error!Title must be less than 128.\n"
      exit
    end
    unless desc.length < 256
      puts "Error!Description must be less than 256.\n"
      exit
    end
    cursor = conn.parse("INSERT INTO ALERT_HIS (TIME,ALERT,SRC,GRP,PRI)VALUES(TO_DATE(:1,'yyyy-mm-dd hh24:mi:ss'),:2,:3,:4,:5)")
    cursor.bind_param(1,time_stamp.strip)
    cursor.bind_param(2,title)
    cursor.bind_param(3,dev_ip)
    cursor.bind_param(4,class_name)
    cursor.bind_param(5,severity)
    begin
      result = cursor.exec()
      if result > 0
        cursor1 = conn1.parse("INSERT INTO IPTFA_ALARM_MSG_ZJ (ALARM_ID,POLICY_ID,TITLE,CLASS,SEVERITY,DESCRIPTION,TIME_STAMP,DEV_IP,OBJTYPE,INSTANCE_ID,EVENT_TYPE,MODULE_NAME)VALUES(SEQ_IPTFA_ALARM_MSG_ZJ.nextval,:1,:2,:3,:4,:5,TO_DATE(:6,'yyyy-mm-dd hh24:mi:ss'),:7,:8,:9,:10,:11)")
        cursor1.bind_param(1,policy_id)
        cursor1.bind_param(2,title)
        cursor1.bind_param(3,class_name)
        cursor1.bind_param(4,severity)
        cursor1.bind_param(5,desc)
        cursor1.bind_param(6,time_stamp)
        cursor1.bind_param(7,dev_ip)
        cursor1.bind_param(8,obj_type)
        cursor1.bind_param(9,instance_id)
        cursor1.bind_param(10,event_type)
        cursor1.bind_param(11,module_name)
        result = cursor1.exec()
        if result > 0
          puts "#{title} has alarmed successfully!"
        else
          puts "#{title} has alarmed failed!"
        end
      end
    rescue
      puts "insert alarm table error"
    end
    cursor.close
    cursor1.close
    conn.commit
    conn1.commit
    conn.logoff
    conn1.logoff
  end

  def alarm(alert,src,time=Time.now,grp="SYS",pri=3)
    username = "mon"
    password = "mon"
    tnsname = "zjmon"
    time=DateTime.parse(time.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s
    conn = OCI8.new(username,password,tnsname)
    conn.exec %q{alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS'}
    cursor = conn.parse("INSERT INTO ALERT_HIS (TIME,ALERT,SRC,GRP,PRI)VALUES(TO_DATE(:1,'yyyy-mm-dd hh24:mi:ss'),:2,:3,:4,:5)")
    puts alert,src,time,grp,pri
    cursor.bind_param(1,time.strip)
    cursor.bind_param(2,alert.strip)
    cursor.bind_param(3,src.strip)
    cursor.bind_param(4,grp.strip)
    cursor.bind_param(5,pri)
    result = cursor.exec()
    cursor = conn.parse("SELECT b.tele_num FROM DBA_INFO b,alert_info a,sys_info c WHERE a.dept=b.dept and a.g_name=c.g_name and c.m_name=:1")
    cursor.bind_param(1,src.strip)
    result = cursor.exec()
    while r = cursor.fetch()
      cursor1 = conn.parse("INSERT INTO APP_SM VALUES('188',:1,:2)")
      cursor1.bind_param(1,r[0])
      cursor1.bind_param(2,alert.strip)
      begin
        result = cursor1.exec()
      rescue
        puts "insert sms table error"
      end
    end
    cursor.close
    conn.commit
    conn.logoff
  end
  
  def insert_alarm_history(alert,src,time=Time.now,grp="SYS",pri=3)
    username = "mon"
    password = "mon"
    tnsname = "zjmon"
    time=DateTime.parse(time.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s
    conn = OCI8.new(username,password,tnsname)
    cursor = conn.parse("INSERT INTO ALERT_HIS (TIME,ALERT,SRC,GRP,PRI)VALUES(TO_DATE(:1,'yyyy-mm-dd hh24:mi:ss'),:2,:3,:4,:5)")
    puts alert,src,time,grp,pri
    cursor.bind_param(1,time.strip)
    cursor.bind_param(2,alert.strip)
    cursor.bind_param(3,src.strip)
    cursor.bind_param(4,grp.strip)
    cursor.bind_param(5,pri)
    begin
      result = cursor.exec()
    rescue
      puts "insert sms table error"
    end
    cursor1.close
    conn.commit
    conn.logoff
  end
  
  def insert_alarm_table(array=[])
    username = "mon"
    password = "mon"
    tnsname = "zjmon"
    #tnsnames = '(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = somehost.somedomain.com)(PORT = 1521)) (CONNECT_DATA = (SID = zjmon)))'
    conn = OCI8.new(username,password,tnsname)
    r = array
    cursor1 = conn.parse("INSERT INTO APP_SM VALUES('188',:1,:2)")
    cursor1.bind_param(1,r[0])
    cursor1.bind_param(2,r[1])
    begin
      result = cursor1.exec()
    rescue
      puts "insert sms table error"
    end
    cursor1.close
    conn.commit
    conn.logoff
  end
end
#alarm "test","zmbc4"
