#!/bin/sh
now=`date -v -1M +%H:%M`
logfile=/var/log/system.log
filter="mac"

tail -10 $logfile|grep "$filter"|grep $now|wc -l|tr -d " "
