#!/bin/bash
phone_num="XXX"
host_ip=$(cat /etc/sysconfig/network-scripts/ifcfg-* | grep IPADDR | grep -v 127.0.0.1 | cut -d "=" -f 2 |  head -n 1 | cut -c 1-15)

disk_used=0
for i in $(df -hP | tail -n +2 | grep -v tmpfs | grep -v boot | awk '{print $5}' | sed 's/%//g'); do
    if [[ $i -gt disk_used ]];then
        disk_used=$i
    fi
done

case $1 in
    -t)
        echo "Get server ip:${host_ip}"
        echo "Phone:${phone_num}"
        echo "Message:${HOSTNAME}:${host_ip},disk_used:${disk_used}"
        ;;
    
    *)
        if [[ disk_used -ge 90 ]]; then
            wget --post-data "phone=${phone_num}&content= ${HOSTNAME}:${host_ip},disk_used:${disk_used} &ac=send" http://sms-url
        fi
        ;;
esac


vim /home/script/disk_check.sh
chmod 700 /home/script/disk_check.sh
0 9 * * * /bin/bash /home/script/disk_check.sh

