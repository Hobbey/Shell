seq 1 100 > aa.txt


#输出第10行

sed -n 10p aa.txt

awk '{ if (NR==10) {print $0} }' aa.txt
awk 'NR==10 {print $0}' aa.txt
awk 'NR==10' aa.txt #简写

tail -n +10 aa.txt | head -n 1


#输出第12到24行

sed -n '12,24p' aa.txt

awk '{ if (NR>=12 && NR<=24) {print $0} }' aa.txt


#按规律输出行

awk '{ A=NR%40 ; if (A>=2 && A<=5 || A==8) {print $0} }' aa.txt

awk 'BEGIN{ for (i=2;i<=5;++i) ar[i]=1 ; ar[8] = 1 } (NR%40 in ar) {print $0} ' aa.txt

awk 'BEGIN{ for (i=2;i<=5;++i) ar[i]=1 ; ar[8] = 1 } ar[NR%40] {print $0} ' aa.txt 

2
3
4
5
8
42
43
44
45
48
82
83
84
85
88

