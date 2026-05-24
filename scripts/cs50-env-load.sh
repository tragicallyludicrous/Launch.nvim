# Source from ~/.bashrc to inject CS50_* env vars into login (SSH) shells.
# CS50 sets these via VS Code session hooks and rotates tokens periodically;
# SSH never gets the refresh. Read live values from a running VS Code server
# process when one exists; fall back to a static snapshot if not.
#
# Usage:
#   - Keep the codespace open in any VS Code session (tab in browser is fine)
#     so a server process is running and its env stays current.
#   - Generate a fallback snapshot from VS Code's integrated terminal once:
#       env | grep '^CS50_' | sed "s/^\([^=]*\)=\(.*\)$/export \1='\2'/" > ~/.cs50env
#   - SSH back in; CS50_* vars should be populated automatically.

_cs50_load_env() {
  local pid env_line key value loaded=

  for pid in $(pgrep -u "$USER" -f 'vscode|code-server' 2>/dev/null); do
    [ -r "/proc/$pid/environ" ] || continue
    while IFS= read -r -d '' env_line; do
      case "$env_line" in
        CS50_*)
          key="${env_line%%=*}"
          value="${env_line#*=}"
          export "$key=$value"
          loaded=1
          ;;
      esac
    done < "/proc/$pid/environ" 2>/dev/null
    [ -n "$loaded" ] && return 0
  done

  [ -f "$HOME/.cs50env" ] && . "$HOME/.cs50env"
}

_cs50_load_env
unset -f _cs50_load_env
