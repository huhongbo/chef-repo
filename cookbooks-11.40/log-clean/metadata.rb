maintainer       "dn365"
maintainer_email "dn@365"
license          "All rights reserved"
description      "Installs/Configures clean-logs, fix:files match, fix:add exec run"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.4"

%w[linux hpux aix].each do |os|
  supports os
end
