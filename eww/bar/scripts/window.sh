#!/usr/bin/env bash
set -euo pipefail

mode=${1:-title}
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/eww-window"
mkdir -p "$cache_dir"

log_icon() {
  # Send icon value to stderr so it appears in eww logs without poll pollution.
  printf '[window.sh] icon="%s"\n' "$1" >&2
}

fallback_icon() {
  for path in \
    "/usr/share/icons/Adwaita/32x32/places/user-desktop.png" \
    "/usr/share/icons/hicolor/32x32/places/user-desktop.png" \
    "/usr/share/icons/Adwaita/32x32/status/dialog-question.png" \
    "/usr/share/icons/hicolor/32x32/status/dialog-question.png" \
    "/usr/share/pixmaps/question.png"; do
    [[ -f "$path" ]] && { echo "$path"; return 0; }
  done
  echo ""
}

active_json=$(hyprctl activewindow -j 2>/dev/null || true)

title="Desktop"
class=""
icon=""

if [[ -n "$active_json" && "$active_json" != "null" ]]; then
  title=$(jq -r '.title // empty' <<<"$active_json")
  class=$(jq -r '.initialClass // .class // empty' <<<"$active_json")

  if [[ -z "$title" || "$title" == "null" ]]; then
    title="$class"
  fi
  if [[ -z "$title" || "$title" == "null" ]]; then
    title="Desktop"
  fi
fi

max_len=30
if (( ${#title} > max_len )); then
  title="${title:0:max_len-3}..."
fi

# Icon resolution is kept client-side and cached to avoid repeated disk scans.
icon_from_cache() {
  local key="$1"
  local cache_file="$cache_dir/${key}.path"
  [[ -f "$cache_file" ]] || return 1
  local cached
  cached=$(<"$cache_file")
  [[ -n "$cached" && -f "$cached" ]] || return 1
  echo "$cached"
  return 0
}

resolve_desktop_icon_name() {
  local cls="$1"
  for dir in "$HOME/.local/share/applications" "/usr/share/applications"; do
    [[ -d "$dir" ]] || continue
    local desktop
    desktop=$(grep -ril "^StartupWMClass=${cls}$" "$dir" 2>/dev/null | head -n1 || true)
    [[ -z "$desktop" ]] && continue
    local icon
    icon=$(grep -i '^Icon=' "$desktop" | head -n1 | cut -d= -f2-)
    [[ -n "$icon" ]] && { echo "$icon"; return 0; }
  done
  return 1
}

resolve_icon_path() {
  local name="$1"
  [[ -z "$name" || "$name" == "null" ]] && return 1
  if [[ "$name" == /* && -f "$name" ]]; then
    echo "$name"
    return 0
  fi

  local theme
  theme=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || true)
  theme=${theme//\"/}
  theme=${theme//\'/}
  theme=${theme:-Adwaita}

  local themes=("$theme" "hicolor" "Adwaita")
  local sizes=("64x64" "48x48" "32x32" "24x24" "16x16" "scalable")
  local contexts=("apps" "categories" "status" "mimetypes" "actions" "places")
  local exts=("png" "svg" "xpm")

  IFS=: read -ra data_dirs <<<"${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
  data_dirs=("$HOME/.local/share" "${data_dirs[@]}")

  for candidate in "$name" "${name}-symbolic"; do
    for dir in "${data_dirs[@]}"; do
      for current_theme in "${themes[@]}"; do
        for size in "${sizes[@]}"; do
          for ctx in "${contexts[@]}"; do
            for ext in "${exts[@]}"; do
              local path="$dir/icons/$current_theme/$size/$ctx/${candidate}.${ext}"
              if [[ -f "$path" ]]; then
                echo "$path"
                return 0
              fi
            done
          done
        done
      done
      for ext in "${exts[@]}"; do
        local path="$dir/pixmaps/${candidate}.${ext}"
        if [[ -f "$path" ]]; then
          echo "$path"
          return 0
        fi
      done
    done
  done

  return 1
}

resolve_icon() {
  local resolved_icon=""

  if [[ "$title" == "Desktop" || -z "$class" || "$class" == "null" ]]; then
    echo ""
    return 0
  fi

  local desktop_icon_name
  desktop_icon_name=$(resolve_desktop_icon_name "$class" || true)

  declare -a candidates
  [[ -n "$desktop_icon_name" ]] && candidates+=("$desktop_icon_name")
  for item in "$class" "${class,,}" "${class%%.*}" "${class,,%%.*}" "$title" "${title,,}"; do
    [[ -n "$item" && "$item" != "null" ]] && candidates+=("$item")
  done
  candidates+=("application-default-icon" "application-x-executable" "dialog-question")

  declare -A seen
  for cand in "${candidates[@]}"; do
    [[ -n "$cand" ]] || continue
    [[ -n "${seen[$cand]:-}" ]] && continue
    seen[$cand]=1

    if icon_from_cache "$cand" >/dev/null 2>&1; then
      resolved_icon=$(icon_from_cache "$cand")
      break
    fi

    if icon_path=$(resolve_icon_path "$cand"); then
      resolved_icon="$icon_path"
      echo "$icon_path" >"$cache_dir/${cand}.path"
      break
    fi
  done

  if [[ -z "$resolved_icon" ]]; then
    resolved_icon=$(fallback_icon)
  fi

  echo "$resolved_icon"
}

if [[ "$mode" == "icon" || "$mode" == "json" ]]; then
  icon=$(resolve_icon)
fi

case "$mode" in
  title)
    echo "$title"
    ;;
  icon)
    log_icon "$icon"
    echo "$icon"
    ;;
  json)
    log_icon "$icon"
    jq -Rn --arg title "$title" --arg icon "$icon" '{title:$title, icon:$icon}'
    ;;
  *)
    echo "unknown mode: $mode" >&2
    exit 1
    ;;
esac
