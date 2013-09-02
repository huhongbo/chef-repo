maintainer       "logstash configure"
maintainer_email "dn365@outlook.com"
description      "Installs/Configures logstash "
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1"

%w[hpux linux aix].each do |os|
  supports os
end