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



测试:

生成测试环境的脚本:
#!/bin/bash
yesterday=$(date -d "-1 day" +%Y-%m-%d)

cd /home/script/
mkdir -p ${yesterday}/{00..23}

for i in {00..18}; do
    j=$(( ${i/#0} * 100 ))
    for q in $(seq 1 $j); do
        touch ${yesterday}/$i/file.$q
    done
done


[root@cloud01 2015-12-03]# pwd
/home/script/2015-12-03

[root@cloud01 2015-12-03]# ll
total 808
drwxr-xr-x. 2 root root     6 Dec  4 15:14 00
drwxr-xr-x. 2 root root  4096 Dec  4 15:14 01
drwxr-xr-x. 2 root root  8192 Dec  4 15:14 02
drwxr-xr-x. 2 root root  8192 Dec  4 15:14 03
drwxr-xr-x. 2 root root 12288 Dec  4 15:14 04
drwxr-xr-x. 2 root root 12288 Dec  4 15:14 05
drwxr-xr-x. 2 root root 16384 Dec  4 15:14 06
drwxr-xr-x. 2 root root 20480 Dec  4 15:14 07
drwxr-xr-x. 2 root root 20480 Dec  4 15:14 08
drwxr-xr-x. 2 root root 24576 Dec  4 15:14 09
drwxr-xr-x. 2 root root 24576 Dec  4 15:14 10
drwxr-xr-x. 2 root root 28672 Dec  4 15:14 11
drwxr-xr-x. 2 root root 32768 Dec  4 15:14 12
drwxr-xr-x. 2 root root 32768 Dec  4 15:14 13
drwxr-xr-x. 2 root root 36864 Dec  4 15:14 14
drwxr-xr-x. 2 root root 36864 Dec  4 15:14 15
drwxr-xr-x. 2 root root 40960 Dec  4 15:14 16
drwxr-xr-x. 2 root root 45056 Dec  4 15:14 17
drwxr-xr-x. 2 root root 45056 Dec  4 15:14 18
drwxr-xr-x. 2 root root     6 Dec  4 15:14 19
drwxr-xr-x. 2 root root     6 Dec  4 15:14 20
drwxr-xr-x. 2 root root     6 Dec  4 15:14 21
drwxr-xr-x. 2 root root     6 Dec  4 15:14 22
drwxr-xr-x. 2 root root     6 Dec  4 15:14 23

[root@cloud01 2015-12-03]# ll 15/file.
Display all 1500 possibilities? (y or n)


[root@cloud01 script]# ./test.sh -t
2015-12-03统计情况:
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

