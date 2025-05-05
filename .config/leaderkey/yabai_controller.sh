#!/bin/zsh

switch_workspace() {
    SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $SPACES["$1"] ]] && yabai -m space --focus $SPACES["$1"]

    sleep 0.1
    local space_index=$SPACES["$1"]
    local first_window=$(yabai -m query --windows --space $space_index | jq '[.[] | select(.minimized == 0)] | sort_by(.frame.x, .frame.y) | .[0].id')

    if [[ "$first_window" != "null" && -n "$first_window" ]]; then
        yabai -m window --focus $first_window
    fi
}

focus_window() {
    # west, south, north or east
    yabai -m window --focus "$1" || yabai -m display --focus "$1"
}

move_to_workspace() {
    SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $SPACES["$1"] ]] && yabai -m window --space $SPACES["$1"]
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
    DISPLAYS=($(yabai -m query --displays | jq '.[].index'))
    SPACES=($(yabai -m query --spaces | jq '.[] | select(.index > 1) | .index' | sort -nr))
    for space in $SPACES; do
        yabai -m space $space --destroy
    done

    for display in $DISPLAYS; do
        yabai -m display --focus $display
        for ((i=1; i<=3; i++)); do
            yabai -m space --create
        done
    done

    CHAT="Slack"
    TERMINAL="Ghostty"
    BROWSER="Firefox"
    EDITOR="Zed"

    chat_windows=($(yabai -m query --windows | jq --arg app "$CHAT" '.[] | select(.app == $app) | .id'))
    for window in $chat_windows; do
        yabai -m window $window --space 4
    done

    terminal_windows=($(yabai -m query --windows | jq --arg app "$TERMINAL" '.[] | select(.app == $app) | .id'))
    for window in $terminal_windows; do
        yabai -m window $window --space 2
    done

    browser_windows=($(yabai -m query --windows | jq --arg app "$BROWSER" '.[] | select(.app == $app) | .id'))
    for window in $browser_windows; do
        yabai -m window $window --space 3
    done

    editor_windows=($(yabai -m query --windows | jq --arg app "$EDITOR" '.[] | select(.app == $app) | .id'))
    for window in $editor_windows; do
        yabai -m window $window --space 4
    done

    yabai --restart-service
    brew services restart sketchybar
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
