#!/bin/bash

mac="$1"

if [[ -z "$mac" ]]; then
    echo "Usage: $0 <mac-address>" >&2
    exit 1
fi

connected=$(bluetoothctl info "$mac" 2>/dev/null | awk '/^\s*Connected:/ {print $2; exit}')

if [[ "$connected" == "yes" ]]; then
    bluetoothctl disconnect "$mac"
else
    bluetoothctl connect "$mac"
fi
