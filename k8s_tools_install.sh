#!/bin/bash

sudo service docker start

# # Install kubectl if it does not exist
if [ $(command -v kubectl) ]
then
  echo "$(tput setaf 2)kubectl exits. Proceed.$(tput sgr 0)"
else
  echo "$(tput setaf 2)Installing kubectl$(tput sgr 0)"
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/
fi

# # Install k3d 
if [ $(command -v k3d) ]
then
  echo "$(tput setaf 2)k3d exists$(tput sgr 0)"
else
  echo "$(tput setaf 2)K3d not installed. Installing$(tput sgr 0)"
  curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
fi

#Make a local registry 
docker ps | awk '{print $NF}' | grep registry.localhost
if [ $? -eq 0 ]
then
echo "$(tput setaf 2)registry exists$(tput sgr 0)"
else
ipaddr=$(hostname -i)
registry_name="registry.localhost"
docker volume create local_registry
docker container run -d --name $registry_name -v local_registry:/var/lib/registry --restart always -p 5000:5000 registry:2
echo "$ipaddr     $registry_name"   | sudo tee -a /etc/hosts > /dev/null
fi

echo "mirrors:
  "registry.localhost:5000":
    endpoint:
      - http://registry.localhost:5000" | tee $HOME/registries.yaml > /dev/null
	  
echo '{
    "insecure-registries" : [ "nexus.lstelcom.ads:18888" ]
}' | sudo tee /etc/docker/daemon.json > /dev/null

docker login -u docker -p docker123 nexus.lstelcom.ads:18888
sudo service docker restart

#Deploy devspace
if [ -x "$(command -v devspace)" ]
then
echo "$(tput setaf 2)Devspace exists$. Proceed.$(tput sgr 0)"
else
echo "$(tput setaf 2)Installing devspace$(tput sgr 0)"
#wget https://github.com/devspace-cloud/devspace/releases/download/v5.2.0/devspace-linux-amd64
curl -s -L "https://github.com/devspace-cloud/devspace/releases/latest" | sed -nE 's!.*"([^"]*devspace-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o devspace  
chmod +x devspace;
sudo mv devspace /usr/local/bin;
fi

echo  -e "\033[33;5mCluster deployment success\033[0m"
