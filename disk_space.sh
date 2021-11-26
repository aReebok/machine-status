#!/bin/bash

function disk_space() {
    echo "Checking disk space..."

    root_line=$(df -h | grep -w '/')
    root_name=$(echo ${root_line} | awk '{print $1}')
    root_size=$(echo ${root_line} | awk '{print $2}')
    root_usage_percent=$(echo ${root_line} | awk '{print $5}')
    root_usage=$(echo ${root_line} | awk '{print $3}')
    
    #echo ROOT SPACE
    echo ">>  ${root_usage_percent} of root (/) in use [${root_usage}/${root_size}]"
   
    #root (/) of size ${root_size} is ${root_usage} full."
    # print out disk space and memory
    #echo DISKS OVER CAPACITY OF 80%
    #df -h | awk '0+$5 >= 80 {print $1, $2, $5, $6}' | column -t

    echo
}

disk_space
