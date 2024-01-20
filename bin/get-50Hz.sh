#!/bin/bash

#  https://www.50hertz.com/de/Transparenz/Kennzahlen/ErzeugungEinspeisung/EinspeisungausPhotovoltaik
#  https://ds.50hertz.com/api/PhotovoltaicForecast/DownloadFile?fileName=2024.csv

AbJahr=2024
BisJahr=2024

pushd ../data

for ((J = $AbJahr; J <=$BisJahr; J++))
do
   wget -O "/tmp/50HzPgSolar$J.csv" "https://ds.50hertz.com/api/PhotovoltaicForecast/DownloadFile?fileName=$J.csv" 
   iconv -f UTF-16 -t UTF-8 -o "50HzPgSolar$J.csv" "/tmp/50HzPgSolar$J.csv"

   sed --in-place '1,5d ; s#\([0-9]\{2\}\)\.\([0-9]\{2\}\)\.\([0-9]\{4\}\);#\3-\2-\1;#' "50HzPgSolar$J.csv"
   sed --in-place 's#\([^;]*\);\([^;]*\);\([^;]*\);#\1 \2;\1 \3;#' "50HzPgSolar$J.csv"

   wget -O "/tmp/50HzHRSolar$J.csv" "https://ds.50hertz.com/api/PhotovoltaicActual/DownloadFile?fileName=$J.csv" 
   iconv -f UTF-16 -t UTF-8 -o "50HzHRSolar$J.csv" "/tmp/50HzHRSolar$J.csv"
   
   sed --in-place '1,5d ; s#\([0-9]\{2\}\)\.\([0-9]\{2\}\)\.\([0-9]\{4\}\);#\3-\2-\1;#' "50HzHRSolar$J.csv"
   sed --in-place 's#\([^;]*\);\([^;]*\);\([^;]*\);#\1 \2;\1 \3;#' "50HzHRSolar$J.csv"
   
   
done

cat 50HzHRSolar20*.csv > 50HzHRSolar.csv
cat 50HzPgSolar20*.csv > 50HzPgSolar.csv


popd
