#!/usr/bin/env bash

prev_is_clip=false

while true; do
  cls="$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')"

  if [ "$cls" = "clipse" ]; then
    prev_is_clip=true
  else
    if [ "$prev_is_clip" = true ]; then
      # just left a clipse window → close it
      hyprctl dispatch closewindow class:clipse
    fi
    prev_is_clip=false
  fi

  sleep 0.1
done
