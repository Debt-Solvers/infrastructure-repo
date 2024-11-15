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

# Install PostgreSQL client
#sudo apt-get install -y postgresql-client

sleep 5

# Step 1: Create Docker network
docker network create --driver bridge my_custom_bridge
sleep 2  # Brief delay to ensure network is ready

# Step 2: Pull the Postgres image from Docker Hub
docker pull postgres

# Step 3: Create the Postgres container
docker run -d \
  --name my_postgres \
  --network my_custom_bridge \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=root \
  -e POSTGRES_DB=debt_solver \
  -e POSTGRES_HOST=localhost \
  -e DB_PORT=5432 \
  -e DB_SSLMODE=disable \
  -v pgdata:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres

# Wait for PostgreSQL to initialize
echo "Waiting for PostgreSQL to start..."
for i in {1..10}; do
  if docker exec my_postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "PostgreSQL is ready!"
    break
  fi
  echo "PostgreSQL not ready yet. Retrying in 2 seconds..."
  sleep 2
done

# Optional: Wait for Postgres container to initialize
# sleep 10

# Step 4: Pull the auth-service and expense-mgmt images from Docker Hub
docker pull billzhaohongwei/caa900debtsolverproject-auth-service:latest
docker pull billzhaohongwei/caa900debtsolverproject-expense-mgmt:latest

# Step 5: Create the auth-service container
docker run -d \
  --name auth_container \
  --network my_custom_bridge \
  -e DB_HOST=my_postgres \
  -e DB_PORT=5432 \
  -e DB_USER=postgres \
  -e DB_PASSWORD=root \
  -e DB_NAME=debt_solver \
  -e DB_SSLMODE=disable \
  -p 8080:8080 \
  billzhaohongwei/caa900debtsolverproject-auth-service:latest

# Step 5: Create the expense-service container
docker run -d \
  --name expense_container \
  --network my_custom_bridge \
  -e DB_HOST=my_postgres \
  -e DB_PORT=5432 \
  -e DB_USER=postgres \
  -e DB_PASSWORD=root \
  -e DB_NAME=debt_solver \
  -e DB_SSLMODE=disable \
  -p 8081:8081 \
  billzhaohongwei/caa900debtsolverproject-expense-mgmt:latest

# Step 6: Confirm that the containers are running
docker ps