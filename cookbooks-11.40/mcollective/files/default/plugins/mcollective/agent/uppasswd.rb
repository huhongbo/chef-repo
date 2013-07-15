module MCollective
  module Agent
    class Uppasswd<RPC::Agent
      metadata  :name        => "uppasswd",
                :description => "update system user's password",
                :author      => "dn365",
                :license     => "GPLv2",
                :version     => "0.1",
                :url         => "https://github.com/dn365/chef-repo",
                :timeout     => 120
 
      # upgrade system user password
      action "upgrade" do
        validate :user, String
        validate :password, String
        reply[:cmd] = system("passwd #{request[:user]}<<EOF\n#{request[:password]}\n#{request[:password]}\nEOF")
        reply[:msg] = $?.exitstatus
      end
      action "upssh" do
        validate :ssh_key, String
        reply[:add_key] = system("echo #{request[:ssh_key]} >> /root/.ssh/authorized_keys")
        reply[:msg] = $?.exitstatus
      end
      action "useradd" do
        validate :user, String
        validate :home, String
        validate :password, String
        reply[:add_user] = system("useradd #{request[:user]} -d #{request[:home]}/#{request[:user]} -m")
        reply[:add_passwd] = system("passwd #{request[:user]}<<EOF\n#{request[:password]}\n#{request[:password]}\nEOF")
        if reply[:add_user] and reply[:add_passwd]
          reply[:msg] = 0
        else
          reply[:msg] = 1
        end
      end
    end
  end
end