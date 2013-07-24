maintainer       "sensu configure"
maintainer_email "dn365@outlook.com"
license          "All rights reserved update version 0.9.13"
description      "Installs/Configures sensu-config add aix and hpux add server, add check sensu client process status"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.4"
# https://github.com/dn365/chef-base-config
#depends "chef-base-config"

# https://github.com/dn365/chef-client
#depends "chef-client"
%w[hpux linux aix].each do |os|
  supports os
end