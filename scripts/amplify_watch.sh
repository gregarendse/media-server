#!/bin/bash

set -x

LOG_FILE='/var/log/amplify-agent.restart.log'

dts=$(date --iso-8601=seconds)
amplify_output=$(systemctl status amplify-agent.service)
amplify_status="${?}"
echo "${dts} amplify-agent.service status: ${amplify_status}" > ${LOG_FILE}

if [[ "${amplify_status}" -ne 0 ]]; then
    amplify_output=$(systemctl start amplify-agent.service)
    amplify_status="${?}"
    dts=$(date --iso-8601=seconds)
    echo "${dts} amplify-agent.service status: ${amplify_status}" > ${LOG_FILE}
fi

