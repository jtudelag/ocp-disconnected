#!/bin/bash

#wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64
#sudo mv mkcert-v1.4.4-linux-amd64 /usr/local/bin/mkcert
#sudo chmod +x /usr/local/bin/mkcert
#sudo chown root:root /usr/local/bin/mkcert

mkdir -p ~/.registry/{lib,auth,certs}

mkcert -cert-file ~/.registry/certs/cert.pem -key-file ~/.registry/certs/cert.key "localhost"

htpasswd -Bbn jorge mypass > ~/.registry/auth/auth

podman stop registry2
podman kill registry2
podman rm registry2

podman container run -dt -p 5000:5000 \
                     --name registry2 \
                     -v "$HOME/.registry/auth:/auth":Z \
                     -e "REGISTRY_AUTH=htpasswd" \
                     -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
                     -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/auth \
                     -v "$HOME/.registry/certs:/certs":Z \
                     -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/cert.pem \
                     -e REGISTRY_HTTP_TLS_KEY=/certs/cert.key \
                     -v "$HOME/.registry/lib:/var/lib/registry":Z docker.io/library/registry:2

curl -k -u jorge:mypass https://localhost:5000/v2/

