#!/bin/bash

set -e
set -x

name="sonarr"		# Container Name
restart="always"		# Starts the Transmission container automatically during boot
config_location="/home/docker/${name}/config"	# Location of config files
downloads_location="/home/docker/transmission/downloads"	# Location of config files
series_location='/media/red_one/TV Shows'	# Location of config files
UserID="1001"			# User ID
GroupID="1001"			# Group ID
ui_port="8989"			# User Interface Port

docker create --name=${name} \
 --restart=${restart} \
 -p ${ui_port}:${ui_port} \
 -e PGID=${GroupID} -e PUID=${UserID} \
 -v /dev/rtc:/dev/rtc:ro \
 -v ${config_location}:/config \
 -v ${downloads_location}:/downloads\
 -v "${series_location}":"${series_location}" \
 linuxserver/sonarr

# Adapted from http://www.htpcbeginner.com/install-transmission-using-docker/
