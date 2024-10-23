#!/bin/bash

# detect use bash shell
if [ -z "$BASH_VERSION" ]; then
    echo "Please use /bin/bash shell to run this script"
    exit 1
fi

# detch if the cwd is the same as the script
if [ "$(pwd)" != "$(dirname $0)" ]; then
    cd "$(dirname $0)"
fi


# call constants file to get the constants
source ./constants.sh
source ./variables.sh
source ./functions/debug.sh
source ./functions/setup.sh
source ./functions/cursor.sh
source ./functions/logic.sh
source ./functions/display.sh
source ./functions/loop.sh

cleanup() {
    clear
    echo "Ctrl+C detected. Exiting gracefully..."
    exit 1
}
trap cleanup SIGINT

# main function

main() {

    get_best_offest_x
    offset_x=$?
    get_best_offest_y
    offset_y=$?

    place_message "Welcome to the game of \e[1;31mGo\e[0m!"

    # loop for the game
    loop
}

main