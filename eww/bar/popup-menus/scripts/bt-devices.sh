#!/bin/bash

print_devices() {
    paired_output=$(bluetoothctl devices Paired)

    if [[ -z "$paired_output" ]]; then
        jq -nc -c '[]'
        return
    fi

    echo "$paired_output" | while IFS= read -r line; do
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d ' ' -f3-)

        info=$(bluetoothctl info "$mac")
        connected=$(echo "$info" | awk '/^\s*Connected:/ {print $2; exit}')
        trusted=$(echo "$info" | awk '/^\s*Trusted:/ {print $2; exit}')

        name=${name:-$mac}
        [[ "$connected" == "yes" ]] && connected=true || connected=false
        [[ "$trusted" == "yes" ]] && trusted=true || trusted=false

        jq -nc \
            --arg name "$name" \
            --arg mac "$mac" \
            --argjson connected "$connected" \
            --argjson trusted "$trusted" \
            '{name:$name,address:$mac,connected:$connected,trusted:$trusted}'
    done | jq -c -s '.'
}

print_devices

bluetoothctl --monitor | while read -r _; do
    print_devices
done
