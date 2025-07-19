#!/bin/bash

echo "Cloning JabiBot v1.0.0 release..."
git clone --branch v1.0.0 https://github.com/connoranastasio/JabiBot.git
cd JabiBot || exit 1

echo "Creating data directory..."
mkdir -p data

echo "Copying .env file..."
cp .env.example .env

echo "Opening .env for editing..."
sleep 1
nano .env

echo "Starting Docker Compose..."
docker compose up -d

echo "JabiBot is now running."

