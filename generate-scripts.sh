#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
commands_dir="$script_dir/src/str-commands"
readme_file="$script_dir/README.md"
begin_marker="<!-- BEGIN GENERATED SCRIPTS -->"
end_marker="<!-- END GENERATED SCRIPTS -->"
api_file=$(mktemp)
output_file=$(mktemp)

cleanup() {
  rm -f "$api_file" "$output_file"
}

path_is_private() {
  local relative_path="$1"
  local path_segment
  local -a path_segments

  IFS='/' read -r -a path_segments <<< "$relative_path"

  for path_segment in "${path_segments[@]}"; do
    [[ "$path_segment" == _* ]] && return 0
  done

  return 1
}

trap cleanup EXIT
found_command=false

while IFS= read -r -d '' command_file; do
  relative_path="${command_file#"$commands_dir/"}"

  if path_is_private "$relative_path"; then
    continue
  fi

  command_name="str ${relative_path//\// }"
  description=$(sed -n 's/^# @description //p' "$command_file")
  usage=$(sed -n 's/^# @usage //p' "$command_file")
  mapfile -t options < <(sed -n 's/^# @option //p' "$command_file")

  if [[ -z "$description" || -z "$usage" ]]; then
    echo "generate-scripts: missing metadata: $relative_path" >&2
    exit 1
  fi

  {
    printf '### `%s`\n\n' "$command_name"
    printf '%s\n\n' "$description"
    printf '```sh\n%s\n' "$usage"

    if (( ${#options[@]} > 0 )); then
      printf '\nOptions:\n'

      for option in "${options[@]}"; do
        printf '  %s\n' "$option"
      done
    fi

    printf '```\n\n'
  } >> "$api_file"

  found_command=true
done < <(find "$commands_dir" -type f -perm /111 -print0 | sort -z)

if [[ "$found_command" == false ]]; then
  echo "generate-scripts: no public executable commands found" >&2
  exit 1
fi

awk \
  -v api_file="$api_file" \
  -v begin_marker="$begin_marker" \
  -v end_marker="$end_marker" '
  $0 == begin_marker {
    print
    while ((getline api_line < api_file) > 0) {
      print api_line
    }
    close(api_file)
    in_generated_section = 1
    found_begin = 1
    next
  }

  $0 == end_marker {
    in_generated_section = 0
    found_end = 1
    print
    next
  }

  !in_generated_section {
    print
  }

  END {
    if (!found_begin || !found_end) {
      exit 1
    }
  }
' "$readme_file" > "$output_file" || {
  echo "generate-scripts: README Scripts markers not found" >&2
  exit 1
}

chmod --reference="$readme_file" "$output_file"
mv "$output_file" "$readme_file"
