# if is executed as main, print error
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    echo "This script is not meant to be executed directly."
    exit 1
fi

# Display functions for game

# print all cells of the board
init_print_board() {
    clear
    place_message "\e[1;30mPreparing the board...\e[0m"

    # print the top border
    place_cursor $((offset_x - 1)) $((offset_y - 1))
    local border="┌"
    for ((i = 0; i < width; i++)); do
        border+="──"
    done
    border+="─┐"
    echo -en $border

    # print the bottom border
    place_cursor $((height + offset_x)) $((offset_y - 1))
    border="└"
    for ((i = 0; i < width; i++)); do
        border+="──"
    done
    border+="─┘"
    echo -en $border

    # print the left and right border
    for ((i = 0; i < height; i++)); do
        place_cursor $((i + offset_x)) $((offset_y - 1))
        echo -ne "│"
        place_cursor $((i + offset_x)) $((width + offset_y))
        echo -ne "│"
    done

    # print cells
    for ((i = 0; i < height; i++)); do
        for ((j = 0; j < width; j++)); do
            print_cell $i $j 0
        done
    done

    # place hoshi points
    for i in "${hoshi_points[@]}"; do
        local x=$(echo $i | cut -d, -f1)
        local y=$(echo $i | cut -d, -f2)
        get_cell $x $y
        if [ $? -eq $EMPTY ]; then
            place_cursor $((x + offset_x)) $((y + offset_y))
            echo -ne $HOSHI_CHAR
        fi
    done

}

_ich="0"
declare -A _ach

is_hoshi() {
    local x=$1
    local y=$2

    for i in "${hoshi_points[@]}"; do
        local hoshi_x=$(echo $i | cut -d, -f1)
        local hoshi_y=$(echo $i | cut -d, -f2)
        if [ $x -eq $hoshi_x ] && [ $y -eq $hoshi_y ]; then
            return 1
        fi
    done
    return 0
}

# print the cell at the position
print_cell() {
    local x=$1
    local y=$2
    local debug=$3
    # if debug == 1, check_hoshi = 1
    # if debug == 2, print DEBUG_CHAR
    local check_hoshi=0
    place_cursor $((x + offset_x)) $((y + offset_y))
    if [ $debug -eq 1 ]; then
        check_hoshi=1
        get_cell $x $y
        echo -ne $(get_print_char $? 1)
    elif [ $debug -eq 2 ]; then
        echo -ne $DEBUG_CHAR
    else
        get_cell $x $y
        echo -ne $(get_print_char $? 0)
    fi
}

get_dispay_name() {
    local player=$1
    if [ $player -eq $BLACK ]; then
        echo $BLACK_NAME
    elif [ $player -eq $WHITE ]; then
        echo $WHITE_NAME
    elif [ $player -eq $EMPTY ]; then
        echo $EMPTY_NAME
    fi
}

get_print_char() {
    local state=$1
    local check_hoshi=$2
    if [ $state -eq $EMPTY ]; then
        if [ $check_hoshi -eq 1 ]; then
            is_hoshi $x $y
            if [ $? -eq 1 ]; then
                echo $HOSHI_CHAR
            else
                echo $EMPTY_CHAR
            fi
        else
            echo $EMPTY_CHAR
        fi
    elif [ $state -eq $BLACK ]; then
        echo $BLACK_CHAR
    elif [ $state -eq $WHITE ]; then
        echo $WHITE_CHAR
    fi
}

place_cursor() {
    local x=$1
    local y=$2
    tput cup $((x + 1)) $((y * 2 + 1))
}

place_message() {
    local msg=$1
    message_history+=("$msg")

    # remove old messages if there are too many
    if [ ${#message_history[@]} -gt $((max_message_length - 1)) ]; then
        message_history=("${message_history[@]:1}")
    fi

    print_messages
}

print_messages() {
    for ((i = 0; i < ${#message_history[@]}; i++)); do
        local message=${message_history[$i]}
        local x=$((offset_x + height + 3 + i))
        # get length of the message without color codes
        local length=$(echo -ne "$message" | sed "s/\x1B\[[0-9;]*[a-zA-Z]//g" | wc -c)
        local center=$((($(get_term_width) - length) / 2))
        tput cup $x 0
        echo -ne "\e[0K"
        tput cup $x $center
        echo -ne "$message"
    done
    echo -e "\n\e[0m"
}

print_current_player() {
    place_message "\e[1;30mPlayer $(get_dispay_name $current_player)\e[1;30m turn\e[0m"
}

print_tips() {
    tput cup $(get_term_height) 0
    echo -ne "\e[1;30mZQSD to move the cursor, A to place a stone, E to exit, R to recenter the board, P to pass, N to restart\e[0m"
}

get_term_width() {
    tput cols
}

get_term_height() {
    tput lines
}

get_best_offest_x() {
    return $((($(get_term_height) / 2) / 2))
}

get_best_offest_y() {
    return $((($(get_term_width) / 2 - width) / 2))
}
