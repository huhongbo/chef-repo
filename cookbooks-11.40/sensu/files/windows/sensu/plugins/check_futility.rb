# system default plugin
# check futility script to windows
# code dn365
# v0.01

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'

$VERBOSE = nil
class CheckFutility < Sensu::Plugin::Check::CLI
  def run
    ok msg = "It's OK"
  end
end