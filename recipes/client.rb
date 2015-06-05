include_recipe 'torque_test::default'

%w(
  torque-client
  ).each do |pkg|
    package pkg
end
