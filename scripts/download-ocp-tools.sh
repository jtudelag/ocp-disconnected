#!/bin/bash
#
#date         :17/08/23
#version      :0.3
#authors      :jtudelag@redhat.com
#description  :Script to download and compress OpenShift CLIs for a discconected installation.
#              This script has to be executed on a RHEL server with connectivity to internet.
#              This script is no handling RPMs packages for now, only binaries.
#
#==========================================================================================

#set -x
set -euo pipefail

# Variables
# OCP graph: https://ctron.github.io/openshift-update-graph/#stable-4.12
OCP_MAJOR=4
OCP_MINOR=12
OCP_PATCH=28
OCP_XY="${OCP_MAJOR}.${OCP_MINOR}"
OCP_XYZ="${OCP_XY}.${OCP_PATCH}"
GOVC_VERSION="v0.30.7"

OCP_MIRROR_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-${OCP_XY}"

CLI_INSTALL_FILE="openshift-install-linux.tar.gz"
CLI_OC_FILE="openshift-client-linux.tar.gz"
CLI_OC_MIRROR_FILE="oc-mirror.tar.gz"
CLI_OPM_FILE="opm-linux.tar.gz"
HELM_FINAL_URL="https://mirror.openshift.com/pub/openshift-v4/clients/helm/latest/helm-linux-amd64"
BUTANE_FINAL_URL="https://mirror.openshift.com/pub/openshift-v4/clients/butane/latest/butane-amd64"
ROXCTL_FINAL_URL="https://mirror.openshift.com/pub/rhacs/assets/latest/bin/linux/roxctl"

GOVC_FINAL_URL="https://github.com/vmware/govmomi/releases/download/${GOVC_VERSION}/govc_Linux_x86_64.tar.gz"
GOVC_FILE="govc_Linux_x86_64.tar.gz"

BINARY_FOLDER="/usr/local/bin"

TMPDIR="$(mktemp -d -q)"
TARGZ_FOLDER="$(mktemp -d -q)"

dl_openshift_install () {
  echo "Downloading openshift-install ;)"
  DEST_FOLDER=${1:-$BINARY_FOLDER}
  curl -Lo "$CLI_INSTALL_FILE" "$OCP_MIRROR_URL/${CLI_INSTALL_FILE}"
  sudo tar xvfz "$CLI_INSTALL_FILE" --directory "${DEST_FOLDER}/" openshift-install
  sudo chmod +x "${DEST_FOLDER}/openshift-install"
  sudo chown root:root "${DEST_FOLDER}/openshift-install"
}

dl_oc () {
  echo "Downloading oc ;)"
  DEST_FOLDER=${1:-$BINARY_FOLDER}
  curl -Lo "$CLI_OC_FILE" "$OCP_MIRROR_URL/${CLI_OC_FILE}"
  sudo tar xvfz "$CLI_OC_FILE" --directory "${DEST_FOLDER}/" oc
  sudo chmod +x "${DEST_FOLDER}/oc"
  sudo chown root:root "${DEST_FOLDER}/oc"
}

dl_oc_mirror () {
  echo "Downloading oc-mirror plugin ;)"
  #DEST_FOLDER=${1:-$BINARY_FOLDER}
  DEST_FOLDER=${1:-$BINARY_FOLDER}
  curl -Lo "$CLI_OC_MIRROR_FILE" "$OCP_MIRROR_URL/${CLI_OC_MIRROR_FILE}"
  sudo tar xvfz "$CLI_OC_MIRROR_FILE" --directory "${DEST_FOLDER}/" oc-mirror
  sudo chmod 755 "${DEST_FOLDER}/oc-mirror"
  sudo chown root:root "${DEST_FOLDER}/oc-mirror"
}

dl_opm () {
  echo "Downloading opm ;)"
  DEST_FOLDER=${1:-$BINARY_FOLDER}
  curl -Lo "$CLI_OPM_FILE" "$OCP_MIRROR_URL/${CLI_OPM_FILE}"
  sudo tar xvfz "$CLI_OPM_FILE" --directory "${DEST_FOLDER}/" opm
  sudo chmod +x "${DEST_FOLDER}/opm"
  sudo chown root:root "${DEST_FOLDER}/opm"
}

dl_helm () {
  echo "Downloading helm ;)"
  DEST_FOLDER=${1:-$BINARY_FOLDER}
  sudo curl -Lo "${DEST_FOLDER}/helm" "${HELM_FINAL_URL}"
  sudo chmod +x "${DEST_FOLDER}/helm"
  sudo chown root:root "${DEST_FOLDER}/helm"
}

dl_butane () {
  echo "Downloading butane ;)"
  DEST_FOLDER=${1:-$BINARY_FOLDER}
  sudo curl -Lo "${DEST_FOLDER}/butane" "${BUTANE_FINAL_URL}"
  sudo chmod +x "${DEST_FOLDER}/butane"
  sudo chown root:root "${DEST_FOLDER}/butane"
}

dl_roxctl () {
  echo "Downloading roxctl, RHACS CLI ;)"
  DEST_FOLDER=${1:-$BINARY_FOLDER}
  sudo curl -Lo "${DEST_FOLDER}/roxctl" "${ROXCTL_FINAL_URL}"
  sudo chmod +x "${DEST_FOLDER}/roxctl"
  sudo chown root:root "${DEST_FOLDER}/roxctl"
}

dl_govc () {
  echo "Downloading govc, vSphere CLI ;)"
  DEST_FOLDER=${1:-$BINARY_FOLDER}
  curl -Lo "$GOVC_FILE" "$GOVC_FINAL_URL"
  sudo tar xvfz "$GOVC_FILE" --directory "${DEST_FOLDER}/" govc
  sudo chmod +x "${DEST_FOLDER}/govc"
  sudo chown root:root "${DEST_FOLDER}/govc"
}

dl_all () {
  echo "Downloading OpenShift CLI binaries ;)"
  DEST_FOLDER=${1:-$BINARY_FOLDER}
  dl_openshift_install "$DEST_FOLDER"
  dl_oc "$DEST_FOLDER"
  dl_oc_mirror "$DEST_FOLDER"
  dl_opm "$DEST_FOLDER"
  dl_helm "$DEST_FOLDER"
  dl_butane "$DEST_FOLDER"
  dl_roxctl "$DEST_FOLDER"
  dl_govc "$DEST_FOLDER"

} 

# Main

cd "$TMPDIR"

mkdir "$TARGZ_FOLDER/bin"
DEST_FOLDER="$TARGZ_FOLDER/bin"

TS=$(date +"%Y-%m-%d_%H%M%S")
OUT_FILE="ocp_bin_${TS}.tar.gz"

dl_all "$DEST_FOLDER"
tar cvfz "${OUT_FILE}" -C "${DEST_FOLDER}/" .

echo -e "\nYour OpenShift CLI binaries tar file: ${TMPDIR}/${OUT_FILE}\n"
echo -e "To decompress it on your target system, please run the command: sudo tar xvfz ${TMPDIR}/${OUT_FILE} -C /usr/local/bin/\n"
