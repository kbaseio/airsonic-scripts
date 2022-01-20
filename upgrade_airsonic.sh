#!/bin/bash

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}


confirm() {
   read -p "Proceed? (Press any key to continue or CTRL+C to abort)"
}

repo="airsonic-advanced/airsonic-advanced"
release=$(get_latest_release $repo)
installfolder="/var/airsonic/"
warname="airsonic.war"

echo "********************"
echo "* AIRSONIC UPGRADE *"
echo "********************"
echo
echo "Repo is $repo"
echo "Latest release is $release"
echo

if [ "$EUID" -ne 0 ]
  then echo "ERROR : Please run as root"
  exit
fi

echo "Do you want to upgrade ?"
confirm

echo "Stoping Service"
systemctl stop airsonic.service

echo "Moving to Installation Folder"
cd $installfolder

echo "Renaming current WAR file"
mv $installfolder$warname "$installfolder$warname.old.`date +%Y%m%d_%H`"

echo "Downloading latest release into installation folder"
wget https://github.com/$repo/releases/download/$release/$warname --output-document="$installfolder$warname"

echo "Starting Sercice"
systemctl start airsonic.service