##Shell 各种括号 `( ) (( )) [ ] [[ ]] { }`

###`( )`

*   命令或管道替换  
    用命令或管道执行的结果,代替 $( ) 结构  
    $(command) 等同于 \`command\`

    ```shell
[root@cloud01 script]# seq 1
1
[root@cloud01 script]# $(seq 1)
-bash: 1: command not found
[root@cloud01 script]# `seq 1`
-bash: 1: command not found
[root@cloud01 script]# ps -ef | grep sshd | awk '{print $2}' | head -n 1
731
[root@cloud01 script]# $(ps -ef | grep sshd | awk '{print $2}' | head -n 1)
-bash: 731: command not found
[root@cloud01 script]# `ps -ef | grep sshd | awk '{print $2}' | head -n 1`
-bash: 731: command not found
    ```

*   数组多个值赋值,从0开始填充  

    ```shell
[root@cloud01 script]#  aaa=(a b c d)
[root@cloud01 script]# for i in ${aaa[*]}; do echo $i; done
a
b
c
d
    ```

*   子Shell  
    把多个命令组合在一起,经常用于 **把几个命令的输出结果合并成一个流** 并与 **管道** 相结合  
    括号中的命令将会新开一个子shell顺序执行  
    命令之间用分号隔开,最后一个命令可以没有分号,各命令和括号之间不必有空格  
    (command;command;command;command)

    ```shell
[root@cloud01 script]# touch {1..5}.txt && ls
1.txt  2.txt  3.txt  4.txt  5.txt
[root@cloud01 script]# touch {1..5}.txt | ls 2.txt
2.txt
[root@cloud01 script]# touch {1..5}.txt | ( ls 2.txt ; ls 3.txt ; ls 5.txt )
2.txt
3.txt
5.txt
[root@cloud01 script]# touch {1..5}.txt | ( ls 2.txt ; ls 3.txt ; ls 5.txt ) | xargs -i ls -lsh {}
0 -rw-r--r--. 1 root root 0 Dec 25 16:23 2.txt
0 -rw-r--r--. 1 root root 0 Dec 25 16:23 3.txt
0 -rw-r--r--. 1 root root 0 Dec 25 16:23 5.txt
    ```

---
###`(( ))`
变量不用加$  
为整数设计

*   整型计算器  
    支持 `+ - * / % ( )` 以及仅对变量生效的:`++ --`  
    用计算的结果代替 $(( )) 结构

    ```shell
[root@cloud01 script]# ((2+2)) #完成一个计算
[root@cloud01 script]# $((2+2)) #用计算的结果代替 $(( )) 结构
-bash: 4: command not found
[root@cloud01 script]# echo $(( (2+3) * 4 ))
20
[root@cloud01 script]# a=6 ; echo $((a+2))
8
[root@cloud01 script]# a=6 ; echo $((a++));echo $a #先完成命令,后自加
6
7
[root@cloud01 script]# a=6 ; echo $((++a));echo $a #先自加,后完成命令
7
7
[root@cloud01 script]# echo $((16#10)) #不同进制运算,结果自动转为十进制
16
[root@cloud01 script]# echo $((16#10 + 1))
17
[root@cloud01 script]# echo $((16#10 + 8#10))
24
    ```

*   整型判断  
    支持 `> >=  < <=  == !=`  
    支持 `&& || !`  

    ```shell
[root@cloud01 script]# a=6 ; if (( a > 5 && a < 9 )) ; then echo "True" ; else echo "False" ; fi
True
[root@cloud01 script]# a=6 ; if ((a>5&&a<9)) ; then echo "True" ; else echo "False" ; fi #可以没有多余空格
True
[root@cloud01 script]# a=6 ; if (( ((a%2)) == 0 )) ; then echo "\$a is even." ; else echo "\$a is odd." ; fi #运算双引号 嵌在 判断双引号 里
$a is even.
    ```

*   判断算式的结果,得到 `$?`
    结果 `= 0`   则 $?为1 即为假  
    结果 `! = 0` 则 $?为0 即为真

    ```shell
[root@cloud01 script]# if (( 0 )) ; then echo "True" ; else echo "False" ; fi
False
[root@cloud01 script]# if (( 2 - 1 )) ; then echo "True" ; else echo "False" ; fi
True
[root@cloud01 script]# if (( 2 - 2 )) ; then echo "True" ; else echo "False" ; fi
False
[root@cloud01 script]# if (( 2 - 3 )) ; then echo "True" ; else echo "False" ; fi
True
    ```

*   其他用法  
    与for合用

    ```shell
[root@cloud01 script]# for((i=0;i<3;i++));do echo $i ;done
0
1
2
    ```

---
###`[ ]`
变量需要加$  
需要留空格,即[ expression ],而[ expression] 是语法错误  
变量最好用"引号"引起来  
不支持正则

*   [ 等价于bash的内部命令 "test"   
    if/test结构中的 "[" 是调用test命令的标识，"]" 是关闭条件判断  
    文件判断: `-e -d` 等  
    字符串判断: `== !=`  
    整数判断: `-eq` 等  
    逻辑与或: `-a -o`

    ```
