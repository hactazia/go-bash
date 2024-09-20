# if is executed as main, print error
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    echo "This script is not meant to be executed directly."
    exit 1
fi

# Cursor functions for game

# Cursor position
get_cursor_x() {
    echo $cursor_x
}

get_cursor_y() {
    echo $cursor_y
}

set_cursor_x() {
    cursor_x=$1
}

set_cursor_y() {
    cursor_y=$1
}

# Move the cursor to the position
try_move_cursor() {
    local x=$1
    local y=$2
    is_valid $x $y
    if [ $? -eq 1 ]; then
        set_cursor_x $x
        set_cursor_y $y
        return 1
    fi
    return 0
}

try_move_cursor_relative() {
    local cdx=$1
    local cdy=$2
    local x=$((cursor_x + cdx))
    local y=$((cursor_y + cdy))
    try_move_cursor $x $y
    return $?
}