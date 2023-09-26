#!/bin/bash

set -euxo pipefail

curl -L https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64 -o mkcert
sudo mv mkcert /usr/local/bin/mkcert
sudo chmod +x /usr/local/bin/mkcert
sudo chown root:root /usr/local/bin/mkcert

REGISTRY_FOLDER="/var/registry"

mkdir -p "${REGISTRY_FOLDER}/lib"
mkdir -p "${REGISTRY_FOLDER}/auth"
mkdir -p "${REGISTRY_FOLDER}/certs"

mkcert -cert-file "${REGISTRY_FOLDER}/certs/cert.pem" -key-file "${REGISTRY_FOLDER}/certs/cert.key" "localhost"
mkcert -install

htpasswd -Bbn jorge mypass > "${REGISTRY_FOLDER}/auth/auth"

#podman stop registry2
#podman kill registry2
#podman rm registry2

podman container run -dt -p 5000:5000 \
                     --name registry2 \
                     -v "${REGISTRY_FOLDER}/auth:/auth":Z \
                     -e "REGISTRY_AUTH=htpasswd" \
                     -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
                     -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/auth \
                     -v "${REGISTRY_FOLDER}/certs:/certs":Z \
                     -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/cert.pem \
                     -e REGISTRY_HTTP_TLS_KEY=/certs/cert.key \
                     -v "${REGISTRY_FOLDER}/lib:/var/lib/registry":Z docker.io/library/registry:2

curl -k -u jorge:mypass https://localhost:5000/v2/

