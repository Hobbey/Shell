#!/bin/bash
JBOSS_DIR="/usr/local/jboss-as-7.1.1.Final1"
FILE_DIR="/root"
FILE_NAME="appStoreNew.war"
BACKUP_DIR="${JBOSS_DIR}/standalone"
DATE="$(date +%Y-%m-%d_%H_%M_%S)"

usage () {
    echo "$(basename $0):"
    echo "1 | start                    :jboss_start"
    echo "1 | start -s                 :jboss_start without tail -f nohup.out"
    echo "2 | stop                     :jboss_stop"
    echo "3 | update                   :jboss_update"
    echo "4 | rollback                 :list old version"
    echo "4 | rollback old_version     :jboss_rollback old_version"
    echo "-t                           :tail nohup.out"
    echo "-t -f                        :tail -f nohup.out"
    echo "-h                           :help info"
}

check_jboss_running () {
    ##### check_jboss_running_status
    if [[ $(ps -ef | grep "${JBOSS_DIR}" | grep -v "grep" | awk '{print $2}' | head -n 1) =~ ^[0-9]+$ ]]; then # head -n 1 是为了解决一个jboss启动多次的情况
        check_jboss_running_status=1    #在运行
    else
        check_jboss_running_status=0    #未运行
    fi
    
#    echo -e "check_jboss_running_status:${check_jboss_running_status}"
}

#希望手动使用脚本的时候默认tail -f,而又能用参数的形式禁止 tail -f 方便脚本调用
jboss_start () {
    if [[ $check_jboss_running_status -eq 1 ]]; then #避免重复启动
        echo "${JBOSS_DIR} is running" #区分一台机器上的多个jboss
        exit 1
    else
        cd ${JBOSS_DIR}/bin/
        nohup ./standalone.sh >> nohup.out 2>&1 &
        if [[ "$1" == "-s" ]]; then
            return
        else
            sleep 2
            tail -f nohup.out
        fi
    fi
}

jboss_stop () {
    if [[ $check_jboss_running_status -eq 0 ]]; then #加不加没用,获取不到pid,顶多kill命令报个错而已
        echo "${JBOSS_DIR} already stoped"
        exit 1
    else
        ps -ef | grep "${JBOSS_DIR}" | grep -v "grep" | awk '{print $2}' | xargs -i kill -9 {}
        echo "${JBOSS_DIR} is killed"
        rm -rf ${JBOSS_DIR}/standalone/tmp/vfs/temp*
        rm -rf ${JBOSS_DIR}/standalone/tmp/vfs/deployment*
        echo "clear ${JBOSS_DIR} tmp file OK"
        mv ${JBOSS_DIR}/bin/nohup.out ${JBOSS_DIR}/bin/nohup.out.${DATE}
        echo "mv nohup.out nohup.out.${DATE}"
        sleep 2
        ps -ef | grep jboss | grep -v "grep"
    fi
}

jboss_update () {
    if [[ -f ${FILE_DIR}/${FILE_NAME} ]]; then
        if [[ $check_jboss_running_status -eq 1 ]]; then
            echo "${JBOSS_DIR} is running"
            exit 1
        fi
        mv ${JBOSS_DIR}/standalone/deployments/${FILE_NAME} ${BACKUP_DIR}/${FILE_NAME}.${DATE}
        echo "backup ${FILE_NAME} to ${BACKUP_DIR}/${FILE_NAME}.${DATE}"
        cp ${FILE_DIR}/${FILE_NAME} ${JBOSS_DIR}/standalone/deployments/
        echo "cp ${FILE_DIR}/${FILE_NAME} to ${JBOSS_DIR}/standalone/deployments/ OK"
    else
        echo "${FILE_DIR}/${FILE_NAME} not exist"
    fi
}

jboss_rollback () {
    if [[ -f ${BACKUP_DIR}/"$1" ]]; then
        if  [[ $check_jboss_running_status -eq 1 ]]; then
            echo "${JBOSS_DIR} is running"
            exit 1
        fi
        mv ${JBOSS_DIR}/standalone/deployments/${FILE_NAME} ${BACKUP_DIR}/${FILE_NAME}.${DATE}.rbak #代表这个版本可能有问题,不然也不会回滚
        echo "backup ${FILE_NAME} to ${BACKUP_DIR}/${FILE_NAME}.${DATE}.rbak"
        cp ${BACKUP_DIR}/$1 ${JBOSS_DIR}/standalone/deployments/${FILE_NAME}
        echo "rollback $1 OK"
    else
        ls -lsh ${BACKUP_DIR}/${FILE_NAME}*
    fi
}

check_jboss_running

case $1 in
    1 | start)
        jboss_start $2
        ;;
    2 | stop)
        jboss_stop
        ;;
    3 | update)
        jboss_update
        ;;
    4 | rollback)
        jboss_rollback $2
        ;;
    -h)
        usage
        ;;
    -t)
        if [[ $check_jboss_running_status -eq 0 ]]; then
            echo "${JBOSS_DIR} stoped"
            exit
        fi
        if [[ "$2" == "-f" ]]; then
            tail -f ${JBOSS_DIR}/bin/nohup.out
        else
            tail ${JBOSS_DIR}/bin/nohup.out
        fi
        ;;
    *)
        echo "use $(basename $0) -h for help"
        ;;
esac



vim /home/script/Jboss7_control.sh
chmod 700 /home/script/Jboss7_control.sh

#因为老旧服务器用户和文件权限不统一的问题,暂时都用root启动,以后改进
#chown jboss:jboss ${FILE_DIR}/${FILE_NAME}
#su jboss -c 'nohup ./standalone.sh >> nohup.out 2>&1 &'
#su - jboss < EOF
#
#EOF



TEST:
[root@cloud1 script]# ./Jboss7_control_push1.sh 
use Jboss7_control_push1.sh -h for help

[root@cloud1 script]# ./Jboss7_control_push1.sh -h
Jboss7_control_push1.sh:
1 | start                    :jboss_start
2 | stop                     :jboss_stop
3 | update                   :jboss_update
4 | rollback                 :list old version
4 | rollback old_version     :jboss_rollback old_version
-t                           :tail nohup.out
-t -f                        :tail -f nohup.out
-h                           :help info

[root@cloud1 script]# ./Jboss7_control_push1.sh 1
Jboss is running

[root@server176 script]# ./Jboss7_control_push1.sh start
Jboss is running

[root@cloud1 script]# ./Jboss7_control_push1.sh 4
22M -rw-r--r-- 1 root root 22M 11-19 18:08 /usr/local/jboss-as-7.1.1.Final1/standalone/appStoreNew.war.2015-12-07_16_59_53

[root@cloud1 script]# ./Jboss7_control_push1.sh 4 appStoreNew.war.2015-12-07_16_59_53
Jboss is running
