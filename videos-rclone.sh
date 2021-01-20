#!/bin/bash
set -o errexit
rclone copy videos-class nau-gdrive:teaching/2021-01-cs470-570/videos-class
rm -r videos-class/*.mp4 ~/Documents/Zoom/*
