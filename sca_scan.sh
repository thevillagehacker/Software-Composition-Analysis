#!/bin/bash

# Set Workspace folder

cd ~
mkdir SCA
cd ~/SCA

# Clean up existing setup
echo "[+] Cleaning up..."
sudo rm -r *

# OWASP Dependency Check installation

function ODCi {

    echo "[*] Setting up OWASP Dependency check..."
    # Define the file and folder names
    file_name="dependency-check-9.0.9-release.zip"
    folder_name="dependency-check"

    # Check if the folder exists
    if [ -d "$folder_name" ]; then
        echo "[*] $folder_name already exists. Skipping unzip."
    else
        # Check if the file exists
        echo "[*] Downloading OWASP Dependency check Script..."
        wget -q --show-progress "https://github.com/jeremylong/DependencyCheck/releases/download/v9.0.9/dependency-check-9.0.9-release.zip"
        if [ -e "$file_name" ]; then
            echo "[*] Unzipping OWASP Dependency check..."
            unzip -q "$file_name"
        else
            echo "[-] Error: $file_name not found."
        fi
    fi
}

# Run OWASP Dependency Check

output=$1
dir=$2

function owasp_dependency_check {
    chmod +x ~/SCA/dependency-check/bin/dependency-check.sh
    ~/SCA/dependency-check/bin/dependency-check.sh --out "$output" --scan "$dir"
}

# NPM Audit begin

function npm_audit {

# Check if npm is installed

if command -v npm &> /dev/null; then
    npm_version=$(npm --version)
    echo "[+] npm is already installed. Version: $npm_version"
else
    echo "[-] npm not found. Installing npm..."
    sudo apt-get update
    sudo apt-get install npm
fi

echo "[+] Initiating NPM audit..."
echo "[+] Checking for node-modules target..."

cd "$dir"

# folder name and file name
folder_name="node_modules"
lock_file="package-lock.json"

# Check if the folder exists
if [ -d "$folder_name" ]; then
    cd "$folder_name"
    echo "[+] Getting into $folder_name"
    
    if [ -e "$lock_file" ]; then
        echo "[+] $lock_file found in $folder_name"
        npm audit
    else
        echo "[-] $lock_file not found in $folder_name"
    fi       
else
    echo "[-] $folder_name not found"
    echo "[+] Checking for $lock_file in the current working directory"
    
    if [ -e "$lock_file" ]; then
        echo "[+] $lock_file found in the current working directory"
        npm audit
    else
        echo "[-] $lock_file not found in the current working directory"
    fi
fi
}

# Snyk audit begin

# Snyk setup

function snyk_run {

echo "[+] Initiating Snyk audit..."
echo "[+] Snyk setup started..."

cd ~/SCA
wget -q --show-progress https://static.snyk.io/cli/latest/snyk-linux
chmod +x snyk-linux
sudo mv snyk-linux /usr/local/bin/

# Snyk configure

echo "[+] Authenticate snyk... you will be redirected to a web page"
if snyk auth; then
    echo "[+] Authentication successful"
    cd "$dir"
else
    echo "[-] Authentication failed. Please check your credentials."
fi

# Run snyk

# Check if the folder exists
if [ -d "$folder_name" ]; then
    cd "$folder_name"
    echo "[+] Getting into $folder_name"
    
    if [ -e "$lock_file" ]; then
        echo "[+] $lock_file found in $folder_name"
        snyk test
    else
        echo "[-] $lock_file not found in $folder_name"
    fi       
else
    echo "[-] $folder_name not found"
    echo "[+] Checking for $lock_file in the current working directory"
    
    if [ -e "$lock_file" ]; then
        echo "[+] $lock_file found in the current working directory"
        snyk test
    else
        echo "[-] $lock_file not found in the current working directory"
    fi
fi
}

# Run all
ODCi
owasp_dependency_check
npm_audit
snyk_run