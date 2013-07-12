metadata  :name => "uppasswd",
	        :description => "update system user's password",
          :author      => "dn365",
          :license     => "GPLv2",
          :version     => "0.1",
          :url         => "https://github.com/dn365/chef-repo",
          :timeout     => 120

action "upgrade", :description => "upgrade system user's password" do
  display :always
  
  input :user,
    :prompt      => "system user name",
    :description => "system user name",
    :type        => :string,
    :validation  => '^[a-zA-Z\-_\d]+$',
    :optional    => false,
    :maxlength   => 120
  input :password,
    :prompt      => "system user new password value",
    :description => "system user new password",
    :type        => :string,
    :validation  => '^[a-zA-Z\-_\d]+$',
    :optional    => false,
    :maxlength   => 120
  output :cmd,
    :description => "show values ...",
    :display_as => "values"
  output :msg,
    :description => "show values ...",
    :display_as => "values"
end 
action "upssh", :description => "add ssh key to sshd" do
  display :always
  
  input :ssh_key,
    :prompt      => "ssh key value",
    :description => "ssh key value",
    :type        => :string,
    :validation  => '^[a-zA-Z\-_\d]+$',
    :optional    => false,
    :maxlength   => 0
  output :add_key,
    :description => "show values ...",
    :display_as => "values"
  output :msg,
    :description => "show values ...",
    :display_as => "values"
end 
