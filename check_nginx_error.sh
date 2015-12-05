#!/bin/bash
phone_num="XXX"
nginx_path="/usr/local/nginx/logs/"
tail_log_num=100

#计算 http_error_num,error_log_num,nginx_worker_processes 以供后续判断,准备了abcd这4个输出
check_log () {
    http_error_num=0
    for i in $(tail -n ${tail_log_num} ${nginx_path}/access.log | awk '{print $9}'); do
        if [[ "$i" =~ ^[0-9]{3}$ ]];then
    #        echo "$i 匹配三位数字OK"    #"#"号在for内,去掉注释跟踪循环内步骤
            #if [[ $i -gt 400 ]]; then
            if [[ $i =~ 404 || $i =~  50* ]]; then
                ((++http_error_num))
    #           echo -e "\033[31m$i 出错+1 累计 ${http_error_num}\033[0m"
            fi
        else
    #        echo "$i 不是三位数字"
            ((--tail_log_num))
    #        echo "当前有效访问次数为 ${tail_log_num}"
        fi
    done
    a="HTTP_error:${http_error_num}/${tail_log_num}"
    
    #####可调整数据获取管道
    host_ip=$(cat /etc/sysconfig/network-scripts/ifcfg-* | grep IPADDR | grep -v 127.0.0.1 | cut -d "=" -f 2 |  head -n 1 | cut -c 1-15)
    error_log_num=$(cat ${nginx_path}/error.log | wc -l)
    error_log_size=$(ls -lsh ${nginx_path}/error.log | awk '{print $6}')
    nginx_worker_processes=$(ps -ef | grep nginx | awk '{print $1}' | grep nginx | wc -l)
    #####
    b="${HOSTNAME}:${host_ip}"
    c="Nginx_error.log:${error_log_num}/${error_log_size}"
    d="Nginx_processes:${nginx_worker_processes}"
#    echo -e "$a\n$b\n$c\n$d"    #"#"号在函数内,去掉注释测试整个函数
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
            tail_log_num=$2
        fi
        check_log
        echo "Phone:${phone_num}"
        echo -e "$b\n$c\n$d\n$a"
        echo "####################"
        echo "$(tail -n ${tail_log_num} ${nginx_path}/access.log | awk '{print $9}' | sort -n | uniq -c)"
        ;;

    -h | --help)
        usage
        ;;

    *)  #错误数大于等于20,错误日志大于等于10万.nginx没有启动,三个条件满足一个就发短信
        check_log
        if [[ http_error_num -ge 20 || error_log_num -ge 100000 || nginx_worker_processes -eq 0 ]]; then
            wget --post-data "phone=${phone_num}&content=$b,$c,$d,$a&ac=send" http://sms-url
        fi
        ;;
esac




vim /home/script/check_nginx_error.sh
chmod 700 /home/script/check_nginx_error.sh
/home/script/check_nginx_error.sh -t
*/20 * * * * /bin/bash /home/script/check_nginx_error.sh
