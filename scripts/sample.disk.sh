#!/bin/sh
# Will get all disks mounted on "/|realtime|home|var" and print the mount point
# followed by space used - (fix the "/" characters ! - not supported by RRDtool in DS names)
df -h|grep "/dev/"|awk '/\/$|realtime|home|var$|usr\/local$/ {print substr($NF,2)":"$(NF-1)}'| \
tr -d "%"|sed 's/^:/root[meta test]:/'|sed 's/\//_/'

