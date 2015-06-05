#!/bin/bash -x

pkill chef-zero
kitchen destroy test0
kitchen destroy test1
