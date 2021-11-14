#!/bin/sh

while true
do
    cpu_usage=`top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}'`
    ram_usage=`free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }'`
    process_number=`ps aux | wc -l`

    stats='CPU:'$cpu_usage'- RAM:'$ram_usage'- PROCESS:'$process_number

    echo $stats | nc -q0 0.0.0.0 5000
    sleep 6
done