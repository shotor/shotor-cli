# shellcheck shell=bash
#
# Command dispatch: walk the argument list from the longest matching prefix
# down to the shortest, execing the deepest executable command found. Falls
# back to listing a namespace when the final segment names a directory.

run_command() {
  local dispatcher_name="$1"
  local scripts_dir="$2"
  shift 2
  local -a arguments=("$@")
  local command_path
  local depth
  local index
  local leaf_name
  local prefix_is_valid
  local segment

  segment="${arguments[0]}"

  if [[ -z "$segment" || "$segment" == "." || "$segment" == ".." || "$segment" == */* ]]; then
    echo "$dispatcher_name: invalid command segment: $segment" >&2
    exit 2
  fi

  for ((depth = ${#arguments[@]}; depth >= 1; depth--)); do
    command_path="$scripts_dir"
    prefix_is_valid=true

    for ((index = 0; index < depth; index++)); do
      segment="${arguments[index]}"

      if [[ -z "$segment" || "$segment" == "." || "$segment" == ".." || "$segment" == */* ]]; then
        prefix_is_valid=false
        break
      fi

      command_path+="/$segment"
    done

    if [[ "$prefix_is_valid" == false ]]; then
      continue
    fi

    if is_executable_command "$scripts_dir" "$command_path"; then
      exec "$command_path" "${arguments[@]:depth}"
    fi

    leaf_name="${arguments[depth - 1]}"

    if is_executable_command "$scripts_dir" "$command_path/$leaf_name"; then
      exec "$command_path/$leaf_name" "${arguments[@]:depth}"
    fi

    if ((depth == ${#arguments[@]})) \
      && [[ -d "$command_path" ]] \
      && ! path_is_private "$scripts_dir" "$command_path"; then
      list_commands "$scripts_dir" "$command_path"
      exit 0
    fi
  done

  echo "$dispatcher_name: command not found: ${arguments[*]}" >&2
  exit 127
}
