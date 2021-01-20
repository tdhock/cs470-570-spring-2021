#!/bin/bash
set -o errexit
rclone copy . nau-gdrive:teaching/2021-01-cs470-570/backup

