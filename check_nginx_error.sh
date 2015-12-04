#!/bin/bash
phone_num="XXX"
host_ip=$(cat /etc/sysconfig/network-scripts/ifcfg-* | grep IPADDR | grep -v 127.0.0.1 | cut -d "=" -f 2 |  head -n 1 | cut -c 1-15)
nginx_worker_processes=$(ps -ef | grep nginx | grep -v grep | wc -l)
error_log_num=$(cat /usr/local/nginx/logs/error.log | wc -l)
error_log_size=$(ls -lsh /usr/local/nginx/logs/error.log | awk '{print $6}')
#查询log数 预设值
log_num=100

check_log () {
    error_num=0
    for i in $(tail -n ${log_num} /usr/local/nginx/logs/access.log | awk '{print $9}'); do
        if [[ "$i" =~ ^[0-9]{3}$ ]];then
#            echo "$i 匹配三位数字OK"
            if [[ $i -gt 400 ]]; then
                ((++error_num))
#                echo -e "\033[31m$i 出错+1 累计 ${error_num}\033[0m"
            fi
        else
#            echo "$i 不是三位数字"
            ((--log_num))
#            echo "当前有效访问次数为 ${log_num}"
        fi
    done
}

usage () {
    echo "$(basename $0):"
    echo "-t           : test the script"
    echo "-t num       : tail -n num access.log"
    echo "-h | --help  : help info"
    echo "*            : sms alerts"
}

case $1 in
    -t)
        if [[ "$2" =~ ^[0-9]+$ ]]; then
            log_num=$2
        fi
        check_log
        echo "Phone:${phone_num}"
        echo "${HOSTNAME}:${host_ip}"
        echo "Nginx processes:${nginx_worker_processes}"
        echo "Nginx error.log:${error_log_num}/${error_log_size}"
        echo "Nginx error:${error_num}/${log_num}"
        echo "####################"
        echo "$(tail -n ${log_num} /usr/local/nginx/logs/access.log | awk '{print $9}' | sort -n | uniq -c)"
        ;;

    -h | --help)
        usage
        ;;

    *)  #错误数大于等于20,错误日志大于等于10万.nginx没有启动,三个条件满足一个就发短信
        check_log
        if [[ error_num -ge 20 || error_log_num -ge 100000 || nginx_worker_processes -eq 0 ]]; then
            wget --post-data "phone=${phone_num}&content= ${HOSTNAME}:${host_ip},Nginx processes:${nginx_worker_processes},Nginx error.log:${error_log_num}/${error_log_size},Nginx error:${error_num}/${log_num} &ac=send" http://sms-url
        fi
        ;;
esac




vim /home/script/check_nginx_error.sh
chmod 700 /home/script/check_nginx_error.sh
*/20 * * * * /bin/bash /home/script/check_nginx_error.sh


/home/script/check_nginx_error.sh -t
cat /usr/local/nginx/logs/access.log | awk '{print $9}' | sort -n | uniq -c





