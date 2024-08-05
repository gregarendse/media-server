#!/bin/bash

set -o noclobber # Avoid overlay files (echo "hi" > foo)
set -o errexit   # Used to exit upon error, avoiding cascading errors
set -o pipefail  # Unveils hidden failures
set -o nounset   # Exposes unset variables

if pidof -o %PPID -x "sftp-backup.sh"; then
    exit 1
fi

rclone sync /mnt/data onedrive:/trinity/data \
    --config /home/greg/.config/rclone/rclone.conf \
    --checksum \
    --copy-links \
    --delete-excluded \
    --delete-during \
    --exclude "Downloads/**" \
    --exclude "**/MediaCover/**" \
    --exclude "**/Cache/**" \
    --exclude "**/cache/**" \
    --exclude "**/Media/**" \
    --exclude "**/Metadata/**" \
    --exclude "**/Metadata/**" \
    --exclude "**/Cache/**" \
    --exclude "**/Codecs/**" \
    --exclude "**/Crash Reports/**" \
    --exclude "**/Diagnostics/**" \
    --exclude "**/Drivers/**" \
    --exclude "**/Logs/**" \
    --exclude "**/logs/**" \
    --exclude "**/Media/**" \
    --exclude "**/Metadata/**" \
    --exclude "**/Plug-ins/**" \
    --exclude "**/Plug-in Support/**" \
    --exclude "**/Scanners/**" \
    --exclude "**/Updates/**" \
    --exclude "plex/Library/**" \
    --exclude "plex/Library.tar.gz" \
    --exclude "greg/**" \
    --log-file /var/log/rclone/data.log
