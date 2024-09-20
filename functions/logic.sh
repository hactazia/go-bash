# if is executed as main, print error
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    echo "This script is not meant to be executed directly."
    exit 1
fi

# Logic functions for game

# try to place a stone
try_place_stone() {
    local x=$1
    local y=$2
    local state=$3
    
    # check if the cell is valid
    is_valid $x $y
    if [ $? -eq 0 ]; then
        return 1
    fi
    
    # check if the cell is empty
    get_cell $x $y
    if [ $? -ne $EMPTY ]; then
        return 2
    fi
    
    # check if the group is dead
    set_cell $x $y $state
    local group=($(get_group $x $y 0))
    is_dead ${group[@]}
    if [ $? -eq 0 ]; then
        set_cell $x $y $EMPTY
        return 3
    fi
    return 0
}

# update the group neiboors of the cell
update_neiboors() {
    local x=$1
    local y=$2
    local state=$3
    local to_update=()
    
    for ((i = 0; i < 4; i++)); do
        local nx=$((x + dx[i]))
        local ny=$((y + dy[i]))
        
        is_valid $nx $ny
        if [ $? -eq 0 ]; then
            continue
        fi
        
        get_cell $nx $ny
        local cellstate=$?
        if [ $cellstate -eq $state ] || [ $cellstate -eq $EMPTY ]; then
            continue
        fi
        
        local group=($(get_group $nx $ny))
        is_dead ${group[@]}
        if [ $? -eq 0 ]; then
            to_update+=(${group[@]})
        fi
        
    done
    
    echo ${to_update[@]}
}

# get connected group of the cells with the same state (rule 3)
get_group() {
    local x=$1
    local y=$2
    get_cell $x $y
    local state=$?
    local queue=("$x $y")
    local group=()
    local visited=()
    while [ ${#queue[@]} -gt 0 ]; do
        local cell=${queue[0]}
        queue=("${queue[@]:1}")
        local cx=${cell%% *}
        local cy=${cell##* }
        is_in_group $cx $cy ${visited[@]}
        if [ $? -eq 1 ]; then
            continue
        fi
        visited+=("$cx $cy")
        is_valid $cx $cy
        if [ $? -eq 0 ]; then
            continue
        fi
        get_cell $cx $cy
        local cellstate=$?
        if [ $cellstate -ne $state ]; then
            continue
        fi
        group+=("$cx $cy")
        for ((i = 0; i < 4; i++)); do
            local nx=$((cx + dx[i]))
            local ny=$((cy + dy[i]))
            queue+=("$nx $ny")
        done
    done
    echo ${group[@]}
}
# get the territory of the cells with the same state (rule 4)
get_territory() {
    local x=$1
    local y=$2
    get_cell $x $y
    local state=$?
    local queue=("$x $y")
    local territory=()
    local visited=()
    while [ ${#queue[@]} -gt 0 ]; do
        local cell=${queue[0]}
        queue=("${queue[@]:1}")
        local cx=${cell%% *}
        local cy=${cell##* }
        is_in_group $cx $cy ${visited[@]}
        if [ $? -eq 1 ]; then
            continue
        fi
        visited+=("$cx $cy")
        is_valid $cx $cy
        if [ $? -eq 0 ]; then
            continue
        fi
        
        get_cell $cx $cy
        local cellstate=$?
        if [ $cellstate -ne $state ]; then
            print_debug "TERRITOTY: $cx $cy is not $(get_dispay_name $state)"
            
            # check if the cell is empty and add it to the territory for check if is in the territory
            if [ $cellstate -eq $EMPTY ]; then
                print_debug "TERRITOTY: $cx $cy is empty"
                set_cell $cx $cy $state
                local group=($(get_group $cx $cy))
                is_dead ${group[@]}
                if [ $? -eq 0 ]; then
                    print_debug "TERRITOTY: $cx $cy is dead if is $(get_dispay_name $state)"
                    territory+=(${group[@]})
                else
                    print_debug "TERRITOTY: $cx $cy check if is $(get_dispay_name $(inverse_state $state)) (inverse)"
                    set_cell $cx $cy $(inverse_state $state)
                    local group=($(get_group $cx $cy))
                    is_dead ${group[@]}
                    if [ $? -eq 0 ]; then
                        print_debug "TERRITOTY: $cx $cy is dead if is $(get_dispay_name $(inverse_state $state)) (inverse)"
                        territory+=(${group[@]})
                    fi
                fi
                set_cell $cx $cy $EMPTY
            fi
            continue
        fi
        
        territory+=("$cx $cy")
        for ((i = 0; i < 4; i++)); do
            local nx=$((cx + dx[i]))
            local ny=$((cy + dy[i]))
            queue+=("$nx $ny")
        done
    done
    echo ${territory[@]}
}

# check if the cell is in the group
is_in_group() {
    local x=$1
    local y=$2
    local l=("$@")
    i=2
    found=0
    while [ $i -lt ${#l[@]} ]; do
        local cx=${l[$i]}
        local cy=${l[$((i + 1))]}
        if [ $x -eq $cx ] && [ $y -eq $cy ]; then
            found=1
            i=${#l[@]}
        fi
        i=$((i + 2))
    done
    return $found
}

count_in_group() {
    local group=("$@")
    echo $(( ${#group[@]} / 2 ))
}

# get the number of liberties of the group
get_liberties() {
    local group=("$@")
    local liberties=()
    i=0
    while [ $i -lt ${#group[@]} ]; do
        local x=${group[$i]}
        local y=${group[$((i + 1))]}
        for ((j = 0; j < 4; j++)); do
            local nx=$((x + dx[j]))
            local ny=$((y + dy[j]))
            is_valid $nx $ny
            if [ $? -eq 0 ]; then
                continue
            fi
            get_cell $nx $ny
            local state=$?
            if [ $state -eq $EMPTY ]; then
                liberties+=("$nx $ny")
            fi
        done
        i=$((i + 2))
    done
    
    echo ${liberties[@]}
}

# check if the group is dead
is_dead() {
    local group=("$@")
    local liberties=($(get_liberties ${group[@]}))
    if [ ${#liberties[@]} -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# get score of
get_score() {
    local black_score=0
    local white_score=0
    for ((i = 0; i < height; i++)); do
        for ((j = 0; j < width; j++)); do
            echo $black_score $white_score
            get_cell $i $j
            if [ $? -eq $BLACK ]; then
                black_score=$((black_score + 1))
                elif [ $? -eq $WHITE ]; then
                white_score=$((white_score + 1))
            fi
        done
    done
    echo $black_score $white_score
}

next_player() {
    current_player=$(inverse_state $current_player)
}

init_game() {
    init_board
    set_cursor_x $((height / 2))
    set_cursor_y $((width / 2))
    
    pass_black=0
    pass_white=0
    
    # setup (rule 1)
    current_player=$BLACK
    nb_black=$NB_BLACK
    nb_white=$NB_WHITE
}

get_pass() {
    local player=$1
    if [ $player -eq $BLACK ]; then
        echo $pass_black
        elif [ $player -eq $WHITE ]; then
        echo $pass_white
    fi
}

set_pass() {
    local player=$1
    local pass=$2
    if [ $player -eq $BLACK ]; then
        pass_black=$pass
        elif [ $player -eq $WHITE ]; then
        pass_white=$pass
    fi
}

inverse_state() {
    local state=$1
    if [ $state -eq $BLACK ]; then
        echo $WHITE
        elif [ $state -eq $WHITE ]; then
        echo $BLACK
    fi
}