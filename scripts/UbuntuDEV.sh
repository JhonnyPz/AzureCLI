#!/bin/bash
grname="GRTest"
vmname="UbuntuDock"

AzureCreateRG(){
    az group create \
  --name $grname
}

AzureCreateVM(){
    az vm create \
  --resource-group $grname \
  --name $vmname \
  --image canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest \
  --storage-sku StandardSSD_LRS \
  --public-ip-sku Standard \
  --generate-ssh-keys \
  --custom-data /home/jhonny/workspace/github/scripts/scriptsInstallApps/Ubuntu_DockerWebGithub.sh
}

AzureConfigVM(){
  az vm open-port -g $grname --name $vmname --port 80 --priority 1001 -o table
}

AzureCreateRG
AzureCreateVM
AzureConfigVM

az vm list-ip-addresses -g $grname -o table