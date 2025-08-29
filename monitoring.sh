#!/bin/bash

printf "	#Architecture: "
uname -a

printf "	#CPU physical : "
lscpu | grep 'Socket(s):' | awk '{print $2}'

printf "	#vCPU : "
nproc --all

printf "	#Memory Usage: "
free -m | grep Mem: | awk '{ percent= ($7 / $2) * 100; printf "%d/%dMB (%.2f%%)\n", $7, $2, percent}'

printf "	#Disk Usage: "
df -h --total | grep total | awk '{printf "%s/%s (%s)\n", $3, $2, $5}'

printf "	#CPU load: "
top -b -n 1 | grep 'Cpu(s)'| awk '{ percent = 100 - $8; printf "%.1f%%\n", percent }'

printf "	#Last boot: "
who -b | awk '{printf "%s %s\n", $3, $4}'

printf "	#LVM use: "
if [ $(lsblk -no TYPE | grep -c '^lvm$') -gt 0 ]; then
	printf "yes\n"
else
	printf "no\n"
fi

tcp_count=$(ss | grep tcp | wc -l)
printf "	#Connections TCP : %d ESTABLISHED\n" $tcp_count

user_count=$(w --no-header | wc -l)
printf "	#User log: %d\n" $user_count

ip_address=$(hostname --ip-address)
mac_address=$(ip link | grep enp -A 1 | grep link/ether | awk '{print $2}')
printf "	#Network: IP %s (%s)\n" $ip_address $mac_address

sudo_count=$(sudo cat /var/log/sudo/sudo.log | grep COMMAND | wc -l)
printf "	#Sudo : %d cmd\n" $sudo_count