[root@cloud01 script]# touch 1.txt ; test -e 1.aaa ; echo $?
1
[root@cloud01 script]# touch 1.txt ; [ -e 1.aaa ] ; echo $? # [ expression ] 等价于 test expression 
1
[root@cloud01 script]# touch 1.txt ; [ -e 1.txt ] ; echo $?
0
[root@cloud01 script]# touch 1.txt ; [ -e 1.txt] ; echo $? # 需要空格
-bash: [: missing `]'
2
[root@cloud01 script]# a=6 ; if [ a -gt 5 ] ; then echo "True" ; else echo "False" ; fi #语法错误的$?为1,而不是判断正确执行后判断结果为false
-bash: [: a: integer expression expected
False
[root@cloud01 script]# a=6 ; if [ $a -gt 5 ] ; then echo "True" ; else echo "False" ; fi # 变量需要加$
True
[root@cloud01 script]# touch 1.txt ; FILE="1.txt" ; if [ -e "$FILE" ]; then echo "file exists" ; else echo "file not exists" ; fi #结果正确
file exists
[root@cloud01 script]# if [ -e "$AAAA" ]; then echo "file exists" ; else echo "file not exists" ; fi #变量未定义,展开为空值,有双引号,结果正确
file not exists
[root@cloud01 script]# if [ -e $AAAA ]; then echo "file exists" ; else echo "file not exists" ; fi #结果错误,用引号把参数引起来能确保了操作符之后总是跟随着一个字符串，即使字符串为空
file exists
    ```

*   正则通配符(待完善[!characters]用法)  
    支持字符: `[characters]` 等  
    支持字符范围: `[0-9] [a-z]` 等  
    支持字符类: `[[:alpha:]]` 等  
    [[:digit:]] 等价于 [0-9] 等价于 [0123456789]

    ```shell
[root@cloud01 script]# cat 1.txt 
1
2
3
a
b
c
A
B
C
[root@cloud01 script]# grep '[1a]' 1.txt 
1
a
[root@cloud01 script]# grep '[[:lower:]]' 1.txt 
a
b
c
[root@cloud01 script]# grep '[2[:lower:]A]' 1.txt 
2
a
b
c
A
    ```

*   数组的索引  
    一维数组: a[0]=foo  
    关联数组: declare -A colors ; colors["red"]="#ff0000"  
    遍历数组: a[@] 或 a[*]

    ```shell
[root@cloud01 script]# a[0]=test ; echo ${a[@]}
test
    ```

---
###`[[ ]]`
变量需要加$  
需要留空格,即[[ expression ]],而[[ expression]] 是语法错误  
匹配字符串或通配符不需要引号  
支持正则  
[[ 是bash语言的关键字。并不是一个命令

*   在 "[ ]" 结构的基础上,增加字符串支持正则,用于参数验证等  
    string `=~` regex

    ```shell
[root@cloud01 script]# a=6 ; if [[ $a =~ [0-9] ]] ; then echo "True" ; else echo "False" ; fi
True
[root@cloud01 script]# a=6 ; if [[ a =~ [0-9] ]] ; then echo "True" ; else echo "False" ; fi #变量需要加$
False
    ```

*   增加 `==` 操作符支持  
    类型匹配，正如路径名展开,使 [[ ]] 有助于计算文件和路径名

    ```shell
[root@cloud01 script]# FILE=1.txt ; if [[ $FILE == *.txt ]] ; then echo Y ; else echo N ; fi
Y
    ```

---
###`{ }`

*   花括号/大括号展开  
    大括号中，不允许有空白  
    以`逗号`分割 或以`..`分割

    ```shell
[root@cloud01 script]# ls [124].txt
1.txt  2.txt  4.txt
[root@cloud01 script]# ls {1,2,4}.txt
1.txt  2.txt  4.txt
[root@cloud01 script]# ls {1..4}.txt
1.txt  2.txt  3.txt  4.txt
    ```

*   基本变量  
    若变量名与其他文本相邻,则可界定变量名范围  
    访问第十一个位置参数：${11}

    ```shell
[root@cloud01 script]# a="AAA" ; echo "${a}_file"
AAA_file
    ```

*   组命令  
    大括号里的组命令不会新开一个子shell运行  
    大括号与命令之间必须有一个空格，并且最后一个命令必须用一个分号或者一个换行符终止  
    { command1; command2; command3; }

*   处理不存在和空变量的参数展开  
    用于解决丢失的位置参数和给参数指定默认值

    `${parameter:=word}`  
    若变量没有设置或者为空，则展开结果是 word 的值,`并把word赋值给变量`  
    若变量不为空,则正常展开  
    注：位置参数或其它的特殊参数不能以这种方式赋值
    
    ```shell
[root@cloud01 script]# a=   #变量a为空
[root@cloud01 ~]# echo ${a:=AAA}
AAA
[root@cloud01 script]# echo $a #赋值
AAA
[root@cloud01 ~]# a=aaa ; echo ${a:=AAA}  #变量不为空 正常展开
aaa
    ```

    `${parameter:-word}`  
    若变量没有设置或者为空，则展开结果是 word 的值,但是`不对变量赋值`
    
    ```shell
[root@cloud01 script]# b=
[root@cloud01 script]# echo ${b:-BBB}
BBB
[root@cloud01 script]# [[ -z "$b" ]] && echo Y || echo N #不赋值,变量仍为空
Y
[root@cloud01 script]# b=bbb ; echo ${b:-BBB}   #变量不为空 正常展开
bbb
    ```

    `${parameter:?word}`  
    若变量没有设置或者为空，这种展开导致脚本带有错误退出，并且 word 的内容会发送到标准错误  
    若变量不为空,则正常展开
    
    ```shell
[root@cloud01 script]# echo ${c:?error CCC}
-bash: c: error CCC
[root@cloud01 script]# echo $?
1
[root@cloud01 script]# c=ccc ; echo ${c:?error CCC}
ccc
    ```
    
    `${parameter:+word}`  
    若变量没有设置或者为空,展开结果为空  
    若变量不为空,展开结果用word的值替换变量自身的值,但是不对变量赋值
    
    ```shell
[root@cloud01 script]# d= #变量为空
[root@cloud01 script]# [[ -z "${e:+DDD}" ]] && echo Y || echo N #变量展开为空
Y
[root@cloud01 script]# d=ddd ; echo ${d:+DDD} #变量非空  则用word替换
DDD
    ```

*   返回变量名的参数展开  
    shell 具有返回变量名的能力  
    `${!prefix*}` 等同于 `${!prefix@}`  
    这种展开会返回以 prefix 开头的已有变量名

    ```shell
[root@cloud01 script]# aaa1=1
[root@cloud01 script]# aaa2=2
[root@cloud01 script]# echo ${!aaa*}
aaa1 aaa2
    ```

*   字符串展开

    `${#parameter}`  
    展开成由 parameter 所包含的字符串的长度  
    如果parameter 是 `@` 或者是 `*` 的话，则展开结果是位置参数的个数  

    ```shell
[root@cloud01 script]# a="123456 78" ; echo ${#a}
9
[root@cloud01 script]# test () {
> echo ${#@}
> }
[root@cloud01 script]# test 1 1 1 1
4
    ```

*   字符串提取  

    `${parameter:offset}`  
    `${parameter:offset:length}`  
    从 parameter 所包含的字符串中提取一部分字符  
    提取的字符`始于第 offset 个字符`（从字符串开头算起）直到字符串的末尾，或指定提取的长度 length  
    若 offset 的值为`负数`，则认为 offset 值是从字符串的末尾开始算起,截取方向仍然是向后  
    注意: 负数前面必须有一个空格 为防止与 ${parameter:-word} 展开形式混淆  
    length，若出现则必须不能小于零  
    如果 parameter 是 `@`，展开结果是 length 个位置参数，从`第 offset 个`位置参数开始 截取 length 个位置参数结束

    ```shell
[root@cloud01 script]# a=123456789 ; echo ${a:2}
3456789
[root@cloud01 script]# a=123456789 ; echo ${a:2:2} #起始于第二个字符,但是不包括第二个字符
34
[root@cloud01 script]# a=123456789 ; echo ${a: -2:1}
8
[root@cloud01 script]# a=123456789 ; echo ${a: -2:2}
89
[root@cloud01 script]# a=123456789 ; echo ${a: -2:3}
89
[root@cloud01 script]# test () {
> echo ${@:2:3}
> }
[root@cloud01 script]# test 11111 22222 33333 44444 55555 66666 #包括第二个位置变量
22222 33333 44444
    ```

*   字符串部分删除  
    \# 号 在键盘上 $ 之前, % 在 $ 之后  
    
    `${parameter#pattern}`  
    `${parameter##pattern}`  
    这种展开会从 paramter 所包含的字符串中删除`开头`一部分文本，删除的文本匹配 patten, pattern 是通配符模式(路径名展开)  
    \# 清除最短的匹配结果 而 \#\# 模式清除最长的匹配结果  

    `${parameter%pattern}`  
    `${parameter%%pattern}`  
    这种展开会从 paramter 所包含的字符串中删除`末尾`一部分文本，删除的文本匹配 patten, pattern 是通配符模式(路径名展开)  
    % 清除最短的匹配结果 而 %% 模式清除最长的匹配结果

    ```shell
[root@cloud01 script]# a=file.tar.bz2 ; echo ${a#*.} #匹配到"file." ,删除开头部分
tar.bz2
[root@cloud01 script]# a=file.tar.bz2 ; echo ${a##*.} #匹配到"file.tar." ,删除开头部分
bz2
[root@cloud01 script]# a=file.tar.bz2 ; echo ${a%.*} #匹配到".bz2" ,删除末尾部分
file.tar
[root@cloud01 script]# a=file.tar.bz2 ; echo ${a%%.*} # 匹配到".tar.bz2" ,删除末尾部分
file
    ```

*   字符串查找替换  
    




---
###其他

*   定义函数

    ```shell
fuction_name () {
    command
}
    ```

