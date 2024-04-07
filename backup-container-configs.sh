#!/bin/bash

# Change this part to suit your folder naming structure
autocomposedir=$(pwd)
yamlbackupdir="yaml-backups"

SECONDS=0
CODE_SAVE_CURSOR="\033[s"
CODE_RESTORE_CURSOR="\033[u"
CODE_CURSOR_IN_SCROLL_AREA="\033[1A"
COLOR_FG="\e[30m"
COLOR_BG="\e[42m"
RESTORE_FG="\e[39m"
RESTORE_BG="\e[49m"
TRAPPING_ENABLED="false"
ETA_ENABLED="false"
TRAP_SET="false"
CURRENT_NR_LINES=0
PROGRESS_TITLE=""
PROGRESS_TOTAL=100
PROGRESS_START=0

setup_scroll_area() {
    if [ "$TRAPPING_ENABLED" = "true" ]; then
        trap_on_interrupt
    fi
    [ -n "$1" ] && PROGRESS_TITLE="$1" || PROGRESS_TITLE="Progress"
    [ -n "$2" ] && PROGRESS_TOTAL=$2 || PROGRESS_TOTAL=100
    lines=$(tput lines)
    CURRENT_NR_LINES=$lines
    let lines=$lines-1
    echo -en "\n"
    echo -en "$CODE_SAVE_CURSOR"
    echo -en "\033[0;${lines}r"
    echo -en "$CODE_RESTORE_CURSOR"
    echo -en "$CODE_CURSOR_IN_SCROLL_AREA"
    if [ "$ETA_ENABLED" = "true" ]; then
      PROGRESS_START=$( date +%s )
    fi
    draw_progress_bar 0
}

destroy_scroll_area() {
    lines=$(tput lines)
    echo -en "$CODE_SAVE_CURSOR"
    echo -en "\033[0;${lines}r"
    echo -en "$CODE_RESTORE_CURSOR"
    echo -en "$CODE_CURSOR_IN_SCROLL_AREA"
    clear_progress_bar
    echo -en "\n\n"
    PROGRESS_TITLE=""
    if [ "$TRAP_SET" = "true" ]; then
        trap - INT
    fi
}

format_eta() {
    local T=$1
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    [ $D -eq 0 -a $H -eq 0 -a $M -eq 0 -a $S -eq 0 ] && echo "--:--:--" && return
    [ $D -gt 0 ] && printf '%d days, ' $D
    printf 'ETA: %d:%02.f:%02.f' $H $M $S
}

draw_progress_bar() {
    eta=""
    if [ "$ETA_ENABLED" = "true" -a $1 -gt 0 ]; then
        let running_time=$(date +%s)-PROGRESS_START
        let total_time=PROGRESS_TOTAL*running_time/$1
        eta=$( format_eta $(($total_time-$running_time)) )
    fi
    percentage=$1
    if [ $PROGRESS_TOTAL -ne 100 ]
    then
        [ $PROGRESS_TOTAL -eq 0 ] && percentage=100 || let percentage=percentage*100/$PROGRESS_TOTAL
    fi
    extra=$2
    lines=$(tput lines)
    let lines=$lines
    if [ "$lines" -ne "$CURRENT_NR_LINES" ]; then
        setup_scroll_area
    fi
    echo -en "$CODE_SAVE_CURSOR"
    echo -en "\033[${lines};0f"
    tput el
    print_bar_text $percentage "$extra" "$eta"
    echo -en "$CODE_RESTORE_CURSOR"
}

clear_progress_bar() {
    lines=$(tput lines)
    let lines=$lines
    echo -en "$CODE_SAVE_CURSOR"
    echo -en "\033[${lines};0f"
    tput el
    echo -en "$CODE_RESTORE_CURSOR"
}

print_bar_text() {
    local percentage=$1
    local extra=$2
    [ -n "$extra" ] && extra=" ($extra)"
    local eta=$3
    if [ -n "$eta" ]; then
        [ -n "$extra" ] && extra="$extra "
        extra="$extra$eta"
    fi
    local cols=$(tput cols)
    let bar_size=$cols-9-${#PROGRESS_TITLE}-${#extra}
    local color="${COLOR_FG}${COLOR_BG}"
    let complete_size=($bar_size*$percentage)/100
    let remainder_size=$bar_size-$complete_size
    progress_bar=$(echo -ne "["; echo -en "${color}"; printf_new "#" $complete_size; echo -en "${RESTORE_FG}${RESTORE_BG}"; printf_new "." $remainder_size; echo -ne "]");
    echo -ne " $PROGRESS_TITLE ${percentage}% ${progress_bar}${extra}"
}

enable_trapping() {
    TRAPPING_ENABLED="true"
}

trap_on_interrupt() {
    TRAP_SET="true"
    trap cleanup_on_interrupt INT
}

cleanup_on_interrupt() {
    destroy_scroll_area
    exit
}

printf_new() {
    str=$1
    num=$2
    v=$(printf "%-${num}s" "$str")
    echo -ne "${v// /$str}"
}

docker_config_backup() {
    IFS=$'\n'
    containers=$(docker ps -a --format "{{.ID}} {{.Names}}" | sort -k 2)
    dockerupcounter=1
    MAX=$(docker info --format "{{json .Containers}}")
    [ -n "$1" ] && MAX=$1
    enable_trapping
    ETA_ENABLED="true"
    setup_scroll_area "Backing up: " $MAX

    echo "Started container config backup on: $(date +%d-%b-%Y\ %H:%M:%S\ %p\ %Z)"
    echo ================================
    echo "Backing up to base folder  : $autocomposedir/$yamlbackupdir"
    echo "Using datetime format      : DD-MM-YYYY HH-MM-SS AM/PM TIMEZONE"
    echo "Total containers to backup : $MAX"
    echo ================================
    echo ""

    for container in $containers
        do
        IFS=$' '
        containerID=($container)
        echo "$dockerupcounter/$MAX: $container"
        datefolder=$(date +%Y)/$(date +%m)-$(date +%B)/$(date +%d)
        mkdir -p "$autocomposedir/$yamlbackupdir/$datefolder/${containerID[1]}/${containerID[0]}"

        sudo python3 $autocomposedir/autocompose.py ${containerID[0]} > "$autocomposedir/$yamlbackupdir/$datefolder/${containerID[1]}/${containerID[0]}/$(date +%H-%M-%S\ %p\ %Z).yaml"

        dockerupcounter=$(expr $dockerupcounter + 1)
        draw_progress_bar $dockerupcounter "$( date "+%r" )| $dockerupcounter on $MAX"
    done
    
    destroy_scroll_area
    echo ================================
    echo "Backup completed : $(date +%d-%b-%Y\ %H:%M:%S\ %p\ %Z)" >> $autocomposedir/$yamlbackupdir/backups.log

    echo "Backup completed : $(date +%d-%b-%Y\ %H:%M:%S\ %p\ %Z)"
    echo "Backup time took : $SECONDS seconds"

    ## Change this part to suit your rclone config
    # echo "Backing up to Dropbox using rclone.."
    # rclone copy -P $autocomposedir/$yamlbackupdir docker-yamls:Backup/$yamlbackupdir
    
    IFS=$' \t\n'
}

docker_config_backup
