#!/bin/bash

IP=10.10.100.254
USER=admin
PW=admin
SQLUSER=solar
SQLPW=solar
DNS=solar.dyn.byggvir.de

[ -f '/etc/deye.conf' ] && while read LINE; do export $LINE ; done < /etc/deye.conf

D=$(date '+%F %H:%M')

curl --user "$USER:$PW" "http://$IP/status.html"
curl --user "$USER:$PW" "http://$IP/status.html" 2>/dev/null > /tmp/status.html
if [ $? -eq 0 ]
then
    cat /tmp/status.html \
    | grep 'var web' \
    | sed 's#.* = "##; s#".*##; s# *##g;' \
    | tr '\n' ',' \
    | sed "s#^#${D},#" \
    | sed 's#,$#\n#;' \
    > /tmp/deye_last.csv
    
    if  [ -s /tmp/status.html ] 
    then
    
        cat /tmp/deye_last.csv >>$HOME/deye.csv

        sudo -u www-data cp $HOME/deye.csv /var/www/vhosts/$DNS/deye.csv    
        ( cat << EOF
USE solar;

LOAD DATA LOCAL 
    INFILE '/tmp/deye_last.csv'      
    INTO TABLE reports
    FIELDS TERMINATED BY ','
    IGNORE 0 ROWS;
EOF
        ) | mysql --user="$SQLUSER" --password="$SQLPW" solar
    
    fi
fi
