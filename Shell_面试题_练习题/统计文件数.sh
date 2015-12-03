原题:
系统每小时自动生成一个文件夹,比如11:00生成文件夹11,然后每2秒生成一个文件,每小时此文件夹将生成1800个文件,某意外将导致文件丢失,
请编写脚本自动统计前一天24个文件夹下文件是否丢失,并自动统计丢失数量导出为txt文件,需考虑大小月情况.不需考虑2月份情况,脚本语言自选

假设:
/home/script/yyyy-mm-dd/{00..23}/1800files

#!/bin/bash
file_path="/home/script/"
yesterday=$(date -d "-1 day" +%Y-%m-%d)

#数组folder[*]:存储每个文件夹缺少多少个文件
for i in {00..23}; do
    j=${i/#0}
    folder[j]=$(( 1800 - $(ls -lsh ${file_path}/${yesterday}/$i/ | tail -n +2 | wc -l) ))    #不考虑意外存在的文件
    lost_file_count=$(( ${lost_file_count} + ${folder[j]} ))
#    echo "$i $j 丢失文件数:folder[$j]=${folder[j]} 累计${lost_file_count}"
done

output () {
    echo "${yesterday}统计情况:"
    echo -e "Folder\tLost Files"
    echo -e "------\t----------"
    for i in {00..23}; do
        j=${i/#0}
        printf "%02d\t%d\n" $j ${folder[j]}
    done
    echo "丢失文件总数:${lost_file_count}"
}

case $1 in
    -t)
        output
        ;;
    *)
        output > /home/${yesterday}.txt
        ;;
esac



效果:
[root@cloud01 2015-12-02]# pwd
/home/script/2015-12-02

[root@cloud01 2015-12-02]# ll
total 72
drwxr-xr-x. 2 root root 32768 Dec  3 16:37 00
drwxr-xr-x. 2 root root     6 Dec  3 14:37 01
drwxr-xr-x. 2 root root     6 Dec  3 14:37 02
drwxr-xr-x. 2 root root     6 Dec  3 14:37 03
drwxr-xr-x. 2 root root     6 Dec  3 14:37 04
drwxr-xr-x. 2 root root     6 Dec  3 14:37 05
drwxr-xr-x. 2 root root     6 Dec  3 14:37 06
drwxr-xr-x. 2 root root     6 Dec  3 14:37 07
drwxr-xr-x. 2 root root     6 Dec  3 14:37 08
drwxr-xr-x. 2 root root     6 Dec  3 14:37 09
drwxr-xr-x. 2 root root    86 Dec  3 14:13 10
drwxr-xr-x. 2 root root     6 Dec  3 14:37 11
drwxr-xr-x. 2 root root    35 Dec  3 14:12 12
drwxr-xr-x. 2 root root     6 Dec  3 14:37 13
drwxr-xr-x. 2 root root     6 Dec  3 14:37 14
drwxr-xr-x. 2 root root     6 Dec  3 14:37 15
drwxr-xr-x. 2 root root     6 Dec  3 14:37 16
drwxr-xr-x. 2 root root     6 Dec  3 14:37 17
drwxr-xr-x. 2 root root     6 Dec  3 14:37 18
drwxr-xr-x. 2 root root  8192 Dec  3 15:35 19
drwxr-xr-x. 2 root root     6 Dec  3 14:37 20
drwxr-xr-x. 2 root root     6 Dec  3 14:37 21
drwxr-xr-x. 2 root root     6 Dec  3 14:37 22
drwxr-xr-x. 2 root root     6 Dec  3 14:37 23

[root@cloud01 script]# ./aa.sh -t
2015-12-02统计情况:
folder	Lost Files
------	----------
00	478
01	1800
02	1800
03	1800
04	1800
05	1800
06	1800
07	1800
08	1800
09	1800
10	1793
11	1800
12	1797
13	1800
14	1800
15	1800
16	1800
17	1800
18	1800
19	1567
20	1800
21	1800
22	1800
23	1800
丢失文件总数:41635

