#!/bin/bash

# Step 1: Create Docker network
docker network create --driver bridge my_custom_bridge

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

# Step 4: Pull the auth-service image from Docker Hub
docker pull billzhaohongwei/caa900debtsolverproject:auth-service

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
  billzhaohongwei/caa900debtsolverproject:auth-service

# Step 6: Confirm that the containers are running
docker ps
