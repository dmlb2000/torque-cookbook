# Authors:: David Brown
# Copyright 2014, David Brown
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Install torque common
include_recipe 'yum-epel::default' if node['platform_family'] == 'rhel'

dist = case node['platform_family']
       when 'rhel'
         ".el#{node['platform_version'].to_i}"
       when 'fedora'
         ".fc#{node['platform_version']}"
       else
         ''
       end

cmd = Mixlib::ShellOut.new('ip route show | grep ^default | cut -d\' \' -f3')
cmd.run_command
server = cmd.stdout.strip
cmd.error!

yum_repository 'local-torque' do
  description 'local torque repository'
  baseurl "http://#{server}:8000/results_torque/4.2.10/10#{dist}"
  gpgcheck false
  enabled true
end

package 'torque'

include_recipe 'torque::munge'

if Chef::Config[:solo]
  snodes = [
    {
      hostname: 'localhost',
      machinename: 'localhost.localdomain',
      ipaddress: '127.0.0.1'
    }
  ]
else
  snodes = search(:node, 'roles:torque-server AND '\
                   "chef_environment:#{node.environment}"
                 )
end
template '/etc/torque/server_name' do
  source 'server_name.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables(
    nodes: snodes
  )
end

service 'trqauthd' do
  action [:start, :enable]
end

include_recipe 'build-essential'
package 'openmpi'
package 'openmpi-devel'
package 'environment-modules'
