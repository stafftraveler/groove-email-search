# Groove Email Search

> Fetch and export contacts from Groove emails with an interactive CLI

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

A command-line tool to search and export contact information from Groove emails using their GraphQL API. Features an interactive fzf-powered interface for easy navigation and supports both JSON and CSV exports.

## ✨ Highlights

- 🎨 **Beautiful Interactive UI** - fzf-powered fuzzy finder interface
- 🔍 **Flexible Search** - Search by text content or tags
- 📊 **Multiple Formats** - Export as JSON or CSV to `export/` folder
- 🚀 **Fast** - Fetches 50 emails per page with automatic pagination
- 🔐 **Secure** - Environment variable-based API token management
- ⚡ **Easy Setup** - One-command installation

## ⚡ Quick Setup

**First time setup (installs dependencies automatically):**

```bash
chmod +x setup.sh
./setup.sh
```

This will:

- Install Homebrew (if not installed)
- Install jq (JSON parser)
- Install fzf (fuzzy finder)
- Make the main script executable
- Create a .env file for your API token

**Configure your API token:**

```bash
# Edit the .env file
nano .env

# Add your Groove API token:
AUTH_TOKEN=your_actual_groove_api_token_here
```

**Then run the fetcher:**

```bash
./fetch_all_groove_emails.sh
```

For detailed setup instructions and troubleshooting, see [SETUP_GUIDE.md](SETUP_GUIDE.md).

## 🔐 Security Best Practices

This project uses a `.env` file to keep your API token secure:

- ✅ `.env` is in `.gitignore` - your token won't be committed to git
- ✅ `.env.example` provides a template without sensitive data
- ✅ Scripts validate the token exists before running
- ⚠️ Never commit your actual `.env` file to version control
- ⚠️ Keep your API token private and secure

## 📊 Features

- **Interactive menus with fzf**: Beautiful fuzzy-finder interface for selections
- **Search by body text**: Find emails containing specific text
- **Search by tag**: Find emails with a specific tag
- **Multiple export formats**: Choose between JSON or CSV output
- **Keyboard navigation**: Use arrow keys to navigate, type to filter options
- **Pagination**: Automatically fetches all results across multiple pages
- **Progress tracking**: Shows real-time progress as emails are fetched
- **Statistics**: Displays total contacts and unique emails

## 📖 Manual Installation (Optional)

If you prefer not to use the setup script, you can install dependencies manually:

```bash
brew install jq fzf
chmod +x fetch_all_groove_emails.sh
```

## 🎨 Interactive fzf Interface

