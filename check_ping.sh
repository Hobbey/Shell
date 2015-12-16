#!/bin/bash
ip_prefix="192.168.12."
ip_postfix="39 40 55 85"
ping_num=4

#check ping
alarm=0 #后续判断是否需要报警
num=0 #出错机器数
for i in $ip_postfix; do
#    packet_loss=75 # test
    packet_loss=$(ping ${ip_prefix}${i} -c ${ping_num} | grep "packet loss" | cut -d "%" -f 1 | awk '{print $NF}')
    if [[ packet_loss -gt 25 ]]; then #丢包 25% 以上 
        alarm=1
        check_ping_ip[num]="${ip_prefix}${i}"
        check_ping_lost[num]="${packet_loss}"
        (( ++num ))
    fi
done

if [[ num -gt 0 ]]; then #有出错机器,也就意味着num多加了1
    (( --num ))
else
    exit 0 #没错直接退出
fi

#output
for j in $(seq 0 $num ); do
    echo  "${check_ping_ip[j]}: ${check_ping_lost[j]}% packet loss"
done
