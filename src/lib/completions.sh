# shellcheck shell=bash
#
# Generate and install shell completions for a dispatcher name. Kept in a lib so
# both src/install-completions.sh and the bundled executable can install
# completions (via `<name> --install-completions`).

generate_zsh_completion() {
  local output_file="$1"
  sed "s/@NAME@/$name/g" >"$output_file" <<'COMPLETION'
#compdef @NAME@

_@NAME@() {
  local dispatcher='@NAME@'
  local executable_path="${commands[$dispatcher]}"
  local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  local real_executable="$executable_path"
  local link_dir
  local commands_dir
  local command_path
  local description
  local entry
  local index
  local metadata
  local option_name
  local option_names
  local option_spec
  local option_text
  local segment
  local -a completion_options
  local -a completions

  if [[ -z "$executable_path" ]]; then
    return 1
  fi

  while [[ -L "$real_executable" ]]; do
    link_dir="${real_executable:h}"
    real_executable="$(readlink -- "$real_executable")"
    [[ "$real_executable" != /* ]] && real_executable="$link_dir/$real_executable"
  done

  if [[ -n "${SHOTOR_SCRIPTS_DIR:-}" ]]; then
    commands_dir="$SHOTOR_SCRIPTS_DIR"
  elif [[ -d "$data_home/shotor-cli/scripts" ]]; then
    commands_dir="$data_home/shotor-cli/scripts"
  else
    commands_dir="${real_executable:h}/scripts"
  fi

  command_path="$commands_dir"

  if [[ ! -d "$commands_dir" ]]; then
    return 1
  fi

  for ((index = 2; index < CURRENT; index++)); do
    segment="${words[index]}"

    if [[ "$segment" == -* ]]; then
      break
    fi

    if [[ -d "$command_path/$segment" ]]; then
      command_path="$command_path/$segment"
      continue
    fi

    if [[ -f "$command_path/$segment" && -x "$command_path/$segment" ]]; then
      command_path="$command_path/$segment"
    fi

    break
  done

  if [[ -f "$command_path" && -x "$command_path" ]]; then
    while IFS= read -r metadata; do
      [[ "$metadata" == '# @option '* ]] || continue
      option_text="${metadata#\# @option }"
      option_spec=$(printf '%s\n' "$option_text" |
        awk -F '[[:space:]][[:space:]]+' '{print $1}')
      description=$(printf '%s\n' "$option_text" |
        awk -F '[[:space:]][[:space:]]+' '{print $2}')
      option_names=$(printf '%s\n' "$option_spec" |
        sed -E 's/[[:space:]]+<[^>]+>//g')
      description="${description//:/\\:}"

      for option_name in ${(s:,:)option_names}; do
        option_name="${option_name// /}"
        completion_options+=("$option_name:$description")
      done
    done < "$command_path"

    if (( ${#completion_options[@]} > 0 )); then
      _describe 'option' completion_options
    fi

    return
  fi

  for entry in "$command_path"/*(N); do
    [[ "${entry:t}" == _* ]] && continue

    if [[ -f "$entry" && -x "$entry" ]]; then
      description=$(sed -n 's/^# @description //p' "$entry" | head -n 1)
      description="${description:-command}"
      description="${description//:/\\:}"
      completions+=("${entry:t}:$description")
    elif [[ -d "$entry" ]]; then
      completions+=("${entry:t}:command namespace")
    fi
  done

  _describe 'command' completions
}

compdef _@NAME@ @NAME@
COMPLETION
}

generate_bash_completion() {
  local output_file="$1"
  local function_name="${name//-/_}"

  sed \
    -e "s/@NAME@/$name/g" \
    -e "s/@FUNCTION@/$function_name/g" \
    >"$output_file" <<'COMPLETION'
_@FUNCTION@() {
  local dispatcher='@NAME@'
  local executable_path
  local real_executable
  local link_dir
  local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  local candidate
  local commands_dir
  local command_path
  local current
  local entry
  local index
  local metadata
  local option_names
  local option_spec
  local option_text
  local segment
  local -a candidates
  local -a options
  local -a parsed_options

  COMPREPLY=()
  current="${COMP_WORDS[COMP_CWORD]}"
  executable_path=$(command -v "$dispatcher")

  if [[ -z "$executable_path" ]]; then
    return
  fi

  real_executable="$executable_path"
  while [[ -L "$real_executable" ]]; do
    link_dir="${real_executable%/*}"
    real_executable="$(readlink -- "$real_executable")"
    [[ "$real_executable" != /* ]] && real_executable="$link_dir/$real_executable"
  done

  if [[ -n "${SHOTOR_SCRIPTS_DIR:-}" ]]; then
    commands_dir="$SHOTOR_SCRIPTS_DIR"
  elif [[ -d "$data_home/shotor-cli/scripts" ]]; then
    commands_dir="$data_home/shotor-cli/scripts"
  else
    commands_dir="${real_executable%/*}/scripts"
  fi

  command_path="$commands_dir"

  if [[ ! -d "$commands_dir" ]]; then
    return
  fi

  for ((index = 1; index < COMP_CWORD; index++)); do
    segment="${COMP_WORDS[index]}"

    if [[ "$segment" == -* ]]; then
      break
    fi

    if [[ -d "$command_path/$segment" ]]; then
      command_path="$command_path/$segment"
      continue
    fi

    if [[ -f "$command_path/$segment" && -x "$command_path/$segment" ]]; then
      command_path="$command_path/$segment"
    fi

    break
  done

  if [[ -f "$command_path" && -x "$command_path" ]]; then
    while IFS= read -r metadata; do
      [[ "$metadata" == '# @option '* ]] || continue
      option_text="${metadata#\# @option }"
      option_spec=$(printf '%s\n' "$option_text" |
        awk -F '[[:space:]][[:space:]]+' '{print $1}')
      option_names=$(printf '%s\n' "$option_spec" |
        sed -E 's/[[:space:]]+<[^>]+>//g; s/,/ /g')
      read -r -a parsed_options <<< "$option_names"
      options+=("${parsed_options[@]}")
    done < "$command_path"

    COMPREPLY=()
    for candidate in "${options[@]}"; do
      [[ "$candidate" == "$current"* ]] && COMPREPLY+=("$candidate")
    done
    return
  fi

  for entry in "$command_path"/*; do
    [[ -e "$entry" ]] || continue
    [[ "${entry##*/}" == _* ]] && continue

    if [[ -d "$entry" || -x "$entry" ]]; then
      candidates+=("${entry##*/}")
    fi
  done

  COMPREPLY=()
  for candidate in "${candidates[@]}"; do
    [[ "$candidate" == "$current"* ]] && COMPREPLY+=("$candidate")
  done
}

complete -F _@FUNCTION@ @NAME@
COMPLETION
}

install_completion() {
  local generator="$1"
  local directory="$2"
  local filename="$3"
  local label="$4"
  local completion_file="$directory/$filename"
  local temporary_file

  mkdir -p "$directory"
  temporary_file=$(mktemp "$directory/.$filename.XXXXXX")

  if ! "$generator" "$temporary_file"; then
    rm -f "$temporary_file"
    return 1
  fi

  chmod 644 "$temporary_file"
  mv "$temporary_file" "$completion_file"
  echo "Installed $label completion: $completion_file"
}

shotor_install_completions() {
  local name="$1"
  local oh_my_zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
  local custom_dir installed=false data_home zsh_completion_dir bash_completion_root

  if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "install-completions: invalid dispatcher name: $name" >&2
    return 2
  fi

  if [[ -n "${ZSH_CUSTOM:-}" || -d "$oh_my_zsh_dir" ]]; then
    custom_dir="${ZSH_CUSTOM:-$oh_my_zsh_dir/custom}"
    install_completion \
      generate_zsh_completion \
      "$custom_dir/completions" \
      "_$name" \
      "Oh My Zsh"
    echo "Restart Zsh to activate it: exec zsh"
    return 0
  fi

  data_home="${XDG_DATA_HOME:-$HOME/.local/share}"

  if command -v zsh >/dev/null 2>&1; then
    zsh_completion_dir="$data_home/zsh/site-functions"
    install_completion \
      generate_zsh_completion \
      "$zsh_completion_dir" \
      "_$name" \
      "Zsh"
    echo "Add this directory to fpath before compinit: $zsh_completion_dir"
    installed=true
  fi

  if command -v bash >/dev/null 2>&1; then
    bash_completion_root="${BASH_COMPLETION_USER_DIR:-$data_home/bash-completion}"
    bash_completion_root="${bash_completion_root%%:*}"
    install_completion \
      generate_bash_completion \
      "$bash_completion_root/completions" \
      "$name" \
      "Bash"
    echo "Restart Bash to activate it: exec bash"
    installed=true
  fi

  if [[ "$installed" == false ]]; then
    echo "install-completions: neither Zsh nor Bash was found" >&2
    return 1
  fi
}
