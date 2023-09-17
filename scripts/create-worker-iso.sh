#!/bin/bash

# Based on this: https://gist.github.com/gellner/f1f2928f847355ae80d0867884569109

NEW_WORKER_FOLDER="worker-1"
ISO_NAME="./rhcos-live.x86_64.iso"
NM_FILE="ens192.nmconnection"
CA="ca.pem"
IGNITION="worker.ign"
DEVICE="/dev/sda"

coreos-installer iso customize "${ISO_NAME}" \
	     --network-keyfile "${NEW_WORKER_FOLDER}/${NM_FILE}" \
	     --ignition-ca "${NEW_WORKER_FOLDER}/${CA}" \
	     --dest-ignition "${NEW_WORKER_FOLDER}/${IGNITION}" \
	     --dest-device "${DEVICE}" \
             --output "${NEW_WORKER_FOLDER}/${NEW_WORKER_FOLDER}.iso"
