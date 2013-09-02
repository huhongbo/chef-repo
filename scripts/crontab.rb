30 * * * * /opt/chef-server/embedded/bin/ruby /var/opt/chef-server/gdash/working/create_gdash_whisper.rb
15 23 * * * cd /opt/chef-server/embedded/service/info-dashboard && /opt/chef-server/embedded/bin/rake update:all
*/30 * * * * cd /opt/chef-server/embedded/service/info-dashboard && /opt/chef-server/embedded/bin/rake update:up_databag
0 * * * * /opt/chef-server/embedded/service/graphite/bin/build-index.sh