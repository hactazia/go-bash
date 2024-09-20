# if is executed as main, print error
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    echo "This script is not meant to be executed directly."
    exit 1
fi

# Constants of Go game

# Neigbors
readonly dx=(-1 1 0 0)
readonly dy=(0 0 -1 1)

# Cell state (enum)
readonly EMPTY=0
readonly BLACK=1
readonly WHITE=2

# Cell chars (enum)
readonly EMPTY_CHAR="\e[1;30m·\e[0m"
readonly HOSHI_CHAR="\e[1;30m+\e[0m"
readonly BLACK_CHAR="\e[1;31m○\e[0m"
readonly WHITE_CHAR="\e[1;34m●\e[0m"
readonly DEBUG_CHAR="\e[1;33mX\e[0m"

# Cell display (enum)
readonly EMPTY_NAME="Empty"
readonly BLACK_NAME="\e[1;31mBlack\e[0m"
readonly WHITE_NAME="\e[1;34mWhite\e[0m"

# Cell status (enum)
readonly DEAD=0
readonly ALIVE=1

# Other display constants
readonly PADDING=" "
