#!/bin/bash

# Toralizer Installation Script
# This script builds and installs the Toralizer project from source.

# Paths
SRC_DIR="src"                              # Source directory
MAKEFILE="$SRC_DIR/Makefile"               # Path to the Makefile
BINARY_NAME="toralize.so"                  # Name of the binary file
HEADER_NAME="toralize.h"                   # Name of the header file
BINARY_PATH="$SRC_DIR/$BINARY_NAME"        # Full path to the binary file
HEADER_PATH="$SRC_DIR/$HEADER_NAME"        # Full path to the header file
TARGET_BIN_PATH="/usr/local/bin"           # Global binary installation path
TARGET_INCLUDE_PATH="/usr/local/include"  # Global header installation path

# Function to check if Tor is installed
is_tor_installed() {
    if command -v tor >/dev/null 2>&1; then
        echo "Tor is installed."
        return 0
    else
        echo "Tor is not installed."
        return 1
    fi
}

# Function to install Tor
install_tor() {
    echo "Attempting to install Tor..."
    if [[ "$(uname -s)" == "Linux" ]]; then
        sudo apt update && sudo apt install -y tor
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        if command -v brew >/dev/null 2>&1; then
            brew install tor
        else
            echo "Homebrew is not installed. Please install Homebrew and rerun this script."
            exit 1
        fi
    else
        echo "Unsupported operating system. Please install Tor manually."
        exit 1
    fi
}

# Function to build the project using the Makefile
build_project() {
    echo "Building the project using Makefile..."
    if [[ -f "$MAKEFILE" ]]; then
        make -C "$SRC_DIR"
    else
        echo "Makefile not found in $SRC_DIR."
        exit 1
    fi
}

# Function to install the binary
install_binary() {
    echo "Installing the binary ($BINARY_NAME) to $TARGET_BIN_PATH..."
    if [[ -f "$BINARY_PATH" ]]; then
        sudo mv "$BINARY_PATH" "$TARGET_BIN_PATH/"
    else
        echo "Binary file ($BINARY_NAME) not found. Build may have failed."
        exit 1
    fi
}

# Function to install the header file
install_header() {
    echo "Installing the header file ($HEADER_NAME) to $TARGET_INCLUDE_PATH..."
    if [[ -f "$HEADER_PATH" ]]; then
        sudo cp "$HEADER_PATH" "$TARGET_INCLUDE_PATH/"
    else
        echo "Header file ($HEADER_NAME) not found in $SRC_DIR."
        exit 1
    fi
}

# Main Installation Script
echo "Starting Toralizer installation..."

# Check if Tor is installed
if ! is_tor_installed; then
    read -p "Tor is required for this tool to work. Do you want to install Tor now? [y/N]: " choice
    choice=${choice,,} # Convert to lowercase
    if [[ "$choice" == "y" ]]; then
        install_tor
    else
        echo "Tor installation is required. Exiting."
        exit 1
    fi
fi

# Build the project
build_project

# Install the binary and header file
install_binary
install_header

echo "Installation completed successfully! The binary and header file are now globally accessible."
