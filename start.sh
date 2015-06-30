#!/bin/bash -xe

#curl -o ~/.ssh/vagrant https://github.com/mitchellh/vagrant/raw/master/keys/vagrant
#chmod 0400 ~/.ssh/vagrant

DIST=${1:-centos-71}

kitchen create c0-$DIST
kitchen create c1-$DIST
kitchen create server-$DIST
kitchen create client-$DIST

/opt/chefdk/embedded/bin/chef-zero -H 192.168.121.1 -d
berks install
rm -rf test/integration/playground/cookbooks/*
berks vendor test/integration/playground/cookbooks
pushd test/integration/playground
knife upload --server-url http://192.168.121.1:8889 .
popd

SERVER_IP=$(echo ip a show dev eth0 | kitchen login server-$DIST | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)
CLIENT_IP=$(echo ip a show dev eth0 | kitchen login client-$DIST | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)
C0_IP=$(echo ip a show dev eth0 | kitchen login c0-$DIST | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)
C1_IP=$(echo ip a show dev eth0 | kitchen login c1-$DIST | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)

function bootstrap_chef()
{
  knife bootstrap \
    --server-url http://192.168.121.1:8889 \
    --environment production \
    --run-list "$1" \
    --ssh-user vagrant \
    --ssh-password vagrant \
    --sudo \
    --secret-file test/integration/encrypted_data_bag_secret \
    --node-name "$2" "$3"
}

bootstrap_chef 'role[torque-server],recipe[torque::setup]' server $SERVER_IP &
bootstrap_chef 'role[torque-clients],recipe[torque::setup]' client $CLIENT_IP &
bootstrap_chef 'role[torque-compute],recipe[torque::setup]' c0 $C0_IP &
bootstrap_chef 'role[torque-compute],recipe[torque::setup]' c1 $C1_IP &
wait
for i in 0 1 ; do
  for h in c0 c1 server client ; do
    echo sudo chef-client | kitchen login $h-$DIST &
  done
  wait
done
