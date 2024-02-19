# copy from /mnt/* to /networkdrive/*
rsync -avHhtUWP /mnt/ /networkdrive/

# ddrescue write 0 to all sectors (DESTRUCTIVE!)
ddrescue -fDJvvP /dev/zero /dev/sdc sdCwipelog.txt

# to add disk to raid 0
mdadm -Gv /dev/md0 -l 0 -n 2 -a /dev/sdc
# no idea why it is stuck in raid4 after reshaping, so grow it back to raid0
mdadm --grow /dev/md0 --level=0
# df -h will stil show old size, so resize the filesize to fill entire array
resize2fs /dev/md0
