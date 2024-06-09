#!/bin/bash

# work
alias clockout='killall slack zoom'

# games
alias rand-poem='fortune songs-poems'
alias rand-words='shuf /usr/share/dict/british-english -n5'
alias uwu='fortune | tee /tmp/fort.txt | fudd; cat /tmp/fort.txt'
 # get all non-generated entries, remove tag marks and empty lines, shuffle
alias jrnl-rand='jrnl -not @random --format txt | sed -e '/^[[:space:]]*$/d' -e '/@/d' | shuf -n10'

# accident prevention
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# symlinks
lns='ln -s'

# programming
alias indent='indent -kr'
alias python='python3'
alias py='python3'
alias js='node'
alias ts='ts-node'

# TCL experimentation
alias tclsh='rlwrap tclsh'

# scratchpads
alias tmp_clear='rm -drf /tmp/sandbox'
alias tmppy='install -Db <(echo -e "#!/usr/bin/env python3\n")  /tmp/sandbox/main.py; cd /tmp/sandbox'
alias tmpjs='install -Db <(echo -e "#!/usr/bin/env node\n")  /tmp/sandbox/main.js; cd /tmp/sandbox'
alias tmpsh='install -Db <(echo -e "#!/usr/bin/bash\n")  /tmp/sandbox/main.sh; cd /tmp/sandbox'

# program setup
alias jrnl-nano='jrnl --config-override editor nano'
alias jrnl-mp='jrnl --config-override editor mousepad'

# utility aliases
alias dud='du -d 1 -h'
alias duf='du -sh'
alias hgrep='history | grep'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias upgrade-all='sudo apt -y update; sudo apt -y upgrade; sudo snap refresh; python3 -m pipx upgrade-all'

alias securerandom='openssl rand'
