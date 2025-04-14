#!/bin/zsh

switch_workspace() {
    SPACES=($(yabai -m query --displays --display | jq '.spaces[]')) && [[ -n $SPACES["$1"] ]] && yabai -m space --focus $SPACES["$1"]
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
    yabai -m window --toggle float --grid 8:8:2:0:4:8
}

toggle_layout() {
    current_layout=$(yabai -m query --spaces --space | jq -r ".type"); if [ "$current_layout" = "bsp" ]; then yabai -m space --layout float; else yabai -m space --layout bsp; fi
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
    *)
        exit 0
        ;;
    esac
exit 0
