# az login --use-device-code
# The terraform code will deploy a VM with a public IP and docker installed.
# Hold BE containers and DB container
# BE container in dockerhub repo:
# billzhaohongwei/caa900debtsolverproject-auth-service
# billzhaohongwei/caa900debtsolverproject-expense-mgmt
# Need to have Azure subscription ID when applying deployment.
# Remember to delete resources using terraform destroy after testing.

# Update 11/29/2024
# 1. use az powershell to create storage for tf state files first with setup-tfstorage.ps1
# 2. Run github action of k8s_deploy.yml
# 3. To destroy, run github action of terraform destroy.yml

# If start from terraform
# Initialization
ssh-keygen -t rsa -f a1
terraform init
terraform apply -auto-approve
# The auth-service container will be listening on public IP or FQDN port 30000.

# The expense-mgmt container will be listening on public IP or FQDN port 30001.

# The receipts-mgmt container will be listening on public IP or FQDN port 30002.

# copy script to VM
scp -i a1 ./application.yaml azureuser@caa900debtsolverappbe.eastus.cloudapp.azure.com:/home/azureuser/
# ssh into vm
ssh -i a1 azureuser@caa900debtsolverappbe.eastus.cloudapp.azure.com
# apply application deployment
kubectl apply -f application.yaml

# Troubleshoot
ssh -i a1 azureuser@caa900debtsolverapp.eastus.cloudapp.azure.com
ssh -i a1 azureuser@caa900debtsolverappbe.eastus.cloudapp.azure.com

# Destroy resources
terraform destroy -auto-approve 
# Or with Powershell cmd
Remove-AzResourceGroup -Name "debtSolverRG" -Force -Confirm:$false

# Configure Azure credentials for Github actions
To fetch the credentials required to authenticate with Azure, run the following command:

az ad sp create-for-rbac --name "myApp" --role contributor \
                            --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} \
                            --sdk-auth

  # Replace {subscription-id}, {resource-group} with the subscription, resource group details

  # The command should output a JSON object similar to the example below

  {
    "clientId": "<GUID>",
    "clientSecret": "<GUID>",
    "subscriptionId": "<GUID>",
    "tenantId": "<GUID>",
    (...)
  }
# Add the JSON output as secrets TF_VAR_agent_client_id, TF_VAR_agent_client_secret, TF_VAR_subscription_id, TF_VAR_tenant_id in the GitHub repository. 

# --------------------------------------------------------------
# Draft
# copy script to VM
scp -i a1 ./setup_docker_containers.sh azureuser@<public IP>:/home/azureuser/
# give script permission
chmod +x setup_docker_containers.sh
# Run script
./setup_docker_containers.sh

# Enter interactive mode
# K8s
kubectl exec -it postgres-statefulset-0 -- psql -U postgres -d debt_solver
# Docker
sudo docker exec -it my_postgres psql -U postgres -d debt_solver

# View DB info in structured view
\x
\pset border 2
SELECT * FROM USERS;

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


# How to delete image in ACR: Replace debtsolverdockerregistry and hello-world
az acr repository delete --name debtsolverdockerregistry --image hello-world:v1 --yes

#$env:ARM_SUBSCRIPTION_ID = "<your_subscription_id>"
#$env:ARM_CLIENT_ID = "<your_client_id>"
#$env:ARM_CLIENT_SECRET = "<your_client_secret>"
#$env:ARM_TENANT_ID = "<your_tenant_id>"
