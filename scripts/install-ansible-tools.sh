#!/bin/bash

set -x

source ocp_vars.sh

sudo subscription-manager repos --enable ansible-automation-platform-2.4-for-rhel-8-x86_64-rpms

sudo dnf install -y ansible-core ansible-navigator ansible-builder

TOKEN="$(cat $ANSIBLE_AUTOMATION_HUB_TOKEN_FILE)"

cat <<EOF > ./ansible.cfg
[defaults]
interpreter_python=/usr/bin/python3

[galaxy]
server_list = ansible_automation_hub, galaxy

[galaxy_server.ansible_automation_hub]
url=https://console.redhat.com/api/automation-hub/content/published/
auth_url=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token

# Dont use quotes, single or double!!! 
# Otherwise this wont work!!!!!!!
token= ${TOKEN}

[galaxy_server.galaxy]
url=https://galaxy.ansible.com/
EOF


