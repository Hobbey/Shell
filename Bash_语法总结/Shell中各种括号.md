##Shell 各种括号 `( ) (( )) [ ] [[ ]] { }`

---
###`( )`
*   命令组-子Shell  
    括号中的命令将会新开一个`子shell`顺序执行,注意子Shell变量
    括号中多个命令之间用分号隔开,最后一个命令可以没有分号,各命令和括号之间不必有空格
    (command;command;command;command)
*   命令 管道 替换
    \$(command) 等同于 \`command\`
*   用于初始化数组
    array=(a b c d)

---
###`(( 为整数设计 ))`
变量不用加\$

1.  完成(( ... ))内的整型算式,得到算式结果
    支持 `+ - * / %` 以及仅对变量生效的:`++ --`

    ```
[root@cloud01 script]# ((2+2)) #完成一个计算
[root@cloud01 script]# echo $(( (2+3) * 4 ))
20
[root@cloud01 script]# $((2+2)) #用计算的结果代替 $(( )) 结构
-bash: 4: command not found
[root@cloud01 script]# a=6 ; echo $((a+2)) #双括号中的变量可以不加$
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
11
[root@cloud01 script]# echo $((16#10 + 8#10))
24
    ```

1.  完成(( ... ))内的整型判断,得到`$?`
    支持 `> >=  < <=  == !=`

    ```
