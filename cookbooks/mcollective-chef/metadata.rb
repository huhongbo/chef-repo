maintainer       "dn365"
maintainer_email "dn365@163.com"
license          "All rights reserved"
description      "Installs/Configures mcollective-chef mcollective 0.2.1"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.2"

%w[ ubuntu hpux aix centos redhat ].each do |os|
  supports os
end

