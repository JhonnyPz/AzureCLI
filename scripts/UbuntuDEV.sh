#!/bin/bash
AzureCreateRG(){
    az group create \
  --name MyVMTest
}

AzureCreateVM(){
    az vm create \
  --resource-group MyVMTest \
  --name UbuntuJP \
  --image canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest \
  --storage-sku StandardSSD_LRS \
  --public-ip-sku Standard \
  --generate-ssh-keys \
  --custom-data /home/jhonny/workspace/github/scripts/Ubuntu_DockerWebGithub.sh
}

AzureCreateRG
AzureCreateVM

az vm open-port --resource-group MyVMTest --name UbuntuJP --port 80 --priority 1001

az vm list-ip-addresses --resource-group MyVMTest -o table