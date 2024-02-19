#!/bin/bash

clear
echo "Available wireless interfaces: "
echo
/sbin/iwconfig
echo
echo "Enter choosen wireless interface name: "
read wirelessname
clear
/sbin/iwconfig $wirelessname
echo
echo -e "Interface selected:" "\e[36m"$wirelessname"\e[0m"
echo
read -p "Press [ENTER] to continue."
export wirelessname
bash ~/runme.sh
