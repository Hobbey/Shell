# ls
alias ll='ls -lsh --time-style="long-iso"'
alias l.='ls -lshd --time-style="long-iso" .*'

# docker
alias d='docker'
alias di='docker images'
alias dps='docker ps -a'
alias dcl="sudo docker ps -a | grep Exited | awk '{print $1}' | xargs -i sudo docker rm {}"

# log
alias j='journalctl'

# other
alias ap='ansible-playbook'
alias grep='grep --color=auto'
