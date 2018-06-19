#!/bin/bash
set -e

if [ "$1" = 'bamboo-agent' ]; then
    # -l : Start a login shell so that JDK paths are evaluated via /etc/profile.d/*
    # -DDISABLE_AGENT_AUTO_CAPABILITY_DETECTION=true : Try to disable capability auto detection though I assume
    #       this won't work. See: https://jira.atlassian.com/browse/BAM-14937 
    #       and : https://jira.atlassian.com/browse/BAM-16502
    exec sudo -H -n -u bamboo bash -l -c "java -DDISABLE_AGENT_AUTO_CAPABILITY_DETECTION=true -jar /home/bamboo/atlassian-bamboo-agent-installer.jar $BAMBOO_SERVER/agentServer/"
fi

exec "$@"
