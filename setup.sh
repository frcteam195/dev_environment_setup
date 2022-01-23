#!/bin/bash

VSCODE_x86_64='https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
VSCODE_aarch64='https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64'
VSCODE=
case "$(arch)" in
    "x86_64"|"amd64")
        VSCODE=${VSCODE_x86_64}
        ;;
    "aarch64"|"arm64")
        VSCODE=${VSCODE_aarch64}
        ;;
    *)
        errmsg "Invalid architecture \"$1\" supported architectures are: x86_64 amd64 aarch64 arm64"
        exit
        ;;
esac

function pause(){
    read -s -n 1 -p "Press any key to continue . . ."
    echo ""
}
echo "Enter a name for this computer:"
read CKHOST

#Get username if user is sudoing
USERNAME=$(who | awk '{print $1}')
echo "Running setup for user ${USERNAME}"
sudo nmcli general hostname ${CKHOST}

if [[ $EUID -ne 0 ]] || [ "${USERNAME}" = "root" ]; then
    echo "This script must be run with sudo from the user account you plan on using" 
    exit 1
fi

sudo apt-get update && apt-get upgrade -y && apt-get install -y docker.io wget curl gparted git git-lfs build-essential cmake

sudo usermod -aG docker $USERNAME
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
docker pull guitar24t/ck-ros:latest

#Disable password entry for sudo
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | (sudo su -c 'EDITOR="tee -a" visudo')

cd /home/${USERNAME}
curl -sLO 'https://github.com/frcteam195/dev_environment_setup/raw/main/team195.png'
mv team195.png /var/lib/AccountsService/icons/${USERNAME}
curl -L -o vscode.deb --header 'Referer: code.visualstudio.com' '${VSCODE}'
sudo dpkg --install vscode.deb
sudo apt-get install -f -y
sudo dpkg --install vscode.deb

mkdir repos
cd repos
ssh-keygen -b 2048 -t rsa -q -N ""
cat ~/.ssh/id_rsa.pub
echo "Please add this key to github named ${CKHOST} before continuing!"
pause
git clone https://github.com/frcteam195/ros_dev.git

sudo reboot