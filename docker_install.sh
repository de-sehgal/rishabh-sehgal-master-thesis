#!/bin/bash
echo "$(tput setaf 2)Installion of local k8s environment$(tput sgr 0)"
echo "$(tput setaf 2)Installing newest version of git$(tput sgr 0)"
sudo add-apt-repository --yes ppa:git-core/ppa
sudo apt install -y git
git version

echo "Install local Kubernetes (k3d) cluster on wsl2"

# Add static ip to wsl distro
ip="$(ip a s | grep eth0:1 | awk '{print $2}' | cut -d/ -f1)"
if [[ $ip = "192.168.50.16" ]]
then
echo "$(tput setaf 2)static ip $ip present$(tput sgr 0)"
else
echo 'wsl.exe -d $WSL_DISTRO_NAME -u root ip addr add 192.168.50.16/24 broadcast 192.168.50.255 dev eth0 label eth0:1' >> ~/.profile
echo "$(tput setaf 2)static ip $ip has been added$(tput sgr 0)"
fi

#Install Docker for Ubuntu
if [ -x "$(command -v docker)" ]
then
    echo "$(tput setaf 2)docker found.proceed$(tput sgr 0)"
else
    echo "$(tput setaf 2)installing docker$(tput sgr 0)"
    sudo curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
	wsl.exe --shutdown
fi
