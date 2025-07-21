#!/usr/bin/env bash

set -o noclobber  # Avoid overlay files (echo "hi" > foo) 
set -o errexit    # Used to exit upon error, avoiding cascading errors 
set -o pipefail   # Unveils hidden failures 
set -o nounset    # Exposes unset variables 

USER="ubuntu"
TAILSCALE_ADDR="$(tailscale status --peers --json | jq --raw-output '.Peer | to_entries[] | select( .value.DNSName | startswith("oci-alpha") ) | .value.TailscaleIPs[0]')"
echo "Tailscale IP: ${TAILSCALE_ADDR}"

# Install k3s; merge the kubeconfig with the user's home kubeconfig instead of
# sporadically dropping kubeconfig files all over.
k3sup install \
    --ip "${TAILSCALE_ADDR}" \
    --user "$USER" \
    --ssh-key "$HOME/.ssh/id_ed25519" \
    --cluster \
    --k3s-extra-args "--flannel-iface tailscale0 \
        --flannel-backend=wireguard-native \
        --advertise-address $TAILSCALE_ADDR \
        --node-ip $TAILSCALE_ADDR \
        --node-external-ip $TAILSCALE_ADDR \
        --tls-san=kubernetes.arendse.nom.za \
        --node-name oci-alpha \
        --cluster-cidr=10.42.0.0/16 \
        --service-cidr=10.43.0.0/16" \
    --k3s-channel latest \
    --local-path $HOME/.kube/config

MASTER_NODE="${TAILSCALE_ADDR}"
TAILSCALE_ADDR="$(tailscale status --peers --json | jq --raw-output '.Peer | to_entries[] | select( .value.DNSName | startswith("oci-bravo") ) | .value.TailscaleIPs[0]')"
echo "Tailscale IP: ${TAILSCALE_ADDR}"

k3sup join \
    --server \
    --server-ip "$MASTER_NODE" \
    --ip "${TAILSCALE_ADDR}" \
    --user "$USER" \
    --ssh-key "$HOME/.ssh/id_ed25519" \
    --k3s-extra-args "--flannel-iface tailscale0 \
        --flannel-backend=wireguard-native \
        --node-ip $TAILSCALE_ADDR \
        --node-external-ip $TAILSCALE_ADDR \
        --tls-san=kubernetes.arendse.nom.za \
        --node-name oci-bravo" \
    --k3s-channel latest

exit 0
