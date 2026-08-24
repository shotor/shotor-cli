# shellcheck shell=bash
#
# Command discovery helpers: privacy rules, executability checks and listing.
#
# A path is "private" when any of its segments (relative to the scripts dir)
# starts with an underscore. Private paths are hidden from listing, completion
# and namespace fallbacks.

path_is_private() {
  local scripts_dir="$1"
  local command_path="$2"
  local relative_path="${command_path#"$scripts_dir"/}"
  local path_segment
  local -a path_segments

  IFS='/' read -r -a path_segments <<<"$relative_path"

  for path_segment in "${path_segments[@]}"; do
    [[ "$path_segment" == _* ]] && return 0
  done

  return 1
}

is_executable_command() {
  local scripts_dir="$1"
  local command_path="$2"

  [[ -f "$command_path" && -x "$command_path" ]] \
    && ! path_is_private "$scripts_dir" "$command_path"
}

list_commands() {
  local scripts_dir="$1"
  local listing_dir="$2"
  local command_dir
  local command_entry
  local command_name
  local found_command=false

  echo "Available commands:"

  shopt -s globstar nullglob

  for command_dir in "$listing_dir"/*; do
    command_name="${command_dir##*/}"

    if is_executable_command "$scripts_dir" "$command_dir"; then
      printf '  %s\n' "$command_name"
      found_command=true
      continue
    fi

    for command_entry in "$command_dir"/**; do
      if is_executable_command "$scripts_dir" "$command_entry"; then
        printf '  %s\n' "$command_name"
        found_command=true
        break
      fi
    done
  done

  if [[ "$found_command" == false ]]; then
    echo "  (none)"
  fi
}
