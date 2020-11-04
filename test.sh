# echo 'wsl.exe -d $WSL_DISTRO_NAME -u root ip addr add 192.168.50.16/24 broadcast 192.168.50.255 dev eth0 label eth0:1' >> .profiles
# hostname -I | awk '{print $2}'
# ip a s| grep eth0:1| awk '{print $2}' | cut -d/ -f1

#!/bin/bash

# ip="$(ip a s| grep eth0:1| awk '{print $2}' | cut -d/ -f1)"
# if [[ $ip = "192.168.50.16" ]]
# then
# echo "static ip $ip present"
# else
# echo 'wsl.exe -d $WSL_DISTRO_NAME -u root ip addr add 192.168.50.16/24 broadcast 192.168.50.255 dev eth0 label eth0:1' >> ~/.profile
# source ~/.profile
# echo "static ip $ip has been added"
# fi
# #Restart


# echo "mirrors:
#   "registry.localhost:5000":
#     endpoint:
#       - http://registry.localhost:5000" | tee registries.yaml > /dev/null

echo '{
    "insecure-registries" : [ "nexus.lstelcom.ads:18888" ]
}' | sudo tee /etc/docker/daemon.json > /dev/null

docker login -u docker -p docker123 nexus.lstelcom.ads:18888
sudo service docker restart

docker ps | awk '{print $NF}' | grep registry.localhost > /dev/null
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