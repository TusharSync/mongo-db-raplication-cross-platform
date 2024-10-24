# MongoDB Replication Management Script

This script is designed to manage MongoDB replication settings across different platforms including Ubuntu/Linux, macOS, and Windows. It allows you to enable or disable replication by modifying the MongoDB configuration file and restarting the MongoDB service as required.

## Features

- Cross-platform support: Works on Ubuntu/Linux, macOS, and Windows.
- Automatically loads predefined environment variables from a `.env` file.
- Makes a backup of the original MongoDB configuration file before making any changes.
- Restarts the MongoDB service to apply replication changes.
- Initiates the MongoDB replica set when enabling replication.

## Requirements

- **MongoDB** installed and configured on your system.
- **Git Bash** (for Windows users), **WSL**, or **Cygwin** to run the script.
- A `.env` file with the required variables.

## .env File Configuration

Create a `.env` file in the same directory as the script with the following content:

```plaintext
MONGO_DB_CONFIG_FILE_PATH="C:/path/to/your/mongod.conf"  # Windows path format example
REPL_SET_NAME="yourReplicaSetName"
```

**Note:** For Unix-based systems (Linux/macOS), provide paths in Unix format.

## Usage

### 1. Clone or download this repository.
### 2. Prepare the `.env` file with the appropriate values.
### 3. Open your preferred terminal (Git Bash for Windows, WSL, or any Unix-based terminal).
### 4. Navigate to the script's directory.

### 5. Run the script:

```bash
# For enabling replication
./mongo-replication-manager.sh enable

# For disabling replication
./mongo-replication-manager.sh disable
```

### Example (on Windows with Git Bash):

```bash
cd /c/Users/YourUsername/path/to/your/script/
./script.sh enable
```

## How It Works

1. The script loads the required environment variables (`MONGO_DB_CONFIG_FILE_PATH` and `REPL_SET_NAME`) from the `.env` file.
2. Depending on the argument passed (`enable` or `disable`), the script:
   - **Enables replication**: Adds the `replication` section to the MongoDB configuration file and sets the replica set name.
   - **Disables replication**: Removes the `replication` section from the configuration file.
3. Restart the MongoDB service to apply changes.
4. If replication is enabled, initiate the replica set using MongoDB commands.

## Cross-Platform Considerations

- The script handles file path differences between Unix-based systems and Windows.
- Commands for restarting MongoDB services and managing file backups are designed to work on Linux, macOS, and Windows (using Git Bash, WSL, or Cygwin).

## Prerequisites

- Ensure that **MongoDB** is installed and accessible on your machine.
- Ensure that you have a Unix-like terminal environment set up if running on Windows (such as Git Bash, WSL, or Cygwin).
- **Administrator Privileges** are required to modify system-level services (like MongoDB) and configuration files.

## Troubleshooting

- **Permission Denied**: Make sure you are running the script with administrative privileges.
- **File Path Issues**: Ensure paths in the `.env` file are in the correct format for your environment (Unix vs. Windows paths).
- **MongoDB Service Not Restarting**: Check that your MongoDB service is named `mongod` and is configured correctly in your OS’s service manager.

## License

This script is distributed under the MIT License. See `LICENSE` for more information.

## Author

Developed by [Tushar]
```
