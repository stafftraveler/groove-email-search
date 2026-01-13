# Setup Guide

## Quick Setup Example

Here's what happens when you run the setup script:

```bash
$ chmod +x setup.sh
$ ./setup.sh

========================================
Groove Email Fetcher - Setup
========================================

[1/5] Checking Homebrew...
✓ Homebrew is already installed

[2/5] Checking jq (JSON parser)...
Installing jq...
✓ jq installed successfully

[3/5] Checking fzf (fuzzy finder)...
Installing fzf...
✓ fzf installed successfully

[4/5] Setting execute permissions...
✓ Execute permissions set on fetch_all_groove_emails.sh

[5/5] Checking .env configuration...
⚠ Created .env file from template
⚠ Please edit .env and add your Groove API token

========================================
Setup Complete!
========================================

All dependencies are installed and configured.

IMPORTANT: Before running the script, edit your .env file:
  1. Open .env in a text editor
  2. Replace 'your_groove_api_token_here' with your actual token
  3. Save the file

To run the Groove Email Fetcher:
  ./fetch_all_groove_emails.sh

Or from anywhere:
  /path/to/fetch_all_groove_emails.sh
```

## What the Setup Script Does

### 1. Checks for Homebrew
If Homebrew is not installed, the script will install it automatically. Homebrew is the package manager for macOS that makes installing software easy.

### 2. Installs jq
jq is a lightweight command-line JSON processor. It's used to parse and manipulate the JSON responses from the Groove API.

### 3. Installs fzf
fzf is a command-line fuzzy finder that provides the interactive menu interface. It makes selecting options fast and intuitive.

### 4. Sets Execute Permissions
Makes the main script executable so you can run it with `./fetch_all_groove_emails.sh`

### 5. Creates .env File
Creates a `.env` file from the `.env.example` template. This file stores your API token securely and is excluded from version control.

## Configuring Your API Token

After setup completes, you need to add your Groove API token:

### Step 1: Open the .env file
```bash
nano .env
# or
open -e .env
# or use your preferred text editor
```

### Step 2: Add your token
Replace `your_groove_api_token_here` with your actual Groove API token:

```bash
# Before:
AUTH_TOKEN=your_groove_api_token_here

# After:
AUTH_TOKEN=8c2e5d37203f9e6b869a4bd7c185a919a77018acf30cad1b12930d5976e2eae1
```

### Step 3: Save the file
Save and close the editor.

### Finding Your Groove API Token
1. Log in to your Groove account
2. Go to Settings → API
3. Generate or copy your API Bearer Token
4. Paste it into your `.env` file

## Security Notes

- ✅ The `.env` file is in `.gitignore` - it won't be committed to git
- ✅ Keep your `.env` file private - never share it or commit it
- ✅ Use `.env.example` as a template for others (without the actual token)
- ⚠️ If you accidentally commit `.env`, rotate your API token immediately

## First Run After Setup

After setup completes, you can immediately run the fetcher:

```bash
$ ./fetch_all_groove_emails.sh

========================================
Groove API Email Fetcher
========================================

What do you want to search for?
┌─ Choose search type: ────────────────────────────────────┐
│ > Emails with text in the body                           │
│   Emails tagged with a specific tag                      │
│                                                           │
│   Use ↑↓ to navigate, Enter to select                    │
│   2/2                                                     │
└───────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Homebrew Installation Prompts
During Homebrew installation, you may be prompted for:
- Your macOS password (this is normal)
- Permission to install Xcode Command Line Tools (press Enter to proceed)

### Manual Installation
If the automatic setup fails, you can install manually:

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install jq fzf

# Make script executable
chmod +x fetch_all_groove_emails.sh
```

### Checking Installation
To verify everything is installed correctly:

```bash
# Check Homebrew
brew --version

# Check jq
jq --version

# Check fzf
fzf --version

# Check script permissions
ls -l fetch_all_groove_emails.sh
# Should show: -rwxr-xr-x (the x means executable)
```

## Updating Dependencies

If you need to update the dependencies later:

```bash
brew update
brew upgrade jq fzf
```

## Uninstalling

To remove the installed dependencies:

```bash
brew uninstall jq fzf
```

Note: This will not uninstall Homebrew itself. If you want to remove Homebrew completely, see: https://docs.brew.sh/FAQ#how-do-i-uninstall-homebrew
