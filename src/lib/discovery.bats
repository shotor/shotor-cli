#!/usr/bin/env bats

setup() {
  load ../../scripts/load.sh
  load_test_helpers
  load_lib
  SCRIPTS="$FIXTURES_DIR/scripts"
}

@test "path_is_private flags underscore segments" {
  run path_is_private "$SCRIPTS" "$SCRIPTS/_hidden/secret"
  assert_success
}

@test "path_is_private ignores normal paths" {
  run path_is_private "$SCRIPTS" "$SCRIPTS/ns/child"
  assert_failure
}

@test "is_executable_command accepts a public executable" {
  run is_executable_command "$SCRIPTS" "$SCRIPTS/leaf"
  assert_success
}

@test "is_executable_command rejects a private executable" {
  run is_executable_command "$SCRIPTS" "$SCRIPTS/_hidden/secret"
  assert_failure
}

@test "list_commands shows public commands and hides private ones" {
  run list_commands "$SCRIPTS" "$SCRIPTS"
  assert_success
  assert_line "  leaf"
  assert_line "  ns"
  refute_output --partial "_hidden"
}

@test "list_commands reports none for an empty directory" {
  local empty="$BATS_TEST_TMPDIR/empty"
  mkdir -p "$empty"
  run list_commands "$empty" "$empty"
  assert_success
  assert_line "  (none)"
}
