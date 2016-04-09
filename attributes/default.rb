default['torque']['etc_dir'] = '/etc/torque'
default['torque']['var_dir'] = '/var/lib/torque'

default['torque']['publickey'] = 'not found'

default['torque']['manager_host'] = node['fqdn']
default['torque']['acl_hosts'] = node['fqdn']
default['torque']['server_scheduling'] = 'true'
default['torque']['keep_completed'] = '300'
default['torque']['mom_job_sync'] = 'pbs'
default['torque']['queue'] = 'batch'
default['torque']['queue_type'] = 'execution'
default['torque']['started'] = 'true'
default['torque']['enabled'] = 'true'
default['torque']['walltime'] = '1:00:00'
default['torque']['auto_node_np'] = 'true'
default['torque']['default_queue'] = 'pbs'

default['auto-update']['enabled'] = true
