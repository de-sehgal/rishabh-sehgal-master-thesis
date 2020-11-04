Set-ExecutionPolicy Bypass
netsh interface ip add address "vEthernet (WSL)" 192.168.50.88 255.255.255.0
bash docker_install.sh
bash k8s_tools_install.sh