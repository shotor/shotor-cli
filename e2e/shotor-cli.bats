#!/usr/bin/env bats

setup() {
  bats_require_minimum_version 1.5.0
  load ../scripts/load.sh
  load_test_helpers
  SHOTOR="$SRC_DIR/shotor-cli"
  export SHOTOR_SCRIPTS_DIR="$FIXTURES_DIR/scripts"
}

@test "dispatches a leaf command with forwarded arguments" {
  run "$SHOTOR" leaf one two
  assert_success
  assert_output "leaf: one two"
}

@test "dispatches a nested namespace command" {
  run "$SHOTOR" ns child alpha
  assert_success
  assert_output "ns child: alpha"
}

@test "dispatches a deeply nested command" {
  run "$SHOTOR" ns deep grandchild
  assert_success
  assert_output "ns deep grandchild: "
}

@test "listing a namespace shows its commands" {
  run "$SHOTOR" ns
  assert_success
  assert_line "  child"
  assert_line "  deep"
}

@test "no arguments lists top-level commands" {
  run "$SHOTOR"
  assert_success
  assert_line "  leaf"
  assert_line "  ns"
}

@test "unknown command fails with 127" {
  run -127 "$SHOTOR" nope
  assert_output --partial "command not found"
}

@test "private command is not dispatchable" {
  run -127 "$SHOTOR" _hidden secret
}

@test "path-like segment is rejected" {
  run "$SHOTOR" ../escape
  assert_failure 2
  assert_output --partial "invalid command segment"
}
