#!/bin/bash

ws() {
	local persistent=(1 2 3 4 5 6)
	local output=""

	# Fast membership check for persistent IDs
	declare -A persistent_set=()
	for wsid in "${persistent[@]}"; do
		persistent_set[$wsid]=1
	done

	workspace_data=$(hyprctl workspaces -j)
	current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

	# Get all workspace IDs reported by Hyprland (sorted ascending)
	mapfile -t all_ws_ids < <(echo "$workspace_data" | jq -r '.[].id' | sort -n)

	# Merge persistent list with whatever Hyprland reports, deduped
	mapfile -t ws_to_show < <(printf "%s\n" "${persistent[@]}" "${all_ws_ids[@]}" | sort -nu)

	# Function to decide class
	get_class() {
		local wsid=$1
		local windows=$2

		if [[ "$current_workspace" == "$wsid" ]]; then
			echo "workspace-active"
		elif [[ -n "${persistent_set[$wsid]}" ]]; then
			if [[ "$windows" -gt 0 ]]; then
				echo "workspace"
			else
				echo "workspace-empty"
			fi
		elif [[ "$windows" -gt 0 ]]; then
			echo "workspace"
		else
			echo ""
		fi
	}

	# Build output string for all workspaces to show in numeric order
	for wsid in "${ws_to_show[@]}"; do
		# Skip negative workspace IDs (Special Workspaces)
		if ((wsid < 0)); then
			continue
		fi

		windows=$(echo "$workspace_data" | jq -r --argjson id "$wsid" '[.[] | select(.id == $id)] | .[0]?.windows // 0')

		# Decide if this workspace should be shown
		if [[ -n "${persistent_set[$wsid]}" ]]; then
			should_show=1
		elif [[ "$current_workspace" == "$wsid" || "$windows" -gt 0 ]]; then
			should_show=1
		else
			should_show=0
		fi

		if [[ "$should_show" -ne 1 ]]; then
			continue
		fi

		# Label: filled circle for active, hollow for others
		if [[ "$current_workspace" == "$wsid" ]]; then
			label=""
		else
			label=""
		fi

		cls=$(get_class "$wsid" "$windows")

		# Append to output only if class is non-empty
		if [[ -n "$cls" ]]; then
			output+="(eventbox :class \"workspace-e\" :cursor \"pointer\" :onclick \"hyprctl dispatch workspace $wsid\" (label :class \"$cls\" :text \"$label\"))"
		fi
	done

	echo "(box :halign 'start' :orientation 'h' $output)"
}

XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

HYPRLAND_SIGNATURE_ACTUAL=$(ls -td "$XDG_RUNTIME_DIR/hypr/"*/ 2>/dev/null | head -n1 | xargs -r basename)

if [[ -z "$HYPRLAND_SIGNATURE_ACTUAL" ]]; then
	echo "No Hyprland socket found. Exiting."
	exit 1
fi

SOCKET="$XDG_RUNTIME_DIR/hypr/${HYPRLAND_SIGNATURE_ACTUAL}/.socket2.sock"

ws

stdbuf -oL socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do
	case $line in
	"workspace>>"* | "createworkspace>>"* | "destroyworkspace>>"* | "movewindow>>"* | "closewindow>>"* | "openwindow>>"*)
		ws
		;;
	esac
done
