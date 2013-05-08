maintainer       "dn365"
maintainer_email "dn@365"
license          "All rights reserved"
description      "Installs/Configures chef-client"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

# https://github.com/dn365/chef-base-config
#depends "chef-base-config"

%w{ aix linux hpux }.each do |os|
  supports os
end
