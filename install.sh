#!/bin/bash

ENV_PATH=".env"
INSTALLER_DIR="./web-installer"
INSTALLER_PORT=3000
TOKENS=("DISCORD_TOKEN" "YOUTUBE_API_KEY" "SPOTIFY_CLIENT_ID" "SPOTIFY_CLIENT_SECRET")

# Helper to check and install a package
check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo "Installing $1..."
    sudo apt-get update && sudo apt-get install -y "$1"
  fi
}

# Install dependencies
install_dependencies() {
  echo "Checking required dependencies..."
  check_command node
  check_command npm
  check_command docker
  check_command docker-compose
  check_command lsof
  check_command curl

  echo "Installing Node packages for web installer..."
  cd "$INSTALLER_DIR"
  npm install
  cd ..
}

# Validate .env file
validate_env_file() {
  echo "Validating .env file..."

  if [ ! -f "$ENV_PATH" ]; then
    echo ".env file not found."
    return 1
  fi

  malformed=0
  while IFS= read -r line; do
    key=$(echo "$line" | cut -d '=' -f1)
    val=$(echo "$line" | cut -d '=' -f2- | tr -d '"')

    case "$key" in
      DISCORD_TOKEN)
        [[ "$val" =~ ^[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+$ ]] || malformed=$((malformed+1))
        ;;
      YOUTUBE_API_KEY)
        [[ "$val" =~ ^[A-Za-z0-9_-]{35,}$ ]] || malformed=$((malformed+1))
        ;;
      SPOTIFY_CLIENT_ID|SPOTIFY_CLIENT_SECRET)
        [[ "$val" =~ ^[A-Za-z0-9]{32,}$ ]] || malformed=$((malformed+1))
        ;;
    esac
  done < "$ENV_PATH"

  if [[ $malformed -gt 0 ]]; then
    echo "One or more tokens appear malformed."
    return 1
  fi

  echo ".env file is valid."
  return 0
}

# Open port 3000 in firewall
configure_firewall() {
  echo "Configuring firewall to allow web installer..."

  check_command ufw

  sudo ufw allow "$INSTALLER_PORT"/tcp
  if ! sudo ufw status | grep -q "Status: active"; then
    echo "Enabling ufw..."
    sudo ufw enable
  fi

  echo "Port $INSTALLER_PORT allowed through firewall."
}

# Check and free port 3000
check_and_free_port() {
  if lsof -i tcp:"$INSTALLER_PORT" > /dev/null; then
    echo "Port $INSTALLER_PORT is already in use."
    read -p "Do you want to free it for the installer? (y/n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      pid=$(lsof -ti tcp:"$INSTALLER_PORT")
      sudo kill -9 "$pid"
      echo "Port $INSTALLER_PORT has been freed."
    else
      echo "Installer cannot continue while port $INSTALLER_PORT is in use. Exiting."
      exit 1
    fi
  fi
}

# Launch web installer
launch_web_installer() {
  echo "Starting web installer on port $INSTALLER_PORT..."
  check_and_free_port
  configure_firewall
  node "$INSTALLER_DIR/server.js" &

  sleep 2
  if curl -s "http://localhost:$INSTALLER_PORT/get-ip" | grep -q 'ip'; then
    echo "Web installer is running. Open it in your browser."
  else
    echo "Installer failed to start or is unreachable. Check firewall or config."
    exit 1
  fi
}

# Start JabiBot with Docker
start_docker_bot() {
  echo "Starting JabiBot using Docker..."
  docker-compose up -d

  if [ $? -eq 0 ]; then
    echo "JabiBot is now running."
  else
    echo "Docker failed to launch JabiBot. Check docker-compose and logs."
    exit 1
  fi
}

# ------------------------
# Begin Installer Flow
# ------------------------

echo "JabiBot v1.1.1 Installer Starting..."

install_dependencies

if ! validate_env_file; then
  echo ""
  echo "API tokens are missing or invalid."
  read -p "Do you want to launch the web installer to fix this? (y/n): " choice
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    launch_web_installer
    exit 0
  else
    echo "Installation aborted by user."
    exit 1
  fi
else
  echo "API tokens appear valid."
  read -p "Do you want to re-run the web installer anyway? (y/n): " choice
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    launch_web_installer
    exit 0
  fi
fi

start_docker_bot
echo ""
echo "JabiBot setup complete."
