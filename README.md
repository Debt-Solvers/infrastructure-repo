# az login --use-device-code
# The terraform code will deploy a VM with a public IP and docker installed.
# It will also create a PostgreSQL Single Server with Azure Database
# Need to have Azure subscription ID when applying deployment.
# Remember to delete resources using terraform destroy after testing.

# Initialization 
ssh-keygen -t rsa -f a1
terraform init
terraform apply
scp -i a1 ./setup_docker_containers.sh azureuser@<public_ip_address>:/home/azureuser/

# connect to VM
ssh -i a1 azureuser@<public_ip_address>
# give script permission
chmod +x setup_docker_containers.sh
# Run script
./setup_docker_containers.sh

# Pull from github
# build image
# Create containers
docker run -d \
  --name my_postgres \
  --network my_custom_bridge \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=root \
  -e POSTGRES_DB=debt_solver \
  -p 5432:5432 \
  postgres

# Pull from dockerhub
docker pull billzhaohongwei/caa900debtsolverproject:auth-service
# create container
docker run -d \
  --name auth_container \
  --network my_custom_bridge \
  -e DB_HOST=my_postgres \
  -e DB_PORT=5432 \
  -e DB_USER=postgres \
  -e DB_PASSWORD=root \
  -e DB_NAME=debt_solver \
  -e DB_SSLMODE=disable \
  -v /home/azureuser/BE-auth-service/configs:/root/configs \
  -v /home/azureuser/BE-auth-service/db:/root/db \
  -p 8080:8080 \
  billzhaohongwei/caa900debtsolverproject:auth-service


# Enter interactive mode
sudo docker exec -it my_postgres psql -U postgres -d debt_solver
or
docker exec -it my_postgres bash
psql -U postgres -d debt_solver

# Sample command
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

# Insert data
INSERT INTO users (username, password, email) VALUES ('testuser', 'testpassword', 'testuser@example.com');

# Query
SELECT * FROM users;

\l # Lists all databases
\dt # check tables
\q # Exit

# How to push local image to dockerhub
docker login
docker tag auth-service:latest billzhaohongwei/caa900debtsolverproject:auth-service
docker push billzhaohongwei/caa900debtsolverproject:auth-service

# Pull from dockerhub
docker pull billzhaohongwei/caa900debtsolverproject:auth-service

# How to push image to ACR: replace hello-world with image name
# Step 1: Log in to Azure and to ACR from the VM
az login
az acr login --name <your_acr_name>
# Step 2: Retrieve your ACR login server name, something like youracr.azurecr.io.
az acr show --name <your_acr_name> --query loginServer --output tsv
# Step 3: Tag the Docker Image with the ACR Login Server
docker tag hello-world debtsolverdockerregistry.azurecr.io/hello-world:v1
# Step 4: Push the Docker Image to ACR
docker push debtsolverdockerregistry.azurecr.io/hello-world:v1
# Step 5: Verify the Image in ACR (Optional)
az acr repository list --name debtsolverdockerregistry --output table

# How to pull image:
# Step 1: Log in to ACR
az login
az acr login --name <your_acr_name>
# Step 2: Pull Image
docker pull debtsolverdockerregistry.azurecr.io/hello-world:v1

# How to delete image in ACR: Replace debtsolverdockerregistry and hello-world
az acr repository delete --name debtsolverdockerregistry --image hello-world:v1 --yes

#$env:ARM_SUBSCRIPTION_ID = "<your_subscription_id>"
#$env:ARM_CLIENT_ID = "<your_client_id>"
#$env:ARM_CLIENT_SECRET = "<your_client_secret>"
#$env:ARM_TENANT_ID = "<your_tenant_id>"