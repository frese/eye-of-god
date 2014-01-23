#!/bin/sh
LC_NUMERIC=en_US uptime|awk '{print $(NF-2)}'|tr -d ","

