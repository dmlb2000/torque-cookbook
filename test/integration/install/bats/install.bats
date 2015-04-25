#!/usr/bin/env bats

@test "install_torque" {
  run rpm -q torque
  [ "$status" -eq 0 ]
}

@test "check_services" {
  # one for tcp and one for udp
  [ `grep pbs /etc/services | wc -l` -eq 8 ]
}
