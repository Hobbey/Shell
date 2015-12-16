#!/bin/bash
phone_num="XXX"
nginx_path="/usr/local/nginx/logs/"
tail_log_num=100

#计算 http错误数,error.log行数,nginx线程数 ,准备了abcd这4个输出
check_log () { 
    #####计算: check_log_http_error_num,check_log_error_log_num,check_log_nginx_worker_processes
    ###输出: check_log_output_a,check_log_output_b,check_log_output_c,check_log_output_d
    
    #####计算A
    check_log_http_error_num=0
    for i in $(tail -n ${tail_log_num} ${nginx_path}/access.log | awk -F \" '{print $3}' | awk '{print $1}'); do #新获取方式 可以百分百确定 获取到的是 http状态码
        #if [[ $i -gt 400 ]]; then
        if [[ $i =~ 404 || $i =~  50* ]]; then
            ((++check_log_http_error_num))
        #   echo -e "\033[31m$i 出错+1 累计 ${check_log_http_error_num}\033[0m"
        fi
    done
    ###计算A的输出 3个#
    check_log_output_a="HTTP_error:${check_log_http_error_num}/${tail_log_num}"
    
    #####计算B
    check_log_host_ip=$(cat /etc/sysconfig/network-scripts/ifcfg-* | grep IPADDR | grep -v 127.0.0.1 | cut -d "=" -f 2 |  head -n 1 | cut -c 1-15)
    check_log_error_log_num=$(cat ${nginx_path}/error.log | wc -l)
    check_log_error_log_size=$(ls -lsh ${nginx_path}/error.log | awk '{print $6}')
    check_log_nginx_worker_processes=$(ps -ef | grep nginx | awk '{print $1}' | grep nginx | wc -l)
    ###计算B的输出
    check_log_output_b="${HOSTNAME}:${check_log_host_ip}"
    check_log_output_c="Nginx_error.log:${check_log_error_log_num}/${check_log_error_log_size}"
    check_log_output_d="Nginx_processes:${check_log_nginx_worker_processes}"

#    echo -e "${check_log_output_a}\n${check_log_output_b}\n${check_log_output_c}\n${check_log_output_d}"    # "#"号在函数内,去掉注释测试整个函数
}

#echo help info
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
        echo -e "${check_log_output_b}\n${check_log_output_c}\n${check_log_output_d}\n${check_log_output_a}"
        echo "####################"
        echo "$(tail -n ${tail_log_num} ${nginx_path}/access.log | awk '{print $9}' | sort -n | uniq -c)"
        ;;

    -h | --help)
        usage
        ;;

    *)  #错误数大于等于20,错误日志大于等于10万.nginx没有启动,三个条件满足一个就发短信
        check_log
        if [[ check_log_http_error_num -ge 20 || check_log_error_log_num -ge 100000 || check_log_nginx_worker_processes -eq 0 ]]; then
            wget --post-data "phone=${phone_num}&content=${check_log_output_b},${check_log_output_c},${check_log_output_d},${check_log_output_a},$a&ac=send" http://sms-url
        fi
        ;;
esac




vim /home/script/check_nginx_error.sh
chmod 700 /home/script/check_nginx_error.sh
*/20 * * * * /bin/bash /home/script/check_nginx_error.sh


TEST:

[root@cloud01 ~]# /home/script/check_nginx_error.sh -h
check_nginx_error.sh:
-t           : test the script
-t num       : tail -n num access.log
-h | --help  : help info
*            : sms alerts

[root@cloud01 ~]# /home/script/check_nginx_error.sh -t
Phone:XXX
SHWT08:xxx.xxx.xxx.xxx
Nginx_error.log:359/115K
Nginx_processes:8
HTTP_error:0/100
####################
     70 200
     24 204
      6 206