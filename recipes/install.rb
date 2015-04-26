include_recipe "yum-epel" if node['platform_family'] == 'rhel'

package "torque"

package "torque" do
  action :remove
end

package "torque"
package "torque-mom"
package "torque-server"
package "torque-scheduler"
package "torque-pam"
