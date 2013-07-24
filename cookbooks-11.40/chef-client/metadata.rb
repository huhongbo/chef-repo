maintainer       "dn365"
maintainer_email "dn@365"
license          "All rights reserved"
description      "Installs/Configures chef-client, fix: add ruby ENV PATH"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.1"


%w{ aix linux hpux }.each do |os|
  supports os
end
