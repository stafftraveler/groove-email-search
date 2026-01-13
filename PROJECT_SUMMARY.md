# Project Summary: Groove Email Search

## Overview
A command-line tool for searching and exporting contact information from Groove emails using their GraphQL API.

## Key Features
- Interactive fzf-powered CLI interface
- Search by text content or tags
- Export contacts as JSON or CSV
- Secure environment variable configuration
- Automated dependency installation
- Comprehensive documentation

## Technology Stack
- **Bash** - Main scripting language
- **Node.js** - Alternative implementation
- **fzf** - Interactive fuzzy finder
- **jq** - JSON processing
- **Groove GraphQL API** - Data source

## Project Structure
```
groove-email-search/
├── .env.example              # Environment variable template
├── .gitignore               # Git ignore rules
├── .github/
│   └── workflows/
│       └── validate.yml     # CI validation workflow
├── LICENSE                  # MIT License
├── README.md                # Main documentation
├── CONTRIBUTING.md          # Contribution guidelines
├── SETUP_GUIDE.md          # Detailed setup instructions
├── PUBLISHING.md           # GitHub publishing guide
├── EXAMPLE_OUTPUT.md       # Example outputs
├── FZF_GUIDE.md           # fzf usage guide
├── setup.sh                # Automated setup script
├── fetch_all_groove_emails.sh  # Main bash script
├── fetch_all_groove_emails.js  # Node.js alternative
├── publish-to-github.sh    # GitHub publishing helper
└── export/                 # Export folder for results
    ├── groove_contacts_sample.json  # Sample JSON data
    └── groove_contacts_sample.csv   # Sample CSV data
```

## Repository Information
- **Organization**: stafftraveler
- **Repository**: groove-email-search
- **URL**: https://github.com/stafftraveler/groove-email-search
- **License**: MIT
- **Visibility**: Public (recommended)

## Quick Start for Users
```bash
# 1. Clone repository
git clone https://github.com/stafftraveler/groove-email-search.git
cd groove-email-search

# 2. Run setup
chmod +x setup.sh
./setup.sh

# 3. Configure API token
nano .env
# Add: AUTH_TOKEN=your_token

# 4. Run the tool
./fetch_all_groove_emails.sh
```

## Security Features
- ✅ No hardcoded API tokens
- ✅ .env file excluded from git
- ✅ Token validation before execution
- ✅ CI checks for security issues
- ✅ Clear documentation on security practices

## Documentation
| File | Purpose |
|------|---------|
| README.md | Main project documentation with quick start |
| SETUP_GUIDE.md | Detailed installation and configuration |
| CONTRIBUTING.md | Contribution guidelines for developers |
| PUBLISHING.md | Instructions for publishing to GitHub |
| EXAMPLE_OUTPUT.md | Example CLI outputs and interactions |
| FZF_GUIDE.md | Guide to using the fzf interface |

## Maintenance
- Regular dependency updates via Homebrew
- CI validation on all pushes
- Security checks for exposed tokens
- Syntax validation for scripts

## Future Enhancements (Potential)
- Additional export formats (Excel, XML)
- Advanced filtering options
- Rate limiting configuration
- Batch processing support
- Progress persistence/resume
- API response caching

## Support Channels
- GitHub Issues for bug reports
- Pull Requests for contributions
- StaffTraveler team for internal support

## Version History
- **v1.0.0** (Initial Release)
  - Interactive CLI with fzf
  - Text and tag-based search
  - JSON and CSV export
  - Environment variable configuration
  - Automated setup script
  - Comprehensive documentation
