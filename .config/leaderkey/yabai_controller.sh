#!/bin/zsh

switch_workspace() {
    spaces=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $spaces["$1"] ]] && yabai -m space --focus $spaces["$1"]

    sleep 0.5
    local space_index=$spaces["$1"]
    local first_window=$(yabai -m query --windows --space $space_index | jq '[.[] | select(.is-minimized == false)] | sort_by(.frame.x, .frame.y) | .[0].id')

    if [[ "$first_window" != "null" && -n "$first_window" ]]; then
        yabai -m window --focus $first_window
    fi
}

focus_window() {
    # west, south, north or east
    yabai -m window --focus "$1" || yabai -m display --focus "$1"
}

move_to_workspace() {
    spaces=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $spaces["$1"] ]] && yabai -m window --space $spaces["$1"]
}

move_in_workspace() {
    yabai -m window --warp "$1" || $(yabai -m window --display "$1" && yabai -m display --focus "$1" && yabai -m window --warp last)
}

zen_mode() {
    local window_info=$(yabai -m query --windows --window)
    local display_index=$(echo "$window_info" | jq '.display')
    local display_info=$(yabai -m query --displays --display $display_index)

    local width=$(echo "$display_info" | jq '.frame.w')

    yabai -m window --toggle float
    if [[ $width -gt 3000 ]]; then
        yabai -m window --grid 12:12:3:0:6:12
    else
        yabai -m window --grid 8:8:1:0:6:8
    fi
}

toggle_layout() {
    current_layout=$(yabai -m query --spaces --space | jq -r ".type"); if [ "$current_layout" = "bsp" ]; then yabai -m space --layout float; else yabai -m space --layout bsp; fi
}

reset_desktop() {
    local displays=($(yabai -m query --displays | jq '.[].index'))
    local spaces=($(yabai -m query --spaces | jq '.[] | select(.index > 1) | .index' | sort -nr))
    for space in $spaces; do
        yabai -m space $space --destroy
    done

    for display in $displays; do
        yabai -m display --focus $display
        for ((i=1; i<=3; i++)); do
            yabai -m space --create
        done
    done

    local app_list=(
        "Slack:1:5"
        "Asana:1:1"
        "Logseq:1:2"
        "Ghostty:2:6"
        "Firefox:3:7"
        "Zed:4:8"
    )

    local is_multi_display=0
    if [[ ${#displays[@]} -gt 1 ]]; then
        is_multi_display=1
    fi

    for app_config in $app_list; do
        local app_name=$(echo $app_config | cut -d: -f1)
        local single_space=$(echo $app_config | cut -d: -f2)
        local multi_space=$(echo $app_config | cut -d: -f3)

        local target_space=$single_space
        if [[ $is_multi_display -eq 1 && -n "$multi_space" ]]; then
            target_space=$multi_space
        fi

        local window_ids=($(yabai -m query --windows | jq --arg app "$app_name" '.[] | select(.app == $app) | .id'))

        for window_id in $window_ids; do
            if [[ -n "$window_id" ]]; then
                yabai -m window $window_id --space $target_space
            fi
        done
    done

    yabai --restart-service
    brew services restart sketchybar
}

get_all_windows_per_app() {
    yabai -m query --windows | jq --arg app "$1" '.[] | select(.app == $app) | .id'
}

move_windows() {
    for window in $1; do
        if [[ -n "$window" ]]; then
            yabai -m window $window --space $2
        fi
    done
}

command="$1"
shift

# Switch statement to handle commands
case "$command" in
    "select_workspace")
        if [[ $# -eq 0 ]]; then
            exit 0
        else
            switch_workspace "$1"
        fi
        ;;
    "select_Window")
        if [[ $# -eq 0 ]]; then
            exit 0
        else
            focus_window "$1"
        fi
        ;;
    "move_to_workspace")
        if [[ $# -eq 0 ]]; then
            exit 0
        else
            move_to_workspace "$1"
        fi
        ;;
    "move_in_workspace")
        if [[ $# -eq 0 ]]; then
            exit 0
        else
            move_in_workspace "$1"
        fi
        ;;
    "zen")
        zen_mode
        ;;
    "toggle")
        toggle_layout
        ;;
    "rebuild")
        reset_desktop
        ;;
    *)
        exit 0
        ;;
    esac
exit 0
