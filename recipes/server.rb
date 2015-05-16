include_recipe 'torque::default'

%w(
  torque-server
  torque-scheduler
  torque-client
  ).each do |pkg|
    package pkg 
end

if Chef::Config[:solo]
  cnodes = [ 'localhost' ]
else
  cnodes = search(:node, "recipes:torque\\:\\:compute AND chef_environment:#{chef_environment}" )
end
template "/var/lib/torque/nodes" do
  source 'nodes.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(
    :nodes => cnodes
  )
  notifies :restart, "service[pbs_server]", :immediately
  notifies :restart, "service[pbs_sched]", :immediately
  notifies :restart, 'service[munge]', :immediately
end

service "trqauthd" do
  action [:start, :enable]
end



service "pbs_server" do
  action [:start, :enable]
end

service "pbs_sched" do
  action [:start, :enable]
end
