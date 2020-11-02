# # #!/bin/bash
# # # Installion of local k8s environment

# # # echo "Install local Kubernetes (k3d) cluster on wsl2"

# # # Add static ip to wsl distro
# # ip="$(ip a s | grep eth0:1 | awk '{print $2}' | cut -d/ -f1)"
# # if [[ $ip = "192.168.50.16" ]]
# # then
# # echo "static ip $ip present"
# # else
# # echo 'wsl.exe -d $WSL_DISTRO_NAME -u root ip addr add 192.168.50.16/24 broadcast 192.168.50.255 dev eth0 label eth0:1' >> ~/.profile
# # source ~/.profile
# # echo "static ip $ip has been added"
# # fi

# # # sudo apt-get -y update && sudo apt-get -y upgrade
# if else


# #Install Docker for Ubuntu
# if [ $(command -v docker) ]
# then
#     echo "docker found. proceed...................................................................."
# else
#     echo "installing docker"
#     sudo curl -fsSL https://get.docker.com -o get-docker.sh
#     sudo sh get-docker.sh
#     # Press enter for the shutdown and restart ubuntu
#     sudo usermod -aG docker $USER
#     wsl.exe shutdown
# fi

# #Going to shutdown 

# sudo service docker start

# # # Install kubectl if it does not exist
# if [ $(command -v kubectl) ]
# then
#   echo "kubectl exits. Proceed......................................................................."
# else
#   echo "kubectl not installed.  Installing"
#   curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
#   chmod +x ./kubectl
#   sudo mv ./kubectl /usr/local/bin/
# fi

# # # Install k3d 
# if [ $(command -v k3d) ]
# then
#   echo "k3d exists. Proceed........................................................................."
# else
#   echo "K3d not installed. Installing"
#   curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
# fi

# Make a local registry 

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

# # Deploy the cluster 
# echo "Enter the cluster name";
# read clusterName;
# echo "specify the number of agents";
# read agentNumber;

# # Make a cluster 

# k3d cluster create $clusterName --agents=$agentNumber --api-port=6551 --port=8081:80@loadbalancer --port=8082:443@loadbalancer --update-default-kubeconfig --switch-context --k3s-server-arg '--no-deploy=traefik' --volume "$HOME/registries.yaml:/etc/rancher/k3s/registries.yaml"
# if [ $? -eq 0 ]
# then
#   echo "$cluster_name cluster created................................................................"
#   k3d cluster list
#   docker network connect k3d-k3s-default registry.localhost
#   sleep 5
# else
#   echo "The cluster with the same name exists"
# fi
# fi

# # Deploy Ingress
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.35.0/deploy/static/provider/cloud/deploy.yaml
# sleep 12
# kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=10s

# Deploy devspace
# curl -s -L "https://github.com/devspace-cloud/devspace/releases/latest" | sed -nE 's!.*"([^"]*devspace-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o devspace  
# chmod +x devspace;
# sudo mv devspace /usr/local/bin;

# echo "cluster deployment sucessfull"
