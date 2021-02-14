#!/bin/bash
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

sudo service docker start

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

cat << EOF >$HOME/registries.yaml
"mirrors:
  'registry.localhost:5000' :
    endpoint:
      - http://registry.localhost:5000"
EOF
echo '{
    "insecure-registries" : [ "registry.localhost:5000" ]
}' | sudo tee /etc/docker/daemon.json > /dev/null

sudo service docker restart

echo "Would you like to install Devspace(d) or Skaffold(s)";
read -p  "Enter your choice " ans;

case $ans in
    s|S)
       if [ -x "$(command -v skaffold)" ]
       then 
       echo "Skaffold already installed"
       else
       echo "Installing skaffold" 
       curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
       sudo install skaffold /usr/local/bin/
       fi; ;;
    d|D)
       if [ -x "$(command -v devspace)" ];  then
       echo "devspace already installed"; else
       echo "Installing devspace"
       curl -s -L "https://github.com/devspace-cloud/devspace/releases/latest" | sed -nE 's!.*"([^"]*devspace-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o devspace  
       chmod +x devspace;
       sudo mv devspace /usr/local/bin; 
       fi; ;;
    *)
        exit;;
esac
echo  -e "\033[33;5mCluster deployment success\033[0m"
