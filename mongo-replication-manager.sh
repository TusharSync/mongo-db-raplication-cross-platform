#!/bin/bash
# Universal script to manage MongoDB replication based on the argument passed

# Function to load predefined variables from .env file
load_env_vars() {
  # Define the list of allowed variables to load
  local ALLOWED_VARS_FROM_ENV=("MONGO_DB_CONFIG_FILE_PATH" "REPL_SET_NAME")

  # Check if .env file exists
  if [ -f .env ]; then
    # Loop through the allowed variables
    for var in "${ALLOWED_VARS_FROM_ENV[@]}"; do
      # Extract the value of each allowed variable from .env
      value=$(grep -w "^$var" .env | cut -d '=' -f2- | xargs) # Use xargs to trim any spaces
      if [ -n "$value" ]; then
        export "$var=$value"
      else
        echo "Warning: Variable '$var' not found or empty in .env file"
      fi
    done
  else
    echo "Error: .env file not found"
    exit 1
  fi
}

# Call the function to load the environment variables
load_env_vars

CONFIG_FILE=${MONGO_DB_CONFIG_FILE_PATH}
REPL_SET_NAME=${REPL_SET_NAME}
# Just for demonstration, let's print the loaded variables
echo "Loaded variables:"
echo "REPL_SET_NAME = $REPL_SET_NAME"
echo "MONGO_CONFIG_FILE = $CONFIG_FILE"

# Function to handle backups in a cross-platform way
backup_file() {
  local file="$1"
  case "$(uname -s)" in
  Linux | Darwin)
    sudo cp "$file" "${file}.backup"
    ;;
  CYGWIN* | MINGW* | MSYS*)
    copy "$file" "${file}.backup"
    ;;
  *)
    echo "Unsupported operating system for file backup."
    exit 1
    ;;
  esac
}

# Function to restart MongoDB service based on OS
restart_mongo_service() {
  case "$(uname -s)" in
  Linux | Darwin)
    sudo systemctl restart mongod
    ;;
  CYGWIN* | MINGW* | MSYS*)
    net stop MongoDB && net start MongoDB
    ;;
  *)
    echo "Unsupported operating system for MongoDB service restart."
    exit 1
    ;;
  esac
}

# Function to enable replication
enable_replication() {
  # Backup the original configuration file
  backup_file "$CONFIG_FILE"

  # Check if replication is already enabled
  grep -q "replSetName" "$CONFIG_FILE"
  if [ $? -eq 0 ]; then
    echo "Replication is already enabled."
    exit 0
  fi

  # Enable replication in the configuration file
  echo "Enabling replication..."
  sudo sed -i "/#replication:/d" "$CONFIG_FILE"
  sudo sed -i "/replication:/d" "$CONFIG_FILE"
  echo -e "\nreplication:\n  replSetName: \"$REPL_SET_NAME\"" | sudo tee -a "$CONFIG_FILE" >/dev/null

  # Restart the MongoDB service
  echo "Restarting MongoDB service..."
  restart_mongo_service

  # Wait for MongoDB to restart
  sleep 5

  # Initiate the replica set
  echo "Initiating replica set..."
  mongosh --port 27017 --eval "rs.initiate()"

  # Check the replica set status
  mongosh --port 27017 --eval "rs.status()"

  echo "Replication enabled successfully."
}

# Function to disable replication
disable_replication() {
  # Backup the original configuration file
  backup_file "$CONFIG_FILE"

  # Check if replication is already disabled
  grep -q "replSetName" "$CONFIG_FILE"
  if [ $? -ne 0 ]; then
    echo "Replication is already disabled."
    exit 0
  fi

  # Disable replication in the configuration file
  echo "Disabling replication..."
  sudo sed -i '/^replication:/,/^[^ ]/d' "$CONFIG_FILE"

  # Restart the MongoDB service
  echo "Restarting MongoDB service..."
  restart_mongo_service

  # Wait for MongoDB to restart
  sleep 5

  echo "Replication disabled successfully."
}

# Main script logic
if [ $# -eq 0 ]; then
  echo "Usage: $0 <enable|disable>"
  exit 1
fi

case $1 in
enable)
  enable_replication
  ;;
disable)
  disable_replication
  ;;
*)
  echo "Invalid argument. Use 'enable' or 'disable'."
  exit 1
  ;;
esac
