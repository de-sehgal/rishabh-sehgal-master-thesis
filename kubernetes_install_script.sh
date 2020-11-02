#!/bin/bash
# Installion of local k8s environment

echo "Install local Kubernetes (k3d) cluster on wsl2"

# Add static ip to wsl distro
ip="$(ip a s | grep eth0:1 | awk '{print $2}' | cut -d/ -f1)"
if [[ $ip = "192.168.50.16" ]]
then
echo "static ip $ip present"
else
echo 'wsl.exe -d $WSL_DISTRO_NAME -u root ip addr add 192.168.50.16/24 broadcast 192.168.50.255 dev eth0 label eth0:1' >> ~/.profile
source ~/.profile
echo "static ip $ip has been added"
fi

Install Docker for Ubuntu
if [ -x "$(command -v docker)" ]
then
    echo "docker found. proceed...................................................................."
else
    echo "installing docker"
    sudo curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    newgrp docker
fi

sudo service docker start

# # Install kubectl if it does not exist
if [ $(command -v kubectl) ]
then
  echo "kubectl exits. Proceed......................................................................."
else
  echo "kubectl not installed.  Installing"
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/
fi

# # Install k3d 
if [ $(command -v k3d) ]
then
  echo "k3d exists. Proceed........................................................................."
else
  echo "K3d not installed. Installing"
  curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
fi

#Make a local registry 
docker ps | awk '{print $NF}' | grep registry.localhost
if [ $? -eq 0 ]
then
echo "registry exists"
else
ipaddr=$(hostname -i)
registry_name="registry.localhost"
docker volume create local_registry
docker container run -d --name $registry_name -v local_registry:/var/lib/registry --restart always -p 5000:5000 registry:2
echo " $ipaddr     $registry_name"   | sudo tee -a /etc/hosts > /dev/null
fi

#Deploy devspace
curl -s -L "https://github.com/devspace-cloud/devspace/releases/latest" | sed -nE 's!.*"([^"]*devspace-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o devspace  
chmod +x devspace;
sudo mv devspace /usr/local/bin;

echo "cluster deployment sucessfull"
