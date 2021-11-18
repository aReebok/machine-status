#!/bin/bash

## Preamble
#  print out date and time -----

function print_date () {
    echo date
    echo
}

function preamble () {
    #  print out hostname and ip address
    echo -n "Hostname: ${HOSTNAME} @ ip address: "
    ip ad | grep 127.0.0. | cut -d " " -f 6 | cut -d "/" -f 1 | head -n 1
    echo 
    echo -n ">>"
    hostnamectl | grep "Operating System"

    echo
}

### SERVICES 
    function ntp_status () {
        #  print out NTP status    -----
        echo ----- $'\033[1;36m'Services $'\033[0m'----------------------------$
        echo -n ">>   NTP: " 
        timedatectl status | grep "NTP"

        if [ $? = 1 ]
        then
            echo $'\033[0;31m'NTP not set up.$'\033[0m'
        else
                echo "NTP is set up"
        fi

}        
    function fail2ban () {
        echo -n ">>  fail2ban: "

        FILE=/etc/init.d/fail2ban

        if test -f "$FILE"; then
            /etc/init.d/fail2ban status | grep "active (running)\|inactive" | cut -d " " -f 5
        else
            echo $'\033[0;31m'fail2ban not set up.$'\033[0m'
        fi

    }

function services () {
    ntp_status
    fail2ban
}

function root_space() {
    root_name=$(df -h | grep root | awk '{print $1}')
    root_size=$(df -h | grep root | awk '{print $2}')
    root_usage=$(df -h | grep root | awk '{print $5}')
    echo 
    echo ----- $'\033[1;36m'ROOT SPACE $'\033[0m'--------------
    echo "root (/) of size ${root_size} is ${root_usage} full."
}

function disk_space () {
    # print out disk space and memory
    echo
    echo ----- $'\033[1;36m'DISKS OVER CAPACITY OF 20% $'\033[0m'-----------------------------------------
    df -h | head -n 1 && df -h | awk '0+$5 >= 20 {print}'
}

function mem_usage () {
    # output: mem_usage: out of Xgb, in use ~Y%
    total_mem=$(free -th | grep "Total" | awk '{print $2}' | numfmt --from=iec) 
    used_mem=$(free -th | grep "Total" | awk '{print $3}' | numfmt --from=iec)
    percent_mem=$( echo "${used_mem} * 100 / ${total_mem}" | bc | numfmt --to=iec)

    echo "Memory usage: Out of $(echo "${total_mem}" | numfmt --to=iec), in use ~ ${percent_mem}%"
    
}

function log_status () {
    # output: error logs up to a week ago
    curr_date=$( date | cut -d " " -f 2-3 | date -d "$1" +%F )
    a_week_ago=$( date -d "${curr_date} - 7 day" +%F )

    echo "Error logs from this past week -------"
    errors=$(journalctl -xe | grep "failed\|failed:\|error\|fail") ## it could check for services. 

    i=${curr_date}
    while [[ ${i} != ${a_week_ago} ]]
    do
        temp_date=$( date --date="${i}" +%c | awk  '{print $3, $2}')
        echo ${errors} | grep ${temp_date} # | awk '{print $0, "\n"}'  # prints new line after each grep.
        echo "" 
        i=$( date -d "${i} - 1 day" +%F )
    done

} 
    
function main (){
    print_date
    preamble
    services
    root_space
    disk_space
    mem_usage
    log_status
} 

main
