case node['platform_family']
when 'rhel'
  include_recipe 'yum-epel'
end

directory '/var/log' do
  mode '0755'
end

package 'munge'

if node['munge'].key?('mungekey')
  if node['munge']['mungekey'].key?('type')
    key = node['munge']['mungekey']
    case key['type']
    when 'vault'
      chef_gem 'chef-vault'
      require 'chef-vault'
      key_item = chef_vault_item(key['data_bag'], key['data_item'])
    when 'databag'
      db_secret = Chef::Config['encrypted_data_bag_secret']
      secret_key = Chef::EncryptedDataBagItem.load_secret(db_secret)
      key_item = Chef::EncryptedDataBagItem.load(
        key['data_bag'], key['data_item'], secret_key
      )
    else
      Chef::Log.error('munge key type needs to be one of vault or databag.')
    end
    key_hash = key_item.to_hash
    # wait this is binary and needs to be a file
    template 'mungekey.ascii' do
      user 'munge'
      group 'munge'
      mode '0400'
      path '/etc/munge/munge.key.base64'
      notifies :run, 'bash[create-munge-key]', :immediately
      source 'mungekey.erb'
      variables(
        data: key_hash['mungekey']
      )
    end
    bash 'create-munge-key' do
      user 'root'
      cwd '/tmp'
      code <<-EOH
      base64 -d < /etc/munge/munge.key.base64 > /etc/munge/munge.key
      chmod 0400 /etc/munge/munge.key
      chown munge:munge /etc/munge/munge.key
      EOH
      action :nothing
    end
  end
else
  bash 'create-munge-key' do
    user 'root'
    cwd '/tmp'
    code 'create-munge-key'
    not_if 'test -e /etc/munge/munge.key'
  end
end

file 'mungekey' do
  user 'munge'
  group 'munge'
  mode '0400'
  path '/etc/munge/munge.key'
end

service 'munge' do
  service_name 'munge'
  subscribes :restart, 'bash[create-munge-key]', :immediately
  action [:enable, :start]
end
