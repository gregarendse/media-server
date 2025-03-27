#!/bin/sh

if [[ ! -d "${HOME}/.ssh" ]]; then
    mkdir -p ${HOME}/.ssh
fi

ssh-keyscan github.com >> "${HOME}/.ssh/known_hosts"

echo "${FILE_SSH_ID_ED25519}" | base64 --decode > "${HOME}/.ssh/id_ed25519"
chmod 400 ${HOME}/.ssh/id_ed25519

echo "${FILE_SSH_ID_RSA}" | base64 --decode > "${HOME}/.ssh/id_rsa"
chmod 400 ${HOME}/.ssh/id_rsa

if [[ ! -d "${HOME}/.oci" ]]; then
    mkdir -p ${HOME}/.oci
fi

echo "${FILE_OCI_KEY}" | base64 --decode > "${HOME}/.oci/oci_api_key.pem"
chmod 400 ${HOME}/.oci/oci_api_key.pem


if [[ ! -d "${HOME}/.kube" ]]; then
    mkdir -p ${HOME}/.kube
fi

echo "${FILE_KUBE_CONFIG}" | base64 --decode > "${HOME}/.kube/config"
chmod 600 ${HOME}/.kube/config

export TF_VAR_tenancy_ocid="${OCI_TENANCY_OCID}"
export TF_VAR_user_ocid="${OCI_USER_OCID}"
export TF_VAR_fingerprint="${OCI_FINGERPRINT}"
export TF_VAR_region="${OCI_REGION}"
