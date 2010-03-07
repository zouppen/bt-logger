#!/bin/bash
echo ';Bluetooth visitor log dump at' $(date --rfc-3339=seconds) >databasedump.txt
echo ';all time fields are in UTC' >>databasedump.txt
echo '' >>databasedump.txt
echo ';site_public' >>databasedump.txt
mysql -u viewer -h zouppen.iki.fi bluetooth -e "select * from site_public" >>databasedump.txt
echo '' >>databasedump.txt
echo ';device_public' >>databasedump.txt
mysql -u viewer -h zouppen.iki.fi bluetooth -e "select * from device_public" >>databasedump.txt
echo '' >>databasedump.txt
echo ';visitor_public' >>databasedump.txt
mysql -u viewer -h zouppen.iki.fi bluetooth -e "select * from visitor_public;" >>databasedump.txt
echo '' >>databasedump.txt
echo ';integer_cache' >>databasedump.txt
mysql -u viewer -h zouppen.iki.fi bluetooth -e "select * from integer_cache;" >>databasedump.txt
scp databasedump.txt jalava:www/web/bt-logger
