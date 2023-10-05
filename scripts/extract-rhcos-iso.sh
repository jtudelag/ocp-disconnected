#!/bin/bash

source ocp_vars.sh

DEST_FOLDER="./test-iso/"

#DONT CHANGE!!!
RHCOS_ISO="/coreos/coreos-x86_64.iso"

OCP_RELEASE_IMAGE="quay.io/openshift-release-dev/ocp-release:${OCP_XYZ}-x86_64"

OCP_MACHINE_OS_IMAGE=$(oc adm release info --image-for=machine-os-images ${OCP_RELEASE_IMAGE})

# --confirm is require if the dest folder is not empty.
oc image extract --confirm \
                 --path=${RHCOS_ISO}:${DEST_FOLDER} \
                 ${OCP_MACHINE_OS_IMAGE}

#TODO: Thse two files can of help also:
# /coreos/coreos-stream.json
# /coreos/coreos-x86_64.iso.sha256
