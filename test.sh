#!/bin/bash -x

berks install
rm -rf test/integration/playground/cookbooks/*
berks vendor test/integration/playground/cookbooks
pushd test/integration/playground
knife upload --server-url http://192.168.121.1:8889 cookbooks
popd

TEST0_IP=$(echo ip a show dev eth0 | kitchen login test0 | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)
TEST1_IP=$(echo ip a show dev eth0 | kitchen login test1 | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)

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
  run_chef 'role[linux-ha],recipe[linux-ha::default]' test0 $TEST0_IP &
  run_chef 'role[linux-ha],recipe[linux-ha::default]' test1 $TEST1_IP &
  wait
done

