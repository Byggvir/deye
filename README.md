# Deye Inverter

## Microinverter data collector

# Abstract

Small utility to read data from DEYE Inverters through the status page http://&lt;ip&gt;/status.html. Works with Deye SUN 800W, MW3_16U_5406_1.53.

The script ***bin/deye.sh*** retrieves the status page from the mircoinverter  extracts the variables starting with ***web*** and appends the values to the file ***deye.csv*** in te users home directory.

I am runing the script to collect the data on a Raspberry Pi. The diagrams are create with R / RStudio on an laptop or desktop.

# Installation

To run the script ***deye.sh*** bash, curl, sed and tr are required.

Copy the script into ***$HOME/bin/deye.sh***. (For example: /home/pi/bin/deye.sh).

Edit the file and replace the placepolders with the username (default ***admin***), password (default ***admi***) and the IP-address of the  microinverter.

Insert the following line into ***/etc/crontab***:

```
* 5-21 * * *  pi /home/pi/bin/deye.sh
```

Replace the script path and name with the location of your script. Replace hours 5-21 with your sunrise and sunset hours. (The DEYE does not answer request, when it produces no power. I see no need for useless requests.)

Maybe that you are happy with the CSV file only. Then you are done here.

If you want to use the R-scripts to generate diagrams, you need a MySQL or MariaDB server.

## MySQL / MariaDB

I run an MariaDB server on my laptop to collect statistical data. For all statistical databases I use the user ***statistik***. The advantage of importing all CSV files into databases is that tables from different sources can be linked.

To create the database DEYE run: (Apply users and names i.a.w. your configuration.)

```
mysql --user=<your-MySQL-user> --password=<your-MySQL-password> < init.sql
```

## Get data from Raspberry Pi

To get the CSV file I from the Raspberry Pi I use the following command:
(Apply users and names i.a.w. your configuration.)

```
scp pi@pi:deye.csv /tmp/

```

## Import

To import the data into a database Deye
(Apply users and names i.a.w. your configuration.)

```
mysql --user=<your-MySQL-user> --password=<your-MySQL-password> < import.sql
```

# R-Script

Diagrams are created with R. Even if there is only one CSV file, I prefer to import that file into a SQL database.

There are currently only to scripts to draw to diagrams. To run these scripts you may have edit ***R/lib/sql.r***.

Copy ***DEYE.conf*** into a file ***$HOME/R/sql.con.d/DEYE.conf***. This is the location where ***lib/sql.r*** looks for the configuration file.

Edit the file and apply username, password and maybe more to your configuration.

# Known Issues

The inverter may not answer correctly. In some cases there will be entries without a serial number. These are deleted after importing the CSV file.

I can test it only with the one microinverter I have.

# Contrib

This is a quick and messy solution. Suggestions are welcome.