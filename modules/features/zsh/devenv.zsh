__devenv_reload_apply() {
    if [ -n "$DEVENV_RELOAD_FILE" ] && [ -f "$DEVENV_RELOAD_FILE" ]; then
        local output
        output=$(DEVENV_RELOAD_FILE="$DEVENV_RELOAD_FILE" bash <<'RELOAD_BASH' 2>/dev/null
__devenv_ignored_var() {
    case "$1" in
        _*|PWD|OLDPWD|SHLVL|SHELL|SHELLOPTS|BASHOPTS|BASH_*|HISTCMD|HISTFILE)
            return 0 ;;
        PS1|PS2|PS3|PS4|PROMPT|PROMPT_COMMAND|PROMPT_DIRTRIM)
            return 0 ;;
        COMP_*|READLINE_*|MAILCHECK|COLUMNS|LINES|RANDOM|SECONDS|LINENO|EPOCHSECONDS|EPOCHREALTIME|SRANDOM)
            return 0 ;;
        STARSHIP_*|__fish*|DIRENV_*|nix_saved_*)
            return 0 ;;
        *)  return 1 ;;
    esac
}
__devenv_capture_env() { declare -p -x 2>/dev/null | LC_ALL=C sort; }
__devenv_serialize_diff() { gzip -c | base64 -w0; }
__devenv_deserialize_diff() { echo "$1" | base64 -d | gzip -d 2>/dev/null; }
__devenv_compute_diff() {
    local before_file="$1" after_file diff_content
    after_file=$(mktemp); diff_content=$(mktemp)
    __devenv_capture_env > "$after_file"
    local -A before_vars after_vars
    while IFS= read -r line; do
        [[ "$line" != declare\ -x\ * ]] && continue
        local vardef="${line#declare -x }" var="${vardef%%=*}"
        [[ -z "$var" ]] && continue
        __devenv_ignored_var "$var" && continue
        before_vars["$var"]="$line"
    done < "$before_file"
    while IFS= read -r line; do
        [[ "$line" != declare\ -x\ * ]] && continue
        local vardef="${line#declare -x }" var="${vardef%%=*}"
        [[ -z "$var" ]] && continue
        __devenv_ignored_var "$var" && continue
        after_vars["$var"]="$line"
    done < "$after_file"
    for var in "${!before_vars[@]}"; do
        [[ "${after_vars[$var]}" != "${before_vars[$var]}" ]] && echo "P:${before_vars[$var]}" >> "$diff_content"
    done
    for var in "${!after_vars[@]}"; do
        if [[ -z "${before_vars[$var]+x}" ]]; then echo "N:$var" >> "$diff_content"
        elif [[ "${after_vars[$var]}" != "${before_vars[$var]}" ]]; then echo "N:$var" >> "$diff_content"; fi
    done
    _DEVENV_DIFF=$(__devenv_serialize_diff < "$diff_content"); export _DEVENV_DIFF
    rm -f "$after_file" "$diff_content"
}
__devenv_apply_reverse_diff() {
    [[ -z "$_DEVENV_DIFF" ]] && return
    local -A prev_vars
    local diff_content; diff_content=$(__devenv_deserialize_diff "$_DEVENV_DIFF")
    while IFS= read -r line; do
        if [[ "$line" == P:declare\ * ]]; then
            local decl="${line#P:}" var="${decl#declare -x }"; var="${var%%=*}"
            prev_vars["$var"]=1; eval "export ${decl#declare -x }" 2>/dev/null
        fi
    done <<< "$diff_content"
    while IFS= read -r line; do
        if [[ "$line" == N:* ]]; then
            local var="${line#N:}"
            [[ -z "${prev_vars[$var]+x}" ]] && unset "$var"
        fi
    done <<< "$diff_content"
}
__devenv_apply_reverse_diff
_before=$(mktemp); __devenv_capture_env > "$_before"
if { : >/dev/tty; } 2>/dev/null; then _devenv_reload_out=/dev/tty; else _devenv_reload_out=/dev/null; fi
source "$DEVENV_RELOAD_FILE" >"$_devenv_reload_out" 2>"$_devenv_reload_out"
rm -f "$DEVENV_RELOAD_FILE"; unset _devenv_reload_out
__devenv_compute_diff "$_before"; rm -f "$_before"
export -p
RELOAD_BASH
)
        if [ -n "$output" ]; then eval "$output"; fi
        _DEVENV_PATH="$PATH"
    fi
}
__devenv_restore_path() {
    [ -n "$_DEVENV_PATH" ] && export PATH="$_DEVENV_PATH"
}

