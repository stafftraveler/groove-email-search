#!/bin/bash

##############################################################################
# GitHub Publishing Helper
#
# This script helps you publish the Groove Email Search project to GitHub
#
# Prerequisites:
# - GitHub CLI (gh) installed: brew install gh
# - Authenticated with GitHub: gh auth login
# - Member of stafftraveler organization with repo creation permissions
#
# Usage:
# ./publish-to-github.sh
##############################################################################

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}GitHub Publishing Helper${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo ""
    echo "Install it with:"
    echo "  brew install gh"
    echo ""
    echo "Then authenticate:"
    echo "  gh auth login"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Not authenticated with GitHub${NC}"
    echo ""
    echo "Run: gh auth login"
    exit 1
fi

echo -e "${GREEN}✓ GitHub CLI is installed and authenticated${NC}"
echo ""

# Repository details
ORG="stafftraveler"

# Prompt for repository name
echo -e "${BLUE}Repository Configuration${NC}"
echo ""
read -p "Enter repository name: " REPO

if [ -z "$REPO" ]; then
    echo -e "${RED}Error: Repository name cannot be empty${NC}"
    exit 1
fi

# Prompt for description
read -p "Enter repository description: " DESCRIPTION

if [ -z "$DESCRIPTION" ]; then
    echo -e "${YELLOW}Warning: No description provided${NC}"
    DESCRIPTION=""
fi

echo ""
echo -e "${BLUE}Repository Details:${NC}"
echo "  Organization: $ORG"
echo "  Repository: $REPO"
echo "  Description: $DESCRIPTION"
echo ""

# Confirm
read -p "Continue with publishing? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Publishing cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}Creating repository...${NC}"

# Create the repository
if gh repo create "$ORG/$REPO" \
    --public \
    --description "$DESCRIPTION" \
    --clone=false; then
    echo -e "${GREEN}✓ Repository created${NC}"
else
    echo -e "${RED}✗ Failed to create repository${NC}"
    echo ""
    echo "If the repository already exists, you can manually add the remote:"
    echo "  git remote add origin git@github.com:$ORG/$REPO.git"
    exit 1
fi

echo ""
echo -e "${YELLOW}Initializing git repository...${NC}"

# Initialize git if needed
if [ ! -d ".git" ]; then
    git init
    echo -e "${GREEN}✓ Git initialized${NC}"
else
    echo -e "${GREEN}✓ Git already initialized${NC}"
fi

# Add remote
if ! git remote | grep -q "origin"; then
    git remote add origin "git@github.com:$ORG/$REPO.git"
    echo -e "${GREEN}✓ Remote added${NC}"
else
    echo -e "${GREEN}✓ Remote already exists${NC}"
fi

echo ""
echo -e "${YELLOW}Staging files...${NC}"

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'EOF'
# Environment variables (contains sensitive API tokens)
.env

# Output files (excluding samples)
export/groove_all_contacts.json
export/groove_all_contacts.csv

# Temporary files
groove_temp_*

# macOS
.DS_Store

# Node.js
node_modules/
npm-debug.log
EOF
    echo -e "${GREEN}✓ Created .gitignore${NC}"
fi

# Stage all files
git add .
echo -e "${GREEN}✓ Files staged${NC}"

echo ""
echo -e "${YELLOW}Creating initial commit...${NC}"

# Initial commit
git commit -m "Initial commit: Groove Email Search

- Interactive CLI with fzf
- Search by text content or tags
- Export as JSON or CSV
- Secure .env-based configuration
- Automated setup script
- Comprehensive documentation"

echo -e "${GREEN}✓ Commit created${NC}"

echo ""
echo -e "${YELLOW}Pushing to GitHub...${NC}"

# Push to GitHub
git branch -M main
git push -u origin main

echo -e "${GREEN}✓ Pushed to GitHub${NC}"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Publishing Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Repository URL:"
echo -e "${CYAN}  https://github.com/$ORG/$REPO${NC}"
echo ""
echo "Next steps:"
echo "  1. Visit the repository on GitHub"
echo "  2. Review the README"
echo "  3. Add topics/tags (groove, api, cli, etc.)"
echo "  4. Invite collaborators if needed"
echo ""
