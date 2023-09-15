#!/bin/bash

set -x

sudo dnf install -y haproxy

#SELinux
sudo setsebool -P haproxy_connect_any=1

source ocp_vars.sh

cat <<EOF > /tmp/haproxy.cfg
#---------------------------------------------------------------------
# Example configuration for a possible web application.  See the
# full configuration options online.
#
#   https://www.haproxy.org/download/1.8/doc/configuration.txt
#
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

    # utilize system-wide crypto-policies
    #ssl-default-bind-ciphers PROFILE=SYSTEM
    #ssl-default-server-ciphers PROFILE=SYSTEM

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    tcp
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------

frontend api
    bind :6443
    default_backend controlplaneapi

#frontend apiinternal
#    bind :22623
#    default_backend controlplaneapiinternal
#
frontend secure
    bind :443
    default_backend secure

#---------------------------------------------------------------------
# static backend
#---------------------------------------------------------------------

backend controlplaneapi
    balance source
    server master0 ${MASTER0_IP}:6443 check
    server master1 ${MASTER1_IP}:6443 check
    server master2 ${MASTER2_IP}:6443 check


#backend controlplaneapiinternal
#    balance source
#    server master0 ${MASTER0_IP}:22623 check
#    server master1 ${MASTER1_IP}:22623 check
#    server master2 ${MASTER2_IP}:22623 check

backend secure
    balance source
    server compute0 ${MASTER0_IP}:443 check
    server compute1 ${MASTER1_IP}:443 check
    server compute2 ${MASTER2_IP}:443 check
EOF

sudo cp /tmp/haproxy.cfg /etc/haproxy/

sudo firewall-cmd --zone=public --permanent --add-service=https
sudo firewall-cmd --zone=public --permanent --add-port=6443/tcp

sudo firewall-cmd --zone=public --permanent --list-services
sudo firewall-cmd --zone=public --permanent --list-ports

sudo systemctl stop haproxy
sudo systemctl --now enable haproxy
