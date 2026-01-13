# AI Agent Instructions

This document guides AI coding assistants on working with this codebase and developing similar tools.

## Project Overview

This is a command-line tool that interacts with an external API. It features:

- Interactive CLI with fuzzy-finder interface (fzf)
- Both Bash and Node.js implementations
- Environment-based configuration (.env files)
- Export functionality (JSON and CSV formats)
- Automated setup and publishing scripts

## Key Design Principles

### 1. Security First

- **Never hardcode API tokens or secrets** in scripts
- All sensitive credentials must be stored in `.env` files
- Always ensure `.env` is in `.gitignore`
- Validate that required environment variables exist before running

### 2. User Experience

- Use interactive menus (fzf for Bash, @inquirer/prompts for Node.js)
- Provide clear, colored console output with status indicators (✓, ✗, ⚠)
- Show progress during long-running operations
- Include helpful error messages with suggested fixes

### 3. Cross-Platform Compatibility

- Bash scripts are optimized for macOS/Linux
- Node.js scripts provide general compatibility
- Use platform-agnostic paths where possible
- Document platform-specific requirements

### 4. Setup Automation

- Include a `setup.sh` script that:
  - Checks for required dependencies
  - Installs missing dependencies (with user consent)
  - Sets execute permissions on scripts
  - Creates configuration files from templates
- Make the setup process one-command simple

## Code Structure Guidelines

### Scripts Should Include:

1. **Header Comments**: Clear description of what the script does, prerequisites, and usage
2. **Color Variables**: Define color codes for consistent output formatting
3. **Error Handling**: Check for prerequisites, validate inputs, handle API errors gracefully
4. **Progress Indicators**: Show what's happening during execution
5. **Help/Usage Information**: Make it easy for users to understand how to use the tool

### File Organization:

```
project/
├── setup.sh              # One-command setup
├── main_script.sh        # Primary bash implementation
├── main_script.js        # Alternative Node.js implementation
├── publish-to-github.sh  # Repository publishing helper
├── package.json          # Node.js dependencies
├── .env.example          # Template for environment variables
├── .gitignore           # Protect sensitive files
├── export/              # Output directory
│   ├── README.md        # Explain what goes here
│   └── samples/         # Example output files
├── README.md            # Main documentation
├── SETUP_GUIDE.md       # Detailed setup instructions
└── AGENTS.md            # This file
```

## Common Patterns

### Environment Variables

```bash
# Load from .env file
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found"
    exit 1
fi

# Validate required variables
if [ -z "$API_TOKEN" ]; then
    echo "Error: API_TOKEN not set in .env"
    exit 1
fi
```

### Interactive Menus with fzf

```bash
CHOICE=$(echo -e "Option 1\nOption 2\nOption 3" | fzf \
    --height=40% \
    --border=rounded \
    --prompt="Select an option: " \
    --header="Choose one:")
```

### Progress Indicators

```bash
echo -e "${BLUE}[1/4] Checking dependencies...${NC}"
echo -e "${GREEN}✓ Task completed${NC}"
echo -e "${YELLOW}⚠ Warning message${NC}"
echo -e "${RED}✗ Error occurred${NC}"
```

### API Pagination

```bash
CURSOR="null"
HAS_NEXT_PAGE=true
PAGE=1

while [ "$HAS_NEXT_PAGE" = "true" ]; do
    # Make API request with cursor
    RESPONSE=$(curl -X POST "$API_ENDPOINT" \
        -H "Authorization: Bearer $API_TOKEN" \
        -d "{\"cursor\": $CURSOR}")

    # Extract next cursor and hasNextPage
    CURSOR=$(echo "$RESPONSE" | jq -r '.data.pageInfo.endCursor')
    HAS_NEXT_PAGE=$(echo "$RESPONSE" | jq -r '.data.pageInfo.hasNextPage')

    PAGE=$((PAGE + 1))
done
```

## When Making Changes

### Adding New Features:

1. Implement in both Bash and Node.js versions (if both exist)
2. Update README.md with usage examples
3. Add to SETUP_GUIDE.md if setup steps change
4. Test on multiple platforms if possible

### Updating Dependencies:

1. Check if Homebrew packages need updating (Bash version)
2. Update package.json with correct version ranges (Node.js version)
3. Document new prerequisites in README.md
4. Update setup.sh to handle new dependencies

### Modifying Scripts:

1. Maintain the existing color scheme and output format
2. Keep error messages helpful and actionable
3. Preserve backward compatibility where possible
4. Update inline comments for complex logic

### Security Updates:

1. Never commit actual .env files
2. Audit any new dependencies
3. Validate all user inputs
4. Use HTTPS for all external requests

## Testing Checklist

Before committing changes, verify:

- [ ] Scripts run successfully from a clean environment
- [ ] setup.sh installs all required dependencies
- [ ] Error messages are clear and helpful
- [ ] .env.example is up-to-date
- [ ] README.md reflects all changes
- [ ] Both Bash and Node.js versions work (if applicable)
- [ ] No sensitive data is included in commits
- [ ] Output files go to the correct directory
- [ ] Scripts are executable (chmod +x)

## Publishing Checklist

When preparing to publish:

- [ ] Remove all sensitive data (tokens, internal URLs)
- [ ] Verify .gitignore is comprehensive
- [ ] Include sample data files (with fictional data)
- [ ] Test setup.sh on a fresh machine
- [ ] Run publish-to-github.sh to create repository
- [ ] Add repository topics/tags on GitHub
- [ ] Review README for accuracy and completeness

## Common Pitfalls to Avoid

1. **Hardcoded Values**: Use variables and .env for configuration
2. **Poor Error Messages**: Always explain what went wrong and how to fix it
3. **Missing Prerequisites**: Check for and install required tools
4. **No Progress Feedback**: Long operations should show progress
5. **Platform Assumptions**: Don't assume macOS when Linux/Windows might be used
6. **Unclear Documentation**: Write for someone who's never seen the code
7. **Committing Secrets**: Triple-check .gitignore before initial commit
8. **Brittle Parsing**: Use proper JSON/CSV parsers, not regex hacks

## Resources

- [Bash Best Practices](https://google.github.io/styleguide/shellguide.html)
- [fzf Documentation](https://github.com/junegunn/fzf)
- [jq Manual](https://stedolan.github.io/jq/manual/)
- [Inquirer.js Prompts](https://github.com/SBoudrias/Inquirer.js)

---

**Remember**: These tools are meant to make developers' lives easier. Prioritize clarity, security, and user experience in every change.
