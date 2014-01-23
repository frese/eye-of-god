#!/bin/sh
# Retrive various system temperatues. Mac OS X
# I use an app from http://www.bresink.com/osx/TemperatureMonitor.html
# but would prefere to use build in "ioreg" - but cannot figureout how. ?? Info appriciated !
/Applications/TemperatureMonitor.app/Contents/MacOS/tempmonitor -tv|cut -d, -f2-

