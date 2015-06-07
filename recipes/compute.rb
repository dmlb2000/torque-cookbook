include_recipe 'torque::default'

package 'torque-mom'

if Chef::Config[:solo]
  snodes = [ node ]
else
  snodes = search(:node, "recipes:torque\\:\\:server AND chef_environment:#{node.environment}" )
end
template "/var/lib/torque/server_name" do
  source 'server_name.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(
    :nodes => snodes
  )
  notifies :restart, "service[pbs_mom]", :immediately
end

template "/etc/torque/mom/config" do
  source 'mom_config.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables(
    :nodes => snodes
  )
  notifies :restart, "service[pbs_mom]", :immediately
end

service 'pbs_mom' do
  action [:start, :enable]
  subscribes :restart, "template[/etc/torque/server_name]", :immediately
end
