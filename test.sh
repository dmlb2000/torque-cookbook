#!/bin/bash -x

DIST=${1:-fedora-21}

berks install
rm -rf test/integration/playground/cookbooks/*
berks vendor test/integration/playground/cookbooks
pushd test/integration/playground
knife upload --server-url http://192.168.121.1:8889 cookbooks
popd

SERVER_IP=$(echo ip a show dev eth0 | kitchen login server-$DIST | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)
CLIENT_IP=$(echo ip a show dev eth0 | kitchen login client-$DIST | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)
C0_IP=$(echo ip a show dev eth0 | kitchen login c0-$DIST | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)
C1_IP=$(echo ip a show dev eth0 | kitchen login c1-$DIST | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)

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
  run_chef 'recipe[torque::server]' server $SERVER_IP
  run_chef 'recipe[torque::client]' client $CLIENT_IP
  run_chef 'recipe[torque::compute]' c0 $C0_IP
  run_chef 'recipe[torque::compute]' c1 $C1_IP
done

