# echo 'wsl.exe -d $WSL_DISTRO_NAME -u root ip addr add 192.168.50.16/24 broadcast 192.168.50.255 dev eth0 label eth0:1' >> .profiles
# hostname -I | awk '{print $2}'
# ip a s| grep eth0:1| awk '{print $2}' | cut -d/ -f1

#!/bin/bash

ip="$(ip a s| grep eth0:1| awk '{print $2}' | cut -d/ -f1)"
if [[ $ip = "192.168.50.16" ]]
then
echo "static ip $ip present"
else
echo 'wsl.exe -d $WSL_DISTRO_NAME -u root ip addr add 192.168.50.16/24 broadcast 192.168.50.255 dev eth0 label eth0:1' >> ~/.profile
source ~/.profile
echo "static ip $ip has been added to .profile"
fi
#Restart