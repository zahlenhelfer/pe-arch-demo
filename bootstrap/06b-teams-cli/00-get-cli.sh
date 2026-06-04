#!/bin/bash
echo "Downloading the teams-cli binary for macOS ARM64"
curl -L https://github.com/zahlenhelfer/teams-cli/releases/download/v1.1.0/teams-cli-darwin-arm64 -o teams-cli
chmod +x teams-cli
sudo mv teams-cli /usr/local/bin/teams-cli

# Test the installation
echo "Testing the teams-cli installation by checking the help command"
teams-cli --help

echo "Checking the version"
teams-cli --version

echo "teams-cli installation completed successfully"