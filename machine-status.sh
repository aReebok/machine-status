#!/bin/bash

## Preamble
#  print out date and time -----

function cur_date () {
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
        timedatectl status | grep "NTP"

        if [ $? = 1 ]
        then
            echo --- NTP not set up
        fi

        echo
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

function disk_space () {
    # print out disk space and memory
    echo
    echo ----- $'\033[1;36m'DISKS OVER CAPACITY OF 20% $'\033[0m'-----------------------------------------
    df -h | head -n 1 && df -h | awk '0+$5 >= 20 {print}'
}

function mem_usage () {
    # output: mem_usage: out of Xgb, in use ~Y%
    total_mem=$(free -th | grep "Total" | cut -d " " -f 11)
    total_mem_n=$(echo ${total_mem} | sed 's/[^0-9]*//g')
    used_mem=$(free -th | grep "Total" | cut -d " " -f 19)
    used_mem_n=$(echo ${used_mem} | sed 's/[^0-9]*//g')

    percent_mem=$( echo "scale=0; ${used_mem_n}*100 / ${total_mem_n}"  | bc )

    echo "Memory usage: Out of ${total_mem}, in use ~${percent_mem}%"
}

function logs_status () {
    echo
    echo ----- ERROR LOGS ---------------------------------------------------------

    journalctl -xe | grep "failed\|failed:\|error\|fail" ## it could check for services. 
} 
    
function main (){
    cur_date
    preamble
    services
    disk_space
    mem_usage
    logs_status
} 

main
