#!/bin/bash

set -e
set -x

docker run -it --rm -v /usr/local/bin:/target emby/embyserver instl service
