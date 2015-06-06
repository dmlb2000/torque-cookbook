#!/bin/bash -x

pkill chef-zero
kitchen destroy -c 2 -p
