#!/bin/bash
phone_num="XXX"
host_ip=$(cat /etc/sysconfig/network-scripts/ifcfg-* | grep IPADDR | grep -v 127.0.0.1 | cut -d "=" -f 2 |  head -n 1 | cut -c 1-15)
error_log_size=$(ls -lsh /usr/local/nginx/logs/error.log | awk '{print $6}')
error_log_num=$(cat /usr/local/nginx/logs/error.log | wc -l)
error_num=0
log_num=100

check_log () {
    for i in $(tail -n ${log_num} /usr/local/nginx/logs/access.log | awk '{print $9}'); do
        if [[ "$i" =~ ^[0-9]{3}$ ]];then
            if [[ $i -gt 400 ]]; then
                ((++error_num))
            fi
        else
                ((--log_num))
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
        echo "Get server ip:${host_ip}"
        echo "Phone:${phone_num}"
        echo "Nginx error number: ${error_num}"
        echo "$(tail -n ${log_num} /usr/local/nginx/logs/access.log | awk '{print $9}' | sort -n | uniq -c)"
        echo "Message:${HOSTNAME}:${host_ip},nginx_error:${error_num}/${log_num},error_log_size:${error_log_size}"
        ;;

    -h | --help)
        usage
        ;;

    *)
        check_log
        if [[ error_num -ge 10 || error_log_num -ge 10000 ]]; then
            wget --post-data "phone=${phone_num}&content= ${HOSTNAME}:${host_ip},nginx_error:${error_num}/${log_num},error_log_size:${error_log_size} &ac=send" http://sms-url
        fi
        ;;
esac




vim /home/script/check_nginx_error.sh
chmod 700 /home/script/check_nginx_error.sh
*/20 * * * * /bin/bash /home/script/check_nginx_error.sh


/home/script/check_nginx_error.sh -t
cat /usr/local/nginx/logs/access.log | awk '{print $9}' | sort -n | uniq -c





