#!/bin/bash

set -e
set -x

name="jacket" 					# Name of the container
restart="always"				# Restart the docker container on system boot
config_lcoation="/home/greg/config/jackett"	# Location of config files
download_location="/home/greg/downloads/queue"	# Location where torrent files will be downloaded to
user_id="1001"					# Set the user
time_zone="Africa/Johannesburg"			# Set the time zone
client_port="9117"				# Set the port used by the torrent client

docker create --name=${name} \
--restart=${restart} \
-v ${config_lcoation}:/config \
-v ${download_location}:/downloads \
-e PGID=${user_id} -e PUID=${user_id} \
-e TZ=${time_zone} \
-p ${client_port}:${client_port} \
linuxserver/jackett
