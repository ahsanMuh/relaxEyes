#!/usr/bin/env bash
#set -ex

# relaxEyes.sh - Reminds you to relax your eyes.
#

INSTALL_DIR="$HOME/.local/bin"
DESKTOP_FILE="$HOME/.config/autostart/relaxEyes.desktop"

# defaults
BREAK_INTERVAL=20 # 20 seconds
INTERVAL=1200     # 20 minute
INCR=.70          # controls brightness

# set script name
RELAX_EYES_SH=$(basename "$0")

show_usage() {
    cat <<-EndUsage
        Usage: $RELAX_EYES_SH [OPTION]
        Reminds you to relax your eyes by adjusting monitor brightness.
        
        OPTION
          -d    Starts the reminder daemon.
          -h    Shows this help message.
          -r    Removes autostart configuration.
          -s    Configures autostart, so that script can start after you login.
    EndUsage
    exit 0
}

start_daemon() {
    interval="$1"
    break_interval="$2"
    incr="$3"

    while true; do
        sleep "$interval"
        output=$(xrandr | grep -w connected | awk '{print $1}')   # Get display name!
        decrease_brightness "$output" "$incr"
        sleep "$break_interval"
        increase_brightness "$output" "$incr"
    done
}

setup_autostart() {
    if ! [ -d "$HOME/.config/autostart" ]; then
        mkdir -p "$HOME/.config/autostart"
    fi

    # executable file
    exec_path="relaxEyes.sh"

    # checking PATH variable
    if [[ ! ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
        # INSTALL_DIR isn't on PATH
        # providing absolute path
        exec_path="$INSTALL_DIR/relaxEyes.sh"
    fi

    cat >"$DESKTOP_FILE" <<-EndFile
        [Desktop Entry]
        Type=Application
        Name=Relax Eyes
        Comment=Reminds you to relax your eyes
        Exec=$exec_path -d
        Terminal=false
        StartupNotify=false
    EndFile
    echo
    echo "Autostart configuration done and you'll be reminded to take a break."
    echo "Now save you work then logout and login again!"
    echo
    echo "Psst! Look out the window and enjoy the break time."
    exit 0
}

remove_autostart() {
    if [ -f "$DESKTOP_FILE" ]; then
        rm "$DESKTOP_FILE"
    fi
    echo
    echo "Removed autostart configuration and you won't be reminded to take break."
    echo "Now save your work then logout and login again!"
    exit 0
}

decrease_brightness() {
    echo "decreasing brightness!"
    output="$1"
    incr="$2"

    old_brightness=$(xrandr --verbose | grep rightness | awk '{ print $2 }' | head -n 1)
    bright=$(echo "scale=2; $old_brightness - $incr" | bc | head -n 1)

    for i in $output
    do
        xrandr --output "$i" --brightness "$bright"
    done

}

increase_brightness() {
    echo "increase brightness!"
    output="$1"
    incr="$2"

    old_brightness=$(xrandr --verbose | grep rightness | awk '{ print $2 }' | head -n 1)
    bright=$(echo "scale=2; $old_brightness + $incr" | bc | head -n 1)

    for i in $output
    do
        xrandr --output "$i" --brightness "$bright"
    done
}

if [[ -z "$1" || "$1" = "-h" || "$1" = "--help" ]]; then
    show_usage
elif [ "$1" = "-d" ]; then
    start_daemon "$INTERVAL" "$BREAK_INTERVAL" "$INCR"
elif [ "$1" = "-s" ]; then
    setup_autostart
elif [ "$1" = "-r" ]; then
    remove_autostart
else
    show_usage
fi

exit 0
