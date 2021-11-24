#!/bin/bash

## Preamble
#  print out date and time -----


function preamble () {
    #  print out hostname and ip address
    echo -n "Hostname: ${HOSTNAME} @ ip address: "
    ip ad | grep 127.0.0. | cut -d " " -f 6 | cut -d "/" -f 1 | head -n 1
    hostnamectl | grep "Operating System"
    echo
}

### SERVICES 
    function ntp_status () {
        #  print out NTP status    -----
        echo SERVICES
        echo -n ">>  " 
        timedatectl status | grep "NTP"
        if [ $? = 1 ]
        then
            echo "NTP not set up."
        fi
}        
    function fail2ban () {
        echo -n ">>  fail2ban: "

        FILE=/etc/init.d/fail2ban

        if test -f "$FILE"; then
            /etc/init.d/fail2ban status | grep "active (running)\|inactive" | cut -d " " -f 5
        else
            echo "not set up."
        fi
        echo 
    }

function services () {
    ntp_status
    fail2ban
}

function disk_space() {
    df_lines=$(df -h)
    root_line=$(df -h | grep -w '/')
        root_name=$(root_line | awk '{print $1}')
        root_size=$(root_line | awk '{print $2}')
        root_usage=$(root_line | awk '{print $5}')
        echo ROOT SPACE
        echo "root (/) of size ${root_size} is ${root_usage} full.\n"
    # print out disk space and memory
    echo DISKS OVER CAPACITY OF 80%
        ${df_lines} | awk '0+$5 >= 80 {print $1, $2, $5, $6}' | column -t
        echo
}


function mem_usage () {
    # output: mem_usage: out of Xgb, in use ~Y%
    total_mem=$(free -th | grep "Mem:" | awk '{print $2}' | numfmt --from=iec) 
    used_mem=$(free -th | grep "Mem:" | awk '{print $3}' | numfmt --from=iec)
    percent_mem=$((used_mem * 100))
    percent_mem=$((percent_mem / total_mem))

    echo "Memory usage: Out of $(echo "${total_mem}" | numfmt --to=iec), in use is $(echo "${used_mem}" | numfmt --to=iec) ~ ${percent_mem}%"
    echo
}

function log_status () {
    # output: error logs up to n days ago

    n_days=10
    curr_date=$( date | cut -d " " -f 2-3 | date -d "$1" +%F )
    a_week_ago=$( date -d "${curr_date} - ${n_days} day" +%F )

    echo "Error logs from ${n_days} day{s} from today -------"
    errors="$(journalctl -xe | grep "failed\|failed:\|error\|fail")" ## it could check for services. 

    i=${curr_date}
    while [[ ${i} != ${a_week_ago} ]]
    do
        temp_date=$( date --date="${i}" +%c | awk  '{print $3, $2}')
        log_output=$( echo ${errors} | grep "${temp_date}" )   # | awk '{print $0, "\n"}'  # prints new line after each grep.
        log_output="${log_output//${temp_date}/$'\n'${temp_date}}" # needed to print new lines for every output 
        if [[ $( echo ${log_output} | awk '{print length}' ) != 0 ]]; then
            echo -n "$temp_date"
            echo "$log_output" | cut -d ";" -f 1 | awk '{$1=$2=$3=$4=$5=""; print $0}'
        fi

        i=$( date -d "${i} - 1 day" +%F )
    done

} 
    
function main (){
    date
    preamble
    services
    timeout 5s disk_space
    mem_usage
    log_status
} 

main
