include_recipe 'yum-epel' if node['platform_family'] == 'rhel'

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
  baseurl "http://#{server}:10000/results_torque/4.2.10/2#{dist}"
  gpgcheck false
  enabled true
end

package 'torque'
package 'torque-mom'
package 'torque-server'
package 'torque-scheduler'
package 'torque-devel'
package 'torque-drmaa'
package 'torque-drmaa-devel'
package 'torque-pam'
