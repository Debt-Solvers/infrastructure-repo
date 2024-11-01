#!/bin/bash

# Update the package index
sudo apt-get update

# Install prerequisites for adding repositories securely
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key and repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package index again to include Docker’s repository and install Docker
sudo apt-get update
sudo apt-get install -y docker-ce

# Add your user to the Docker group to allow running Docker without sudo
sudo usermod -aG docker azureuser

# Install prerequisites for the Azure CLI
sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg

# Add Microsoft’s GPG key and Azure CLI repository
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list

# Update the package index again to include the Azure CLI repository and install Azure CLI
sudo apt-get update
sudo apt-get install -y azure-cli