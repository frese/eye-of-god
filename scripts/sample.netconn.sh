#!/bin/sh
/usr/sbin/netstat -n|grep "^tcp4"|awk '{print $NF}'|sort|uniq -c|awk '{print $2":"$1}'
