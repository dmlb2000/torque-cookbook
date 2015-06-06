#!/bin/bash -xe

#curl -o ~/.ssh/vagrant https://github.com/mitchellh/vagrant/raw/master/keys/vagrant
#chmod 0400 ~/.ssh/vagrant

DIST=${1:-fedora-21}

/opt/chefdk/embedded/bin/chef-zero -H 192.168.121.1 -d
berks install
rm -rf test/integration/playground/cookbooks/*
berks vendor test/integration/playground/cookbooks
pushd test/integration/playground
knife upload --server-url http://192.168.121.1:8889 .
popd
kitchen create -c 3 -p compute-$DIST server-$DIST client-$DIST

SERVER_IP=$(echo ip a show dev eth0 | kitchen login server-$DIST | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)
CLIENT_IP=$(echo ip a show dev eth0 | kitchen login client-$DIST | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)
COMPUTE_IP=$(echo ip a show dev eth0 | kitchen login compute-$DIST | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)

function run_chef()
{
  knife bootstrap \
    --server-url http://192.168.121.1:8889 \
    --environment production \
    --run-list "$1" \
    --ssh-user vagrant \
    --ssh-password vagrant \
    --sudo \
    --node-name "$2" "$3"
}

for i in 0 1 ; do
  run_chef 'recipe[torque::setup]' server $SERVER_IP &
  run_chef 'recipe[torque::setup]' client $CLIENT_IP &
  run_chef 'recipe[torque::setup]' compute $COMPUTE_IP &
  wait
done
