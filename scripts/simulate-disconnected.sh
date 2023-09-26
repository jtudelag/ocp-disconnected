#!/bin/bash

#Block quay.io and registry.redhat.io
# https://docs.openshift.com/container-platform/4.13/installing/install_config/configuring-firewall.html

## VARS ##
IFACE="em3"

URLS_TO_BLOCK="
registry.redhat.io
access.redhat.com
quay.io
cdn.quay.io
cdn01.quay.io
cdn02.quay.io
cdn03.quay.io
sso.redhat.com
registry.connect.redhat.com
rhc4tp-prod-z8cxf-image-registry-us-east-1-evenkyleffocxqvofrk.s3.dualstack.us-east-1.amazonaws.com
oso-rhc4tp-docker-registry.s3-us-west-2.amazonaws.com
"


## FUNCTIONS ##
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

function block_ip(){
  IP="$1"
  firewall-cmd --direct --add-rule ipv4 filter OUTPUT 1 -o "${IFACE}" -d "${IP}/32" -j REJECT
}

function block_url(){
  URL="$1"
  DNS_RESOLUTION=$(dig +short "$URL")

  for i in $DNS_RESOLUTION
  do

   ip="$i"
   if valid_ip $ip
   then
     block_ip "$ip"
   fi

  done;

}

## MAIN 
for url in $URLS_TO_BLOCK
do
  block_url "$url"
done

#Show rules
firewall-cmd --direct --get-rules ipv4 filter OUTPUT
