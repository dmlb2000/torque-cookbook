include_recipe 'torque::default'

%w(
  torque-server
  torque-scheduler
  torque-client
).each do |pkg|
    package pkg 
end

if Chef::Config[:solo]
  cnodes = [
    {
      "hostname" => "localhost",
      "machinename" => "localhost.localdomain",
      "ipaddress" => "127.0.0.1",
      "cpu" => {
        "total" => 1
      }
    }
  ]
  server_fqdn = "localhost"
else
  cnodes = search(:node, "roles:torque-compute AND chef_environment:#{node.environment}" )
  server_fqdn = node[:hostname]
end

template "/var/lib/torque/server_priv/nodes" do
  source 'nodes.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(
    :nodes => cnodes
  )
  notifies :restart, "service[pbs_server]"
  notifies :restart, "service[pbs_sched]"
end

case node['platform_family']
  when 'fedora'
    torque_docdir = "/usr/share/doc/torque"
  else
    torque_docdir = "/usr/share/doc/torque-4.2.10"
end

bash "server-setup" do
  flags "-xe"
  code <<-EOH
  /bin/echo y | /bin/bash -x #{torque_docdir}/torque.setup root #{server_fqdn}
  pkill pbs_server
  while pgrep pbs_server ; do
    sleep 1
  done
  EOH
  not_if "test -e /var/lib/torque/server_priv/serverdb"
end

service "pbs_server" do
  action [:start, :enable]
  subscribes :restart, "template[/etc/torque/server_name]"
end

service "pbs_sched" do
  action [:start, :enable]
  subscribes :restart, "template[/etc/torque/server_name]"
end

if Chef::Config[:solo]
  cnodes = [
    {
      "hostname" => "localhost",
      "machinename" => "localhost.localdomain",
      "ipaddress" => "127.0.0.1"
    }
  ]
else
  cnodes = search(:node, "roles:torque-clients AND chef_environment:#{node.environment}" )
end

clients_names = []
cnodes.each do |client_node|
  clients_names.push(client_node['hostname'])
end
execute "qmgr -c 'set server submit_hosts = #{clients_names.join(',')}'"
