#!/usr/bin/env ruby
#
# Sensu GELF Handler
# ===

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'gelf'

class GelfHandler < Sensu::Handler

  def event_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def action_to_string
    @event['action'].eql?('resolve') ? "RESOLVE" : "ALERT"
  end

  def action_to_gelf_level
    #@event['action'].eql?('resolve') ? ::GELF::Levels::INFO : ::GELF::Levels::FATAL
    if @event['action'].eql?('resolve')
      ::GELF::Levels::INFO
    elsif @event['check']['status'].eql?(1)
      ::GELF::Levels::ERROR
    else
      ::GELF::Levels::FATAL
    end
  end

  def handle
    @notifier = ::GELF::Notifier.new(settings['gelf']['server'], settings['gelf']['port'])
    unless @event['check']['name'].eql?('keepalive') && ( @event['check']['status'].eql?(1) || @event['action'].eql?('resolve') )
      gelf_msg = {
        :short_message => "#{action_to_string} - #{event_name}: #{@event['check']['notification']}",
        :full_message  => @event['check']['output'],
        :facility      => 'sensu',
        :level         => action_to_gelf_level,
        :host          => @event['client']['name'],
        :timestamp     => @event['check']['issued'],
        :_address      => @event['client']['address'],
        :_check_name   => @event['check']['name'],
        :_command      => @event['check']['command'],
        :_status       => @event['check']['status'],
        :_flapping     => @event['check']['flapping'],
        :_occurrences  => @event['occurrences'],
        :_action       => @event['action']
      }
      @notifier.notify!(gelf_msg)
    end
  end

end
