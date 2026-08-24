#!/usr/bin/env bats

setup() {
  load ../../scripts/load.sh
  load_test_helpers
  load_lib
}

@test "SHOTOR_SCRIPTS_DIR override wins" {
  SHOTOR_SCRIPTS_DIR="/tmp/custom-scripts" run shotor_scripts_dir "$SRC_DIR/shotor-cli"
  assert_success
  assert_output "/tmp/custom-scripts"
}

@test "XDG_DATA_HOME location is used when it exists" {
  local data_home="$BATS_TEST_TMPDIR/data"
  mkdir -p "$data_home/shotor-cli/scripts"
  unset SHOTOR_SCRIPTS_DIR
  XDG_DATA_HOME="$data_home" run shotor_scripts_dir "$SRC_DIR/shotor-cli"
  assert_success
  assert_output "$data_home/shotor-cli/scripts"
}

@test "falls back to scripts next to the executable" {
  unset SHOTOR_SCRIPTS_DIR
  XDG_DATA_HOME="$BATS_TEST_TMPDIR/empty" run shotor_scripts_dir "$SRC_DIR/shotor-cli"
  assert_success
  assert_output "$SRC_DIR/scripts"
}

@test "resolves through a symlink for the dev fallback" {
  local link_dir="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$link_dir"
  ln -s "$SRC_DIR/shotor-cli" "$link_dir/anyname"
  unset SHOTOR_SCRIPTS_DIR
  XDG_DATA_HOME="$BATS_TEST_TMPDIR/empty" run shotor_scripts_dir "$link_dir/anyname"
  assert_success
  assert_output "$SRC_DIR/scripts"
}
