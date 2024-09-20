# if is executed as main, print error
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    echo "This script is not meant to be executed directly."
    exit 1
fi

# Game loop functions

loop() {

    init_game
    init_print_board
    print_tips
    print_current_player

    while true; do
        place_cursor $((cursor_x + offset_x)) $((cursor_y + offset_y))
        read -rsn1 input
        case $input in
        'z')
            try_move_cursor_relative -1 0
            ;;
        's')
            try_move_cursor_relative 1 0
            ;;
        'd')
            try_move_cursor_relative 0 1
            ;;
        'q')
            try_move_cursor_relative 0 -1
            ;;
        'a')
            local x=$(get_cursor_x)
            local y=$(get_cursor_y)
            try_place_stone $x $y $current_player
            local result=$?
            if (($result == 0)); then
                set_pass $current_player 0
                print_cell $x $y 1
                place_message "\e[1;30mPlaced stone at ($x, $y)\e[0m"
                local data=($(update_neiboors $x $y $current_player 0))
                local i=0
                while [ $i -lt ${#data[@]} ]; do
                    set_cell ${data[$i]} ${data[$i + 1]} $EMPTY
                    print_cell ${data[$i]} ${data[$i + 1]} 1
                    i=$((i + 2))
                done
                next_player
                print_current_player
            elif (($result == 1)); then
                place_message "\e[1;30mInvalid move\e[0m"
            elif (($result == 2)); then
                place_message "\e[1;30mCell is not empty\e[0m"
            elif (($result == 3)); then
                place_message "\e[1;30mInvalid move, group is dead\e[0m"
            fi
            ;;
        'e')
            place_message "\e[1;30mExiting...\e[0m"
            break
            ;;
        'r')
            place_message "\e[1;30mReprinting the board...\e[0m"
            get_best_offest_x
            offset_x=$?
            get_best_offest_y
            offset_y=$?
            init_print_board
            print_tips
            ;;
        'p')
            local pass=$(get_pass $current_player)
            set_pass $current_player $((pass + 1))

            local passs=$((pass_black + pass_white))
            if [ $passs -gt 1 ]; then
                place_message "\e[1;30mBoth players passed, game over\e[0m"
                local black_score=0
                local white_score=0
                for ((i = 0; i < height; i++)); do
                    for ((j = 0; j < width; j++)); do
                        get_cell $i $j
                        if [ $? -eq $BLACK ]; then
                            black_score=$((black_score + 1))
                        elif [ $? -eq $WHITE ]; then
                            white_score=$((white_score + 1))
                        fi
                    done
                done
                place_message "\e[1;30mBlack: $black_score\e[0m"
                place_message "\e[1;30mWhite: $white_score\e[0m"
                break
                exit 0
            else
                place_message "\e[1;30mPlayer $(get_dispay_name $current_player)\e[1;30m pass...\e[0m"
                next_player
                print_current_player
            fi
            ;;
        'n')
            place_message "\e[1;30mNew game...\e[0m"
            init_game
            init_print_board
            print_current_player
            ;;
        'g')
            get_cell $cursor_x $cursor_y
            if [ $? -eq $EMPTY ]; then
                tput cup 0 0
                echo -ne "\e[0KCell is empty"
                continue
            fi
            local group=($(get_group $cursor_x $cursor_y 0))
            local group_length=$((${#group[@]} / 2))
            tput cup 0 0
            echo -ne "\e[0KGroup: ${group[@]} (${group_length})"
            i=0
            while [ $i -lt ${#group[@]} ]; do
                local x=${group[$i]}
                local y=${group[$i + 1]}
                print_cell $x $y 2
                i=$((i + 2))
            done
            ;;
        'l')
            get_cell $cursor_x $cursor_y
            if [ $? -eq $EMPTY ]; then
                tput cup 0 0
                echo -ne "\e[0KCell is empty"
                continue
            fi
            local group=($(get_group $cursor_x $cursor_y 0))
            local liberties=($(get_liberties ${group[@]}))
            local liberties_length=$((${#liberties[@]} / 2))
            tput cup 0 0
            echo -ne "\e[0KLiberties: ${liberties[@]} (${liberties_length})"
            i=0
            while [ $i -lt ${#liberties[@]} ]; do
                local x=${liberties[$i]}
                local y=${liberties[$i + 1]}
                print_cell $x $y 2
                i=$((i + 2))
            done
            ;;
        'y')
            set_cell $cursor_x $cursor_y $current_player
            print_cell $cursor_x $cursor_y 1
            tput cup 0 0
            echo -ne "\e[0KSet cell $cursor_x $cursor_y to $current_player"
            ;;
        esac
    done
}
