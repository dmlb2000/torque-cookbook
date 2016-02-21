#!/bin/bash -x

DIST=${1:-centos-72}

berks install
rm -rf test/integration/playground/cookbooks/*
berks vendor test/integration/playground/cookbooks
pushd test/integration/playground
knife upload --server-url http://192.168.121.1:8889 cookbooks data_bags environments roles
popd

for i in 0 1 ; do 
  echo "sudo chef-client -r 'role[torque-server],recipe[torque::server]'" | kitchen login server-$DIST
  echo "sudo chef-client -r 'role[torque-clients],recipe[torque::client]'" | kitchen login client-$DIST
  echo "sudo chef-client -r 'role[torque-compute],recipe[torque::compute]'" | kitchen login c0-$DIST
  echo "sudo chef-client -r 'role[torque-compute],recipe[torque::compute]'" | kitchen login c1-$DIST
done

