#!/bin/bash

DIR=$(dirname $0)
echo $DIR

D=$(date '+%F %H:%M')

curl --user thomas:thohx1aekohTeiz 'http://192.168.20.148/status.html' 2>/dev/null > /tmp/status_station.html

if [ $? -eq 0 ]
then
    echo 1
    cat /tmp/status_station.html \
    | grep -E '(var cover_|var webdata_)'  \
    | sed '/webdata_rate_p/,/webdata_utime/d' \
    | sed 's#.* = "##; s#".*##; s# *##g; s#\([0-9]*\)%#0.\1#' \
    | tr '\n' ',' \
    | sed "s#^#${D},#" \
    | sed 's#,$#\n#;' \
    > /tmp/status_station_last.csv
    
    if  [ -s /tmp/status_station.html ] 
    then
        echo $DIR/../SQL/update_station.sql
        cat $DIR/../SQL/update_station.sql | mysql --user=solar --password=of9Aing7lec2uho3aiquahsa solar
    
    fi
fi
