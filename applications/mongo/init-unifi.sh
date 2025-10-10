#!/bin/bash

set -o noclobber # Avoid overlay files (echo "hi" > foo)
set -o errexit   # Used to exit upon error, avoiding cascading errors
set -o pipefail  # Unveils hidden failures
set -o nounset   # Exposes unset variables

# Configure log file location
LOG_FILE=${MONGO_INIT_LOG_FILE:-/var/log/mongo-init.log}

# Ensure log directory exists
LOG_DIR=$(dirname "${LOG_FILE}")
if [ ! -d "${LOG_DIR}" ]; then
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] Creating log directory: ${LOG_DIR}"
  mkdir -p "${LOG_DIR}" || echo "[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: Failed to create log directory ${LOG_DIR}"
fi

# Check if log file can be written
if [ -d "${LOG_DIR}" ] && [ -w "${LOG_DIR}" ]; then
  touch "${LOG_FILE}" 2>/dev/null || echo "[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: Cannot write to log file ${LOG_FILE}"
  if [ -f "${LOG_FILE}" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Log file ready: ${LOG_FILE}"
  fi
else
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: Log directory ${LOG_DIR} is not writable, logging to stdout only"
fi

# Function to log messages to both stdout and file
log() {
  if [ -f "${LOG_FILE}" ] && [ -w "${LOG_FILE}" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "${LOG_FILE}"
  else
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
  fi
}

# Function to log errors
log_error() {
  if [ -f "${LOG_FILE}" ] && [ -w "${LOG_FILE}" ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "${LOG_FILE}" >&2
  else
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
  fi
}

MONGO_UNIFI_USER=${MONGO_UNIFI_USER:-unifi}
MONGO_UNIFI_DBNAME=${MONGO_UNIFI_DBNAME:-unifi}

if [ -z "${MONGO_UNIFI_PASS}" ]; then
  log_error "MONGO_UNIFI_PASS is not set"
  exit 1
fi

MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME:-root}
MONGO_AUTHSOURCE=${MONGO_AUTHSOURCE:-unifi}

if [ -z "${MONGO_INITDB_ROOT_PASSWORD}" ]; then
  log_error "MONGO_INITDB_ROOT_PASSWORD is not set"
  exit 1
fi

if which mongosh > /dev/null 2>&1; then
  mongo_init_bin='mongosh'
else
  mongo_init_bin='mongo'
fi

log "Starting MongoDB initialization for UniFi"
log "Creating MongoDB user '${MONGO_UNIFI_USER}' with access to database '${MONGO_UNIFI_DBNAME}'"

"${mongo_init_bin}" --username "${MONGO_INITDB_ROOT_USERNAME}" --password "${MONGO_INITDB_ROOT_PASSWORD}" <<EOF
use ${MONGO_AUTHSOURCE}
db.createUser({
  user: "${MONGO_UNIFI_USER}",
  pwd: "${MONGO_UNIFI_PASS}",
  roles: [
    { db: "${MONGO_UNIFI_DBNAME}", role: "dbOwner" },
    { db: "${MONGO_UNIFI_DBNAME}_stat", role: "dbOwner" },
    { db: "${MONGO_UNIFI_DBNAME}_audit", role: "dbOwner" }
  ]
})
EOF

log "MongoDB user '${MONGO_UNIFI_USER}' created successfully"