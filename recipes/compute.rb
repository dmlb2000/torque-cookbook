include_recipe 'torque::default'

package 'torque-mom'

if Chef::Config[:solo]
  snodes = [
    {
      "hostname" => "localhost",
      "machinename" => "localhost.localdomain",
      "ipaddress" => "127.0.0.1"
    }
  ]
else
  snodes = search(:node, "roles:torque-server AND chef_environment:#{node.environment}" )
end
template "/var/lib/torque/server_name" do
  source 'server_name.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(
    :nodes => snodes
  )
  notifies :restart, "service[pbs_mom]"
end

template "/var/lib/torque/mom_priv/mom.layout" do
  source 'mom_layout.erb'
  owner 'root'
  group 'root'
  mode '644'
  notifies :restart, "service[pbs_mom]"
end

template "/etc/torque/mom/config" do
  source 'mom_config.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables(
    :nodes => snodes
  )
  notifies :restart, "service[pbs_mom]"
end

service 'pbs_mom' do
  action [:start, :enable]
  subscribes :restart, "template[/etc/torque/server_name]"
end
