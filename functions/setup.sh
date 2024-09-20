# if is executed as main, print error
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    echo "This script is not meant to be executed directly."
    exit 1
fi

# Setup functions for game

# Get the cell value of the matrix
get_cell() {
    local x=$1
    local y=$2
    return ${board[$x, $y]}
}

# Set the cell value of the matrix
set_cell() {
    local x=$1
    local y=$2
    local state=$3
    board[$x, $y]=$state
}

# Set the size of the board
set_size() {
    height=$1
    width=$2
    board=()
    for ((i = 0; i < height; i++)); do
        for ((j = 0; j < width; j++)); do
            board[$i, $j]=$EMPTY
        done
    done
}

# Initialize the board
init_board() {
    set_size $height $width
    for ((i = 0; i < height; i++)); do
        for ((j = 0; j < width; j++)); do
            set_cell $i $j $EMPTY
        done
    done
}

# check valid coordinates
is_valid() {
    local x=$1
    local y=$2
    if [ $x -ge 0 ] && [ $x -lt $height ] && [ $y -ge 0 ] && [ $y -lt $width ]; then
        return 1
    else
        return 0
    fi
}
