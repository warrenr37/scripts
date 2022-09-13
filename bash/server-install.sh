#!/bin/bash
echo "Please use ROOT for this script and ONLY for initial setup"

if [ $(whoami) = 'root' ]; then
    echo "[OK]"
else
    echo "INCORRECT PERMISSIONS"
    echo "You are not root"
    exit
fi

read -p "Ready to Install? [Y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo
EDITOR=nano && echo "EDITOR=" $EDITOR
sleep 3

sudo apt update && sudo apt upgrade -y

read -p "Install Ansible? [Y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    ansible=0
else
    ansible=1
fi

read -p "Install Docker? [Y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    docker=0
else
    docker=1
fi

if [[ $ansible == [1] ]]
then
    apt install ansible -Y
fi

if [[ $docker == [1] ]]
then
    apt install docker docker-compose docker.io -Y
    usermod -aG docker $USER
fi

sleep 3

read -p "REBOOT? [Y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
    reboot
fi