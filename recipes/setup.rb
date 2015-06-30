chef_gem "chef-rewind"
require 'chef/rewind'

include_recipe 'yum-epel' if node['platform_family'] == 'rhel'
include_recipe 'auto-update'

rewind "execute[periodic-update]" do
  command "yum update -y -q"
end

case node['platform_family']
  when 'rhel'
    dist = ".el#{node['platform_version'].to_i}"
  when 'fedora'
    dist = ".fc#{node['platform_version']}"
  else
    dist = ""
end

cmd = Mixlib::ShellOut.new("ip route show | grep ^default | cut -d' ' -f3")
cmd.run_command
server = cmd.stdout.strip
cmd.error!

yum_repository "local-torque" do
  description "local torque repository"
  baseurl "http://#{server}:10000/results_torque/4.2.10/4#{dist}"
  gpgcheck false
  enabled true
end

hostsfile_entry "127.0.0.1" do
  hostname "localhost localhost.localdomain localhost4 localhost4.localdomain4"
end
if Chef::Config[:solo]
  nodes = [
    {
      "hostname" => "localhost",
      "machinename" => "localhost.localdomain",
      "ipaddress" => "127.0.0.1"
    }
  ]
  node.default['set_fqdn'] = "localhost.localdomain"
  include_recipe('hostname')
else
  nodes = search(:node, "chef_environment:#{node.environment}")
end
nodes.each do |cnode|
  hostsfile_entry cnode['ipaddress'] do
    hostname "#{cnode['hostname']} #{cnode['machinename']}"
  end
end

cookbook_file "/home/vagrant/.ssh/id_rsa" do
  owner "vagrant"
  group "vagrant"
  mode "0600"
end
cookbook_file "/home/vagrant/.ssh/id_rsa.pub" do
  owner "vagrant"
  group "vagrant"
  mode "0644"
end
execute "cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys" do
  not_if "grep vagrant@localhost.localdomain /home/vagrant/.ssh/authorized_keys"
end
cookbook_file "/home/vagrant/.ssh/config" do
  source 'config'
  owner "vagrant"
  group "vagrant"
  mode "0600"
end

