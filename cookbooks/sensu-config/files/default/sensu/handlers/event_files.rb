#!/usr/bin/env ruby
#
# This handler create event file.
#
# code dn365
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'

class EventCreate < Sensu::Handler
  
  def action_to_string
    @event['action'].eql?('resolve') ? "RESOLVE" : "ALERT"
  end
  def occurrence_time
    Time.now.strftime("%Y-%m-%d-%H:%M:%S")
  end
  
  def create_file(array)
    file = File.open("/var/html/www/event.txt","w")
    array.each do |content|
      file.puts(content)
    end
    file.close
  end
  
  def handle
    @event['client']['name']
    @event['check']['name']
     #@event['client']['address']
     #@event['occurrences']
    @event['check']['status']
    output = @event['check']['output']
    
    content_array = []
    level = if @event['check']['status'].eql?(2); "CRITICAL"; elsif @event['check']['status'].eql?(1); "Warning" end
    if ["zjjzcj02","zjjzcj01"].include?(@event['client']['name']) and ["cpu","stdev_cpu","keepalive"].include?(@event['check']['name'])
      case @event['check']['name']
      when "keepalive"
        content_array << "#{@event['client']['name']}  #{occurrence_time}  agent_unkeepalive"
      when "cpu"
        content = output.split(":")[-1].strip.split(" ")[0]
        content_array << "#{@event['client']['name']} #{occurrence_time} #{level}-cpu_avg #{content}%"
      when "stdev_cpu"
        content = output.split(":")[-1].strip.split(" ")[0]
        content_array << "#{@event['client']['name']} #{occurrence_time} #{level}-cpu_stdev #{content}%"
      end
    end
    #content_array << "#{@event['client']['name']} #{occurrence_time}"
    create_file(content_array) unless content_array.empty?
  end
  
end