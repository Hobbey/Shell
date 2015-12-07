原题:
系统每小时自动生成一个文件夹,比如11:00生成文件夹11,然后每2秒生成一个文件,每小时此文件夹将生成1800个文件,某意外将导致文件丢失,
请编写脚本自动统计前一天24个文件夹下文件是否丢失,并自动统计丢失数量导出为txt文件,需考虑大小月情况.不需考虑2月份情况,脚本语言自选

假设:
/opt/log/yyyy-mm-dd/{00..23}/1800files



#!/bin/bash
file_path="/opt/log/"
log_date=$(date -d "-1 day" +%Y-%m-%d)

#计算每个文件夹缺少文件数
check_lostfile () {
    ### check_lostfile_folder[*] check_lostfile_output_a
    
    #####
    for i in {00..23}; do
        j=${i/#0}
        check_lostfile_folder[j]=$(( 1800 - $(ls -lsh ${file_path}/${log_date}/$i/ | tail -n +2 | wc -l) ))    #不考虑意外存在的文件,
        lost_total=$(( ${lost_total} + ${check_lostfile_folder[j]} ))   #总数累加
    #    echo "$i $j 丢失文件数:check_lostfile_folder[$j]=${check_lostfile_folder[j]} 累计${lost_total}"    # 去掉#测试for循环
    done
    ###
    check_lostfile_output_a="丢失文件总数:${lost_total}"

#    echo "${check_lostfile_output_a}"
}

output () {
    echo "${log_date}统计情况:"
    echo -e "Folder\tLost Files"
    echo -e "------\t----------"
    for i in {00..23}; do
        j=${i/#0}
        printf "%02d\t%d\n" $j ${check_lostfile_folder[j]}
    done
    echo "${check_lostfile_output_a}"
}

case $1 in
    -t)
        check_lostfile
        output
        ;;
    *)
        check_lostfile
        output > /home/${log_date}.txt
        ;;
esac



测试:

生成测试环境的脚本:
#!/bin/bash
log_date=$(date -d "-1 day" +%Y-%m-%d)

cd /opt/log/
mkdir -p ${log_date}/{00..23}

for i in {00..18}; do
    j=$(( ${i/#0} * 100 ))
    for q in $(seq -w 1 $j); do
        touch ${log_date}/$i/file.$q
    done
done

TEST:

[root@cloud01 2015-12-06]# date
Mon Dec  7 19:31:38 CST 2015

[root@cloud01 2015-12-06]# pwd
/opt/log/2015-12-06

[root@cloud01 2015-12-06]# ll
total 768
drwxr-xr-x. 2 root root     6 Dec  7 19:30 00
drwxr-xr-x. 2 root root  4096 Dec  7 19:30 01
drwxr-xr-x. 2 root root  8192 Dec  7 19:30 02
drwxr-xr-x. 2 root root  8192 Dec  7 19:30 03
drwxr-xr-x. 2 root root 12288 Dec  7 19:30 04
drwxr-xr-x. 2 root root 12288 Dec  7 19:30 05
drwxr-xr-x. 2 root root 16384 Dec  7 19:31 06
drwxr-xr-x. 2 root root 20480 Dec  7 19:31 07
drwxr-xr-x. 2 root root 20480 Dec  7 19:31 08
drwxr-xr-x. 2 root root 24576 Dec  7 19:31 09
drwxr-xr-x. 2 root root 24576 Dec  7 19:31 10
drwxr-xr-x. 2 root root 28672 Dec  7 19:31 11
drwxr-xr-x. 2 root root 32768 Dec  7 19:31 12
drwxr-xr-x. 2 root root 32768 Dec  7 19:31 13
drwxr-xr-x. 2 root root 36864 Dec  7 19:31 14
drwxr-xr-x. 2 root root 36864 Dec  7 19:31 15
drwxr-xr-x. 2 root root 40960 Dec  7 19:31 16
drwxr-xr-x. 2 root root 45056 Dec  7 19:31 17
drwxr-xr-x. 2 root root 45056 Dec  7 19:31 18
drwxr-xr-x. 2 root root     6 Dec  7 19:30 19
drwxr-xr-x. 2 root root     6 Dec  7 19:30 20
drwxr-xr-x. 2 root root     6 Dec  7 19:30 21
drwxr-xr-x. 2 root root     6 Dec  7 19:30 22
drwxr-xr-x. 2 root root     6 Dec  7 19:30 23

[root@cloud01 2015-12-06]# ll 15/file.
Display all 1500 possibilities? (y or n)

[root@cloud01 log]# ./test.sh -t
2015-12-06统计情况:
Folder	Lost Files
------	----------
00	1800
01	1700
02	1600
03	1500
04	1400
05	1300
06	1200
07	1100
08	1000
09	900
10	800
11	700
12	600
13	500
14	400
15	300
16	200
17	100
18	0
19	1800
20	1800
21	1800
22	1800
23	1800
丢失文件总数:26100

[root@cloud01 log]# ./test.sh && ll /home/*.txt
-rw-r--r--. 1 root root 265 Dec  7 19:36 /home/2015-12-06.txt


#附加:
可以在case的 -t 内 先if判断$2 是否是真实存在的日期yyyy-mm-dd
是的话就把传入的日期,赋值给log_date
实现自定义查询功能