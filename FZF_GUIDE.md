# FZF Interactive Menu Guide

## What is fzf?

fzf (fuzzy finder) is a powerful command-line fuzzy finder that provides an interactive, user-friendly way to select options. Instead of typing numbers, you can visually browse and search through options.

## Key Features

### 1. Visual Selection
- **Arrow Keys (↑↓)**: Navigate through options
- **Enter**: Confirm selection
- **ESC**: Cancel and exit

### 2. Fuzzy Search
Type any part of an option to filter the list in real-time:
- Type "tag" → Shows only "Emails tagged with a specific tag"
- Type "body" → Shows only "Emails with text in the body"
- Type "json" → Shows only "JSON" option

### 3. Visual Feedback
```
┌─ Choose search type: ────────────────────────────────────┐
│ > Emails with text in the body                           │  ← Selected (> indicator)
│   Emails tagged with a specific tag                      │  ← Not selected
│                                                           │
│   Use ↑↓ to navigate, Enter to select                    │  ← Header/instructions
│   2/2                                                     │  ← Counter (showing 2 of 2)
└───────────────────────────────────────────────────────────┘
```

## Why fzf is Better

### Before (Traditional Prompts)
```bash
What do you want to search for?
1) Emails with text in the body
2) Emails tagged with a specific tag

Enter your choice (1 or 2): _
```

**Issues:**
- Must remember/type numbers
- No visual preview
- Easy to make typos (typing "3" by accident)
- Can't search/filter options

### After (With fzf)
```bash
What do you want to search for?
┌─ Choose search type: ────────────────────────────────────┐
│ > Emails with text in the body                           │
│   Emails tagged with a specific tag                      │
└───────────────────────────────────────────────────────────┘
```

**Benefits:**
- ✅ Visual, intuitive interface
- ✅ Arrow key navigation
- ✅ Type to filter/search
- ✅ No typo errors
- ✅ Professional appearance

## Advanced Usage

### Filtering While Typing
As you type, fzf filters options in real-time:

```bash
# Type "js"
┌─ Choose export format: ──────────────────────────────────┐
│ > JSON                                                    │
│                                                           │
│   1/2 (1 filtered)                                        │
└───────────────────────────────────────────────────────────┘

# Type "cs"
┌─ Choose export format: ──────────────────────────────────┐
│ > CSV                                                     │
│                                                           │
│   1/2 (1 filtered)                                        │
└───────────────────────────────────────────────────────────┘
```

### Keyboard Shortcuts
- **Ctrl+C** or **ESC**: Cancel selection
- **Tab**: Select/deselect (in multi-select mode, not used in this script)
- **Backspace**: Clear search query
- **Ctrl+U**: Clear entire line
- **Home/End**: Jump to first/last option

## Installation

### macOS (Homebrew)
```bash
brew install fzf
```

### Manual Installation (Alternative)
```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

## Integration in This Script

The Groove Email Fetcher uses fzf for:
1. **Search Type Selection**: Choose between body text or tag search
2. **Export Format Selection**: Choose between JSON or CSV output

This provides a modern, user-friendly experience that's both faster and more intuitive than traditional numbered menus.

## Learn More

- Official GitHub: https://github.com/junegunn/fzf
- Interactive Examples: https://github.com/junegunn/fzf/wiki/examples
- Advanced Configuration: https://github.com/junegunn/fzf/wiki
