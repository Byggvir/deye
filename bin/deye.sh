#!/bin/bash

# Simple bash script to collect and log data from a Deye SUN microinverter

# Set date and time to a MySLQ / mariaDB conform format.

DATE=$(date '+%F %T')

# Get status page
# Insert your username, password and ip-address of the mircoinverter

curl --user <yourusername>:<yourpassword> 'http://<youripaddr>/status.html' 2>/dev/null > /tmp/status.html

# If the request was successfull append values to deye.csv in your home directory
#
# Note:
# We put all variables starting with web into the dataset, even when the device does not use them.
#
# Separator: ,
# decimal Point: .

if [ $? -eq 0 ]
then
    cat /tmp/status.html \
    | grep 'var web' \
    | sed 's#.* = "##; s#".*##; s# *##g;' \
    | tr '\n' ',' \
    | sed "s#^#${DATE},#" \
    | sed 's#,$#\n#;' \
    >> $HOME/deye.csv
fi
