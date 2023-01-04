#!/bin/bash
sudo apt update

InstallDocker(){
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce

    sudo usermod -aG docker ${USER}
}

DockerInstallNginx(){
    sudo docker run --name Nginx-JP -v /web/html:/usr/share/nginx/html:ro -p 80:80 -d nginx
    sudo chmod 777 /web/html
    sudo echo "<h1>Welcome Art</h1>" > /web/html/index.html
}

InstallDocker
DockerInstallNginx