#!/bin/bash
logs_path="/usr/local/nginx/logs/"
pid_path="/usr/local/nginx/logs/nginx.pid"
yesterday=$(date -d "-1 day" +%Y-%m-%d)

mv ${logs_path}access.log ${logs_path}access.log.${yesterday}
mv ${logs_path}error.log ${logs_path}error.log.${yesterday}

kill -USR1 `cat ${pid_path}`





vim /home/script/cut_nginxlog.sh
chmod 700 /home/script/cut_nginxlog.sh
0 0 * * * /bin/bash /home/script/cut_nginxlog.sh
