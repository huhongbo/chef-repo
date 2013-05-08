module MCollective
  module Agent
    class Runchef<RPC::Agent
      metadata :name        => "run chef echo",
      		     :description => "run info agent output",
               :author      => "dn365",
      	       :license     => "GPLv2",
               :version     => "0.1",
               :url         => "https://github.com/dn365/mcollective-chef",
               :timeout     => 300
               
      action "run" do 
        reply[:stdout] = ""
        reply[:stderr] = ""
        client = "chef-client"  
        if File.exist?("/usr/local/ruby1.9/bin/chef-client")
          client = "/usr/local/ruby1.9/bin/chef-client"
        elsif File.exist?("/opt/freeware/ruby1.9/bin/chef-client")
          client = "/opt/freeware/ruby1.9/bin/chef-client"
        else
          client
        end       
        run_chef = run("#{client}", :stdout => reply[:stdout], :stderr => reply[:stderr] ) 
        reply[:output] = run_chef
      end

    end
  end
end