#!/bin/bash

# cal day month year
if [[ $1 =~ ^[0-9]{8}$ ]]; then
    if [[ $(cal ${1:6:2} ${1:4:2} ${1:0:4}) ]]; then
        echo "Ok"
    else
        2>/dev/null
        echo "Error"
    fi
else
    echo "Usage:yyyymmdd"
    exit 1
fi


更简单的写法:
#!/bin/bash

# cal day month year
if [[ $1 =~ ^[0-9]{8}$ ]]; then
    cal ${1:6:2} ${1:4:2} ${1:0:4} &> /dev/null && echo "OK" || echo "Error"
else
    echo "Usage:yyyymmdd"
    exit 1
fi



TEST:

[root@cloud01 script]# ./test.sh 20160208
OK

[root@cloud01 script]# ./test.sh 20160232
Error

[root@cloud01 script]# ./test.sh 2016023223
Usage:yyyymmdd

[root@cloud01 script]# ./test.sh fafafwaf
Usage:yyyymmdd