#!/bin/sh
set -eu

if [ "$(uname -s)" != "Darwin" ]; then
  exit 0
fi

conf_line="$(tmux show-environment -g TMUX_CONF_LOCAL 2>/dev/null || true)"
conf_file=""
case "$conf_line" in
  TMUX_CONF_LOCAL=*)
    conf_file="${conf_line#TMUX_CONF_LOCAL=}"
    ;;
esac
if [ -z "$conf_file" ]; then
  conf_file="/Users/andreca/.tmux.conf.local"
fi

get_conf() {
  key="$1"
  awk -v k="$key" '
    index($0, k "=") == 1 {
      v = substr($0, length(k) + 2)
      gsub(/^[ \t]+/, "", v)
      gsub(/[ \t]+$/, "", v)
      if (v ~ /^"/) {
        v = substr(v, 2)
        split(v, a, "\"")
        v = a[1]
      } else if (v ~ /^'\''/) {
        v = substr(v, 2)
        split(v, a, "'\''")
        v = a[1]
      } else {
        split(v, a, /[ \t]+/)
        v = a[1]
      }
      print v
      exit
    }
  ' "$conf_file" 2>/dev/null || true
}

c1="$(get_conf tmux_conf_theme_colour_1)"
c2="$(get_conf tmux_conf_theme_colour_2)"
c3="$(get_conf tmux_conf_theme_colour_3)"
c4="$(get_conf tmux_conf_theme_colour_4)"
c7="$(get_conf tmux_conf_theme_colour_7)"

appearance="light"
if [ "${1:-}" = "light" ] || [ "${1:-}" = "dark" ]; then
  appearance="$1"
elif defaults read -g AppleInterfaceStyle >/dev/null 2>&1; then
  appearance="dark"
fi

prev="$(tmux show-options -gqv @ui_appearance 2>/dev/null || true)"
if [ "$appearance" = "dark" ]; then
  status_bg="$c1"
  status_fg="$c3"
  left_fg="$c7"
  left_bg="$c1"
  tab_idx_bg="$c2"
  tab_idx_fg="$c3"
  tab_name_bg="$c1"
  tab_name_fg="$c7"
  tab_active_idx_bg="$c4"
  tab_active_idx_fg="$c1"
  tab_active_name_bg="$c1"
  tab_active_name_fg="$c7"
  expected_status_style="fg=${status_fg},bg=${status_bg},none"
  expected_status_bg="$status_bg"
  expected_status_fg="$status_fg"
  expected_window_current_format="#[fg=${tab_active_idx_fg},bg=${tab_active_idx_bg}] #I #[fg=${tab_active_name_fg},bg=${tab_active_name_bg}] #W #[fg=${status_fg},bg=${status_bg},none]"
  current_status_style="$(tmux show-options -gqv status-style 2>/dev/null || true)"
  current_status_bg="$(tmux show-options -gqv status-bg 2>/dev/null || true)"
  current_status_fg="$(tmux show-options -gqv status-fg 2>/dev/null || true)"
  current_window_current_format="$(tmux show-options -gwqv window-status-current-format 2>/dev/null || true)"
  if [ "$prev" = "$appearance" ] && [ "$current_status_style" = "$expected_status_style" ] && [ "$current_status_bg" = "$expected_status_bg" ] && [ "$current_status_fg" = "$expected_status_fg" ] && [ "$current_window_current_format" = "$expected_window_current_format" ]; then
    exit 0
  fi
  if [ "$prev" != "$appearance" ]; then
    tmux set -g @ui_appearance "$appearance"
  fi
  tmux set -g status-bg "$status_bg"
  tmux set -g status-fg "$status_fg"
  tmux set -g status-style "$expected_status_style"
  tmux set -g status-left-style "fg=${left_fg},bg=${left_bg},none"
  tmux set -g status-right-style "fg=${status_fg},bg=${status_bg},none"
  tmux setw -g pane-border-style "fg=${tab_idx_bg}"
  tmux setw -g pane-active-border-style "fg=${tab_active_idx_bg}"
  tmux setw -g window-status-separator ""
  tmux setw -g window-status-style "fg=${status_fg},bg=${status_bg},none"
  tmux setw -g window-status-current-style "fg=${tab_active_name_fg},bg=${tab_active_name_bg},none"
  tmux setw -g window-status-format "#[fg=${tab_idx_fg},bg=${tab_idx_bg}] #I #[fg=${tab_name_fg},bg=${tab_name_bg}] #W #[fg=${status_fg},bg=${status_bg},none]"
  tmux setw -g window-status-current-format "$expected_window_current_format"
else
  status_bg="$c7"
  status_fg="$c3"
  left_fg="$c1"
  left_bg="$status_bg"
  tab_idx_bg="$c3"
  tab_idx_fg="$c1"
  tab_name_bg="$c7"
  tab_name_fg="$c1"
  tab_active_idx_bg="$c4"
  tab_active_idx_fg="$c1"
  tab_active_name_bg="$c7"
  tab_active_name_fg="$c1"
  expected_status_style="fg=${status_fg},bg=${status_bg},none"
  expected_status_bg="$status_bg"
  expected_status_fg="$status_fg"
  expected_window_current_format="#[fg=${tab_active_idx_fg},bg=${tab_active_idx_bg}] #I #[fg=${tab_active_name_fg},bg=${tab_active_name_bg}] #W #[fg=${status_fg},bg=${status_bg},none]"
  current_status_style="$(tmux show-options -gqv status-style 2>/dev/null || true)"
  current_status_bg="$(tmux show-options -gqv status-bg 2>/dev/null || true)"
  current_status_fg="$(tmux show-options -gqv status-fg 2>/dev/null || true)"
  current_window_current_format="$(tmux show-options -gwqv window-status-current-format 2>/dev/null || true)"
  if [ "$prev" = "$appearance" ] && [ "$current_status_style" = "$expected_status_style" ] && [ "$current_status_bg" = "$expected_status_bg" ] && [ "$current_status_fg" = "$expected_status_fg" ] && [ "$current_window_current_format" = "$expected_window_current_format" ]; then
    exit 0
  fi
  if [ "$prev" != "$appearance" ]; then
    tmux set -g @ui_appearance "$appearance"
  fi
  tmux set -g status-bg "$status_bg"
  tmux set -g status-fg "$status_fg"
  tmux set -g status-style "$expected_status_style"
  tmux set -g status-left-style "fg=${left_fg},bg=${left_bg},none"
  tmux set -g status-right-style "fg=${status_fg},bg=${status_bg},none"
  tmux setw -g pane-border-style "fg=${status_fg}"
  tmux setw -g pane-active-border-style "fg=${tab_active_idx_bg}"
  tmux setw -g window-status-separator ""
  tmux setw -g window-status-style "fg=${status_fg},bg=${status_bg},none"
  tmux setw -g window-status-current-style "fg=${tab_active_name_fg},bg=${tab_active_name_bg},none"
  tmux setw -g window-status-format "#[fg=${tab_idx_fg},bg=${tab_idx_bg}] #I #[fg=${tab_name_fg},bg=${tab_name_bg}] #W #[fg=${status_fg},bg=${status_bg},none]"
  tmux setw -g window-status-current-format "$expected_window_current_format"
fi

tmux set -g status-right-length 0
