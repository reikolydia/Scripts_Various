#!/bin/bash

clear

if [[ $wirelessname == "No interface selected." ]]
then
echo "No interface selected!"
else
echo "Checking" $wirelessname".."
echo
/sbin/iwconfig $wirelessname
fi
echo
read -p "Press [ENTER] to continue."

export wirelessname
bash ~/runme.sh
