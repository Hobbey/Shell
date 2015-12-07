#!/bin/bash
phone_num="XXX"

disk_check () {
    ##### disk_check_disk_used
    ### disk_check_output_a,disk_check_output_b
    
    #####
    disk_check_disk_used=0
    for i in $(df -hP | tail -n +2 | grep -v tmpfs | grep -v boot | awk '{print $5}' | sed 's/%//g'); do
        if [[ $i -gt disk_check_disk_used ]]; then
            disk_check_disk_used=$i
        fi
    done
    ###
    disk_check_output_a="Disk_Space_Used:${disk_check_disk_used}"
    
    #####
    host_ip=$(cat /etc/sysconfig/network-scripts/ifcfg-* | grep IPADDR | grep -v 127.0.0.1 | cut -d "=" -f 2 |  head -n 1 | cut -c 1-15)
    ###
    disk_check_output_b="${HOSTNAME}:${host_ip}"
    
#    echo -e "${disk_check_output_a}\n${disk_check_output_b}"
}

case $1 in
    -t)
        disk_check
        echo "Phone:${phone_num}"
        echo "${disk_check_output_b}"
        echo "${disk_check_output_a}"
        ;;
    
    *)
        disk_check
        if [[ disk_check_disk_used -ge 90 ]]; then
            wget --post-data "phone=${phone_num}&content=${disk_check_output_b},${disk_check_output_a}&ac=send" sms-url
        fi
        ;;
esac


vim /home/script/disk_check.sh
chmod 700 /home/script/disk_check.sh
0 9 * * * /bin/bash /home/script/disk_check.sh