[root@cloud01 script]# a=6 ;if (( a > 5 && a < 9 ));then echo $a ;fi #正确形式
6
[root@cloud01 script]# a=6 ;if ((a>5&&a<9));then echo $a ;fi #可以没有多余空格
6
[root@cloud01 script]# a=6 ;if (( $a > 5 && a < 9 ));then echo $a ;fi #双括号中的变量可以不加$
6
[root@cloud01 script]# a=6 ;if (( ${a} > 5 && a < 9 ));then echo $a ;fi
6
[root@cloud01 script]# a=6 ; if (( a -gt 4 )); then echo ok;else echo error;fi #不支持 -eq 类形式
-bash: ((: a -gt 4 : syntax error in expression (error token is "4 ")
error
[root@cloud01 script]# a=6 ; if (( ((a%2)) == 0 )) ; then echo "\$a is even." ; else echo "\$a is odd." ; fi #运算双引号 嵌在 判断双引号 里
$a is even.
[root@cloud01 script]# for((i=0;i<3;i++));do echo $i ;done #个人常用for i in 这种形式
0
1
2
    ```

1.  判断算式的结果,得到 `\$?`  ~~个人很少用~~
    结果 `= 0` 则 \$?为1 即为假
    结果 `! = 0` 则 \$?为0 即为真

    ```
[root@cloud01 script]# if (( 0 )) ; then echo "True" ; else echo "False" ; fi
False
[root@cloud01 script]# if (( 2 - 1 )) ; then echo "True" ; else echo "False" ; fi
True
[root@cloud01 script]# if (( 2 - 2 )) ; then echo "True" ; else echo "False" ; fi
False
[root@cloud01 script]# if (( 2 - 3 )) ; then echo "True" ; else echo "False" ; fi
True
    ```

---
###`[ ]`
变量需要加\$

1.  [ 等价于 bash的内部命令 "test"
    if/test结构中的 "[" 是调用test命令的标识，"]" 是关闭条件判断
    文件判断: `-e -d 等`
    字符串比较: `== !=`
    整数比较: ` -eq 型 `
    逻辑与或: `-a -o`

    ```
个人认为可以废弃,不如 [[ ]] 型好用,语法还容易混
[root@cloud01 script]# a=6 ; if [ a -gt 5 ] ; then echo ok ; fi
-bash: [: a: integer expression expected
[root@cloud01 script]# a=6 ; if [ $a -gt 5 ] ; then echo ok ; fi #变量需要$符
ok
[root@cloud01 script]# a=6 ; if [ $a -gt 5 -a $a -lt 7] ; then echo ok ; fi
-bash: [: missing `]'
[root@cloud01 script]# a=6 ; if [ $a -gt 5 -a $a -lt 7 ] ; then echo ok ; fi #需要留空格
ok
[root@cloud01 script]# FILE="aa.txt" ; if [ -e "$FILE" ]; then echo "file exists" ; else echo "file not exists" ; fi #正确
file exists
[root@cloud01 script]# FILE="aa.txt" ; if [ -e "$AAAA" ]; then echo "file exists" ; else echo "file not exists" ; fi #变量未定义,展开为空值,有双引号,结果正确
file not exists
[root@cloud01 script]# FILE="aa.txt" ; if [ -e $AAAA ]; then echo "file exists" ; else echo "file not exists" ; fi #结果错误,用引号把参数引起来能确保了操作符之后总是跟随着一个字符串，即使字符串为空,所以习惯性判断 字符串 都加引号
file exists
    ```

1.  正则通配符

    ```
grep -h '^[A-Za-z0-9]' dirlist*.txt
    ```

1.  数组索引

    ```
[root@cloud01 script]# a[0]=test ; echo ${a[0]}
test
    ```

---
###`[[ ]]`
变量需要加\$

[[ 是 bash 程序语言的关键字。并不是一个命令, [[ ]] 结构比[ ]结构更加通用。

*   文件判断
    支持`-e -f -d`等,详见附表

    ```
[root@cloud01 script]# touch aa.txt 
[root@cloud01 script]# if [[ -e aa.txt ]];then echo "True" ;fi
True
[root@cloud01 script]# if [[ -e aa.txt]];then echo "True" ;fi #需要留空格
-bash: syntax error in conditional expression: unexpected token `;'
-bash: syntax error near `;t'
[root@cloud01 script]# FILE="aa.txt" ; if [[ -e "$FILE" ]]; then echo "file exists" ; else echo "file not exists" ; fi
[root@cloud01 script]# FILE="aa.txt" ; if [ -e FILE ]; then echo "file exists" ; else echo "file not exists" ; fi #变量需要$符
file not exists
file exists
[root@cloud01 script]# FILE="aa.txt" ; if [[ -e "$AAAA" ]]; then echo "file exists" ; else echo "file not exists" ; fi
file not exists
[root@cloud01 script]# FILE="aa.txt" ; if [[ -e $AAAA ]]; then echo "file exists" ; else echo "file not exists" ; fi #所以说[[ ]]比[ ]方便,不知不觉避免了很多错误 
file not exists
    ```

*   字符串判断
    支持`-n -z > ==`等,详见附表

    ```
[root@cloud01 script]# a='abc' ; if [[ -n "$a" ]] ; then echo OK ; else echo "Error" ;fi
OK
[root@cloud01 script]# a='abc' ; if [[ -z "$a" ]] ; then echo OK ; else echo "Error" ;fi
Error
    ```


支持字符串的模式匹配
*   字符串的模式匹配,支持正则,匹配字符串或通配符，不需要引号。
    [[ =~ ]]
*   if 判断
    支持 && || < >

---
###`{ }`
*   文件名扩展 
    在大括号中，不允许有空白，除非这个空白被引用或转义
    touch {a..d}.txt
*   组命令
    大括号内的命令不会新开一个子shell运行
    括号内的命令间用分号隔开，最后一个也必须有分号。{}的第一个命令和左括号之间必须要有一个空格
    { command;command;command;command; }
*   变量预设
    \${var:-string},\${var:+string},\${var:=string},\${var:?string}
*   变量替换
    # 是去掉左边(在键盘上#在\$之左边)
    % 是去掉右边(在键盘上%在\$之右边)
    #和%中的单一符号是最小匹配，两个相同符号是最大匹配。
    \${var%pattern},\${var%%pattern},\${var#pattern},\${var##pattern}
*   变量提取
    \${var:num},\${var:num1:num2},\${var/pattern/pattern},\${var//pattern/pattern}

###`$`
（1）\${a} 变量a的值, 在不引起歧义的情况下可以省略大括号。

（2）\$(cmd) 命令替换，和\`cmd\`效果相同，结果为shell命令cmd的输，过某些Shell版本不支持$()形式的命令替换, 如tcsh。

（3）\$((expression)) 和\`exprexpression\`效果相同, 计算数学表达式exp的数值, 其中exp只要符合C语言的运算规则即可, 甚至三目运算符和逻辑表达式都可以计算。

（1）单小括号，(cmd1;cmd2;cmd3) 新开一个子shell顺序执行命令cmd1,cmd2,cmd3, 各命令之间用分号隔开, 最后一个命令后可以没有分号。

（2）单大括号，{ cmd1;cmd2;cmd3;} 在当前shell顺序执行命令cmd1,cmd2,cmd3, 各命令之间用分号隔开, 最后一个命令后必须有分号, 第一条命令和左括号之间必须用空格隔开。
对{}和()而言, 括号中的重定向符只影响该条命令， 而括号外的重定向符影响到括号中的所有命令。