#!/bin/bash

# configured as a reduced extension file for appending

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

### custom ###
if [ $( command -v mousepad ) ] ; then
  export EDITOR='mousepad'
else
  export EDITOR='vi'
fi

# ENV
PYTHON=python3

### pallete
red="\[`tput setaf 1`\]"
purple="\[`tput setaf 5`\]"
white="\[`tput setaf 7`\]"
cyan="\[`tput setaf 6`\]"
bold="\[`tput bold`\]"
reset="\[`tput sgr0`\]"

### PS1 override

parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

usrhost="$reset$cyan\u$white@$purple\h"
dirgit="$cyan$bold\w$reset$purple\$(parse_git_branch)$white"

export PS1="$CHROOT$usrhost:$dirgit\\$> $reset"
