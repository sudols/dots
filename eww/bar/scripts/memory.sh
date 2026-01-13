#! /bin/bash

print_bytes() {
    if [ "$1" -le 1024000 ]; then
        # Under ~1 GiB: show MiB
        awk -v kb="$1" 'BEGIN { printf "%.2f MiB\n", kb/1024 }'
    else
        # Otherwise show GiB
        awk -v kb="$1" 'BEGIN { printf "%.2f GiB\n", kb/1048576 }'
    fi
}

mem_info=$(free -k | awk '/^Mem:/ {print $3}')

print_bytes "$mem_info"
