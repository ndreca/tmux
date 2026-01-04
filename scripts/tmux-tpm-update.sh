#!/bin/sh
set -eu

tmux_plugins_path=""
if tmux_plugins_path_line="$(tmux show-environment -g TMUX_PLUGIN_MANAGER_PATH 2>/dev/null)"; then
  case "$tmux_plugins_path_line" in
    TMUX_PLUGIN_MANAGER_PATH=*)
      tmux_plugins_path="${tmux_plugins_path_line#TMUX_PLUGIN_MANAGER_PATH=}"
      ;;
  esac
fi

candidates=""
if [ -n "$tmux_plugins_path" ]; then
  candidates="$tmux_plugins_path"
fi
candidates="$candidates /Users/andreca/.tmux/plugins /Users/andreca/.config/tmux/plugins"

for base in $candidates; do
  if [ -f "$base/tpm/bin/update_plugins" ]; then
    tmux display-message -d 2000 "TPM: updating plugins..."
    log_path="$base/tpm_log.txt"
    if command -v bash >/dev/null 2>&1; then
      bash "$base/tpm/bin/update_plugins" all >>"$log_path" 2>&1 || true
    else
      sh "$base/tpm/bin/update_plugins" all >>"$log_path" 2>&1 || true
    fi
    sh /Users/andreca/.config/tmux/scripts/tmux-sync-appearance.sh >/dev/null 2>&1 || true
    tmux display-message -d 5000 "TPM: update finished (log: $log_path)"
    exit 0
  fi
done

tmux display-message -d 5000 "TPM not installed (expected $tmux_plugins_path/tpm)."
