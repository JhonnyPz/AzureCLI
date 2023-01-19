#!/bin/bash
AzureCreateRG(){
    az group create \
  --name MyVMTest
}

AzureCreateVM(){
    az vm create \
  --resource-group MyVMTest \
  --name VS2022 \
  --image MicrosoftWindowsDesktop:windows-11:win11-22h2-ent:latest \
  --storage-sku StandardSSD_LRS \
  --size Standard_D4s_v3 \
  --admin-username azure \
  --admin-password Qwe123qwe123 \
  --public-ip-sku Standard \
  --custom-data /home/jhonny/workspace/github/scripts/scriptsInstallApps/visualstudio2022.ps1
}

AzureCreateRG
AzureCreateVM

az vm open-port --resource-group MyVMTest --name VS2022 --port 3389 --priority 1001 -o table

az vm list-ip-addresses --resource-group MyVMTest -o table