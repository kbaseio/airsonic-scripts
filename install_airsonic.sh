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
user="airsonic"

echo "********************"
echo "* AIRSONIC INSTALL *"
echo "********************"
echo
echo "Repo is $repo"
echo "Latest release is $release"
echo

if [ "$EUID" -ne 0 ]
  then echo "ERROR : Please run as root"
  exit
fi

echo "********************"
echo "*  NOT TESTED YET  *"
echo "********************"

echo "Do you want to install ?"
confirm

echo "Installation of OpenJDK 8 Runtime"
apt install openjdk-8-jre
update-alternatives --config java

echo "New User creation"
useradd $user

echo "Installation folder creation"
mkdir $installfolder

echo "Setting premission on installation folder"
chown $user $installfolder

echo "Downloading software and config"
wget https://github.com/$repo/releases/download/$release/airsonic.war  --output-document="$installfolder$warname"
wget https://raw.githubusercontent.com/$repo/master/contrib/airsonic.service -O /etc/systemd/system/airsonic.service
wget https://raw.githubusercontent.com/$repo/master/contrib/airsonic-systemd-env -O /etc/sysconfig/airsonic
wget https://raw.githubusercontent.com/$repo/master/contrib/airsonic-systemd-env -O /etc/default/airsonic

echo "Starting and Enabling Service"
systemctl daemon-reload
systemctl start airsonic.service
systemctl enable airsonic.service

