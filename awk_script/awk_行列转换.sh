行列转换

[root@cloud01 script]# cat aa.txt 
1 2 3 4 5
1 2 3 4 5
1 2 3 4 5
1 2 3 4 5
1 2 3 4 5
1 2 3 4 5


awk脚本

awk '{for (f=1;f<=NF;f++) {a[NR, f]=$f } } NF > nf { nf = NF }  END { for (f = 1; f <= nf; f++) { for (r = 1; r <= NR; r++) { printf a[r, f] (r==NR ? RS : FS) } } }' aa.txt


    
awk '{
       for (f = 1; f <= NF; f++) { a[NR, f] = $f } 
     }
     NF > nf { nf = NF }
     END {
       for (f = 1; f <= nf; f++) {
           for (r = 1; r <= NR; r++) {
               printf a[r, f] (r==NR ? RS : FS)
           }
       }
    }'
    

awk '{ for                            }'
    
#awk 列变行
seq 1 9 | awk '{ if (NR%3==0) {printf ("%s\n",$0)} else {printf ("%s\t",$0)} }'
1   2   3
4	5	6
7	8	9







#不懂
#sed 列变行
seq 1 9 | sed -n 'N;N;s/\n/ /gp'
1 2 3
4 5 6
7 8 9