This script uses [fzf](https://github.com/junegunn/fzf) for a modern, user-friendly selection experience:

- **Visual navigation**: Use ↑↓ arrow keys instead of typing numbers
- **Fuzzy search**: Type any part of an option to filter instantly
- **No typos**: Select with Enter, cancel with ESC
- **Professional UI**: Clean, bordered interface with visual feedback

See [FZF_GUIDE.md](FZF_GUIDE.md) for detailed usage instructions and tips.

## 🚀 Alternative: Node.js Script

If you prefer Node.js over Bash, or need better cross-platform compatibility, you can use the Node.js version:

**First time setup:**

```bash
npm install
```

**Configure your API token:**

Edit the `.env` file and add your token (same as the bash version)

**Run the script:**

```bash
node fetch_all_groove_emails.js
# or
npm start
```

**Features:**

- ✨ Uses `@inquirer/prompts` for elegant interactive prompts
- 🎨 Colored console output
- 🔍 Same search functionality (body text or tags)
- 📊 Same export options (JSON or CSV)
- 🌍 Cross-platform compatible (Windows, macOS, Linux)

## 📁 Output

All results are automatically saved to the `export/` folder. The script can export results in two formats:

### JSON Format (`export/groove_all_contacts.json`)

```json
[
  {
    "firstName": "Alice",
    "lastName": "Johnson",
    "email": "alice.johnson@example.com"
  },
  {
    "firstName": "Bob",
    "lastName": "Smith",
    "email": "bob.smith@example.com"
  }
  // ... more contacts
]
```

### CSV Format (`export/groove_all_contacts.csv`)

```csv
firstName,lastName,email
Alice,Johnson,alice.johnson@example.com
Bob,Smith,bob.smith@example.com
Carol,Williams,carol.williams@example.com
David,Brown,david.brown@example.com
Emma,Davis,emma.davis@example.com
```

The CSV format is ideal for:

- Importing into spreadsheet applications (Excel, Google Sheets)
- Importing into email marketing tools
- Bulk data processing

## 🔍 Search Types

### 1. Body Text Search

Searches for emails that contain specific text in the email body.

**Example queries:**

- "You voted for these StaffTraveler PRO"
- "password reset"
- "refund request"
- Any text you want to find in email content

### 2. Tag Search

Searches for emails that have been tagged with a specific tag.

**Example tags:**

- "StaffTraveler PRO Features"
- "Bug Report"
- "Feature Request"
- Any tag that exists in your Groove system

## 🔧 How It Works

1. **Search Type Selection**: Prompts you to choose between body text or tag search
2. **Query Input**: Asks for your search query or tag name
3. **Export Format Selection**: Choose between JSON or CSV output
4. **Initial Request**: Makes a POST request to the Groove GraphQL API with cursor set to `null`
5. **Pagination**: Uses the `endCursor` from each response to fetch the next page
6. **Extraction**: Extracts `firstName`, `lastName`, and `email` from each conversation's contact
7. **Loop**: Continues until `hasNextPage` is `false`
8. **Export**: Saves all contacts in your chosen format (JSON or CSV)

## 📊 Example Usage

### Searching for Feedback Emails

```bash
./fetch_all_groove_emails.sh

# Choose: 1 (Emails with text in the body)
# Enter: You voted for these StaffTraveler PRO
```

Expected output: ~850 contacts from feedback emails

### Searching by Tag

```bash
./fetch_all_groove_emails.sh

# Choose: 2 (Emails tagged with a specific tag)
# Enter: StaffTraveler PRO Features
```

Expected output: All contacts from emails with that tag

## 🔐 Authentication

The scripts use a pre-configured Bearer token. If the token expires or you need to update it:

1. Open the script file (`fetch_all_groove_emails.sh` or `fetch_all_groove_emails.js`)
2. Update the `AUTH_TOKEN` or `authToken` variable
3. Save and re-run the script

## ⚠️ Important Notes

- The scripts include a 500ms delay between requests to avoid rate limiting
- All responses are temporarily saved for debugging in case of errors
- If the script is interrupted, it will save whatever data was fetched up to that point
- The API returns conversations that contain the search text "You voted for these StaffTraveler PRO"

## 🐛 Troubleshooting

### "jq: command not found"

Install jq as shown in the prerequisites section above.

### "Empty response received"

- Check your internet connection
- Verify the API token is still valid
- Check if the API endpoint has changed

### "API Error: ..."

The API returned an error. Check the error message and verify:

- The authorization token is correct
- The API endpoint is correct
- You have proper permissions

## 📤 Publishing to GitHub

This project includes a helper script to publish to GitHub:

```bash
./publish-to-github.sh
```

**Prerequisites:**

- GitHub CLI (gh) installed: `brew install gh`
- Authenticated with GitHub: `gh auth login`
- Member of stafftraveler organization with repo creation permissions

The script will:

1. Prompt you for the repository name and description
2. Create the repository in the stafftraveler organization
3. Initialize git (if needed)
4. Add the remote
5. Create an initial commit
6. Push to GitHub

## 📝 Files Included

- `setup.sh` - Automated setup script (installs bash dependencies)
- `fetch_all_groove_emails.sh` - Bash script with fzf interactive interface
- `fetch_all_groove_emails.js` - Node.js script with @inquirer/prompts
- `package.json` - Node.js dependencies configuration
- `publish-to-github.sh` - Helper script to publish repository to GitHub
- `.env.example` - Template for environment variables (copy to .env)
- `.gitignore` - Ensures .env and output files aren't committed
- `export/` - Output directory for exported contacts
  - `groove_contacts_sample.json` - Sample data (20 fictional contacts)
  - `groove_contacts_sample.csv` - Sample data in CSV format
  - `groove_all_contacts.json/csv` - Your exported results (auto-generated)
- `README.md` - This file
- `SETUP_GUIDE.md` - Detailed setup instructions
- `EXAMPLE_OUTPUT.md` - Example script outputs
- `FZF_GUIDE.md` - Guide to using fzf interactive menus

## 🔄 API Details

**Endpoint**: `https://api.groovehq.com/v2/graphql?_TicketConversationsQuery`

**Method**: POST

**Query Type**: GraphQL

**Search Filters**:

- Body text: `filter: { keywords: "your search text" }`
- Tags: `filter: { tagNames: ["Your Tag"] }`

**Order**: Newest by collaborator comment

**Page Size**: 50 items per request

---

Made with ❤️ by the StaffTraveler team
