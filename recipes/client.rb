include_recipe 'torque::default'

%w(
  torque-client
  ).each do |pkg|
    package pkg
end
