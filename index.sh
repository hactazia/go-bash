#!/bin/bash

## Make a Go board with shell script

# board data matrix
declare -A board
# width and height of the board
width=19
height=19
# enum for cell state
EMPTY=0
BLACK=1
WHITE=2
# enum display character with color code
EMPTY_CHAR="."
BLACK_CHAR="X"
WHITE_CHAR="O"
# cursor position
cursor_x=0
cursor_y=0
# enum cursor frames
CURSOR_FRAMES=("▲" "►" "▼" "◄")

# get cursor frame from time
get_cursor_frame() {
    local frame_index=$(($(date +%s) % ${#CURSOR_FRAMES[@]}))
    echo ${CURSOR_FRAMES[$frame_index]}
}

# fill the board with empty cells

fill_board() {
    for ((i = 0; i < height; i++)); do
        for ((j = 0; j < width; j++)); do
            board[$i, $j]=$EMPTY
        done
    done
}

# print the board
print_board() {
    # print board, cell by cell and overwrite by te cursor if needed
    for ((i = 0; i < height; i++)); do
        for ((j = 0; j < width; j++)); do
            if [ $i -eq $cursor_x ] && [ $j -eq $cursor_y ]; then
                echo -n "$(get_cursor_frame) "
            else
                case $(get_cell $i $j) in
                $EMPTY) echo -n "$EMPTY_CHAR " ;;
                $BLACK) echo -n "$BLACK_CHAR " ;;
                $WHITE) echo -n "$WHITE_CHAR " ;;
                esac
            fi
        done
        echo ""
    done
}

get_cell() {
    local x=$1
    local y=$2
    echo ${board[$x, $y]}
}

set_cell() {
    local x=$1
    local y=$2
    local state=$3
    board[$x, $y]=$state
}

# move cursor
move_cursor() {
    local x=$1
    local y=$2
    cursor_x=$x
    cursor_y=$y
    tput cup $((cursor_x + 1)) $((cursor_y * 2 + 1))
}

can_move_cursor() {
    local x=$1
    local y=$2
    if [ $x -ge 0 ] && [ $x -lt $height ] && [ $y -ge 0 ] && [ $y -lt $width ]; then
        return 0
    else
        return 1
    fi
}

# game loop

game_loop() {
    while true; do
        clear
        print_board
        move_cursor $cursor_x $cursor_y
        read -rsn1 input
        case $input in
        A)
            if can_move_cursor $((cursor_x - 1)) $cursor_y; then
                cursor_x=$((cursor_x - 1))
            fi
            ;;
        B)
            if can_move_cursor $((cursor_x + 1)) $cursor_y; then
                cursor_x=$((cursor_x + 1))
            fi
            ;;
        C)
            if can_move_cursor $cursor_x $((cursor_y + 1)); then
                cursor_y=$((cursor_y + 1))
            fi
            ;;
        D)
            if can_move_cursor $cursor_x $((cursor_y - 1)); then
                cursor_y=$((cursor_y - 1))
            fi
            ;;
        esac
    done
}

# main function

main() {
    fill_board
    game_loop
}

main
