# az login --use-device-code
# The code will deploy a VM with public IP and docker 
# Need to have Azure subscription ID when applying deployment.

# Initialization 
ssh-keygen -t rsa -f a1
terraform init
terraform apply

# connect to VM
ssh -i a1 azureuser@<public_ip_address>

# Create custom network
docker network create --driver bridge my_custom_bridge

# Run postgresql container with official image on custom network and volume mount
# If container is removed, data can be restored by running cmd again(volume attached).
sudo docker pull postgres
docker run -d \
  --name my_postgres \
  --network my_custom_bridge \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_DB=mydatabase \
  -v pgdata:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres

# Enter interactive mode
sudo docker exec -it my_postgres psql -U myuser -d mydatabase
or
docker exec -it my_postgres bash
psql -U myuser -d mydatabase

# Sample command
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO users (username, password, email) VALUES ('testuser', 'testpassword', 'testuser@example.com');
SELECT * FROM users;

\l # Lists all databases
\dt # check tables
\q # Exit

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