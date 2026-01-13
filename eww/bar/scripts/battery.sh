#!/bin/bash

get_battery_info() {
	# Find the battery path (usually /org/freedesktop/UPower/devices/battery_BAT0 or similar)
	bat_path=$(upower -e | grep 'BAT' | head -n 1)
	
	if [ -z "$bat_path" ]; then
		echo "{\"status\": \"unknown\", \"percent\": 0, \"icon\": \"\"}"
		return
	fi

	upower_output=$(upower -i "$bat_path")
	state=$(echo "$upower_output" | grep "state" | awk '{print $2}')
	# percentage might have a % sign, remove it
	percent=$(echo "$upower_output" | grep "percentage" | awk '{print $2}' | tr -d '%')

	if [ -z "$percent" ]; then percent=0; fi

	icon=""
	if [[ "$state" == "charging" || "$state" == "fully-charged" ]]; then
		if [ $(echo "$percent" | awk '{print ($1 > 80)}') -eq 1 ]; then
			icon=""
		elif [ $(echo "$percent" | awk '{print ($1 > 60)}') -eq 1 ]; then
			icon="" 
		elif [ $(echo "$percent" | awk '{print ($1 > 40)}') -eq 1 ]; then
			icon=""
		elif [ $(echo "$percent" | awk '{print ($1 > 20)}') -eq 1 ]; then
			icon="" 
		else
			icon="" 
		fi
	else
		if [ $(echo "$percent" | awk '{print ($1 > 80)}') -eq 1 ]; then
			icon=""
		elif [ $(echo "$percent" | awk '{print ($1 > 60)}') -eq 1 ]; then
			icon=""
		elif [ $(echo "$percent" | awk '{print ($1 > 40)}') -eq 1 ]; then
			icon=""
		elif [ $(echo "$percent" | awk '{print ($1 > 20)}') -eq 1 ]; then
			icon=""
		else
			icon=""
		fi
	fi

	echo "{\"status\": \"$state\", \"percent\": $percent, \"icon\": \"$icon\"}"
}

get_battery_info

# Monitor specific battery path for changes, or just monitor all and trigger update
upower --monitor | while read -r line; do
	# We could filter for our battery, but any power event probably warrants a check
	if [[ "$line" == *"BAT"* || "$line" == *"line-power"* ]]; then
		get_battery_info
	fi
done
