include_recipe 'torque::default'
include_recipe 'nfs::client4'
if Chef::Config[:solo]
  head = node
else
  heads = search(:node,
                 "role:torque-server",
                 filter_result: { name: ['hostname'],
                                  ip: ['ipaddress']
                                }
                )
  print heads
  head = heads[0]
end

mount '/home' do
  device "#{head['name']}:/home"
  fstype 'nfs'
  options 'rw'
  action [:mount, :enable]
end

%w(
  torque-client
  ).each do |pkg|
    package pkg
end
