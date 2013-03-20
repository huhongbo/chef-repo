#!/usr/bin/env ruby
#
# code dn365
# v 0.02

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require "open-uri"
require "yajl"

$VERBOSE = nil
class CheckGraph < Sensu::Plugin::Check::CLI

  option :base_url,
    :short => '-u',
    :long => '--url=VALUE',
    :description => 'Graphite base url',
    :default => 'http://graphite.zj.chinamobile.com:8080'
  option :time,
    :short => '-s=VALUE',
    :long => '--seconds',
    :description => 'set from time seconds'
  option :rand_time,
    :short => '-S=VALUE',
    :long => '--waittime',
    :description => 'set rand time, Waiting for request'
  option :scheme,
    :description => "Metric naming scheme, text to prepend to .$parent.$child",
    :long => "--scheme SCHEME"
    #:default => "#{Socket.gethostname}"
  option :target,
    :short => '-t=VALUE',
    :long => '--target',
    :description => 'target name'
  option :crit,
    :short => '-c',
    :long => '--crit=VALUE',
    :description => 'Critical threshold'
  option :warn,
    :short => '-w',
    :long => '--warn=VALUE',
    :description => 'Warning threshold'
  option :reverse,
    :short => '-r',
    :long => '--reverse',
    :description => 'Alert when the value is UNDER warn/crit instead of OVER'
  option :diff,
    :short => '-d',
    :long => '--deff=VALUE',
    :description => 'Diff the latest values between two graphs url'
  option :holt_winters,
    :short => '-W',
    :long => '--holt-winters',
    :description => 'Perform a Holt-Winters check'
  option :alias,
    :short => '-n=VALUE',
    :long => '--alias-name',
    :description => 'alias the target name'
  option :help,
    :short => "-h",
    :long => "--help",
    :description => "Check usage",
    :on => :tail,
    :boolean => true,
    :show_options => true,
    :exit => 0


  def read_url(url)
    parser = Yajl::Parser.new
    begin
      file = parser.parse(open(url).read)
    rescue
      file = false
    end
      return file
  end

  def grap_data(file)
      data = file[0]["datapoints"].reject {|k,v| [nil].include?(k) }
      data_sum = data.map {|k,v| k.to_i}.inject(:+)
      data_count = data.count
      data_value = sprintf("%.0f", data_sum.to_f / data_count)
      return data_value
  end

  def stdev_data(file)
      data = file[0]["datapoints"].reject {|k,v| [nil].include?(k) }
      data_max_value = data.map {|k,v| k.to_i}.max
      return data_max_value
  end

  def last_data(file)
      data = file[0]["datapoints"].reject {|k,v| [nil].include?(k)}
      data_last_value = data.map {|k,v| k }[-1]
      return data_last_value
  end

  def holt_grap_data(file)
      tmp_arry = []
      file.each do |f|
        target_name = f["target"]
        data = f["datapoints"].reject {|k,v| [nil].include?(k) }
        data_sum = data.map {|k,v| k.to_i }.inject(:+)
        data_count = data.count
        ave_vaule = sprintf("%.0f", data_sum.to_f / data_count )
        case target_name
        when /holtWintersConfidenceUpper/
          tmp_arry << ["upper_data",ave_vaule]
        when /holtWintersConfidenceLower/
          tmp_arry << ["lower_data",ave_vaule]
        else
          tmp_arry << ["t_value", ave_vaule]
        end
      end
      value_hash = Hash[tmp_arry]
      return value_hash['upper_data'], value_hash['lower_data'], value_hash['t_value']
  end

  def run
    base_url = config[:base_url]
    from_time = config[:time]
    target = nil
    if config[:target]
      target = config[:target]
    elsif config[:scheme]
      target = "*.*."+ config[:scheme].to_s + ".cpu.total"
      target = "stdev(movingAverage(*.*." + config[:scheme].to_s + ".cpu.total,60),60)" if config[:reverse]
    end
      
    #puts target
    
    alias_name = config[:alias].nil? ? target : config[:alias]
    wait_time = config[:rand_time] ? rand(config[:rand_time].to_i) : 0
    
    unknown_msg = {
      :base_msg => "Not find url and time and target, please -h",
      :rev_msg => "Not find -r reverse, please -h",
      :url_error => "#{base_url} connect time out",
      :config_err => "Not find -c crit or -w warn, please -h "

    }

    if base_url.nil? or from_time.nil? or target.nil?
      unknown msg = unknown_msg[:base_msg]
      exit
    end
    
    # rand time, Waiting for request ...
    sleep wait_time
    
    if config[:holt_winters]
      holt_url = "#{base_url}/render?from=-#{from_time}sen&until=now&target=#{target}&target=holtWintersConfidenceBands(#{alias_name})&format=json"
      holt_file = read_url(holt_url)
      if holt_file
        upper_data, lower_data, t_value = holt_grap_data(holt_file)
        critical msg = "#{alias_name} holtWintersConfidenceUpper: #{t_value} >= #{upper_data}" if t_value >= upper_data
        warning msg = "#{alias_name} holtWintersConfidenceLower: #{t_value} <= #{lower_data}" if t_value <= lower_data
        ok msg = "#{alias_name}: #{t_value}" unless (t_value > upper_data) and (t_value < lower_data)
      else
        unknown msg = unknown_msg[:url_error]
      end
      exit
    end

    if config[:diff]
      diff1_url = "#{base_url}/render?from=-#{from_time}sen&until=now&target=#{target}&format=json"
      diff2_url = "#{base_url}/render?from=-#{from_time}sen&until=now&target=#{config[:diff]}&format=json"
      if read_url(diff1_url) and read_url(diff2_url)

        diff1_data = grap_data(read_url(diff1_url))
        diff2_data = grap_data(read_url(diff2_url))
        diff_data = (diff1_data.to_i - diff2_data.to_i).abs.to_i
        unless config[:reverse]
          unknown msg = unknown_msg[:rev_msg]
        else
          unless config[:crit] or config[:warn] != nil
            unknown msg = unknown_msg[:config_err]
          else
            if (diff_data > config[:crit].to_i) and config[:crit]
              critical msg = "#{alias_name}: #{diff_data} > #{config[:crit]}"
            elsif (diff_data > config[:warn].to_i) and config[:warn]
              warning msg = "#{alias_name}: #{diff_data} > #{config[:warn]}"
            else
              ok msg = "#{alias_name}: #{diff_data}"
            end
          end
        end
        else
          unknown msg = unknown_msg[:url_error]
      end
      exit
    end

    grap_url = "#{base_url}/render?from=-#{from_time}sen&until=now&target=#{target}&format=json"
    file = read_url(grap_url)
    if file
      data_value = grap_data(file)
      data_value = stdev_data(file) if config[:reverse]
      unless config[:crit] or config[:warn]
        unknown msg = unknown_msg[:config_err]
      else
        if (data_value.to_i >= config[:crit].to_i) and config[:crit]
          critical msg = "#{alias_name}: #{data_value} >= #{config[:crit]}"
        elsif (data_value.to_i >= config[:warn].to_i) and config[:warn]
          warning msg = "#{alias_name}: #{data_value} >= #{config[:warn]}"
        else
          ok msg = "#{alias_name}: #{data_value}"
        end
      end
    else
      unknown msg = unknown_msg[:url_error]
    end
  end
end
