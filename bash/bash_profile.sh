#!/bin/bash

### START SSH AGENT ACTIVATION

SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

### END SSH AGENT ###

export PATH="$HOME/.cargo/bin:$HOME/.nimble/bin:$PATH"

export INTELFPGAOCLSDKROOT="/home/liambirtles/intelFPGA_pro/19.3/hld"

export QSYS_ROOTDIR="/home/liambirtles/intelFPGA_pro/19.3/qsys/bin"

export PATH="$HOME/.cargo/bin:$PATH"
