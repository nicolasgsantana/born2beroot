#!/bin/bash	

arch=$(uname -a)
physical_cpu=$(lscpu | grep 'Socket(s):' | awk '{print $2}')
virtual_cpu=$(nproc --all)
memory_usage=$(free -m | grep Mem: | awk '{ percent= ($7 / $2) * 100; printf "%d/%dMB (%.2f%%)\n", $7, $2, percent}')
disk_usage=$(df -h --total | grep total | awk '{printf "%s/%s (%s)\n", $3, $2, $5}')
cpu_load=$(top -b -n 1 | grep 'Cpu(s)'| awk '{ percent = 100 - $8; printf "%.1f%%\n", percent }')
last_boot=$(who -b | awk '{printf "%s %s\n", $3, $4}')

if [ $(lsblk -no TYPE | grep -c '^lvm$') -gt 0 ]; then
	lvm_use="yes"
else
	lvm_use="no"
fi

tcp_count=$(ss | grep tcp | wc -l)
user_count=$(w --no-header | wc -l)
ip_address=$(hostname --ip-address)
mac_address=$(ip link | grep enp -A 1 | grep link/ether | awk '{print $2}')

sudo_count=$(echo "obase=10; ibase=36; $(sudo cat /var/log/sudo/seq)" | bc)

msg="\
	#Architecture: $arch
	#CPU physical : $physical_cpu
	#vCPU : $virtual_cpu
	#Memory Usage: $memory_usage
	#Disk Usage: $disk_usage
	#CPU load: $cpu_load
	#Last boot: $last_boot
	#LVM use: $lvm_use
	#Connections TCP : $tcp_count ESTABLISHED
	#User log: $user_count
	#Network: IP $ip_address ($mac_address)
	#Sudo : $sudo_count cmd"

if [ ! -f /tmp/startup-message-displayed ]; then

		echo "$msg" | sudo tee /etc/issue > /dev/null
		touch /tmp/startup-message-displayed
fi

ls /dev/pts/* /dev/tty[1-6] | while read -r TTY; do
	if [ -w "$TTY" ]; then
		printf "%s\n" "$msg" > "$TTY"
	fi
done
