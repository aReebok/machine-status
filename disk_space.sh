#!/bin/bash

function disk_space() {
    echo "Checking disk space..."    
    df_lines=$(df -h)
    root_line=$(df_lines | grep -w '/')
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

disk_space