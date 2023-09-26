#!/bin/bash

#Based on a KCS: https://access.redhat.com/solutions/7019225

sudo dnf install -y yum-utils

REPO_FOLDER="/var/repos"
ANSIBLE_NAVIGATOR_REPO="ansible-automation-platform-2.4-for-rhel-8-x86_64-rpms"
OUTPUT_FILE="local-app24-repo.tar.gz"

reposync -p "${REPO_FOLDER}" --download-metadata --repoid="${ANSIBLE_NAVIGATOR_REPO}"

echo ""
echo "Copy the following repo file to the folder /etc/yum.repos.d/local-app24.repo"
echo "Replace <REPO_FOLDER> with the absolute path to the repository folder in your machine"
echo ""

cat <<EOF
[local-app24-repo]
name=Ansible Automation Platform 2.4
gpgcheck=0
enabled=1
baseurl=file://<REPO_FOLDER>
EOF


tar cvfz "${OUTPUT_FILE}" -C "${REPO_FOLDER}" "${ANSIBLE_NAVIGATOR_REPO}"

echo ""
echo "Copy the file ${OUTPUT_FILE} to your disconnected machibe and uncompressed inside your <REPO_FOLDER>:"
echo "                          tar xvfz ${OUTPUT_FILE} --directory <REPO_FOLDER>"
echo ""
