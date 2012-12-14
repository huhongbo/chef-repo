module MCollective
  module Agent
    class Sensu<RPC::Agent
      action "restart" do
        reply[:stdout] = ""
        reply[:stderr] = ""
        client = "sensu-client"
        if File.exist?("/etc/init.d/sensu-client")
          client = "/etc/init.d/sensu-client"
        elsif File.exist?("/sbin/init.d/sensu-client")
          client = "/sbin/init.d/sensu-client"
        else
          client
        end
        restart_sensu = run("#{client} restart", :stdout => reply[:stdout], :stderr => reply[:stderr] )
        reply[:output] = restart_sensu
      end
    end
  end
end
