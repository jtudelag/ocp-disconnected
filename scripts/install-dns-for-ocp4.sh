#!/bin/bash

set -x

source ocp_vars.sh

sudo dnf install -y dnsmasq

cat <<EOF > /tmp/ocp4.conf
host-record=master-0.ocp4.abi.com,${MASTER0_IP}
host-record=master-1.ocp4.abi.com,${MASTER1_IP}
host-record=master-2.ocp4.abi.com,${MASTER2_IP}
host-record=worker-0.ocp4.abi.com,${WORKER0_IP}

host-record=api.ocp4.abi.com,${OCP4_API_IP}
address=/apps.ocp4.abi.com/${OCP4_INGRESS_IP}

listen-address=${DNS_IP}

server=1.1.1.1
server=8.8.8.8
EOF

sudo cp /tmp/ocp4.conf /etc/dnsmasq.d/

sudo firewall-cmd --zone=public --permanent --add-service=dns
sudo firewall-cmd --zone=public --permanent --list-services

sudo systemctl stop dnsmasq
sudo systemctl --now enable dnsmasq
