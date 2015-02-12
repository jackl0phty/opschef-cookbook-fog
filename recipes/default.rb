#
# Cookbook Name:: fog
# Recipe:: default
#
# Copyright 2012, Gerald L. Hevener Jr., M.S.
#

# Download and untar FOG
bash "download-untar-fog" do
  user "root"
  cwd "/opt"
  code <<-EOH
  wget http://downloads.sourceforge.net/project/freeghost/FOG/fog_#{node['fog']['version']}/fog_#{node['fog']['version']}.tar.gz
  tar -xvzf fog_#{node['fog']['version']}.tar.gz
  rm -f fog_#{node['fog']['version']}.tar.gz
  EOH
  not_if "test -f /opt/fog_#{node['fog']['version']}.tar.gz"
  not_if "test -d /opt/fog_#{node['fog']['version']}"
end

# Install apache2 & php5
case node['platform_family']

  when "debian"
    %w{ apache2 php5 php5-gd php5-cli php5-mysql php5-curl
        isc-dhcp-server tftpd-hpa tftp-hpa nfs-kernel-server
        vsftpd net-tools wget xinetd sysv-rc-conf tar gzip
        cpp gcc g++ m4 htmldoc perl libcrypt-passwdmd5-perl
        lftp ssh php-gettext clamav-freshclam }.each do |pkg|
    package pkg
  end
  when "centos"
    %w{ httpd php php-mysql tar gzip libgcc }.each do |pkg|
    package pkg
  end
end

# Install MySQL server
include_recipe "mysql::server"

# Configure the firewall
template "/etc/sysconfig/iptables" do
  # path "/etc/sysconfig/iptables"
  source "iptables.erb"
  owner "root"
  group "root"
  mode 00600
  # notifies :restart, resources(:service => "iptables")
end

execute "service iptables restart" do
  user "root"
  command "service iptables restart"
end