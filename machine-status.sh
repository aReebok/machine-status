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
    echo
    echo ----- MEMORY USAGE -------------------------------------------------------
    for line in "total" "Mem:" "Swap:" "Total:"
    do
        free -th | grep ${line} | cut -d " " -f -35 | tr '\n' ' ' && free -th | grep ${line} | cut -d " " -f 40-50
    done
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
    root_space
    disk_space
    mem_usage
    logs_status
} 

main

