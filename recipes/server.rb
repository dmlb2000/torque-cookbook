include_recipe 'torque::default'

%w(
  torque-server
  torque-scheduler
  torque-client
  ).each do |pkg|
    package pkg 
end

if Chef::Config[:solo]
  cnodes = [ node ]
else
  cnodes = search(:node, "recipes:torque\\:\\:compute AND chef_environment:#{chef_environment}" )
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

service "trqauthd" do
  action [:start, :enable]
end

case node['platform_family']
  when 'fedora'
    case node['platform_version'].to_i
      when 20
        torque_docdir = "/usr/share/doc/torque"
      else
        torque_docdir = "/usr/share/doc/torque-4.2.10"
    end
  else
    torque_docdir = "/usr/share/doc/torque-4.2.10"
end

bash "server-setup" do
  flags "-xe"
  code <<-EOH
  /bin/echo y | /bin/bash -x #{torque_docdir}/torque.setup root #{node['fqdn']}
  pkill pbs_server
  while pgrep pbs_server ; do
    sleep 1
  done
  EOH
  not_if "test -e /var/lib/torque/server_priv/serverdb"
end

service "pbs_server" do
  action [:start, :enable]
end

service "pbs_sched" do
  action [:start, :enable]
end
