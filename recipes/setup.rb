chef_gem 'chef-rewind'
require 'chef/rewind'

include_recipe 'yum-epel' if node['platform_family'] == 'rhel'
include_recipe 'auto-update'

rewind 'execute[periodic-update]' do
  command 'yum update -y -q'
end

hostsfile_entry '127.0.0.1' do
  hostname 'localhost'
  aliases %w(localhost.localdomain localhost4 localhost4.localdomain4)
end
if Chef::Config[:solo]
  nodes = [
    {
      hostname: 'localhost',
      machinename: 'localhost.localdomain',
      ipaddress: '127.0.0.1'
    }
  ]
  node.default['set_fqdn'] = 'localhost.localdomain'
  include_recipe('hostname')
else
  nodes = search(:node, "chef_environment:#{node.environment}")
end
nodes.each do |cnode|
  hostsfile_entry cnode['ipaddress'] do
    hostname "#{cnode['hostname']} #{cnode['machinename']}"
  end
end

cookbook_file '/home/vagrant/.ssh/id_rsa' do
  owner 'vagrant'
  group 'vagrant'
  mode '0600'
end
cookbook_file '/home/vagrant/.ssh/id_rsa.pub' do
  owner 'vagrant'
  group 'vagrant'
  mode '0644'
end
execute 'cat /home/vagrant/.ssh/id_rsa.pub >> '\
        '/home/vagrant/.ssh/authorized_keys' do
  not_if 'grep vagrant@localhost.localdomain /home/vagrant/.ssh/authorized_keys'
end
cookbook_file '/home/vagrant/.ssh/config' do
  source 'config'
  owner 'vagrant'
  group 'vagrant'
  mode '0600'
end
