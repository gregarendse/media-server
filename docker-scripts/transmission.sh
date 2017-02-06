#!/bin/bash

set -e
set -x

name="transmission"		# Container Name
restart="always"		# Starts the Transmission container automatically during boot
config_location="/home/docker/transmission/config"	# Location of config files
download_location="/home/docker/transmission/downloads"	# Location to download into
watch_location="/home/docker/transmission/downloads"	# Location of watch directory
UserID="1001"			# User ID
time_zone="Africa/Johannesburg"	# Time zone
download_port="51413"		# Download port
ui_port="9091"			# User Interface Port

docker create --name=${name} \
 --restart=${restart} \
 -v ${config_location}:/config \
 -v ${download_location}:/downloads \
 -v ${watch_location}:/watch \
 -e PGID=${UserID} -e PUID=${UserID} \
 -e TZ=${time_zone} \
 -p ${ui_port}:${ui_port} -p ${download_port}:${download_port} \
 -p ${download_port}:${download_port}/udp \
 linuxserver/transmission
