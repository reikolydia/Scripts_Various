#!/bin/bash
clear
if [ $wirelessname -z ]
then
wirelessname="No interface selected."
elif [[ $wirelessname == "No interface selected." ]]
then
wirelessname="No interface selected."
fi
echo "WIFI MODE MENU"
echo
echo "CTRL-C to stop script at anytime."
echo
echo -e "Interface selected:" "\e[31m"$wirelessname"\e[0m"
echo
PS3='Enter number: '
option1=( "Select wireless interface" "ENABLE monitor mode" "DISABLE monitor mode" "CHECK monitor mode" "Scan for networks" "TEST injection" )
select opt1 in "${option1[@]}"
do
case $opt1 in
"Select wireless interface")
export wirelessname
bash scripts/selectwifi.sh
;;
"ENABLE monitor mode")
export wirelessname
echo "Enabling monitor mode.."
bash scripts/enable.sh
;;
"DISABLE monitor mode")
export wirelessname
echo "Disabling monitor mode.."
bash scripts/disable.sh
;;
"CHECK monitor mode")
export wirelessname
bash scripts/check.sh
;;
"Scan for networks")
export wirelessname
gnome-terminal -x sh -c "airodump-ng $wirelessname; bash"
;;
"TEST injection")
aireplay-ng -9 $wirelessname
;;

*) echo "Invalid option";;
esac

done
