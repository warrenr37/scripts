#!/bin/bash
echo "Please use ROOT for this script and ONLY for initial setup"

if [ $(whoami) = 'root' ]; then
    echo "[OK]"
else
    echo "INCORRECT PERMISSIONS"
    echo "You are not root"
    exit
fi

read -p "Are ready to Install? [Y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo
EDITOR=nano && echo "EDITOR=$EDITOR"
sleep 2

apt update && apt upgrade -y
apt install git

read -p "Install Ansible? [Y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    ansible=0
else
    ansible=1
fi
echo

read -p "Install Docker? [Y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    docker=0
else
    docker=1
fi
echo

read -p "Install NMAP? [Y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    nmap=0
else
    nmap=1
fi
echo

if [ $ansible == 1 ]; then
    apt install ansible -y
fi

if [ $docker == 1 ]; then
    apt install docker -y
    usermod -aG docker $USER
fi

if [ $nmap == 1 ]; then
    apt install nmap -y
fi