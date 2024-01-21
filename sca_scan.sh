#!/bin/bash

# Set Workspace folder

cd ~
mkdir SCA
cd ~/SCA

# Clean up existing setup
echo -e "\e[92m[+]\e[0m Cleaning up..."
sudo rm -r *

# OWASP Dependency Check installation

function owasp_dependency_check_setup {

    echo -e "\e[94m[*]\e[0m Setting up OWASP Dependency check..."
    # Define the file and folder names
    file_name="dependency-check-9.0.9-release.zip"
    folder_name="dependency-check"

    # Check if the folder exists
    if [ -d "$folder_name" ]; then
        echo -e "\e[94m[*]\e[0m $folder_name already exists. Skipping unzip."
    else
        # Check if the file exists
        echo -e "\e[94m[*]\e[0m Downloading OWASP Dependency check Script..."
        wget -q --show-progress "https://github.com/jeremylong/DependencyCheck/releases/download/v9.0.9/dependency-check-9.0.9-release.zip"
        if [ -e "$file_name" ]; then
            echo -e "\e[94m[*]\e[0m Unzipping OWASP Dependency check..."
            unzip -q "$file_name"
        else
            echo -e "\e[91m[-]\e[0m Error: $file_name not found."
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
    echo -e "\e[92m[+]\e[0m npm is already installed. Version: $npm_version"
else
    echo -e "\e[91m[-]\e[0m npm not found. Installing npm..."
    sudo apt-get update &>/dev/null  # Suppressing stdout
    sudo apt-get install npm -y &>/dev/null  # Suppressing stdout
fi

echo -e "\e[94m[*]\e[0m Initiating NPM audit..."
echo -e "\e[94m[*]\e[0m Checking for node-modules target..."

cd "$dir"

# folder name and file name
folder_name="node_modules"
lock_file="package-lock.json"

# Check if the folder exists
if [ -d "$folder_name" ]; then
    cd "$folder_name"
    echo -e "\e[94m[*]\e[0m Getting into $folder_name"
    
    if [ -e "$lock_file" ]; then
        echo -e "\e[92m[+]\e[0m $lock_file found in $folder_name"
        npm audit
    else
        echo -e "\e[91m[-]\e[0m $lock_file not found in $folder_name"
    fi       
else
    echo -e "\e[91m[-]\e[0m $folder_name not found"
    echo -e "\e[94m[*]\e[0m Checking for $lock_file in the current working directory"
    
    if [ -e "$lock_file" ]; then
        echo -e "\e[92m[+]\e[0m $lock_file found in the current working directory"
        npm audit
    else
        echo -e "\e[91m[-]\e[0m $lock_file not found in the current working directory"
    fi
fi
}

# Snyk audit begin

# Snyk setup

function snyk_run {

echo -e "\e[94m[*]\e[0m Initiating Snyk audit..."
echo -e "\e[94m[*]\e[0m Snyk setup started..."

cd ~/SCA
wget -q --show-progress https://static.snyk.io/cli/latest/snyk-linux
chmod +x snyk-linux
sudo mv snyk-linux /usr/local/bin/snyk

# Snyk configure

echo -e "\e[94m[*]\e[0m Authenticate snyk... you will be redirected to a web page"
if snyk auth; then
    echo -e "\e[92m[+]\e[0m Authentication successful"
    cd "$dir"
else
    echo -e "\e[91m[-]\e[0m Authentication failed. Please check your credentials."
fi

# Run snyk

# folder name and file name
folder_name="node_modules"
lock_file="package-lock.json"

# Check if the folder exists
if [ -d "$folder_name" ]; then
    cd "$folder_name"
    echo -e "\e[94m[*]\e[0m Getting into $folder_name"
    
    if [ -e "$lock_file" ]; then
        echo -e "\e[92m[+]\e[0m $lock_file found in $folder_name"
        snyk test
    else
        echo -e "\e[91m[-]\e[0m $lock_file not found in $folder_name"
    fi       
else
    echo -e "\e[91m[-]\e[0m $folder_name not found"
    echo -e "\e[94m[*]\e[0m Checking for $lock_file in the current working directory"
    
    if [ -e "$lock_file" ]; then
        echo -e "\e[92m[+]\e[0m $lock_file found in the current working directory"
        snyk test
    else
        echo -e "\e[91m[-]\e[0m $lock_file not found in the current working directory"
    fi
fi
}

# Run all
owasp_dependency_check_setup
owasp_dependency_check
npm_audit
snyk_run