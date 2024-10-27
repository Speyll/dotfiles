#!/bin/sh

if pgrep -x "wlsunset" > /dev/null
then
    pkill -x wlsunset > /dev/null 2>&1
else
    wlsunset -l 36.7 -L 3.08 > /dev/null 2>&1 &
fi

