#!/usr/bin/env sh

# Auto-detect distro
if [ -f /etc/fedora-release ]; then
  DISTRO="fedora"
elif [ -f /etc/arch-release ]; then
  DISTRO="arch"
  AUR_HELPER="yay"
else
  DISTRO="unknown"
fi

UPDATES_DIR="/tmp/updates"
ICON="󰮯"
INTERVAL_MINUTES=200

# Exit early on snapshot boots (Arch btrfs specific)
if grep -q 'subvol=@/.snapshots' /proc/cmdline 2>/dev/null; then
  exit
fi

mkdir -p "$UPDATES_DIR"

check_and_write_updates() {
  case "$DISTRO" in
    fedora)
      # DNF updates
      ofc=$(dnf check-update -q 2>/dev/null \
            | grep -v "^$" \
            | tee "$UPDATES_DIR/official_list" \
            | wc -l)
      echo "$ofc" > "$UPDATES_DIR/official"
      # No AUR on Fedora
      echo "0" > "$UPDATES_DIR/aur"
      : > "$UPDATES_DIR/aur_list"
      ;;
    arch)
      # Official repos
      ofc=$(CHECKUPDATES_DB=$(mktemp -u) checkupdates 2>/dev/null \
            | tee "$UPDATES_DIR/official_list" \
            | wc -l)
      echo "$ofc" > "$UPDATES_DIR/official"
      # AUR
      aur=$($AUR_HELPER -Qua 2>/dev/null \
            | grep -v '\[ignored\]' \
            | tee "$UPDATES_DIR/aur_list" \
            | wc -l)
      echo "$aur" > "$UPDATES_DIR/aur"
      ;;
    *)
      echo "0" > "$UPDATES_DIR/official"
      echo "0" > "$UPDATES_DIR/aur"
      : > "$UPDATES_DIR/official_list"
      : > "$UPDATES_DIR/aur_list"
      ;;
  esac

  # Flatpak
  if command -v flatpak >/dev/null 2>&1; then
    flatpak remote-ls --updates 2>/dev/null \
      | tee "$UPDATES_DIR/flatpak_list" >/dev/null
    fpk=$(wc -l < "$UPDATES_DIR/flatpak_list")
  else
    fpk=0
    : > "$UPDATES_DIR/flatpak_list"
  fi
  echo "$fpk" > "$UPDATES_DIR/flatpak"
}

boldify_ascii() {
  INPUT="$1"
  echo "$INPUT" | perl -CS -pe '
    s/([A-Z])/chr(ord($1) + 0x1D400 - ord("A"))/ge;
    s/([a-z])/chr(ord($1) + 0x1D41A - ord("a"))/ge;
  '
}

generate_json_output() {
  ofc=$(< "$UPDATES_DIR/official")
  aur=$(< "$UPDATES_DIR/aur")
  fpk=$(< "$UPDATES_DIR/flatpak")
  total=$((ofc + aur + fpk))

  if (( total == 0 )); then
    echo "{\"icon\": \"\", \"count\": \"\", \"tooltip\": \"\"}"
    return
  fi

  tooltip=$(
    cat "$UPDATES_DIR"/{official_list,aur_list,flatpak_list} 2>/dev/null \
    | sed '/^$/d' \
    | while IFS= read -r line; do
        pkg="${line%% *}"
        rest="${line#* }"
        boldpkg=$(boldify_ascii "$pkg")
        printf '%s %s\n' "$boldpkg" "$rest"
      done \
    | sed -z 's/\n/\\n/g' \
    | sed -E 's|</?b>||g' \
    | sed -E 's|<span[^>]*>||g' \
    | sed -E 's|</span>||g'
  )

  # Remove trailing \n at end if any
  tooltip="${tooltip%\\n}"

  echo "{\"icon\": \"${ICON}\", \"count\": \"${total}\", \"tooltip\": \"$tooltip\"}"
}

# --- Main loop ---
while true; do
  check_and_write_updates
  generate_json_output
  sleep $((INTERVAL_MINUTES * 60))
done
