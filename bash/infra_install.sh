#!/bin/bash

#Pi Infrastructure install

#Colors set
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

# Folder check
#####
echo -e "Checking for tmp folder"
if [[ -d ~/tmp ]]
then
	echo -e "${RED}tmp folder exists deleting...${NOCOLOR}"
	rm -R ~/tmp
	mkdir ~/tmp
else
	mkdir ~/tmp
fi

echo -e "Checking for docker folder"

if [[ -d ~/docker ]]
then
	echo -e "${YELLOW}Docker folder exists skipping...${NOCOLOR}"
else
	mkdir ~/docker
	mkdir ~/docker/pihole
	mkdir ~/docker/duplicati
fi

if [[ -d ~/backups ]]
then
        echo -e "${YELLOW}Backups folder exists skipping...${NOCOLOR}"
else
	mkdir ~/backups
fi

echo -e "${GREEN}Folder creation complete${NOCOLOR}"
#####


#Downloads compose files into tmp folder
#####
cd ~/tmp
echo "Downloading pihole..."
mkdir ~/tmp/pihole
cd ~/tmp/pihole
wget -nv  https://raw.githubusercontent.com/warrenr37/homelab/main/Docker/docker-compose/pihole/docker-compose.yml
cd ~/

echo "Downloading speedtest..."
mkdir ~/tmp/speedtest
cd ~/tmp/speedtest

echo "Downloading UptimeKuma..."
mkdir ~/tmp/uptime
cd ~/tmp/uptime
wget -nv https://raw.githubusercontent.com/warrenr37/homelab/main/Docker/docker-compose/uptime-kuma/docker-compose.yml
cd ~/

echo "Downloading Duplicati ..."
mkdir ~/tmp/duplicati
cd ~/tmp/duplicati
wget -nv https://raw.githubusercontent.com/warrenr37/homelab/main/Docker/docker-compose/duplicati/docker-compose.yml
cd ~/
#####


#Check for then create Docker Volumes
#####
docker volume inspect portainer_data >&-
if [[ $? -eq 0 ]]
then

	vc=0

else

	vc=1
	docker volume create portainer_data

fi

docker volume inspect uptime-kuma >&-
if [[ $? -eq 0 ]]
then

	vc=0

else

	vc=1
	docker volume create uptime-kuma

fi

if [[ $vc -eq 1 ]]
then

	echo -e "${GREEN}Volume creation complete.${NOCOLOR}"

else

	echo -e "${GREEN}Volume(s) already exists. skipping...${NOCOLOR}"

fi
#####


#Downloads Misc. persistent config files
#####
echo -e "${GREEN}Config Creation Complete.${NOCOLOR}"
#####


#Pull docker images
#####
docker pull portainer/portainer-ce:latest
docker pull pihole/pihole:latest
docker pull louislam/uptime-kuma
docker pull linuxserver/duplicati:latest
echo -e "${GREEN}Image Pull Complete.${NOCOLOR}"
#####


#Bring up docker containers
#####
#portainer
PORTAINER=$(docker ps --format '{{.Names}}' --filter name=portainer)
if [[ $PORTAINER == portainer ]]
then

	echo -e "${GREEN}portainer already up. skipping...${NOCOLOR}"

else

	docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

fi
#pihole
cd ~/tmp/pihole
docker-compose up -d
cd ~/

#uptime kuma
UPTIMEKUMA=$(docker ps --format '{{.Names}}' --filter name=uptime-kuma)
if [[ $UPTIMEKUMA == uptime-kuma ]]
then

	echo -e "${GREEN}uptime-kuma already up. skipping...${NOCOLOR}"

else

	docker run -d --restart=always -p 3001:3001 -v uptime-kuma:/app/data --name uptime-kuma louislam/uptime-kuma

fi

#duplicati
cd ~/tmp/duplicati
docker-compose up -d
cd ~/

echo -e "${GREEN}Docker container Creation Complete.${NOCOLOR}"
#####

#Set Pihole Password
#####
echo "Please enter pihole password"
docker exec -it pihole pihole -a -p
#####

#Clean up
#####
echo "Cleaning up..."
cd ~/
rm -R ~/tmp
#####
