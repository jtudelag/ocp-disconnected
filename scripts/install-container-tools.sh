#!/bin/bash

source ocp_vars.sh

sudo dnf install -y podman skopeo

mkdir -p $HOME/.docker/

cp "${PULL_SECRET_FILE}" "$HOME/.docker/config.json"
