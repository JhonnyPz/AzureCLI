#!/bin/bash
grname="MyVMTest"
vmname="VS2022"

AzureCreateRG(){
    az group create \
  --name $grname
}

AzureCreateVM(){
    az vm create \
  --resource-group $grname \
  --name $vmname \
  --image MicrosoftWindowsDesktop:windows-11:win11-22h2-ent:latest \
  --storage-sku StandardSSD_LRS \
  --size Standard_D4s_v3 \
  --admin-username azure \
  --admin-password Qwe123qwe123 \
  --public-ip-sku Standard
}

AzureConfigVM(){
  az vm open-port -g $grname --name $vmname --port 3389 --priority 1001 --output table

  az vm run-command invoke -g $grname -n $vmname --command-id RunPowerShellScript --scripts @/home/jhonny/workspace/github/scripts/scriptsInstallApps/visualstudio2022.ps1
}

AzureCreateRG
AzureCreateVM
AzureConfigVM

az vm list-ip-addresses -g $grname -o table