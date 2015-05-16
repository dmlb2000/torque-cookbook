include_recipe 'yum-epel' if node['platform_family'] == 'rhel'

if File.directory?("/localrepo")
  yum_repository "local-torque" do
    description "local torque repository"
    baseurl "file:///localrepo"
    gpgcheck false
    enabled true
  end
end
package 'torque'
package 'torque-mom'
package 'torque-server'
package 'torque-scheduler'
package 'torque-devel'
package 'torque-drmaa'
package 'torque-drmaa-devel'
package 'torque-pam'
