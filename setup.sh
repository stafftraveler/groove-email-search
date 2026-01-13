#!/bin/bash

##############################################################################
# Groove API Email Fetcher - Setup Script
# 
# This script installs all required dependencies and sets up the environment
# for the Groove API Email Fetcher
#
# What it does:
# 1. Checks if Homebrew is installed (installs if missing)
# 2. Installs jq (JSON parser)
# 3. Installs fzf (fuzzy finder)
# 4. Makes the main script executable
# 5. Creates .env file for API token configuration
#
# Usage:
# ./setup.sh
##############################################################################

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Groove Email Fetcher - Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to install Homebrew
install_homebrew() {
    echo -e "${YELLOW}Homebrew is not installed. Installing now...${NC}"
    echo ""
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Check if installation was successful
    if command_exists brew; then
        echo -e "${GREEN}✓ Homebrew installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install Homebrew${NC}"
        echo "Please install Homebrew manually from https://brew.sh"
        exit 1
    fi
    echo ""
}

# Function to install a package via Homebrew
install_package() {
    local package=$1
    echo -e "${YELLOW}Installing $package...${NC}"
    if brew install "$package"; then
        echo -e "${GREEN}✓ $package installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install $package${NC}"
        exit 1
    fi
    echo ""
}

# Check and install Homebrew
echo -e "${BLUE}[1/4] Checking Homebrew...${NC}"
if command_exists brew; then
    echo -e "${GREEN}✓ Homebrew is already installed${NC}"
else
    install_homebrew
fi
echo ""

# Check and install jq
echo -e "${BLUE}[2/4] Checking jq (JSON parser)...${NC}"
if command_exists jq; then
    echo -e "${GREEN}✓ jq is already installed${NC}"
    jq --version
else
    install_package jq
fi
echo ""

# Check and install fzf
echo -e "${BLUE}[3/4] Checking fzf (fuzzy finder)...${NC}"
if command_exists fzf; then
    echo -e "${GREEN}✓ fzf is already installed${NC}"
    fzf --version
else
    install_package fzf
fi
echo ""

# Make the main script executable
echo -e "${BLUE}[4/5] Setting execute permissions...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/fetch_all_groove_emails.sh"

if [ -f "$MAIN_SCRIPT" ]; then
    chmod +x "$MAIN_SCRIPT"
    echo -e "${GREEN}✓ Execute permissions set on fetch_all_groove_emails.sh${NC}"
else
    echo -e "${RED}✗ Could not find fetch_all_groove_emails.sh${NC}"
    echo "Make sure setup.sh is in the same directory as fetch_all_groove_emails.sh"
    exit 1
fi
echo ""

# Create .env file if it doesn't exist
echo -e "${BLUE}[5/5] Checking .env configuration...${NC}"
ENV_FILE="$SCRIPT_DIR/.env"
ENV_EXAMPLE="$SCRIPT_DIR/.env.example"

if [ -f "$ENV_FILE" ]; then
    echo -e "${GREEN}✓ .env file already exists${NC}"
else
    if [ -f "$ENV_EXAMPLE" ]; then
        cp "$ENV_EXAMPLE" "$ENV_FILE"
        echo -e "${YELLOW}⚠ Created .env file from template${NC}"
        echo -e "${YELLOW}⚠ Please edit .env and add your Groove API token${NC}"
    else
        echo -e "${YELLOW}⚠ .env.example not found, creating .env manually...${NC}"
        cat > "$ENV_FILE" << 'EOF'
# Groove API Configuration
# Add your actual token below

# Your Groove API Bearer Token
AUTH_TOKEN=your_groove_api_token_here
EOF
        echo -e "${YELLOW}⚠ Created .env file${NC}"
        echo -e "${YELLOW}⚠ Please edit .env and add your Groove API token${NC}"
    fi
fi
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "All dependencies are installed and configured."
echo ""
echo -e "${YELLOW}IMPORTANT: Before running the script, edit your .env file:${NC}"
echo -e "${YELLOW}  1. Open .env in a text editor${NC}"
echo -e "${YELLOW}  2. Replace 'your_groove_api_token_here' with your actual token${NC}"
echo -e "${YELLOW}  3. Save the file${NC}"
echo ""
echo "To run the Groove Email Fetcher:"
echo -e "${CYAN}  ./fetch_all_groove_emails.sh${NC}"
echo ""
echo "Or from anywhere:"
echo -e "${CYAN}  $MAIN_SCRIPT${NC}"
echo ""
