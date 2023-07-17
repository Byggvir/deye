#!/bin/bash

IP=10.10.100.254
USER=admin
PW=admin
SQLUSER=solar
SQLPW=solar

[ -f '/etc/deye.conf' ] && while read LINE; do export $LINE ; done < /etc/deye.conf

DIR=$(dirname $0)
D=$(date '+%F %H:%M')

curl --user "$USER:$PW" "http://$IP/status.html" 2> /dev/null > /tmp/status_station.html

if [ $? -eq 0 ]
then

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

        cat $DIR/../SQL/update_station.sql | mysql --user="$SQLUSER" --password="$SQLPW" solar
    
    fi
    
fi
