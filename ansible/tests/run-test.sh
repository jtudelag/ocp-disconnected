#!/bin/bash

export VMWARE_HOST='XXX'
export VMWARE_USER='YYY'
export VMWARE_PASSWORD='XXX'

ansible-navigator run -m stdout  --pp missing --pae false --lf /tmp/out.log test-playbook.yaml

# Broken lookups in the vmware.vmware_rest collection of the latest EEs. 
# Using AAP 2.3 EE: https://github.com/ansible-collections/vmware.vmware_rest/issues/356
#ansible-navigator run -m stdout  --pp missing --pae false --lf /tmp/out.log --eei registry.redhat.io/ansible-automation-platform-23/ee-supported-rhel8:1.0.0 test-vsphere-connection.yaml
