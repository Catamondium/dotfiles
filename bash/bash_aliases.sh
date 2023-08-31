#!/bin/bash

# games
alias uwu='fortune | tee /tmp/fort.txt | fudd; cat /tmp/fort.txt'

# accident prevention
alias rm='rm -i'
alias mv='mv -i'

# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# programming
alias indent='indent -kr'
alias python='python3'
alias py='python3'
alias js='node'

# program setup
alias jrnl-nano='jrnl --config-override editor nano'
alias jrnl-mp='jrnl --config-override editor mousepad'

# utility aliases
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
