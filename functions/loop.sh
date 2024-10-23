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
                # successive stone-laying (rule 2)
                local x=$(get_cursor_x)
                local y=$(get_cursor_y)
                try_place_stone $x $y $current_player
                local result=$?
                if (($result == 0)); then
                    set_pass $current_player 0
                    print_cell $x $y 1
                    place_message "Player $(get_dispay_name $current_player) placed a stone at $x $y"
                    local data=($(update_neiboors $x $y $current_player 0))
                    local data_length=$(count_in_group ${data[@]})
                    if [ $data_length -gt 0 ]; then
                        place_message "Player $(get_dispay_name $current_player) captured $data_length stones"
                    fi
                    local i=0
                    while [ $i -lt ${#data[@]} ]; do
                        set_cell ${data[$i]} ${data[$i + 1]} $EMPTY
                        print_cell ${data[$i]} ${data[$i + 1]} 1
                        i=$((i + 2))
                    done
                    next_player
                    print_current_player
                    elif (($result == 1)); then
                    place_message "Out of bounds"
                    elif (($result == 2)); then
                    place_message "Cell is occupied"
                    elif (($result == 3)); then
                    place_message "Invalid move, suicide"
                    elif (($result ==4)); then
                    place_message "No more stones left, pass your turn"
                fi
            ;;
            'e')
                place_message "Exiting..."
                break
            ;;
            'r')
                place_message "Reprinting the board..."
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
                    place_message "Both players passed, game over"

                    place_message "$(get_dispay_name $BLACK) score: $(get_score $BLACK)"
                    place_message "$(get_dispay_name $WHITE) score: $(get_score $WHITE)"
                    break
                    exit 0
                else
                    place_message "Player $(get_dispay_name $current_player) pass..."
                    next_player
                    print_current_player
                fi
            ;;
            'n')
                place_message "New game..."
                init_game
                init_print_board
                print_current_player
            ;;
            'g')
                # debug of the rule 3 (group)
                get_cell $cursor_x $cursor_y
                if [ $? -eq $EMPTY ]; then
                    tput cup 0 0
                    echo -ne "\e[0KCell is empty"
                    continue
                fi
                local group=($(get_group $cursor_x $cursor_y 0))
                local group_length=$(count_in_group ${group[@]})
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
                # debug of the rule ? (liberties)
                get_cell $cursor_x $cursor_y
                if [ $? -eq $EMPTY ]; then
                    tput cup 0 0
                    echo -ne "\e[0KCell is empty"
                    continue
                fi
                local group=($(get_group $cursor_x $cursor_y 0))
                local liberties=($(get_liberties ${group[@]}))
                local liberties_length=$(count_in_group ${liberties[@]})
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
            't')
                # debug of the rule 4 (territory)
                get_cell $cursor_x $cursor_y
                if [ $? -eq $EMPTY ]; then
                    tput cup 0 0
                    echo -ne "\e[0KCell is empty"
                    continue
                fi
                local territory=($(get_territory $cursor_x $cursor_y 0))
                local territory_length=$(count_in_group ${territory[@]})    
                tput cup 0 0
                echo -ne "\e[0KTerritory: ${territory[@]} (${territory_length})"
                i=0
                while [ $i -lt ${#territory[@]} ]; do
                    local x=${territory[$i]}
                    local y=${territory[$i + 1]}
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
