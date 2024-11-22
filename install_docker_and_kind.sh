#!/bin/bash

# Update the package index and install prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# Add azureuser to the docker group
sudo usermod -aG docker azureuser

# Install Kind
curl -sLo kind https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64
sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
rm -f ./kind

# Install Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f ./kubectl

# Create configuration file for Kind cluster
cat <<EOF > /home/azureuser/kind.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.19.11@sha256:07db187ae84b4b7de440a73886f008cf903fcf5764ba8106a9fd5243d6f32729
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
  - containerPort: 30001
    hostPort: 30001
EOF

sudo chown azureuser:azureuser /home/azureuser/kind.yaml
sleep 5

# Create cluster with kind.yaml
sudo -u azureuser /usr/local/bin/kind create cluster --config /home/azureuser/kind.yaml
echo "Script completed."
