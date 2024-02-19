#!/bin/bash

clear
echo "Enabling monitor mode for:" $wirelessname

/sbin/ifconfig $wirelessname down
/sbin/iwconfig $wirelessname mode monitor
/sbin/ifconfig $wirelessname up
echo
/sbin/iwconfig $wirelessname | grep 'Mode:'

echo
read -p "Press [ENTER] to continue."

export wirelessname
bash ~/runme.sh
