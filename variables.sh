# if is executed as main, print error
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    echo "This script is not meant to be executed directly."
    exit 1
fi

# Variables of Go game

# Current player
current_player=$BLACK
pass_black=0
pass_white=0
stone_black=$NB_BLACK
stone_white=$NB_WHITE

# Board size
height=19
width=19

# Hoshi points
hoshi_points=(
    "3,3" "3,9" "3,15"
    "9,3" "9,9" "9,15"
    "15,3" "15,9" "15,15"
)

# Cursor position
origin_cursor_x=0
origin_cursor_y=0
cursor_x=0
cursor_y=0
offset_x=5
offset_y=10

# Board matrix
declare -A board

# Display settings
debug=1
messages_history=()
max_message_length=6
