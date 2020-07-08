#!/bin/bash

# Don't run if it's already run
if [ -d /var/scripts ]
then
    exit
fi

# shellcheck disable=2034,2059
true
# shellcheck source=lib.sh
. <(curl -sL https://raw.githubusercontent.com/nextcloud/vm/official/lib.sh)

# T&M Hansson IT AB © - 2020, https://www.hanssonit.se/

# Check for errors + debug code and abort if something isn't right
# 1 = ON
# 0 = OFF
DEBUG=0
debug_mode

# Check if dpkg or apt is running
is_process_running apt
is_process_running dpkg

# Create scripts folder
mkdir -p "$SCRIPTS"

# Get needed scripts for first bootup
download_script STATIC instruction
download_script STATIC history
download_script STATIC static_ip
download_script GITHUB_REPO lib
download_script GITHUB_REPO nextcloud_install_production

# Make $SCRIPTS excutable
chmod +x -R "$SCRIPTS"
chown root:root -R "$SCRIPTS"

# Prepare first bootup
check_command run_script STATIC change-ncadmin-profile
check_command run_script STATIC change-root-profile

# Upgrade
apt update -q4 & spinner_loading
apt dist-upgrade -y

# Remove LXD (always shows up as failed during boot)
apt-get purge lxd -y

# Put IP adress in /etc/issue (shown before the login)
if [ -f /etc/issue ]
then
    echo "\4" >> /etc/issue
    echo "USER: ncadmin" >> /etc/issue
    echo "PASS: nextcloud" >> /etc/issue
fi
