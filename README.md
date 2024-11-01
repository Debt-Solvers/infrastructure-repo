# az login --use-device-code
# Need to have Azure subscription ID when applying deployment.

# Initialization 
ssh-keygen -t rsa -f a1
terraform init
terraform apply

# connect to VM
ssh -i a1 azureuser@<public_ip_address>

# Create custom network
docker network create -d bridge --subnet 182.18.0.0/24 --gateway 182.18.0.1 new-network

# Run postgresql container with official image on custom network
sudo docker pull postgres
docker run -d \
  --name my_postgres \
  --network my_custom_bridge \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_DB=mydatabase \
  -p 5432:5432 \
  postgres

# Enter interactive mode
sudo docker exec -it my_postgres psql -U myuser -d mydatabase
or
docker exec -it my_postgres bash
psql -U myuser -d mydatabase

# Sample command
\l # Lists all databases
\dt # check tables
\q # Exit


#$env:ARM_SUBSCRIPTION_ID = "<your_subscription_id>"
#$env:ARM_CLIENT_ID = "<your_client_id>"
#$env:ARM_CLIENT_SECRET = "<your_client_secret>"
#$env:ARM_TENANT_ID = "<your_tenant_id>"