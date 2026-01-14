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
# 4. Checks if Node.js is available (doesn't install if missing)
# 5. Checks for pnpm or npm (uses whichever is available)
# 6. Installs Node.js dependencies from package.json (if Node.js available)
# 7. Makes all scripts executable
# 8. Creates .env file for API token configuration
# 9. Automatically runs the email fetcher (if Node.js and token configured)
#
# Note: Both Bash and Node.js versions are available. The Bash version
#       works without Node.js. Install Node.js manually if you want to
#       use the JavaScript version with its enhanced features.
#
# Usage:
# ./setup.sh
##############################################################################

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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
echo -e "${BLUE}[1/7] Checking Homebrew...${NC}"
if command_exists brew; then
    echo -e "${GREEN}✓ Homebrew is already installed${NC}"
else
    install_homebrew
fi
echo ""

# Check and install jq
echo -e "${BLUE}[2/7] Checking jq (JSON parser)...${NC}"
if command_exists jq; then
    echo -e "${GREEN}✓ jq is already installed${NC}"
    jq --version
else
    install_package jq
fi
echo ""

# Check and install fzf
echo -e "${BLUE}[3/7] Checking fzf (fuzzy finder)...${NC}"
if command_exists fzf; then
    echo -e "${GREEN}✓ fzf is already installed${NC}"
    fzf --version
else
    install_package fzf
fi
echo ""

# Get script directory (needed for later steps)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check Node.js (don't install if missing)
echo -e "${BLUE}[4/7] Checking Node.js...${NC}"
if command_exists node; then
    echo -e "${GREEN}✓ Node.js is already installed${NC}"
    node --version
    NODE_AVAILABLE=true
else
    echo -e "${YELLOW}⚠ Node.js is not installed${NC}"
    echo -e "${YELLOW}  Skipping Node.js dependency installation${NC}"
    echo -e "${YELLOW}  Install Node.js to use the JavaScript version of this tool${NC}"
    NODE_AVAILABLE=false
fi
echo ""

# Check package manager (pnpm or npm)
if [ "$NODE_AVAILABLE" = true ]; then
    echo -e "${BLUE}[5/7] Checking package manager...${NC}"
    if command_exists pnpm; then
        echo -e "${GREEN}✓ pnpm is available${NC}"
        pnpm --version
        PACKAGE_MANAGER="pnpm"
    elif command_exists npm; then
        echo -e "${GREEN}✓ npm is available (will use npm instead of pnpm)${NC}"
        npm --version
        PACKAGE_MANAGER="npm"
    else
        echo -e "${RED}✗ Neither pnpm nor npm is available${NC}"
        PACKAGE_MANAGER=""
    fi
    echo ""
else
    echo -e "${BLUE}[5/7] Skipping package manager check...${NC}"
    echo -e "${YELLOW}⚠ Node.js not available${NC}"
    echo ""
    PACKAGE_MANAGER=""
fi

# Install Node.js dependencies
if [ "$NODE_AVAILABLE" = true ] && [ -n "$PACKAGE_MANAGER" ]; then
    echo -e "${BLUE}[6/7] Installing Node.js dependencies...${NC}"
    cd "$SCRIPT_DIR"
    if $PACKAGE_MANAGER install; then
        echo -e "${GREEN}✓ Node.js dependencies installed successfully using $PACKAGE_MANAGER${NC}"
    else
        echo -e "${RED}✗ Failed to install Node.js dependencies${NC}"
        echo -e "${YELLOW}⚠ The JavaScript version may not work properly${NC}"
    fi
    echo ""
else
    echo -e "${BLUE}[6/7] Skipping Node.js dependency installation...${NC}"
    if [ "$NODE_AVAILABLE" = false ]; then
        echo -e "${YELLOW}⚠ Node.js is not installed${NC}"
    else
        echo -e "${YELLOW}⚠ No package manager available${NC}"
    fi
    echo ""
fi

# Make the scripts executable
echo -e "${BLUE}[7/7] Setting execute permissions...${NC}"
MAIN_SCRIPT="$SCRIPT_DIR/fetch_all_groove_emails.sh"
PUBLISH_SCRIPT="$SCRIPT_DIR/publish-to-github.sh"

if [ -f "$MAIN_SCRIPT" ]; then
    chmod +x "$MAIN_SCRIPT"
    echo -e "${GREEN}✓ Execute permissions set on fetch_all_groove_emails.sh${NC}"
else
    echo -e "${RED}✗ Could not find fetch_all_groove_emails.sh${NC}"
    echo "Make sure setup.sh is in the same directory as fetch_all_groove_emails.sh"
    exit 1
fi

if [ -f "$PUBLISH_SCRIPT" ]; then
    chmod +x "$PUBLISH_SCRIPT"
    echo -e "${GREEN}✓ Execute permissions set on publish-to-github.sh${NC}"
else
    echo -e "${YELLOW}⚠ publish-to-github.sh not found (optional)${NC}"
fi
echo ""

# Make JavaScript file executable
JS_SCRIPT="$SCRIPT_DIR/fetch_all_groove_emails.js"
if [ -f "$JS_SCRIPT" ]; then
    chmod +x "$JS_SCRIPT"
    echo -e "${GREEN}✓ Execute permissions set on fetch_all_groove_emails.js${NC}"
else
    echo -e "${YELLOW}⚠ fetch_all_groove_emails.js not found${NC}"
fi
echo ""

# Create .env file if it doesn't exist
echo -e "${BLUE}Checking .env configuration...${NC}"
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

# Check if AUTH_TOKEN is set and Node.js is available
if grep -q "your_groove_api_token_here" "$ENV_FILE" 2>/dev/null; then
    echo -e "${YELLOW}⚠ WARNING: You need to configure your API token before running!${NC}"
    echo -e "${YELLOW}  1. Open .env in a text editor${NC}"
    echo -e "${YELLOW}  2. Replace 'your_groove_api_token_here' with your actual token${NC}"
    echo -e "${YELLOW}  3. Save the file${NC}"
    echo ""
    echo -e "${YELLOW}Skipping automatic script execution until token is configured.${NC}"
    echo ""
    echo "After configuring your token, run:"
    if [ "$NODE_AVAILABLE" = true ]; then
        echo -e "${CYAN}  node fetch_all_groove_emails.js${NC}"
        echo ""
        echo "Or the Bash version:"
    fi
    echo -e "${CYAN}  ./fetch_all_groove_emails.sh${NC}"
elif [ "$NODE_AVAILABLE" = true ]; then
    echo -e "${GREEN}✓ API token is configured${NC}"
    echo ""
    echo -e "${BLUE}Starting Groove Email Fetcher...${NC}"
    echo ""
    node "$SCRIPT_DIR/fetch_all_groove_emails.js"
else
    echo -e "${YELLOW}⚠ API token is configured but Node.js is not available${NC}"
    echo ""
    echo "To run the Bash version:"
    echo -e "${CYAN}  ./fetch_all_groove_emails.sh${NC}"
fi
echo ""
