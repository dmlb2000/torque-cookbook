#!/bin/bash -x

pkill chef-zero
kitchen destroy -c 4 -p
