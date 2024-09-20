#!/bin/bash

# call constants file to get the constants
source constants.sh
source variables.sh
source functions/setup.sh
source functions/cursor.sh
source functions/logic.sh
source functions/display.sh
source functions/loop.sh

# main function

main() {
    height=19
    width=19

    get_best_offest_x
    offset_x=$?
    get_best_offest_y
    offset_y=$?

    place_message "\e[1;30mWelcome to the game of \e[1;31mGo\e[1;30m!\e[0m"

    # loop for the game
    loop
}

main
