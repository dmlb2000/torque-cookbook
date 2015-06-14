#!/usr/bin/env bats

@test "qstat_check" {
  qstat -q
}

@test "pbsnodes_check" {
  pbsnodes -a
}

@test "enable_node" {
  pbsnodes -c -a
}

@test "submit_test_job" {
  echo "sleep 10" | qsub
}

@test "qstat_for_job" {
  [ `qstat | wc -l` -gt 0 ]
}

@test "job_sleep" {
  sleep 10
}
