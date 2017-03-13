#!/bin/bash
find /home/docker/transmission/downloads/complete/ -name '*.rar' -execdir unrar e -o- {} \;
