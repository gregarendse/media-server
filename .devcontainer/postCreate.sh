#!/bin/sh

mkdir -p ${HOME}/.ssh

ssh-keyscan github.com >> ${HOME}/.ssh/known_hosts

echo "${FILE_SSH_ID_ED25519}" > ${HOME}/.ssh/id_ed25519
chmod 600 ${HOME}/.ssh/id_ed25519
