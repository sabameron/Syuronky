#!/bin/bash

# Clone the WireHole repository from GitHub
git clone https://github.com/IAmStoxe/wirehole.git

# Update the .env file with your configuration
cp .env wirehole/.env
cp docker-compose.yml wirehole/docker-compose.yml

# Change directory to the cloned repository
cd wirehole

# Replace the public IP placeholder in the docker-compose.yml
sed -i "s/REPLACE_ME_WITH_YOUR_PUBLIC_IP/$(curl -s ifconfig.me)/g" docker-compose.yml

# Start the Docker containers
# docker compose up -d
