#!/bin/bash

clear
echo "Disabling monitor mode for:" $wirelessname

/sbin/ifconfig $wirelessname down
/sbin/iwconfig $wirelessname mode managed
/sbin/ifconfig $wirelessname up
/sbin/iwconfig $wirelessname | grep 'Mode:'
echo
read -p "Press [ENTER] to continue."

export wirelessname
bash ~/runme.sh
