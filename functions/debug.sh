print_debug() {
    if [ $debug -eq 1 ]; then
        local msg=$1
        msg=$(echo -e "$msg" | sed "s/\x1B\[[0-9;]*[a-zA-Z]//g")
        echo $msg >> debug.log
    fi
}